<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class WebAuthController extends Controller
{
    public function loginPage()
    {
        return view(
            'auth.login'
        );
    }

    public function login(
        Request $request
    ) {

        $credentials =
            $request->validate([
                'email' => 'required|email',
                'password' => 'required',
            ]);

        /* Login Attempt */

        if (
            !Auth::attempt(
                $credentials
            )
        ) {

            return back()
                ->withErrors([
                    'email' =>
                        'Email atau password salah.'
                ]);
        }

        $user = Auth::user();

        /* Cek akun aktif */

        if (
            !$user->is_active
        ) {

            Auth::logout();

            return back()
                ->withErrors([
                    'email' =>
                        'Akun Anda telah dinonaktifkan.'
                ]);
        }

        /* Cek apakah user adalah admin atau superadmin */
        if (!in_array($user->role_id, [1, 2])) {
            Auth::logout();

            return back()
                ->withErrors([
                    'email' => 'Hanya akun Admin atau Super Admin yang diizinkan masuk ke panel ini.'
                ]);
        }

        /* Update Online Status */

        $user->update([
            'is_online' => true
        ]);

        $request
            ->session()
            ->regenerate();

        return redirect()
            ->route(
                'dashboard'
            );
    }

    public function logout(Request $request)
    {
        if (Auth::check()) {

            Auth::user()->update([
                'is_online' => false
            ]);
        }

        Auth::logout();

        $request
            ->session()
            ->invalidate();

        $request
            ->session()
            ->regenerateToken();

        return redirect('/login');
    }
}