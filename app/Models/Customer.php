<?php

namespace App\Models;

use Illuminate\Database\Eloquent\SoftDeletes;

class Customer extends Record
{
    use SoftDeletes;
}
