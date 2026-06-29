# Audit Backend-Frontend-Seeder Alignment

**Status**: ⚠️ CRITICAL INCONSISTENCIES FOUND  
**Date**: 30 May 2026

---

## 1. RATING ISSUE - 🔴 CRITICAL

### Problem
Rating ditampilkan di web tetapi **tidak didukung oleh review data di seeder**.

### Current State

**Backend Logic** (ReviewController.php):
- Rating hanya bisa dibuat oleh **seller** (role_id = 3)
- Rating hanya bisa dibuat untuk order dengan status `COMPLETED`
- Ketika review dibuat, rata-rata rating dihitung dari semua review courier itu
- Formula: `$avgRating = Review::where('courier_id', $id)->avg('rating')`
- Rating diupdate ke `courier_profile.rating`

**Seeder State** (DemoDataSeeder.php):
- ❌ **Tidak ada seeding untuk tabel `reviews`**
- Rating hardcoded langsung di `CourierProfile` (5.0, 0.0, 4.0, dll)
- Tidak ada hubungan dengan `Review` model
- Tabel `reviews` kosong di database

**Frontend Display** (couriers/index.blade.php):
- ✅ Menampilkan `rating` dari `CourierProfile`
- ✅ Menampilkan data dengan benar

### Konsekuensi
- Saat user (seller) membuat review via API, rating akan berubah ke nilai actual
- Rating di seeder hardcoded **bukan dari real reviews**
- Tidak ada demo data review untuk testing di web
- **Sinkronisasi rusak**: seeder hardcode vs. API logic

### Solusi
Seeder perlu membuat sample `Review` records:
```php
// Untuk courier 1-2: buat 3-4 review dengan rating 5.0
// Untuk courier 3: buat 2 review dengan rating 4.0 dan 4.0
// Untuk courier lain: tidak ada review (rating = 0)
```

---

## 2. PERFORMANCE SCORE ISSUE - 🟡 CRITICAL

### Problem
`performance_score` di seeder tidak sesuai dengan backend logic.

### Current State

**Backend Logic** (ReviewController.php):
```php
$completedOrders = Order::where('courier_id', $id)
    ->where('status', 'COMPLETED')
    ->count();
$courierProfile->update([
    'performance_score' => $completedOrders * 10
]);
```
- Performance score = **jumlah completed orders × 10**
- Diupdate otomatis ketika ada review baru (order COMPLETED)

**Seeder State**:
- Hardcoded `performance_score`: 20.0, 0.0, 10.0, dll
- Tidak berdasarkan jumlah completed orders

**Frontend Display** (sebelumnya):
- ❌ Menampilkan `performance_score` (sudah diubah ke `totalWasteCollected`)
- Sekarang: Total sampah diambil (kg) - **ini lebih baik dari performance_score**

### Konsekuensi
- Seeder `performance_score` tidak match dengan backend formula
- Saat order COMPLETED dan review dibuat, nilai akan berubah
- Data di seeder **tidak konsisten dengan logic**

### Solusi
Perlu update seeder untuk:
1. Membuat orders dengan status COMPLETED untuk setiap courier
2. Seeder otomatis menghitung `performance_score = completed_order_count * 10`
3. Atau import Review model dan seeder reviews terlebih dahulu

---

## 3. REVIEW SEEDER MISSING - 🔴 CRITICAL

### Problem
Tidak ada `ReviewSeeder` di database seeders.

### Current State
```php
// DemoDataSeeder.php hanya seed:
- seedSellerAddresses()
- seedWallets()
- seedCourierProfiles()  ← rating hardcoded
- seedOrders()           ← 20 orders, 4 completed, 4 delivered
- seedWithdrawals()
```

**Missing**: Review seeding

### Expected State
Seharusnya ada:
1. Review records untuk courier yang memiliki completed orders
2. Setiap completed order dari seller harus bisa dihubungkan dengan review

### Solusi
Buat method `seedReviews()` yang:
- Loop setiap order dengan status COMPLETED
- Untuk 4 order COMPLETED, buat 3 review (seller kadang tidak review)
- Review rating: 5, 5, 4 (untuk courier 1), 4, 4 (untuk courier 3), dll

---

## 4. TOTAL WASTE COLLECTED - ✅ GOOD

### Status: IMPLEMENTED CORRECTLY

**Backend Logic**:
- Dihitung dari sum `actual_total_weight` orders dengan status PICKED_UP, DELIVERED, COMPLETED
- Seeder: ada 4 order PICKED_UP, 4 DELIVERED, 4 COMPLETED per batch

