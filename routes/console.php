<?php

use App\Services\ReconciliationService;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('counter:verify-ledger', function () {
    $errors = app(ReconciliationService::class)->verify();
    foreach ($errors as $error) {
        $this->error($error);
    }
    if ($errors) {
        return 1;
    }
    $this->info('Seluruh saldo dan stok sesuai dengan rantai mutasi.');

    return 0;
})->purpose('Verify all account and stock mutation chains without modifying data');

Schedule::command('counter:verify-ledger')->dailyAt('23:50')->withoutOverlapping()->appendOutputTo(storage_path('logs/ledger-integrity.log'));
