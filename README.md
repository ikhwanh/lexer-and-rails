# Lexer and Rails

Ini hanyalah tokenizer dan parser sederhana yang menerima inputan syntax. Lalu dengan dipanggil fungsi yang sesuai. Menggunakan rails walau hanya sedikit. Misal dilakukan input syntax *daftar nasi goreng harga 10000 es teh harga 2000 tambah nasi goreng jumlah 1 es teh jumlah 2 uang 50000* maka akan dilakukan:

1. insert data produk nasi goreng dengan harga 10000 dan es teh dengan harga 2000 kedalam database
2. cari dalam database nasi goreng dan es teh kedalam keranjang dengan kuantitas 1 dan 2 secara urut
3. hitung kembalian jika uang 50000
4. menampilkan output kembalian 36000

Kode lengkap disimpan di *app/utils/lexer.rb*

## Test
    rails test test/lex_test.rb test/controllers/home_controller_test.rb
