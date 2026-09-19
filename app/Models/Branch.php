<?php

namespace App\Models;

use Illuminate\Database\Eloquent\SoftDeletes;

class Branch extends Record
{
    use SoftDeletes;

    protected function casts(): array
    {
        return ['is_main' => 'boolean', 'is_active' => 'boolean'];
    }
}
