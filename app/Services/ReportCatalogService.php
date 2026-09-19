<?php

namespace App\Services;

use App\Support\Access;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;

class ReportCatalogService
{
    public function catalog(): array
    {
        return ['accounts' => 'Saldo rekening', 'ledger' => 'Mutasi kas / bank / provider', 'stock' => 'Stok cabang', 'stock_movements' => 'Pergerakan stok', 'stock_transfers' => 'Transfer stok', 'reconciliations' => 'Rekonsiliasi', 'cashier_sessions' => 'Penutupan kasir', 'payables' => 'Hutang supplier', 'receivables' => 'Piutang pelanggan', 'wallets' => 'Saldo wallet pelanggan', 'branch_performance' => 'Kinerja cabang', 'digital' => 'Produk digital', 'pulsa' => 'Pulsa', 'data' => 'Paket data', 'token' => 'Token PLN', 'ewallet' => 'E-Wallet', 'cash_withdrawal' => 'Tarik tunai', 'money_transfer' => 'Transfer pelanggan', 'purchase' => 'Pembelian', 'expense' => 'Pengeluaran', 'audit' => 'Jejak audit'];
    }

    public function dataset(Request $r): array
    {
        Gate::authorize('report.view');
        $d = $r->validate(['dataset' => 'required|in:'.implode(',', array_keys($this->catalog())), 'from' => 'nullable|date_format:Y-m-d', 'to' => 'nullable|date_format:Y-m-d'.($r->filled('from') ? '|after_or_equal:from' : ''), 'branch_id' => 'nullable|integer|exists:branches,id']);
        $name = $d['dataset'];
        $branch = $r->integer('branch_id') ?: null;
        $scope = fn ($q, $column = 'branch_id') => Access::scope($q, $r->user(), $branch, $column);
        $time = null;
        if ($name === 'accounts') {
            $q = $scope(DB::table('financial_accounts as a')->leftJoin('branches as b', 'b.id', '=', 'a.branch_id'), 'a.branch_id')->select('a.id', 'b.name as branch', 'a.name as account', 'a.account_type', 'a.opening_balance', 'a.current_balance', 'a.minimum_balance');
            $columns = ['branch' => 'Cabang', 'account' => 'Rekening', 'account_type' => 'Jenis', 'opening_balance' => 'Saldo awal', 'current_balance' => 'Saldo saat ini', 'minimum_balance' => 'Minimum'];
        } elseif ($name === 'ledger') {
            $q = $scope(DB::table('account_transactions as l')->join('financial_accounts as a', 'a.id', '=', 'l.financial_account_id')->leftJoin('branches as b', 'b.id', '=', 'l.branch_id'), 'l.branch_id')->select('l.id', 'b.name as branch', 'a.name as account', 'l.reference_number', 'l.direction', 'l.amount', 'l.balance_before', 'l.balance_after', 'l.created_at');
            $columns = ['created_at' => 'Waktu', 'branch' => 'Cabang', 'account' => 'Rekening', 'reference_number' => 'Referensi', 'direction' => 'Arah', 'amount' => 'Nominal', 'balance_before' => 'Sebelum', 'balance_after' => 'Sesudah'];
            $time = 'l.created_at';
            if ($r->filled('account_id')) {
                $q->where('l.financial_account_id', $r->integer('account_id'));
            }if ($r->filled('account_type')) {
                $q->where('a.account_type', $r->input('account_type'));
            }
        } elseif ($name === 'stock') {
            $q = $scope(DB::table('branch_stocks as s')->join('products as p', 'p.id', '=', 's.product_id')->join('branches as b', 'b.id', '=', 's.branch_id'), 's.branch_id')->select('s.id', 'b.name as branch', 'p.name as product', 'p.sku', 's.quantity', 'p.minimum_stock', 'p.purchase_price')->selectRaw('s.quantity * p.purchase_price as stock_value');
            $columns = ['branch' => 'Cabang', 'product' => 'Produk', 'sku' => 'SKU', 'quantity' => 'Jumlah', 'minimum_stock' => 'Minimum', 'purchase_price' => 'Modal satuan', 'stock_value' => 'Nilai stok'];
        } elseif ($name === 'stock_movements') {
            $q = $scope(DB::table('stock_movements as s')->join('products as p', 'p.id', '=', 's.product_id')->join('branches as b', 'b.id', '=', 's.branch_id'), 's.branch_id')->select('s.id', 'b.name as branch', 'p.name as product', 's.type', 's.before_qty', 's.quantity', 's.after_qty', 's.reason', 's.created_at');
            $columns = ['created_at' => 'Waktu', 'branch' => 'Cabang', 'product' => 'Produk', 'type' => 'Jenis', 'before_qty' => 'Sebelum', 'quantity' => 'Perubahan', 'after_qty' => 'Sesudah', 'reason' => 'Alasan'];
            $time = 's.created_at';
        } elseif ($name === 'stock_transfers') {
            $q = $scope(DB::table('stock_transfers as s')->join('branches as b', 'b.id', '=', 's.branch_id')->join('branches as dest', 'dest.id', '=', 's.destination_branch_id')->join('transactions as t', 't.id', '=', 's.transaction_id'), 's.branch_id')->select('s.id', 'b.name as branch', 'dest.name as destination', 't.reference_number', 's.status', 's.notes', 's.created_at');
            $columns = ['created_at' => 'Waktu', 'branch' => 'Asal', 'destination' => 'Tujuan', 'reference_number' => 'Referensi', 'status' => 'Status', 'notes' => 'Catatan'];
            $time = 's.created_at';
        } elseif ($name === 'reconciliations') {
            $q = $scope(DB::table('account_reconciliations as s')->join('financial_accounts as a', 'a.id', '=', 's.financial_account_id')->leftJoin('branches as b', 'b.id', '=', 's.branch_id')->join('users as u', 'u.id', '=', 's.reconciled_by'), 's.branch_id')->select('s.id', 'b.name as branch', 'a.name as account', 'u.name as user', 's.system_balance', 's.actual_balance', 's.difference', 's.status', 's.notes', 's.created_at');
            $columns = ['created_at' => 'Waktu', 'branch' => 'Cabang', 'account' => 'Rekening', 'system_balance' => 'Sistem', 'actual_balance' => 'Aktual', 'difference' => 'Selisih', 'status' => 'Status', 'user' => 'Pengguna', 'notes' => 'Catatan'];
            $time = 's.created_at';
        } elseif ($name === 'cashier_sessions') {
            $q = $scope(DB::table('cashier_sessions as s')->join('branches as b', 'b.id', '=', 's.branch_id')->join('users as u', 'u.id', '=', 's.user_id'), 's.branch_id')->select('s.id', 'b.name as branch', 'u.name as user', 's.opening_cash', 's.expected_cash', 's.actual_cash', 's.difference', 's.created_at', 's.closed_at', 's.notes');
            $columns = ['created_at' => 'Mulai', 'closed_at' => 'Selesai', 'branch' => 'Cabang', 'user' => 'Kasir', 'opening_cash' => 'Awal', 'expected_cash' => 'Sistem', 'actual_cash' => 'Hitung', 'difference' => 'Selisih', 'notes' => 'Catatan'];
            $time = 's.created_at';
        } elseif (in_array($name, ['payables', 'receivables'])) {
            $party = $name === 'payables' ? 'suppliers' : 'customers';
            $fk = $name === 'payables' ? 'supplier_id' : 'customer_id';
            $q = $scope(DB::table('transactions as t')->join('branches as b', 'b.id', '=', 't.branch_id')->leftJoin($party.' as p', 'p.id', '=', 't.'.$fk), 't.branch_id')->where('t.type', $name === 'payables' ? 'purchase' : 'sale')->where('t.status', 'completed')->where('t.outstanding_amount', '>', 0)->select('t.id', 'b.name as branch', 'p.name as party', 't.reference_number', 't.amount', 't.paid_amount', 't.outstanding_amount', 't.created_at');
            $columns = ['created_at' => 'Waktu', 'branch' => 'Cabang', 'party' => $name === 'payables' ? 'Supplier' : 'Pelanggan', 'reference_number' => 'Tagihan', 'amount' => 'Total', 'paid_amount' => 'Dibayar', 'outstanding_amount' => 'Sisa'];
            $time = 't.created_at';
        } elseif ($name === 'wallets') {
            $q = $scope(DB::table('customer_wallets as w')->join('customers as c', 'c.id', '=', 'w.customer_id')->join('financial_accounts as a', 'a.id', '=', 'w.financial_account_id')->join('branches as b', 'b.id', '=', 'w.branch_id'), 'w.branch_id')->select('w.id', 'b.name as branch', 'c.name as customer', 'a.current_balance');
            $columns = ['branch' => 'Cabang', 'customer' => 'Pelanggan', 'current_balance' => 'Saldo titipan'];
        } elseif ($name === 'branch_performance') {
            $q = $scope(DB::table('transactions as t')->join('branches as b', 'b.id', '=', 't.branch_id'), 't.branch_id')->whereIn('t.status', ['completed', 'reversed'])->select('b.id', 'b.name as branch')->selectRaw('COUNT(t.id) as count, SUM(t.revenue) as revenue, SUM(t.cost) as cost, SUM(t.profit) as profit')->groupBy('b.id', 'b.name');
            $columns = ['branch' => 'Cabang', 'count' => 'Transaksi', 'revenue' => 'Pendapatan', 'cost' => 'Biaya', 'profit' => 'Laba'];
            $time = 't.created_at';
        } elseif ($name === 'audit') {
            Gate::authorize('audit.view');
            $q = $scope(DB::table('audit_logs as a')->leftJoin('users as u', 'u.id', '=', 'a.user_id')->leftJoin('branches as b', 'b.id', '=', 'a.branch_id'), 'a.branch_id')->select('a.id', 'u.name as user', 'b.name as branch', 'a.action', 'a.module', 'a.ip_address', 'a.created_at');
            $columns = ['created_at' => 'Waktu', 'branch' => 'Cabang', 'user' => 'Pengguna', 'action' => 'Aksi', 'module' => 'Modul', 'ip_address' => 'IP'];
            $time = 'a.created_at';
        } else {
            $q = $scope(DB::table('transactions as t')->join('branches as b', 'b.id', '=', 't.branch_id')->leftJoin('digital_products as p', 'p.id', '=', 't.digital_product_id'), 't.branch_id')->where('t.type', in_array($name, ['pulsa', 'data', 'token', 'ewallet']) ? 'digital' : $name)->select('t.id', 'b.name as branch', 'p.name as product', 't.reference_number', 't.status', 't.amount', 't.fee', 't.revenue', 't.cost', 't.profit', 't.created_at');
            if (in_array($name, ['pulsa', 'data', 'token', 'ewallet'])) {
                $q->where('t.digital_category', $name);
            }foreach (['provider_id', 'operator_id', 'customer_id', 'created_by', 'status'] as $f) {
                if ($r->filled($f)) {
                    $q->where('t.'.$f, $r->input($f));
                }
            }$columns = ['created_at' => 'Waktu', 'branch' => 'Cabang', 'product' => 'Produk digital', 'reference_number' => 'Referensi', 'status' => 'Status', 'amount' => 'Nominal', 'fee' => 'Admin', 'revenue' => 'Pendapatan', 'cost' => 'Biaya', 'profit' => 'Laba'];
            $time = 't.created_at';
        }
        if ($time) {
            if ($r->filled('from')) {
                $q->where($time, '>=', $r->input('from').' 00:00:00');
            }if ($r->filled('to')) {
                $q->where($time, '<=', $r->input('to').' 23:59:59');
            }
        }

        return ['title' => $this->catalog()[$name], 'columns' => $columns, 'query' => $q, 'current_snapshot' => $time === null];
    }

    public function display(array $row, array $columns): array
    {
        return collect($columns)->mapWithKeys(function ($label, $key) use ($row) {
            $value = $row[$key] ?? '—';
            if (in_array($key, ['type', 'account_type', 'status', 'direction'])) {
                $translated = __('counter.'.$value);
                $value = $translated === 'counter.'.$value ? $value : $translated;
            }

            return [$key => $value];
        })->all();
    }
}
