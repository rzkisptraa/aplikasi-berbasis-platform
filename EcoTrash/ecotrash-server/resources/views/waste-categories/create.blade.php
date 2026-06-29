@extends('layouts.app')

@section('content')
    <div class="container-fluid px-4 py-4">

        {{-- Header --}}
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="fw-bold mb-1">
                    Tambah Kategori Sampah
                </h1>
                <p class="text-muted mb-0">
                    Tambahkan jenis kategori sampah baru beserta harga per kilogram
                </p>
            </div>
            <a href="{{ route('waste-categories.index') }}" class="btn btn-outline-secondary rounded-pill px-4">
                ← Kembali
            </a>
        </div>

        {{-- Validation Error Alerts --}}
        @if ($errors->any())
            <div class="alert alert-danger border-0 rounded-4 shadow-sm mb-4 p-3">
                <h6 class="fw-bold mb-2">Terjadi Kesalahan:</h6>
                <ul class="mb-0 ps-3">
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        {{-- Card --}}
        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4">

                <form action="{{ route('waste-categories.store') }}" method="POST">
                    @csrf

                    <div class="row justify-content-center">
                        <div class="col-lg-8">

                            {{-- Nama Kategori --}}
                            <div class="mb-4">
                                <label class="form-label fw-semibold">Nama Kategori</label>
                                <input type="text" name="name" class="form-control @error('name') is-invalid @enderror" value="{{ old('name') }}" placeholder="Contoh: Plastik, Kertas, Logam" required style="border-radius: 12px; padding: 12px 16px;">
                                @error('name')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            {{-- Harga Per KG --}}
                            <div class="mb-4">
                                <label class="form-label fw-semibold">Harga per Kilogram (Rupiah)</label>
                                <div class="input-group">
                                    <span class="input-group-text" style="border-top-left-radius: 12px; border-bottom-left-radius: 12px; background: #f8fafc; border-right: 0;">Rp</span>
                                    <input type="number" name="price_per_kg" class="form-control @error('price_per_kg') is-invalid @enderror" value="{{ old('price_per_kg') }}" placeholder="Contoh: 3000" min="0" required style="border-top-right-radius: 12px; border-bottom-right-radius: 12px; padding: 12px 16px;">
                                </div>
                                @error('price_per_kg')
                                    <div class="text-danger small mt-1">{{ $message }}</div>
                                @enderror
                            </div>

                            {{-- Deskripsi --}}
                            <div class="mb-4">
                                <label class="form-label fw-semibold">Deskripsi Kategori</label>
                                <textarea name="description" rows="4" class="form-control @error('description') is-invalid @enderror" placeholder="Tulis deskripsi atau kriteria sampah yang termasuk dalam kategori ini..." style="border-radius: 12px; padding: 12px 16px;">{{ old('description') }}</textarea>
                                @error('description')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            {{-- Status Aktif --}}
                            <div class="mb-4">
                                <label class="form-label fw-semibold">Status Kategori</label>
                                <select name="is_active" class="form-select @error('is_active') is-invalid @enderror" required style="border-radius: 12px; padding: 12px 16px;">
                                    <option value="1" {{ old('is_active', '1') == '1' ? 'selected' : '' }}>Aktif (Tersedia untuk Transaksi)</option>
                                    <option value="0" {{ old('is_active') == '0' ? 'selected' : '' }}>Nonaktif (Tidak Tersedia)</option>
                                </select>
                                @error('is_active')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            {{-- Submit --}}
                            <div class="text-end mt-4">
                                <button type="submit" class="btn btn-success px-5 py-2.5 rounded-pill" style="background: var(--eco-primary); border-color: var(--eco-primary);">
                                    Simpan Kategori
                                </button>
                            </div>

                        </div>
                    </div>

                </form>
            </div>
        </div>
    </div>
@endsection
