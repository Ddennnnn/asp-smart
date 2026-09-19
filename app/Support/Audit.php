<?php

namespace App\Support;

use Illuminate\Support\Facades\DB;

class Audit
{
    public static function record(string $action, string $module, mixed $id, ?int $branch, array $old = [], array $new = []): void
    {
        foreach (['password', 'credentials', 'account_number', 'destination_account', 'target_number', 'remember_token'] as $key) {
            unset($old[$key],$new[$key]);
        }
        DB::table('audit_logs')->insert(['user_id' => auth()->id(), 'branch_id' => $branch, 'action' => $action, 'module' => $module, 'reference_id' => (string) $id, 'old_values' => json_encode($old), 'new_values' => json_encode($new), 'ip_address' => request()->ip(), 'user_agent' => substr((string) request()->userAgent(), 0, 500), 'created_at' => now()]);
    }
}
