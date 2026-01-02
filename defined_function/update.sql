-- Update digunakkan untuk memperbarui data yang salah pada tabel RawatInap dan TandaVital
CREATE OR REPLACE FUNCTION UpdateRawatInap(
    p_IDPasien INT,
    p_RuangPerawatan VARCHAR,
    p_Diagnosis VARCHAR,
    p_DokterPenanggungjawab VARCHAR
)
RETURNS VOID AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM RawatInap
        WHERE IDPasien = p_IDPasien
          AND ValidEnd IS NULL
    ) THEN
        UPDATE RawatInap
        SET RuangPerawatan = p_RuangPerawatan,
            Diagnosis = p_Diagnosis,
            DokterPenanggungjawab = p_DokterPenanggungjawab
        WHERE IDPasien = p_IDPasien
          AND ValidEnd IS NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION UpdateTandaVital(
    p_IDPasien INT,
    p_IDRawatInap INT,
    p_Temperature DECIMAL,
    p_Systolic INT,
    p_Diastolic INT,
    p_HeartRate INT,
    p_RespiratoryRate INT,
    p_SPO2 INT
) 
RETURNS VOID AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM TandaVital
        WHERE IDPasien = p_IDPasien
          AND IDRawatInap = p_IDRawatInap
          AND ValidEnd IS NULL
    ) THEN
        UPDATE TandaVital
        SET Temperature = p_Temperature,
            Systolic = p_Systolic,
            Diastolic = p_Diastolic,
            HeartRate = p_HeartRate,
            RespiratoryRate = p_RespiratoryRate,
            SPO2 = p_SPO2
        WHERE IDPasien = p_IDPasien
          AND IDRawatInap = p_IDRawatInap
          AND ValidEnd IS NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;