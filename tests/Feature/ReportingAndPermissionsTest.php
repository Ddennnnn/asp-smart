<?php

namespace Tests\Feature;

use App\Models\Branch;
use App\Models\FinancialAccount;
use App\Models\Role;
use App\Models\User;
use App\Services\ReportCatalogService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ReportingAndPermissionsTest extends TestCase
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

    public function test_every_operational_report_and_export_executes(): void
    {
        foreach (app(ReportCatalogService::class)->catalog() as $key => $title) {
            $this->getJson('/api/report-data?dataset='.$key)->assertOk();
        }$this->get('/api/report-data/export?dataset=ledger&format=pdf')->assertOk()->assertHeader('content-type', 'application/pdf');
        $this->get('/api/report-data/export?dataset=stock&format=xlsx')->assertOk();
    }

    public function test_edit_account_keeps_masked_number_and_opening_ledger(): void
    {
        $a = $this->postJson('/api/resources/financial-accounts', ['branch_id' => (string) Branch::first()->id, 'code' => 'EDITBANK', 'name' => 'Edit Bank', 'account_type' => 'bank', 'account_number' => '1234567890', 'opening_balance' => '10000', 'minimum_balance' => '100', 'is_central' => false, 'is_active' => true])->assertCreated()->json();
        $this->putJson('/api/resources/financial-accounts/'.$a['id'], ['branch_id' => (string) Branch::first()->id, 'code' => 'EDITBANK', 'name' => 'Edited Bank', 'account_type' => 'bank', 'account_number' => null, 'opening_balance' => '999999', 'minimum_balance' => '100', 'is_central' => false, 'is_active' => true])->assertOk()->assertJsonPath('account_number_masked', '******7890');
        $this->assertSame('10000.00', FinancialAccount::find($a['id'])->current_balance);
        $this->assertSame('10000.00', FinancialAccount::find($a['id'])->opening_balance);
    }

    public function test_role_permission_changes_are_enforced_and_owner_role_is_protected(): void
    {
        $role = Role::where('name', 'CASHIER')->first();
        $this->putJson('/api/roles/'.$role->id, ['name' => 'CASHIER', 'permissions' => ['dashboard.view']])->assertOk();
        $this->putJson('/api/roles/'.Role::where('name', 'OWNER')->value('id'), ['name' => 'OWNER', 'permissions' => []])->assertUnprocessable();
        $this->actingAs(User::where('email', 'cashier@aspsmart.local')->first());
        $this->getJson('/api/resources/financial-accounts')->assertForbidden();
        $this->getJson('/api/report-data?dataset=ledger')->assertForbidden();
    }

    public function test_pending_approval_cannot_bypass_branch_account_access(): void
    {
        $b = Branch::create(['code' => 'PRIVATE', 'name' => 'Private']);
        $a = FinancialAccount::create(['branch_id' => $b->id, 'code' => 'PRIVATEBANK', 'name' => 'Private Bank', 'account_type' => 'bank']);
        $this->actingAs(User::where('email', 'cashier@aspsmart.local')->first());
        $this->postJson('/api/transactions', ['type' => 'money_transfer', 'branch_id' => Branch::first()->id, 'account_id' => FinancialAccount::where('code', 'CASH')->value('id'), 'counter_account_id' => $a->id, 'amount' => '6000000', 'fee' => '1000', 'destination_bank' => 'BCA', 'destination_account' => '1234567890', 'recipient_name' => 'Test', 'idempotency_key' => 'forbidden-approval-test-1'])->assertForbidden();
        $this->assertDatabaseCount('approvals', 0);
    }

    public function test_account_reveal_is_permission_checked_and_audited(): void
    {
        $account = FinancialAccount::where('code', 'BCA')->first();
        $account->update(['account_number' => '1234567890']);
        $this->getJson('/api/accounts/'.$account->id.'/reveal')->assertOk()->assertJsonPath('account_number', '1234567890');
        $this->assertDatabaseHas('audit_logs', ['action' => 'ACCOUNT_REVEAL']);
        $this->actingAs(User::where('email', 'cashier@aspsmart.local')->first());
        $this->getJson('/api/accounts/'.$account->id.'/reveal')->assertForbidden();
    }

    public function test_reports_accept_end_date_only_and_reject_backwards_ranges(): void
    {
        $this->getJson('/api/reports?to=2026-09-30')->assertOk();
        $this->getJson('/api/report-data?dataset=ledger&to=2026-09-30')->assertOk();
        $this->getJson('/api/reports?from=2026-09-30&to=2026-09-01')->assertUnprocessable();
        $this->getJson('/api/report-data?dataset=ledger&from=2026-09-30&to=2026-09-01')->assertUnprocessable();
    }
}
