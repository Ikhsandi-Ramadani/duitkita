<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class SuperAdminSeeder extends Seeder
{
    public function run(): void
    {
        User::updateOrCreate(
            ['email' => 'admin@duitkita.com'],
            [
                'name'           => 'Super Admin',
                'password'       => bcrypt('admin123'),
                'is_super_admin' => true,
                'household_id'   => null,
                'role'           => 'member',
            ]
        );
    }
}
