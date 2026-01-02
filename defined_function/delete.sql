-- Delete digunakan untuk menghapus data pada tabel RawatInap dengan menandai ValidEnd
CREATE OR REPLACE FUNCTION DeleteRawatInap(
    p_IDPasien INT,
    p_ValidEnd TIMESTAMP
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
        SET ValidEnd = p_ValidEnd
        WHERE IDPasien = p_IDPasien
          AND ValidEnd IS NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION DeleteTandaVital(
    p_IDPasien INT,
    p_IDRawatInap INT,
    p_ValidEnd TIMESTAMP
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
        SET ValidEnd = p_ValidEnd
        WHERE IDPasien = p_IDPasien
          AND IDRawatInap = p_IDRawatInap
          AND ValidEnd IS NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;