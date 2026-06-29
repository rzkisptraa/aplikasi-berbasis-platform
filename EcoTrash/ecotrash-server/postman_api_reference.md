# EcoTrash Postman API Reference Guide

Dokumen ini berisi daftar lengkap endpoint API EcoTrash yang siap digunakan untuk pengujian di Postman, diurutkan berdasarkan role pengguna: **Superadmin, Admin, Kurir, dan Seller**, serta **Endpoint Publik/Umum**.

---

## 🔑 PETUNJUK UMUM PENGUJIAN DI POSTMAN

Sebelum menguji endpoint yang dilindungi (*protected*), Anda harus melakukan login terlebih dahulu untuk mendapatkan token autentikasi.

### 1. Dapatkan Token (Login)
* Jalankan request **Login** sesuai role Anda.
* Salin nilai `token` yang dikembalikan di response JSON.

### 2. Konfigurasi Autentikasi di Postman
Di setiap request berikutnya:
1. Buka tab **Authorization** di Postman.
2. Pilih tipe **Bearer Token**.
3. Tempelkan (*paste*) token yang telah Anda salin ke kolom token.
4. Atau tambahkan secara manual di tab **Headers**:
   * Key: `Authorization`
   * Value: `Bearer <token_anda>`
   * Key: `Accept`
   * Value: `application/json`

---

## 1. 👑 FITUR SUPERADMIN (Role ID: 1)

Fitur ini hanya dapat diakses oleh pengguna dengan `role_id = 1` (Superadmin). Digunakan untuk manajemen level admin.

### A. Lihat Daftar Admin
Melihat daftar semua pengguna dengan role Admin (role_id = 2).
* **Method:** `GET`
* **URL:** `{{base_url}}/api/super-admin/admins`
* **Headers:** 
  * `Authorization: Bearer <token>`
  * `Accept: application/json`

### B. Tambah Admin Baru
Membuat akun Admin baru di sistem.
* **Method:** `POST`
* **URL:** `{{base_url}}/api/super-admin/admins`
* **Headers:** 
  * `Authorization: Bearer <token>`
  * `Content-Type: application/json`
  * `Accept: application/json`
* **Body (RAW JSON):**
```json
{
  "name": "Admin Baru",
  "email": "adminbaru@ecotrash.com",
  "password": "password123",
  "phone": "081234567890"
}
```

### C. Aktifkan Akun Admin
Mengaktifkan status keaktifan akun admin.
* **Method:** `PATCH`
* **URL:** `{{base_url}}/api/super-admin/admins/{id}/activate`
* **Headers:** 
  * `Authorization: Bearer <token>`
  * `Accept: application/json`

### D. Nonaktifkan Akun Admin
Menonaktifkan status keaktifan akun admin agar tidak bisa login.
* **Method:** `PATCH`
* **URL:** `{{base_url}}/api/super-admin/admins/{id}/deactivate`
* **Headers:** 
  * `Authorization: Bearer <token>`
  * `Accept: application/json`

### E. Pemberhentian (Hapus) Admin
Menghapus akun admin secara permanen dari sistem.
* **Method:** `DELETE`
* **URL:** `{{base_url}}/api/super-admin/admins/{id}`
* **Headers:** 
  * `Authorization: Bearer <token>`
  * `Accept: application/json`

---

## 2. 🛡️ FITUR ADMIN (Role ID: 2)

Fitur operasional utama dan dashboard untuk Admin (Superadmin juga memiliki akses ke sini).

### A. Dashboard & Statistik

#### 1. Ringkasan Statistik Utama
Mendapatkan KPI utama seperti total pengguna, pesanan, kurir, dan pendapatan.
* **Method:** `GET`
* **URL:** `{{base_url}}/api/admin/dashboard`
* **Headers:** `Authorization: Bearer <token>`, `Accept: application/json`

#### 2. Daftar Pesanan Terbaru
* **Method:** `GET`
* **URL:** `{{base_url}}/api/admin/dashboard/recent-orders`

#### 3. Daftar Penarikan Dana Terbaru
* **Method:** `GET`
* **URL:** `{{base_url}}/api/admin/dashboard/recent-withdrawals`

