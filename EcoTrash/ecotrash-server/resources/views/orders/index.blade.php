@extends('layouts.app')

@section('page-title', 'Dashboard')

@section('content')

<div class="mb-4">

    <h2
        class="fw-bold mb-1"
        style="font-size: 3rem;"
    >
        Manajemen Pesanan
    </h2>

    <p class="text-muted">
        Kelola seluruh aktivitas pesanan EcoTrash
    </p>

</div>

{{-- Statistik --}}
<div class="row g-4 mb-4">

    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card h-100">
            <p class="text-muted mb-2">
                Total Pesanan
            </p>

            <h2 class="fw-bold">
                {{ $totalOrders }}
            </h2>
        </div>
    </div>

    <div class="col-md-6 col-xl-3">
        <div
            class="dashboard-card h-100"
            style="
                border:1px solid #FFD66B;
                background:#FFFBEF;
            "
        >
            <p class="mb-2">
                Menunggu
            </p>

            <h2 class="fw-bold">
                {{ $pendingOrders }}
            </h2>
        </div>
    </div>

    <div class="col-md-6 col-xl-3">
        <div
            class="dashboard-card h-100"
            style="
                border:1px solid #9BE8B1;
                background:#F1FFF4;
            "
        >
            <p class="mb-2">
                Selesai
            </p>

            <h2 class="fw-bold text-success">
                {{ $completedOrders }}
            </h2>
        </div>
    </div>

    <div class="col-md-6 col-xl-3">
        <div class="dashboard-card h-100">
            <p class="text-muted mb-2">
                Total Pengeluaran
            </p>

            <h2
                class="fw-bold text-success"
            >
                Rp
                {{ number_format($revenue, 0, ',', '.') }}
            </h2>

            <small class="text-muted">
                Dari pesanan selesai
            </small>
        </div>
    </div>

</div>

{{-- Filter + Table --}}
<div class="dashboard-card">

    <form
    action="{{ url('/orders') }}"
    method="GET"
    class="row g-3 order-filter-form"
    >

        <div class="col-lg-5">
            <input
                type="text"
                name="search"
                value="{{ request('search') }}"
                class="form-control custom-input rounded-pill"
                placeholder="Cari kode pesanan / seller / kurir">
        </div>

        <div class="col-lg-3">
            <select
                name="status"
                class="form-select custom-input rounded-pill"
            >
                <option value="ALL">
                    Semua Status
                </option>

                <option
                    value="PENDING"
                    @selected(request('status')==='PENDING')
                >
                    Menunggu
                </option>

                <option
                    value="PICKED_UP"
                    @selected(request('status')==='PICKED_UP')
                >
                    Diambil
                </option>

                <option
                    value="DELIVERED"
                    @selected(request('status')==='DELIVERED')
                >
                    Diantar
                </option>

                <option
                    value="COMPLETED"
                    @selected(request('status')==='COMPLETED')
                >
                    Selesai
                </option>

                <option
                    value="CANCELLED"
                    @selected(request('status')==='CANCELLED')
                >
                    Dibatalkan
                </option>
            </select>
        </div>

        <div class="col-lg-2 d-flex align-items-center">
            <button
                type="submit"
                class="eco-filter-btn rounded-pill w-100"
            >
                Filter
            </button>
        </div>

    </form>

    <div class="table-responsive">

        <table class="table align-middle">

            <thead>
                <tr>
                    <th>Kode</th>
                    <th>Seller</th>
                    <th>Kurir</th>
                    <th>Kendaraan</th>
                    <th>Jumlah Item</th>
                    <th>Berat</th>
                    <th>Total</th>
                    <th>Status</th>
                    <th>Tanggal</th>
                </tr>
            </thead>

            <tbody>

                @forelse($orders as $order)

                    <tr>

                        <td>
                            {{ $order->order_code }}
                        </td>

                        <td>
                            {{ $order->seller?->name ?? '-' }}
                        </td>

                        <td>
                            {{ $order->courier?->name ?? '-' }}
                        </td>

                        <td>
                            @if(($order->vehicle_type ?? 'EcoRide') === 'EcoCargo')
                                <span class="badge bg-secondary">EcoCargo</span>
                            @else
                                <span class="badge bg-light text-dark">EcoRide</span>
                            @endif
                        </td>

                            <td>
                                {{ $order->items_count ?? $order->items->count() }}
                            </td>

                        <td>
                            @php
                                $itemsWeight = $order->items_total_actual_weight ?: $order->items->sum('actual_weight');
                                $displayWeight = $itemsWeight ?: $order->actual_total_weight ?: $order->estimated_total_weight ?: 0;
                            @endphp

                            {{ number_format($displayWeight, 2) }} Kg
                        </td>

                        <td class="fw-semibold">
                            Rp
                            {{ number_format($order->total_price ?? 0, 0, ',', '.') }}
                        </td>

                        <td>

                            @switch($order->status)

                                @case('PENDING')
                                    <span class="badge bg-warning text-dark">
                                        Menunggu
                                    </span>
                                @break

                                @case('PICKED_UP')
                                    <span class="badge bg-primary">
                                        Diambil
                                    </span>
                                @break

                                @case('DELIVERED')
                                    <span class="badge bg-info">
                                        Diantar
                                    </span>
                                @break

                                @case('COMPLETED')
                                    <span class="badge bg-success">
                                        Selesai
                                    </span>
                                @break

                                @default
                                    <span class="badge bg-danger">
                                        Dibatalkan
                                    </span>
                            @endswitch

                        </td>

                        <td>
                            {{ $order->created_at->format('d M Y') }}
                        </td>

                        <td class="text-center">

                            <a
                                href="{{ url('/orders/' . $order->id) }}"
                                class="btn btn-outline-success btn-sm"
                            >
                                Detail
                            </a>

                        </td>

                    </tr>

                @empty

                    <tr>
                        <td
                            colspan="8"
                            class="text-center py-5"
                        >
                            Tidak ada data pesanan
                        </td>
                    </tr>

                @endforelse

            </tbody>

        </table>

    </div>

<div class="order-pagination-wrapper">

    <div class="order-result-count">
        Showing
        {{ $orders->firstItem() }}
        to
        {{ $orders->lastItem() }}
        of
        {{ $orders->total() }}
        results
    </div>

    <div class="eco-pagination">
        {{ $orders->onEachSide(1)->links('pagination::bootstrap-5') }}
    </div>

</div>

</div>
@endsection