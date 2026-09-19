<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AccountReconciliation;
use App\Models\FinancialAccount;
use App\Support\Access;
use App\Support\Audit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;

class ReviewController extends Controller
{
    public function reconciliation(Request $r, AccountReconciliation $reconciliation)
    {
        Gate::authorize('approval.approve');
        Access::branch($r->user(), $reconciliation->branch_id);
        $d = $r->validate(['notes' => 'required|string|max:2000']);

        return DB::transaction(function () use ($r, $reconciliation, $d) {
            $row = AccountReconciliation::whereKey($reconciliation->id)->lockForUpdate()->firstOrFail();
            abort_unless($row->status === 'pending_review', 409, 'Rekonsiliasi sudah ditinjau.');
            $row->update(['status' => 'approved', 'approved_by' => $r->user()->id, 'review_notes' => $d['notes'], 'reviewed_at' => now()]);
            Audit::record('RECONCILIATION_REVIEW', 'account_reconciliations', $row->id, $row->branch_id);

            return $row;
        });
    }

    public function riskFlags(Request $r)
    {
        Gate::authorize('approval.approve');

        return Access::scope(DB::table('risk_flags')->join('transactions', 'transactions.id', '=', 'risk_flags.transaction_id')->join('branches', 'branches.id', '=', 'risk_flags.branch_id')->select('risk_flags.*', 'transactions.reference_number', 'branches.name as branch_name'), $r->user(), $r->integer('branch_id') ?: null, 'risk_flags.branch_id')->orderByDesc('risk_flags.id')->paginate(25);
    }

    public function reviewRisk(Request $r, int $id)
    {
        Gate::authorize('approval.approve');
        $d = $r->validate(['notes' => 'required|string|max:2000']);

        return DB::transaction(function () use ($r, $id, $d) {
            $row = DB::table('risk_flags')->where('id', $id)->lockForUpdate()->first();
            abort_unless($row, 404);
            Access::branch($r->user(), $row->branch_id);
            abort_unless($row->status === 'review', 409, 'Penanda sudah ditinjau.');
            DB::table('risk_flags')->where('id', $id)->update(['status' => 'reviewed', 'reviewed_by' => $r->user()->id, 'notes' => $d['notes'], 'updated_at' => now()]);
            Audit::record('RISK_REVIEW', 'risk_flags', $id, $row->branch_id);

            return ['message' => 'Peninjauan disimpan.'];
        });
    }

    public function reveal(Request $r, FinancialAccount $account)
    {
        Gate::authorize('account.reveal');
        Access::branch($r->user(), $account->branch_id);
        Audit::record('ACCOUNT_REVEAL', 'financial_accounts', $account->id, $account->branch_id);

        return response()->json(['account_number' => $account->account_number])->header('Cache-Control', 'no-store');
    }

    public function readNotifications(Request $r)
    {
        Gate::authorize('dashboard.view');
        $d = $r->validate(['keys' => 'required|array|max:100', 'keys.*' => 'required|regex:/^[a-f0-9]{64}$/D']);
        foreach ($d['keys'] as $key) {
            DB::table('notification_reads')->updateOrInsert(['user_id' => $r->user()->id, 'notification_key' => $key], ['read_at' => now()]);
        }

        return ['message' => 'Notifikasi ditandai dibaca.'];
    }
}
