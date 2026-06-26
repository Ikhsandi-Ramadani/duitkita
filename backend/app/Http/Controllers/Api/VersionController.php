<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

class VersionController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'version' => '1.0.0',      // bump this when releasing new APK
            'build'   => 1,            // int, increment each release
            'url'     => 'https://github.com/Ikhsandi-Ramadani/duitkita/releases/latest/download/app-arm64-v8a-release.apk',
            'notes'   => 'Versi terbaru DuitKita',
            'force'   => false,        // true = user cannot dismiss
        ]);
    }
}
