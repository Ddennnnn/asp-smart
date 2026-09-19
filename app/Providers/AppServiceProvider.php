<?php

namespace App\Providers;

use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Services are resolved through Laravel's container.
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        foreach (array_unique(array_column(config('counter.resources'), 'permission')) as $module) {
            foreach (['view', 'create', 'update'] as $action) {
                Gate::define($module.'.'.$action, fn ($user) => $user->hasPermission($module.'.'.$action));
            }
        }
        foreach (['stock.opname', 'account.reveal', 'wallet.manage', 'payable.manage', 'receivable.manage', 'closing.manage', 'dashboard.view', 'account.central', 'account.adjust', 'account.transfer', 'account.reconcile', 'sale.view', 'sale.create', 'sale.cancel', 'cash_withdrawal.create', 'transfer.create', 'digital.create', 'purchase.create', 'stock.view', 'stock.adjust', 'stock.transfer', 'expense.create', 'income.create', 'approval.approve', 'report.view', 'report.export', 'session.manage', 'audit.view', 'users.manage'] as $permission) {
            Gate::define($permission, fn ($user) => $user->hasPermission($permission));
        }
        RateLimiter::for('login', fn ($request) => [Limit::perMinute(5)->by(strtolower((string) $request->input('email')).'|'.$request->ip())]);
        RateLimiter::for('api', fn ($request) => Limit::perMinute(180)->by($request->user()?->id ?? $request->ip()));
        ResetPassword::createUrlUsing(fn ($user, $token) => config('app.frontend_url').'/reset-password?token='.$token.'&email='.urlencode($user->email));
    }
}
