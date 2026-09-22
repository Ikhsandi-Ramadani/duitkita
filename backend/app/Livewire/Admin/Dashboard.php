<?php

namespace App\Livewire\Admin;

use App\Models\Household;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('layouts.admin')]
class Dashboard extends Component
{
    public function render()
    {
        $stats = [
            'total_users' => User::count(),
            'total_households' => Household::count(),
            'total_transactions' => Transaction::count(),
            'total_amount' => Transaction::where('type', 'expense')->sum('amount'),
            'new_users_month' => User::whereMonth('created_at', now()->month)
                ->whereYear('created_at', now()->year)
                ->count(),
        ];

        $monthExpression = match (DB::connection()->getDriverName()) {
            'sqlite' => "strftime('%Y-%m', created_at)",
            'pgsql' => "TO_CHAR(created_at, 'YYYY-MM')",
            default => "DATE_FORMAT(created_at, '%Y-%m')",
        };

        $rows = DB::table('transactions')
            ->selectRaw("{$monthExpression} as month, type, SUM(amount) as total")
            ->where('created_at', '>=', now()->subMonths(5)->startOfMonth())
            ->groupBy('month', 'type')
            ->orderBy('month')
            ->get();

        $chart = collect(range(5, 0))->map(function (int $offset) use ($rows): array {
            $month = now()->copy()->subMonths($offset)->format('Y-m');

            return [
                'label' => now()->copy()->subMonths($offset)->translatedFormat('M'),
                'income' => (int) ($rows->first(fn ($row) => $row->month === $month && $row->type === 'income')?->total ?? 0),
                'expense' => (int) ($rows->first(fn ($row) => $row->month === $month && $row->type === 'expense')?->total ?? 0),
            ];
        })->values()->all();

        $maxChartValue = max(1, collect($chart)->max(fn (array $item) => max($item['income'], $item['expense'])));

        return view('livewire.admin.dashboard', [
            'stats' => $stats,
            'chart' => $chart,
            'maxChartValue' => $maxChartValue,
        ])->title('Ringkasan Admin');
    }
}
