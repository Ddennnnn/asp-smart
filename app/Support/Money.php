<?php

namespace App\Support;

use Illuminate\Validation\ValidationException;

/** Money stays decimal strings; BCMath is the sole arithmetic engine. */
final class Money
{
    public static function value(mixed $value): string
    {
        if (! is_string($value) && ! is_int($value)) {
            throw ValidationException::withMessages(['amount' => 'Nominal harus berupa angka desimal, bukan float.']);
        }
        if (! preg_match('/^-?\d{1,14}(\.\d{1,2})?$/D', (string) $value)) {
            throw ValidationException::withMessages(['amount' => 'Nominal tidak valid (maksimal 14 digit dan 2 desimal).']);
        }

        return bcadd((string) $value, '0', 2);
    }

    public static function add(string $a, string $b): string
    {
        return bcadd($a, $b, 2);
    }

    public static function sub(string $a, string $b): string
    {
        return bcsub($a, $b, 2);
    }

    public static function mul(string $a, string $b): string
    {
        return bcmul($a, $b, 2);
    }
}
