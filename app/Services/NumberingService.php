<?php

namespace App\Services;

use App\Models\Branch;
use Illuminate\Support\Facades\DB;

class NumberingService
{
    public function next(int $branch, string $type): string
    {
        if (DB::transactionLevel() < 1) {
            throw new \LogicException('Numbering requires a database transaction.');
        }
        $key = ['branch_id' => $branch, 'type' => $type, 'period' => now()->format('Ym')];
        DB::table('number_sequences')->insertOrIgnore($key + ['value' => 0]);
        $row = DB::table('number_sequences')->where($key)->lockForUpdate()->first();
        $number = $row->value + 1;
        DB::table('number_sequences')->where('id', $row->id)->update(['value' => $number]);
        $defaults = ['sale' => 'TRX', 'cash_withdrawal' => 'CASHOUT', 'money_transfer' => 'TRANSFER', 'digital' => 'DIGITAL', 'purchase' => 'PURCHASE', 'stock_adjustment' => 'STOCK', 'stock_transfer' => 'STOCK-TRF', 'account_transfer' => 'INTERNAL'];
        $prefix = SettingService::get('numbering', [])[$type] ?? $defaults[$type] ?? strtoupper($type);

        return $prefix.'/'.Branch::findOrFail($branch)->code.'/'.$key['period'].'/'.str_pad((string) $number, 6, '0', STR_PAD_LEFT);
    }
}
