<?php

namespace App\Models;

class AccountTransaction extends Record
{
    public function account()
    {
        return $this->belongsTo(FinancialAccount::class, 'financial_account_id');
    }
}
