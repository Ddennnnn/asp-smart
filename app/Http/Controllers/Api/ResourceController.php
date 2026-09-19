<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ResourceService;
use App\Support\Access;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ResourceController extends Controller
{
    public function __construct(private ResourceService $service) {}

    public function metadata(Request $r)
    {
        return collect(config('counter.resources'))->filter(fn ($d) => $r->user()->hasPermission($d['permission'].'.view'))->map(fn ($d) => collect($d)->except('model')->all());
    }

    public function index(Request $r, string $resource)
    {
        $q = $this->service->query($resource, $r->user(), $r->integer('branch_id') ?: null);
        $d = $this->service->definition($resource);
        $field = isset($d['fields']['name']) ? 'name' : (isset($d['fields']['title']) ? 'title' : (isset($d['fields']['account_name']) ? 'account_name' : null));
        if ($field && $r->filled('search')) {
            $q->where(function ($sub) use ($field, $r, $resource) {
                $term = '%'.$r->string('search').'%';
                $sub->where($field, 'like', $term);
                if ($resource === 'products') {
                    $sub->orWhere('sku', 'like', $term)->orWhere('barcode', 'like', $term);
                }
            });
        }
        if ($resource === 'products' && $r->integer('branch_id')) {
            Access::branch($r->user(), $r->integer('branch_id'));
            $q->withSum(['stocks as stock_quantity' => fn ($s) => $s->where('branch_id', $r->integer('branch_id'))], 'quantity');
        }

        return $q->orderByDesc('id')->paginate(min(100, max(1, $r->integer('per_page', 20))))->through(fn ($row) => $this->service->present($row, $resource));
    }

    public function save(Request $r, string $resource, ?int $id = null)
    {
        $d = $this->service->definition($resource);
        $rules = collect($d['fields'])->map(fn ($f) => $f['rules'])->all();
        if ($id && $resource === 'financial-accounts') {
            unset($rules['opening_balance']);
        }
        foreach (['code', 'sku', 'barcode'] as $key) {
            if (isset($rules[$key])) {
                $rules[$key] = [...explode('|', $rules[$key]), Rule::unique(str_replace('-', '_', $resource), $key)->ignore($id)];
            }
        }
        $row = $this->service->save($resource, $r->validate($rules), $r->user(), $id);

        return response()->json($this->service->present($row, $resource), $id ? 200 : 201);
    }
}
