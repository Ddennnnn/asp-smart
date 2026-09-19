<?php

namespace App\Services;

use App\Models\CashierSession;
use App\Models\FinancialAccount;
use App\Models\User;
use App\Support\Access;
use App\Support\Audit;
use App\Support\Money;
use Illuminate\Support\Facades\DB;

class CashierSessionService
{
    public function open(array $d, User $u)
    {
        Access::branch($u, (int) $d['branch_id']);

        return DB::transaction(function () use ($d, $u) {
            User::whereKey($u->id)->lockForUpdate()->firstOrFail();
            $a = FinancialAccount::whereKey($d['financial_account_id'])->lockForUpdate()->firstOrFail();
            abort_unless($a->branch_id == (int) $d['branch_id'] && $a->account_type === 'cash' && $a->is_active, 422, 'Rekening kas tidak sesuai.');
            abort_if(CashierSession::whereNull('closed_at')->where(fn ($q) => $q->where('user_id', $u->id)->orWhere('financial_account_id', $a->id))->exists(), 409, 'Kasir atau rekening kas sudah memiliki shift aktif.');
            $s = CashierSession::create(['branch_id' => $a->branch_id, 'user_id' => $u->id, 'financial_account_id' => $a->id, 'opening_cash' => $a->current_balance]);
            Audit::record('SHIFT_OPEN', 'cashier_sessions', $s->id, $s->branch_id);

            return $s;
        });
    }

    public function close(int $id, array $d, User $u)
    {
        return DB::transaction(function () use ($id, $d, $u) {
            User::whereKey($u->id)->lockForUpdate()->firstOrFail();
            $s = CashierSession::whereKey($id)->where('user_id', $u->id)->lockForUpdate()->firstOrFail();
            abort_if($s->closed_at, 409, 'Shift sudah ditutup.');
            $a = FinancialAccount::whereKey($s->financial_account_id)->lockForUpdate()->firstOrFail();
            $actual = Money::value($d['actual_cash']);
            $diff = Money::sub($actual, $a->current_balance);
            abort_if(bccomp($diff, '0', 2) !== 0 && empty($d['notes']), 422, 'Catatan wajib jika ada selisih.');
            $s->update(['expected_cash' => $a->current_balance, 'actual_cash' => $actual, 'difference' => $diff, 'notes' => $d['notes'] ?? null, 'closed_at' => now()]);
            Audit::record('SHIFT_CLOSE', 'cashier_sessions', $s->id, $s->branch_id, [], ['difference' => $diff]);

            return $s;
        });
    }
}
