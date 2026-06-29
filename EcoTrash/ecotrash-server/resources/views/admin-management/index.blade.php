@extends('layouts.app')

@section('content')

    <div style="padding:40px;">

        {{-- HEADER --}}
        <div class="dashboard-header">

            <div>

                <h1 class="dashboard-title">
                    Manajemen Admin
                </h1>

                <p class="dashboard-subtitle">
                    Kelola admin EcoTrash
                </p>

            </div>

            <a href="{{ route('admin-management.create') }}" class="btn-primary-dashboard">
                + Tambah Admin
            </a>

        </div>

        {{-- STAT CARD --}}
        <div class="stats-grid mb-4">

            <div class="stat-card">

                <span class="stat-label">
                    Total Admin
                </span>

                <h2 class="stat-number">
                    {{ $totalAdmin }}
                </h2>

            </div>

            <div class="stat-card">

                <span class="stat-label">
                    Admin Aktif
                </span>

                <h2 class="stat-number text-success">
                    {{ $activeAdmin }}
                </h2>

            </div>

            <div class="stat-card">

                <span class="stat-label">
                    Online
                </span>

                <h2 class="stat-number text-success">
                    {{ $onlineAdmin }}
                </h2>

            </div>

            <div class="stat-card">

                <span class="stat-label">
                    Offline
                </span>

                <h2 class="stat-number text-secondary">
                    {{ $offlineAdmin }}
                </h2>

            </div>

        </div>

        {{-- FILTER --}}
        {{-- Filter --}}
<div class="card border-0 shadow-sm rounded-5 mb-4">

    <div class="card-body p-4">

        <form method="GET">

            <div class="row g-3 align-items-center">

                {{-- Search --}}
                <div class="col-lg-6">

                    <input
                        type="text"
                        name="search"
                        value="{{ request('search') }}"
                        class="form-control custom-input"
                        placeholder="Cari nama admin atau email"
                    >

                </div>

                {{-- Status --}}
                <div class="col-lg-3">

                    <select
                        name="status"
                        class="form-select custom-input"
                    >

                        <option value="">
                            Semua Status
                        </option>

                        <option
                            value="1"
                            {{ request('status') === '1' ? 'selected' : '' }}
                        >
                            Aktif
                        </option>

                        <option
                            value="0"
                            {{ request('status') === '0' ? 'selected' : '' }}
                        >
                            Nonaktif
                        </option>

                    </select>

                </div>

                {{-- Button --}}
                <div class="col-lg-3">

                    <button
                        type="submit"
                        class="eco-filter-btn w-100"
                    >
                        Filter
                    </button>

                </div>

            </div>

        </form>

    </div>

</div>

        {{-- TABLE --}}
        <div style="
                background:#fff;
                border-radius:40px;
                padding:35px;
                box-shadow:0 2px 10px rgba(0,0,0,.05);
                overflow-x:auto;
            ">

            <table style="
                    width:100%;
                    border-collapse:collapse;
                    min-width:1000px;
                ">

                <thead>
                    <tr style="
                            border-bottom:2px solid #e2e8f0;
                        ">
                        <th style="padding:20px;text-align:left;">
                            Nama
                        </th>

                        <th style="padding:20px;text-align:left;">
                            Email
                        </th>

                        <th style="padding:20px;text-align:left;">
                            Role
                        </th>

                        <th style="padding:20px;text-align:left;">
                            Status
                        </th>

                        <th style="padding:20px;text-align:left;">
                            Online
                        </th>

                        <th style="padding:20px;text-align:left;">
                            Bergabung
                        </th>

                        <th style="padding:20px;text-align:center;">
                            Aksi
                        </th>
                    </tr>
                </thead>

                <tbody>

                    @forelse($admins as $admin)

                        <tr style="
                                    border-bottom:1px solid #e2e8f0;
                                ">

                            <td style="padding:28px 20px;">
                                <strong style="font-size:22px;">
                                    {{ $admin->name }}
                                </strong>
                            </td>

                            <td>
                                {{ $admin->email }}
                            </td>

                            <td>
                                <span style="
                                            background:#dcfce7;
                                            color:#16a34a;
                                            padding:12px 24px;
                                            border-radius:999px;
                                            font-weight:700;
                                        ">
                                    ADMIN
                                </span>
                            </td>

                            <td>
                                @if($admin->is_active)

                                    <span style="
                                                        background:#dcfce7;
                                                        color:#16a34a;
                                                        padding:12px 22px;
                                                        border-radius:999px;
                                                        font-weight:700;
                                                    ">
                                        Aktif
                                    </span>

                                @else

                                    <span style="
                                                        background:#fee2e2;
                                                        color:#dc2626;
                                                        padding:12px 22px;
                                                        border-radius:999px;
                                                        font-weight:700;
                                                    ">
                                        Nonaktif
                                    </span>

                                @endif
                            </td>

                            <td>

                                @if($admin->is_online)

                                    <span style="
                                                    color:#16a34a;
                                                    font-weight:700;
                                                ">
                                        Online
                                    </span>

                                @else

                                    <span style="
                                                    color:#94a3b8;
                                                    font-weight:700;
                                                ">
                                        Offline
                                    </span>

                                @endif

                            </td>

                            <td>
                                {{ $admin->created_at->format('d M Y') }}
                            </td>

                            <td class="text-center">
                                <a href="{{ route('admin-management.show', $admin->id) }}" class="btn btn-outline-success btn-sm">
                                    Detail
                                </a>
                            </td>

                        </tr>

                    @empty

                        <tr>
                            <td colspan="7" style="
                                            text-align:center;
                                            padding:60px;
                                            color:#64748b;
                                        ">
                                Tidak ada data admin
                            </td>
                        </tr>

                    @endforelse

                </tbody>
            </table>

        </div>

    </div>

@endsection