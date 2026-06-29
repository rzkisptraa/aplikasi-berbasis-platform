@extends('layouts.app')

@section('page-title', 'Detail Admin')

@section('content')

    <div class="container-fluid py-4">

        {{-- Header --}}
        <div class="dashboard-header mb-4">
            <div>
                <h1 class="dashboard-title">
                    Detail Admin
                </h1>
                <p class="dashboard-subtitle">
                    Informasi lengkap tentang admin sistem
                </p>
            </div>
            <a href="{{ route('admin-management.index') }}" class="btn-secondary-dashboard">
                Kembali
            </a>
        </div>

        {{-- Admin Detail Card --}}
        <div class="content-card">

            <div class="row g-4">

                {{-- Left Column --}}
                <div class="col-lg-8">

                    <div class="card border-0 shadow-sm rounded-4 mb-4">
                        <div class="card-body p-5">

                            <h5 class="section-title mb-4">
                                Informasi Umum
                            </h5>

                            <div class="row g-4">

                                <div class="col-md-6">
                                    <div class="info-group">
                                        <label class="info-label">Nama Admin</label>
                                        <p class="info-value">{{ $admin->name }}</p>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <div class="info-group">
                                        <label class="info-label">Email</label>
                                        <p class="info-value">{{ $admin->email }}</p>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <div class="info-group">
                                        <label class="info-label">Nomor Telepon</label>
                                        <p class="info-value">{{ $admin->phone ?? '-' }}</p>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <div class="info-group">
                                        <label class="info-label">Role</label>
                                        <p class="info-value">
                                            <span class="badge bg-success">
                                                {{ $admin->role->name ?? 'Admin' }}
                                            </span>
                                        </p>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <div class="info-group">
                                        <label class="info-label">Status Akun</label>
                                        <p class="info-value">
                                            @if($admin->is_active)
                                                <span class="badge bg-success">Aktif</span>
                                            @else
                                                <span class="badge bg-danger">Nonaktif</span>
                                            @endif
                                        </p>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <div class="info-group">
                                        <label class="info-label">Status Online</label>
                                        <p class="info-value">
                                            @if($admin->is_online)
                                                <span class="badge bg-success">Online</span>
                                            @else
                                                <span class="badge bg-secondary">Offline</span>
                                            @endif
                                        </p>
                                    </div>
                                </div>

                            </div>

                        </div>
                    </div>

                    {{-- Additional Info --}}
                    <div class="card border-0 shadow-sm rounded-4">
                        <div class="card-body p-5">

                            <h5 class="section-title mb-4">
                                Tanggal & Waktu
                            </h5>

                            <div class="row g-4">

                                <div class="col-md-6">
                                    <div class="info-group">
                                        <label class="info-label">Terdaftar Sejak</label>
                                        <p class="info-value">
                                            {{ $admin->created_at->format('d M Y H:i') }}
                                        </p>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <div class="info-group">
                                        <label class="info-label">Diperbarui Terakhir</label>
                                        <p class="info-value">
                                            {{ $admin->updated_at->format('d M Y H:i') }}
                                        </p>
                                    </div>
                                </div>

                            </div>

                        </div>
                    </div>

                </div>

                {{-- Right Column - Actions --}}
                <div class="col-lg-4">

                    <div class="card border-0 shadow-sm rounded-4">
                        <div class="card-body p-5">

                            <h5 class="section-title mb-4">
                                Aksi
                            </h5>

                            <div class="d-flex flex-column gap-3">

                                <form action="{{ route('admin-management.toggle-status', $admin->id) }}" method="POST">
                                    @csrf

                                    @if($admin->is_active)
                                        <button type="submit" class="btn btn-warning w-100 rounded-3">
                                            Nonaktifkan Admin
                                        </button>
                                    @else
                                        <button type="submit" class="btn btn-success w-100 rounded-3">
                                            Aktifkan Admin
                                        </button>
                                    @endif
                                </form>

                                <form action="{{ route('admin-management.fire', $admin->id) }}" method="POST" onsubmit="return confirm('Apakah Anda yakin ingin menghapus admin ini?');">
                                    @csrf
                                    <button type="submit" class="btn btn-danger w-100 rounded-3">
                                        Hapus Admin
                                    </button>
                                </form>

                            </div>

                        </div>
                    </div>

                </div>

            </div>

        </div>

    </div>

    <style>
        .info-group {
            margin-bottom: 12px;
        }

        .info-label {
            display: block;
            font-size: 0.875rem;
            color: #64748b;
            margin-bottom: 6px;
            font-weight: 600;
        }

        .info-value {
            font-size: 1rem;
            color: #1e293b;
            font-weight: 500;
            margin: 0;
        }

        .btn-secondary-dashboard {
            background-color: #f1f5f9;
            color: #475569;
            padding: 12px 24px;
            border-radius: 999px;
            text-decoration: none;
            font-weight: 600;
            display: inline-block;
            transition: all 0.3s ease;
        }

        .btn-secondary-dashboard:hover {
            background-color: #e2e8f0;
            color: #334155;
        }
    </style>

@endsection
