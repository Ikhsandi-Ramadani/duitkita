<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\StreamedResponse;

class DownloadController extends Controller
{
    /**
     * Streams the latest APK release from storage/app/releases/.
     * Public (no auth) so the app update flow can fetch it without a token.
     *
     * Looks for, in order:
     *   1. storage/app/releases/duitkita-{app_version}.apk
     *   2. storage/app/releases/duitkita-latest.apk
     */
    public function apk(Request $request): StreamedResponse|JsonResponse
    {
        $version = AppSetting::get('app_version', '1.0.0');
        $build = AppSetting::get('app_build', '1');

        $candidates = [
            storage_path("app/releases/duitkita-{$version}.apk"),
            storage_path("app/releases/duitkita-latest.apk"),
        ];

        $path = null;
        foreach ($candidates as $candidate) {
            if (is_file($candidate)) {
                $path = $candidate;
                break;
            }
        }

        if ($path === null) {
            return response()->json([
                'message' => 'APK release not found. Upload to storage/app/releases/.',
                'expected_version' => $version,
                'expected_build' => (int) $build,
            ], 404);
        }

        $filename = "duitkita-{$version}+{$build}.apk";

        return response()->download($path, $filename, [
            'Content-Type' => 'application/vnd.android.package-archive',
            'Content-Length' => (string) filesize($path),
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
            'X-App-Version' => $version,
            'X-App-Build' => (string) $build,
        ]);
    }
}
