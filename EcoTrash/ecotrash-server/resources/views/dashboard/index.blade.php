@extends('layouts.app')

@section('page-title', 'Dashboard')

@section('content')

    @php
        function statusIndonesia($status)
        {
            return match ($status) {
                'PENDING' => 'Menunggu',
                'APPROVED' => 'Disetujui',
                'REJECTED' => 'Ditolak',
                'COMPLETED' => 'Selesai',
                'DELIVERED' => 'Diantar',
                'PICKED_UP' => 'Diambil',
                'CANCELLED' => 'Dibatalkan',
                'PAID' => 'Dibayar',
                default => $status
            };
        }

        function statusClass($status)
        {
            return match ($status) {
                'COMPLETED', 'APPROVED' => 'status-success',
                'PENDING' => 'status-warning',
                'CANCELLED', 'REJECTED' => 'status-danger',
                default => 'status-info'
            };
        }
    @endphp

    <div class="mb-4">

        <div class="d-flex justify-content-between align-items-start flex-wrap gap-3">

            <div>
                <h2 class="fw-semibold mb-1">
                    Dashboard Operasional
                </h2>

                <p class="text-muted mb-0">
                    Ringkasan aktivitas dan performa EcoTrash
                </p>
            </div>

            {{-- Filter Range --}}
            <div class="range-filter">

                <a href="{{ route('dashboard', ['range' => 'today']) }}"
                    class="range-btn {{ $range === 'today' ? 'active' : '' }}">

                    Hari Ini

                </a>

                <a href="{{ route('dashboard', ['range' => 'week']) }}"
                    class="range-btn {{ $range === 'week' ? 'active' : '' }}">

                    Minggu Ini

                </a>

                <a href="{{ route('dashboard', ['range' => 'month']) }}"
                    class="range-btn {{ $range === 'month' ? 'active' : '' }}">

                    Bulan Ini

                </a>

                <a href="{{ route('dashboard', ['range' => 'all']) }}"
                    class="range-btn {{ $range === 'all' ? 'active' : '' }}">

                    Semua

                </a>

            </div>

        </div>

    </div>

    {{-- KPI --}}
    <div class="row g-3 mb-4">

        <div class="col-xl-3 col-md-6">
            <div class="dashboard-card">
                <div class="card-label">
                    Total Pengguna
                </div>

                <div class="card-value">
                    {{ number_format($totalUsers) }}
                </div>

                <div class="card-helper">
                    Pengguna EcoTrash
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6">
            <div class="dashboard-card">
                <div class="card-label">
                    Total Pesanan
                </div>

                <div class="card-value">
                    {{ number_format($totalOrders) }}
                </div>

                <div class="card-helper">
                    Berdasarkan filter waktu
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6">
            <div class="dashboard-card">
                <div class="card-label">
                    Total Kurir
                </div>

                <div class="card-value">
                    {{ number_format($totalCouriers) }}
                </div>

                <div class="card-helper">
                    Kurir terdaftar
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6">
            <div class="dashboard-card">
                <div class="card-label">
                    Pengeluaran
                </div>

                <div class="card-value text-success">
                    Rp {{ number_format($revenue) }}
                </div>

                <div class="card-helper">
                    Pesanan selesai
                </div>
            </div>
        </div>

    </div>

    {{-- Snapshot Status --}}
    <div class="row g-3 mb-4">

        <div class="col">
            <div class="summary-card summary-pending">
                <div class="summary-label">
                    Menunggu
                </div>
                <div class="summary-value">
                    {{ $orderSummary['pending'] }}
                </div>
            </div>
        </div>

        <div class="col">
            <div class="summary-card summary-picked">
                <div class="summary-label">
                    Diambil
                </div>
                <div class="summary-value">
                    {{ $orderSummary['picked_up'] }}
                </div>
            </div>
        </div>

        <div class="col">
            <div class="summary-card summary-delivered">
                <div class="summary-label">
                    Diantar
                </div>
                <div class="summary-value">
                    {{ $orderSummary['delivered'] }}
                </div>
            </div>
        </div>

        <div class="col">
            <div class="summary-card summary-completed">
                <div class="summary-label">
                    Selesai
                </div>
                <div class="summary-value">
                    {{ $orderSummary['completed'] }}
                </div>
            </div>
        </div>

        <div class="col">
            <div class="summary-card summary-cancelled">
                <div class="summary-label">
                    Dibatalkan
                </div>
                <div class="summary-value">
                    {{ $orderSummary['cancelled'] }}
                </div>
            </div>
        </div>

    </div>

    {{-- Statistik Pesanan --}}
    <div class="content-card mb-4">

        <div class="mb-4">

            <h5 class="section-title mb-1">
                Statistik Pesanan
            </h5>

            <p class="text-muted mb-0 small">
                Tren jumlah pesanan berdasarkan periode waktu
            </p>

        </div>

        <div class="chart-wrapper">

            <canvas id="ordersChart"></canvas>

        </div>

    </div>

    <script>
        document.addEventListener(
            'DOMContentLoaded',
            () => {

                const canvas =
                    document.getElementById(
                        'ordersChart'
                    );

                if (!canvas) return;

                const ctx =
                    canvas.getContext(
                        '2d'
                    );

                /*
                |--------------------------------------------------------------------------
                | Destroy old chart
                |--------------------------------------------------------------------------
                */

                if (
                    window.ordersChartInstance
                ) {

                    window
                        .ordersChartInstance
                        .destroy();
                }

                console.log(
                    @json($chartLabels)
                );

                console.log(
                    @json($chartData)
                );
                window.ordersChartInstance =
                    new Chart(
                        ctx,
                        {
                            type: 'line',

                            data: {

                                labels:
                                    @json($chartLabels),

                                datasets: [
                                    {

                                        data:
                                            @json($chartData),

                                        borderColor:
                                            '#1f8f55',

                                        borderWidth:
                                            2,

                                        pointRadius:
                                            4,

                                        pointHoverRadius:
                                            5,

                                        tension:
                                            0.35,

                                        fill:
                                            false
                                    }
                                ]
                            },

                            options: {

                                responsive:
                                    true,

                                maintainAspectRatio:
                                    false,

                                plugins: {

                                    legend: {
                                        display:
                                            false
                                    }
                                },

                                scales: {

                                    x: {

                                        grid: {
                                            display:
                                                false
                                        },

                                        ticks: {
                                            color:
                                                '#64748b'
                                        }
                                    },

                                    y: {

                                        beginAtZero:
                                            true,

                                        ticks: {

                                            precision:
                                                0,

                                            color:
                                                '#64748b'
                                        },

                                        grid: {
                                            color:
                                                '#eef2f7'
                                        }
                                    }
                                }
                            }
                        }
                    );
            }
        );
    </script>

    {{-- Row 1: Recent Orders & Recent Withdrawals --}}
    <div class="row g-4 mb-4">

        {{-- Pesanan --}}
        <div class="col-lg-6">
            <div class="content-card h-100">

                <h5 class="section-title mb-3">
                    Pesanan Terbaru
                </h5>

                @forelse($recentOrders as $order)

                    <div class="activity-item">

                        <div>

                            <div class="activity-title">
                                {{ $order->seller->name ?? '-' }}
                            </div>

                            <span class="status-badge {{ statusClass($order->status) }}">
                                {{ statusIndonesia($order->status) }}
                            </span>

                        </div>

                        <div class="activity-price">
                            Rp {{ number_format($order->total_price) }}
                        </div>

                    </div>

                @empty

                    <div class="empty-state">
                        Tidak ada data
                    </div>

                @endforelse

            </div>
        </div>

        {{-- Withdrawal --}}
        <div class="col-lg-6">
            <div class="content-card h-100">

                <h5 class="section-title mb-3">
                    Penarikan Dana
                </h5>

                @forelse($recentWithdrawals as $withdrawal)

                    <div class="activity-item">

                        <div>

                            <div class="activity-title">
                                {{ $withdrawal->user->name ?? '-' }}
                            </div>

                            <span class="status-badge {{ statusClass($withdrawal->status) }}">
                                {{ statusIndonesia($withdrawal->status) }}
                            </span>

                        </div>

                        <div class="activity-price">
                            Rp {{ number_format($withdrawal->amount) }}
                        </div>

                    </div>

                @empty

                    <div class="empty-state">
                        Tidak ada data
                    </div>

                @endforelse

            </div>
        </div>

    </div>

    {{-- Row 2: Top Couriers & Top Sellers --}}
    <div class="row g-4">

        {{-- Courier --}}
        <div class="col-lg-6">
            <div class="content-card h-100">

                <h5 class="section-title mb-3">
                    Kurir Terbaik (Top Couriers)
                </h5>

                @forelse($topCouriers as $courier)

                    <div class="activity-item">

                        <div>

                            <div class="activity-title">
                                {{ $courier->user->name ?? 'Kurir Demo' }}
                            </div>

                            <div class="activity-subtitle">
                                Rating ⭐ {{ number_format($courier->rating, 1) }}
                            </div>

                        </div>

                        <div class="performance-score text-success font-semibold">
                            {{ number_format($courier->totalWasteCollected(), 2) }} kg
                        </div>

                    </div>

                @empty

                    <div class="empty-state">
                        Tidak ada data
                    </div>

                @endforelse

            </div>
        </div>

        {{-- Top Sellers --}}
        <div class="col-lg-6">
            <div class="content-card h-100">

                <h5 class="section-title mb-3">
                    Kontributor Terbaik (Top Sellers)
                </h5>

                @forelse($topSellers as $seller)

                    <div class="activity-item">

                        <div>

                            <div class="activity-title">
                                {{ $seller->name }}
                            </div>

                            <div class="activity-subtitle">
                                {{ $seller->email }}
                            </div>

                        </div>

                        <div class="performance-score text-success font-semibold">
                            {{ $seller->completed_orders_count }} Pesanan
                        </div>

                    </div>

                @empty

                    <div class="empty-state">
                        Tidak ada data
                    </div>

                @endforelse

            </div>
        </div>

    </div>

@endsection