<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class TransactionResource extends JsonResource
{
    public function toArray($request): array
    {
        $data = parent::toArray($request);
        $details = $this->details;
        foreach (['destination_account', 'target_number'] as $field) {
            if (isset($details[$field])) {
                $details[$field] = '******'.substr($details[$field], -4);
            }
        }
        unset($details['idempotency_key'],$data['request_hash'],$data['idempotency_key']);
        $data['details'] = $details;

        return $data;
    }
}
