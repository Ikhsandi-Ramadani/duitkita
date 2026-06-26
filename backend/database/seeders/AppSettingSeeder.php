<?php

namespace Database\Seeders;

use App\Models\AppSetting;
use Illuminate\Database\Seeder;

class AppSettingSeeder extends Seeder
{
    public function run(): void
    {
        $defaults = [
            'app_version'      => '1.0.1',
            'app_build'        => '2',
            'app_download_url' => 'https://github.com/Ikhsandi-Ramadani/duitkita/releases/latest/download/app-arm64-v8a-release.apk',
            'app_release_notes' => 'Versi terbaru DuitKita',
            'app_force_update' => 'false',
        ];

        foreach ($defaults as $key => $value) {
            AppSetting::set($key, $value);
        }
    }
}
