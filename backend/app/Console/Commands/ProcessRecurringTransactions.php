<?php

namespace App\Console\Commands;

use App\Models\Recurring;
use App\Models\Transaction;
use App\Services\BalanceService;
use Illuminate\Console\Command;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Throwable;

class ProcessRecurringTransactions extends Command
{
    protected $signature = 'recurring:process';

    protected $description = 'Auto-create transactions for all due recurring entries where auto_create = true';

    public function __construct(private readonly BalanceService $balanceService)
    {
        parent::__construct();
    }

    public function handle(): int
    {
        $due = Recurring::where('auto_create', true)
            ->whereDate('next_run_date', '<=', Carbon::today())
            ->get();

        $processed = 0;
        $skipped   = 0;

        foreach ($due as $recurring) {
            try {
                DB::transaction(function () use ($recurring): void {
                    $transaction = Transaction::create([
                        'client_id'    => (string) Str::uuid(),
                        'household_id' => $recurring->household_id,
                        'type'         => $recurring->type,
                        'wallet_id'    => $recurring->wallet_id,
                        'category_id'  => $recurring->category_id,
                        'amount'       => $recurring->amount,
                        'date'         => now(),
                        'note'         => $recurring->note ?? 'Recurring: ' . $recurring->id,
                        'recorded_by'  => $recurring->created_by,
                    ]);

                    $this->balanceService->apply($transaction);

                    $next = $this->advanceDate(Carbon::parse($recurring->next_run_date), $recurring->freq);
                    $recurring->update(['next_run_date' => $next]);
                });

                $processed++;
            } catch (Throwable $e) {
                $skipped++;
                Log::error('ProcessRecurringTransactions: failed to process recurring', [
                    'recurring_id' => $recurring->id,
                    'household_id' => $recurring->household_id,
                    'error'        => $e->getMessage(),
                    'trace'        => $e->getTraceAsString(),
                ]);
            }
        }

        $this->info("Processed {$processed} recurring(s), skipped {$skipped}.");
        Log::info("ProcessRecurringTransactions: processed={$processed} skipped={$skipped}");

        return self::SUCCESS;
    }

    private function advanceDate(Carbon $date, string $freq): Carbon
    {
        return match ($freq) {
            'daily'   => $date->addDay(),
            'weekly'  => $date->addWeek(),
            'monthly' => $date->addMonth(),
            'yearly'  => $date->addYear(),
            default   => $date->addMonth(),
        };
    }
}
