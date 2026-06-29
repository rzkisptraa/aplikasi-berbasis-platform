<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Hash;

class ProfileController extends Controller
{
    /*GET PROFILE*/
    public function show(
        Request $request
    ) {
        $user =
            $request->user()
                ->load(
                    'courierProfile',
                    'sellerAddresses'
                );

        return response()->json([

            'message' =>
                'Profile fetched successfully',

            'data' =>
                $user
        ]);
    }

    /*UPDATE PROFILE*/
    public function update(
        Request $request
    ) {
        $user =
            $request->user();

        $validated =
            $request->validate([

                'name' =>
                    'required|string|max:100',

                'email' => [
                    'required',
                    'email',
                    Rule::unique(
                        'users',
                        'email'
                    )->ignore(
                            $user->id
                        ),
                ],

                'phone' => [
                    'required',
                    'string',
                    'max:20',
                    Rule::unique(
                        'users',
                        'phone'
                    )->ignore(
                            $user->id
                        ),
                ],

                'profile_photo' =>
                    'nullable|image|mimes:jpg,jpeg,png|max:5120',

                // courier only
                'vehicle_type' =>
                    'nullable|string|max:100',

                'vehicle_plate' =>
                    'nullable|string|max:50',

                'address' =>
                    'nullable|string',

                'city' =>
                    'nullable|string|max:100',

                'province' =>
                    'nullable|string|max:100',
            ]);

        //PHOTO
        $photoPath =
            $user
                ->profile_photo;

        if (
            $request->hasFile(
                'profile_photo'
            )
        ) {

            $photoPath =
                $request
                    ->file(
                        'profile_photo'
                    )
                    ->store(
                        'profiles',
                        'public'
                    );
        }

        //USER UPDATE
        $user->update([

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

            'profile_photo' =>
                $photoPath,
        ]);

        //COURIER PROFILE
        if (
            $user->role_id == 4
        ) {

            $user
                ->courierProfile()
                ->firstOrCreate([])
                    ?->update([

                    'vehicle_type' =>
                        $validated[
                            'vehicle_type'
                        ] ?? null,

                    'vehicle_plate' =>
                        $validated[
                            'vehicle_plate'
                        ] ?? null,

                    'address' =>
                        $validated[
                            'address'
                        ] ?? null,

                    'city' =>
                        $validated[
                            'city'
                        ] ?? null,

                    'province' =>
                        $validated[
                            'province'
                        ] ?? null,
                ]);
        }

        return response()->json([

            'message' =>
                'Profile updated successfully',

            'data' =>
                $user->fresh()
                    ->load(
                        'courierProfile',
                        'sellerAddresses'
                    )
        ]);
    }

    /*CHANGE PASSWORD*/
    public function changePassword(
        Request $request
    ) {
        $validated =
            $request->validate([

                'current_password' =>
                    'required',

                'new_password' =>
                    'required|min:8|confirmed',
            ]);

        $user =
            $request->user();

        if (
            !Hash::check(
                $validated[
                    'current_password'
                ],
                $user->password
            )
        ) {

            return response()->json([
                'message' =>
                    'Current password is incorrect'
            ], 422);
        }

        $user->update([

            'password' =>
                bcrypt(
                    $validated[
                        'new_password'
                    ]
                )
        ]);

        return response()->json([

            'message' =>
                'Password updated successfully',

            'data' =>
                null
        ]);
    }
}