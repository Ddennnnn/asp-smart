<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('transactions', fn (Blueprint $t) => $t->foreignId('settlement_of')->nullable()->constrained('transactions'));
    }

    public function down(): void
    {
        Schema::table('transactions', fn (Blueprint $t) => $t->dropConstrainedForeignId('settlement_of'));
    }
};
