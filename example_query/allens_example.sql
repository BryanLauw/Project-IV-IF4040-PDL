-- 1. BEFORE (X < Y)
-- Mencari data Tanda Vital yang dimasukkan sebelum masa Rawat Inap dimulai (data tidak valid).
SELECT tv.IDVital “ID Vital”, 
       tv.ValidStart AS “Valid Start”, 
       r.ValidStart AS “Mulai Rawat”
FROM TandaVital tv
JOIN RawatInap r ON tv.IDRawatInap = r.IDRawatInap
WHERE allen_before(tv.ValidStart, tv.ValidEnd, r.ValidStart, r.ValidEnd);

-- 2. AFTER (Y > X)
-- Mencari jadwal Rawat Inap baru yang terjadi setelah rawat inap sebelumnya selesai.
SELECT r1.IDPasien as “Pasien”,
       r1.IDRawatInap AS “Rawat Inap Lama”, 
       r2.IDRawatInap AS “Rawat Inap Baru”
FROM RawatInap r1
JOIN RawatInap r2 ON r1.IDPasien = r2.IDPasien
WHERE r1.IDRawatInap != r2.IDRawatInap
  AND allen_after(r2.ValidStart, r2.ValidEnd, r1.ValidStart, r1.ValidEnd);

-- 3. MEETS (X m Y)
-- Mencari rawat inap dengan perpindahan kamar/unit. Rawat Inap awalnya di kamar A lalu dipindahkan ke kamar B.
SELECT r1.IDPasien AS “Pasien”,
       r1.RuangPerawatan AS “Ruang Asal”, 
       r2.RuangPerawatan AS “Ruang Tujuan”
FROM RawatInap r1
JOIN RawatInap r2 ON r1.IDPasien = r2.IDPasien
WHERE allen_meets(r1.ValidStart, r1.ValidEnd, r2.ValidStart, r2.ValidEnd);

-- 4. MET BY (Y mi X)
-- Kebalikan dari Meets.
SELECT r1.IDPasien AS “Pasien”,
       r2.RuangPerawatan AS “Ruang Tujuan”, 
       r1.RuangPerawatan AS “Ruang Asal”
FROM RawatInap r1
JOIN RawatInap r2 ON r1.IDPasien = r2.IDPasien
WHERE allen_met_by(r2.ValidStart, r2.ValidEnd, r1.ValidStart, r1.ValidEnd);

-- 5. OVERLAPS (X o Y)
-- Mencari jadwal Rawat Inap yang beririsan dengan kejadian tertentu (misal renovasi rumah sakit).
SELECT IDRawatInap, RuangPerawatan
FROM RawatInap
WHERE allen_overlaps(
    ValidStart, ValidEnd, 
    '2024-03-01 08:00:00', '2024-04-02 08:00:00' -- Jadwal
);

-- 6. OVERLAPPED BY (Y oi X)
-- Kebalikan Overlaps. Apakah jadwal tertentu "overlap" dengan jadwal pasien tertentu.
SELECT IDRawatInap, RuangPerawatan
FROM RawatInap
WHERE allen_overlapped_by(
    '2024-03-01 08:00:00', '2024-04-02 08:00:00', -- Jadwal
    ValidStart, ValidEnd
);

-- 7. STARTS (X s Y)
-- Mencari pemeriksaan Tanda Vital yang dilakukan tepat saat pasien baru saja masuk.
SELECT r.IDPasien, tv.IDRawatInap, tv.IDVital
FROM TandaVital tv
JOIN RawatInap r ON tv.IDRawatInap = r.IDRawatInap
WHERE allen_starts(tv.ValidStart, tv.ValidEnd, r.ValidStart, r.ValidEnd);

-- 8. STARTED BY (Y si X)
-- Kebalikan Starts. Mencari Rawat Inap yang diawali dengan proses pemeriksaan tertentu.
SELECT r.IDRawatInap, r.IDPasien
FROM RawatInap r
JOIN TandaVital tv ON r.IDRawatInap = tv.IDRawatInap
WHERE allen_started_by(r.ValidStart, r.ValidEnd, tv.ValidStart, tv.ValidEnd);

-- 9. DURING (X d Y)
-- Mengambil semua data Tanda Vital yang validitasnya berada sepenuhnya di dalam masa Rawat Inap pasien.
SELECT r.IDRawatInap, 
       tv.HeartRate, 
       tv.Temperature, 
       tv.Systolic, 
       tv.Diastolic, 
       tv.RespiratoryRate, 
       tv.SPO2
FROM RawatInap r
JOIN TandaVital tv ON r.IDRawatInap = tv.IDRawatInap
WHERE r.IDPasien = 79
  AND allen_during(tv.ValidStart, tv.ValidEnd, r.ValidStart, r.ValidEnd);


-- 10. CONTAINS (Y di X)
-- Mencari Rawat Inap yang didalamnya terjadinya kejadian tertentu (misal mati lampu RS).
SELECT IDRawatInap, RuangPerawatan
FROM RawatInap
WHERE allen_contains(
    ValidStart, ValidEnd, 
    '2024-05-01 08:00:00', '2024-05-02 08:00:00' -- Waktu 
);

-- 11. FINISHES (X f Y)
-- Mencari pemeriksaan Tanda Vital terakhir yang selesai tepat bersamaan dengan waktu pasien pulang.
SELECT r.IDRawatInap,
       tv.IDVital,
       tv.HeartRate,
       tv.Temperature, 
       tv.Systolic, 
       tv.Diastolic, 
       tv.RespiratoryRate, 
       tv.SPO2
FROM TandaVital tv
JOIN RawatInap r ON tv.IDRawatInap = r.IDRawatInap
WHERE r.IDPasien = 79
  AND allen_finishes(tv.ValidStart, tv.ValidEnd, r.ValidStart, r.ValidEnd);

-- 12. FINISHED BY (Y fi X)
-- Kebalikan Finishes. Rawat Inap selesai bersamaan dengan selesainya pemantauan tertentu.
SELECT r.IDRawatInap, tv.IDVital
FROM RawatInap r
JOIN TandaVital tv ON r.IDRawatInap = tv.IDRawatInap
WHERE allen_finished_by(r.ValidStart, r.ValidEnd, tv.ValidStart, tv.ValidEnd);

-- 13. EQUALS (X = Y)
-- Mencari duplikasi data. Misal mencari dua data Tanda Vital yang memiliki rentang validitas waktu yang persis sama (kemungkinan entri ganda).
SELECT tv1.IDVital AS Vital1, 
       tv2.IDVital AS Vital2
FROM TandaVital tv1
JOIN TandaVital tv2 ON tv1.IDRawatInap = tv2.IDRawatInap
WHERE tv1.IDVital < tv2.IDVital
  AND allen_equals(tv1.ValidStart, tv1.ValidEnd, tv2.ValidStart, tv2.ValidEnd);
