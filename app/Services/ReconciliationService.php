<?php

namespace App\Services;

use App\Models\BranchStock;
use App\Models\FinancialAccount;
use App\Support\Money;
use Illuminate\Support\Facades\DB;

class ReconciliationService
{
    /** Read-only integrity verification. Never repairs or overwrites a balance. */
    public function verify(): array
    {
        $errors = [];
        foreach (FinancialAccount::orderBy('id')->cursor() as $account) {
            $balance = '0.00';
            foreach ($account->ledger()->orderBy('id')->cursor() as $entry) {
                if (bccomp($balance, $entry->balance_before, 2) !== 0) {
                    $errors[] = 'Rantai saldo terputus: '.$account->code.' / '.$entry->id;
                }$balance = Money::add($balance, ($entry->direction === 'out' ? '-' : '').$entry->amount);
                if (bccomp($balance, $entry->balance_after, 2) !== 0) {
                    $errors[] = 'Mutasi tidak sesuai: '.$account->code.' / '.$entry->id;
                }
            }if (bccomp($balance, $account->current_balance, 2) !== 0) {
                $errors[] = 'Saldo akhir tidak sesuai: '.$account->code;
            }
        }
        foreach (BranchStock::orderBy('id')->cursor() as $stock) {
            $qty = 0;
            foreach (DB::table('stock_movements')->where('branch_id', $stock->branch_id)->where('product_id', $stock->product_id)->orderBy('id')->cursor() as $m) {
                if ($qty !== $m->before_qty) {
                    $errors[] = 'Rantai stok terputus: '.$stock->id;
                }$qty += $m->quantity;
                if ($qty !== $m->after_qty) {
                    $errors[] = 'Mutasi stok tidak sesuai: '.$stock->id;
                }
            }if ($qty !== $stock->quantity) {
                $errors[] = 'Stok akhir tidak sesuai: '.$stock->id;
            }
        }

        return $errors;
    }
}
