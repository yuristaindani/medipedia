# Architecture Decision Record

## Status

Accepted

## Context

MediPedia adalah aplikasi referensi obat berbasis Flutter yang menggunakan
OpenFDA Drug Labeling API. Fitur utamanya adalah daftar obat, pencarian,
pagination, filter, detail obat, favorit, lokalisasi, dan penanganan data API
yang tidak lengkap.

Aplikasi harus dapat berjalan tanpa kredensial privat serta memiliki pemisahan
yang jelas antara data, domain, dan presentation.

## Decisions

### State Management

Aplikasi menggunakan Cubit dari Flutter Bloc.

- `MedicationCubit` menangani daftar, pencarian, pagination, refresh, filter,
  loading, empty state, dan error state.
- `FavoritesCubit` menangani pemuatan, penambahan, penghapusan, dan status
  favorit.
- `LocaleCubit` menangani bahasa aktif dan perubahan bahasa.

Cubit dipilih karena cukup sederhana untuk cakupan aplikasi ini, mudah diuji,
dan membuat transisi state terlihat jelas. Jika alur bisnis menjadi lebih
kompleks, sebagian Cubit dapat dikembangkan menjadi Bloc atau use case khusus.

### Project Architecture

Proyek dibagi menjadi beberapa lapisan:

- `data`: API OpenFDA, model, data source, service, dan implementasi repository;
- `domain`: entity dan kontrak repository;
- `presentation`: halaman, widget, dan Cubit;
- `core`: konfigurasi umum, exception, theme, dan utilitas;
- `l10n`: resource lokalisasi English dan Indonesia.

Widget tidak mengakses API atau persistence secara langsung. Widget berkomunikasi
dengan Cubit, sedangkan Cubit berkomunikasi dengan repository.

Struktur ini menambah beberapa lapisan dibandingkan pendekatan sederhana, tetapi
membuat tanggung jawab lebih jelas dan mempermudah testing serta pengembangan.

### Dependency Injection

Dependency disalurkan melalui constructor dan `RepositoryProvider`. HTTP client,
data source, repository, Cubit, `SharedPreferences`, dan service penerjemahan
dibuat dari composition root aplikasi.

Pendekatan ini membuat dependency terlihat jelas dan mudah diganti dengan fake
atau mock saat testing. Konsekuensinya, constructor dapat bertambah panjang jika
jumlah dependency meningkat.

### Local Persistence

Favorit dan pilihan bahasa disimpan menggunakan `SharedPreferences`. Favorit
disimpan sebagai JSON string dan dimuat kembali ketika aplikasi dibuka. Entry
favorit yang rusak dilewati agar data lain tetap dapat digunakan.

Pendekatan ini ringan dan cukup untuk data kecil. Jika aplikasi berkembang dengan
data besar, relasi kompleks, atau sinkronisasi akun, persistence dapat dipindahkan
ke database lokal seperti SQLite, Drift, atau Isar dan backend terautentikasi.

### OpenFDA Integration and Error Handling

OpenFDA dipilih sebagai sumber data karena merupakan API publik dan tidak
memerlukan kredensial privat.

Aplikasi menangani kegagalan jaringan, kegagalan server, HTTP 429 rate limit,
response JSON tidak valid, serta field API yang hilang atau nullable. HTTP 429
ditangani dengan retry terbatas dan backoff berdasarkan header `Retry-After`.

Exception jaringan tingkat rendah tidak ditampilkan langsung kepada pengguna.
UI menggunakan pesan error yang sudah dilokalkan.

### Localization and ML Kit

UI mendukung English dan Indonesia menggunakan Flutter localization dan file ARB.

Konten naratif obat, yaitu indikasi, tujuan penggunaan, bahan aktif, dosis, dan
peringatan, diterjemahkan ke bahasa Indonesia menggunakan Google ML Kit
on-device.

Nama merek, nama generik, dan produsen tetap menggunakan nilai asli OpenFDA agar
identitas obat tidak berubah.

Jika terjemahan gagal, teks asli tetap ditampilkan dan aplikasi menampilkan
pesan yang menjelaskan bahwa sebagian konten masih menggunakan bahasa sumber.

ML Kit dipilih karena tidak memerlukan API key atau kredensial cloud. Trade-off-nya
adalah model bahasa perlu tersedia di perangkat dan hasil terjemahan istilah medis
tidak selalu sempurna.

