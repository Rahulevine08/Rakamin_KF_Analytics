#LANGKAH UTAMA: Membuat atau memperbarui tabel fisik bernama 'analisa_hasil_aggregasi'
CREATE OR REPLACE TABLE `kimia_farma.analisa_hasil_aggregasi` AS

#Membuat Common Table Expression (CTE) bernama 'kf_joined_data'
#Menggabungkan (JOIN) keempat tabel sumber dan menentukan persentase laba kotor.

WITH kf_joined_data AS (
  SELECT
    #Mengambil data identitas transaksi
    fin_trans.transaction_id,
    fin_trans.date,
    
    #Mengambil data terkait kantor cabang
    fin_trans.branch_id,
    kantor_cabang.branch_name,
    kantor_cabang.kota,
    kantor_cabang.provinsi,
    kantor_cabang.rating AS rating_cabang,              #Mengubah nama kolom 'rating' cabang agar tidak tertukar
    
    #Mengambil data terkait pelanggan dan produk
    fin_trans.customer_name,
    fin_trans.product_id,
    product.product_name,
    
    #Mengambil data finansial dasar
    fin_trans.price AS actual_price,                #Mengaliaskan 'price' dari tabel transaksi menjadi 'actual_price'
    fin_trans.discount_percentage,
    
    #Menentukan persentase laba berdasarkan rentang harga obat (actual_price)
    #Ketentuan ini didasarkan pada aturan bisnis Kimia Farma yang tertera pada lembar Challenge
    CASE
      WHEN fin_trans.price <= 50000 THEN 0.10                                #Harga <= Rp 50.000 -> Laba 10%
      WHEN fin_trans.price > 50000 AND fin_trans.price <= 100000 THEN 0.15   #Harga Rp 50.001 - Rp 100.000 -> Laba 15%
      WHEN fin_trans.price > 100000 AND fin_trans.price <= 300000 THEN 0.20  #Harga Rp 100.001 - Rp 300.000 -> Laba 20%
      WHEN fin_trans.price > 300000 AND fin_trans.price <= 500000 THEN 0.25  #Harga Rp 300.001 - Rp 500.000 -> Laba 25%
      ELSE 0.30                                                              #Harga > Rp 500.000 -> Laba 30%
    END AS persentase_gross_laba,
    
    #Mengambil data performa layanan
    fin_trans.rating AS rating_transaksi            #Mengubah nama kolom 'rating' transaksi agar spesifik
    
  FROM
    `kimia_farma.kf_final_transaction` AS fin_trans
  
  #Menggabungkan dengan tabel cabang menggunakan LEFT JOIN untuk memastikan semua data transaksi tetap ada
  LEFT JOIN
    `kimia_farma.kf_kantor_cabang` AS kantor_cabang 
    ON fin_trans.branch_id = kantor_cabang.branch_id
    
  #Menggabungkan dengan tabel produk untuk mendapatkan informasi nama produk yang terjual
  LEFT JOIN
    `kimia_farma.kf_product` AS product 
    ON fin_trans.product_id = product.product_id
)

#Melakukan Kalkulasi Lanjutan (Nett Sales & Nett Profit)
#Menggunakan data yang sudah bersih dan terstruktur dari CTE 'kf_joined_data'
SELECT
  transaction_id,
  date,
  branch_id,
  branch_name,
  kota,
  provinsi,
  rating_cabang,
  customer_name,
  product_id,
  product_name,
  actual_price,
  discount_percentage,
  persentase_gross_laba,
  
  #Fomula Nett Sales: Menghitung harga jual riil setelah dikurangi nominal diskon
  #Rumus: Harga Asli * (1 - (Persentase Diskon / 100))
  (actual_price * (1 - (discount_percentage / 100))) AS nett_sales,
  
  #Formula Nett Profit: Menghitung keuntungan bersih yang diterima perusahaan
  #Rumus: Nett Sales * Persentase Gross Laba
  ((actual_price * (1 - (discount_percentage / 100))) * persentase_gross_laba) AS nett_profit,
  
  rating_transaksi
FROM
  kf_joined_data;
