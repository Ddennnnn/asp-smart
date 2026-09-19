<?php

namespace App\Models;

class Transaction extends Record
{
    protected function casts(): array
    {
        return ['details' => 'encrypted:array'];
    }

    public function items()
    {
        return $this->hasMany(TransactionItem::class);
    }

    public function ledger()
    {
        return $this->hasMany(AccountTransaction::class);
    }

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