#### 4. Kurir Terbaik (Berdasarkan Rating)
* **Method:** `GET`
* **URL:** `{{base_url}}/api/admin/dashboard/top-couriers`

#### 5. Seller Terbaik (Berdasarkan Kontribusi)
* **Method:** `GET`
* **URL:** `{{base_url}}/api/admin/dashboard/top-sellers`

### B. Kelola Kurir

#### 1. Lihat Semua Kurir
* **Method:** `GET`
* **URL:** `{{base_url}}/api/admin/couriers`
* **Headers:** `Authorization: Bearer <token>`, `Accept: application/json`

#### 2. Tambah Kurir Baru
Mendaftarkan profil kurir beserta dokumen verifikasinya.
* **Method:** `POST`
* **URL:** `{{base_url}}/api/admin/couriers`
* **Headers:** 
  * `Authorization: Bearer <token>`
  * `Content-Type: multipart/form-data`
  * `Accept: application/json`
* **Body (form-data):**
  * `name` (text): `Kurir Baru`
  * `email` (text): `kurirbaru@ecotrash.com`
  * `password` (text): `password123`
  * `phone` (text): `084444555666`
  * `vehicle_type` (text): `Motor`
  * `vehicle_plate` (text): `D 1234 XYZ`
  * `ktp_number` (text): `3201020304050001`
  * `sim_number` (text): `123456789012`
  * `ktp_photo` (file): *[Upload KTP Image]*
  * `sim_photo` (file): *[Upload SIM Image]*
  * `face_photo` (file): *[Upload Selfie Image]*
  * `address` (text): `Jl. Bojongsoang No. 10`
  * `city` (text): `Bandung`
  * `province` (text): `Jawa Barat`

#### 3. Aktifkan Akun Kurir
* **Method:** `PATCH`
* **URL:** `{{base_url}}/api/admin/couriers/{id}/activate`

#### 4. Nonaktifkan Akun Kurir
* **Method:** `PATCH`
* **URL:** `{{base_url}}/api/admin/couriers/{id}/deactivate`

### C. Kelola Kategori Sampah

#### 1. Tambah Kategori Sampah
* **Method:** `POST`
* **URL:** `{{base_url}}/api/waste-categories`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: application/json`, `Accept: application/json`
* **Body (RAW JSON):**
```json
{
  "name": "Plastik PET",
  "price_per_kg": 4500,
  "description": "Botol air mineral transparan bersih"
}
```

#### 2. Update Kategori Sampah
* **Method:** `PUT`
* **URL:** `{{base_url}}/api/waste-categories/{id}`
* **Body (RAW JSON):**
```json
{
  "name": "Plastik PET Premium",
  "price_per_kg": 5000,
  "description": "Botol air mineral bersih, tanpa label"
}
```

#### 3. Hapus Kategori Sampah
* **Method:** `DELETE`
* **URL:** `{{base_url}}/api/waste-categories/{id}`

### D. Monitoring Pesanan

#### 1. Lihat Seluruh Pesanan di Sistem
* **Method:** `GET`
* **URL:** `{{base_url}}/api/admin/orders`

---

## 3. 🛵 FITUR KURIR (Role ID: 4)

Endpoint operasional bagi mitra kurir penjemput sampah menggunakan aplikasi mobile.

### A. Lokasi & Status Kerja

#### 1. Aktifkan Status Online/Offline
Mengatur apakah kurir siap menerima tugas penjemputan baru.
* **Method:** `PATCH`
* **URL:** `{{base_url}}/api/courier/toggle-online`
* **Headers:** `Authorization: Bearer <token>`, `Accept: application/json`

#### 2. Update Koordinat Lokasi Terkini (Tracking)
* **Method:** `PATCH`
* **URL:** `{{base_url}}/api/courier/location`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: application/json`, `Accept: application/json`
* **Body (RAW JSON):**
```json
{
  "latitude": -6.9744,
  "longitude": 107.6303
}
```

### B. Alur Penjemputan Pesanan (Order Lifecycle)

#### 1. Lihat Daftar Pesanan Tersedia (PENDING)
Mencari pesanan dari seller terdekat yang berstatus PENDING (belum diambil kurir lain).
* **Method:** `GET`
* **URL:** `{{base_url}}/api/courier/orders/available`

