<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Role;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class SuperAdminController extends Controller
{
    /*LIST ADMINS*/
    public function index()
    {
        $admins =
User::with('role')
    ->whereHas('role', function ($query) {
        $query->where('slug', 'admin');
    })
                ->latest()
                ->get();

        return response()->json([

            'message' =>
                'Admins fetched successfully',

            'data' =>
                $admins
        ]);
    }

    /*CREATE ADMIN*/
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
            ]);

        $admin =
            User::create([

'role_id' => Role::where(
    'slug',
    'admin'
)->value('id'),

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
            ]);

        return response()->json([

            'message' =>
                'Admin created successfully',

            'data' =>
                $admin
        ], 201);
    }

    /*ACTIVATE ADMIN*/
    public function activate(
        string $id
    ) {

        $admin =
            User::whereHas('role', function ($query) {
                $query->where('slug', 'admin');
            })
                ->where('id', $id)->first();

        if (!$admin) {

            return response()->json([
                'message' =>
                    'Admin not found'
            ], 404);
        }

        if (
            $admin->is_active
        ) {

            return response()->json([
                'message' =>
                    'Admin already active'
            ], 422);
        }

        $admin->update([
            'is_active' =>
                true
        ]);

        return response()->json([

            'message' =>
                'Admin activated successfully',

            'data' =>
                $admin
        ]);
    }

    /*DEACTIVATE ADMIN*/
    public function deactivate(
        Request $request,
        string $id
    ) {

        $admin =
            User::whereHas('role', function ($query) {
                $query->where('slug', 'admin');
            })
                ->where('id', $id)->first();

        if (!$admin) {

            return response()->json([
                'message' =>
                    'Admin not found'
            ], 404);
        }

        //prevent self deactivate
        if (
            $request
                ->user()
                ->id
            ===
            $admin->id
        ) {

            return response()->json([
                'message' =>
                    'You cannot deactivate yourself'
            ], 422);
        }

        if (
            !$admin->is_active
        ) {

            return response()->json([
                'message' =>
                    'Admin already inactive'
            ], 422);
        }

        $admin->update([
            'is_active' =>
                false
        ]);

        return response()->json([

            'message' =>
                'Admin deactivated successfully',

            'data' =>
                $admin
        ]);
    }

    /*FIRE ADMIN*/
    public function fire(
        Request $request,
        string $id
    ) {

        $admin =
            User::whereHas('role', function ($query) {
                $query->where('slug', 'admin');
            })
                ->where('id', $id)->first();

        if (!$admin) {

            return response()->json([
                'message' =>
                    'Admin not found'
            ], 404);
        }

        //prevent self delete
        if (
            $request
                ->user()
                ->id
            ===
            $admin->id
        ) {

            return response()->json([
                'message' =>
                    'You cannot fire yourself'
            ], 422);
        }

        $admin->delete();

        return response()->json([

            'message' =>
                'Admin fired successfully',

            'data' =>
                null
        ]);
    }
}