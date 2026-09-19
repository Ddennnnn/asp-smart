<?php

namespace App\Enums;

enum TransactionType: string
{
    case StockOpname = 'stock_opname';
    case WalletTopup = 'wallet_topup';
    case PayablePayment = 'payable_payment';
    case ReceivablePayment = 'receivable_payment';
    case PurchaseReturn = 'purchase_return';
    case Sale = 'sale';
    case Purchase = 'purchase';
    case Withdrawal = 'cash_withdrawal';
    case Transfer = 'money_transfer';
    case Internal = 'account_transfer';
    case Digital = 'digital';
    case Expense = 'expense';
    case Income = 'income';
    case Adjustment = 'adjustment';
    case StockAdjustment = 'stock_adjustment';
    case StockTransfer = 'stock_transfer';
    case Reversal = 'reversal';

    public function permission(): string
    {
        return match ($this) {
            self::StockOpname => 'stock.opname', self::WalletTopup => 'wallet.manage',self::PayablePayment => 'payable.manage',self::ReceivablePayment => 'receivable.manage',self::PurchaseReturn => 'purchase.create',self::Sale => 'sale.create',self::Purchase => 'purchase.create',self::Withdrawal => 'cash_withdrawal.create',self::Transfer => 'transfer.create',self::Internal => 'account.transfer',self::Digital => 'digital.create',self::Expense => 'expense.create',self::Income => 'income.create',self::Adjustment => 'account.adjust',self::StockAdjustment => 'stock.adjust',self::StockTransfer => 'stock.transfer',self::Reversal => 'sale.cancel'
        };
    }
}
