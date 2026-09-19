<?php

namespace App\Models;

class Approval extends Record
{
    public function transaction()
    {
        return $this->belongsTo(Transaction::class);
    }
}
