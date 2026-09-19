<?php

namespace App\Support;

use App\Models\User;

class Access
{
    public static function branch(User $user, ?int $id): void
    {
        abort_unless($user->canAccessBranch($id), 403, 'Anda tidak memiliki akses cabang ini.');
    }

    public static function scope($query, User $user, ?int $branch = null, string $column = 'branch_id')
    {
        if ($branch) {
            self::branch($user, $branch);

            return $query->where($column, $branch);
        }

        return $user->role?->name === 'OWNER' ? $query : $query->whereIn($column, $user->branches()->pluck('branches.id'));
    }
}
