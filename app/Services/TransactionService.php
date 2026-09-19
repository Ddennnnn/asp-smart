<?php

namespace App\Services;

use App\Enums\TransactionType;
use App\Models\AccountTransaction;
use App\Models\Approval;
use App\Models\Branch;
use App\Models\BranchStock;
use App\Models\CashierSession;
use App\Models\DigitalProduct;
use App\Models\Product;
use App\Models\ProviderAccount;
use App\Models\Transaction;
use App\Models\User;
use App\Support\Access;
use App\Support\Audit;
use App\Support\Money;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;

class TransactionService
{
    public function __construct(private LedgerService $ledger, private InventoryService $inventory) {}

    public function create(array $data, User $user): Transaction
    {
        $type = TransactionType::from($data['type']);
        Gate::forUser($user)->authorize($type->permission());
        Access::branch($user, (int) $data['branch_id']);

        return DB::transaction(function () use ($data, $user, $type) {
            User::whereKey($user->id)->lockForUpdate()->firstOrFail();
            Branch::whereKey($data['branch_id'])->where('is_active', true)->lockForUpdate()->firstOrFail();
            $hash = hash('sha256', json_encode($data));
            $existing = Transaction::where('idempotency_key', $data['idempotency_key'])->first();
            if ($existing) {
                abort_unless($existing->created_by === $user->id && hash_equals($existing->request_hash, $hash), 409, 'Kunci transaksi telah digunakan untuk permintaan berbeda.');

                return $existing;
            }
            $requestedAccounts = array_filter([$data['account_id'] ?? null, $data['counter_account_id'] ?? null, $data['wallet_account_id'] ?? null]);
            $this->ledger->lockAccounts($requestedAccounts, $user, (int) $data['branch_id']);
            if (isset($data['destination_branch_id'])) {
                Access::branch($user, (int) $data['destination_branch_id']);
            }
            $tx = Transaction::create(['reference_number' => app(NumberingService::class)->next((int) $data['branch_id'], $type->value), 'idempotency_key' => $data['idempotency_key'], 'request_hash' => $hash, 'branch_id' => $data['branch_id'], 'created_by' => $user->id, 'customer_id' => $data['customer_id'] ?? null, 'supplier_id' => $data['supplier_id'] ?? null, 'type' => $type->value, 'status' => 'processing', 'details' => $data, 'notes' => $data['notes'] ?? null]);
            $sensitive = in_array($type, [TransactionType::StockOpname, TransactionType::Adjustment, TransactionType::StockAdjustment, TransactionType::Reversal, TransactionType::PurchaseReturn]);
            $large = bccomp((string) ($data['amount'] ?? '0'), (string) SettingService::get('approval_threshold', '5000000'), 2) > 0;
            if ($large) {
                DB::table('risk_flags')->insert(['branch_id' => $tx->branch_id, 'transaction_id' => $tx->id, 'reason' => 'Nominal melampaui batas peninjauan', 'status' => 'review', 'created_at' => now(), 'updated_at' => now()]);
            }
            if (($sensitive || $large) && ! $user->hasPermission('approval.approve')) {
                $tx->update(['status' => 'pending_approval', 'amount' => $data['amount'] ?? '0']);
                Approval::create(['branch_id' => $tx->branch_id, 'transaction_id' => $tx->id, 'requested_by' => $user->id]);
                Audit::record('APPROVAL_REQUEST', $tx->type, $tx->id, $tx->branch_id);

                return $tx;
            }

            return $this->execute($tx, $user);
        }, 5);
    }