### Testing Strategy

Automated testing mencakup:

- parsing response OpenFDA yang berhasil;
- response error dan data invalid;
- HTTP 429, retry, dan backoff menggunakan mock;
- repository dan local persistence;
- transisi state Cubit;
- widget daftar, detail, favorit, filter, splash, loading, empty, error, dan
  fallback translation.

Test rate limit menggunakan mock atau fake sehingga tidak mengirim permintaan
berlebihan ke API OpenFDA asli. Seluruh test dapat dijalankan dengan
`flutter test`.

## Technical Trade-offs

OpenFDA menyediakan data publik tanpa kredensial, tetapi struktur field dan
kualitas teks label dapat bervariasi. Karena itu, model menggunakan field nullable,
normalisasi teks, dan fallback yang aman.

Pencarian diprioritaskan berdasarkan nama merek, nama generik, produsen, lalu
indikasi. Pendekatan ini meningkatkan relevansi hasil, tetapi pencarian bertingkat
dapat membutuhkan beberapa request API untuk melengkapi satu halaman.

Data tanpa nama utama ditempatkan di bagian belakang halaman yang sedang dimuat.
Data tersebut tidak dihapus sehingga pagination tetap dapat berjalan.

## Pengembangan MediPedia di Dalam Sobat Bunda

Jika MediPedia digabungkan ke dalam aplikasi Sobat Bunda, MediPedia akan
dikembangkan sebagai modul khusus yang dapat diakses melalui navbar Sobat Bunda.

Pada tahap awal, modul MediPedia tetap mempertahankan daftar obat, pencarian,
detail, filter, lokalisasi, dan favorit. Modul ini kemudian dihubungkan dengan
sistem utama Sobat Bunda melalui authentication dan backend bersama.

Pengembangan dilakukan secara bertahap:

1. Memindahkan logika MediPedia menjadi feature module yang terpisah di dalam
   aplikasi Sobat Bunda.
2. Menghubungkan user account Sobat Bunda dengan favorit, riwayat pencarian, dan
   preferensi bahasa.
3. Mengintegrasikan informasi obat dengan fitur `prescriptions` agar pengguna
   dapat melihat penjelasan obat yang berkaitan dengan resepnya.
4. Menghubungkan detail obat dengan `appointments`, `medical records`, dan
   `laboratory results` melalui navigasi atau konteks pasien yang sama.
5. Menggunakan backend terautentikasi untuk data medis agar data tidak hanya
   tersimpan secara lokal.
6. Menambahkan cache dan database lokal untuk mendukung penggunaan offline.
7. Menerapkan role-based access, audit log, API versioning, dan monitoring.

Dengan pendekatan ini, MediPedia tetap menjadi modul dengan batas tanggung jawab
yang jelas, tetapi dapat berbagi authentication, user profile, backend, dan
navigasi dengan fitur lain di Sobat Bunda.

## Future Chatbot

Setelah MediPedia terintegrasi dengan backend Sobat Bunda, chatbot berbasis Gemini
atau GPT dapat ditambahkan sebagai fitur bantuan untuk:

- menjawab pertanyaan umum tentang RSIA Puri Bunda;
- menjelaskan informasi obat berdasarkan data OpenFDA;
- memberikan panduan pertolongan pertama yang disusun dan divalidasi oleh dokter.

API key tidak disimpan di aplikasi Flutter. Aplikasi berkomunikasi dengan backend
Sobat Bunda, sedangkan backend mengelola kredensial, authentication, rate limit,
logging, dan perlindungan data.

Informasi pertolongan pertama harus melalui validasi dokter dan versioning.
Chatbot harus menjelaskan bahwa jawabannya bukan diagnosis atau pengganti
pemeriksaan medis, serta mengarahkan pengguna ke layanan darurat jika kondisi
berisiko.

## Consequences

Keputusan ini menghasilkan aplikasi yang cukup sederhana untuk cakupan tugas,
tetapi tetap memiliki pemisahan tanggung jawab, pengujian, lokalisasi,
persistence, dan error handling yang jelas.

Keterbatasan utama adalah ketergantungan pada kualitas data OpenFDA, kapasitas
`SharedPreferences`, dan akurasi terjemahan ML Kit. Keterbatasan tersebut dapat
ditangani melalui backend, database, authentication, dan layanan medis yang
tervalidasi ketika MediPedia dikembangkan di dalam Sobat Bunda.
