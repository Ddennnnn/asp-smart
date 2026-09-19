<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BranchStock;
use App\Models\Product;
use App\Services\TransactionService;
use App\Support\Access;
use App\Support\Audit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;

class StockOpnameController extends Controller
{
    public function index(Request $r)
    {
        Gate::authorize('stock.view');

        return Access::scope(DB::table('stock_opnames as o')->join('branches as b', 'b.id', '=', 'o.branch_id')->leftJoin('transactions as t', 't.id', '=', 'o.transaction_id')->select('o.id', 'o.branch_id', 'o.notes', 'o.created_at', 'o.transaction_id', 'b.name as branch_name')->selectRaw('COALESCE(t.status,o.status) as status'), $r->user(), $r->integer('branch_id') ?: null, 'o.branch_id')->orderByDesc('o.id')->paginate(25)->through(function ($row) {
            $row->items = DB::table('stock_opname_items as i')->join('products as p', 'p.id', '=', 'i.product_id')->where('i.stock_opname_id', $row->id)->select('p.name', 'i.system_quantity', 'i.actual_quantity')->get();

            return $row;
        });
    }

    public function store(Request $r)
    {
        Gate::authorize('stock.opname');
        $d = $r->validate(['branch_id' => 'required|exists:branches,id', 'notes' => 'required|string|max:1000', 'items' => 'required|array|min:1|max:100', 'items.*.product_id' => 'required|distinct|exists:products,id', 'items.*.actual_quantity' => 'required|integer|min:0|max:1000000']);
        Access::branch($r->user(), (int) $d['branch_id']);

        return DB::transaction(function () use ($r, $d) {
            $id = DB::table('stock_opnames')->insertGetId(['branch_id' => $d['branch_id'], 'created_by' => $r->user()->id, 'notes' => $d['notes'], 'created_at' => now(), 'updated_at' => now()]);
            foreach ($d['items'] as $item) {
                $p = Product::findOrFail($item['product_id']);
                abort_unless($p->track_stock, 422, 'Produk jasa tidak memiliki stok.');
                $system = BranchStock::where('branch_id', $d['branch_id'])->where('product_id', $p->id)->value('quantity') ?? 0;
                DB::table('stock_opname_items')->insert(['stock_opname_id' => $id, 'product_id' => $p->id, 'system_quantity' => $system, 'actual_quantity' => $item['actual_quantity']]);
            }Audit::record('OPNAME_DRAFT', 'stock_opnames', $id, (int) $d['branch_id']);

            return ['id' => $id];
        });
    }

    public function post(Request $r, int $id, TransactionService $s)
    {
        Gate::authorize('stock.opname');

        return DB::transaction(function () use ($r, $id, $s) {
            $row = DB::table('stock_opnames')->where('id', $id)->lockForUpdate()->first();
            abort_unless($row, 404);
            Access::branch($r->user(), $row->branch_id);
            abort_if($row->transaction_id, 409, 'Opname sudah diajukan.');
            $items = DB::table('stock_opname_items')->where('stock_opname_id', $id)->get()->map(fn ($item) => ['product_id' => $item->product_id, 'actual_quantity' => $item->actual_quantity, 'system_quantity' => $item->system_quantity])->all();
            $tx = $s->create(['type' => 'stock_opname', 'branch_id' => $row->branch_id, 'items' => $items, 'notes' => $row->notes, 'idempotency_key' => 'opname-post-'.str_pad((string) $id, 16, '0', STR_PAD_LEFT)], $r->user());
            DB::table('stock_opnames')->where('id', $id)->update(['transaction_id' => $tx->id, 'updated_at' => now()]);

            return ['id' => $id, 'transaction_id' => $tx->id, 'status' => $tx->status];
        });
    }
}