#### 2. Terima Pesanan (Accept Order)
* **Method:** `PATCH`
* **URL:** `{{base_url}}/api/orders/{id}/accept`

#### 3. Konfirmasi Sampah Diambil (Upload Foto Penjemputan)
Dilakukan di lokasi seller saat sampah dimuat ke atas kendaraan.
* **Method:** `POST`
* **URL:** `{{base_url}}/api/orders/{id}/pickup`
* **Headers:** 
  * `Authorization: Bearer <token>`
  * `Content-Type: multipart/form-data`
  * `Accept: application/json`
* **Body (form-data):**
  * `pickup_photo` (file): *[Upload Foto Sampah]*

#### 4. Konfirmasi Sampah Tiba di Gudang (Deliver)
Kurir mengantar sampah ke depot/gudang utama EcoTrash.
* **Method:** `PATCH`
* **URL:** `{{base_url}}/api/orders/{id}/deliver`

#### 5. Selesaikan Pesanan (Input Berat & Kalkulasi Uang)
Petugas gudang/kurir menimbang berat aktual dan memicu pembayaran saldo ke dompet seller.
* **Method:** `PATCH`
* **URL:** `{{base_url}}/api/orders/{id}/complete`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: application/json`, `Accept: application/json`
* **Body (RAW JSON):**
```json
{
  "items": [
    {
      "order_item_id": 1,
      "actual_weight": 8.5
    },
    {
      "order_item_id": 2,
      "actual_weight": 4.2
    }
  ]
}
```

### C. Riwayat Ulasan Kurir
Melihat daftar ulasan bintang dan ulasan teks yang ditulis seller untuk kurir ini.
* **Method:** `GET`
* **URL:** `{{base_url}}/api/reviews/my-received`

---

## 4. 🧑‍🌾 FITUR SELLER (Role ID: 3)

Endpoint untuk penjual/mitra seller yang ingin menyetor sampah daur ulang.

### A. Kelola Alamat Penjemputan (CRUD Alamat)

#### 1. Lihat Daftar Alamat
* **Method:** `GET`
* **URL:** `{{base_url}}/api/seller-addresses`

#### 2. Tambah Alamat Baru
* **Method:** `POST`
* **URL:** `{{base_url}}/api/seller-addresses`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: application/json`, `Accept: application/json`
* **Body (RAW JSON):**
```json
{
  "label": "Kantor Cabang",
  "address": "Jl. Ganesha No. 10, Lb. Siliwangi",
  "latitude": -6.8915,
  "longitude": 107.6107
}
```

#### 3. Update Alamat
* **Method:** `PUT`
* **URL:** `{{base_url}}/api/seller-addresses/{id}`
* **Body (RAW JSON):**
```json
{
  "label": "Kantor Utama",
  "address": "Jl. Ganesha No. 12, Lb. Siliwangi",
  "latitude": -6.8916,
  "longitude": 107.6108
}
```

#### 4. Hapus Alamat
* **Method:** `DELETE`
* **URL:** `{{base_url}}/api/seller-addresses/{id}`

### B. Kelola Pesanan Sampah (Order Management)

#### 1. Buat Pesanan Penjemputan Baru
* **Method:** `POST`
* **URL:** `{{base_url}}/api/orders`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: application/json`, `Accept: application/json`
* **Body (RAW JSON):**
```json
{
  "seller_address_id": 1,
  "latitude": -6.8915,
  "longitude": 107.6107,
  "pickup_notes": "Tolong jemput sebelum jam 5 sore.",
  "items": [
    {
      "waste_category_id": 1,
      "estimated_weight": 5.0
    },
    {
      "waste_category_id": 2,
      "estimated_weight": 10.0
    }
  ]
}
```

#### 2. Batalkan Pesanan (Hanya status PENDING)
* **Method:** `PATCH`
* **URL:** `{{base_url}}/api/orders/{id}/cancel`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: application/json`, `Accept: application/json`
* **Body (RAW JSON):**
```json
{
  "cancel_reason": "Salah memasukkan berat perkiraan sampah."
}
```

