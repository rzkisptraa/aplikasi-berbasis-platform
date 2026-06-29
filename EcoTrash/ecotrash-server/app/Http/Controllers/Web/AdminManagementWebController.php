<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class AdminManagementWebController extends Controller
{
    public function index(Request $request)
    {
        $search = $request->search;
        $status = $request->status;

        $admins = User::with('role')
            ->whereHas('role', function ($query) {
                $query->where('slug', 'admin');
            })
            ->when($search, function ($query) use ($search) {
                $query->where(function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%");
                });
            })
            ->when($status !== null && $status !== '', function ($query) use ($status) {
                $query->where('is_active', $status);
            })
            ->latest()
            ->paginate(10);

        $totalAdmin = User::whereHas('role', function ($query) {
            $query->where('slug', 'admin');
        })->count();

        $activeAdmin = User::whereHas('role', function ($query) {
            $query->where('slug', 'admin');
        })->where('is_active', true)->count();

        $onlineAdmin = User::whereHas('role', function ($query) {
            $query->where('slug', 'admin');
        })->where('is_online', true)->count();

        $offlineAdmin = User::whereHas('role', function ($query) {
            $query->where('slug', 'admin');
        })->where('is_online', false)->count();

        return view(
            'admin-management.index',
            compact(
                'admins',
                'totalAdmin',
                'activeAdmin',
                'onlineAdmin',
                'offlineAdmin'
            )
        );
    }

    public function create()
    {
        return view('admin-management.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:8',
            'phone' => 'required|string|max:20',
        ]);

        $adminRoleId = \App\Models\Role::where(
            'slug',
            'admin'
        )->value('id');

        User::create([
            'role_id' => $adminRoleId,
            'name' => $request->name,
            'email' => $request->email,
            'password' => bcrypt(
                $request->password
            ),
            'phone' => $request->phone,
            'is_active' => true,
            'is_online' => false,
        ]);

        return redirect()
            ->route(
                'admin-management.index'
            )
            ->with(
                'success',
                'Admin berhasil ditambahkan.'
            );
    }

    public function show($id)
    {
        $admin = User::with('role')
            ->whereHas(
                'role',
                function ($query) {
                    $query->where(
                        'slug',
                        'admin'
                    );
                }
            )
            ->findOrFail($id);

        return view(
            'admin-management.show',
            compact('admin')
        );
    }

    public function fire($id)
    {
        $admin = User::findOrFail($id);

        $admin->delete();

        return redirect()
            ->route(
                'admin-management.index'
            )
            ->with(
                'success',
                'Admin berhasil diberhentikan.'
            );
    }

    public function toggleStatus(User $user)
    {
        $user->update([
            'is_active' => !$user->is_active
        ]);

        return back()->with(
            'success',
            'Status admin berhasil diperbarui.'
        );
    }
}