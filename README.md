# ✨ Mogi Frontend

[![GitHub language count](https://img.shields.io/github/languages/count/justshev/mogi-frontend)](https://github.com/justshev/mogi-frontend)
[![GitHub stars](https://img.shields.io/github/stars/justshev/mogi-frontend?style=social)](https://github.com/justshev/mogi-frontend)
[![License](https://img.shields.io/github/license/justshev/mogi-frontend)](https://github.com/justshev/mogi-frontend/blob/main/LICENSE)


> Aplikasi frontend Mogi: Dibangun dengan kerangka kerja Flutter. Aplikasi ini menyediakan antarmuka pengguna untuk aplikasi pertanian jamur pintar yang didukung AI, MOGI.  MOGI membantu petani jamur memantau suhu dan kelembapan secara real-time dan memprediksi pertumbuhan jamur secara cerdas.

## ✨ Fitur Utama

* **Pemantauan Suhu dan Kelembapan Real-time:**  Memantau kondisi lingkungan penting di dalam rumah jamur secara real-time melalui sensor IoT terintegrasi.
* **Prediksi Pertumbuhan Jamur:** Menggunakan data lingkungan untuk memprediksi pertumbuhan jamur, membantu petani mengantisipasi hasil panen dan mengoptimalkan proses budidaya.
* **Rekomendasi Budidaya yang Cerdas:** Memberikan saran berdasarkan data dan prediksi untuk membantu petani mengoptimalkan kondisi pertumbuhan jamur.
* **Pelacakan Riwayat Pertumbuhan:** Mencatat dan menyimpan data pertumbuhan jamur dari waktu ke waktu, memungkinkan analisis tren dan perbaikan proses.
* **Akses Real-time melalui Aplikasi Mobile:** Memberikan akses mudah dan nyaman ke data dan rekomendasi kapan saja dan di mana saja.
* **Otentikasi Pengguna:**  Memungkinkan petani untuk masuk dan mengakses data mereka secara aman. (Disimpulkan dari struktur direktori dan nama file, meskipun detail spesifik tidak tersedia dalam analisis.)
* **Antarmuka Pengguna yang Intuitif:**  Menyediakan tampilan yang mudah dipahami dari data dan rekomendasi yang relevan untuk petani. (Disimpulkan dari penggunaan kerangka kerja Flutter.)


## 🛠️ Tumpukan Teknologi

| Kategori         | Teknologi | Catatan                                      |
|-----------------|------------|----------------------------------------------|
| Bahasa Pemrograman | Dart       | Digunakan untuk pengembangan aplikasi Flutter |
| Kerangka Kerja    | Flutter    | Untuk membangun antarmuka pengguna mobile       |


## 🏛️ Tinjauan Arsitektur

Arsitektur aplikasi ini didasarkan pada kerangka kerja Flutter, yang memungkinkan pengembangan aplikasi lintas platform (Android dan iOS).  Aplikasi ini dibagi ke dalam beberapa modul, termasuk halaman utama (home_page.dart), halaman profil (profile_page.dart), halaman eksplorasi (explore_page.dart), dan halaman login/registrasi (login_page.dart, registerEmail_page.dart).  Logika bisnis dikelola melalui layanan (services) dan model data (models).  Widget khusus dibuat untuk menampilkan data dengan cara yang visual dan mudah dipahami.

## 🚀 Memulai

1. Pastikan Anda telah menginstal Flutter dan mengatur lingkungan pengembangan Anda.
2. Kloning repositori:
   ```bash
   git clone https://github.com/justshev/mogi-frontend.git
   ```
3. Navigasi ke direktori proyek:
   ```bash
   cd mogi-frontend
   ```
4. Instal dependensi: (Catatan: Analisis menunjukan `npm` namun repositori menggunakan Flutter, sehingga perintah berikut lebih tepat)
   ```bash
   flutter pub get
   ```
5. Jalankan aplikasi:
   ```bash
   flutter run
   ```


## 📂 Struktur File

```
/
├── .gitignore
├── .metadata
├── README.md
├── analysis_options.yaml
├── android/
├── ios/
├── lib/               // Berisi kode sumber utama aplikasi Flutter.
│   ├── main.dart      // Titik masuk utama aplikasi.
│   ├── models/        // Mendefinisikan model data.
│   ├── pages/         // Mendefinisikan halaman-halaman aplikasi.
│   ├── services/      // Mendefinisikan layanan-layanan aplikasi.
│   ├── widgets/       // Mendefinisikan widget-widget kustom.
│   └── ...
├── linux/
├── macos/
├── pubspec.lock
├── pubspec.yaml
├── test/
├── web/
└── windows/
```

* **android/, ios/, linux/, macos/, web/, windows/:** Direktori-direktori ini berisi kode dan aset yang dibutuhkan untuk menjalankan aplikasi pada platform masing-masing.
* **lib/:** Direktori ini berisi kode sumber Dart utama aplikasi Flutter.
* **test/:** Direktori ini berisi uji unit untuk aplikasi.
