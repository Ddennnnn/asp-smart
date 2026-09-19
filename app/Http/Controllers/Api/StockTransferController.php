<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\StockTransferService;
use App\Support\Access;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;

class StockTransferController extends Controller
{
    public function index(Request $r)
    {
        Gate::authorize('stock.transfer');

        return Access::scope(DB::table('stock_transfers')->join('branches as source', 'source.id', '=', 'stock_transfers.branch_id')->join('branches as destination', 'destination.id', '=', 'stock_transfers.destination_branch_id')->join('transactions', 'transactions.id', '=', 'stock_transfers.transaction_id')->select('stock_transfers.*', 'source.name as source_name', 'destination.name as destination_name', 'transactions.reference_number'), $r->user(), $r->integer('branch_id') ?: null, 'stock_transfers.branch_id')->orderByDesc('stock_transfers.id')->paginate(25);
    }

    public function store(Request $r, StockTransferService $s)
    {
        Gate::authorize('stock.transfer');
        $d = $r->validate(['branch_id' => 'required|exists:branches,id', 'destination_branch_id' => 'required|different:branch_id|exists:branches,id', 'items' => 'required|array|min:1|max:100', 'items.*.product_id' => 'required|distinct|exists:products,id', 'items.*.quantity' => 'required|integer|min:1|max:100000', 'notes' => 'required|string|max:1000', 'idempotency_key' => 'required|string|min:16|max:80']);

        return $s->create($d, $r->user());
    }

    public function transition(Request $r, int $id, StockTransferService $s)
    {
        Gate::authorize('stock.transfer');
        $d = $r->validate(['action' => 'required|in:approve,send,receive,cancel']);

        return $s->transition($id, $d['action'], $r->user());
    }
}
