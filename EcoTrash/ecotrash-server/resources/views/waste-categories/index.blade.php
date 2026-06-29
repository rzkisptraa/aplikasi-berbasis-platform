@extends('layouts.app')

@section('content')
    <div class="container-fluid px-0">

        {{-- Header --}}
        <div class="mb-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="fw-bold mb-2">
                        Kategori Sampah
                    </h1>
                    <p class="text-muted mb-0">
                        Kelola jenis dan harga per kilogram kategori sampah EcoTrash
                    </p>
                </div>
                <a href="{{ route('waste-categories.create') }}" class="btn btn-success rounded-pill px-4 py-2" style="background: var(--eco-primary); border-color: var(--eco-primary);">
                    + Tambah Kategori
                </a>
            </div>
        </div>

        {{-- Session Flash Alert --}}
        @if(session('success'))
            <div class="alert alert-success border-0 rounded-4 shadow-sm mb-4 p-3 d-flex align-items-center">
                <span class="me-2" style="font-size: 20px;">✅</span>
                <div>{{ session('success') }}</div>
            </div>
        @endif

        {{-- Filter --}}
        <div class="card border-0 shadow-sm rounded-4 mb-4">
            <div class="card-body p-4">
                <form method="GET" action="{{ route('waste-categories.index') }}">
                    <div class="row g-3 align-items-center">
                        {{-- Search --}}
                        <div class="col-lg-9">
                            <input
                                type="text"
                                name="search"
                                value="{{ $search }}"
                                class="form-control custom-input"
                                placeholder="Cari nama atau deskripsi kategori..."
                                style="border-radius: 12px; padding: 12px 16px; border: 1px solid var(--eco-border);"
                            >
                        </div>
                        {{-- Button --}}
                        <div class="col-lg-3">
                            <button
                                type="submit"
                                class="btn btn-success w-100 py-2.5 rounded-pill"
                                style="background: var(--eco-primary); border-color: var(--eco-primary);"
                            >
                                Cari Kategori
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
                            <th class="ps-4" style="width: 50px;">No</th>
                            <th>Nama Kategori</th>
                            <th>Deskripsi</th>
                            <th>Harga / kg</th>
                            <th>Status</th>
                            <th class="text-center pe-4" style="width: 200px;">Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($categories as $index => $category)
                            <tr>
                                <td class="ps-4 text-muted">
                                    {{ $categories->firstItem() + $index }}
                                </td>
                                <td>
                                    <div class="fw-bold fs-5 text-dark">
                                        {{ $category->name }}
                                    </div>
                                </td>
                                <td>
                                    <span class="text-secondary text-truncate-2" style="font-size: 13.5px; max-width: 300px; display: inline-block;">
                                        {{ $category->description ?? 'Tidak ada deskripsi.' }}
                                    </span>
                                </td>
                                <td>
                                    <span class="fw-bold text-success">
                                        Rp {{ number_format($category->price_per_kg, 0, ',', '.') }}
                                    </span>
                                </td>
                                <td>
                                    @if($category->is_active)
                                        <span class="badge rounded-pill bg-success-soft text-success px-3 py-1.5" style="background: #e8f7ef; font-weight: 600;">
                                            Aktif
                                        </span>
                                    @else
                                        <span class="badge rounded-pill bg-danger-soft text-danger px-3 py-1.5" style="background: #fdf2f2; font-weight: 600;">
                                            Nonaktif
                                        </span>
                                    @endif
                                </td>
                                <td class="text-center pe-4">
                                    <div class="d-flex justify-content-center gap-2">
                                        <a href="{{ route('waste-categories.edit', $category->id) }}" class="btn btn-outline-primary btn-sm rounded-pill px-3">
                                            Edit
                                        </a>
                                        <form action="{{ route('waste-categories.destroy', $category->id) }}" method="POST" class="d-inline" onsubmit="return confirm('Apakah Anda yakin ingin menghapus kategori sampah ini?')">
                                            @csrf
                                            <button type="submit" class="btn btn-outline-danger btn-sm rounded-pill px-3">
                                                Hapus
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="6" class="text-center py-5 text-muted">
                                    <span style="font-size: 40px;" class="d-block mb-2">🗑️</span>
                                    Tidak ada kategori sampah ditemukan.
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            {{-- Pagination --}}
            @if($categories->hasPages())
                <div class="p-4 d-flex justify-content-end border-top">
                    {{ $categories->appends(request()->query())->links() }}
                </div>
            @endif
        </div>
    </div>
@endsection
