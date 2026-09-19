<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\FinancialAccount;
use App\Models\User;
use App\Support\Access;
use App\Support\Audit;
use Illuminate\Support\Facades\DB;

class CustomerWalletService
{
    public function open(int $customer, int $branch, User $user): array
    {
        Access::branch($user, $branch);

        return DB::transaction(function () use ($customer, $branch) {
            $c = Customer::whereKey($customer)->lockForUpdate()->firstOrFail();
            $wallet = DB::table('customer_wallets')->where('customer_id', $customer)->where('branch_id', $branch)->first();
            if ($wallet) {
                return (array) $wallet;
            }$a = FinancialAccount::create(['branch_id' => $branch, 'code' => 'WALLET-'.$branch.'-'.$customer, 'name' => 'Wallet '.$c->name, 'account_type' => 'customer_wallet']);
            $id = DB::table('customer_wallets')->insertGetId(['customer_id' => $customer, 'branch_id' => $branch, 'financial_account_id' => $a->id, 'created_at' => now(), 'updated_at' => now()]);
            Audit::record('WALLET_CREATE', 'customer_wallets', $id, $branch);

            return (array) DB::table('customer_wallets')->find($id);
        });
    }
}
