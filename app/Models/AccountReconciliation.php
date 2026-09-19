<?php

namespace App\Models;

class AccountReconciliation extends Record
{
    public function account()
    {
        return $this->belongsTo(FinancialAccount::class, 'financial_account_id');
    }
}
