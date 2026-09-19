<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Branch;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $r)
    {
        $data = $r->validate(['email' => 'required|email', 'password' => 'required|string']);
        $user = User::where('email', $data['email'])->where('is_active', true)->first();
        $success = $user && Hash::check($data['password'], $user->password);
        DB::table('login_logs')->insert(['user_id' => $user?->id, 'ip' => $r->ip(), 'user_agent' => substr((string) $r->userAgent(), 0, 500), 'success' => $success, 'created_at' => now()]);
        if (! $success) {
            throw ValidationException::withMessages(['email' => 'Email atau kata sandi tidak sesuai.']);
        }
        Auth::login($user);
        $r->session()->regenerate();

        return $this->me($r);
    }

    public function me(Request $r)
    {
        $u = $r->user()->load('role');

        return ['user' => $u, 'permissions' => $u->role?->name === 'OWNER' ? ['*'] : $u->role?->permissions, 'branches' => $u->role?->name === 'OWNER' ? Branch::where('is_active', true)->get() : $u->branches()->where('is_active', true)->get()];
    }

    public function logout(Request $r)
    {
        Auth::guard('web')->logout();
        $r->session()->invalidate();
        $r->session()->regenerateToken();

        return response()->json(['message' => 'Anda telah keluar.']);
    }

    public function forgot(Request $r)
    {
        $r->validate(['email' => 'required|email']);
        Password::sendResetLink($r->only('email'));

        return ['message' => 'Jika email terdaftar, tautan reset akan dikirim.'];
    }

    public function reset(Request $r)
    {
        $data = $r->validate(['token' => 'required', 'email' => 'required|email', 'password' => 'required|min:10|confirmed']);
        $status = Password::reset($data, function ($user, $password) {
            $user->forceFill(['password' => $password, 'remember_token' => Str::random(60)])->save();
            $user->tokens()->delete();
            DB::table('sessions')->where('user_id', $user->id)->delete();
        });
        if ($status !== Password::PASSWORD_RESET) {
            throw ValidationException::withMessages(['email' => __($status)]);
        }

        return ['message' => 'Kata sandi diperbarui.'];
    }
}
