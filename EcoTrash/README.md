# EcoTrash - Ubah Sampah Jadi Berkah ♻️

EcoTrash adalah aplikasi berbasis platform untuk mempermudah pengelolaan sampah daur ulang. Aplikasi ini mempertemukan **Seller** (penjual sampah) dan **Courier** (kurir penjemput sampah) dengan alur penimbangan digital terintegrasi yang dikonfirmasi oleh **Admin** gudang.

Proyek ini terdiri dari dua bagian utama:
1.  **Backend API:** Laravel Framework (ada di folder `ecotrash-server`)
2.  **Mobile Client:** Flutter Framework (ada di folder `ecotrash_mobile`)

---

## 🚀 Panduan Persiapan & Menjalankan Aplikasi

Ikuti langkah-langkah di bawah ini untuk menjalankan seluruh sistem di komputer lokal Anda:

### 1. Prasyarat (*Prerequisites*)
Pastikan Anda sudah menginstal:
*   [PHP >= 8.2](https://www.php.net/downloads.php)
*   [Composer](https://getcomposer.org/)
*   [Node.js](https://nodejs.org/) & NPM
*   [Flutter SDK](https://docs.flutter.dev/get-started/install)
*   [MySQL / MariaDB](https://www.mysql.com/) (atau menggunakan XAMPP/Laragon)

---

### 2. Setup Backend (`ecotrash-server`)

Buka terminal Anda, masuk ke folder `ecotrash-server`, lalu jalankan perintah berikut:

1.  **Instal Dependensi PHP (Composer):**
    ```bash
    composer install
    ```

2.  **Instal Dependensi JavaScript (NPM):**
    ```bash
    npm install
    ```

3.  **Buat & Konfigurasi File Lingkungan (`.env`):**
    Salin file template `.env.example` menjadi `.env`:
    *   **Windows (Command Prompt):** `copy .env.example .env`
    *   **Windows (PowerShell) / Linux / Mac:** `cp .env.example .env`

4.  **Konfigurasi Database di `.env`:**
    Buka file `.env` yang baru dibuat, lalu sesuaikan konfigurasi koneksi database Anda (buat database kosong bernama `ecotrash` di MySQL/phpMyAdmin Anda terlebih dahulu):
    ```env
    DB_CONNECTION=mysql
    DB_HOST=127.0.0.1
    DB_PORT=3306
    DB_DATABASE=ecotrash
    DB_USERNAME=root
    DB_PASSWORD=
    ```

5.  **Generate Application Key:**
    ```bash
    php artisan key:generate
    ```

6.  **Jalankan Migrasi & Database Seeding:**
    Perintah ini akan membuat semua tabel database dan mengisi data awal akun percobaan (Seller, Courier, Admin, Super Admin):
    ```bash
    php artisan migrate --seed
    ```

7.  **Jalankan Server Backend:**
    *   Terminal 1 (Server PHP):
        ```bash
        php artisan serve
        ```
    *   Terminal 2 (Asset Compiler):
        ```bash
        npm run dev
        ```

Setelah langkah ini selesai, API server Anda akan berjalan di `http://127.0.0.1:8000`.

---

### 3. Setup Frontend (`ecotrash_mobile`)

Buka terminal baru, masuk ke folder `ecotrash_mobile`, lalu jalankan langkah berikut:

1.  **Dapatkan Paket Dependensi Flutter:**
    ```bash
    flutter pub get
    ```

2.  **Sesuaikan Base URL API:**
    Buka file `lib/core/network/dio_client.dart` di baris ke-9. Sesuaikan `_currentBaseUrl` ke arah server API Anda:
    *   Jika menjalankan di **Browser/Web** atau **Simulator iOS**: `http://127.0.0.1:8000/api`
    *   Jika menjalankan di **Android Emulator**: `http://10.0.2.2:8000/api`
    *   Jika menjalankan di **HP Fisik**: Ganti dengan alamat IP lokal komputer Anda yang terhubung dalam satu jaringan Wi-Fi yang sama (contoh: `http://192.168.1.10:8000/api`).

3.  **Jalankan Aplikasi Mobile:**
    ```bash
    flutter run
    ```

---

### 🔑 Kredensial Akun Percobaan (Default Seeders)

Anda dapat langsung masuk ke aplikasi menggunakan data akun pengujian berikut (semua password adalah `password`):

*   **Role: Seller (Penjual)**
    *   Email: `seller1@ecotrash.com` s.d `seller5@ecotrash.com`
    *   Password: `password`
*   **Role: Courier (Kurir)**
    *   Email: `courier1@ecotrash.com` s.d `courier5@ecotrash.com`
    *   Password: `password`
*   **Role: Admin**
    *   Email: `admin1@ecotrash.com` s.d `admin3@ecotrash.com`
    *   Password: `password`
*   **Role: Super Admin**
    *   Email: `superadmin@ecotrash.com`
    *   Password: `password`
