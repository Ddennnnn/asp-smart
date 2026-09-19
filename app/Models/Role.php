<?php

namespace App\Models;

class Role extends Record
{
    protected function casts(): array
    {
        return ['permissions' => 'array'];
    }
}
