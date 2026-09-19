<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class ImportRailwayData extends Command
{
    protected $signature = 'db:import-railway-data';

    protected $description = 'Import data SQL lama ke database Railway';

    public function handle()
    {
        $path = database_path('asp_smartDb_data.sql');

        if (!file_exists($path)) {
            $this->error('File SQL tidak ditemukan.');
            return self::FAILURE;
        }

        try {
            $this->info('Memulai import data...');

            DB::statement('SET FOREIGN_KEY_CHECKS=0');

            $sql = file_get_contents($path);

            DB::unprepared($sql);

            DB::statement('SET FOREIGN_KEY_CHECKS=1');

            $this->info('Import data berhasil.');

            return self::SUCCESS;
        } catch (\Throwable $e) {
            DB::statement('SET FOREIGN_KEY_CHECKS=1');

            $this->error('Import gagal:');
            $this->error($e->getMessage());

            return self::FAILURE;
        }
    }
}