<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Role;
use App\Support\Audit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rule;

class RoleController extends Controller
{
    public function permissions()
    {
        Gate::authorize('users.manage');
        $modules = ['dashboard' => 'Dashboard', 'account' => 'Rekening', 'branch' => 'Cabang', 'product' => 'Produk', 'provider' => 'Provider', 'customer' => 'Pelanggan', 'supplier' => 'Supplier', 'settings' => 'Pengaturan', 'website' => 'Website', 'sale' => 'Penjualan', 'cash_withdrawal' => 'Tarik tunai', 'transfer' => 'Transfer pelanggan', 'digital' => 'Produk digital', 'purchase' => 'Pembelian', 'stock' => 'Stok', 'expense' => 'Pengeluaran', 'income' => 'Pendapatan', 'approval' => 'Persetujuan', 'report' => 'Laporan', 'session' => 'Shift', 'audit' => 'Audit', 'users' => 'Karyawan', 'wallet' => 'Wallet pelanggan', 'payable' => 'Hutang', 'receivable' => 'Piutang', 'closing' => 'Penutupan harian'];
        $actions = ['view' => 'Lihat', 'create' => 'Tambah', 'update' => 'Ubah', 'manage' => 'Kelola', 'reveal' => 'Lihat nomor lengkap', 'central' => 'Akses rekening pusat', 'adjust' => 'Penyesuaian', 'transfer' => 'Transfer', 'reconcile' => 'Rekonsiliasi', 'cancel' => 'Pembalikan', 'approve' => 'Setujui', 'export' => 'Ekspor', 'opname' => 'Stock opname'];

        return collect(array_keys(Gate::abilities()))->sort()->values()->map(function ($key) use ($modules, $actions) {
            [$m,$a] = explode('.', $key);

            return ['key' => $key, 'label' => ($modules[$m] ?? $m).' · '.($actions[$a] ?? $a)];
        });
    }

    public function save(Request $r, ?int $id = null)
    {
        Gate::authorize('users.manage');
        $d = $r->validate(['name' => ['required', 'regex:/^[A-Z][A-Z0-9_]{2,40}$/D', Rule::unique('roles')->ignore($id)], 'permissions' => 'present|array', 'permissions.*' => ['string', Rule::in(array_keys(Gate::abilities()))]]);
        abort_if($d['name'] === 'OWNER', 422, 'Role OWNER bersifat tetap.');

        return DB::transaction(function () use ($d, $id) {
            $role = $id ? Role::findOrFail($id) : new Role;
            abort_if($role->name === 'OWNER', 403, 'Role OWNER tidak dapat diubah.');
            $old = $role->toArray();
            $role->fill($d)->save();
            Audit::record('ROLE_SAVE', 'roles', $role->id, null, $old, $role->toArray());

            return $role;
        });
    }
}
