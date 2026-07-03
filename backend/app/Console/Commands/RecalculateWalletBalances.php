<?php

namespace App\Console\Commands;

use App\Models\Transaction;
use App\Models\Wallet;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class RecalculateWalletBalances extends Command
{
    protected $signature = 'wallets:recalculate {--dry-run : Show what would change without saving}';

    protected $description = 'Recompute current_balance for every wallet from initial_balance + transaction history. '
        . 'Fixes wallets corrupted by the sync push sign bug (expense/transfer amounts were pre-signed by the '
        . 'mobile app, so BalanceService::decrement() added instead of subtracting).';

    public function handle(): int
    {
        $dryRun = (bool) $this->option('dry-run');
        $wallets = Wallet::withTrashed()->get();

        $changed = 0;

        foreach ($wallets as $wallet) {
            $balance = $wallet->initial_balance;

            // Deliberately NOT withTrashed() here — soft-deleted transactions
            // must not count toward the balance. (withTrashed() is only used
            // above for the wallet itself, to also repair deleted wallets.)
            $balance += Transaction::where('wallet_id', $wallet->id)
                ->where('type', 'income')
                ->sum(DB::raw('ABS(amount)'));

            $balance -= Transaction::where('wallet_id', $wallet->id)
                ->where('type', 'expense')
                ->sum(DB::raw('ABS(amount)'));

            $balance -= Transaction::where('wallet_id', $wallet->id)
                ->where('type', 'transfer')
                ->sum(DB::raw('ABS(amount)'));

            $balance += Transaction::where('target_wallet_id', $wallet->id)
                ->where('type', 'transfer')
                ->sum(DB::raw('ABS(amount)'));

            // Adjustment amount is a genuine signed delta — sum as-is.
            $balance += (int) Transaction::where('wallet_id', $wallet->id)
                ->where('type', 'adjustment')
                ->sum('amount');

            if ($balance !== $wallet->current_balance) {
                $this->line("Wallet #{$wallet->id} ({$wallet->name}): {$wallet->current_balance} -> {$balance}");
                $changed++;

                if (!$dryRun) {
                    $wallet->update(['current_balance' => $balance]);
                }
            }
        }

        $this->info($dryRun
            ? "Dry run: {$changed} wallet(s) would change."
            : "Done: {$changed} wallet(s) corrected.");

        return self::SUCCESS;
    }
}
