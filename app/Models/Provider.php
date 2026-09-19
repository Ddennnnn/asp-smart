<?php

namespace App\Models;

class Provider extends Record
{
    protected $hidden = ['credentials'];

    protected function casts(): array
    {
        return ['credentials' => 'encrypted:array', 'api_enabled' => 'boolean', 'is_active' => 'boolean'];
    }
}
