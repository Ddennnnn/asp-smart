<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class ImportSqlDatabase extends Command
{
    protected $signature = 'db:import-sql';
    protected $description = 'Import SQL backup into configured database';

    public function handle()
    {
        $path = database_path('asp_smartDb_backup.sql');

        if (!file_exists($path)) {
            $this->error("File tidak ditemukan: {$path}");
            return Command::FAILURE;
        }

        $this->info('Mulai import database...');

        $sql = file_get_contents($path);

        DB::unprepared($sql);

        $this->info('Import database selesai.');

        return Command::SUCCESS;
    }
}