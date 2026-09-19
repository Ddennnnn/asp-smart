<?php

namespace App\Services;

use App\Models\FinancialAccount;
use App\Models\Transaction;
use App\Support\Access;
use Illuminate\Http\Request;

class ReportService
{
    public function transactions(Request $r)
    {
        $r->validate(['from' => 'nullable|date_format:Y-m-d', 'to' => 'nullable|date_format:Y-m-d'.($r->filled('from') ? '|after_or_equal:from' : ''), 'branch_id' => 'nullable|integer|exists:branches,id']);
        $q = Access::scope(Transaction::query(), $r->user(), $r->integer('branch_id') ?: null);
        if (! $r->user()->hasPermission('report.view')) {
            $q->where('created_by', $r->user()->id);
        }
        foreach (['type', 'status', 'customer_id', 'created_by', 'provider_id', 'operator_id', 'digital_category'] as $f) {
            if ($r->filled($f)) {
                $q->where($f, $r->input($f));
            }
        }
        if ($r->filled('account_id')) {
            $q->whereHas('ledger', fn ($ledger) => $ledger->where('financial_account_id', $r->integer('account_id')));
        }
        if ($r->filled('from')) {
            $q->where('created_at', '>=', $r->input('from').' 00:00:00');
        }
        if ($r->filled('to')) {
            $q->where('created_at', '<=', $r->input('to').' 23:59:59');
        }
        if ($r->filled('search')) {
            $q->where('reference_number', 'like', '%'.$r->string('search').'%');
        }

        return $q;
    }

    public function summary(Request $r): array
    {
        $q = $this->transactions($r)->whereIn('status', ['completed', 'reversed']);
        $totals = (clone $q)->selectRaw('COUNT(*) as count, COALESCE(SUM(revenue),0) as revenue, COALESCE(SUM(cost),0) as cost, COALESCE(SUM(profit),0) as profit')->first();
        $types = (clone $q)->selectRaw('type, COUNT(*) as count, SUM(revenue) as revenue, SUM(cost) as cost, SUM(profit) as profit')->groupBy('type')->get();
        $trend = (clone $q)->where('created_at', '>=', now()->subDays(13)->startOfDay())->selectRaw('DATE(created_at) as date, SUM(revenue) as revenue, SUM(profit) as profit')->groupByRaw('DATE(created_at)')->orderBy('date')->get();
        $accounts = $r->user()->hasPermission('report.view') ? Access::scope(FinancialAccount::query(), $r->user(), $r->integer('branch_id') ?: null)->where('account_type', '!=', 'customer_wallet')->selectRaw('account_type, SUM(current_balance) as balance')->groupBy('account_type')->get() : [];

        return compact('totals', 'types', 'trend', 'accounts');
    }
}
