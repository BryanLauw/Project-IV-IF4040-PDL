CREATE TABLE Pasien (
    IDPasien SERIAL PRIMARY KEY,
    Nama VARCHAR(250) NOT NULL,
    TanggalLahir DATE NOT NULL,
    JenisKelamin CHAR(1) NOT NULL CHECK (JenisKelamin IN ('L','P')),
    Alamat VARCHAR(250) NOT NULL
);

CREATE TABLE TandaVital(
    IDVital SERIAL PRIMARY KEY,
    IDPasien INT NOT NULL REFERENCES Pasien(IDPasien),
    Temperature DECIMAL(4,2) NOT NULL,
    Systolic INT NOT NULL,
    Diastolic INT NOT NULL,
    HeartRate INT NOT NULL,
    RespiratoryRate INT NOT NULL,
    SPO2 INT NOT NULL,
    ValidStart TIMESTAMP NOT NULL,
    ValidEnd TIMESTAMP
);