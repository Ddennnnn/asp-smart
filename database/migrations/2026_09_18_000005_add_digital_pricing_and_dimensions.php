<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('customer_group_prices')) {
            Schema::create('customer_group_prices', function (Blueprint $t) {
                $t->id();
                $t->foreignId('customer_group_id')->constrained();
                $t->foreignId('digital_product_id')->constrained();
                $t->decimal('selling_price', 18, 2);
                $t->timestamps();
            });
        }
        Schema::table('customer_group_prices', fn (Blueprint $t) => $t->unique(['customer_group_id', 'digital_product_id'], 'customer_group_product_unique'));
        Schema::create('branch_group_prices', function (Blueprint $t) {
            $t->id();
            $t->foreignId('branch_id')->constrained();
            $t->foreignId('customer_group_id')->constrained();
            $t->foreignId('digital_product_id')->constrained();
            $t->decimal('selling_price', 18, 2);
            $t->timestamps();
            $t->unique(['branch_id', 'customer_group_id', 'digital_product_id'], 'branch_group_product_unique');
        });
        Schema::create('operator_prefixes', function (Blueprint $t) {
            $t->id();
            $t->foreignId('operator_id')->constrained();
            $t->string('prefix', 8)->unique();
            $t->timestamps();
        });
        Schema::table('transactions', function (Blueprint $t) {
            $t->foreignId('provider_id')->nullable()->constrained();
            $t->foreignId('digital_product_id')->nullable()->constrained();
            $t->foreignId('operator_id')->nullable()->constrained();
            $t->string('digital_category')->nullable()->index();
        });
    }

    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $t) {
            $t->dropConstrainedForeignId('provider_id');
            $t->dropConstrainedForeignId('digital_product_id');
            $t->dropConstrainedForeignId('operator_id');
            $t->dropColumn('digital_category');
        });
        Schema::dropIfExists('operator_prefixes');
        Schema::dropIfExists('branch_group_prices');
        Schema::dropIfExists('customer_group_prices');
    }
};