    public function execute(Transaction $tx, User $user): Transaction
    {
        $d = $tx->details;
        $type = TransactionType::from($tx->type);
        Access::branch($user, $tx->branch_id);
        $ids = array_filter([$d['account_id'] ?? null, $d['counter_account_id'] ?? null, $d['wallet_account_id'] ?? null]);
        $digital = null;
        if ($type === TransactionType::Digital) {
            $digital = DigitalProduct::with('provider')->findOrFail($d['digital_product_id']);
            abort_unless($digital->is_active && $digital->provider->is_active, 422, 'Produk/provider tidak aktif.');
            abort_unless($digital->provider->provider_type === 'mock' && app()->environment(['local', 'testing']), 422, 'Provider live belum dikonfigurasi. Transaksi tidak dikirim.');
            $provider = ProviderAccount::where('branch_id', $tx->branch_id)->where('provider_id', $digital->provider_id)->where('is_active', true)->firstOrFail();
            $d['provider_account_id'] = $provider->financial_account_id;
            $ids[] = $provider->financial_account_id;
        }
        $accounts = $this->ledger->lockAccounts($ids, $user, $tx->branch_id);
        foreach ($accounts as $a) {
            if ($a->account_type === 'customer_wallet') {
                abort_unless(in_array($type, [TransactionType::Sale, TransactionType::Digital, TransactionType::WalletTopup]), 422, 'Wallet hanya untuk top up dan pembayaran pelanggan.');
                abort_unless(! empty($d['customer_id']) && DB::table('customer_wallets')->where('financial_account_id', $a->id)->where('customer_id', $d['customer_id'])->exists(), 422, 'Wallet tidak sesuai pelanggan.');
            }
        }
        if ($type !== TransactionType::Internal) {
            foreach ($accounts as $a) {
                abort_unless($a->is_central || $a->branch_id === $tx->branch_id, 422, 'Rekening harus sesuai cabang transaksi.');
            }
        }
        $post = function ($id, string $value) use (&$accounts, $user, $tx) {
            $this->ledger->post($accounts[$id], $value, $user, $tx, $tx->type, $tx->notes ?? $tx->reference_number);
        };
        $amount = Money::value($d['amount'] ?? '0');
        $revenue = '0.00';
        $cost = '0.00';
        $fee = '0.00';
        if (in_array($type, [TransactionType::Withdrawal, TransactionType::Transfer, TransactionType::Internal, TransactionType::Expense, TransactionType::Income])) {
            abort_unless(bccomp($amount, '0', 2) > 0, 422, 'Nominal harus lebih dari nol.');
        }
        if (in_array($type, [TransactionType::Sale, TransactionType::Digital, TransactionType::Withdrawal, TransactionType::Transfer]) && SettingService::get('require_cashier_session', true)) {
            $session = CashierSession::where('user_id', $tx->created_by)->where('branch_id', $tx->branch_id)->whereNull('closed_at')->first();
            abort_unless($session, 422, 'Buka shift kasir terlebih dahulu.');
            $tx->cashier_session_id = $session->id;
            foreach ($accounts as $a) {
                if ($a->account_type === 'cash') {
                    abort_unless($a->id === $session->financial_account_id, 422, 'Gunakan rekening kas pada shift aktif.');
                }
            }
        }
        if (in_array($type, [TransactionType::Withdrawal, TransactionType::Transfer])) {
            $fee = $this->fee($tx->type, $tx->branch_id, $amount, $d['fee'] ?? null);
            $cash = $accounts[$d['account_id']];
            $bank = $accounts[$d['counter_account_id']];
            abort_unless(in_array($cash->account_type, ['cash', 'bank', 'ewallet']) && in_array($bank->account_type, ['bank', 'ewallet']), 422, 'Jenis rekening transaksi tidak sesuai.');
            if ($type === TransactionType::Withdrawal) {
                abort_unless($cash->account_type === 'cash', 422, 'Tarik tunai membutuhkan rekening kas.');
                $post($cash->id, '-'.$amount);
                $post($bank->id, $amount);
                $post($d['fee_method'] === 'cash' ? $cash->id : $bank->id, $fee);
            } else {
                $post($bank->id, '-'.$amount);
                $post($cash->id, Money::add($amount, $fee));
            }
            $revenue = $fee;
        } elseif ($type === TransactionType::Internal) {
            abort_unless($accounts[$d['account_id']]->branch_id === $tx->branch_id || $accounts[$d['account_id']]->is_central, 422, 'Cabang sumber tidak sesuai.');
            $post($d['account_id'], '-'.$amount);
            $post($d['counter_account_id'], $amount);
        } elseif ($type === TransactionType::Adjustment) {
            $actual = Money::value($d['actual_balance']);
            $delta = Money::sub($actual, $accounts[$d['account_id']]->current_balance);
            $post($d['account_id'], $delta);
            $amount = ltrim($delta, '-');
        } elseif ($type === TransactionType::Expense || $type === TransactionType::Income) {
            $post($d['account_id'], $type === TransactionType::Expense ? '-'.$amount : $amount);
            if ($type === TransactionType::Income) {
                $revenue = $amount;
            } else {
                $cost = $amount;
            }
        } elseif ($type === TransactionType::Digital) {
            abort_unless($d['account_id'] != $d['provider_account_id'] && $accounts[$d['provider_account_id']]->account_type === 'provider', 422, 'Rekening provider tidak sesuai.');
            $price = app(PricingService::class)->digital($digital, $tx->branch_id, $tx->customer_id);
            $tx->provider_id = $digital->provider_id;
            $tx->digital_product_id = $digital->id;
            $tx->operator_id = $digital->operator_id;
            $tx->digital_category = $digital->category;
            $fee = Money::value($digital->admin_fee);
            $amount = Money::add($price, $fee);
            $cost = Money::value($digital->cost_price);
            $result = (new Providers\MockProvider)->createTransaction($tx->reference_number, $digital->code, $d['target_number']);
            $d['product_name'] = $digital->name;
            $d['provider_reference'] = $result['reference'];
            $d['provider_name'] = $digital->provider->name;
            if ($result['status'] === 'failed') {
                $tx->update(['status' => 'failed', 'details' => $d, 'amount' => $amount]);
                Audit::record('DIGITAL_FAILED', 'digital', $tx->id, $tx->branch_id);

                return $tx;
            }
            $post($d['provider_account_id'], '-'.$cost);
            $post($d['account_id'], ($accounts[$d['account_id']]->account_type === 'customer_wallet' ? '-' : '').$amount);
            $revenue = $amount;
        } elseif ($type === TransactionType::Sale || $type === TransactionType::Purchase) {
            $amount = '0.00';
            $cost = '0.00';
            $items = $d['items'];
            usort($items, fn ($a, $b) => $a['product_id'] <=> $b['product_id']);
            foreach ($items as $item) {
                $p = Product::whereKey($item['product_id'])->where('is_active', true)->lockForUpdate()->firstOrFail();
                $price = Money::value($type === TransactionType::Sale ? $p->selling_price : $item['unit_cost']);
                $unitCost = Money::value($type === TransactionType::Sale ? $p->purchase_price : $item['unit_cost']);
                $amount = Money::add($amount, Money::mul($price, (string) $item['quantity']));
                $cost = Money::add($cost, Money::mul($unitCost, (string) $item['quantity']));
                $tx->items()->create(['product_id' => $p->id, 'name' => $p->name, 'quantity' => $item['quantity'], 'unit_price' => $price, 'unit_cost' => $unitCost, 'warranty_days' => $p->warranty_days]);
                $this->inventory->move($tx->branch_id, $p, ($type === TransactionType::Sale ? -1 : 1) * $item['quantity'], $tx, $user, $tx->reference_number);
            }
            $paid = Money::value($d['paid_amount'] ?? $amount);
            if ($type === TransactionType::Sale) {
                $credit = bccomp($paid, $amount, 2) < 0;
                abort_if($credit && (! SettingService::get('allow_customer_credit', false) || ! $tx->customer_id), 422, 'Pembayaran kurang dari total. Kredit harus diaktifkan dan pelanggan wajib dipilih.');
                $received = $credit ? $paid : $amount;
                $post($d['account_id'], ($accounts[$d['account_id']]->account_type === 'customer_wallet' ? '-' : '').$received);
                $revenue = $amount;
                $tx->change_amount = $credit ? '0.00' : Money::sub($paid, $amount);
                $tx->outstanding_amount = $credit ? Money::sub($amount, $paid) : '0.00';
            } else {
                abort_unless(bccomp($paid, $amount, 2) <= 0, 422, 'Pembayaran melebihi tagihan.');
                $post($d['account_id'], '-'.$paid);
                $tx->outstanding_amount = Money::sub($amount, $paid);
                $cost = '0.00';
            }
            $tx->paid_amount = $paid;
        } elseif ($type === TransactionType::WalletTopup) {
            abort_unless(bccomp($amount, '0', 2) > 0 && $d['account_id'] != $d['wallet_account_id'], 422, 'Nominal/rekening top up tidak valid.');
            abort_unless($accounts[$d['wallet_account_id']]->account_type === 'customer_wallet' && in_array($accounts[$d['account_id']]->account_type, ['cash', 'bank', 'ewallet']), 422, 'Jenis rekening top up tidak sesuai.');
            $post($d['account_id'], $amount);
            $post($d['wallet_account_id'], $amount);
        } elseif (in_array($type, [TransactionType::PayablePayment, TransactionType::ReceivablePayment])) {
            $original = Transaction::whereKey($d['settlement_of'])->lockForUpdate()->firstOrFail();
            Access::branch($user, $original->branch_id);
            abort_unless($original->branch_id === $tx->branch_id && $original->status === 'completed' && $original->type === ($type === TransactionType::PayablePayment ? 'purchase' : 'sale'), 422, 'Tagihan tidak sesuai.');
            abort_unless(bccomp($amount, '0', 2) > 0 && bccomp($amount, $original->outstanding_amount, 2) <= 0, 422, 'Pembayaran melebihi sisa tagihan.');
            $post($d['account_id'], ($type === TransactionType::PayablePayment ? '-' : '').$amount);
            $original->update(['outstanding_amount' => Money::sub($original->outstanding_amount, $amount), 'paid_amount' => Money::add($original->paid_amount, $amount)]);
            $d['settlement_reference'] = $original->reference_number;
            $tx->settlement_of = $original->id;
        } elseif ($type === TransactionType::PurchaseReturn) {
            $original = Transaction::whereKey($d['settlement_of'])->lockForUpdate()->firstOrFail();
            Access::branch($user, $original->branch_id);
            abort_unless($original->branch_id === $tx->branch_id && $original->type === 'purchase' && $original->status === 'completed', 422, 'Pembelian tidak dapat diretur.');
            foreach ($original->items as $item) {
                $this->inventory->move($tx->branch_id, Product::withTrashed()->findOrFail($item->product_id), -$item->quantity, $tx, $user, $d['notes'] ?? 'Retur pembelian');
            }
            $post($d['account_id'], $original->paid_amount);
            $amount = $original->amount;
            $d['settlement_reference'] = $original->reference_number;
            $original->update(['status' => 'returned', 'outstanding_amount' => '0.00']);
        } elseif ($type === TransactionType::StockOpname) {
            $items = $d['items'];
            usort($items, fn ($a, $b) => $a['product_id'] <=> $b['product_id']);
            foreach ($items as $item) {
                $p = Product::whereKey($item['product_id'])->lockForUpdate()->firstOrFail();
                $stock = BranchStock::where('branch_id', $tx->branch_id)->where('product_id', $p->id)->lockForUpdate()->first();
                $before = $stock?->quantity ?? 0;
                abort_unless($before === (int) $item['system_quantity'], 409, 'Stok '.$p->name.' berubah sejak dihitung. Buat opname baru.');
                $this->inventory->move($tx->branch_id, $p, (int) $item['actual_quantity'] - $before, $tx, $user, $d['notes']);
            }
        } elseif ($type === TransactionType::StockAdjustment || $type === TransactionType::StockTransfer) {
            $p = Product::whereKey($d['product_id'])->lockForUpdate()->firstOrFail();
            abort_unless($p->track_stock, 422, 'Produk jasa tidak memiliki stok.');
            if ($type === TransactionType::StockAdjustment) {
                $before = BranchStock::where('branch_id', $tx->branch_id)->where('product_id', $p->id)->lockForUpdate()->value('quantity') ?? 0;
                $this->inventory->move($tx->branch_id, $p, $d['actual_quantity'] - $before, $tx, $user, $d['notes']);
            } else {
                Access::branch($user, (int) $d['destination_branch_id']);
                $this->inventory->move($tx->branch_id, $p, -$d['quantity'], $tx, $user, 'Transfer keluar');
                $this->inventory->move((int) $d['destination_branch_id'], $p, $d['quantity'], $tx, $user, 'Transfer masuk');
            }
        } elseif ($type === TransactionType::Reversal) {
            $original = Transaction::whereKey($d['reversal_of'])->lockForUpdate()->firstOrFail();
            Access::branch($user, $original->branch_id);
            abort_unless($original->branch_id === $tx->branch_id && $original->status === 'completed' && in_array($original->type, ['sale', 'digital', 'cash_withdrawal', 'money_transfer', 'account_transfer', 'expense', 'income']), 422, 'Transaksi tidak dapat dibalik.');
            abort_if($original->type === 'sale' && bccomp($original->outstanding_amount, '0', 2) > 0, 422, 'Lunasi atau koreksi piutang terlebih dahulu sebelum reversal.');
            $settlements = Transaction::where('settlement_of', $original->id)->where('type', 'receivable_payment')->where('status', 'completed')->lockForUpdate()->get();
            $entries = AccountTransaction::whereIn('transaction_id', [$original->id, ...$settlements->pluck('id')->all()])->orderByDesc('id')->get();
            $accounts = $this->ledger->lockAccounts($entries->pluck('financial_account_id')->all(), $user, $tx->branch_id);
            foreach ($entries as $entry) {
                $post($entry->financial_account_id, ($entry->direction === 'in' ? '-' : '').$entry->amount);
            }
            foreach ($settlements as $settlement) {
                $settlement->update(['status' => 'reversed']);
            }
            foreach ($original->items as $item) {
                $this->inventory->move($tx->branch_id, Product::withTrashed()->findOrFail($item->product_id), $item->quantity, $tx, $user, $d['notes']);
            }
            $amount = $original->amount;
            $revenue = Money::sub('0', $original->revenue);
            $cost = Money::sub('0', $original->cost);
            $tx->reversal_of = $original->id;
            $original->update(['status' => 'reversed']);
        }
        $tx->fill(['amount' => $amount, 'fee' => $fee, 'revenue' => $revenue, 'cost' => $cost, 'profit' => Money::sub($revenue, $cost), 'status' => 'completed', 'details' => $d]);
        $tx->save();
        Audit::record('POST', $tx->type, $tx->id, $tx->branch_id, [], ['amount' => $amount, 'reference' => $tx->reference_number]);

        return $tx->fresh(['items', 'branch', 'creator', 'customer']);
    }

    public function fee(string $type, int $branch, string $amount, mixed $manual = null): string
    {
        $rule = DB::table('transaction_fee_rules')->where('is_active', true)->where('type', $type)->where(fn ($q) => $q->whereNull('branch_id')->orWhere('branch_id', $branch))->where('minimum_amount', '<=', $amount)->where(fn ($q) => $q->whereNull('maximum_amount')->orWhere('maximum_amount', '>=', $amount))->orderByDesc('branch_id')->orderByDesc('minimum_amount')->first();
        if ($rule) {
            return $rule->fee_type === 'percentage' ? bcdiv(bcmul($amount, $rule->fee_value, 4), '100', 2) : Money::value($rule->fee_value);
        }

        return Money::value($manual ?? '0');
    }
}
