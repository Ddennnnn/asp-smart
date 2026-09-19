<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('customer_wallets', function (Blueprint $t) {
            $t->id();
            $t->foreignId('customer_id')->constrained();
            $t->foreignId('branch_id')->constrained();
            $t->foreignId('financial_account_id')->unique()->constrained();
            $t->timestamps();
            $t->unique(['customer_id', 'branch_id']);
        });
        Schema::create('branch_daily_closings', function (Blueprint $t) {
            $t->id();
            $t->foreignId('branch_id')->constrained();
            $t->date('date');
            $t->json('summary');
            $t->foreignId('closed_by')->constrained('users');
            $t->timestamps();
            $t->unique(['branch_id', 'date']);
        });
        Schema::create('notification_reads', function (Blueprint $t) {
            $t->foreignId('user_id')->constrained();
            $t->string('notification_key');
            $t->timestamp('read_at');
            $t->primary(['user_id', 'notification_key']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notification_reads');
        Schema::dropIfExists('branch_daily_closings');
        Schema::dropIfExists('customer_wallets');
    }
};
