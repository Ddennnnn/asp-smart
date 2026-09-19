# ASP Smart Cell

Sistem operasi counter multi-cabang untuk POS aksesori dan jasa, pulsa/produk digital, tarik tunai, transfer pelanggan, rekening, kasir, stok, hutang/piutang, wallet pelanggan, rekonsiliasi, laporan, serta website profil. Backend memakai Laravel 13 dan frontend memakai React/Vite pada folder `frontEnd_asp_smart`.

## Menjalankan aplikasi

Prasyarat: PHP 8.3+, Composer, Node.js/NPM, serta MySQL/MariaDB XAMPP aktif. Database operasional yang dipakai adalah `asp_smartDb`.

1. Salin `.env.example` menjadi `.env` bila belum ada, lalu isi `APP_KEY` dan kredensial database. Konfigurasi pengembangan memakai `127.0.0.1`, database `asp_smartDb`, user `root`, dan password kosong.
2. Jalankan `composer install`, kemudian `php artisan migrate` dan `php artisan db:seed`. Seeder hanya diizinkan pada environment `local` atau `testing`; ia tidak menghapus data yang ada.
3. Jalankan backend dengan `php artisan serve --host=127.0.0.1 --port=8000`.
4. Pada terminal lain, jalankan `npm run dev` dari root project. Perintah ini meneruskan proses ke `frontEnd_asp_smart` dan membuka frontend di `http://127.0.0.1:5173`.

Untuk build produksi frontend gunakan `npm run build`. Konfigurasi proxy Vite meneruskan `/api`, `/sanctum`, dan `/storage` ke backend lokal. Untuk deployment, build `frontEnd_asp_smart` dan sajikan hasilnya dari web server yang sama atau atur `VITE_API_URL`, CORS, cookie domain, dan `FRONTEND_URL` sesuai domain produksi.

## Akun pengembangan

| Email | Password | Role |
| --- | --- | --- |
| owner@aspsmart.local | Owner123! | OWNER |
| admin@aspsmart.local | Admin123! | ADMIN |
| cashier@aspsmart.local | Cashier123! | CASHIER |

Ganti seluruh akun contoh sebelum aplikasi dapat diakses pihak lain.

## Arsitektur dan data

Laravel menyajikan API berbasis cookie Sanctum; React menyimpan sesi di memori dan memakai TanStack Query untuk data server. Semua transaksi bisnis memakai tabel `transactions` yang sama, dengan `transaction_items` untuk detail barang, `account_transactions` sebagai ledger saldo, dan `stock_movements` untuk mutasi stok. Saldo rekening hanya berubah melalui `LedgerService`, dengan penguncian baris, aritmetika desimal BCMath, dan pencatatan saldo sebelum/sesudah. Operasi stok memakai pola yang sama melalui `InventoryService`.

Migrasi membentuk tabel cabang, role, pengguna dan penempatan cabang; pelanggan/supplier; rekening dan akun provider; produk fisik/digital, harga cabang/grup, stok; shift kasir; transaksi dan persetujuan; ledger; rekonsiliasi; stock transfer/opname; wallet; penutupan harian; pengaturan/website; dan audit/login log. Migrations tidak menjalankan `migrate:fresh` pada database operasional.

Layanan inti berada di `app/Services`: transaksi, ledger, persediaan, persetujuan, shift kasir, penomoran aman bersamaan, harga, wallet, rekonsiliasi, transfer stok, stock opname, laporan utama, dan katalog laporan. Route API dapat diperiksa dengan `php artisan route:list --path=api`.

## Fitur yang telah diimplementasikan

- POS penjualan dan pembelian dengan stok, harga dari server, pembayaran, kembalian, piutang/hutang, retur pembelian penuh, reversal, serta struk 58 mm, 80 mm, atau A4/PDF.
- Tarik tunai, transfer pelanggan, transfer internal rekening, pendapatan/pengeluaran, penyesuaian saldo dan stok dengan pemeriksaan permission dan approval.
- Produk digital melalui provider mock pada environment local/testing. Nomor tujuan berakhiran `0000` mensimulasikan kegagalan tanpa membukukan saldo.
- Multi-cabang, rekening kas/bank/e-wallet/provider, wallet pelanggan sebagai kewajiban, transfer stok bertahap, stock opname dengan proteksi snapshot basi, shift kasir, rekonsiliasi tanpa koreksi saldo tersembunyi, dan penutupan harian.
- 21 dataset laporan operasional, filter cabang/periode, ekspor XLSX melalui OpenSpout dan PDF melalui Dompdf. Laporan PDF dibatasi 2.000 baris.
- Role granular yang dapat diubah, pembatasan cabang, akun rekening terenkripsi dan dimask, endpoint buka nomor rekening yang diaudit/no-cache, audit trail, idempotency key, rate limit login/API, validasi server, dan reset password.
- Website profil responsif dengan profil usaha, logo unggahan, tema, SEO, bagian konten, cabang, galeri, testimoni, dan promo yang dikelola dari aplikasi.

## Verifikasi

`php artisan test` memakai database terpisah `asp_smart_testing` melalui `phpunit.xml`. Tes menolak berjalan bila nama database test berubah. Cakupan meliputi otentikasi/role, transaksi dan rollback, ledger, stok, provider mock, wallet, hutang/piutang, approval, rekonsiliasi, laporan/ekspor/PDF, masking rekening, audit, dan dua penulis proses bersamaan.

```text
php artisan test
npm run lint
npm run build
npm run test:e2e
php artisan counter:verify-ledger
```

`test:e2e` dijalankan dari root dan memakai browser Chrome terpasang dengan backend/frontend lokal aktif. Ia memeriksa login, POS, reversal, form rekening, izin kasir, halaman inti pada lebar 375–1440 px, dan overflow horizontal.

## Batasan yang perlu diketahui

- Provider produksi (Digiflazz/PPOB), webhook, retry queue, sinkronisasi saldo/katalog, dan kredensial live belum dihubungkan. Provider mock sengaja dibatasi untuk `local`/`testing`.
- Pembelian langsung diterima; belum ada purchase order, penerimaan parsial, serial/IMEI, material jasa, pengembalian parsial, pertukaran barang, diskon/pajak item, atau pembayaran campuran.
- Transfer internal melalui transaksi langsung; alur persetujuan/pengiriman/penerimaan bertahap tersedia khusus transfer stok.
- Kamera pemindai barcode/QR, notifikasi kanal eksternal, unggahan dokumen transaksi, dan pencetakan ke perangkat fisik belum diuji. Cetak browser dan PDF telah tersedia.
- Konfigurasi security rate limit dan password policy masih berbasis nilai aplikasi, bukan panel pengaturan. Sebelum produksi, gunakan HTTPS, SMTP/queue nyata, backup database, secrets provider yang aman, dan role/akun operasional yang tidak memakai kredensial contoh.
