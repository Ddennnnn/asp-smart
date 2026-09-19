<?php

namespace App\Contracts;

interface DigitalProviderInterface
{
    public function checkBalance(): array;

    public function getProducts(): array;

    public function createTransaction(string $reference, string $product, string $target): array;

    public function checkTransaction(string $reference): array;
}
