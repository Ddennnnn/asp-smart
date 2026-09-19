<?php

namespace Tests\Feature;

use App\Models\Branch;
use App\Models\FinancialAccount;
use App\Models\Product;
use App\Models\User;
use App\Services\SettingService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OperationsReviewTest extends TestCase
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
    }

    public function test_opname_posts_once_and_detects_stale_count(): void
    {
        $branch = Branch::first()->id;
        $product = Product::first()->id;
        $d = ['branch_id' => $branch, 'notes' => 'Hitung fisik', 'items' => [['product_id' => $product, 'actual_quantity' => 9]]];
        $first = $this->postJson('/api/stock-opnames', $d)->assertOk()->json('id');
        $second = $this->postJson('/api/stock-opnames', $d)->assertOk()->json('id');
        $this->postJson('/api/stock-opnames/'.$first.'/post')->assertOk();
        $this->assertDatabaseHas('branch_stocks', ['branch_id' => $branch, 'product_id' => $product, 'quantity' => 9]);
        $this->postJson('/api/stock-opnames/'.$first.'/post')->assertConflict();
        $this->postJson('/api/stock-opnames/'.$second.'/post')->assertConflict();
    }

    public function test_reconciliation_review_does_not_silently_change_balance(): void
    {
        $account = FinancialAccount::where('code', 'BCA')->first();
        $id = $this->postJson('/api/reconciliations', ['financial_account_id' => $account->id, 'actual_balance' => '7975000', 'notes' => 'Selisih bank'])->assertCreated()->json('id');
        $this->postJson('/api/reconciliations/'.$id.'/review', ['notes' => 'Bukti diverifikasi; koreksi terpisah diperlukan'])->assertOk()->assertJsonPath('status', 'approved');
        $this->assertSame('8000000.00', $account->fresh()->current_balance);
        $this->postJson('/api/reconciliations/'.$id.'/review', ['notes' => 'Ulang'])->assertConflict();
    }

    public function test_settings_numbering_and_website_visibility_persist(): void
    {
        $this->putJson('/api/settings', ['website' => ['hero_title' => 'Judul Baru', 'theme' => 'dark', 'show_services' => false, 'show_gallery' => false, 'show_testimonials' => false, 'show_promotions' => false], 'numbering' => ['sale' => 'JUAL']])->assertOk();
        $this->getJson('/api/public/website')->assertOk()->assertJsonPath('website.show_testimonials', false);
        SettingService::put('require_cashier_session', false);
        $result = $this->postJson('/api/transactions', ['type' => 'sale', 'branch_id' => Branch::first()->id, 'account_id' => FinancialAccount::where('code', 'CASH')->value('id'), 'items' => [['product_id' => Product::first()->id, 'quantity' => 1]], 'idempotency_key' => 'numbering-verification-1'])->assertSuccessful();
        $this->assertStringStartsWith('JUAL/CB01/', $result->json('data.reference_number'));
    }

    public function test_read_notifications_is_user_scoped(): void
    {
        FinancialAccount::where('code', 'CASH')->update(['minimum_balance' => '99999999']);
        $items = $this->getJson('/api/notifications')->assertOk()->json();
        $key = $items[0]['key'];
        $this->postJson('/api/notifications/read', ['keys' => [$key]])->assertOk();
        $this->getJson('/api/notifications')->assertOk()->assertJsonPath('0.read', true);
        $this->actingAs(User::where('email', 'cashier@aspsmart.local')->first());
        $this->getJson('/api/notifications')->assertOk()->assertJsonPath('0.read', false);
    }
}
