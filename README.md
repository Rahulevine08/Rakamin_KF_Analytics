# Kimia Farma Big Data Analytics Project-Based Internship
Final Task Big Data Analytics Kimia Farma x Rakamin Academy untuk menganalisis performa bisnis tahun 2020-2023

Repositori ini berisi dokumentasi proses data analytics dan sintaks SQL yang digunakan dalam proyek evaluasi kinerja bisnis Kimia Farma untuk periode tahun 2020 hingga 2023. Proyek ini merupakan bagian dari program **Project-Based Internship** bersama **Rakamin Academy**.

---

## 🚀 Gambaran Proyek
Tujuan utama proyek ini adalah mentransformasi data mentah dari berbagai tabel operasional Kimia Farma menjadi satu **Tabel Analisa** terintegrasi, yang kemudian akan digunakan sebagai sumber data utama (*single source of truth*) dalam pembuatan *dashboard interaktif* di Google Looker Studio.

## 📁 Dataset & Skema
Proyek ini mengintegrasikan 4 dataset utama yang diimpor ke Google BigQuery:
1. `kf_final_transaction`: Data transaksi penjualan riil.
2. `kf_kantor_cabang`: Data informasi lokasi dan rating kantor cabang.
3. `kf_product`: Data detail produk obat beserta harganya.
4. `kf_inventory`: Data ketersediaan stok produk di tiap cabang.

---

## ⚙️ Langkah Penyelesaian & Logika Bisnis

### 1. Impor Data ke Google BigQuery
* Mengunggah ke-4 file berformat `.csv` menjadi tabel fisik di BigQuery tanpa ekstensi nama file.
* Mengaktifkan fitur *Auto-detect schema* dengan penyesuaian tipe data tanggal ke tipe `DATE`/`TIMESTAMP`.

### 2. Aturan Perhitungan Persentase Laba (`persentase_gross_laba`)
Persentase keuntungan bersih ditentukan berdasarkan nilai harga produk (`price`):
* Harga $\le$ Rp 50.000 $\rightarrow$ Laba 10%
* Harga > Rp 50.000 s.d Rp 100.000 $\rightarrow$ Laba 15%
* Harga > Rp 100.000 s.d Rp 300.000 $\rightarrow$ Laba 20%
* Harga > Rp 300.000 s.d Rp 500.000 $\rightarrow$ Laba 25%
* Harga > Rp 500.000 $\rightarrow$ Laba 30%

### 3. Rumus Kalkulasi Finansial
* **Nett Sales** (Harga Setelah Diskon):
  $$\text{Nett Sales} = \text{Actual Price} \times \left(1 - \frac{\text{Discount Percentage}}{100}\right)$$
* **Nett Profit** (Keuntungan Bersih):
  $$\text{Nett Profit} = \text{Nett Sales} \times \text{Persentase Gross Laba}$$

---

## 💻 Cara Menjalankan Script SQL
1. Masuk ke konsol [Google BigQuery](https://console.cloud.google.com/bigquery).
2. Buat dataset baru bernama `kimia_farma`.
3. Buka tab query baru, lalu salin seluruh kode dari file `tabel_analisa.sql` yang ada di repositori ini.
4. Ganti placeholder `nama_project_anda.nama_dataset_anda` dengan ID proyek GCP Anda sendiri.
5. Klik **Run**. Tabel hasil analisa siap dihubungkan ke Looker Studio.
