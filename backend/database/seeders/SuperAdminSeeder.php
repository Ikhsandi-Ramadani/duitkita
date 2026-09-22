<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use RuntimeException;

class SuperAdminSeeder extends Seeder
{
    public function run(): void
    {
        $email = (string) env('ADMIN_EMAIL', 'admin@duitkita.com');
        $password = (string) env('ADMIN_PASSWORD', '');

        // Pengaman: di production, sandi tidak boleh kosong atau lemah.
        // Tanpa ini, seeder akan membuat akun super admin dengan sandi
        // bawaan "admin123" yang bisa ditebak siapa pun.
        if (app()->isProduction() && strlen($password) < 12) {
            throw new RuntimeException(
                'Set ADMIN_PASSWORD (minimal 12 karakter) di .env sebelum menjalankan seeder ini di production.'
            );
        }

        User::updateOrCreate(
            ['email' => $email],
            [
                'name'           => 'Super Admin',
                'password'       => bcrypt($password !== '' ? $password : 'admin123'),
                'is_super_admin' => true,
                'household_id'   => null,
                'role'           => null,
            ]
        );
    }
}
