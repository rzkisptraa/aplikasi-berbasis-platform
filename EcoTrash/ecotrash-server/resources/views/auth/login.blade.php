<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>
        Masuk - EcoTrash
    </title>

    <link
        href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap"
        rel="stylesheet"
    >

    @vite([
        'resources/css/app.css',
        'resources/js/app.js'
    ])
</head>

<body>

    <div
        style="
            min-height:100vh;
            display:flex;
        "
    >

        {{-- LEFT PANEL --}}
        <div
            style="
                flex:1;
                position:relative;
                background-image:url('{{ asset('storage/bg.jpg') }}');
                background-size:cover;
                background-position:center;
                display:flex;
                align-items:center;
                justify-content:center;
                color:white;
                padding:40px;
                min-height:100vh;
            "
        >

            <div
                style="
                    position:absolute;
                    inset:0;
                    background:rgba(0, 0, 0, 0.45);
                "
            ></div>

            <div
                style="
                    position:relative;
                    text-align:center;
                    max-width:520px;
                    z-index:1;
                "
            >

                <h1
                    style="
                        font-size:58px;
                        margin:0;
                        font-weight:700;
                        letter-spacing: -1px;
                    "
                >
                    EcoTrash
                </h1>

                <p
                    style="
                        margin-top:18px;
                        font-size:20px;
                        line-height:1.7;
                        opacity:.95;
                    "
                >
                    Panel admin untuk memantau pesanan, mengelola kurir, dan melihat laporan operasional secara real-time.
                </p>

                <div
                    style="
                        margin-top:32px;
                        text-align:center;
                        font-size:16px;
                        color:rgba(255,255,255,0.94);
                        display:grid;
                        gap:10px;
                    "
                >
                    <div>• Pantau status penjemputan dan pengiriman.</div>
                    <div>• Kelola kurir, aktivitas, dan validasi akun.</div>
                    <div>• Lihat ringkasan pendapatan, pesanan, dan performa.</div>
                </div>

            </div>

        </div>

        {{-- RIGHT PANEL --}}
        <div
            style="
                width:500px;
                background:white;
                display:flex;
                align-items:center;
                justify-content:center;
                padding:40px;
            "
        >

            <div
                style="
                    width:100%;
                "
            >

                <h2
                    style="
                        font-size:42px;
                        margin-bottom:10px;
                        font-weight:700;
                    "
                >
                    Masuk
                </h2>

                <p
                    style="
                        color:#4b5563;
                        margin-bottom:32px;
                        line-height:1.5;
                    "
                >
                    Masukkan email dan kata sandi akun admin Anda untuk mulai mengelola EcoTrash.
                </p>

                <form
                    action="/login"
                    method="POST"
                >

                    @csrf

                    @if ($errors->any())
                        <div
                            style="
                                background:#fee2e2;
                                color:#991b1b;
                                padding:16px;
                                border-radius:12px;
                                margin-bottom:20px;
                                font-size:14px;
                            "
                        >
                            <strong>Gagal masuk.</strong>
                            <div style="margin-top:6px;">
                                {{ $errors->first() }}
                            </div>
                        </div>
                    @endif

                    {{-- Email --}}
                    <div
                        style="
                            margin-bottom:20px;
                        "
                    >

                        <label
                            style="
                                display:block;
                                margin-bottom:8px;
                                font-weight:500;
                            "
                        >
                            Email
                        </label>

                        <input
                            type="email"
                            name="email"
                            required
                            autocomplete="email"
                            placeholder="contoh@ecotrash.com"
                            style="
                                width:100%;
                                padding:16px;
                                border:1px solid #d1d5db;
                                border-radius:14px;
                                font-size:16px;
                                background:#f8fafc;
                                outline:none;
                            "
                        >

                    </div>

                    {{-- Password --}}
                    <div
                        style="
                            margin-bottom:20px;
                        "
                    >

                        <label
                            style="
                                display:block;
                                margin-bottom:8px;
                                font-weight:500;
                            "
                        >
                            Password
                        </label>

                        <input
                            type="password"
                            name="password"
                            required
                            autocomplete="current-password"
                            placeholder="Kata sandi Anda"
                            style="
                                width:100%;
                                padding:16px;
                                border:1px solid #d1d5db;
                                border-radius:14px;
                                font-size:16px;
                                background:#f8fafc;
                                outline:none;
                            "
                        >

                    </div>


                    <button
                        type="submit"
                        style="
                            width:100%;
                            border:none;
                            border-radius:16px;
                            background:#1f8f55;
                            color:white;
                            padding:18px;
                            font-size:18px;
                            font-weight:600;
                            cursor:pointer;
                            transition:background .2s ease;
                        "
                        onmouseover="this.style.background='#196f40'"
                        onmouseout="this.style.background='#1f8f55'"
                    >
                        Masuk
                    </button>

                    <!-- Lupa password dihapus; fitur tidak tersedia untuk data dummy -->

                </form>

            </div>

        </div>

    </div>

</body>

</html>