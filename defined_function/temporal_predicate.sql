-- Helper 
CREATE OR REPLACE FUNCTION get_end_time(ts TIMESTAMP) 
RETURNS TIMESTAMP AS $$
BEGIN
    RETURN COALESCE(ts, 'infinity'::TIMESTAMP);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION temporal_intersects(s1 TIMESTAMP, e1 TIMESTAMP, s2 TIMESTAMP, e2 TIMESTAMP) 
RETURNS BOOLEAN AS $$
BEGIN 
    RETURN s1 < get_end_time(e2)  AND s2 < get_end_time(e1); 
END; 
$$ LANGUAGE plpgsql IMMUTABLE;

-- ===========================
-- Changed
-- Mengecek apakah ada perubahan nilai pada suatu kolom dalam interval waktu tertentu
-- ===========================
CREATE OR REPLACE FUNCTION temporal_changed(
    _table_name TEXT,
    _id_col TEXT,
    _id_val INT,
    _target_col TEXT,
    _start_time TIMESTAMP,
    _end_time TIMESTAMP
) 
RETURNS BOOLEAN AS $$
DECLARE
    _is_changed BOOLEAN;
    _sql TEXT;
BEGIN
    _sql := format(
        'SELECT COUNT(DISTINCT %I) > 1 
         FROM %I 
         WHERE %I = %L 
         AND temporal_intersects(ValidStart, ValidEnd, %L, %L)', 
         _target_col, _table_name, _id_col, _id_val, _start_time, _end_time
    );

    EXECUTE _sql INTO _is_changed;
    RETURN COALESCE(_is_changed, FALSE);
END;
$$ LANGUAGE plpgsql STABLE;

-- ===========================
-- Trend
-- Mengecek tren data: INCREASING, DECREASING, STABLE, FLUCTUATING
-- ===========================
CREATE OR REPLACE FUNCTION temporal_trend(
    _table_name TEXT,
    _id_col TEXT,
    _id_val INT,
    _target_col TEXT,
    _start_time TIMESTAMP,
    _end_time TIMESTAMP
) 
RETURNS TEXT AS $$
DECLARE
    _is_increasing BOOLEAN;
    _is_decreasing BOOLEAN;
    _sql TEXT;
BEGIN
    _sql := format(
        'WITH OrderedData AS (
            SELECT %I::FLOAT as val, ValidStart 
            FROM %I 
            WHERE %I = %L 
            AND temporal_intersects(ValidStart, ValidEnd, %L, %L)
            ORDER BY ValidStart ASC
        ),
        TrendCheck AS (
            SELECT 
                BOOL_AND(next_val >= val) as all_increasing,
                BOOL_AND(next_val <= val) as all_decreasing
            FROM (
                SELECT val, LEAD(val) OVER (ORDER BY ValidStart) as next_val
                FROM OrderedData
            ) sub
            WHERE next_val IS NOT NULL
        )
        SELECT all_increasing, all_decreasing FROM TrendCheck;',
        _target_col, _table_name, _id_col, _id_val, _start_time, _end_time
    );

    EXECUTE _sql INTO _is_increasing, _is_decreasing;

    IF _is_increasing AND NOT _is_decreasing THEN RETURN 'INCREASING';
    ELSIF _is_decreasing AND NOT _is_increasing THEN RETURN 'DECREASING';
    ELSIF _is_increasing AND _is_decreasing THEN RETURN 'STABLE';
    ELSE RETURN 'FLUCTUATING';
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;

-- ===========================
-- Speed
-- Menghitung rata-rata kecepatan perubahan
-- ===========================
CREATE OR REPLACE FUNCTION temporal_speed(
    _table_name TEXT,
    _id_col TEXT,
    _id_val INT,
    _target_col TEXT,
    _start_time TIMESTAMP,
    _end_time TIMESTAMP
) 
RETURNS FLOAT AS $$
DECLARE
    _delta_val FLOAT;
    _delta_time_hours FLOAT;
    _sql TEXT;
BEGIN
    -- Mengambil selisih nilai akhir dan nilai awal, serta selisih waktu
    _sql := format(
        'WITH Data AS (
            SELECT %I::FLOAT as val, EXTRACT(EPOCH FROM ValidStart) as ts
            FROM %I
            WHERE %I = %L AND temporal_intersects(ValidStart, ValidEnd, %L, %L)
        ),
        Stats AS (
            SELECT 
                (SELECT val FROM Data ORDER BY ts DESC LIMIT 1) - (SELECT val FROM Data ORDER BY ts ASC LIMIT 1) as d_val,
                (SELECT ts FROM Data ORDER BY ts DESC LIMIT 1) - (SELECT ts FROM Data ORDER BY ts ASC LIMIT 1) as d_ts
        )
        SELECT d_val, d_ts FROM Stats',
         _target_col, _table_name, _id_col, _id_val, _start_time, _end_time
    );

    EXECUTE _sql INTO _delta_val, _delta_time_hours;
    
    -- Konversi detik ke jam (3600), handle pembagian dengan nol
    IF _delta_time_hours IS NULL OR _delta_time_hours = 0 THEN
        RETURN 0.0;
    END IF;

    RETURN _delta_val / (_delta_time_hours / 3600.0);
END;
$$ LANGUAGE plpgsql STABLE;

-- ===========================
-- Acceleration
-- Menghitung rata-rata percepatan perubahan
-- ===========================
CREATE OR REPLACE FUNCTION temporal_acceleration(
    _table_name TEXT,
    _id_col TEXT,
    _id_val INT,
    _target_col TEXT,
    _start_time TIMESTAMP,
    _end_time TIMESTAMP
) 
RETURNS FLOAT AS $$
DECLARE
    _mid_time TIMESTAMP;
    _speed_1 FLOAT;
    _speed_2 FLOAT;
    _total_hours FLOAT;
BEGIN
    _mid_time := _start_time + ((_end_time - _start_time) / 2);
    
    -- Hitung speed awal (memanggil fungsi speed)
    _speed_1 := temporal_speed(_table_name, _id_col, _id_val, _target_col, _start_time, _mid_time);
    
    -- Hitung speed akhir
    _speed_2 := temporal_speed(_table_name, _id_col, _id_val, _target_col, _mid_time, _end_time);
    
    _total_hours := EXTRACT(EPOCH FROM (_end_time - _start_time)) / 3600.0;

    IF _total_hours = 0 THEN RETURN 0; END IF;

    RETURN (_speed_2 - _speed_1) / _total_hours;
END;
$$ LANGUAGE plpgsql STABLE;