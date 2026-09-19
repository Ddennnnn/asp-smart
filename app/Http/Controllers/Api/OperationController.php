<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AccountReconciliation;
use App\Models\Approval;
use App\Models\BranchStock;
use App\Models\CashierSession;
use App\Models\FinancialAccount;
use App\Models\Transaction;
use App\Services\ApprovalService;
use App\Services\CashierSessionService;
use App\Support\Access;
use App\Support\Audit;
use App\Support\Money;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;

class OperationController extends Controller
{
    public function stock(Request $r)
    {
        Gate::authorize('stock.view');

        return Access::scope(BranchStock::with('product', 'branch'), $r->user(), $r->integer('branch_id') ?: null)->latest('id')->paginate(25);
    }

    public function movements(Request $r)
    {
        Gate::authorize('stock.view');

        return Access::scope(DB::table('stock_movements')->join('products', 'products.id', '=', 'stock_movements.product_id')->join('branches', 'branches.id', '=', 'stock_movements.branch_id')->select('stock_movements.*', 'products.name as product_name', 'branches.name as branch_name'), $r->user(), $r->integer('branch_id') ?: null, 'stock_movements.branch_id')->orderByDesc('stock_movements.id')->paginate(25);
    }

    public function approvals(Request $r)
    {
        Gate::authorize('approval.approve');

        return Access::scope(Approval::with('transaction', 'branch'), $r->user(), $r->integer('branch_id') ?: null)->latest('id')->paginate(20);
    }

    public function decide(Request $r, int $id, ApprovalService $service)
    {
        Gate::authorize('approval.approve');
        $d = $r->validate(['approve' => 'required|boolean', 'reason' => 'required|string|max:1000']);

        return $service->decide($id, $r->user(), $d['approve'], $d['reason']);
    }

    public function sessions(Request $r)
    {
        Gate::authorize('session.manage');
        $q = Access::scope(CashierSession::with('branch', 'account', 'user'), $r->user(), $r->integer('branch_id') ?: null);
        if (! $r->user()->hasPermission('report.view')) {
            $q->where('user_id', $r->user()->id);
        }

        return $q->latest('id')->paginate(20);
    }

    public function open(Request $r, CashierSessionService $service)
    {
        Gate::authorize('session.manage');

        return $service->open($r->validate(['branch_id' => 'required|exists:branches,id', 'financial_account_id' => 'required|exists:financial_accounts,id']), $r->user());
    }

    public function close(Request $r, int $id, CashierSessionService $service)
    {
        Gate::authorize('session.manage');

        return $service->close($id, $r->validate(['actual_cash' => 'required|regex:/^\d{1,14}(\.\d{1,2})?$/D', 'notes' => 'nullable|string|max:1000']), $r->user());
    }

    public function reconciliations(Request $r)
    {
        Gate::authorize('account.reconcile');

        return Access::scope(AccountReconciliation::with('account', 'branch'), $r->user(), $r->integer('branch_id') ?: null)->latest('id')->paginate(20);
    }

    public function reconcile(Request $r)
    {
        Gate::authorize('account.reconcile');
        $d = $r->validate(['financial_account_id' => 'required|exists:financial_accounts,id', 'actual_balance' => 'required|regex:/^\d{1,14}(\.\d{1,2})?$/D', 'notes' => 'nullable|string|max:1000']);

        return DB::transaction(function () use ($d, $r) {
            $a = FinancialAccount::whereKey($d['financial_account_id'])->lockForUpdate()->firstOrFail();
            Access::branch($r->user(), $a->branch_id);
            $diff = Money::sub($d['actual_balance'], $a->current_balance);
            abort_if(bccomp($diff, '0', 2) !== 0 && empty($d['notes']), 422, 'Catatan wajib untuk selisih rekonsiliasi.');
            $row = AccountReconciliation::create(['branch_id' => $a->branch_id, 'financial_account_id' => $a->id, 'system_balance' => $a->current_balance, 'actual_balance' => $d['actual_balance'], 'difference' => $diff, 'notes' => $d['notes'] ?? null, 'status' => bccomp($diff, '0', 2) === 0 ? 'matched' : 'pending_review', 'reconciled_by' => $r->user()->id]);
            Audit::record('RECONCILE', 'reconciliations', $row->id, $a->branch_id, [], ['difference' => $diff]);

            return $row;
        });
    }

    public function audit(Request $r)
    {
        Gate::authorize('audit.view');

        return Access::scope(DB::table('audit_logs')->leftJoin('users', 'users.id', '=', 'audit_logs.user_id')->select('audit_logs.*', 'users.name as user_name'), $r->user(), $r->integer('branch_id') ?: null, 'audit_logs.branch_id')->orderByDesc('audit_logs.id')->paginate(25);
    }

    public function notifications(Request $r)
    {
        Gate::authorize('dashboard.view');
        $items = [];
        if ($r->user()->hasPermission('account.view')) {
            foreach (Access::scope(FinancialAccount::query(), $r->user(), $r->integer('branch_id') ?: null)->whereColumn('current_balance', '<=', 'minimum_balance')->limit(20)->get() as $a) {
                $items[] = ['title' => 'Saldo '.$a->name.' menipis', 'detail' => $a->current_balance, 'url' => '/app/manage/financial-accounts'];
            }
        }
        if ($r->user()->hasPermission('stock.view')) {
            foreach (Access::scope(BranchStock::with('product'), $r->user(), $r->integer('branch_id') ?: null)->whereHas('product', fn ($q) => $q->whereColumn('minimum_stock', '>=', 'branch_stocks.quantity'))->limit(20)->get() as $s) {
                $items[] = ['title' => 'Stok '.$s->product->name.' menipis', 'detail' => $s->quantity.' tersisa', 'url' => '/app/stock'];
            }
        }
        if ($r->user()->hasPermission('approval.approve')) {
            $n = Access::scope(Approval::query(), $r->user())->where('status', 'pending')->count();
            if ($n) {
                $items[] = ['title' => $n.' transaksi menunggu persetujuan', 'detail' => 'Perlu ditinjau', 'url' => '/app/approvals'];
            }
        }
        if ($r->user()->hasPermission('approval.approve')) {
            $failed = Access::scope(Transaction::query(), $r->user(), $r->integer('branch_id') ?: null)->where('status', 'failed')->where('created_at', '>=', now()->subDay())->count();
            if ($failed) {
                $items[] = ['title' => $failed.' transaksi digital gagal dalam 24 jam', 'detail' => 'Periksa riwayat transaksi', 'url' => '/app/transactions'];
            }
            $pending = Access::scope(AccountReconciliation::query(), $r->user(), $r->integer('branch_id') ?: null)->where('status', 'pending_review')->count();
            if ($pending) {
                $items[] = ['title' => $pending.' selisih rekonsiliasi perlu ditinjau', 'detail' => 'Bandingkan bukti dengan saldo sistem', 'url' => '/app/reconciliations'];
            }
        }
        $read = DB::table('notification_reads')->where('user_id', $r->user()->id)->pluck('notification_key')->all();

        return array_map(function ($item) use ($read) {
            $item['key'] = hash('sha256', json_encode($item));
            $item['read'] = in_array($item['key'], $read, true);

            return $item;
        }, $items);
    }
}
