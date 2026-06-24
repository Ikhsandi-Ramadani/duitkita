<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user        = $request->user();
        $householdId = $user->household_id;

        $notifications = Notification::where('household_id', $householdId)
            ->latest()
            ->take(50)
            ->get();

        $unreadCount = Notification::where('household_id', $householdId)
            ->whereNull('read_at')
            ->where(function ($q) use ($user) {
                $q->whereNull('user_id')->orWhere('user_id', $user->id);
            })
            ->count();

        return response()->json([
            'notifications' => $notifications,
            'unread_count'  => $unreadCount,
        ]);
    }

    public function markRead(Request $request, int $id): JsonResponse
    {
        $user = $request->user();

        $notification = Notification::where('id', $id)
            ->where('household_id', $user->household_id)
            ->firstOrFail();

        if (is_null($notification->read_at)) {
            $notification->update(['read_at' => now()]);
        }

        return response()->json($notification->fresh());
    }

    public function markAllRead(Request $request): JsonResponse
    {
        $user        = $request->user();
        $householdId = $user->household_id;

        $updated = Notification::where('household_id', $householdId)
            ->whereNull('read_at')
            ->where(function ($q) use ($user) {
                $q->whereNull('user_id')->orWhere('user_id', $user->id);
            })
            ->update(['read_at' => now()]);

        return response()->json(['marked_read' => $updated]);
    }
}
