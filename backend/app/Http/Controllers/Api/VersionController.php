<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use Illuminate\Http\JsonResponse;

class VersionController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'version' => AppSetting::get('app_version', '1.0.0'),
            'build'   => (int) AppSetting::get('app_build', 1),
            'url'     => AppSetting::get('app_download_url', ''),
            'notes'   => AppSetting::get('app_release_notes', ''),
            'force'   => AppSetting::get('app_force_update', 'false') === 'true',
        ]);
    }
}
