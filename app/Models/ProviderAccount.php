<?php

namespace App\Models;

class ProviderAccount extends Record
{
    public function provider()
    {
        return $this->belongsTo(Provider::class);
    }

    public function financialAccount()
    {
        return $this->belongsTo(FinancialAccount::class);
    }
}
