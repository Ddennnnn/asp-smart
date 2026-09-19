<?php

namespace App\Models;

class BranchStock extends Record
{
    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
