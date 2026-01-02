-- 1. Changed
-- Dokter ingin tahu apakah kondisi oksigen (SPO2) pasien stabil atau naik-turun selama shift malam (22:00 - 06:00). 
-- Jika hasil FALSE, berarti pasien sangat stabil (nilai konstan). Jika TRUE, perlu dicek fluktuasinya.
-- Contoh 1
SELECT 
    p.Nama,
    r.IDRawatInap,
    temporal_changed(
        'tandavital', 'idrawatinap', r.IDRawatInap, 'spo2',
        '2024-07-05 00:00:00', '2024-07-05 23:59:59'
    ) AS status_spo2_berubah
FROM Pasien p
JOIN RawatInap r ON p.IDPasien = r.IDPasien
WHERE r.IDRawatInap = 220;

-- Contoh 2
SELECT 
    p.Nama,
    r.IDRawatInap,
    temporal_changed(
        'tandavital', 'idrawatinap', r.IDRawatInap, 'spo2',
        '2024-06-21 00:00:00', '2024-06-21 23:59:59'
    ) AS status_spo2_berubah
FROM Pasien p
JOIN RawatInap r ON p.IDPasien = r.IDPasien
WHERE r.IDRawatInap = 220;

-- 2. Trend
-- Perawat ingin mencari daftar pasien yang suhu tubuhnya (Temperature) menunjukkan tren TURUN (DECREASING).
-- Contoh 1
SELECT 
    p.Nama,
    r.IDRawatInap,
    temporal_trend(
        'tandavital', 'idrawatinap', r.IDRawatInap, 'temperature',
        '2024-03-27 00:00:00', '2024-03-27 23:59:59'
    ) AS tren_suhu
FROM RawatInap r
JOIN Pasien p ON r.IDPasien = p.IDPasien
WHERE r.IDRawatInap = 236;

-- Contoh 2
SELECT 
    p.Nama,
    r.IDRawatInap,
    temporal_trend(
        'tandavital', 'idrawatinap', r.IDRawatInap, 'temperature',
        '2024-03-29 00:00:00', '2024-03-29 23:59:59'
    ) AS tren_suhu
FROM RawatInap r
JOIN Pasien p ON r.IDPasien = p.IDPasien
WHERE r.IDRawatInap = 236;

-- 3. Speed
SELECT 
    p.Nama,
    temporal_speed(
        'tandavital', 'idrawatinap', r.IDRawatInap, 'systolic',
        '2024-03-27 00:00:00', '2024-03-27 23:59:59'
    ) AS kecepatan_penurunan_suhu
FROM RawatInap r
JOIN Pasien p ON r.IDPasien = p.IDPasien
WHERE r.IDRawatInap = 236;

-- 3. Acceleration
SELECT 
    p.Nama,
    r.IDRawatInap,
    r.RuangPerawatan,
    temporal_acceleration(
        'tandavital', 'idrawatinap', r.IDRawatInap, 'systolic',
        '2024-01-01 00:00:00', '2024-12-31 23:59:59'
    ) AS akselerasi_tensi
FROM RawatInap r
JOIN Pasien p ON r.IDPasien = p.IDPasien
WHERE temporal_acceleration(
    'tandavital', 'idrawatinap', r.IDRawatInap, 'systolic',
    '2024-01-01 00:00:00', '2024-12-31 23:59:59'
) < 0;