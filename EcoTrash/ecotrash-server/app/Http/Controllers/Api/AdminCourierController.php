<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Wallet;
use App\Models\CourierProfile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AdminCourierController
    extends Controller
{
    /*LIST COURIERS*/
    public function index()
    {
        $couriers =
            User::with([
                'courierProfile'
            ])
            ->where(
                'role_id',
                4
            )
            ->latest()
            ->get();

        return response()->json([

            'message' =>
                'Couriers fetched successfully',

            'data' =>
                $couriers
        ]);
    }

    /*CREATE COURIER*/
    public function store(
        Request $request
    ) {

        $validated =
            $request->validate([

                'name' =>
                    'required|string|max:100',

                'email' =>
                    'required|email|unique:users,email',

                'phone' =>
                    'required|string|unique:users,phone',

                'password' =>
                    'required|string|min:8',

                'vehicle_type' =>
                    'required|string|max:50',

                'vehicle_plate' =>
                    'required|string|max:50',

                'ktp_number' =>
                    'required|string|max:50',

                'sim_number' =>
                    'required|string|max:50',

                'ktp_photo' =>
                    'required|image|mimes:jpg,jpeg,png|max:2048',

                'sim_photo' =>
                    'required|image|mimes:jpg,jpeg,png|max:2048',

                'face_photo' =>
                    'required|image|mimes:jpg,jpeg,png|max:2048',

                'address' =>
                    'required|string|max:255',

                'city' =>
                    'required|string|max:100',

                'province' =>
                    'required|string|max:100',
            ]);

        /*UPLOAD PHOTOS*/
        $ktpPhotoPath = $request
            ->file('ktp_photo')
            ->store('couriers/ktp', 'public');

        $simPhotoPath = $request
            ->file('sim_photo')
            ->store('couriers/sim', 'public');

        $facePhotoPath = $request
            ->file('face_photo')
            ->store('couriers/selfie', 'public');

        /*CREATE USER*/
        $courier =
            User::create([

                'role_id' =>
                    4,

                'name' =>
                    $validated[
                        'name'
                    ],

                'email' =>
                    $validated[
                        'email'
                    ],

                'phone' =>
                    $validated[
                        'phone'
                    ],

                'password' =>
                    Hash::make(
                        $validated[
                            'password'
                        ]
                    ),

                'is_active' =>
                    true,

                'is_online' =>
                    false,
            ]);

        /*CREATE COURIER PROFILE*/
        CourierProfile::create([

            'user_id' =>
                $courier->id,

            'vehicle_type' =>
                $validated[
                    'vehicle_type'
                ],

            'vehicle_plate' =>
                $validated[
                    'vehicle_plate'
                ],

            'ktp_number' =>
                $validated[
                    'ktp_number'
                ],

            'ktp_photo' =>
                $ktpPhotoPath,

            'sim_number' =>
                $validated[
                    'sim_number'
                ],

            'sim_photo' =>
                $simPhotoPath,

            'face_photo' =>
                $facePhotoPath,

            'address' =>
                $validated[
                    'address'
                ],

            'city' =>
                $validated[
                    'city'
                ],

            'province' =>
                $validated[
                    'province'
                ],

            'is_verified' =>
                true,
        ]);

        /*CREATE WALLET*/
        Wallet::create([
            'user_id' =>
                $courier->id,

            'balance' =>
                0
        ]);

        return response()->json([

            'message' =>
                'Courier created successfully',

            'data' =>
                $courier->load(
                    'courierProfile'
                )
        ], 201);
    }

    /*ACTIVATE COURIER*/
    public function activate(
        string $id
    ) {

        $courier =
            User::where(
                'role_id',
                4
            )
            ->findOrFail(
                $id
            );

        $courier->update([
            'is_active' =>
                true
        ]);

        return response()->json([

            'message' =>
                'Courier activated successfully',

            'data' =>
                $courier
        ]);
    }

    /*DEACTIVATE COURIER*/
    public function deactivate(
        string $id
    ) {

        $courier =
            User::where(
                'role_id',
                4
            )
            ->findOrFail(
                $id
            );

        $courier->update([
            'is_active' =>
                false
        ]);

        return response()->json([

            'message' =>
                'Courier deactivated successfully',

            'data' =>
                $courier
        ]);
    }
}