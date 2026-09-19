<?php

namespace App\Models;

class DigitalProduct extends Record
{
    public function provider()
    {
        return $this->belongsTo(Provider::class);
    }

    public function operator()
    {
        return $this->belongsTo(Operator::class);
    }
}
