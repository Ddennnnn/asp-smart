<?php

namespace App\Services;

use App\Models\BranchStock;
use App\Models\Product;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class InventoryService
{
    public function move(int $branch, Product $product, int $quantity, Transaction $transaction, User $user, string $reason): void
    {
        if (! $product->track_stock) {
            return;
        }
        DB::table('branch_stocks')->insertOrIgnore(['branch_id' => $branch, 'product_id' => $product->id, 'quantity' => 0, 'created_at' => now(), 'updated_at' => now()]);
        $stock = BranchStock::where('branch_id', $branch)->where('product_id', $product->id)->lockForUpdate()->firstOrFail();
        $after = $stock->quantity + $quantity;
        if ($after < 0 && ! SettingService::get('allow_negative_stock', false)) {
            throw ValidationException::withMessages(['stock' => 'Stok '.$product->name.' tidak mencukupi.']);
        }
        DB::table('stock_movements')->insert(['branch_id' => $branch, 'product_id' => $product->id, 'transaction_id' => $transaction->id, 'type' => $transaction->type, 'before_qty' => $stock->quantity, 'quantity' => $quantity, 'after_qty' => $after, 'reason' => $reason, 'created_by' => $user->id, 'created_at' => now(), 'updated_at' => now()]);
        $stock->update(['quantity' => $after]);
    }
}
