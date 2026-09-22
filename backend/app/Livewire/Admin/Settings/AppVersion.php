<?php

namespace App\Livewire\Admin\Settings;

use App\Models\AppSetting;
use Illuminate\Contracts\View\View;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('layouts.admin')]
class AppVersion extends Component
{
    public string $app_version = '';

    public int $app_build = 1;

    public string $app_download_url = '';

    public string $app_release_notes = '';

    public bool $app_force_update = false;

    public function mount(): void
    {
        $this->app_version = (string) AppSetting::get('app_version', '1.0.0');
        $this->app_build = (int) AppSetting::get('app_build', 1);
        $this->app_download_url = (string) AppSetting::get('app_download_url', '');
        $this->app_release_notes = (string) AppSetting::get('app_release_notes', '');
        $this->app_force_update = AppSetting::get('app_force_update', 'false') === 'true';
    }

    public function save(): void
    {
        $data = $this->validate([
            'app_version' => ['required', 'string', 'max:20'],
            'app_build' => ['required', 'integer', 'min:1'],
            'app_download_url' => ['required', 'url', 'max:500'],
            'app_release_notes' => ['required', 'string', 'max:1000'],
            'app_force_update' => ['boolean'],
        ]);

        AppSetting::set('app_version', $data['app_version']);
        AppSetting::set('app_build', (string) $data['app_build']);
        AppSetting::set('app_download_url', $data['app_download_url']);
        AppSetting::set('app_release_notes', $data['app_release_notes']);
        AppSetting::set('app_force_update', $data['app_force_update'] ? 'true' : 'false');

        session()->flash('success', 'Pengaturan versi aplikasi berhasil disimpan.');
    }

    public function render(): View
    {
        return view('livewire.admin.settings.app-version')->title('Versi aplikasi');
    }
}
