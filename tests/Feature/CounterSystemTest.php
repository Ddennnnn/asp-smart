<?php

namespace Tests\Feature;

use App\Models\Approval;
use App\Models\Branch;
use App\Models\DigitalProduct;
use App\Models\FinancialAccount;
use App\Models\Product;
use App\Models\Supplier;
use App\Models\Transaction;
use App\Models\User;
use App\Services\SettingService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class CounterSystemTest extends TestCase
{
    use RefreshDatabase;

    protected function beforeRefreshingDatabase(): void
    {
        if (config('database.connections.mysql.database') !== 'asp_smart_testing') {
            throw new \RuntimeException('Refusing to reset non-testing database.');
        }
    }

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
        $this->actingAs(User::where('email', 'owner@aspsmart.local')->first());
        SettingService::put('require_cashier_session', false);
    }

    private function account(string $code): FinancialAccount
    {
        return FinancialAccount::where('code', $code)->firstOrFail();
    }

    private function postTransaction(array $data)
    {
        return $this->postJson('/api/transactions', $data + ['branch_id' => Branch::first()->id, 'idempotency_key' => (string) Str::uuid()]);
    }

    public function test_login_and_me(): void
    {
        auth()->logout();
        $this->postJson('/api/auth/login', ['email' => 'cashier@aspsmart.local', 'password' => 'Cashier123!'])->assertOk()->assertJsonPath('user.name', 'Kasir');
        $this->getJson('/api/auth/me')->assertOk();
    }

    public function test_wrong_login_is_logged(): void
    {
        auth()->logout();
        $this->postJson('/api/auth/login', ['email' => 'cashier@aspsmart.local', 'password' => 'wrong'])->assertUnprocessable();
        $this->assertDatabaseHas('login_logs', ['success' => false]);
    }

    public function test_cashier_cannot_adjust_or_read_other_branch(): void
    {
        $this->actingAs(User::where('email', 'cashier@aspsmart.local')->first());
        $this->postTransaction(['type' => 'adjustment', 'account_id' => $this->account('CASH')->id, 'actual_balance' => '10', 'notes' => 'Test'])->assertForbidden();
        $b = Branch::create(['code' => 'OTHER', 'name' => 'Lain']);
        $this->getJson('/api/resources/financial-accounts?branch_id='.$b->id)->assertForbidden();
        $this->getJson('/api/reports')->assertForbidden();
    }

    public function test_opening_balance_has_ledger(): void
    {
        $a = $this->account('CASH');
        $this->assertSame('5000000.00', $a->current_balance);
        $this->assertDatabaseHas('account_transactions', ['financial_account_id' => $a->id, 'transaction_type' => 'opening', 'balance_after' => '5000000.00']);
    }

    public function test_withdrawal_bank_fee(): void
    {
        $this->postTransaction(['type' => 'cash_withdrawal', 'account_id' => $this->account('CASH')->id, 'counter_account_id' => $this->account('BCA')->id, 'amount' => '500000', 'fee' => '10000', 'fee_method' => 'bank'])->assertSuccessful();
        $this->assertSame('4500000.00', $this->account('CASH')->current_balance);
        $this->assertSame('8510000.00', $this->account('BCA')->current_balance);
        $this->assertDatabaseHas('transactions', ['type' => 'cash_withdrawal', 'revenue' => '10000.00', 'profit' => '10000.00']);
    }

    public function test_customer_transfer(): void
    {
        $this->postTransaction(['type' => 'money_transfer', 'account_id' => $this->account('CASH')->id, 'counter_account_id' => $this->account('BCA')->id, 'amount' => '1000000', 'fee' => '10000', 'destination_bank' => 'BCA', 'destination_account' => '1234567890', 'recipient_name' => 'Budi'])->assertSuccessful()->assertJsonPath('data.details.destination_account', '******7890');
        $this->assertSame('6010000.00', $this->account('CASH')->current_balance);
        $this->assertSame('7000000.00', $this->account('BCA')->current_balance);
    }

    public function test_internal_transfer_and_deposit_have_no_revenue(): void
    {
        $this->postTransaction(['type' => 'account_transfer', 'account_id' => $this->account('CASH')->id, 'counter_account_id' => $this->account('BCA')->id, 'amount' => '5000000'])->assertSuccessful();
        $this->assertSame('0.00', $this->account('CASH')->current_balance);
        $this->assertDatabaseHas('transactions', ['type' => 'account_transfer', 'revenue' => '0.00', 'profit' => '0.00']);
    }

    public function test_insufficient_balance_rolls_back_everything(): void
    {
        $before = Transaction::count();
        $this->postTransaction(['type' => 'account_transfer', 'account_id' => $this->account('CASH')->id, 'counter_account_id' => $this->account('BCA')->id, 'amount' => '99999999'])->assertUnprocessable();
        $this->assertSame($before, Transaction::count());
        $this->assertSame('8000000.00', $this->account('BCA')->current_balance);
    }

    public function test_digital_success_is_idempotent_and_reversible(): void
    {
        $d = ['type' => 'digital', 'account_id' => $this->account('CASH')->id, 'digital_product_id' => DigitalProduct::where('code', 'TSEL50')->value('id'), 'target_number' => '081234567890', 'idempotency_key' => 'duplicate-digital-test-0001'];
        $first = $this->postTransaction($d)->assertSuccessful();
        $this->postTransaction($d)->assertSuccessful()->assertJsonPath('data.id', $first->json('data.id'));
        $this->assertSame('1951500.00', $this->account('DIGI')->current_balance);
        $this->assertSame('5052000.00', $this->account('CASH')->current_balance);
        $this->postTransaction(['type' => 'reversal', 'reversal_of' => $first->json('data.id'), 'notes' => 'Permintaan pelanggan'])->assertSuccessful();
        $this->assertSame('2000000.00', $this->account('DIGI')->current_balance);
        $this->assertSame('5000000.00', $this->account('CASH')->current_balance);
        $this->postTransaction(['type' => 'reversal', 'reversal_of' => $first->json('data.id'), 'notes' => 'Ulang'])->assertUnprocessable();
    }

    public function test_failed_digital_keeps_money_and_audit(): void
    {
        $this->postTransaction(['type' => 'digital', 'account_id' => $this->account('CASH')->id, 'digital_product_id' => DigitalProduct::first()->id, 'target_number' => '0812340000'])->assertSuccessful()->assertJsonPath('data.status', 'failed');
        $this->assertSame('2000000.00', $this->account('DIGI')->current_balance);
        $this->assertSame('5000000.00', $this->account('CASH')->current_balance);
        $this->assertDatabaseHas('audit_logs', ['action' => 'DIGITAL_FAILED']);
    }

    public function test_pos_stock_cash_and_refund(): void
    {
        $p = Product::first();
        $r = $this->postTransaction(['type' => 'sale', 'account_id' => $this->account('CASH')->id, 'items' => [['product_id' => $p->id, 'quantity' => 2]], 'paid_amount' => '100000'])->assertSuccessful();
        $this->assertDatabaseHas('branch_stocks', ['product_id' => $p->id, 'quantity' => 18]);
        $this->assertSame('5050000.00', $this->account('CASH')->current_balance);
        $this->assertSame('50000.00', $r->json('data.change_amount'));
        $this->postTransaction(['type' => 'reversal', 'reversal_of' => $r->json('data.id'), 'notes' => 'Retur barang'])->assertSuccessful();
        $this->assertDatabaseHas('branch_stocks', ['product_id' => $p->id, 'quantity' => 20]);
    }

    public function test_purchase_increases_stock_and_records_payable(): void
    {
        $supplier = Supplier::create(['code' => 'S1', 'name' => 'Supplier']);
        $p = Product::first();
        $this->postTransaction(['type' => 'purchase', 'supplier_id' => $supplier->id, 'account_id' => $this->account('CASH')->id, 'paid_amount' => '20000', 'items' => [['product_id' => $p->id, 'quantity' => 3, 'unit_cost' => '10000']]])->assertSuccessful()->assertJsonPath('data.outstanding_amount', '10000.00');
        $this->assertDatabaseHas('branch_stocks', ['product_id' => $p->id, 'quantity' => 23]);
        $this->assertSame('4980000.00', $this->account('CASH')->current_balance);
    }

    public function test_stock_opname_and_transfer(): void
    {
        $p = Product::first();
        $this->postTransaction(['type' => 'stock_adjustment', 'product_id' => $p->id, 'actual_quantity' => 9, 'notes' => 'Opname'])->assertSuccessful();
        $b = Branch::create(['code' => 'CB02', 'name' => 'Cabang Kedua']);
        $this->postTransaction(['type' => 'stock_transfer', 'product_id' => $p->id, 'quantity' => 2, 'destination_branch_id' => $b->id])->assertSuccessful();
        $this->assertDatabaseHas('branch_stocks', ['branch_id' => Branch::first()->id, 'product_id' => $p->id, 'quantity' => 7]);
        $this->assertDatabaseHas('branch_stocks', ['branch_id' => $b->id, 'product_id' => $p->id, 'quantity' => 2]);
    }

    public function test_cashier_shift_expense_reconciliation(): void
    {
        $a = $this->account('CASH');
        $s = $this->postJson('/api/cashier-sessions', ['branch_id' => $a->branch_id, 'financial_account_id' => $a->id])->assertSuccessful()->json('id');
        $this->postTransaction(['type' => 'expense', 'account_id' => $a->id, 'amount' => '25000'])->assertSuccessful();
        $this->postJson('/api/cashier-sessions/'.$s.'/close', ['actual_cash' => '4970000'])->assertUnprocessable();
        $this->postJson('/api/cashier-sessions/'.$s.'/close', ['actual_cash' => '4970000', 'notes' => 'Selisih hitung'])->assertSuccessful()->assertJsonPath('difference', '-5000.00');
        $this->postJson('/api/reconciliations', ['financial_account_id' => $a->id, 'actual_balance' => '4970000', 'notes' => 'Perlu tinjau'])->assertSuccessful()->assertJsonPath('difference', '-5000.00');
        $this->assertSame('4975000.00', $this->account('CASH')->current_balance);
    }

    public function test_approval_posts_once(): void
    {
        $cashier = User::where('email', 'cashier@aspsmart.local')->first();
        $this->actingAs($cashier);
        $this->postTransaction(['type' => 'money_transfer', 'account_id' => $this->account('CASH')->id, 'counter_account_id' => $this->account('BCA')->id, 'amount' => '6000000', 'fee' => '10000', 'destination_bank' => 'BCA', 'destination_account' => '1234567890', 'recipient_name' => 'Budi'])->assertSuccessful()->assertJsonPath('data.status', 'pending_approval');
        $this->assertSame('8000000.00', $this->account('BCA')->current_balance);
        $this->actingAs(User::where('email', 'owner@aspsmart.local')->first());
        $id = Approval::first()->id;
        $this->postJson('/api/approvals/'.$id.'/decision', ['approve' => true, 'reason' => 'Diverifikasi'])->assertSuccessful();
        $this->postJson('/api/approvals/'.$id.'/decision', ['approve' => true, 'reason' => 'Ulang'])->assertConflict();
        $this->assertSame('2000000.00', $this->account('BCA')->current_balance);
    }

    public function test_reports_exports_receipt_and_public_settings(): void
    {
        $r = $this->postTransaction(['type' => 'income', 'account_id' => $this->account('CASH')->id, 'amount' => '10000'])->assertSuccessful();
        $this->getJson('/api/reports')->assertOk()->assertJsonPath('summary.totals.revenue', '10000.00');
        $this->get('/api/reports/export?format=pdf')->assertOk()->assertHeader('content-type', 'application/pdf');
        $this->get('/api/reports/export?format=xlsx')->assertOk();
        foreach (['58mm', '80mm', 'A4'] as $paper) {
            $this->get('/api/transactions/'.$r->json('data.id').'/invoice?paper='.$paper)->assertOk()->assertHeader('content-type', 'application/pdf');
        }
        $this->putJson('/api/settings', ['business' => ['name' => 'Counter Baru']])->assertOk();
        $this->getJson('/api/public/website')->assertOk()->assertJsonPath('business.name', 'Counter Baru');
    }

    public function test_masked_accounts_and_duplicate_conflict(): void
    {
        $r = $this->postJson('/api/resources/financial-accounts', ['branch_id' => Branch::first()->id, 'code' => 'TEST', 'name' => 'Bank Test', 'account_type' => 'bank', 'account_number' => '123456789012', 'opening_balance' => '100', 'minimum_balance' => '0', 'is_central' => false, 'is_active' => true])->assertCreated();
        $this->assertArrayNotHasKey('account_number', $r->json());
        $this->assertSame('******9012', $r->json('account_number_masked'));
        $d = ['type' => 'income', 'account_id' => $this->account('CASH')->id, 'amount' => '100', 'idempotency_key' => 'same-payload-test-000001'];
        $this->postTransaction($d)->assertSuccessful();
        $d['amount'] = '200';
        $this->postTransaction($d)->assertConflict();
    }
}
