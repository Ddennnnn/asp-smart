<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Record extends Model
{
    protected $guarded = ['id'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean', 'enabled' => 'boolean'];
    }

    public function getCasts(): array
    {
        return array_merge(parent::getCasts(), array_fill_keys(['branch_id', 'destination_branch_id', 'created_by', 'customer_id', 'supplier_id', 'financial_account_id', 'provider_id', 'operator_id', 'product_id', 'digital_product_id', 'cashier_session_id', 'user_id', 'transaction_id', 'reversal_of', 'settlement_of'], 'integer'));
    }

    public function branch()
    {
        return $this->belongsTo(Branch::class);
    }
}
