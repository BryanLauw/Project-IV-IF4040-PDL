-- Helper untuk menangani ValidEnd yang NULL sebagai Infinity
CREATE OR REPLACE FUNCTION get_end_time(ts TIMESTAMP) 
RETURNS TIMESTAMP AS $$
BEGIN
    RETURN COALESCE(ts, 'infinity'::TIMESTAMP);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 1. BEFORE (X < Y): X terjadi sepenuhnya sebelum Y
CREATE OR REPLACE FUNCTION allen_before(s1 TIMESTAMP, e1 TIMESTAMP, s2 TIMESTAMP, e2 TIMESTAMP) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN get_end_time(e1) < s2;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 2. AFTER (Y > X): Kebalikan dari Before
CREATE OR REPLACE FUNCTION allen_after(s1 TIMESTAMP, e1 TIMESTAMP, s2 TIMESTAMP, e2 TIMESTAMP) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN s1 > get_end_time(e2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 3. MEETS (X m Y): X bertemu langsung dengan Y (akhir X = awal Y)
CREATE OR REPLACE FUNCTION allen_meets(s1 TIMESTAMP, e1 TIMESTAMP, s2 TIMESTAMP, e2 TIMESTAMP) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN get_end_time(e1) = s2;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 4. MET BY (Y mi X): Kebalikan dari Meets
CREATE OR REPLACE FUNCTION allen_met_by(s1 TIMESTAMP, e1 TIMESTAMP, s2 TIMESTAMP, e2 TIMESTAMP) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN s1 = get_end_time(e2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 5. OVERLAPS (X o Y): X mulai sebelum Y, dan berakhir di tengah-tengah Y
CREATE OR REPLACE FUNCTION allen_overlaps(s1 TIMESTAMP, e1 TIMESTAMP, s2 TIMESTAMP, e2 TIMESTAMP) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN s1 < s2 
       AND get_end_time(e1) > s2 
       AND get_end_time(e1) < get_end_time(e2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 6. OVERLAPPED BY (Y oi X): Kebalikan dari Overlaps
CREATE OR REPLACE FUNCTION allen_overlapped_by(s1 TIMESTAMP, e1 TIMESTAMP, s2 TIMESTAMP, e2 TIMESTAMP) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN s1 > s2
       AND s1 < get_end_time(e2) 
       AND get_end_time(e1) > get_end_time(e2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 7. STARTS (X s Y): Mulai bersamaan, tapi X selesai lebih dulu
CREATE OR REPLACE FUNCTION allen_starts(s1 TIMESTAMP, e1 TIMESTAMP, s2 TIMESTAMP, e2 TIMESTAMP) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN s1 = s2 
       AND get_end_time(e1) < get_end_time(e2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 8. STARTED BY (Y si X): Mulai bersamaan, tapi X selesai belakangan
CREATE OR REPLACE FUNCTION allen_started_by(s1 TIMESTAMP, e1 TIMESTAMP, s2 TIMESTAMP, e2 TIMESTAMP) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN s1 = s2 
       AND get_end_time(e1) > get_end_time(e2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 9. DURING (X d Y): X sepenuhnya ada di dalam Y
CREATE OR REPLACE FUNCTION allen_during(s1 TIMESTAMP, e1 TIMESTAMP, s2 TIMESTAMP, e2 TIMESTAMP) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN s1 > s2 
       AND get_end_time(e1) < get_end_time(e2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 10. CONTAINS (Y di X): Y sepenuhnya ada di dalam X
CREATE OR REPLACE FUNCTION allen_contains(s1 TIMESTAMP, e1 TIMESTAMP, s2 TIMESTAMP, e2 TIMESTAMP) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN s1 < s2 
       AND get_end_time(e1) > get_end_time(e2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 11. FINISHES (X f Y): Selesai bersamaan, tapi X mulai belakangan
CREATE OR REPLACE FUNCTION allen_finishes(s1 TIMESTAMP, e1 TIMESTAMP, s2 TIMESTAMP, e2 TIMESTAMP) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN get_end_time(e1) = get_end_time(e2) 
       AND s1 > s2;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 12. FINISHED BY (Y fi X): Selesai bersamaan, tapi X mulai lebih awal
CREATE OR REPLACE FUNCTION allen_finished_by(s1 TIMESTAMP, e1 TIMESTAMP, s2 TIMESTAMP, e2 TIMESTAMP) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN get_end_time(e1) = get_end_time(e2) 
       AND s1 < s2;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 13. EQUALS (X = Y): Identik
CREATE OR REPLACE FUNCTION allen_equals(s1 TIMESTAMP, e1 TIMESTAMP, s2 TIMESTAMP, e2 TIMESTAMP) 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN s1 = s2 
       AND get_end_time(e1) = get_end_time(e2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;