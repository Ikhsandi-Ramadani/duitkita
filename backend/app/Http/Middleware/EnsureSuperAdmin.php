<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureSuperAdmin
{
    public function handle(Request $request, Closure $next): Response
    {
        if (! auth()->check() || ! auth()->user()->is_super_admin) {
            return redirect()->route('admin.login')
                ->with('error', 'Akses ditolak.');
        }

        return $next($request);
    }
}
