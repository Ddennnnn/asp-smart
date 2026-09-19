<?php

namespace Database\Seeders;

use App\Models\Branch;
use App\Models\DigitalProduct;
use App\Models\FinancialAccount;
use App\Models\Operator;
use App\Models\Product;
use App\Models\Provider;
use App\Models\ProviderAccount;
use App\Models\Role;
use App\Models\User;
use App\Services\LedgerService;
use App\Services\SettingService;
use App\Services\TransactionService;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CounterSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function () {
            $branch = Branch::firstOrCreate(['code' => 'CB01'], ['name' => 'Cabang Utama', 'is_main' => true, 'address' => 'Alamat counter belum diatur', 'city' => 'Jambi', 'is_active' => true]);
            $all = [];
            foreach (config('counter.resources') as $d) {
                foreach (['view', 'create', 'update'] as $a) {
                    $all[] = $d['permission'].'.'.$a;
                }
            }
            $operations = ['dashboard.view', 'branch.view', 'account.view', 'product.view', 'provider.view', 'customer.view', 'customer.create', 'stock.view', 'sale.view', 'sale.create', 'cash_withdrawal.create', 'transfer.create', 'digital.create', 'session.manage'];
            $roles = ['OWNER' => ['*'], 'ADMIN' => array_values(array_unique(array_merge($all, $operations, ['account.transfer', 'stock.adjust', 'stock.transfer', 'purchase.create', 'report.view', 'report.export', 'audit.view']))), 'MANAGER' => array_merge($operations, ['account.transfer', 'stock.adjust', 'report.view', 'report.export']), 'CASHIER' => $operations, 'INVENTORY' => ['dashboard.view', 'branch.view', 'product.view', 'product.create', 'product.update', 'supplier.view', 'supplier.create', 'supplier.update', 'stock.view', 'stock.adjust', 'stock.transfer', 'purchase.create', 'sale.view', 'account.view'], 'FINANCE' => ['dashboard.view', 'branch.view', 'account.view', 'account.create', 'account.update', 'account.adjust', 'account.transfer', 'account.reconcile', 'expense.view', 'expense.create', 'income.create', 'report.view', 'report.export', 'sale.view', 'supplier.view']];
            foreach ($roles as $name => $permissions) {
                Role::firstOrCreate(['name' => $name], ['permissions' => $permissions]);
            }
            foreach (['owner' => ['Owner', 'OWNER', 'Owner123!'], 'admin' => ['Administrator', 'ADMIN', 'Admin123!'], 'cashier' => ['Kasir', 'CASHIER', 'Cashier123!']] as $key => [$name,$role,$password]) {
                $u = User::firstOrCreate(['email' => $key.'@aspsmart.local'], ['name' => $name, 'password' => $password, 'role_id' => Role::where('name', $role)->value('id')]);
                $u->branches()->syncWithoutDetaching([$branch->id]);
            }
            $owner = User::where('email', 'owner@aspsmart.local')->first();
            foreach (['CASH' => ['Kas Counter', 'cash', '5000000'], 'BCA' => ['BCA', 'bank', '8000000'], 'BRI' => ['BRI', 'bank', '3000000'], 'DIGI' => ['Digiflazz (Demo)', 'provider', '2000000']] as $code => [$name,$type,$balance]) {
                if (! FinancialAccount::where('code', $code)->exists()) {
                    $a = FinancialAccount::create(['branch_id' => $branch->id, 'code' => $code, 'name' => $name, 'account_type' => $type, 'opening_balance' => $balance, 'minimum_balance' => '100000']);
                    app(LedgerService::class)->post($a, $balance, $owner, null, 'opening', 'Saldo awal pengembangan');
                }
            }
            $provider = Provider::firstOrCreate(['code' => 'MOCK'], ['name' => 'Provider Demo', 'provider_type' => 'mock']);
            ProviderAccount::firstOrCreate(['provider_id' => $provider->id, 'branch_id' => $branch->id], ['financial_account_id' => FinancialAccount::where('code', 'DIGI')->value('id'), 'account_name' => 'Saldo digital utama']);
            foreach (['Telkomsel', 'Indosat', 'XL', 'PLN', 'DANA', 'OVO', 'GoPay'] as $name) {
                Operator::firstOrCreate(['name' => $name]);
            }
            foreach (['TSEL10' => ['Telkomsel 10K', '10000', '10500', '12000', 'pulsa'], 'TSEL50' => ['Telkomsel 50K', '50000', '48500', '52000', 'pulsa'], 'DATA' => ['Internet Package Demo', '25000', '22000', '27000', 'data']] as $code => [$name,$nominal,$cost,$price,$category]) {
                DigitalProduct::firstOrCreate(['code' => $code], ['provider_id' => $provider->id, 'operator_id' => Operator::where('name', 'Telkomsel')->value('id'), 'name' => $name, 'nominal' => $nominal, 'cost_price' => $cost, 'selling_price' => $price, 'category' => $category]);
            }
            foreach (['customer_groups' => ['Retail', 'Reseller', 'Agent', 'VIP'], 'product_categories' => ['Aksesoris', 'Jasa'], 'brands' => ['Universal'], 'units' => ['PCS'], 'expense_categories' => ['Listrik', 'Internet', 'Sewa', 'Gaji', 'Transport', 'Operasional', 'ATK', 'Lainnya']] as $table => $names) {
                foreach ($names as $name) {
                    if (! DB::table($table)->where('name', $name)->exists()) {
                        DB::table($table)->insert(['name' => $name, 'created_at' => now(), 'updated_at' => now()]);
                    }
                }
            }
            foreach (['USB' => ['USB Cable', '15000', '25000'], 'GLASS' => ['Tempered Glass', '10000', '20000'], 'CHARGER' => ['Charger', '35000', '55000']] as $sku => [$name,$cost,$price]) {
                $p = Product::firstOrCreate(['sku' => $sku], ['name' => $name, 'purchase_price' => $cost, 'selling_price' => $price, 'warranty_days' => 7]);
                if ($p->wasRecentlyCreated) {
                    app(TransactionService::class)->create(['type' => 'stock_adjustment', 'branch_id' => $branch->id, 'product_id' => $p->id, 'actual_quantity' => 20, 'notes' => 'Stok awal pengembangan', 'idempotency_key' => 'seed-stock-'.$sku.'-initial'], $owner);
                }
            }
            $defaults = ['business' => ['name' => 'ASP Smart Cell', 'legal_name' => 'ASP Smart Cell', 'tagline' => 'Solusi digital, dekat dengan Anda.', 'address' => 'Silakan atur alamat counter', 'phone' => '', 'whatsapp' => '', 'email' => '', 'logo' => '', 'description' => 'Pulsa, paket data, transfer, dan aksesori dalam satu counter.'], 'website' => ['hero_title' => 'Kebutuhan digital Anda. Semua ada di sini.', 'hero_description' => 'Isi pulsa, beli paket data, transfer uang, dan temukan aksesori pilihan. Kami siap membantu setiap hari.', 'primary_color' => '#176b52', 'theme' => 'modern', 'seo_title' => 'ASP Smart Cell', 'seo_description' => 'Counter pulsa dan layanan digital.'], 'receipt' => ['paper' => '80mm', 'footer' => 'Terima kasih atas kepercayaan Anda.', 'terms' => 'Simpan struk sebagai bukti transaksi.', 'show_logo' => true], 'approval_threshold' => '5000000', 'require_cashier_session' => true, 'allow_negative_stock' => false];
            foreach ($defaults as $key => $value) {
                if (SettingService::get($key) === null) {
                    SettingService::put($key, $value);
                }
            }
            foreach (['Tentang kami' => ['about', 'Layanan personal untuk kebutuhan digital Anda.'], 'Layanan counter' => ['services', 'Pulsa • Paket data • Token PLN • Transfer • Tarik tunai • Aksesoris'], 'Jam operasional' => ['hours', 'Hubungi cabang untuk memastikan jam operasional.']] as $title => [$type,$content]) {
                if (! DB::table('website_sections')->where('title', $title)->exists()) {
                    DB::table('website_sections')->insert(['type' => $type, 'title' => $title, 'content' => $content, 'enabled' => true, 'sort_order' => 1, 'created_at' => now(), 'updated_at' => now()]);
                }
            }
        });
    }
}
