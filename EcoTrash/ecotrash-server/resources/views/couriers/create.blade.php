@extends('layouts.app')

@section('content')
    <div class="container-fluid px-4 py-4">

        {{-- Header --}}
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h1 class="fw-bold mb-1">
                    Tambah Courier
                </h1>

                <p class="text-muted mb-0">
                    Tambahkan courier baru EcoTrash
                </p>
            </div>

            <a href="{{ route('couriers.index') }}" class="btn btn-outline-secondary rounded-pill px-4">
                ← Kembali
            </a>
        </div>

        {{-- Card --}}
        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4">

                <form action="{{ route('couriers.store') }}" method="POST" enctype="multipart/form-data">
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

                                <input type="text" name="name" class="form-control" required>
                            </div>

                            {{-- Email --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Email
                                </label>

                                <input type="email" name="email" class="form-control" required>
                            </div>

                            {{-- Password --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Password
                                </label>

                                <input type="password" name="password" class="form-control" required>
                            </div>

                            {{-- Phone --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Nomor HP
                                </label>

                                <input type="text" name="phone" class="form-control" required>
                            </div>

                            {{-- KTP Number --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Nomor KTP
                                </label>

                                <input type="text" name="ktp_number" class="form-control" required>
                            </div>

                            {{-- Upload KTP --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Foto KTP
                                </label>

                                <input type="file" name="ktp_photo" class="form-control" accept="image/*" required>
                            </div>

                            {{-- SIM Number --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Nomor SIM
                                </label>

                                <input type="text" name="sim_number" class="form-control" required>
                            </div>

                            {{-- Upload SIM --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Foto SIM
                                </label>

                                <input type="file" name="sim_photo" class="form-control" accept="image/*" required>
                            </div>

                            {{-- Face Photo --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Foto Wajah Courier
                                </label>

                                <input type="file" name="face_photo" class="form-control" accept="image/*" required>
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
                                    required>
                            </div>

                            {{-- Vehicle Plate --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Plat Kendaraan
                                </label>

                                <input type="text" name="vehicle_plate" class="form-control" required>
                            </div>

                            {{-- Address --}}
                            <div class="mb-3">
                                <label class="form-label">
                                    Address
                                </label>

                                <textarea name="address" rows="4" class="form-control" required></textarea>
                            </div>

                            <div class="row">

                                {{-- City --}}
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">
                                        City
                                    </label>

                                    <input type="text" name="city" class="form-control" required>
                                </div>

                                {{-- Province --}}
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">
                                        Province
                                    </label>

                                    <input type="text" name="province" class="form-control" required>
                                </div>

                            </div>

                            <div class="text-end mt-4">
                                <button type="submit" class="btn btn-success px-5 py-2 rounded-pill">
                                    Simpan Courier
                                </button>
                            </div>

                        </div>

                    </div>

                </form>
            </div>
        </div>
    </div>
@endsection