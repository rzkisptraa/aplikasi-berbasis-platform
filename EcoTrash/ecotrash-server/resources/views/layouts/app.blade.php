<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0">

    <title>EcoTrash Dashboard</title>

    {{-- Google Font --}}
    <link
        href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap"
        rel="stylesheet">

    {{-- Bootstrap 5 --}}
    <link
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css"
        rel="stylesheet">

    {{-- Leaflet --}}
    <link
        rel="stylesheet"
        href="https://unpkg.com/leaflet/dist/leaflet.css" />

    @vite([
        'resources/css/app.css',
        'resources/js/app.js'
    ])
</head>

<body>

    <div class="dashboard-wrapper">

        {{-- Sidebar --}}
        <aside
            id="sidebar"
            class="sidebar">

            <x-sidebar />

        </aside>

        {{-- Main --}}
        <div class="main-wrapper">

            {{-- Header --}}
            <header class="topbar">

                <div class="topbar-left">

                    <button
                        id="toggleSidebar"
                        class="sidebar-toggle">
                        ☰
                    </button>

                    <div>

                        <h1 class="page-title">
                            @yield('page-title', 'Dashboard')
                        </h1>

                        <p class="page-subtitle">
                            EcoTrash Management System
                        </p>

                    </div>

                </div>

                <div class="topbar-right">

                    <div class="date-box">
                        {{ now()->format('d M Y') }}
                    </div>

                    <div class="dropdown">
                        <button class="user-box btn btn-white dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <div>
                                <small class="text-muted d-block">
                                    Masuk Sebagai
                                </small>

                                <strong>
                                    {{ auth()->user()->name }}
                                </strong>
                            </div>
                        </button>

                        <ul class="dropdown-menu dropdown-menu-end" style="min-width: 250px;">
                            <li>
                                <h6 class="dropdown-header">
                                    Informasi Admin
                                </h6>
                            </li>
                            <li>
                                <div class="px-3 py-2">
                                    <div class="mb-2">
                                        <small class="text-muted d-block">Nama</small>
                                        <strong>{{ auth()->user()->name }}</strong>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted d-block">Email</small>
                                        <span class="small">{{ auth()->user()->email }}</span>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted d-block">Role</small>
                                        <span class="badge bg-success">{{ auth()->user()->role->name ?? 'Admin' }}</span>
                                    </div>
                                    <div>
                                        <small class="text-muted d-block">Terdaftar</small>
                                        <span class="small">{{ auth()->user()->created_at->format('d M Y') }}</span>
                                    </div>
                                </div>
                            </li>
                            <li>
                                <hr class="dropdown-divider">
                            </li>
                            <li>
                                <a class="dropdown-item" href="{{ route('admin-management.index') }}">
                                    Kelola Admin
                                </a>
                            </li>
                            <li>
                                <form method="POST" action="/logout">
                                    @csrf
                                    <button type="submit" class="dropdown-item text-danger">
                                        Logout
                                    </button>
                                </form>
                            </li>
                        </ul>
                    </div>

                </div>

            </header>

            {{-- Main Content --}}
            <main class="main-content">

                @yield('content')

            </main>

        </div>

    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js"></script>

    <script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

</body>

</html>