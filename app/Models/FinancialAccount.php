<?php

namespace App\Models;

class FinancialAccount extends Record
{
    protected $attributes = ['current_balance' => '0.00', 'opening_balance' => '0.00', 'minimum_balance' => '0.00', 'is_active' => true, 'is_central' => false];

    protected $hidden = ['account_number'];

    protected function casts(): array
    {
        return ['account_number' => 'encrypted', 'opening_balance' => 'decimal:2', 'current_balance' => 'decimal:2', 'minimum_balance' => 'decimal:2', 'is_active' => 'boolean', 'is_central' => 'boolean'];
    }

    public function ledger()
    {
        return $this->hasMany(AccountTransaction::class);
    }
}
