<?php

namespace Tests\Feature;

use App\Models\Branch;
use App\Models\Customer;
use App\Models\DigitalProduct;
use App\Models\FinancialAccount;
use App\Models\Product;
use App\Models\Supplier;
use App\Models\User;
use App\Services\SettingService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;

class ExtendedFinanceTest extends TestCase
{
    use RefreshDatabase;

    protected function beforeRefreshingDatabase(): void
    {
        if (config('database.connections.mysql.database') !== 'asp_smart_testing') {
            throw new \RuntimeException('Unsafe test database.');
        }
    }

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
        $this->actingAs(User::where('email', 'owner@aspsmart.local')->first());
        SettingService::put('require_cashier_session', false);
    }

    private function cash(): FinancialAccount
    {
        return FinancialAccount::where('code', 'CASH')->firstOrFail();
    }

    private function tx(array $d)
    {
        return $this->postJson('/api/transactions', $d + ['branch_id' => (string) Branch::first()->id, 'idempotency_key' => (string) Str::uuid()]);
    }

    public function test_string_branch_ids_from_react_work(): void
    {
        $this->tx(['type' => 'sale', 'account_id' => (string) $this->cash()->id, 'items' => [['product_id' => (string) Product::first()->id, 'quantity' => 1]], 'paid_amount' => '50000'])->assertSuccessful();
        $this->assertSame('5025000.00', $this->cash()->current_balance);
    }

    public function test_wallet_topup_and_sale_have_one_revenue(): void
    {
        $c = Customer::create(['code' => 'CW1', 'name' => 'Wallet User']);
        $w = $this->postJson('/api/wallets', ['customer_id' => $c->id, 'branch_id' => Branch::first()->id])->assertSuccessful()->json();
        $this->tx(['type' => 'wallet_topup', 'customer_id' => $c->id, 'account_id' => $this->cash()->id, 'wallet_account_id' => $w['financial_account_id'], 'amount' => '100000'])->assertSuccessful();
        $sale = $this->tx(['type' => 'sale', 'customer_id' => $c->id, 'account_id' => $w['financial_account_id'], 'items' => [['product_id' => Product::first()->id, 'quantity' => 1]]])->assertSuccessful();
        $this->assertSame('5100000.00', $this->cash()->current_balance);
        $this->assertSame('75000.00', FinancialAccount::find($w['financial_account_id'])->current_balance);
        $this->getJson('/api/reports')->assertOk()->assertJsonPath('summary.totals.revenue', '25000.00');
        $this->tx(['type' => 'reversal', 'reversal_of' => $sale->json('data.id'), 'notes' => 'Refund wallet'])->assertSuccessful();
        $this->assertSame('100000.00', FinancialAccount::find($w['financial_account_id'])->current_balance);
    }

    public function test_credit_settlement_then_refund_returns_all_payments(): void
    {
        SettingService::put('allow_customer_credit', true);
        $c = Customer::create(['code' => 'CR1', 'name' => 'Credit User']);
        $sale = $this->tx(['type' => 'sale', 'customer_id' => $c->id, 'account_id' => $this->cash()->id, 'paid_amount' => '10000', 'items' => [['product_id' => Product::first()->id, 'quantity' => 1]]])->assertSuccessful()->json('data');
        $this->tx(['type' => 'receivable_payment', 'settlement_of' => $sale['id'], 'account_id' => $this->cash()->id, 'amount' => '15000'])->assertSuccessful();
        $this->assertSame('5025000.00', $this->cash()->current_balance);
        $this->tx(['type' => 'receivable_payment', 'settlement_of' => $sale['id'], 'account_id' => $this->cash()->id, 'amount' => '1'])->assertUnprocessable();
        $this->tx(['type' => 'reversal', 'reversal_of' => $sale['id'], 'notes' => 'Full refund'])->assertSuccessful();
        $this->assertSame('5000000.00', $this->cash()->current_balance);
    }

    public function test_payable_settlement_and_purchase_return(): void
    {
        $s = Supplier::create(['code' => 'SP1', 'name' => 'Supplier']);
        $p = $this->tx(['type' => 'purchase', 'supplier_id' => $s->id, 'account_id' => $this->cash()->id, 'paid_amount' => '0', 'items' => [['product_id' => Product::first()->id, 'quantity' => 2, 'unit_cost' => '10000']]])->assertSuccessful()->json('data');
        $this->tx(['type' => 'payable_payment', 'settlement_of' => $p['id'], 'account_id' => $this->cash()->id, 'amount' => '10000'])->assertSuccessful();
        $this->getJson('/api/debts/payables')->assertOk()->assertJsonPath('data.0.outstanding_amount', '10000.00');
        $this->tx(['type' => 'purchase_return', 'settlement_of' => $p['id'], 'account_id' => $this->cash()->id, 'notes' => 'Retur'])->assertSuccessful();
        $this->assertSame('5000000.00', $this->cash()->current_balance);
        $this->assertDatabaseHas('transactions', ['id' => $p['id'], 'status' => 'returned', 'outstanding_amount' => '0.00']);
    }

    public function test_staged_stock_transfer_only_increases_destination_when_received(): void
    {
        $b = Branch::create(['code' => 'DEST', 'name' => 'Tujuan']);
        $p = Product::first();
        $r = $this->postJson('/api/stock-transfers', ['branch_id' => Branch::first()->id, 'destination_branch_id' => $b->id, 'items' => [['product_id' => $p->id, 'quantity' => 2]], 'notes' => 'Kirim stok', 'idempotency_key' => 'stock-transfer-test-0001'])->assertSuccessful();
        $id = $r->json('id');
        $this->postJson('/api/stock-transfers/'.$id.'/transition', ['action' => 'receive'])->assertConflict();
        $this->postJson('/api/stock-transfers/'.$id.'/transition', ['action' => 'approve'])->assertSuccessful();
        $this->postJson('/api/stock-transfers/'.$id.'/transition', ['action' => 'send'])->assertSuccessful();
        $this->assertDatabaseHas('branch_stocks', ['branch_id' => Branch::first()->id, 'product_id' => $p->id, 'quantity' => 18]);
        $this->assertDatabaseMissing('branch_stocks', ['branch_id' => $b->id, 'product_id' => $p->id]);
        $this->postJson('/api/stock-transfers/'.$id.'/transition', ['action' => 'receive'])->assertSuccessful();
        $this->assertDatabaseHas('branch_stocks', ['branch_id' => $b->id, 'product_id' => $p->id, 'quantity' => 2]);
        $this->postJson('/api/stock-transfers/'.$id.'/transition', ['action' => 'receive'])->assertConflict();
    }

    public function test_pricing_priority_and_daily_closing(): void
    {
        $group = DB::table('customer_groups')->where('name', 'Reseller')->value('id');
        $c = Customer::create(['code' => 'PRICE', 'name' => 'Reseller', 'customer_group_id' => $group]);
        $p = DigitalProduct::first();
        $branch = Branch::first()->id;
        DB::table('customer_group_prices')->insert(['customer_group_id' => $group, 'digital_product_id' => $p->id, 'selling_price' => '11000']);
        DB::table('branch_product_prices')->insert(['branch_id' => $branch, 'digital_product_id' => $p->id, 'selling_price' => '11500']);
        DB::table('branch_group_prices')->insert(['branch_id' => $branch, 'customer_group_id' => $group, 'digital_product_id' => $p->id, 'selling_price' => '11200']);
        $this->tx(['type' => 'digital', 'customer_id' => $c->id, 'account_id' => $this->cash()->id, 'digital_product_id' => $p->id, 'target_number' => '08123456789'])->assertSuccessful()->assertJsonPath('data.amount', '11200.00');
        $this->postJson('/api/daily-closings', ['branch_id' => $branch, 'date' => now()->subDay()->toDateString()])->assertSuccessful();
        $this->postJson('/api/daily-closings', ['branch_id' => $branch, 'date' => now()->subDay()->toDateString()])->assertConflict();
    }
}
