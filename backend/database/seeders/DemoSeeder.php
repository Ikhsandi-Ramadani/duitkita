<?php

namespace Database\Seeders;

use App\Models\Budget;
use App\Models\Category;
use App\Models\Household;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DemoSeeder extends Seeder
{
    public function run(): void
    {
        // ── Household ───────────────────────────────────────────────────────
        $household = Household::create([
            'name'        => 'Keluarga Pratama',
            'invite_code' => 'PRT4K9',
            // owner_id set after Budi is created
        ]);

        // ── Users ───────────────────────────────────────────────────────────
        $budi = User::create([
            'name'         => 'Budi',
            'email'        => 'budi@keluarga.id',
            'password'     => Hash::make('password'),
            'household_id' => $household->id,
            'role'         => 'owner',
            'avatar_hue'   => 162,
        ]);

        $sari = User::create([
            'name'         => 'Sari',
            'email'        => 'sari@keluarga.id',
            'password'     => Hash::make('password'),
            'household_id' => $household->id,
            'role'         => 'member',
            'avatar_hue'   => 340,
        ]);

        $rian = User::create([
            'name'         => 'Rian',
            'email'        => 'rian@keluarga.id',
            'password'     => Hash::make('password'),
            'household_id' => $household->id,
            'role'         => 'member',
            'avatar_hue'   => 255,
        ]);

        // Set household owner now that Budi exists
        $household->update(['owner_id' => $budi->id]);

        // ── Wallets ─────────────────────────────────────────────────────────
        $wallets = [
            [
                'name'            => 'BCA Budi',
                'scope'           => 'personal',
                'type'            => 'bank',
                'owner_user_id'   => $budi->id,
                'initial_balance' => 18_450_000,
                'current_balance' => 18_450_000,
            ],
            [
                'name'            => 'Tunai Budi',
                'scope'           => 'personal',
                'type'            => 'cash',
                'owner_user_id'   => $budi->id,
                'initial_balance' => 620_000,
                'current_balance' => 620_000,
            ],
            [
                'name'            => 'GoPay Sari',
                'scope'           => 'personal',
                'type'            => 'ewallet',
                'owner_user_id'   => $sari->id,
                'initial_balance' => 845_000,
                'current_balance' => 845_000,
            ],
            [
                'name'            => 'Tunai Sari',
                'scope'           => 'personal',
                'type'            => 'cash',
                'owner_user_id'   => $sari->id,
                'initial_balance' => 310_000,
                'current_balance' => 310_000,
            ],
            [
                'name'            => 'OVO Rian',
                'scope'           => 'personal',
                'type'            => 'ewallet',
                'owner_user_id'   => $rian->id,
                'initial_balance' => 175_000,
                'current_balance' => 175_000,
            ],
            [
                'name'            => 'Kas Belanja',
                'scope'           => 'shared',
                'type'            => 'cash',
                'owner_user_id'   => null,
                'initial_balance' => 2_380_000,
                'current_balance' => 2_380_000,
            ],
            [
                'name'            => 'Dana Keluarga',
                'scope'           => 'shared',
                'type'            => 'bank',
                'owner_user_id'   => null,
                'initial_balance' => 12_500_000,
                'current_balance' => 12_500_000,
            ],
        ];

        foreach ($wallets as $walletData) {
            Wallet::create(array_merge($walletData, ['household_id' => $household->id]));
        }

        // ── Categories ──────────────────────────────────────────────────────
        $expenseCategories = [
            ['name' => 'Makanan',       'icon' => 'utensils',   'hue' => 24],
            ['name' => 'Transport',     'icon' => 'car',        'hue' => 210],
            ['name' => 'Bensin',        'icon' => 'fuel',       'hue' => 30],
            ['name' => 'Tagihan',       'icon' => 'receipt',    'hue' => 265],
            ['name' => 'Pulsa & Data',  'icon' => 'signal',     'hue' => 190],
            ['name' => 'Belanja',       'icon' => 'bag',        'hue' => 320],
            ['name' => 'Kesehatan',     'icon' => 'health',     'hue' => 0],
            ['name' => 'Pendidikan',    'icon' => 'book',       'hue' => 230],
            ['name' => 'Hiburan',       'icon' => 'film',       'hue' => 290],
            ['name' => 'Arisan',        'icon' => 'users',      'hue' => 130],
            ['name' => 'Zakat & Sedekah', 'icon' => 'handheart', 'hue' => 160],
            ['name' => 'Lainnya',       'icon' => 'dots',       'hue' => 200],
        ];

        $incomeCategories = [
            ['name' => 'Gaji',        'icon' => 'briefcase', 'hue' => 162],
            ['name' => 'Bonus / THR', 'icon' => 'gift',      'hue' => 145],
            ['name' => 'Lainnya',     'icon' => 'dots',      'hue' => 175],
        ];

        $categoryMap = [];

        foreach ($expenseCategories as $cat) {
            $created = Category::create(array_merge($cat, [
                'household_id' => $household->id,
                'type'         => 'expense',
            ]));
            $categoryMap[$cat['name']] = $created;
        }

        foreach ($incomeCategories as $cat) {
            $created = Category::create(array_merge($cat, [
                'household_id' => $household->id,
                'type'         => 'income',
            ]));
            $categoryMap['income_' . $cat['name']] = $created;
        }

        // ── Budgets — June 2026, family scope ───────────────────────────────
        $june2026Budgets = [
            'Makanan'   => 3_500_000,
            'Transport' => 1_200_000,
            'Belanja'   => 2_000_000,
            'Tagihan'   => 1_800_000,
            'Hiburan'   => 800_000,
        ];

        foreach ($june2026Budgets as $categoryName => $amount) {
            Budget::create([
                'household_id'  => $household->id,
                'scope'         => 'family',
                'owner_user_id' => null,
                'category_id'   => $categoryMap[$categoryName]->id,
                'amount'        => $amount,
                'period_month'  => '2026-06',
            ]);
        }
    }
}
