<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    public function monthly(Request $request): JsonResponse
    {
        $request->validate([
            'month' => ['required', 'string', 'regex:/^\d{4}-\d{2}$/'],
        ]);

        $householdId = $request->user()->household_id;
        $month       = $request->input('month');
        $start       = Carbon::parse($month . '-01')->startOfDay();
        $end         = $start->copy()->endOfMonth()->endOfDay();

        // Base query for the month (exclude transfers and adjustments)
        $base = Transaction::where('household_id', $householdId)
            ->whereBetween('date', [$start, $end])
            ->whereIn('type', ['income', 'expense']);

        $totalIncome  = (clone $base)->where('type', 'income')->sum('amount');
        $totalExpense = (clone $base)->where('type', 'expense')->sum('amount');

        // Per-category expense breakdown
        $categoryBreakdown = (clone $base)
            ->where('type', 'expense')
            ->whereNotNull('category_id')
            ->select('category_id', DB::raw('SUM(amount) as total'))
            ->groupBy('category_id')
            ->with('category')
            ->get()
            ->map(fn($row) => [
                'category_id'   => $row->category_id,
                'category_name' => $row->category?->name,
                'total'         => $row->total,
            ]);

        // Per-member expense (prefer spent_by, fallback recorded_by)
        $memberExpense = Transaction::where('household_id', $householdId)
            ->whereBetween('date', [$start, $end])
            ->where('type', 'expense')
            ->select(
                DB::raw('COALESCE(spent_by, recorded_by) as user_id'),
                DB::raw('SUM(amount) as total')
            )
            ->groupBy(DB::raw('COALESCE(spent_by, recorded_by)'))
            ->get()
            ->map(fn($row) => [
                'user_id' => $row->user_id,
                'total'   => $row->total,
            ]);

        // 6-month cashflow series (ending at the requested month)
        $cashflow = [];
        for ($i = 5; $i >= 0; $i--) {
            $mStart = $start->copy()->subMonths($i)->startOfMonth();
            $mEnd   = $mStart->copy()->endOfMonth()->endOfDay();
            $label  = $mStart->format('Y-m');

            $inc = Transaction::where('household_id', $householdId)
                ->whereBetween('date', [$mStart, $mEnd])
                ->where('type', 'income')
                ->sum('amount');

            $exp = Transaction::where('household_id', $householdId)
                ->whereBetween('date', [$mStart, $mEnd])
                ->where('type', 'expense')
                ->sum('amount');

            $cashflow[] = [
                'month'   => $label,
                'income'  => (int) $inc,
                'expense' => (int) $exp,
            ];
        }

        return response()->json([
            'month'              => $month,
            'total_income'       => (int) $totalIncome,
            'total_expense'      => (int) $totalExpense,
            'net'                => (int) ($totalIncome - $totalExpense),
            'category_breakdown' => $categoryBreakdown,
            'member_expense'     => $memberExpense,
            'cashflow_series'    => $cashflow,
        ]);
    }
}
