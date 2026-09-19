<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('branches', function (Blueprint $t) {
            $t->id();
            $t->string('code')->unique();
            $t->string('name');
            $t->boolean('is_main')->default(false);
            foreach (['phone', 'whatsapp', 'email', 'address', 'city', 'province', 'postal_code'] as $f) {
                $t->string($f)->nullable();
            }
            $t->decimal('latitude', 10, 7)->nullable();
            $t->decimal('longitude', 10, 7)->nullable();
            $t->boolean('is_active')->default(true);
            $t->timestamps();
            $t->softDeletes();
        });
        Schema::create('roles', function (Blueprint $t) {
            $t->id();
            $t->string('name')->unique();
            $t->json('permissions');
            $t->timestamps();
        });
        Schema::table('users', function (Blueprint $t) {
            $t->foreignId('role_id')->nullable()->constrained();
            $t->boolean('is_active')->default(true);
            $t->softDeletes();
        });
        Schema::create('user_branches', function (Blueprint $t) {
            $t->foreignId('user_id')->constrained();
            $t->foreignId('branch_id')->constrained();
            $t->primary(['user_id', 'branch_id']);
        });
        Schema::create('personal_access_tokens', function (Blueprint $t) {
            $t->id();
            $t->morphs('tokenable');
            $t->text('name');
            $t->string('token', 64)->unique();
            $t->text('abilities')->nullable();
            $t->timestamp('last_used_at')->nullable();
            $t->timestamp('expires_at')->nullable()->index();
            $t->timestamps();
        });
        foreach (['customer_groups', 'product_categories', 'brands', 'units', 'operators', 'expense_categories'] as $table) {
            Schema::create($table, function (Blueprint $t) {
                $t->id();
                $t->string('name')->unique();
                $t->boolean('is_active')->default(true);
                $t->timestamps();
            });
        }
        foreach (['customers', 'suppliers'] as $table) {
            Schema::create($table, function (Blueprint $t) use ($table) {
                $t->id();
                $t->string('code')->unique();
                $t->string('name');
                foreach (['phone', 'whatsapp', 'email', 'address', 'notes'] as $f) {
                    $t->string($f)->nullable();
                }
                if ($table === 'customers') {
                    $t->foreignId('customer_group_id')->nullable()->constrained();
                }
                $t->boolean('is_active')->default(true);
                $t->timestamps();
                $t->softDeletes();
            });
        }
        Schema::create('financial_accounts', function (Blueprint $t) {
            $t->id();
            $t->foreignId('branch_id')->nullable()->constrained();
            $t->string('code')->unique();
            $t->string('name');
            $t->string('account_type');
            $t->string('bank_name')->nullable();
            $t->text('account_number')->nullable();
            $t->string('account_holder')->nullable();
            $t->decimal('opening_balance', 18, 2)->default(0);
            $t->decimal('current_balance', 18, 2)->default(0);
            $t->decimal('minimum_balance', 18, 2)->default(0);
            $t->boolean('is_central')->default(false);
            $t->boolean('is_active')->default(true);
            $t->timestamps();
        });
        Schema::create('providers', function (Blueprint $t) {
            $t->id();
            $t->string('code')->unique();
            $t->string('name');
            $t->string('provider_type')->default('mock');
            $t->boolean('api_enabled')->default(false);
            $t->text('credentials')->nullable();
            $t->boolean('is_active')->default(true);
            $t->timestamps();
        });
        Schema::create('provider_accounts', function (Blueprint $t) {
            $t->id();
            $t->foreignId('provider_id')->constrained();
            $t->foreignId('branch_id')->constrained();
            $t->foreignId('financial_account_id')->constrained();
            $t->string('account_name');
            $t->boolean('is_active')->default(true);
            $t->timestamps();
            $t->unique(['provider_id', 'branch_id']);
        });
        Schema::create('digital_products', function (Blueprint $t) {
            $t->id();
            $t->foreignId('provider_id')->constrained();
            $t->foreignId('operator_id')->constrained();
            $t->string('code')->unique();
            $t->string('name');
            $t->string('category');
            foreach (['nominal', 'cost_price', 'selling_price', 'admin_fee'] as $f) {
                $t->decimal($f, 18, 2)->default(0);
            } $t->boolean('is_active')->default(true);
            $t->timestamps();
        });
        Schema::create('products', function (Blueprint $t) {
            $t->id();
            $t->string('sku')->unique();
            $t->string('barcode')->nullable()->unique();
            $t->string('name');
            $t->text('description')->nullable();
            $t->string('type')->default('physical');
            foreach (['category_id' => 'product_categories', 'brand_id' => 'brands', 'unit_id' => 'units'] as $f => $table) {
                $t->foreignId($f)->nullable()->constrained($table);
            } $t->decimal('purchase_price', 18, 2)->default(0);
            $t->decimal('selling_price', 18, 2);
            $t->boolean('track_stock')->default(true);
            $t->unsignedInteger('minimum_stock')->default(5);
            $t->unsignedInteger('warranty_days')->default(0);
            $t->string('image')->nullable();
            $t->boolean('is_active')->default(true);
            $t->timestamps();
            $t->softDeletes();
        });
        Schema::create('branch_product_prices', function (Blueprint $t) {
            $t->id();
            $t->foreignId('branch_id')->constrained();
            $t->foreignId('digital_product_id')->constrained();
            $t->decimal('selling_price', 18, 2);
            $t->timestamps();
            $t->unique(['branch_id', 'digital_product_id']);
        });
        Schema::create('branch_stocks', function (Blueprint $t) {
            $t->id();
            $t->foreignId('branch_id')->constrained();
            $t->foreignId('product_id')->constrained();
            $t->integer('quantity')->default(0);
            $t->timestamps();
            $t->unique(['branch_id', 'product_id']);
        });
        Schema::create('cashier_sessions', function (Blueprint $t) {
            $t->id();
            $t->foreignId('branch_id')->constrained();
            $t->foreignId('user_id')->constrained();
            $t->foreignId('financial_account_id')->constrained();
            foreach (['opening_cash', 'expected_cash', 'actual_cash', 'difference'] as $f) {
                $t->decimal($f, 18, 2)->nullable();
            } $t->text('notes')->nullable();
            $t->timestamp('closed_at')->nullable();
            $t->timestamps();
        });
        Schema::create('transactions', function (Blueprint $t) {
            $t->id();
            $t->string('reference_number')->unique();
            $t->string('idempotency_key', 80)->unique();
            $t->string('request_hash', 64);
            $t->foreignId('branch_id')->constrained();
            $t->foreignId('created_by')->constrained('users');
            $t->foreignId('customer_id')->nullable()->constrained();
            $t->foreignId('supplier_id')->nullable()->constrained();
            $t->foreignId('cashier_session_id')->nullable()->constrained();
            $t->string('type')->index();
            $t->string('status')->index();
            foreach (['amount', 'fee', 'revenue', 'cost', 'profit', 'paid_amount', 'change_amount', 'outstanding_amount'] as $f) {
                $t->decimal($f, 18, 2)->default(0);
            }
            $t->text('details');
            $t->text('notes')->nullable();
            $t->foreignId('reversal_of')->nullable()->unique()->constrained('transactions');
            $t->timestamps();
            $t->index(['branch_id', 'created_at']);
        });
        Schema::create('transaction_items', function (Blueprint $t) {
            $t->id();
            $t->foreignId('transaction_id')->constrained();
            $t->foreignId('product_id')->constrained();
            $t->string('name');
            $t->integer('quantity');
            $t->decimal('unit_price', 18, 2);
            $t->decimal('unit_cost', 18, 2);
            $t->unsignedInteger('warranty_days')->default(0);
        });
        Schema::create('account_transactions', function (Blueprint $t) {
            $t->id();
            $t->foreignId('branch_id')->nullable()->constrained();
            $t->foreignId('financial_account_id')->constrained();
            $t->foreignId('transaction_id')->nullable()->constrained();
            $t->string('transaction_type');
            $t->string('reference_number');
            $t->string('direction', 3);
            foreach (['amount', 'balance_before', 'balance_after'] as $f) {
                $t->decimal($f, 18, 2);
            } $t->text('description');
            $t->foreignId('created_by')->constrained('users');
            $t->timestamps();
            $t->index(['financial_account_id', 'created_at']);
        });
        Schema::create('stock_movements', function (Blueprint $t) {
            $t->id();
            $t->foreignId('branch_id')->constrained();
            $t->foreignId('product_id')->constrained();
            $t->foreignId('transaction_id')->nullable()->constrained();
            $t->string('type');
            $t->integer('before_qty');
            $t->integer('quantity');
            $t->integer('after_qty');
            $t->text('reason');
            $t->foreignId('created_by')->constrained('users');
            $t->timestamps();
        });
        Schema::create('transaction_fee_rules', function (Blueprint $t) {
            $t->id();
            $t->foreignId('branch_id')->nullable()->constrained();
            $t->string('name');
            $t->string('type');
            $t->decimal('minimum_amount', 18, 2)->default(0);
            $t->decimal('maximum_amount', 18, 2)->nullable();
            $t->string('fee_type')->default('fixed');
            $t->decimal('fee_value', 18, 2);
            $t->boolean('is_active')->default(true);
            $t->timestamps();
        });
        Schema::create('approvals', function (Blueprint $t) {
            $t->id();
            $t->foreignId('branch_id')->constrained();
            $t->foreignId('transaction_id')->unique()->constrained();
            $t->foreignId('requested_by')->constrained('users');
            $t->foreignId('approved_by')->nullable()->constrained('users');
            $t->string('status')->default('pending');
            $t->text('reason')->nullable();
            $t->timestamps();
        });
        Schema::create('account_reconciliations', function (Blueprint $t) {
            $t->id();
            $t->foreignId('branch_id')->nullable()->constrained();
            $t->foreignId('financial_account_id')->constrained();
            foreach (['system_balance', 'actual_balance', 'difference'] as $f) {
                $t->decimal($f, 18, 2);
            } $t->string('status');
            $t->text('notes')->nullable();
            $t->foreignId('reconciled_by')->constrained('users');
            $t->timestamps();
        });
        Schema::create('settings', function (Blueprint $t) {
            $t->string('key')->primary();
            $t->json('value');
            $t->timestamps();
        });
        Schema::create('website_sections', function (Blueprint $t) {
            $t->id();
            $t->string('type');
            $t->string('title');
            $t->text('subtitle')->nullable();
            $t->text('content')->nullable();
            $t->string('image')->nullable();
            $t->boolean('enabled')->default(true);
            $t->integer('sort_order')->default(0);
            $t->timestamps();
        });
        foreach (['galleries', 'testimonials', 'promotions'] as $table) {
            Schema::create($table, function (Blueprint $t) {
                $t->id();
                $t->string('title');
                $t->text('description')->nullable();
                $t->string('image')->nullable();
                $t->timestamp('start_at')->nullable();
                $t->timestamp('end_at')->nullable();
                $t->boolean('is_active')->default(true);
                $t->timestamps();
            });
        }
        Schema::create('audit_logs', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->nullable()->constrained();
            $t->foreignId('branch_id')->nullable()->constrained();
            $t->string('action');
            $t->string('module');
            $t->string('reference_id')->nullable();
            $t->json('old_values')->nullable();
            $t->json('new_values')->nullable();
            $t->string('ip_address', 45)->nullable();
            $t->text('user_agent')->nullable();
            $t->timestamp('created_at')->useCurrent();
        });
        Schema::create('login_logs', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->nullable()->constrained();
            $t->string('ip', 45)->nullable();
            $t->text('user_agent')->nullable();
            $t->boolean('success');
            $t->timestamp('created_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::disableForeignKeyConstraints();
        foreach (['login_logs', 'audit_logs', 'promotions', 'testimonials', 'galleries', 'website_sections', 'settings', 'account_reconciliations', 'approvals', 'transaction_fee_rules', 'stock_movements', 'account_transactions', 'transaction_items', 'transactions', 'cashier_sessions', 'branch_stocks', 'branch_product_prices', 'products', 'digital_products', 'provider_accounts', 'providers', 'financial_accounts', 'customers', 'suppliers', 'expense_categories', 'operators', 'units', 'brands', 'product_categories', 'customer_groups', 'personal_access_tokens', 'user_branches'] as $table) {
            Schema::dropIfExists($table);
        }
        Schema::table('users', function (Blueprint $t) {
            $t->dropConstrainedForeignId('role_id');
            $t->dropColumn(['is_active', 'deleted_at']);
        });
        Schema::dropIfExists('roles');
        Schema::dropIfExists('branches');
        Schema::enableForeignKeyConstraints();
    }
};
