<?php

namespace App\Models;

use Illuminate\Database\Eloquent\SoftDeletes;

class Product extends Record
{
    use SoftDeletes;

    protected function casts(): array
    {
        return ['track_stock' => 'boolean', 'is_active' => 'boolean'];
    }

    public function stocks()
    {
        return $this->hasMany(BranchStock::class);
    }
}
