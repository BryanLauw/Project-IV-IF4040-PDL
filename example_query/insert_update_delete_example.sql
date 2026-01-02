-- insert patient
insert into pasien (nama, tanggallahir, jeniskelamin, alamat) values ('Pasien test', '2000-11-01', 'L', 'Jl. Cisitu Lama');

-- RAWAT INAP
-- insert rawat inap
select InsertRawatInap(101, 'ICU', 'Penyakit test', 'Dokter test', '2026-02-01 07:00:00');

-- ubah detail rawat inap
select InsertRawatInap(101, 'ICU 2', 'Penyakit test', 'Dokter test', '2026-02-01 08:00:00');

-- perbaikan terhadap data rawat inap
select UpdateRawatInap(101, 'ICU 2', 'Ralat penyakit', 'Dokter test');

-- hapus data rawat inap
select DeleteRawatInap(101, '2026-02-03 07:00:00');

-- TANDA VITAL
-- insert tanda vital
select InsertTandaVital(256, 36.45, 110, 70, 82, 17, 93, '2026-02-01 07:00:00');

-- insert tanda vital baru
select InsertTandaVital(256, 37.00, 115, 75, 81, 18, 95, '2026-02-01 10:00:00');

-- perbaikan terhadap data tanda vital terakhir
select updatetandavital(256, 37.00, 118, 75, 81, 18, 95);

-- hapus data tanda vital
select deletetandavital(256, '2026-02-01 13:00:00');