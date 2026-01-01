import random
from datetime import datetime, timedelta
from faker import Faker
import psycopg2
from psycopg2.extras import execute_values
from dotenv import load_dotenv
import os
from pathlib import Path

load_dotenv()

# Configuration
DB_CONFIG = {
    "dbname": os.getenv("DB_NAME", "project_iv_pdl"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASSWORD", "postgres"),
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", 5432)),
}

fake = Faker("id_ID")
Faker.seed(42)
random.seed(42)

MEDICAL_CASES = [
    # Critical/ICU cases
    (
        "Pneumonia berat dengan respiratory distress",
        ["ICU", "PICU"],
        ["Sp.P", "Sp.PD", "Sp.An"],
        0.8,
    ),
    ("Acute myocardial infarction (STEMI)", ["IGD", "ICU"], ["Sp.JP", "Sp.PD"], 0.9),
    ("Sepsis dengan syok septik", ["ICU"], ["Sp.PD", "Sp.An"], 0.85),
    (
        "Stroke iskemik dengan hemiparesis",
        ["ICU", "Ruang Rawat Inap Kelas 1"],
        ["Sp.S"],
        0.7,
    ),
    (
        "COVID-19 dengan pneumonia",
        ["ICU", "Ruang Rawat Inap Kelas 1"],
        ["Sp.P", "Sp.PD"],
        0.75,
    ),
    (
        "Gagal jantung kongestif",
        ["ICU", "Ruang Rawat Inap Kelas 1"],
        ["Sp.JP", "Sp.PD"],
        0.7,
    ),
    ("Respiratory distress syndrome", ["ICU", "PICU"], ["Sp.A", "Sp.An"], 0.8),
    (
        "Acute kidney injury dengan dialysis",
        ["ICU", "Ruang Rawat Inap Kelas 1"],
        ["Sp.PD"],
        0.75,
    ),
    # Emergency cases
    ("Appendisitis akut", ["IGD", "Ruang Rawat Inap Kelas 2"], ["Sp.B"], 0.6),
    ("Trauma kepala sedang", ["IGD", "ICU"], ["Sp.S", "Sp.B"], 0.7),
    ("Perdarahan gastrointestinal", ["IGD", "ICU"], ["Sp.PD", "Sp.B"], 0.75),
    (
        "Hipertensi emergensi",
        ["IGD", "Ruang Rawat Inap Kelas 2"],
        ["Sp.PD", "Sp.JP"],
        0.65,
    ),
    # Regular ward cases
    (
        "Diabetes mellitus tipe 2 tidak terkontrol",
        ["Ruang Rawat Inap Kelas 2", "Ruang Rawat Inap Kelas 3"],
        ["Sp.PD"],
        0.4,
    ),
    (
        "Dengue fever grade II",
        ["Ruang Rawat Inap Kelas 2", "Ruang Rawat Inap Kelas 3"],
        ["Sp.PD", "Sp.A"],
        0.5,
    ),
    (
        "Demam tifoid",
        ["Ruang Rawat Inap Kelas 2", "Ruang Rawat Inap Kelas 3"],
        ["Sp.PD"],
        0.45,
    ),
    (
        "Tuberkulosis paru dengan komplikasi",
        ["Ruang Rawat Inap Kelas 1", "Ruang Rawat Inap Kelas 2"],
        ["Sp.P"],
        0.55,
    ),
    (
        "Asma bronkial eksaserbasi akut",
        ["Ruang Rawat Inap Kelas 2", "Ruang Rawat Inap Kelas 3"],
        ["Sp.P", "Sp.A"],
        0.5,
    ),
    (
        "Gastroenteritis akut dengan dehidrasi",
        ["Ruang Rawat Inap Kelas 3", "Ruang Rawat Inap Kelas 2"],
        ["Sp.PD", "Sp.A"],
        0.4,
    ),
    (
        "Chronic kidney disease stage 4",
        ["Ruang Rawat Inap Kelas 1", "Ruang Rawat Inap Kelas 2"],
        ["Sp.PD"],
        0.6,
    ),
    (
        "Pneumonia komunitas ringan-sedang",
        ["Ruang Rawat Inap Kelas 2", "Ruang Rawat Inap Kelas 3"],
        ["Sp.P", "Sp.PD"],
        0.5,
    ),
    (
        "Hipertensi dengan komplikasi",
        ["Ruang Rawat Inap Kelas 2"],
        ["Sp.PD", "Sp.JP"],
        0.5,
    ),
    (
        "Anemia berat",
        ["Ruang Rawat Inap Kelas 2", "Ruang Rawat Inap Kelas 3"],
        ["Sp.PD"],
        0.45,
    ),
    # Post-operative/Rehabilitation
    (
        "Post operasi appendektomi",
        ["Ruang Rawat Inap Kelas 2", "Ruang Rawat Inap Kelas 3"],
        ["Sp.B"],
        0.3,
    ),
    (
        "Post stroke rehabilitation",
        ["Ruang Rawat Inap Kelas 1"],
        ["Sp.KFR", "Sp.S"],
        0.4,
    ),
    ("Post myocardial infarction care", ["Ruang Rawat Inap Kelas 1"], ["Sp.JP"], 0.5),
]


def load_schema():
    schema_path = Path("schema.sql")
    if not schema_path.exists():
        raise FileNotFoundError(
            "schema.sql not found! Please create schema.sql in the same directory as this script."
        )

    print("Loading schema from schema.sql...")
    with open(schema_path, "r", encoding="utf-8") as f:
        return f.read()


def generate_patients(n=50):
    patients = []
    for _ in range(n):
        gender = random.choice(["L", "P"])
        if gender == "L":
            name = fake.name_male()
        else:
            name = fake.name_female()

        # Birth date between 1940 and 2020
        birth_date = fake.date_of_birth(minimum_age=4, maximum_age=84)
        address = fake.address().replace("\n", ", ")

        patients.append((name, birth_date, gender, address))

    return patients


def generate_admissions(patient_ids, min_admissions=1, max_admissions=4):
    admissions = []
    base_date = datetime(2024, 1, 1)

    for patient_id in patient_ids:
        # Random number of admissions per patient
        num_admissions = random.randint(min_admissions, max_admissions)

        current_date = base_date + timedelta(days=random.randint(0, 90))

        for i in range(num_admissions):
            # Choose a medical case
            diagnosis, possible_rooms, possible_specialists, severity = random.choice(
                MEDICAL_CASES
            )

            # Select appropriate room for this diagnosis
            ruang = random.choice(possible_rooms)

            # Select appropriate specialist for this diagnosis
            specialist = random.choice(possible_specialists)

            # Generate doctor name with appropriate specialization
            doctor_name = f"Dr. {fake.name()}, {specialist}"

            # Admission duration depends on room type and severity
            if ruang in ["ICU", "PICU", "NICU"]:
                # ICU stays: 3-14 days, longer for more severe cases
                duration_days = random.randint(3, 14) * severity
            elif ruang == "IGD":
                # Emergency: hours to 1 day before transfer
                duration_days = random.uniform(0.1, 1)
            else:
                # Regular ward: 2-10 days based on severity
                duration_days = random.randint(2, 10) * (0.5 + severity * 0.5)

            valid_start = current_date

            # 10% chance of still being admitted (ValidEnd = NULL)
            if i == num_admissions - 1 and random.random() < 0.1:
                valid_end = None
            else:
                valid_end = valid_start + timedelta(days=duration_days)
                current_date = valid_end + timedelta(days=random.randint(7, 60))

            admissions.append(
                (patient_id, ruang, diagnosis, doctor_name, valid_start, valid_end)
            )

    return admissions


def generate_vital_signs(admission_id, patient_id, ruang, valid_start, valid_end):
    vitals = []

    # Determine monitoring frequency and severity based on room type
    if ruang in ["ICU", "PICU", "NICU", "IGD"]:
        # ICU: Every 15-30 minutes initially, then hourly
        interval_minutes = 15
        is_critical = True
    else:
        # Regular ward: Every 6-8 hours
        interval_minutes = 360
        is_critical = False

    # If still admitted (valid_end is None), set end to now
    if valid_end is None:
        end_time = datetime.now()
    else:
        end_time = valid_end

    # Generate vital signs progression
    current_time = valid_start

    # Initial vital signs (potentially abnormal based on severity)
    if is_critical:
        # Critical patients have more abnormal vitals
        temp = random.uniform(38.0, 39.5)
        systolic = random.randint(135, 160)
        diastolic = random.randint(85, 105)
        heart_rate = random.randint(100, 130)
        resp_rate = random.randint(22, 32)
        spo2 = random.randint(88, 94)
    else:
        # Regular ward patients are more stable
        temp = random.uniform(37.0, 38.5)
        systolic = random.randint(110, 140)
        diastolic = random.randint(70, 90)
        heart_rate = random.randint(70, 95)
        resp_rate = random.randint(16, 22)
        spo2 = random.randint(94, 98)

    reading_count = 0

    while current_time < end_time:
        next_time = current_time + timedelta(minutes=interval_minutes)

        # Vital signs trend towards improvement over time
        # Temperature decreases
        temp = max(36.5, temp - random.uniform(0, 0.3))

        # Blood pressure normalizes (target ~120/80)
        if systolic > 120:
            systolic = max(110, systolic - random.randint(0, 5))
        else:
            systolic = min(130, systolic + random.randint(0, 3))

        if diastolic > 80:
            diastolic = max(70, diastolic - random.randint(0, 3))
        else:
            diastolic = min(85, diastolic + random.randint(0, 2))

        # Heart rate normalizes (target ~75)
        if heart_rate > 90:
            heart_rate = max(70, heart_rate - random.randint(1, 4))
        else:
            heart_rate = max(65, min(85, heart_rate + random.randint(-2, 2)))

        # Respiratory rate normalizes (target ~16)
        if resp_rate > 20:
            resp_rate = max(14, resp_rate - random.randint(0, 2))
        else:
            resp_rate = max(12, min(18, resp_rate + random.randint(-1, 1)))

        # SpO2 increases (target 97-99)
        spo2 = min(99, spo2 + random.uniform(0, 0.5))

        # Determine ValidEnd for this reading
        if next_time >= end_time:
            reading_valid_end = None if valid_end is None else end_time
        else:
            reading_valid_end = next_time

        vitals.append(
            (
                patient_id,
                admission_id,
                round(temp, 2),
                int(systolic),
                int(diastolic),
                int(heart_rate),
                int(resp_rate),
                int(spo2),
                current_time,
                reading_valid_end,
            )
        )

        current_time = next_time
        reading_count += 1

        # After initial critical period, reduce monitoring frequency
        if is_critical and reading_count > 10:
            interval_minutes = 60  # Switch to hourly

    return vitals


def seed_database(num_patients=100):
    print(f"Starting database seeding with {num_patients} patients...")
    print(f"Database: {DB_CONFIG['dbname']} at {DB_CONFIG['host']}\n")

    # Connect to database
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        print("Connected to database")
    except psycopg2.OperationalError as e:
        print(f"Connection failed: {e}")
        return

    try:
        # Check if tables exist
        cur.execute(
            "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'pasien');"
        )
        tables_exist = cur.fetchone()[0]

        if not tables_exist:
            schema_sql = load_schema()
            print("Creating schema from schema.sql...")
            cur.execute(schema_sql)
            conn.commit()
            print("Schema created\n")
        else:
            print("Schema already exists (skipping creation)\n")

        # Clear existing data
        print("Clearing existing data...")
        cur.execute("TRUNCATE TABLE TandaVital, RawatInap, Pasien CASCADE;")
        cur.execute("ALTER SEQUENCE pasien_idpasien_seq RESTART WITH 1;")
        cur.execute("ALTER SEQUENCE rawatinap_idrawatinap_seq RESTART WITH 1;")
        cur.execute("ALTER SEQUENCE tandavital_idvital_seq RESTART WITH 1;")
        conn.commit()
        print("Data cleared\n")

        # Insert patients
        print(f"Generating {num_patients} patients...")
        patients = generate_patients(num_patients)
        execute_values(
            cur,
            "INSERT INTO Pasien (Nama, TanggalLahir, JenisKelamin, Alamat) VALUES %s RETURNING IDPasien",
            patients,
        )
        patient_ids = [row[0] for row in cur.fetchall()]
        print(f"Inserted {len(patient_ids)} patients\n")

        # Insert admissions
        print("Generating admissions...")
        admissions = generate_admissions(patient_ids)
        execute_values(
            cur,
            "INSERT INTO RawatInap (IDPasien, RuangPerawatan, Diagnosis, DokterPenanggungjawab, ValidStart, ValidEnd) VALUES %s RETURNING IDRawatInap, IDPasien, RuangPerawatan, ValidStart, ValidEnd",
            admissions,
        )
        admission_data = cur.fetchall()
        print(f"Inserted {len(admission_data)} admissions\n")

        # Insert vital signs
        print("Generating vital signs...")
        all_vitals = []
        for idx, (admission_id, patient_id, ruang, valid_start, valid_end) in enumerate(
            admission_data, 1
        ):
            if idx % 10 == 0:
                print(f"   Processing {idx}/{len(admission_data)}...")
            vitals = generate_vital_signs(
                admission_id, patient_id, ruang, valid_start, valid_end
            )
            all_vitals.extend(vitals)

        print(f"Inserting {len(all_vitals)} vital sign records...")
        execute_values(
            cur,
            "INSERT INTO TandaVital (IDPasien, IDRawatInap, Temperature, Systolic, Diastolic, HeartRate, RespiratoryRate, SPO2, ValidStart, ValidEnd) VALUES %s",
            all_vitals,
            page_size=1000,
        )
        conn.commit()
        print(f"Inserted {len(all_vitals)} vital signs\n")

        # Statistics
        print("Database Statistics:")
        cur.execute("SELECT COUNT(*) FROM Pasien")
        print(f"   Patients:           {cur.fetchone()[0]}")
        cur.execute("SELECT COUNT(*) FROM RawatInap")
        print(f"   Admissions:         {cur.fetchone()[0]}")
        cur.execute("SELECT COUNT(*) FROM RawatInap WHERE ValidEnd IS NULL")
        print(f"   Currently admitted: {cur.fetchone()[0]}")
        cur.execute("SELECT COUNT(*) FROM TandaVital")
        print(f"   Vital signs:        {cur.fetchone()[0]}")

        print("\nSeeding completed successfully!")

    except FileNotFoundError as e:
        print(str(e))
    except Exception as e:
        print(f"Error: {e}")
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    seed_database(100)
