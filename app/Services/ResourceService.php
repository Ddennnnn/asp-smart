<?php

namespace App\Services;

use App\Models\Branch;
use App\Models\FinancialAccount;
use App\Models\Record;
use App\Models\User;
use App\Support\Access;
use App\Support\Audit;
use App\Support\Money;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;

class ResourceService
{
    public function definition(string $resource): array
    {
        return config('counter.resources.'.$resource) ?? abort(404);
    }

    public function model(string $resource)
    {
        $d = $this->definition($resource);

        return isset($d['model']) ? new $d['model'] : (new Record)->setTable(str_replace('-', '_', $resource));
    }

    public function query(string $resource, User $user, ?int $branch = null)
    {
        $d = $this->definition($resource);
        Gate::forUser($user)->authorize($d['permission'].'.view');
        $q = $this->model($resource)->newQuery();
        if ($d['scoped'] ?? false) {
            $q = Access::scope($q, $user, $branch);
        }
        if ($resource === 'branches' && $user->role?->name !== 'OWNER') {
            $q->whereIn('id', $user->branches()->pluck('branches.id'));
        }

        return $q;
    }

    public function save(string $resource, array $data, User $user, ?int $id = null)
    {
        $d = $this->definition($resource);
        Gate::forUser($user)->authorize($d['permission'].($id ? '.update' : '.create'));

        return DB::transaction(function () use ($resource, $data, $user, $id, $d) {
            $record = $id ? $this->query($resource, $user)->whereKey($id)->lockForUpdate()->firstOrFail() : $this->model($resource);
            $old = $record->toArray();
            if ($d['scoped'] ?? false) {
                $branch = $data['branch_id'] ?? null;
                if ($branch) {
                    Access::branch($user, (int) $branch);
                } else {
                    abort_unless($user->hasPermission('account.central'), 403);
                }
            }
            if ($resource === 'branches') {
                DB::table('settings')->where('key', 'business')->lockForUpdate()->first();
                if ($data['is_main'] ?? false) {
                    Branch::where('is_main', true)->update(['is_main' => false]);
                }
            }
            if ($resource === 'financial-accounts') {
                if ($id && empty($data['account_number'])) {
                    unset($data['account_number']);
                }
                if ($id) {
                    unset($data['opening_balance']);
                    abort_unless(($data['branch_id'] ?? null) == $record->branch_id && $data['account_type'] === $record->account_type && (bool) ($data['is_central'] ?? false) === $record->is_central, 422, 'Cabang dan jenis rekening tidak dapat diubah.');
                }
                abort_unless((bool) ($data['is_central'] ?? false) === empty($data['branch_id']), 422, 'Rekening pusat tidak memiliki cabang.');
                if ($data['is_central'] ?? false) {
                    abort_unless($user->hasPermission('account.central'), 403);
                }
            }
            if ($resource === 'provider-accounts') {
                $a = FinancialAccount::findOrFail($data['financial_account_id']);
                Access::branch($user, $a->branch_id);
                abort_unless($a->branch_id == (int) $data['branch_id'] && $a->account_type === 'provider', 422, 'Pilih rekening provider pada cabang yang sama.');
            }
            if ($resource === 'products' && $data['type'] === 'service') {
                $data['track_stock'] = false;
            }
            $record->fill($data);
            $record->save();
            if ($resource === 'financial-accounts' && ! $id) {
                app(LedgerService::class)->post($record, Money::value($data['opening_balance']), $user, null, 'opening', 'Saldo awal');
            }
            Audit::record($id ? 'UPDATE' : 'CREATE', $resource, $record->id, $record->branch_id, $old, $record->toArray());

            return $record;
        }, 5);
    }

    public function present($record, string $resource): array
    {
        $row = $record->toArray();
        $d = $this->definition($resource);
        foreach ($d['fields'] as $key => $field) {
            if (isset($field['source']) && ! empty($row[$key])) {
                $related = $this->model($field['source'])->find($row[$key]);
                $row[$key.'_label'] = $related?->name ?? $related?->account_name ?? '—';
            }
        }
        if ($resource === 'financial-accounts') {
            $row['account_number_masked'] = $record->account_number ? '******'.substr($record->account_number, -4) : '—';
        }

        return $row;
    }
}
