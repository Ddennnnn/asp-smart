<?php

namespace App\Services\Providers;

use App\Contracts\DigitalProviderInterface;

class MockProvider implements DigitalProviderInterface
{
    public function checkBalance(): array
    {
        return ['mode' => 'mock'];
    }

    public function getProducts(): array
    {
        return [];
    }

    public function createTransaction(string $reference, string $product, string $target): array
    {
        return ['status' => str_ends_with($target, '0000') ? 'failed' : 'success', 'reference' => 'MOCK-'.$reference];
    }

    public function checkTransaction(string $reference): array
    {
        return ['reference' => $reference, 'status' => 'unknown'];
    }
}
