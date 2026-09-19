<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('number_sequences', function (Blueprint $t) {
            $t->id();
            $t->foreignId('branch_id')->constrained();
            $t->string('type');
            $t->string('period', 6);
            $t->unsignedBigInteger('value')->default(0);
            $t->unique(['branch_id', 'type', 'period']);
        });
        Schema::create('stock_transfers', function (Blueprint $t) {
            $t->id();
            $t->foreignId('branch_id')->constrained();
            $t->foreignId('destination_branch_id')->constrained('branches');
            $t->foreignId('transaction_id')->unique()->constrained();
            $t->string('status')->default('draft');
            $t->foreignId('created_by')->constrained('users');
            $t->foreignId('approved_by')->nullable()->constrained('users');
            $t->foreignId('received_by')->nullable()->constrained('users');
            $t->text('notes');
            $t->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stock_transfers');
        Schema::dropIfExists('number_sequences');
    }
};
