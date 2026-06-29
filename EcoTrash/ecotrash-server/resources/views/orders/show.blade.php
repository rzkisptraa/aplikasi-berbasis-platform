@extends('layouts.app')

@section('page-title', 'Dashboard')

@section('content')

<div class="mb-3">

    <h2
        class="fw-bold mb-1"
        style="font-size: clamp(2rem, 4vw, 3rem);"
    >
        Detail Pesanan
    </h2>

    <p class="text-muted mb-0">
        Informasi lengkap pesanan EcoTrash
    </p>

</div>

{{-- Header --}}
<div class="dashboard-card compact-card mb-3">

    <div
        class="d-flex justify-content-between align-items-start flex-wrap gap-3"
    >

        <div>

            <small class="text-muted">
                Kode Pesanan
            </small>

            <h2 class="fw-bold mb-3">
                {{ $order->order_code }}
            </h2>

            @switch($order->status)

                @case('PENDING')
                    <span class="badge bg-warning text-dark">
                        Menunggu
                    </span>
                @break

                @case('PICKED_UP')
                    <span class="badge bg-primary">
                        Sudah Diambil
                    </span>
                @break

                @case('DELIVERED')
                    <span class="badge bg-info">
                        Sedang Diantar
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

        </div>

        <a
            href="{{ url('/orders') }}"
            class="btn btn-outline-secondary rounded-pill px-4"
        >
            ← Kembali
        </a>

    </div>

</div>

{{-- Seller + Kurir --}}
<div class="row g-4 mb-4">

    {{-- Seller --}}
    <div class="col-lg-6">

        <div class="dashboard-card compact-card h-100">

            <h4 class="fw-bold mb-3">
                Informasi Seller
            </h4>

            <div class="mb-2">

                <small class="text-muted">
                    Nama
                </small>

                <h5 class="mb-0">
                    {{ $order->seller?->name ?? '-' }}
                </h5>

            </div>

            <div>

                <small class="text-muted">
                    Email
                </small>

                <p class="mb-0">
                    {{ $order->seller?->email ?? '-' }}
                </p>

            </div>

        </div>

    </div>

    {{-- Kurir --}}
    <div class="col-lg-6">

        <div class="dashboard-card h-100">

            <h4 class="fw-bold mb-4">
                Informasi Kurir
            </h4>

            <div class="mb-3">

                <small class="text-muted">
                    Nama Kurir
                </small>

                <h5 class="mb-0">
                    {{ $order->courier?->name ?? '-' }}
                </h5>

            </div>

            <div>

                <small class="text-muted">
                    Email
                </small>

                <p class="mb-0">
                    {{ $order->courier?->email ?? '-' }}
                </p>

            </div>

        </div>

    </div>

</div>

{{-- Detail Pesanan --}}
<div class="dashboard-card mb-4">

    <h4 class="fw-bold mb-4">
        Detail Pesanan
    </h4>

    <div class="row g-3">

        <div class="col-6 col-md-4 col-lg-2">

            <small class="text-muted">
                Berat Estimasi
            </small>

            <h4>
                {{ number_format($order->estimated_total_weight ?? 0, 2) }} Kg
            </h4>

        </div>

        <div class="col-6 col-md-4 col-lg-2">

            <small class="text-muted">
                Berat Aktual
            </small>

            <h4>
                {{ number_format($order->actual_total_weight ?? 0, 2) }} Kg
            </h4>

        </div>

        <div class="col-6 col-md-4 col-lg-2">

            <small class="text-muted">
                Total Harga
            </small>

            <h4 class="text-success">
                Rp {{ number_format($order->total_price ?? 0, 0, ',', '.') }}
            </h4>

        </div>

        <div class="col-6 col-md-4 col-lg-3">

            <small class="text-muted">
                Kendaraan Penjemputan
            </small>

            <h4>
                {{ ($order->vehicle_type ?? 'EcoRide') === 'EcoCargo' ? 'EcoCargo' : 'EcoRide' }}
            </h4>

        </div>

        <div class="col-6 col-md-4 col-lg-3">

            <small class="text-muted">
                Dibuat
            </small>

            <h5>
                {{ $order->created_at->format('d M Y H:i') }}
            </h5>

        </div>

    </div>

