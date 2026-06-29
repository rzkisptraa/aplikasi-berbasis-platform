<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\CourierProfile;
use Illuminate\Http\Request;
use App\Models\Role;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class CourierWebController extends Controller
{
    public function index(Request $request)
    {
        $search = $request->search;
        $status = $request->status;

        $couriers = User::with([
            'courierProfile',
            'role'
        ])
            ->whereHas('role', function ($query) {
                $query->where('slug', 'courier');
            })
            ->when($search, function ($query) use ($search) {
                $query->where(function ($q) use ($search) {
                    $q->where(
                        'name',
                        'like',
                        "%{$search}%"
                    )
                        ->orWhere(
                            'email',
                            'like',
                            "%{$search}%"
                        );
                });
            })
            ->when(
                $status !== null
                && $status !== '',
                function ($query) use ($status) {
                    $query->where(
                        'is_active',
                        $status
                    );
                }
            )
            ->latest()
            ->paginate(10);

        /*Stats*/

        $totalCourier = User::whereHas(
            'role',
            function ($query) {
                $query->where(
                    'slug',
                    'courier'
                );
            }
        )->count();

        $activeCourier = User::whereHas(
            'role',
            function ($query) {
                $query->where(
                    'slug',
                    'courier'
                );
            }
        )
            ->where('is_active', true)
            ->count();

        $onlineCourier = User::whereHas(
            'role',
            function ($query) {
                $query->where(
                    'slug',
                    'courier'
                );
            }
        )
            ->where('is_online', true)
            ->count();

        $offlineCourier = User::whereHas(
            'role',
            function ($query) {
                $query->where(
                    'slug',
                    'courier'
                );
            }
        )
            ->where('is_online', false)
            ->count();

        return view(
            'couriers.index',
            compact(
                'couriers',
                'totalCourier',
                'activeCourier',
                'onlineCourier',
                'offlineCourier'
            )
        );
    }

    public function create()
    {
        return view('couriers.create');
    }

public function store(Request $request)
{
    $request->validate([
        'name' => 'required|string|max:255',
        'email' => 'required|email|unique:users,email',
        'password' => 'required|min:6',
        'phone' => 'required|string|max:20',

        'vehicle_type' => 'required|string|max:255',
        'vehicle_plate' => 'required|string|max:255',

        'ktp_number' => 'required|string|max:255',
        'sim_number' => 'required|string|max:255',

        'ktp_photo' => 'required|image|mimes:jpg,jpeg,png|max:2048',
        'sim_photo' => 'required|image|mimes:jpg,jpeg,png|max:2048',
        'face_photo' => 'required|image|mimes:jpg,jpeg,png|max:2048',

        'address' => 'required|string',
        'city' => 'required|string|max:255',
        'province' => 'required|string|max:255',
    ]);

    /*Upload Photos*/

    $ktpPhoto = $request
        ->file('ktp_photo')
        ->store('couriers/ktp', 'public');

    $simPhoto = $request
        ->file('sim_photo')
        ->store('couriers/sim', 'public');

    $facePhoto = $request
        ->file('face_photo')
        ->store('couriers/selfie', 'public');

    /*Get Courier Role*/

    $courierRole = Role::where(
        'slug',
        'courier'
    )->first();

    /*Create User*/

    $user = User::create([
        'role_id' => $courierRole->id,
        'name' => $request->name,
        'email' => $request->email,
        'password' => bcrypt($request->password),
        'phone' => $request->phone,
        'is_active' => true,
        'is_online' => false,
    ]);

    /*Create Courier Profile*/

    CourierProfile::create([
        'user_id' => $user->id,

        'vehicle_type' => $request->vehicle_type,
        'vehicle_plate' => $request->vehicle_plate,

        'ktp_number' => $request->ktp_number,
        'ktp_photo' => $ktpPhoto,

        'sim_number' => $request->sim_number,
        'sim_photo' => $simPhoto,

        'face_photo' => $facePhoto,

        'address' => $request->address,
        'city' => $request->city,
        'province' => $request->province,

        'rating' => 0,
        'is_verified' => false,
        'current_latitude' => null,
        'current_longitude' => null,
    ]);

    return redirect()
        ->route('couriers.index')
        ->with(
            'success',
            'Courier berhasil ditambahkan.'
        );
}

    public function show($id)
    {
        $courier = User::with([
            'courierProfile',
            'role',
            'reviewsReceived.seller'
        ])
            ->whereHas('role', function ($query) {
                $query->where('slug', 'courier');
            })
            ->findOrFail($id);

        return view(
            'couriers.show',
            compact('courier')
        );
    }

    public function edit($id)
    {
        $courier = User::with([
            'courierProfile',
            'role'
        ])
            ->whereHas('role', function ($query) {
                $query->where('slug', 'courier');
            })
            ->findOrFail($id);

        return view('couriers.edit', compact('courier'));
    }

    public function update(Request $request, $id)
    {
        $user = User::with('courierProfile')->findOrFail($id);

        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,' . $user->id,
            'password' => 'nullable|min:6',
            'phone' => 'required|string|max:20',

            'vehicle_type' => 'required|string|max:255',
            'vehicle_plate' => 'required|string|max:255',

            'ktp_number' => 'required|string|max:255',
            'sim_number' => 'required|string|max:255',

            'ktp_photo' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
            'sim_photo' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
            'face_photo' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',

            'address' => 'required|string',
            'city' => 'required|string|max:255',
            'province' => 'required|string|max:255',
        ]);

        $userData = [
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
        ];

        if ($request->filled('password')) {
            $userData['password'] = Hash::make($request->password);
        }

        $user->update($userData);

        $profileData = [
            'vehicle_type' => $request->vehicle_type,
            'vehicle_plate' => $request->vehicle_plate,
            'ktp_number' => $request->ktp_number,
            'sim_number' => $request->sim_number,
            'address' => $request->address,
            'city' => $request->city,
            'province' => $request->province,
        ];

        if ($request->hasFile('ktp_photo')) {
            $profileData['ktp_photo'] = $request->file('ktp_photo')->store('couriers/ktp', 'public');
        }

        if ($request->hasFile('sim_photo')) {
            $profileData['sim_photo'] = $request->file('sim_photo')->store('couriers/sim', 'public');
        }

        if ($request->hasFile('face_photo')) {
            $profileData['face_photo'] = $request->file('face_photo')->store('couriers/selfie', 'public');
        }

        $user->courierProfile()->update($profileData);

        return redirect()
            ->route('couriers.show', $user->id)
            ->with('success', 'Profil kurir berhasil diperbarui.');
    }

    public function toggleStatus($id)
    {
        $courier = User::findOrFail($id);

        $courier->update([
            'is_active' => !$courier->is_active
        ]);

        return back()->with(
            'success',
            'Status courier berhasil diperbarui.'
        );
    }

    public function fire($id)
    {
        $user = User::findOrFail($id);

        $user->delete();

        return redirect()
            ->route('couriers.index')
            ->with(
                'success',
                'Courier berhasil diberhentikan.'
            );
    }
}