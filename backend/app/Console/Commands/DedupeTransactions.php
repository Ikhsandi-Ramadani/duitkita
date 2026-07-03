<?php

namespace App\Console\Commands;

use App\Models\Transaction;
use App\Services\BalanceService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class DedupeTransactions extends Command
{
    protected $signature = 'transactions:dedupe
        {--window=30 : Max seconds between two creates to treat them as duplicates}
        {--dry-run : Show what would be removed without changing anything}';

    protected $description = 'Find and remove duplicate transactions created within a short window '
        . '(same wallet/type/amount/category/note) — repairs rows from the fixed rapid-retap/'
        . 'retry-without-idempotency bug (e.g. the same Rp1.400.000 "Cicilan" entry created 4 times '
        . 'a few seconds apart). Keeps the earliest of each duplicate group and reverses the '
        . 'balance effect of every one it removes.';

    public function __construct(private readonly BalanceService $balanceService)
    {
        parent::__construct();
    }

    public function handle(): int
    {
        $window = (int) $this->option('window');
        $dryRun = (bool) $this->option('dry-run');

        $groups = Transaction::orderBy('created_at')
            ->get()
            ->groupBy(fn (Transaction $t) => implode('|', [
                $t->household_id,
                $t->wallet_id,
                $t->target_wallet_id,
                $t->type,
                $t->amount,
                $t->category_id,
                $t->note,
            ]));

        $removed = 0;

        foreach ($groups as $txs) {
            if ($txs->count() < 2) {
                continue;
            }

            $sorted = $txs->sortBy('created_at')->values();
            $anchor = $sorted->first();

            for ($i = 1; $i < $sorted->count(); $i++) {
                $current = $sorted[$i];

                if ($current->created_at->diffInSeconds($anchor->created_at) > $window) {
                    // Gap too large — treat as a genuinely separate transaction
                    // and start a new comparison anchor from here.
                    $anchor = $current;
                    continue;
                }

                $this->line(sprintf(
                    'Duplicate: #%d of #%d — wallet %s, %s %s, %s (created %ss apart)',
                    $current->id,
                    $anchor->id,
                    $current->wallet_id,
                    $current->type,
                    number_format($current->amount),
                    $current->note ?? '(no note)',
                    $current->created_at->diffInSeconds($anchor->created_at),
                ));
                $removed++;

                if (!$dryRun) {
                    DB::transaction(function () use ($current) {
                        $this->balanceService->reverse($current);
                        $current->delete();
                    });
                }
            }
        }

        $this->info($dryRun
            ? "Dry run: {$removed} duplicate transaction(s) would be removed."
            : "Done: {$removed} duplicate transaction(s) removed.");

        if ($removed > 0) {
            $this->warn('Run `php artisan wallets:recalculate` afterward to correct any wallet balances.');
        }

        return self::SUCCESS;
    }
}
