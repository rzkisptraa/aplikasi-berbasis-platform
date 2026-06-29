<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SuperAdminMiddleware
{
    public function handle(
        Request $request,
        Closure $next
    ): Response {

        if (
            auth()->user()->role_id !== 1
        ) {
            abort(403);
        }

        return $next($request);
    }
}