### C. Berikan Ulasan Ke Kurir
Menulis review untuk kurir setelah pesanan berstatus `COMPLETED`.
* **Method:** `POST`
* **URL:** `{{base_url}}/api/reviews`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: application/json`, `Accept: application/json`
* **Body (RAW JSON):**
```json
{
  "order_id": 1,
  "rating": 5,
  "comment": "Kurirnya ramah dan datang sangat cepat!"
}
```

### D. Dompet & Penarikan Saldo (Wallet & Withdraw)

#### 1. Lihat Informasi & Saldo Dompet
* **Method:** `GET`
* **URL:** `{{base_url}}/api/wallet`

#### 2. Lihat Riwayat Transaksi Keluar/Masuk Dompet
* **Method:** `GET`
* **URL:** `{{base_url}}/api/wallet/transactions`

#### 3. Ajukan Penarikan Dana (Withdrawal)
* **Method:** `POST`
* **URL:** `{{base_url}}/api/withdrawals`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: application/json`, `Accept: application/json`
* **Body (RAW JSON):**
```json
{
  "amount": 50000,
  "bank_name": "BCA",
  "account_name": "John Doe",
  "account_number": "1234567890"
}
```

---

## 5. 🌐 ENDPOINT UMUM (Protected - Semua Role Terautentikasi)

Endpoint umum yang bisa dipanggil oleh semua role pengguna setelah login.

### A. Autentikasi Utama

#### 1. Pendaftaran Akun Baru (Register)
* **Method:** `POST`
* **URL:** `{{base_url}}/api/register`
* **Headers:** `Content-Type: application/json`, `Accept: application/json`
* **Body (RAW JSON):**
```json
{
  "name": "Budi Seller",
  "email": "budiseller@gmail.com",
  "password": "password123",
  "phone": "081234567888",
  "role_id": 3
}
```
*(Gunakan `role_id = 3` untuk Seller, `role_id = 4` untuk Kurir)*

#### 2. Masuk Akun (Login)
Mendapatkan Bearer Token untuk pengujian endpoint lainnya.
* **Method:** `POST`
* **URL:** `{{base_url}}/api/login`
* **Headers:** `Content-Type: application/json`, `Accept: application/json`
* **Body (RAW JSON):**
```json
{
  "email": "seller1@ecotrash.com",
  "password": "password"
}
```

#### 3. Keluar Akun (Logout)
* **Method:** `POST`
* **URL:** `{{base_url}}/api/logout`
* **Headers:** `Authorization: Bearer <token>`, `Accept: application/json`

### B. Kelola Akun & Profile

#### 1. Lihat Data Profil Diri
* **Method:** `GET`
* **URL:** `{{base_url}}/api/profile`

#### 2. Edit Data Profil
* **Method:** `PATCH`
* **URL:** `{{base_url}}/api/profile`
* **Body (RAW JSON):**
```json
{
  "name": "Budi Seller Baru",
  "phone": "081234567999"
}
```

#### 3. Ganti Password Akun
* **Method:** `PATCH`
* **URL:** `{{base_url}}/api/profile/password`
* **Body (RAW JSON):**
```json
{
  "current_password": "password123",
  "new_password": "passwordbaru123",
  "new_password_confirmation": "passwordbaru123"
}
```

### C. Notifikasi Pengguna

#### 1. Lihat Seluruh Notifikasi Diri
* **Method:** `GET`
* **URL:** `{{base_url}}/api/notifications`

#### 2. Tandai Satu Notifikasi Dibaca
* **Method:** `PATCH`
* **URL:** `{{base_url}}/api/notifications/{id}/read`

#### 3. Tandai Semua Notifikasi Dibaca
* **Method:** `PATCH`
* **URL:** `{{base_url}}/api/notifications/read-all`

#### 4. Lihat Jumlah Notifikasi Belum Dibaca
* **Method:** `GET`
* **URL:** `{{base_url}}/api/notifications/unread-count`

### D. Fitur Informasi Pendukung

#### 1. Lihat Semua Kategori Sampah Daur Ulang
* **Method:** `GET`
* **URL:** `{{base_url}}/api/waste-categories`

#### 2. Lihat Detail Kategori Sampah Tertentu
* **Method:** `GET`
* **URL:** `{{base_url}}/api/waste-categories/{id}`

#### 3. Lihat Informasi Peta Pesanan (Rute Penjemputan)
* **Method:** `GET`
* **URL:** `{{base_url}}/api/orders/{id}/map`
