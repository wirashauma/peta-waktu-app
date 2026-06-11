# 🗺️ Peta Waktu: Media Pembelajaran Sejarah & Geografi Indonesia

[![Flutter](https://img.shields.io/badge/Flutter-v3.22+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-v3.4+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Groq AI](https://img.shields.io/badge/Groq%20AI-Llama%203.3-orange?style=for-the-badge&logo=probot&logoColor=white)](https://groq.com/)

**Peta Waktu** adalah aplikasi mobile berbasis Flutter yang dikembangkan sebagai media pembelajaran interaktif sejarah Indonesia. Aplikasi ini menggabungkan visualisasi lokasi geografis peristiwa bersejarah (**Peta**) dengan periodisasi kejadian (**Garis Waktu**) untuk mempermudah pemahaman kronologis peristiwa sejarah di Indonesia.

---

## 🛠️ Tech Stack (Teknologi yang Digunakan)

Aplikasi **Peta Waktu** dibangun menggunakan teknologi modern pengembangan mobile:

1.  **Frontend & SDK:**
    *   **Flutter (Dart SDK `^3.4.0`):** Sebagai kerangka kerja lintas platform untuk performa UI yang mulus dan responsif.
    *   **Google Fonts (Poppins):** Untuk tipografi antarmuka yang rapi dan profesional.
2.  **Backend & Database (Firebase):**
    *   **Firebase Authentication:** Menangani manajemen sesi masuk, pendaftaran, dan login sosial.
    *   **Cloud Firestore:** Database NoSQL untuk menyimpan data profil pengguna, daftar kuis, riwayat nilai kuis, dan data peristiwa sejarah secara *real-time*.
3.  **Integrasi AI (Artificial Intelligence):**
    *   **Groq API (Model: `llama-3.3-70b-versatile`):** Digunakan untuk fitur pembuatan soal kuis otomatis bagi Guru hanya dengan mengetikkan topik sejarah tertentu.
4.  **Layanan Pihak Ketiga & Library:**
    *   `google_sign_in`: Autentikasi sekali klik menggunakan Akun Google.
    *   `flutter_facebook_auth`: Alternatif login sosial menggunakan Facebook.
    *   `cloudinary_public` & `image_picker`: Digunakan untuk pengambilan dan penyimpanan berkas gambar profil ke cloud.
    *   `flutter_dotenv`: Memuat konfigurasi kunci API secara aman dari berkas `.env`.
    *   `http`: Menangani request HTTP eksternal ke API Groq.

---

## 👥 Manajemen Pengguna & Hak Akses (Role-Based Access)

Aplikasi ini mengimplementasikan **Role-Based Access Control (RBAC)** dengan 3 jenis peran pengguna:

1.  **Siswa (User / Student):** Berfokus pada pembelajaran mandiri melalui peta sejarah dan pengerjaan kuis evaluasi.
2.  **Guru (Teacher):** Memiliki wewenang untuk menambahkan materi peta sejarah serta merancang kuis evaluasi (baik manual maupun dengan bantuan kecerdasan buatan).
3.  **Admin:** Pengawas sistem yang bertugas mengelola daftar pengguna dan menyesuaikan peran (*role*) mereka.

---

## 📱 Fitur-Fitur Utama

### 1. Modul Autentikasi Pintar
*   **Login & Registrasi Manual:** Masuk menggunakan Email dan Password yang tervalidasi.
*   **Masuk Cepat (Quick Login):** Fitur khusus testing yang memungkinkan masuk instan sebagai Admin, Guru, atau Siswa. Jika akun pengujian belum terdaftar di Firebase, sistem akan membuatkannya otomatis (*auto-seed*).
*   **Google Sign-In:** Login cepat dan otomatis menyimpan data pengguna baru ke database Firestore.

### 2. Peta Waktu Interaktif (Interactive Time-Map) - *Siswa & Guru*
*   **Filter Periode Tahun:** Menyaring peristiwa sejarah berdasarkan periode waktu (era `< 500 M`, `< 1000 M`, `< 1500 M`, `< 1700 M`, dan `< 2000 M`).
*   **Peta Interaktif Indonesia:** Menampilkan penanda lokasi (*pin*) peristiwa penting pada peta geografis Indonesia.
*   **Panel Detail Peristiwa:** Menampilkan detail cerita, nama lokasi, dan ringkasan peristiwa sejarah ketika pin di peta diketuk.

### 3. Modul Kuis Interaktif (Interactive Quiz Module) - *Siswa*
*   **Daftar Kuis:** Menampilkan daftar kuis aktif yang siap dikerjakan siswa.
*   **Sesi Bermain Kuis:**
    *   Soal pilihan ganda yang disajikan secara terstruktur.
    *   **Countdown Timer:** Batas waktu dinamis untuk setiap soal (misal: 30 detik) dilengkapi dengan bilah progress visual.
    *   **PopScope Guard:** Mencegah siswa keluar dari kuis secara tidak sengaja sebelum kuis selesai.
    *   **Auto-Timeout:** Jika waktu habis, sistem otomatis mengisi dengan jawaban kosong (-1) dan lanjut ke soal berikutnya.
*   **Hasil & Skor Kuis:** Menampilkan persentase skor akhir kuis, rangkuman jawaban benar/salah, penjelasan detail (*explanation*) untuk tiap pertanyaan, dan menyimpan hasil kuis ke Firestore.

### 4. Konsol Manajemen Guru (Teacher Console)
*   **Manajemen Peristiwa Sejarah:** Menambahkan pin baru atau mengedit detail peristiwa sejarah langsung dari dashboard peta.
*   **Pembuat Kuis (Quiz Creator):** Membuat 10 soal kuis pilihan ganda secara manual (berisi pertanyaan, pilihan A-D, indeks kunci jawaban, pembahasan, dan timer).
*   **AI Spark (Generator Soal Otomatis):** Integrasi asisten Groq AI untuk menghasilkan 10 soal kuis beserta pilihan jawaban dan pembahasannya secara instan hanya dengan memasukkan topik kuis.
*   **Papan Peringkat (Leaderboard):** Memantau skor tertinggi dan perkembangan siswa yang telah menyelesaikan kuis.

### 5. Konsol Admin (Admin Console)
*   **Manajemen Pengguna:** Menampilkan daftar lengkap semua pengguna terdaftar beserta informasi NISN dan email mereka.
*   **Ubah Peran (Edit Role):** Mengubah peran pengguna (misalnya menaikkan status Siswa menjadi Guru atau Admin).

### 6. Profil & Pengaturan Pengguna
*   **Edit Profil:** Memperbarui data diri seperti Nama Lengkap, Username, dan NISN.
*   **Ubah Kata Sandi:** Fitur keamanan untuk memperbarui kata sandi akun secara berkala.
*   **Riwayat Kuis:** Siswa dapat melihat daftar nilai dari kuis-kuis yang telah mereka kerjakan sebelumnya.
*   **Menu FAQ:** Menyajikan tanya jawab umum seputar penggunaan aplikasi.

---

## 📂 Struktur Folder Utama (Proyek)

```text
lib/
├── features/
│   ├── admin/         # Fitur administrasi pengguna (List & Edit Role)
│   ├── auth/          # Layanan masuk, registrasi, model user, & splash
│   ├── core/          # Layanan bersama (Firebase gate, Groq AI, konstanta peta)
│   ├── dashboard/     # Peta sejarah interaktif & year filter bar
│   ├── profile/       # Pengaturan akun, ganti password, riwayat, faq
│   └── quiz/          # Modul kuis untuk Guru (membuat/AI) dan Siswa (bermain/skor)
└── main.dart          # Titik masuk utama aplikasi (inisialisasi Firebase & Tema Teal)
```
