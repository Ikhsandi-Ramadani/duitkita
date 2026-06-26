<?php

namespace App\Filament\Widgets;

use App\Models\Household;
use App\Models\Transaction;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Carbon;

class StatsOverviewWidget extends BaseWidget
{
    protected int | string | array $columnSpan = 'full';

    protected function getStats(): array
    {
        $currentMonth = now()->startOfMonth();
        $usersThisMonth = User::where('created_at', '>=', $currentMonth)->count();

        return [
            Stat::make('Total Users', number_format(User::count(), 0, ',', '.'))
                ->description('All registered users')
                ->icon('heroicon-o-user-group'),
            Stat::make('Total Households', number_format(Household::count(), 0, ',', '.'))
                ->description('All households')
                ->icon('heroicon-o-home-modern'),
            Stat::make('Total Transactions', number_format(Transaction::count(), 0, ',', '.'))
                ->description('All time')
                ->icon('heroicon-o-currency-dollar'),
            Stat::make('Total Amount', 'Rp ' . number_format(Transaction::sum('amount'), 0, ',', '.'))
                ->description('All time')
                ->icon('heroicon-o-credit-card'),
            Stat::make('New Users This Month', number_format($usersThisMonth, 0, ',', '.'))
                ->description('Since ' . $currentMonth->format('M Y'))
                ->icon('heroicon-o-plus-circle'),
        ];
    }
}
