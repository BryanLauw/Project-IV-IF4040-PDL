CREATE TABLE Pasien (
    IDPasien SERIAL PRIMARY KEY,
    Nama VARCHAR(250) NOT NULL,
    TanggalLahir DATE NOT NULL,
    JenisKelamin CHAR(1) NOT NULL CHECK (JenisKelamin IN ('L','P')),
    Alamat VARCHAR(250) NOT NULL
);

CREATE TABLE RawatInap (
    IDRawatInap SERIAL PRIMARY KEY,
    IDPasien INT NOT NULL REFERENCES Pasien(IDPasien),
    RuangPerawatan VARCHAR(100) NOT NULL,
    Diagnosis VARCHAR(500),
    DokterPenanggungjawab VARCHAR(250),
    ValidStart TIMESTAMP NOT NULL,
    ValidEnd TIMESTAMP,
    CONSTRAINT chk_rawatinap_time CHECK (ValidEnd IS NULL OR ValidEnd > ValidStart)
);

CREATE TABLE TandaVital(
    IDVital SERIAL PRIMARY KEY,
    IDRawatInap INT REFERENCES RawatInap(IDRawatInap),
    Temperature DECIMAL(4,2) NOT NULL,
    Systolic INT NOT NULL,
    Diastolic INT NOT NULL,
    HeartRate INT NOT NULL,
    RespiratoryRate INT NOT NULL,
    SPO2 INT NOT NULL,
    ValidStart TIMESTAMP NOT NULL,
    ValidEnd TIMESTAMP,
    CONSTRAINT chk_vital_time CHECK (ValidEnd IS NULL OR ValidEnd > ValidStart)
);