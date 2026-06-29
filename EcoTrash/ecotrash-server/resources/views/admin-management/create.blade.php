@extends('layouts.app')

@section('content')

<div class="container-fluid p-4">

    <div class="d-flex justify-content-between align-items-center mb-4">

        <div>
            <h1 class="fw-bold">
                Tambah Admin
            </h1>

            <p class="text-muted">
                Tambahkan admin baru EcoTrash
            </p>
        </div>

        <a
            href="{{ route('admin-management.index') }}"
            class="btn btn-outline-secondary rounded-pill px-4"
        >
            ← Kembali
        </a>

    </div>

    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-body p-4">

            <form
                action="{{ route('admin-management.store') }}"
                method="POST"
            >

                @csrf

                <div class="mb-3">
                    <label class="form-label">
                        Nama Admin
                    </label>

                    <input
                        type="text"
                        name="name"
                        class="form-control"
                        required
                    >
                </div>

                <div class="mb-3">
                    <label class="form-label">
                        Email
                    </label>

                    <input
                        type="email"
                        name="email"
                        class="form-control"
                        required
                    >
                </div>

                <div class="mb-3">
                    <label class="form-label">
                        Password
                    </label>

                    <input
                        type="password"
                        name="password"
                        class="form-control"
                        required
                    >
                </div>

                <div class="mb-3">
                    <label class="form-label">
                        Nomor HP
                    </label>

                    <input
                        type="text"
                        name="phone"
                        class="form-control"
                        required
                    >
                </div>

                <button
                    type="submit"
                    class="btn btn-success rounded-pill px-4"
                >
                    Simpan Admin
                </button>

            </form>

        </div>
    </div>

</div>

@endsection