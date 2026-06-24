<?php

namespace App\Services;

use App\Models\Notification;

class NotificationService
{
    public static function create(
        int $householdId,
        string $type,
        string $title,
        string $body,
        array $data = [],
        ?int $userId = null,
    ): void {
        Notification::create([
            'household_id' => $householdId,
            'user_id'      => $userId,
            'type'         => $type,
            'title'        => $title,
            'body'         => $body,
            'data'         => $data ?: null,
        ]);
    }
}
