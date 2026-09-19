<?php

namespace App\Services;

use App\Models\AccountTransaction;
use App\Models\FinancialAccount;
use App\Models\Transaction;
use App\Models\User;
use App\Support\Access;
use App\Support\Money;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class LedgerService
{
    public function lockAccounts(array $ids, User $user, int $branch): array
    {
        $ids = array_values(array_unique(array_map('intval', $ids)));
        sort($ids);
        $accounts = FinancialAccount::whereIn('id', $ids)->orderBy('id')->lockForUpdate()->get()->keyBy('id');
        foreach ($ids as $id) {
            $a = $accounts->get($id);
            abort_unless($a && $a->is_active, 422, 'Rekening tidak tersedia.');
            if ($a->is_central) {
                abort_unless($user->hasPermission('account.central'), 403);
            } else {
                Access::branch($user, $a->branch_id);
            }
        }

        return $accounts->all();
    }

    public function post(FinancialAccount $account, string $signed, User $user, ?Transaction $transaction, string $type, string $description): void
    {
        if (DB::transactionLevel() < 1) {
            throw new \LogicException('Ledger requires an active database transaction.');
        }
        $amount = Money::value($signed);
        if (bccomp($amount, '0', 2) === 0) {
            return;
        }
        $before = $account->current_balance;
        $after = Money::add($before, $amount);
        if (bccomp($after, '0', 2) < 0) {
            throw ValidationException::withMessages(['account' => 'Saldo '.$account->name.' tidak mencukupi.']);
        }
        AccountTransaction::create(['branch_id' => $transaction?->branch_id ?? $account->branch_id, 'financial_account_id' => $account->id, 'transaction_id' => $transaction?->id, 'transaction_type' => $type, 'reference_number' => $transaction?->reference_number ?? 'OPEN/'.$account->code, 'direction' => bccomp($amount, '0', 2) > 0 ? 'in' : 'out', 'amount' => ltrim($amount, '-'), 'balance_before' => $before, 'balance_after' => $after, 'description' => $description, 'created_by' => $user->id]);
        $account->current_balance = $after;
        $account->save();
    }
}
