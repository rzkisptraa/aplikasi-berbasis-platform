@extends('layouts.app')

@section('content')
    <div class="container-fluid px-4 py-4">

        {{-- Header --}}
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="fw-bold mb-1">
                    Edit Profil Courier
                </h1>

                <p class="text-muted mb-0">
                    Perbarui informasi profil dan detail berkas dari {{ $courier->name }}
                </p>
            </div>

            <a href="{{ route('couriers.show', $courier->id) }}" class="btn btn-outline-secondary rounded-pill px-4">
                ← Batal
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

                <form action="{{ route('couriers.update', $courier->id) }}" method="POST" enctype="multipart/form-data">
                    @csrf

                    <div class="row">

                        {{-- LEFT --}}
                        <div class="col-lg-6">

                            <h4 class="fw-bold mb-4">
                                Informasi Akun
                            </h4>

                            {{-- Nama --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Nama Courier
                                </label>

                                <input type="text" name="name" class="form-control" value="{{ old('name', $courier->name) }}" required>
                            </div>

                            {{-- Email --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Email
                                </label>

                                <input type="email" name="email" class="form-control" value="{{ old('email', $courier->email) }}" required>
                            </div>

                            {{-- Password --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Password <span class="text-muted" style="font-size: 11px;">(Kosongkan jika tidak ingin diubah)</span>
                                </label>

                                <input type="password" name="password" class="form-control" placeholder="••••••••">
                            </div>

                            {{-- Phone --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Nomor HP
                                </label>

                                <input type="text" name="phone" class="form-control" value="{{ old('phone', $courier->phone) }}" required>
                            </div>

                            {{-- KTP Number --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Nomor KTP
                                </label>

                                <input type="text" name="ktp_number" class="form-control" value="{{ old('ktp_number', $courier->courierProfile?->ktp_number) }}" required>
                            </div>

                            {{-- Upload KTP --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Foto KTP <span class="text-muted" style="font-size: 11px;">(Kosongkan jika tidak ingin diubah)</span>
                                </label>

                                <input type="file" name="ktp_photo" class="form-control mb-2" accept="image/*">
                                @if($courier->courierProfile?->ktp_photo)
                                    <div class="mt-1">
                                        <small class="text-muted d-block mb-1">Foto KTP saat ini:</small>
                                        <img src="{{ asset('storage/' . $courier->courierProfile->ktp_photo) }}" alt="KTP" style="max-height: 100px; border-radius: 8px; border: 1px solid var(--eco-border);">
                                    </div>
                                @endif
                            </div>

                            {{-- SIM Number --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Nomor SIM
                                </label>

                                <input type="text" name="sim_number" class="form-control" value="{{ old('sim_number', $courier->courierProfile?->sim_number) }}" required>
                            </div>

                            {{-- Upload SIM --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Foto SIM <span class="text-muted" style="font-size: 11px;">(Kosongkan jika tidak ingin diubah)</span>
                                </label>

                                <input type="file" name="sim_photo" class="form-control mb-2" accept="image/*">
                                @if($courier->courierProfile?->sim_photo)
                                    <div class="mt-1">
                                        <small class="text-muted d-block mb-1">Foto SIM saat ini:</small>
                                        <img src="{{ asset('storage/' . $courier->courierProfile->sim_photo) }}" alt="SIM" style="max-height: 100px; border-radius: 8px; border: 1px solid var(--eco-border);">
                                    </div>
                                @endif
                            </div>

                            {{-- Face Photo --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Foto Wajah Courier <span class="text-muted" style="font-size: 11px;">(Kosongkan jika tidak ingin diubah)</span>
                                </label>

                                <input type="file" name="face_photo" class="form-control mb-2" accept="image/*">
                                @if($courier->courierProfile?->face_photo)
                                    <div class="mt-1">
                                        <small class="text-muted d-block mb-1">Foto Wajah saat ini:</small>
                                        <img src="{{ asset('storage/' . $courier->courierProfile->face_photo) }}" alt="Wajah" style="max-height: 100px; border-radius: 8px; border: 1px solid var(--eco-border);">
                                    </div>
                                @endif
                            </div>

                        </div>

                        {{-- RIGHT --}}
                        <div class="col-lg-6">

                            <h4 class="fw-bold mb-4">
                                Informasi Kendaraan
                            </h4>

                            {{-- Vehicle Type --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Jenis Kendaraan
                                </label>

                                <input type="text" name="vehicle_type" class="form-control" placeholder="Motor / Mobil"
                                    value="{{ old('vehicle_type', $courier->courierProfile?->vehicle_type) }}" required>
                            </div>

                            {{-- Vehicle Plate --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Plat Kendaraan
                                </label>

                                <input type="text" name="vehicle_plate" class="form-control" value="{{ old('vehicle_plate', $courier->courierProfile?->vehicle_plate) }}" required>
                            </div>

                            {{-- Address --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Address
                                </label>

                                <textarea name="address" rows="4" class="form-control" required>{{ old('address', $courier->courierProfile?->address) }}</textarea>
                            </div>

                            <div class="row">

                                {{-- City --}}
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">
                                        City
                                    </label>

                                    <input type="text" name="city" class="form-control" value="{{ old('city', $courier->courierProfile?->city) }}" required>
                                </div>

                                {{-- Province --}}
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">
                                        Province
                                    </label>

                                    <input type="text" name="province" class="form-control" value="{{ old('province', $courier->courierProfile?->province) }}" required>
                                </div>

                            </div>

                            <div class="text-end mt-4">
                                <button type="submit" class="btn btn-success px-5 py-2 rounded-pill">
                                    Simpan Perubahan
                                </button>
                            </div>

                        </div>

                    </div>

                </form>
            </div>
        </div>
    </div>
@endsection
