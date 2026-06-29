<div class="sidebar-container">

    {{-- Logo --}}
    <div class="brand-section">

        <h2 class="brand-title">
            EcoTrash
        </h2>

        <p class="brand-subtitle">
            Admin Dashboard
        </p>

    </div>

    {{-- Navigation --}}
    <nav class="sidebar-menu">

        <div class="menu-group">

            <p class="menu-label">
                OVERVIEW
            </p>

            <a href="{{ route('dashboard') }}"
                class="sidebar-link {{ request()->routeIs('dashboard') ? 'active' : '' }}">

                Dashboard

            </a>

        </div>

        <div class="menu-group">

            <p class="menu-label">
                OPERASIONAL
            </p>

            <a href="{{ route('orders') }}" class="sidebar-link {{ request()->routeIs('orders*') ? 'active' : '' }}">

                Orders

            </a>

            <a href="{{ route('couriers.index') }}" class="sidebar-link {{ request()->routeIs('couriers*') ? 'active' : '' }}">

                Couriers

            </a>

            <a href="{{ route('waste-categories.index') }}" class="sidebar-link {{ request()->routeIs('waste-categories*') ? 'active' : '' }}">

                Kategori Sampah

            </a>

        </div>

        <div class="menu-group">

            <p class="menu-label">
                FINANCE
            </p>

            <a href="{{ route('withdrawals') }}" class="sidebar-link {{ request()->routeIs('withdrawals*') ? 'active' : '' }}">

                Withdrawals

            </a>

        </div>

        @if(auth()->user()->role_id === 1)

            <div class="menu-group">

                <p class="menu-label">
                    SYSTEM
                </p>

                <a href="{{ route('admin-management.index') }}" class="sidebar-link {{ request()->routeIs('admin-management*') ? 'active' : '' }}">

                    Admin Management

                </a>

            </div>

        @endif

    </nav>

    <div class="sidebar-info-card">
        <small>Status Sistem</small>

        <h6>EcoTrash Admin</h6>

        <p>
            Sistem pengelolaan operasional dan keuangan untuk layanan EcoTrash, memastikan efisiensi dan transparansi dalam setiap aspek bisnis.
        </p>
    </div>

</div>