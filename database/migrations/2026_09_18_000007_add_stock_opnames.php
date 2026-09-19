<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('stock_opnames', function (Blueprint $t) {
            $t->id();
            $t->foreignId('branch_id')->constrained();
            $t->foreignId('created_by')->constrained('users');
            $t->foreignId('transaction_id')->nullable()->unique()->constrained();
            $t->string('status')->default('draft');
            $t->text('notes');
            $t->timestamps();
        });
        Schema::create('stock_opname_items', function (Blueprint $t) {
            $t->id();
            $t->foreignId('stock_opname_id')->constrained();
            $t->foreignId('product_id')->constrained();
            $t->integer('system_quantity');
            $t->integer('actual_quantity');
            $t->unique(['stock_opname_id', 'product_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stock_opname_items');
        Schema::dropIfExists('stock_opnames');
    }
};
