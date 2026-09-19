<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\TransactionRequest;
use App\Http\Resources\TransactionResource;
use App\Models\AccountTransaction;
use App\Models\Transaction;
use App\Services\ReportService;
use App\Services\SettingService;
use App\Services\TransactionService;
use App\Support\Access;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class TransactionController extends Controller
{
    public function index(Request $r, ReportService $reports)
    {
        Gate::authorize('sale.view');

        return TransactionResource::collection($reports->transactions($r)->with('branch', 'creator', 'customer')->latest('id')->paginate(20));
    }

    public function store(TransactionRequest $r, TransactionService $service)
    {
        return new TransactionResource($service->create($r->validated(), $r->user())->load('branch', 'creator', 'customer', 'items'));
    }

    public function show(Request $r, Transaction $transaction)
    {
        Gate::authorize('sale.view');
        Access::branch($r->user(), $transaction->branch_id);
        abort_unless($r->user()->hasPermission('report.view') || $transaction->created_by === $r->user()->id, 403);

        return new TransactionResource($transaction->load('branch', 'creator', 'customer', 'items'));
    }

    public function invoice(Request $r, Transaction $transaction)
    {
        $data = $this->show($r, $transaction)->resolve();
        $paper = $r->input('paper', '80mm');
        abort_unless(in_array($paper, ['58mm', '80mm', 'A4']), 422);
        $pdf = Pdf::loadView('receipt', ['tx' => $data, 'business' => SettingService::get('business', []), 'receipt' => SettingService::get('receipt', [])]);
        $pdf->setPaper($paper === 'A4' ? 'a4' : [0, 0, $paper === '58mm' ? 164.4 : 226.8, 800]);

        return $pdf->download('receipt-'.$transaction->id.'.pdf');
    }

    public function ledger(Request $r)
    {
        Gate::authorize('account.view');
        $q = Access::scope(AccountTransaction::with('account', 'branch'), $r->user(), $r->integer('branch_id') ?: null);
        if ($r->filled('account_id')) {
            $q->where('financial_account_id', $r->integer('account_id'));
        }

        return $q->latest('id')->paginate(25);
    }
}
