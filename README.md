# 🗺️ Peta Waktu: Media Pembelajaran Geografi & Sejarah Indonesia

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

**Peta Waktu** adalah aplikasi pembelajaran interaktif yang menggabungkan dimensi spasial (Peta Geografi) dan temporal (Garis Waktu Sejarah) untuk memvisualisasikan peristiwa penting dalam sejarah kemerdekaan Indonesia.

> *"Belajar sejarah bukan hanya menghafal tahun, tapi memahami di mana dan kapan peristiwa itu terjadi."*

---

## 📱 Fitur Unggulan

* **Interactive Time-Map:** Peta yang berubah secara dinamis mengikuti *slider* waktu (tahun kejadian).
* **Visualisasi Sejarah:** Marker lokasi peristiwa penting (misal: Rengasdengklok, Pegangsaan Timur) yang terintegrasi dengan materi sejarah.
* **Kuis Edukatif:** Evaluasi pemahaman siswa dengan sistem skor.
* **Media Gallery:** Koleksi foto tokoh dan dokumen sejarah (menggunakan caching untuk performa).

## 🛠️ Tech Stack (Teknologi)

Aplikasi ini dibangun dengan standar *modern mobile development*:

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Backend & Database:** [Firebase](https://firebase.google.com/) (Firestore NoSQL, Auth)
* **Architecture:** MVVM (Model-View-ViewModel) *[Sesuaikan jika Anda pakai yang lain]*
* **AI Integration:** Groq API (untuk fitur asisten cerdas/generasi konten).
* **Environment Management:** `flutter_dotenv` untuk keamanan API Key.

---

## 🚀 Cara Menjalankan (Installation)

Karena alasan keamanan, file sensitif tidak disertakan dalam repository ini. Ikuti langkah berikut untuk menjalankan aplikasi di lokal:

### 1. Clone Repository
```bash
git clone [https://github.com/wirashauma/peta-waktu-app.git](https://github.com/wirashauma/peta-waktu-app.git)
cd peta-waktu-app
