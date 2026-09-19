<?php

namespace App\Models;

class CashierSession extends Record
{
    protected function casts(): array
    {
        return ['closed_at' => 'datetime'];
    }

    public function account()
    {
        return $this->belongsTo(FinancialAccount::class, 'financial_account_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
