<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class AdminWebMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = Auth::user();

        if (!$user || !in_array($user->role_id, [1, 2])) {
            Auth::logout();
            
            return redirect('/login')->withErrors([
                'email' => 'Hanya akun Admin atau Super Admin yang diizinkan mengakses panel ini.'
            ]);
        }

        return $next($request);
    }
}
