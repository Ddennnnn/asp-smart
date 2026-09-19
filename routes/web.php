<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;

Route::get('/health-db', function () {
    $database = DB::selectOne('SELECT DATABASE() AS database_name');

    return response()->json([
        'status' => true,
        'message' => 'Laravel dan MySQL berhasil terhubung',
        'database' => $database->database_name,
    ]);
});
