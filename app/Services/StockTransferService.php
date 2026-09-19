<?php

namespace App\Services;

use App\Models\Product;
use App\Models\Transaction;
use App\Models\User;
use App\Support\Access;
use App\Support\Audit;
use Illuminate\Support\Facades\DB;

class StockTransferService
{
    public function create(array $d, User $u)
    {
        Access::branch($u, (int) $d['branch_id']);
        Access::branch($u, (int) $d['destination_branch_id']);

        return DB::transaction(function () use ($d, $u) {
            $tx = Transaction::create(['reference_number' => app(NumberingService::class)->next((int) $d['branch_id'], 'stock_transfer'), 'idempotency_key' => $d['idempotency_key'], 'request_hash' => hash('sha256', json_encode($d)), 'branch_id' => $d['branch_id'], 'created_by' => $u->id, 'type' => 'stock_transfer', 'status' => 'draft', 'details' => $d, 'notes' => $d['notes']]);
            foreach ($d['items'] as $i) {
                $p = Product::findOrFail($i['product_id']);
                abort_unless($p->track_stock && $p->is_active, 422, 'Produk tidak dapat ditransfer.');
                $tx->items()->create(['product_id' => $p->id, 'name' => $p->name, 'quantity' => $i['quantity'], 'unit_price' => '0', 'unit_cost' => $p->purchase_price]);
            }$id = DB::table('stock_transfers')->insertGetId(['branch_id' => $d['branch_id'], 'destination_branch_id' => $d['destination_branch_id'], 'transaction_id' => $tx->id, 'status' => 'draft', 'created_by' => $u->id, 'notes' => $d['notes'], 'created_at' => now(), 'updated_at' => now()]);
            Audit::record('TRANSFER_DRAFT', 'stock_transfers', $id, (int) $d['branch_id']);

            return DB::table('stock_transfers')->find($id);
        });
    }

    public function transition(int $id, string $action, User $u)
    {
        return DB::transaction(function () use ($id, $action, $u) {
            $t = DB::table('stock_transfers')->where('id', $id)->lockForUpdate()->first();
            abort_unless($t, 404);
            Access::branch($u, $t->branch_id);
            Access::branch($u, $t->destination_branch_id);
            $tx = Transaction::whereKey($t->transaction_id)->lockForUpdate()->firstOrFail();
            $valid = ['approve' => ['draft', 'approved'], 'send' => ['approved', 'sent'], 'receive' => ['sent', 'received'], 'cancel' => ['draft', 'cancelled']];
            abort_unless(isset($valid[$action]) && $t->status === $valid[$action][0], 409, 'Status transfer tidak sesuai.');
            if ($action === 'approve') {
                abort_unless($u->hasPermission('approval.approve'), 403);
            }$next = $valid[$action][1];
            $updates = ['status' => $next, 'updated_at' => now()];
            if ($action === 'approve') {
                $updates['approved_by'] = $u->id;
            }if ($action === 'receive') {
                $updates['received_by'] = $u->id;
            }if (in_array($action, ['send', 'receive'])) {
                foreach ($tx->items()->orderBy('product_id')->get() as $i) {
                    app(InventoryService::class)->move($action === 'send' ? $t->branch_id : $t->destination_branch_id, Product::findOrFail($i->product_id), ($action === 'send' ? -1 : 1) * $i->quantity, $tx, $u, $action === 'send' ? 'Pengiriman stok' : 'Penerimaan stok');
                }
            }DB::table('stock_transfers')->where('id', $id)->update($updates);
            $tx->update(['status' => $next === 'received' ? 'completed' : $next]);
            Audit::record('TRANSFER_'.strtoupper($action), 'stock_transfers', $id, $t->branch_id);

            return DB::table('stock_transfers')->find($id);
        }, 5);
    }
}
