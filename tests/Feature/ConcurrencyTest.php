<?php

namespace Tests\Feature;

use App\Models\FinancialAccount;
use Symfony\Component\Process\Process;
use Tests\TestCase;

class ConcurrencyTest extends TestCase
{
    public function test_simultaneous_writers_preserve_exact_balance_and_ledger_chain(): void
    {
        $this->assertSame('asp_smart_testing', config('database.connections.mysql.database'));
        $this->artisan('migrate:fresh', ['--force' => true])->assertExitCode(0);
        $this->seed();
        $jobs = [];
        foreach (['a', 'b'] as $worker) {
            $p = new Process([PHP_BINARY, base_path('scripts/concurrency-worker.php'), $worker], base_path(), ['APP_ENV' => 'testing']);
            $p->setTimeout(60);
            $p->start();
            $jobs[] = $p;
        }
        foreach ($jobs as $job) {
            $job->wait();
            $this->assertTrue($job->isSuccessful(), $job->getErrorOutput().$job->getOutput());
        }
        $account = FinancialAccount::where('code', 'CASH')->firstOrFail();
        $this->assertSame('5000000.20', $account->current_balance);
        $this->assertSame(21, $account->ledger()->count());
        $balance = '0.00';
        foreach ($account->ledger()->orderBy('id')->get() as $entry) {
            $this->assertSame($balance, $entry->balance_before);
            $balance = bcadd($balance, ($entry->direction === 'out' ? '-' : '').$entry->amount, 2);
            $this->assertSame($balance, $entry->balance_after);
        }$this->assertSame($balance, $account->current_balance);
    }
}
