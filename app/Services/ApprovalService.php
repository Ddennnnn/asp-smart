<?php

namespace App\Services;

use App\Models\Approval;
use App\Models\Transaction;
use App\Models\User;
use App\Support\Access;
use App\Support\Audit;
use Illuminate\Support\Facades\DB;

class ApprovalService
{
    public function decide(int $id, User $user, bool $approve, string $reason): Approval
    {
        return DB::transaction(function () use ($id, $user, $approve, $reason) {
            $approval = Approval::whereKey($id)->lockForUpdate()->firstOrFail();
            Access::branch($user, $approval->branch_id);
            abort_unless($approval->status === 'pending', 409, 'Persetujuan sudah diproses.');
            $tx = Transaction::whereKey($approval->transaction_id)->lockForUpdate()->firstOrFail();
            if ($approve) {
                $requester = User::findOrFail($approval->requested_by);
                abort_unless($requester->is_active && $requester->canAccessBranch($tx->branch_id), 403, 'Akses pemohon sudah tidak berlaku.');
            }
            if ($approve) {
                app(TransactionService::class)->execute($tx, $user);
            } else {
                $tx->update(['status' => 'cancelled']);
            }
            $approval->update(['status' => $approve ? 'approved' : 'rejected', 'approved_by' => $user->id, 'reason' => $reason]);
            Audit::record('APPROVAL_DECISION', 'approvals', $id, $approval->branch_id);

            return $approval;
        }, 5);
    }
}
