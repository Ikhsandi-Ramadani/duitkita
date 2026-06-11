<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\Wallet;
use Illuminate\Support\Facades\DB;

class BalanceService
{
    /**
     * Apply a transaction's effect to wallet balance(s).
     * Must be called inside an existing DB::transaction block.
     */
    public function apply(Transaction $transaction): void
    {
        match ($transaction->type) {
            'income'     => $this->increment($transaction->wallet_id, $transaction->amount),
            'expense'    => $this->decrement($transaction->wallet_id, $transaction->amount),
            'transfer'   => $this->transfer($transaction->wallet_id, $transaction->target_wallet_id, $transaction->amount),
            'adjustment' => $this->increment($transaction->wallet_id, $transaction->amount),
        };
    }

    /**
     * Reverse a previously-applied transaction (for update/delete).
     */
    public function reverse(Transaction $transaction): void
    {
        match ($transaction->type) {
            'income'     => $this->decrement($transaction->wallet_id, $transaction->amount),
            'expense'    => $this->increment($transaction->wallet_id, $transaction->amount),
            'transfer'   => $this->transfer($transaction->target_wallet_id, $transaction->wallet_id, $transaction->amount),
            'adjustment' => $this->decrement($transaction->wallet_id, $transaction->amount),
        };
    }

    private function increment(int $walletId, int $amount): void
    {
        Wallet::where('id', $walletId)->lockForUpdate()->increment('current_balance', $amount);
    }

    private function decrement(int $walletId, int $amount): void
    {
        Wallet::where('id', $walletId)->lockForUpdate()->decrement('current_balance', $amount);
    }

    private function transfer(int $sourceId, int $targetId, int $amount): void
    {
        Wallet::where('id', $sourceId)->lockForUpdate()->decrement('current_balance', $amount);
        Wallet::where('id', $targetId)->lockForUpdate()->increment('current_balance', $amount);
    }
}
