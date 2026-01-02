-- Contoh 1
-- Menampilkan daftar pasien rawat inap beserta ruang perawatannya, lengkap dengan periode waktu rawat inap.
SELECT 
    data->>'idpasien' as IDPasien,
    data->>'ruangperawatan' as RuangPerawatan,
    validstart,
    validend
FROM temporal_projection('rawatinap', ARRAY['idpasien', 'ruangperawatan'])
LIMIT 5;

-- Contoh 2
-- Mencari seluruh pasien yang pernah dirawat di ruang ICU, beserta diagnosis dan waktu masuknya.
SELECT 
    data->>'idrawatinap' as ID,
    data->>'ruangperawatan' as Room,
    data->>'diagnosis' as Diagnosis,
    validstart
FROM temporal_selection('rawatinap', 'ruangperawatan = ''ICU''')
LIMIT 5;

-- Contoh 3
-- Berapa total rawat inap ICU + IGD per ruang?
SELECT
  data->>'ruangperawatan' AS ruang,
  COUNT(*) AS total
FROM temporal_union(
  'rawatinap',
  'ruangperawatan = ''ICU''',
  'ruangperawatan = ''IGD'''
)
GROUP BY data->>'ruangperawatan';


-- Contoh 4
-- Apakah ada periode ICU pasien yang terpotong atau terbelah karena adanya perawatan IGD di tengahnya?
SELECT
  (data->>'idpasien')::int AS idpasien,
  COUNT(*) AS jumlah_interval_hasil
FROM temporal_set_difference(
  'rawatinap',
  'idpasien',
  'ruangperawatan = ''ICU''',
  'ruangperawatan = ''IGD'''
)
GROUP BY (data->>'idpasien')::int
HAVING COUNT(*) > 1
ORDER BY jumlah_interval_hasil DESC, idpasien;


-- Contoh 5
-- Menampilkan tanda vital pasien ICU atau pasien dengan diagnosis sepsis selama masa rawat inapnya.
SELECT 
    data->>'diagnosis' as Diagnosis,
    data->>'temperature' as Temp,
    data->>'heartrate' as HR,
    validstart_t1::DATE as AdmissionDate,
    validstart_t2 as VitalTime
FROM temporal_join(
    'rawatinap',
    'tandavital',
    'idrawatinap',
    ARRAY['diagnosis'],
    ARRAY['temperature', 'heartrate']
)
WHERE data->>'diagnosis' LIKE '%ICU%' 
   OR data->>'diagnosis' LIKE '%Sepsis%'
LIMIT 5;


-- Contoh 6
-- Menampilkan daftar pasien yang sedang dirawat saat ini.
SELECT 
    data->>'idrawatinap' as ID,
    data->>'ruangperawatan' as Room,
    data->>'diagnosis' as Diagnosis,
    validstart::DATE as AdmittedOn
FROM temporal_timeslice('rawatinap', CURRENT_TIMESTAMP)
LIMIT 5;
