<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\DigitalProduct;
use Illuminate\Support\Facades\DB;

class PricingService
{
    public function digital(DigitalProduct $product, int $branch, ?int $customer): string
    {
        $group = $customer ? Customer::findOrFail($customer)->customer_group_id : null;
        if ($group) {
            $price = DB::table('branch_group_prices')->where('branch_id', $branch)->where('customer_group_id', $group)->where('digital_product_id', $product->id)->value('selling_price');
            if ($price !== null) {
                return $price;
            }
        }
        $price = DB::table('branch_product_prices')->where('branch_id', $branch)->where('digital_product_id', $product->id)->value('selling_price');
        if ($price !== null) {
            return $price;
        }
        if ($group) {
            $price = DB::table('customer_group_prices')->where('customer_group_id', $group)->where('digital_product_id', $product->id)->value('selling_price');
            if ($price !== null) {
                return $price;
            }
        }

        return $product->selling_price;
    }
}
