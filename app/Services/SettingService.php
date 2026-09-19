<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;

class SettingService
{
    public static function get(string $key, mixed $default = null): mixed
    {
        $value = DB::table('settings')->where('key', $key)->value('value');

        return $value === null ? $default : json_decode($value, true);
    }

    public static function put(string $key, mixed $value): void
    {
        DB::table('settings')->updateOrInsert(['key' => $key], ['value' => json_encode($value), 'updated_at' => now(), 'created_at' => now()]);
    }
}