</div>

<div class="card border-0 rounded-5 shadow-sm p-4 mb-4">

        {{-- Detail Item Pesanan --}}
        <h4 class="fw-bold mb-3">Detail Item Pesanan</h4>

        @if($order->items && $order->items->isNotEmpty())

            <div class="table-responsive mb-4">
                <table class="table align-middle">
                    <thead>
                        <tr>
                            <th>Jenis Sampah</th>
                            <th class="text-end">Estimasi (Kg)</th>
                            <th class="text-end">Aktual (Kg)</th>
                            <th class="text-end">Harga/Kg</th>
                            <th class="text-end">Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($order->items as $item)
                            <tr>
                                <td>
                                    {{ $item->wasteCategory?->name ?? '—' }}
                                </td>
                                <td class="text-end">
                                    {{ number_format($item->estimated_weight ?? 0, 2) }}
                                </td>
                                <td class="text-end">
                                    {{ number_format($item->actual_weight ?? 0, 2) }}
                                </td>
                                <td class="text-end">
                                    Rp {{ number_format($item->price_per_kg ?? 0, 0, ',', '.') }}
                                </td>
                                <td class="text-end">
                                    Rp {{ number_format($item->subtotal ?? 0, 0, ',', '.') }}
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

        @else

            <div class="empty-state mb-4">
                Tidak ada item pesanan tercatat.
            </div>

        @endif

        <div class="mb-4">
            <h3 class="fw-bold mb-1">
                Bukti Pickup Sampah
            </h3>

            <p class="text-muted mb-0">
                Foto sampah saat diambil kurir
            </p>
        </div>

        @if($order->pickup_photo)

            <div class="pickup-image-wrapper">
                <img
                    src="{{ $order->pickup_photo_url }}"
                    alt="Pickup Photo"
                    class="pickup-image"
                >
            </div>

        @else

            <div class="pickup-empty-state">

                <h5 class="fw-semibold mb-2">
                    Belum ada bukti pickup
                </h5>

                <p class="text-muted mb-0">
                    Kurir belum mengunggah foto pickup
                    atau data belum tersedia.
                </p>

            </div>

        @endif

</div>

{{-- Area Pickup --}}
<div class="dashboard-card">

    <h4 class="fw-bold mb-3">
        Area Pickup
    </h4>

    <p class="text-muted mb-4">
        Lokasi penjemputan seller
    </p>

    <div class="mb-4">

        <small class="text-muted">
            Alamat Pickup
        </small>

        <p class="fw-semibold mb-0">
            {{ $order->sellerAddress->address ?? '-' }}
        </p>

    </div>

    @if(
        $order->latitude &&
        $order->longitude
    )

        <div
            id="pickupMap"
            style="
                height:280px;
                border-radius:24px;
                overflow:hidden;
            "
        ></div>

    @else

        <div
            class="
                border
                rounded-4
                p-5
                text-center
                text-muted
            "
        >
            Lokasi pickup belum tersedia
        </div>

    @endif

</div>

{{-- Map Script --}}
@if(
    $order->latitude &&
    $order->longitude
)

<script>

document.addEventListener(
    "DOMContentLoaded",
    function () {

        const lat =
            {{ $order->latitude }};

        const lng =
            {{ $order->longitude }};

        const map =
            L.map('pickupMap')
            .setView([lat, lng], 14);

        L.tileLayer(
            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            {
                attribution:
                    '&copy; OpenStreetMap'
            }
        ).addTo(map);

        L.marker([lat, lng])
            .addTo(map)
            .bindPopup(
                'Lokasi Pickup'
            )
            .openPopup();

    }
);

</script>

@endif

@endsection