<?php

use App\Models\FinancialAccount;
use App\Models\User;
use App\Services\TransactionService;
use Illuminate\Contracts\Console\Kernel;
use Illuminate\Support\Facades\DB;

require __DIR__.'/../vendor/autoload.php';
$app = require __DIR__.'/../bootstrap/app.php';
$app->make(Kernel::class)->bootstrap();
config(['database.default' => 'mysql', 'database.connections.mysql.database' => 'asp_smart_testing', 'database.connections.mysql.username' => 'root', 'database.connections.mysql.password' => '']);
DB::purge('mysql');
if (DB::connection()->getDatabaseName() !== 'asp_smart_testing') {
    throw new RuntimeException('Unsafe concurrency database.');
}
$user = User::where('email', 'owner@aspsmart.local')->firstOrFail();
$account = FinancialAccount::where('code', 'CASH')->firstOrFail();
for ($i = 0; $i < 10; $i++) {
    app(TransactionService::class)->create(['type' => 'income', 'branch_id' => $account->branch_id, 'account_id' => $account->id, 'amount' => '0.01', 'idempotency_key' => 'concurrent-'.($argv[1] ?? 'worker').'-'.str_pad((string) $i, 8, '0', STR_PAD_LEFT)], $user);
}
echo "posted 10 entries\n";
