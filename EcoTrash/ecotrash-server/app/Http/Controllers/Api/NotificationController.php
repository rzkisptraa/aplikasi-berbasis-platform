<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /*GET MY NOTIFICATIONS*/
    public function index(Request $request)
    {
        try {

            $notifications = Notification::where(
                'user_id',
                $request->user()->id
            )
                ->latest()
                ->get();

            return response()->json([
                'message' =>
                    'Notifications fetched successfully',

                'data' =>
                    $notifications
            ]);

        } catch (\Exception $e) {

            return response()->json([
                'message' =>
                    'Failed to fetch notifications',

                'error' =>
                    $e->getMessage()
            ], 500);
        }
    }

    /*MARK AS READ*/
    public function markAsRead(
        Request $request,
        string $id
    ) {
        try {

            $notification =
                Notification::where(
                    'user_id',
                    $request->user()->id
                )->find($id);

            if (!$notification) {

                return response()->json([
                    'message' =>
                        'Notification not found'
                ], 404);
            }

            $notification->update([

                'is_read' =>
                    true,

                'read_at' =>
                    now(),
            ]);

            return response()->json([
                'message' =>
                    'Notification marked as read',

                'data' =>
                    $notification
            ]);

        } catch (\Exception $e) {

            return response()->json([
                'message' =>
                    'Failed to mark notification',

                'error' =>
                    $e->getMessage()
            ], 500);
        }
    }

    public function markAllAsRead(
        Request $request
    ) {
        Notification::where(
            'user_id',
            $request->user()->id
        )
            ->where(
                'is_read',
                false
            )
            ->update([

                'is_read' =>
                    true,

                'read_at' =>
                    now(),
            ]);

        return response()->json([

            'message' =>
                'All notifications marked as read',

            'data' => null
        ]);
    }

    public function unreadCount(
        Request $request
    ) {
        $count =
            Notification::where(
                'user_id',
                $request->user()->id
            )
                ->where(
                    'is_read',
                    false
                )
                ->count();

        return response()->json([

            'message' =>
                'Unread notification count fetched successfully',

            'data' => [

                'unread_count' =>
                    $count
            ]
        ]);
    }
}