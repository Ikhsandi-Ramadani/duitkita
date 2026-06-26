<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class AppVersionController extends Controller
{
    public function index(): Response
    {
        return Inertia::render('Admin/Settings/AppVersion', [
            'settings' => [
                'app_version'       => AppSetting::get('app_version', '1.0.0'),
                'app_build'         => AppSetting::get('app_build', '1'),
                'app_download_url'  => AppSetting::get('app_download_url', ''),
                'app_release_notes' => AppSetting::get('app_release_notes', ''),
                'app_force_update'  => AppSetting::get('app_force_update', 'false'),
            ],
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'app_version'       => ['required', 'string', 'max:20'],
            'app_build'         => ['required', 'integer', 'min:1'],
            'app_download_url'  => ['required', 'url', 'max:500'],
            'app_release_notes' => ['required', 'string', 'max:1000'],
            'app_force_update'  => ['sometimes', 'boolean'],
        ]);

        AppSetting::set('app_version', $validated['app_version']);
        AppSetting::set('app_build', (string) $validated['app_build']);
        AppSetting::set('app_download_url', $validated['app_download_url']);
        AppSetting::set('app_release_notes', $validated['app_release_notes']);
        AppSetting::set('app_force_update', ($validated['app_force_update'] ?? false) ? 'true' : 'false');

        return redirect()->route('admin.settings.app-version')
            ->with('success', 'Pengaturan versi aplikasi berhasil disimpan.');
    }
}
