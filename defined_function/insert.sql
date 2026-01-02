-- Insert digunakan untuk memasukkan data baru ke dalam tabel RawatInap dan TandaVital
CREATE OR REPLACE FUNCTION InsertRawatInap(
    p_IDPasien INT,
    p_RuangPerawatan VARCHAR,
    p_Diagnosis VARCHAR,
    p_DokterPenanggungjawab VARCHAR,
    p_ValidStart TIMESTAMP
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
        SET ValidEnd = p_ValidStart
        WHERE IDPasien = p_IDPasien
          AND ValidEnd IS NULL;
    END IF;

    INSERT INTO RawatInap (
        IDPasien,
        RuangPerawatan,
        Diagnosis,
        DokterPenanggungjawab,
        ValidStart,
        ValidEnd
    )
    VALUES (
        p_IDPasien,
        p_RuangPerawatan,
        p_Diagnosis,
        p_DokterPenanggungjawab,
        p_ValidStart,
        NULL
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION InsertTandaVital(
    p_IDPasien INT,
    p_IDRawatInap INT,
    p_Temperature DECIMAL,
    p_Systolic INT,
    p_Diastolic INT,
    p_HeartRate INT,
    p_RespiratoryRate INT,
    p_SPO2 INT,
    p_ValidStart TIMESTAMP
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
        SET ValidEnd = p_ValidStart
        WHERE IDPasien = p_IDPasien
          AND IDRawatInap = p_IDRawatInap
          AND ValidEnd IS NULL;
    END IF;

    INSERT INTO TandaVital (
        IDPasien,
        IDRawatInap,
        Temperature,
        Systolic,
        Diastolic,
        HeartRate,
        RespiratoryRate,
        SPO2,
        ValidStart
    )
    VALUES (
        p_IDPasien,
        p_IDRawatInap,
        p_Temperature,
        p_Systolic,
        p_Diastolic,
        p_HeartRate,
        p_RespiratoryRate,
        p_SPO2,
        p_ValidStart
    );
END;
$$ LANGUAGE plpgsql;