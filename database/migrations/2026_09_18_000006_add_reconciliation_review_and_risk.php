<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('account_reconciliations', function (Blueprint $t) {
            $t->foreignId('approved_by')->nullable()->constrained('users');
            $t->text('review_notes')->nullable();
            $t->timestamp('reviewed_at')->nullable();
        });
        Schema::create('risk_flags', function (Blueprint $t) {
            $t->id();
            $t->foreignId('branch_id')->constrained();
            $t->foreignId('transaction_id')->constrained();
            $t->string('reason');
            $t->string('status')->default('review');
            $t->foreignId('reviewed_by')->nullable()->constrained('users');
            $t->text('notes')->nullable();
            $t->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('risk_flags');
        Schema::table('account_reconciliations', function (Blueprint $t) {
            $t->dropConstrainedForeignId('approved_by');
            $t->dropColumn(['review_notes', 'reviewed_at']);
        });
    }
};
