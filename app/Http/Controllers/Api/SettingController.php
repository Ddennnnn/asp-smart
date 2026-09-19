<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Branch;
use App\Models\Role;
use App\Models\User;
use App\Services\SettingService;
use App\Support\Audit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rule;

class SettingController extends Controller
{
    public function publicSite()
    {
        return ['business' => SettingService::get('business', []), 'website' => SettingService::get('website', []), 'receipt' => SettingService::get('receipt', []), 'branches' => Branch::where('is_active', true)->get(['id', 'name', 'address', 'phone', 'whatsapp', 'city', 'latitude', 'longitude']), 'sections' => DB::table('website_sections')->where('enabled', true)->orderBy('sort_order')->get(), 'galleries' => DB::table('galleries')->where('is_active', true)->get(), 'testimonials' => DB::table('testimonials')->where('is_active', true)->get(), 'promotions' => DB::table('promotions')->where('is_active', true)->where(fn ($q) => $q->whereNull('start_at')->orWhere('start_at', '<=', now()))->where(fn ($q) => $q->whereNull('end_at')->orWhere('end_at', '>=', now()))->get()];
    }

    public function index()
    {
        Gate::authorize('settings.view');

        return DB::table('settings')->get()->mapWithKeys(fn ($s) => [$s->key => json_decode($s->value, true)]);
    }

    public function update(Request $r)
    {
        $r->validate(['numbering' => 'sometimes|array:sale,cash_withdrawal,money_transfer,purchase,adjustment,digital,stock_transfer', 'numbering.*' => 'required|regex:/^[A-Z][A-Z0-9-]{1,19}$/D', 'website.show_services' => 'sometimes|boolean', 'website.show_gallery' => 'sometimes|boolean', 'website.show_testimonials' => 'sometimes|boolean', 'website.show_promotions' => 'sometimes|boolean']);
        Gate::authorize('settings.update');
        $data = $r->validate(['business' => 'sometimes|array:name,legal_name,tagline,address,phone,whatsapp,email,logo,description', 'business.name' => 'required_with:business|string|max:150', 'business.legal_name' => 'nullable|string|max:150', 'business.tagline' => 'nullable|string|max:250', 'business.address' => 'nullable|string|max:500', 'business.phone' => 'nullable|string|max:30', 'business.whatsapp' => 'nullable|regex:/^[0-9]{8,16}$/D', 'business.email' => 'nullable|email', 'business.logo' => 'nullable|string|starts_with:/storage/uploads/', 'business.description' => 'nullable|string|max:5000', 'website' => 'sometimes|array:hero_title,hero_description,primary_color,theme,seo_title,seo_description,show_services,show_gallery,show_testimonials,show_promotions', 'website.hero_title' => 'required_with:website|string|max:250', 'website.hero_description' => 'nullable|string|max:2000', 'website.primary_color' => 'nullable|regex:/^#[a-fA-F0-9]{6}$/D', 'website.theme' => 'nullable|in:modern,minimal,dark,retail,technology', 'website.seo_title' => 'nullable|string|max:200', 'website.seo_description' => 'nullable|string|max:500', 'receipt' => 'sometimes|array:paper,footer,terms,show_logo', 'receipt.paper' => 'required_with:receipt|in:58mm,80mm,A4', 'receipt.footer' => 'nullable|string|max:500', 'receipt.terms' => 'nullable|string|max:1000', 'receipt.show_logo' => 'boolean', 'approval_threshold' => 'sometimes|regex:/^\d{1,14}(\.\d{1,2})?$/D', 'require_cashier_session' => 'sometimes|boolean', 'allow_negative_stock' => 'sometimes|boolean', 'allow_customer_credit' => 'sometimes|boolean']);
        if ($r->has('numbering')) {
            $data['numbering'] = $r->input('numbering');
        }
        DB::transaction(function () use ($data) {
            foreach ($data as $key => $value) {
                $old = SettingService::get($key);
                SettingService::put($key, $value);
                Audit::record('SETTING_UPDATE', 'settings', $key, null, ['value' => $old], ['value' => $value]);
            }
        });

        return $this->index();
    }

    public function upload(Request $r)
    {
        Gate::authorize('website.create');
        $r->validate(['file' => 'required|file|mimes:jpg,jpeg,png,webp|max:5120']);
        $path = $r->file('file')->store('uploads', 'public');
        Audit::record('IMAGE_UPLOAD', 'uploads', $path, null);

        return ['url' => '/storage/'.$path];
    }

    public function users(Request $r)
    {
        Gate::authorize('users.manage');

        return User::with('role', 'branches')->latest('id')->paginate(25);
    }

    public function roles()
    {
        Gate::authorize('users.manage');

        return Role::all();
    }

    public function saveUser(Request $r, ?int $id = null)
    {
        Gate::authorize('users.manage');
        $d = $r->validate(['name' => 'required|string|max:150', 'email' => ['required', 'email', Rule::unique('users')->ignore($id)], 'password' => ($id ? 'nullable' : 'required').'|string|min:10', 'role_id' => 'required|exists:roles,id', 'branch_ids' => 'required|array|min:1', 'branch_ids.*' => 'integer|exists:branches,id', 'is_active' => 'boolean']);

        return DB::transaction(function () use ($d, $id, $r) {
            $user = $id ? User::findOrFail($id) : new User;
            abort_if($user->id === $r->user()->id && (($d['role_id'] != $user->role_id) || ! ($d['is_active'] ?? true)), 422, 'Tidak dapat menonaktifkan atau mengubah role sendiri.');
            $branches = $d['branch_ids'];
            unset($d['branch_ids']);
            if (empty($d['password'])) {
                unset($d['password']);
            } $user->fill($d)->save();
            $user->branches()->sync($branches);
            Audit::record('USER_SAVE', 'users', $user->id, null);

            return $user->load('role', 'branches');
        });
    }
}