**Frontend**:
- Sekarang menampilkan dengan benar: `totalWasteCollected()` method di CourierProfile
- Format: "28.00 kg"
- ✅ Sudah selaras

---

## 5. NOTIFICATIONS - 🟢 AVAILABLE BUT NOT DISPLAYED

### Backend State
- ✅ Model `Notification` exists
- ✅ Table `notifications` exists
- ✅ NotificationController exists dengan 4 endpoints:
  - GET `/api/notifications` (list user notifications)
  - POST `/api/notifications/{id}/read` (mark as read)
  - POST `/api/notifications/read-all` (mark all as read)
  - GET `/api/notifications/unread-count` (count unread)
- ✅ Notifications dibuat di OrderController saat:
  - Order pickup photo uploaded
  - Order status berubah (ACCEPTED, PICKED_UP, DELIVERED, COMPLETED, CANCELLED)

**Seeder State**:
- ❌ Tidak ada notifikasi di seeder
- Seeding tidak membuat notifikasi sample

**Frontend State**:
- ❌ Tidak ada tampilan notifikasi di web

### Apakah Perlu di Web?
**Rekomendasi**: 
- Opsional untuk web (admin dashboard)
- **Prioritas**: Flutter app (seller & courier) yang lebih butuh notifikasi real-time
- Jika mau di web: bisa tambah bell icon di topbar dengan dropdown notifikasi

---

## 6. BACKEND RESOURCES NOT USED IN WEB - 🟡 INFO

### Available API Endpoints (untuk Flutter) tapi tidak dipakai di web:

#### Courier Related
- `GET /api/couriers` - list couriers
- `GET /api/couriers/{id}` - courier detail
- `PUT /api/couriers/{id}` - update courier profile
- `GET /api/couriers/{id}/reviews` - courier reviews

#### Seller Related
- `GET /api/sellers/{id}/reviews` - seller received reviews
- `POST /api/reviews` - create review

#### Order API
- `POST /api/orders` - create order (seller)
- `GET /api/orders` - list orders
- `POST /api/orders/{id}/pickup-photo` - upload pickup photo
- `POST /api/orders/{id}/accept` - accept order (courier)
- `POST /api/orders/{id}/complete` - complete order
- `POST /api/orders/{id}/cancel` - cancel order

#### Wallet & Withdrawal
- `GET /api/wallet` - seller wallet balance
- `GET /api/wallet/transactions` - transaction history
- `POST /api/withdrawals` - request withdrawal

### Reason
Web adalah **admin dashboard**, tidak untuk seller/courier operations.
Seller & courier operations akan di **Flutter app**.

---

## 7. SEEDER DATA SUMMARY

| Table | Records | Issues |
|-------|---------|--------|
| `users` | 6 sellers + 6 couriers | ✅ OK |
| `courier_profiles` | 6 | ⚠️ Rating hardcoded, no Review data |
| `orders` | 20 | ✅ OK (4 COMPLETED, 4 DELIVERED, 4 PICKED_UP) |
| `order_items` | ~50 | ✅ OK |
| `reviews` | 0 | 🔴 MISSING |
| `notifications` | 0 | 🔴 NOT SEEDED |
| `wallets` | 5 | ✅ OK |
| `withdrawals` | 5 | ✅ OK |
| `seller_addresses` | 5 | ✅ OK |

---

## 8. RECOMMENDED ACTIONS

### Priority 1 (High - Fix Now)
- [ ] Create `seedReviews()` method in DemoDataSeeder
  - Generate 8-10 reviews untuk COMPLETED orders
  - Rating: 5 (courier 1), 4 (courier 3), 0 (lainnya)
  - This will populate rating correctly via ReviewController logic

### Priority 2 (Medium - Enhancement)
- [ ] Add demo notifications in seeder (optional)
- [ ] Consider adding notification bell + dropdown in web topbar
- [ ] Add review history view in courier detail page (web)

### Priority 3 (Low - Documentation)
- [ ] Document API endpoints mapping
- [ ] Clarify web vs. Flutter responsibility
- [ ] Add comments in DemoDataSeeder about relationships

---

## 9. CONCLUSION

### Current State Assessment
```
Backend Logic:    ✅ Complete & Correct
Frontend Web:     ✅ Displaying correctly (after recent changes)
Seeder Data:      ⚠️ Incomplete (missing Reviews, inconsistent ratings)
Data Alignment:   🔴 Not fully aligned (hardcoded vs. calculated values)
```

### Key Insight
**The core issue**: Rating adalah **derived value** (calculated from reviews) tetapi seeder **hardcoding** nilai bukan dari reviews.

Solusi: Seeding reviews terlebih dahulu, maka rating akan otomatis calculated dengan benar.

