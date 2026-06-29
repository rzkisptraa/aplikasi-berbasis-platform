<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CourierProfile;
use Illuminate\Http\Request;

class CourierLocationController extends Controller
{
    public function update(
        Request $request
    ) {

        $user =
            $request->user();

        // ONLY COURIER
        if (
            $user->role_id != 4
        ) {

            return response()->json([
                'message' =>
                    'Only courier allowed'
            ], 403);
        }

        $validated =
            $request->validate([

                'latitude' =>
                    'required|numeric|between:-90,90',

                'longitude' =>
                    'required|numeric|between:-180,180',
            ]);

        $profile =
            CourierProfile::where(
                'user_id',
                $user->id
            )
                ->firstOrFail();

        $profile->update([

            'current_latitude' =>
                $validated[
                    'latitude'
                ],

            'current_longitude' =>
                $validated[
                    'longitude'
                ],
        ]);

        return response()->json([

            'message' =>
                'Location updated successfully',

            'data' => [
                'latitude' =>
                    $profile
                        ->current_latitude,

                'longitude' =>
                    $profile
                        ->current_longitude,
            ]
        ]);
    }

    public function toggleOnline(
        Request $request
    ) {
        $user =
            $request->user();

        // COURIER ONLY
        if (
            $user->role_id != 4
        ) {

            return response()->json([
                'message' =>
                    'Only courier allowed'
            ], 403);
        }

        // ACTIVE CHECK
        if (
            !$user->is_active
        ) {

            return response()->json([
                'message' =>
                    'Courier inactive'
            ], 422);
        }

        $user->update([
            'is_online' =>
                !$user
                    ->is_online
        ]);

        return response()->json([

            'message' =>
                $user->is_online
                ? 'Courier online'
                : 'Courier offline',

            'data' => [
                'is_online' =>
                    $user
                        ->fresh()
                        ->is_online
            ]
        ]);
    }

}