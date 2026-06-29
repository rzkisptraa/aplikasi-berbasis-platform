@extends('layouts.app')

@section('page-title', 'Dashboard')

@section('content')

    <div class="withdrawal-page">

        {{-- Header --}}
        <div class="mb-5">

            <h1 style="
                            font-size:64px;
                            font-weight:700;
                            color:#0F172A;
                            line-height:1;
                        ">
                Penarikan Dana
            </h1>

            <p style="
                            font-size:20px;
                            color:#64748B;
                            margin-top:12px;
                        ">
                Kelola pencairan saldo pengguna
            </p>

        </div>

        {{-- Success Alert --}}
        @if(session('success'))

            <div class="mb-4" style="
                                        background:#DCFCE7;
                                        color:#15803D;
                                        padding:18px 24px;
                                        border-radius:24px;
                                        font-weight:600;
                                    ">
                {{ session('success') }}
            </div>

        @endif

        {{-- Statistik --}}
        <div class="row g-4 mb-5">

            <div class="col-12 col-md-4">

                <div class="stat-card">

                    <p class="stat-label">
                        Total Withdrawal
                    </p>

                    <h2 class="stat-number">
                        {{ $totalWithdrawals }}
                    </h2>

                    <p class="stat-subtitle">
                        Pengajuan penarikan
                    </p>

                </div>

            </div>

            <div class="col-12 col-md-4">

                <div class="stat-card">

                    <p class="stat-label">
                        Disetujui
                    </p>

                    <h2 class="stat-number" style="color:#16A34A;">
                        {{ $approvedWithdrawals }}
                    </h2>

                    <p class="stat-subtitle">
                        Sudah diproses
                    </p>

                </div>

            </div>

            <div class="col-12 col-md-4">

                <div class="stat-card">

                    <p class="stat-label">
                        Total Nominal
                    </p>

                    <h2 class="stat-number nominal">

                        Rp
                        {{ number_format($totalAmount, 0, ',', '.') }}

                    </h2>

                    <p class="stat-subtitle">
                        Total pencairan
                    </p>

                </div>

            </div>

        </div>

        {{-- Filter --}}
        <div class="card border-0 shadow-sm rounded-5 p-4 mb-4">

            <form action="{{ route('withdrawals') }}" method="GET" class="row g-3">

                <div class="col-12 col-lg-7">

                    <input type="text" name="search" value="{{ request('search') }}"
                        placeholder="Cari nama pengguna, email, atau bank" class="form-control custom-input rounded-pill">

                </div>

                <div class="col-12 col-md-6 col-lg-3">

                    <select name="status" class="form-select custom-input rounded-pill">
                        <option value="">
                            Semua Status
                        </option>

                        <option value="PENDING" {{ request('status') == 'PENDING' ? 'selected' : '' }}>
                            Menunggu
                        </option>

                        <option value="APPROVED" {{ request('status') == 'APPROVED' ? 'selected' : '' }}>
                            Disetujui
                        </option>

                        <option value="REJECTED" {{ request('status') == 'REJECTED' ? 'selected' : '' }}>
                            Ditolak
                        </option>
                    </select>

                </div>

                <div class="col-12 col-md-6 col-lg-2">

                    <button type="submit" class="btn btn-success w-100 rounded-pill py-3 fw-semibold">
                        Filter
                    </button>

                </div>

            </form>

        </div>

        {{-- Table --}}
        <div class="card border-0 shadow-sm rounded-5 p-4">

            <div class="table-responsive">

                <table class="table align-middle withdrawal-table">

                    <thead>

                        <tr class="text-secondary">

                            <th>Pengguna</th>
                            <th>Bank</th>
                            <th>Rekening</th>
                            <th>Nominal</th>
                            <th>Status</th>
                            <th>Tanggal</th>

                        </tr>

                    </thead>

                    <tbody>

                        @forelse($withdrawals as $withdrawal)

                            <tr class="withdrawal-row border-top">

                                {{-- User --}}
                                <td>

                                    <div class="text-secondary fw-semibold">
                                        {{ $withdrawal->user->name }}
                                    </div>

                                    <div class="text-muted">
                                        {{ $withdrawal->user->email }}
                                    </div>

                                </td>

                                {{-- Bank --}}
                                <td>
                                    {{ $withdrawal->bank_name }}
                                </td>

                                {{-- Rekening --}}
                                <td>
                                    {{ $withdrawal->account_number }}
                                </td>

                                {{-- Nominal --}}
                                <td class="fw-semibold" style="
                                                             color:#0f172a;
                                                             font-size:18px;
                                                 ">

                                    Rp
                                    {{ number_format($withdrawal->amount, 0, ',', '.') }}

                                </td>

                                {{-- Status --}}
                                <td>

                                    @if($withdrawal->status === 'PENDING')

                                        <span class="badge rounded-pill px-3 py-2" style="
                                                                                            background:#FFF4D6;
                                                                                            color:#D97706;
                                                                                        ">
                                            Menunggu
                                        </span>

                                    @elseif($withdrawal->status === 'APPROVED')

                                        <span class="badge rounded-pill px-3 py-2" style="
                                                                                            background:#DCFCE7;
                                                                                            color:#16A34A;
                                                                                        ">
                                            Disetujui
                                        </span>

                                    @else

                                        <span class="badge rounded-pill px-3 py-2" style="
                                                                                            background:#FEE2E2;
                                                                                            color:#DC2626;
                                                                                        ">
                                            Ditolak
                                        </span>

                                    @endif

                                </td>

                                {{-- Tanggal --}}
                                <td>

                                    {{ $withdrawal->created_at->format('d M Y') }}

                                </td>

                            </tr>

                        @empty

                            <tr>

                                <td colspan="6" class="text-center py-5 text-muted">
                                    Belum ada data penarikan
                                </td>

                            </tr>

                        @endforelse

                    </tbody>

                </table>

            </div>

        </div>

@endsection