<?php

namespace App\Filament\Widgets;

use Filament\Widgets\ChartWidget;
use Illuminate\Support\Facades\DB;

class TransactionsChartWidget extends ChartWidget
{
    protected ?string $heading = 'Transaksi 6 Bulan Terakhir';

    protected static ?int $sort = 3;

    protected int|string|array $columnSpan = 'full';

    protected function getData(): array
    {
        $rows = DB::table('transactions')
            ->selectRaw('DATE_FORMAT(created_at, "%Y-%m") as month, type, SUM(amount) as total')
            ->where('created_at', '>=', now()->subMonths(6))
            ->whereNull('deleted_at')
            ->groupBy('month', 'type')
            ->orderBy('month')
            ->get();

        // Build sorted list of months
        $months = $rows->pluck('month')->unique()->sort()->values()->toArray();

        $income  = [];
        $expense = [];

        foreach ($months as $month) {
            $incomeRow  = $rows->firstWhere(fn ($r) => $r->month === $month && $r->type === 'income');
            $expenseRow = $rows->firstWhere(fn ($r) => $r->month === $month && $r->type === 'expense');

            $income[]  = $incomeRow  ? (int) $incomeRow->total  : 0;
            $expense[] = $expenseRow ? (int) $expenseRow->total : 0;
        }

        // Format labels as "Jan 2026"
        $labels = array_map(
            fn (string $m) => \Illuminate\Support\Carbon::createFromFormat('Y-m', $m)->format('M Y'),
            $months
        );

        return [
            'datasets' => [
                [
                    'label'           => 'Pemasukan',
                    'data'            => $income,
                    'backgroundColor' => 'rgba(34, 197, 94, 0.7)',
                    'borderColor'     => 'rgba(34, 197, 94, 1)',
                    'borderWidth'     => 1,
                ],
                [
                    'label'           => 'Pengeluaran',
                    'data'            => $expense,
                    'backgroundColor' => 'rgba(239, 68, 68, 0.7)',
                    'borderColor'     => 'rgba(239, 68, 68, 1)',
                    'borderWidth'     => 1,
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'bar';
    }
}
