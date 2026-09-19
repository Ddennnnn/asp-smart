<?php

namespace App\Http\Requests;

use App\Enums\TransactionType;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class TransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        $type = TransactionType::tryFrom((string) $this->input('type'));

        return $type && $type !== TransactionType::StockOpname && $this->user()->hasPermission($type->permission());
    }

    public function rules(): array
    {
        $money = ['regex:/^\d{1,14}(\.\d{1,2})?$/D'];

        return ['settlement_of' => 'required_if:type,payable_payment,receivable_payment,purchase_return|integer|exists:transactions,id', 'wallet_account_id' => 'required_if:type,wallet_topup|integer|exists:financial_accounts,id', 'type' => ['required', Rule::enum(TransactionType::class)], 'branch_id' => 'required|integer|exists:branches,id', 'idempotency_key' => 'required|string|min:16|max:80', 'customer_id' => 'nullable|exists:customers,id', 'supplier_id' => 'required_if:type,purchase|nullable|exists:suppliers,id', 'amount' => ['required_if:type,cash_withdrawal,money_transfer,account_transfer,expense,income,wallet_topup,payable_payment,receivable_payment', ...$money], 'account_id' => 'required_unless:type,stock_adjustment,stock_transfer,reversal|integer|exists:financial_accounts,id', 'counter_account_id' => 'required_if:type,cash_withdrawal,money_transfer,account_transfer|integer|different:account_id|exists:financial_accounts,id', 'fee' => ['nullable', ...$money], 'fee_method' => 'required_if:type,cash_withdrawal|in:cash,bank', 'destination_bank' => 'required_if:type,money_transfer|string|max:100', 'destination_account' => 'required_if:type,money_transfer|regex:/^[0-9]{5,40}$/D', 'recipient_name' => 'required_if:type,money_transfer|string|max:150', 'digital_product_id' => 'required_if:type,digital|integer|exists:digital_products,id', 'target_number' => 'required_if:type,digital|regex:/^[0-9]{8,20}$/D', 'notes' => 'required_if:type,adjustment,stock_adjustment,reversal|nullable|string|max:2000', 'actual_balance' => ['required_if:type,adjustment', ...$money], 'items' => 'required_if:type,sale,purchase|array|min:1|max:100', 'items.*.product_id' => 'required|integer|distinct|exists:products,id', 'items.*.quantity' => 'required|integer|min:1|max:100000', 'items.*.unit_cost' => ['required_if:type,purchase', ...$money], 'paid_amount' => ['nullable', ...$money], 'product_id' => 'required_if:type,stock_adjustment,stock_transfer|integer|exists:products,id', 'actual_quantity' => 'required_if:type,stock_adjustment|integer|min:0|max:1000000', 'quantity' => 'required_if:type,stock_transfer|integer|min:1|max:1000000', 'destination_branch_id' => 'required_if:type,stock_transfer|integer|different:branch_id|exists:branches,id', 'reversal_of' => 'required_if:type,reversal|integer|exists:transactions,id'];
    }
}
