@extends('layouts.app')

@section('content')

    <div class="container-fluid px-0">

        {{-- Header --}}
        <div class="mb-4">
            <div class="d-flex justify-content-between align-items-center mb-4">

                <div>
                    <h1 class="fw-bold mb-2">
                        Manajemen Kurir
                    </h1>

                    <p class="text-muted mb-0">
                        Pengelolaan Kurir EcoTrash
                    </p>
                </div>

                <a href="{{ route('couriers.create') }}" class="btn btn-success rounded-pill px-4 py-2">
                    + Tambah Courier
                </a>

            </div>
        </div>

        {{-- Statistik --}}
        <div class="row g-3 mb-4">

            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card border-0 shadow-sm rounded-4 h-100">
                    <div class="card-body p-4">
                        <p class="text-muted mb-2">
                            Total Courier
                        </p>

                        <h2 class="fw-bold display-5 mb-0">
                            {{ $totalCourier }}
                        </h2>
                    </div>
                </div>
            </div>

            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card border border-success-subtle bg-success-subtle rounded-4 h-100">
                    <div class="card-body p-4">
                        <p class="text-muted mb-2">
                            Courier Aktif
                        </p>

                        <h2 class="fw-bold display-5 text-success mb-0">
                            {{ $activeCourier }}
                        </h2>
                    </div>
                </div>
            </div>

            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card border border-info-subtle bg-info-subtle rounded-4 h-100">
                    <div class="card-body p-4">
                        <p class="text-muted mb-2">
                            Online
                        </p>

                        <h2 class="fw-bold display-5 text-info mb-0">
                            {{ $onlineCourier }}
                        </h2>
                    </div>
                </div>
            </div>

            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card border border-secondary-subtle bg-light rounded-4 h-100">
                    <div class="card-body p-4">
                        <p class="text-muted mb-2">
                            Offline
                        </p>

                        <h2 class="fw-bold display-5 text-secondary mb-0">
                            {{ $offlineCourier }}
                        </h2>
                    </div>
                </div>
            </div>

        </div>

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
                        placeholder="Cari nama / email courier"
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

        {{-- Table --}}
        <div class="card border-0 shadow-sm rounded-4">

            <div class="table-responsive">

                <table class="table align-middle mb-0">

                    <thead class="table-light">

                        <tr>
                            <th class="ps-4">Courier</th>
                            <th>Phone</th>
                            <th>Vehicle</th>
                            <th>City</th>
                            <th>Rating</th>
                            <th>Total Sampah Diambil</th>
                            <th>Status</th>
                            <th>Bergabung</th>
                            <th class="text-center pe-4">Aksi</th>
                        </tr>

                    </thead>

                    <tbody>

                        @forelse($couriers as $courier)

                            <tr>

                                {{-- Courier --}}
                                <td class="ps-4">

                                    <div class="fw-semibold fs-5">
                                        {{ $courier->name }}
                                    </div>

                                    <small class="text-muted">
                                        {{ $courier->email }}
                                    </small>

                                </td>

                                {{-- Phone --}}
                                <td>
                                    {{ $courier->phone ?? '-' }}
                                </td>

                                {{-- Vehicle --}}
                                <td>

                                    <div class="fw-semibold">
                                        {{ $courier->courierProfile?->vehicle_type ?? '-' }}
                                    </div>

                                    <small class="text-muted">
                                        {{ $courier->courierProfile?->vehicle_plate ?? '-' }}
                                    </small>

                                </td>

                                {{-- City --}}
                                <td>
                                    {{ $courier->courierProfile?->city ?? '-' }}
                                </td>

                                {{-- Rating --}}
                                <td>

                                    <span class="badge bg-warning text-dark fs-6">
                                        ⭐
                                        {{ number_format($courier->courierProfile?->rating ?? 0, 1) }}
                                    </span>

                                </td>

                                {{-- Total Waste Collected --}}
                                <td>

                                    <span class="fw-semibold text-success">
                                        {{ number_format($courier->courierProfile?->totalWasteCollected() ?? 0, 2) }} kg
                                    </span>

                                </td>

                                {{-- Status --}}
                                <td>

                                    @if($courier->is_active)

                                        <span class="badge bg-success">
                                            Aktif
                                        </span>

                                    @else

                                        <span class="badge bg-danger">
                                            Nonaktif
                                        </span>

                                    @endif

                                </td>

                                {{-- Bergabung --}}
                                <td>
                                    {{ $courier->created_at->format('d M Y') }}
                                </td>

                                {{-- Aksi --}}
                                <td class="text-center pe-4">

                                    <a href="{{ route('couriers.show', $courier->id) }}" class="btn btn-outline-success btn-sm">
                                        Detail
                                    </a>

                                </td>

                            </tr>

                        @empty

                            <tr>

                                <td colspan="9" class="text-center py-5 text-muted">

                                    Tidak ada courier ditemukan

                                </td>

                            </tr>

                        @endforelse

                    </tbody>

                </table>

            </div>

            {{-- Pagination --}}
            <div class="p-4 d-flex justify-content-end">
                {{ $couriers->links() }}
            </div>

        </div>

    </div>

@endsection