<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Branch;
use App\Models\FinancialAccount;
use App\Models\Transaction;
use App\Services\CustomerWalletService;
use App\Support\Access;
use App\Support\Audit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;

class FinanceController extends Controller
{
    public function wallets(Request $r)
    {
        Gate::authorize('wallet.manage');

        return Access::scope(DB::table('customer_wallets')->join('customers', 'customers.id', '=', 'customer_wallets.customer_id')->join('financial_accounts', 'financial_accounts.id', '=', 'customer_wallets.financial_account_id')->join('branches', 'branches.id', '=', 'customer_wallets.branch_id')->select('customer_wallets.*', 'customers.name as customer_name', 'branches.name as branch_name', 'financial_accounts.current_balance'), $r->user(), $r->integer('branch_id') ?: null, 'customer_wallets.branch_id')->orderByDesc('customer_wallets.id')->paginate(25);
    }

    public function openWallet(Request $r, CustomerWalletService $s)
    {
        Gate::authorize('wallet.manage');
        $d = $r->validate(['customer_id' => 'required|exists:customers,id', 'branch_id' => 'required|exists:branches,id']);

        return $s->open((int) $d['customer_id'], (int) $d['branch_id'], $r->user());
    }

    public function debts(Request $r, string $kind)
    {
        abort_unless(in_array($kind, ['payables', 'receivables']), 404);
        Gate::authorize($kind === 'payables' ? 'payable.manage' : 'receivable.manage');

        return Access::scope(Transaction::query(), $r->user(), $r->integer('branch_id') ?: null)->where('type', $kind === 'payables' ? 'purchase' : 'sale')->where('status', 'completed')->where('outstanding_amount', '>', 0)->with('branch', 'customer')->latest('id')->paginate(25)->through(fn ($t) => $t->only(['id', 'reference_number', 'branch_id', 'supplier_id', 'customer_id', 'amount', 'paid_amount', 'outstanding_amount', 'created_at']) + ['branch_name' => $t->branch->name, 'party_name' => $t->customer?->name ?? DB::table('suppliers')->where('id', $t->supplier_id)->value('name')]);
    }

    public function closings(Request $r)
    {
        Gate::authorize('report.view');

        return Access::scope(DB::table('branch_daily_closings')->join('branches', 'branches.id', '=', 'branch_daily_closings.branch_id')->select('branch_daily_closings.*', 'branches.name as branch_name'), $r->user(), $r->integer('branch_id') ?: null, 'branch_daily_closings.branch_id')->orderByDesc('date')->paginate(25)->through(function ($row) {
            $row->summary = json_decode($row->summary, true);

            return $row;
        });
    }

    public function closeDay(Request $r)
    {
        Gate::authorize('closing.manage');
        $d = $r->validate(['branch_id' => 'required|exists:branches,id', 'date' => 'required|date_format:Y-m-d|before:today']);
        Access::branch($r->user(), (int) $d['branch_id']);

        return DB::transaction(function () use ($r, $d) {
            Branch::whereKey($d['branch_id'])->lockForUpdate()->firstOrFail();
            abort_if(DB::table('branch_daily_closings')->where($d)->exists(), 409, 'Tanggal ini sudah ditutup.');
            $q = Transaction::where('branch_id', $d['branch_id'])->whereDate('created_at', $d['date'])->whereIn('status', ['completed', 'reversed']);
            $summary = $q->selectRaw('COUNT(*) as count, COALESCE(SUM(revenue),0) as revenue, COALESCE(SUM(cost),0) as cost, COALESCE(SUM(profit),0) as profit')->first()->toArray();
            $summary['accounts'] = FinancialAccount::where('branch_id', $d['branch_id'])->get()->map(function ($a) use ($d) {
                return ['name' => $a->name, 'type' => $a->account_type, 'closing_balance' => DB::table('account_transactions')->where('financial_account_id', $a->id)->where('created_at', '<=', $d['date'].' 23:59:59')->orderByDesc('id')->value('balance_after') ?? '0.00'];
            });
            $id = DB::table('branch_daily_closings')->insertGetId($d + ['summary' => json_encode($summary), 'closed_by' => $r->user()->id, 'created_at' => now(), 'updated_at' => now()]);
            Audit::record('DAILY_CLOSE', 'branch_daily_closings', $id, (int) $d['branch_id']);

            return ['id' => $id, 'summary' => $summary];
        });
    }

    public function branch(Request $r, Branch $branch)
    {
        Gate::authorize('branch.view');
        Access::branch($r->user(), $branch->id);

        return ['branch' => $branch, 'accounts' => $r->user()->hasPermission('account.view') ? $branch->id : null, 'transaction_count' => Transaction::where('branch_id', $branch->id)->count(), 'employee_count' => DB::table('user_branches')->where('branch_id', $branch->id)->count()];
    }
}
