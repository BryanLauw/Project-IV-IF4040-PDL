--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: allen_after(timestamp without time zone, timestamp without time zone, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.allen_after(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN s1 > get_end_time(e2);
END;
$$;


ALTER FUNCTION public.allen_after(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) OWNER TO postgres;

--
-- Name: allen_before(timestamp without time zone, timestamp without time zone, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.allen_before(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN get_end_time(e1) < s2;
END;
$$;


ALTER FUNCTION public.allen_before(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) OWNER TO postgres;

--
-- Name: allen_contains(timestamp without time zone, timestamp without time zone, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.allen_contains(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN s1 < s2 
       AND get_end_time(e1) > get_end_time(e2);
END;
$$;


ALTER FUNCTION public.allen_contains(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) OWNER TO postgres;

--
-- Name: allen_during(timestamp without time zone, timestamp without time zone, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.allen_during(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN s1 > s2 
       AND get_end_time(e1) < get_end_time(e2);
END;
$$;


ALTER FUNCTION public.allen_during(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) OWNER TO postgres;

--
-- Name: allen_equals(timestamp without time zone, timestamp without time zone, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.allen_equals(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN s1 = s2 
       AND get_end_time(e1) = get_end_time(e2);
END;
$$;


ALTER FUNCTION public.allen_equals(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) OWNER TO postgres;

--
-- Name: allen_finished_by(timestamp without time zone, timestamp without time zone, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.allen_finished_by(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN get_end_time(e1) = get_end_time(e2) 
       AND s1 < s2;
END;
$$;


ALTER FUNCTION public.allen_finished_by(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) OWNER TO postgres;

--
-- Name: allen_finishes(timestamp without time zone, timestamp without time zone, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.allen_finishes(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN get_end_time(e1) = get_end_time(e2) 
       AND s1 > s2;
END;
$$;


ALTER FUNCTION public.allen_finishes(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) OWNER TO postgres;

--
-- Name: allen_meets(timestamp without time zone, timestamp without time zone, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.allen_meets(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN get_end_time(e1) = s2;
END;
$$;


ALTER FUNCTION public.allen_meets(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) OWNER TO postgres;

--
-- Name: allen_met_by(timestamp without time zone, timestamp without time zone, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.allen_met_by(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN s1 = get_end_time(e2);
END;
$$;


ALTER FUNCTION public.allen_met_by(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) OWNER TO postgres;

--
-- Name: allen_overlapped_by(timestamp without time zone, timestamp without time zone, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.allen_overlapped_by(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN s1 > s2
       AND s1 < get_end_time(e2) 
       AND get_end_time(e1) > get_end_time(e2);
END;
$$;


ALTER FUNCTION public.allen_overlapped_by(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) OWNER TO postgres;

--
-- Name: allen_overlaps(timestamp without time zone, timestamp without time zone, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.allen_overlaps(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN s1 < s2 
       AND get_end_time(e1) > s2 
       AND get_end_time(e1) < get_end_time(e2);
END;
$$;


ALTER FUNCTION public.allen_overlaps(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) OWNER TO postgres;

--
-- Name: allen_started_by(timestamp without time zone, timestamp without time zone, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.allen_started_by(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN s1 = s2 
       AND get_end_time(e1) > get_end_time(e2);
END;
$$;


ALTER FUNCTION public.allen_started_by(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) OWNER TO postgres;

--
-- Name: allen_starts(timestamp without time zone, timestamp without time zone, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.allen_starts(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN s1 = s2 
       AND get_end_time(e1) < get_end_time(e2);
END;
$$;


ALTER FUNCTION public.allen_starts(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) OWNER TO postgres;

--
-- Name: coalesce_tandavital(integer, text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.coalesce_tandavital(_idrawatinap integer, _vital_columns text[]) RETURNS TABLE(idrawatinap integer, vital_data jsonb, validstart timestamp without time zone, validend timestamp without time zone, coalesced_count bigint, merged_ids integer[])
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    _vital_cols_select TEXT;
    _vital_cols_partition TEXT;
    _vital_cols_json TEXT;
    _where_clause TEXT;
BEGIN
    _vital_cols_select := (
        SELECT string_agg(format('%I', col), ', ') FROM unnest(_vital_columns) col
    );
    _vital_cols_partition := _vital_cols_select;
    _vital_cols_json := (
        SELECT string_agg(format('''%s'', %I', col, col), ', ') FROM unnest(_vital_columns) col
    );
    
    IF _idrawatinap IS NOT NULL THEN
        _where_clause := format('WHERE idrawatinap = %L', _idrawatinap);
    ELSE
        _where_clause := '';
    END IF;

    RETURN QUERY EXECUTE format(
        'WITH ordered_data AS (
            SELECT 
                t.idrawatinap, t.idvital, %s, t.validstart, t.validend,
                COALESCE(t.validend, ''infinity''::TIMESTAMP) as validend_norm,
                CASE 
                    WHEN LAG(COALESCE(t.validend, ''infinity''::TIMESTAMP)) OVER (
                        PARTITION BY t.idrawatinap, %s ORDER BY t.validstart
                    ) >= t.validstart THEN 0
                    ELSE 1
                END as is_new_group
            FROM tandavital t %s
        ),
        grouped_data AS (
            SELECT *, SUM(is_new_group) OVER (
                PARTITION BY idrawatinap, %s ORDER BY validstart ROWS UNBOUNDED PRECEDING
            ) as group_num
            FROM ordered_data
        )
        SELECT 
            idrawatinap,
            jsonb_build_object(%s) as vital_data,
            MIN(validstart)::TIMESTAMP,
            CASE WHEN MAX(validend_norm) = ''infinity''::TIMESTAMP 
                 THEN NULL ELSE MAX(validend_norm) END::TIMESTAMP,
            COUNT(*)::BIGINT,
            array_agg(idvital ORDER BY validstart)::INT[]
        FROM grouped_data
        GROUP BY idrawatinap, %s, group_num
        ORDER BY idrawatinap, MIN(validstart)',
        _vital_cols_select, _vital_cols_partition, _where_clause,
        _vital_cols_partition, _vital_cols_json, _vital_cols_partition
    );
END;
$$;


ALTER FUNCTION public.coalesce_tandavital(_idrawatinap integer, _vital_columns text[]) OWNER TO postgres;

--
-- Name: deleterawatinap(integer, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deleterawatinap(p_idpasien integer, p_validend timestamp without time zone) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.deleterawatinap(p_idpasien integer, p_validend timestamp without time zone) OWNER TO postgres;

--
-- Name: deletetandavital(integer, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletetandavital(p_idrawatinap integer, p_validend timestamp without time zone) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM TandaVital
        WHERE IDRawatInap = p_IDRawatInap
          AND ValidEnd IS NULL
    ) THEN
        UPDATE TandaVital
        SET ValidEnd = p_ValidEnd
        WHERE IDRawatInap = p_IDRawatInap
          AND ValidEnd IS NULL;
    END IF;
END;
$$;


ALTER FUNCTION public.deletetandavital(p_idrawatinap integer, p_validend timestamp without time zone) OWNER TO postgres;

--
-- Name: get_end_time(timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_end_time(ts timestamp without time zone) RETURNS timestamp without time zone
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    RETURN COALESCE(ts, 'infinity'::TIMESTAMP);
END;
$$;


ALTER FUNCTION public.get_end_time(ts timestamp without time zone) OWNER TO postgres;

--
-- Name: insertrawatinap(integer, character varying, character varying, character varying, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insertrawatinap(p_idpasien integer, p_ruangperawatan character varying, p_diagnosis character varying, p_dokterpenanggungjawab character varying, p_validstart timestamp without time zone) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.insertrawatinap(p_idpasien integer, p_ruangperawatan character varying, p_diagnosis character varying, p_dokterpenanggungjawab character varying, p_validstart timestamp without time zone) OWNER TO postgres;

--
-- Name: inserttandavital(integer, numeric, integer, integer, integer, integer, integer, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.inserttandavital(p_idrawatinap integer, p_temperature numeric, p_systolic integer, p_diastolic integer, p_heartrate integer, p_respiratoryrate integer, p_spo2 integer, p_validstart timestamp without time zone) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM TandaVital
        WHERE IDRawatInap = p_IDRawatInap
          AND ValidEnd IS NULL
    ) THEN
        UPDATE TandaVital
        SET ValidEnd = p_ValidStart
        WHERE IDRawatInap = p_IDRawatInap
          AND ValidEnd IS NULL;
    END IF;

    INSERT INTO TandaVital (
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
$$;


ALTER FUNCTION public.inserttandavital(p_idrawatinap integer, p_temperature numeric, p_systolic integer, p_diastolic integer, p_heartrate integer, p_respiratoryrate integer, p_spo2 integer, p_validstart timestamp without time zone) OWNER TO postgres;

--
-- Name: temporal_acceleration(text, text, integer, text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.temporal_acceleration(_table_name text, _id_col text, _id_val integer, _target_col text, _start_time timestamp without time zone, _end_time timestamp without time zone) RETURNS double precision
    LANGUAGE plpgsql STABLE
    AS $$
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
$$;


ALTER FUNCTION public.temporal_acceleration(_table_name text, _id_col text, _id_val integer, _target_col text, _start_time timestamp without time zone, _end_time timestamp without time zone) OWNER TO postgres;

--
-- Name: temporal_changed(text, text, integer, text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.temporal_changed(_table_name text, _id_col text, _id_val integer, _target_col text, _start_time timestamp without time zone, _end_time timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
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
$$;


ALTER FUNCTION public.temporal_changed(_table_name text, _id_col text, _id_val integer, _target_col text, _start_time timestamp without time zone, _end_time timestamp without time zone) OWNER TO postgres;

--
-- Name: temporal_coalesce(text, text[], text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.temporal_coalesce(_table_name text, _group_columns text[], _where_clause text DEFAULT NULL::text) RETURNS TABLE(data jsonb, validstart timestamp without time zone, validend timestamp without time zone, coalesced_count bigint)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    _group_cols_select TEXT;
    _group_cols_partition TEXT;
    _group_cols_json TEXT;
    _where_sql TEXT;
BEGIN
    -- validasi
    IF _table_name IS NULL OR _table_name = '' THEN
        RAISE EXCEPTION '_table_name tidak boleh kosong';
    END IF;
    IF _group_columns IS NULL OR array_length(_group_columns, 1) IS NULL THEN
        RAISE EXCEPTION '_group_columns tidak boleh kosong';
    END IF;

    -- build dynamic SQL parts
    _group_cols_select := (
        SELECT string_agg(format('%I', col), ', ') FROM unnest(_group_columns) col
    );
    _group_cols_partition := _group_cols_select;
    _group_cols_json := (
        SELECT string_agg(format('''%s'', %I', col, col), ', ') FROM unnest(_group_columns) col
    );
    
    IF _where_clause IS NOT NULL AND _where_clause <> '' THEN
        _where_sql := format('WHERE %s', _where_clause);
    ELSE
        _where_sql := '';
    END IF;

    RETURN QUERY EXECUTE format(
        'WITH ordered_data AS (
            SELECT 
                %s,
                validstart,
                validend,
                COALESCE(validend, ''infinity''::TIMESTAMP) as validend_normalized,
                -- cek adjacent: LAG(validend) >= validstart berarti lanjutan grup
                CASE 
                    WHEN LAG(COALESCE(validend, ''infinity''::TIMESTAMP)) OVER (
                        PARTITION BY %s ORDER BY validstart
                    ) >= validstart THEN 0
                    ELSE 1
                END as is_new_group
            FROM %I %s
        ),
        grouped_data AS (
            SELECT *, SUM(is_new_group) OVER (
                PARTITION BY %s ORDER BY validstart ROWS UNBOUNDED PRECEDING
            ) as group_num
            FROM ordered_data
        ),
        coalesced AS (
            SELECT 
                %s,
                MIN(validstart) as validstart,
                CASE WHEN MAX(validend_normalized) = ''infinity''::TIMESTAMP 
                     THEN NULL ELSE MAX(validend_normalized) END as validend,
                COUNT(*) as coalesced_count
            FROM grouped_data
            GROUP BY %s, group_num
        )
        SELECT jsonb_build_object(%s), validstart, validend, coalesced_count
        FROM coalesced ORDER BY validstart',
        _group_cols_select, _group_cols_partition, _table_name, _where_sql,
        _group_cols_partition, _group_cols_select, _group_cols_partition, _group_cols_json
    );
END;
$$;


ALTER FUNCTION public.temporal_coalesce(_table_name text, _group_columns text[], _where_clause text) OWNER TO postgres;

--
-- Name: temporal_intersects(timestamp without time zone, timestamp without time zone, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.temporal_intersects(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN 
    RETURN s1 < get_end_time(e2)  AND s2 < get_end_time(e1); 
END; 
$$;


ALTER FUNCTION public.temporal_intersects(s1 timestamp without time zone, e1 timestamp without time zone, s2 timestamp without time zone, e2 timestamp without time zone) OWNER TO postgres;

--
-- Name: temporal_join(text, text, text, text[], text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.temporal_join(_table1 text, _table2 text, _join_column text, _columns_t1 text[], _columns_t2 text[]) RETURNS TABLE(data jsonb, validstart_t1 timestamp without time zone, validend_t1 timestamp without time zone, validstart_t2 timestamp without time zone, validend_t2 timestamp without time zone)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    _select_t1 TEXT;
    _select_t2 TEXT;
BEGIN
    _select_t1 := (
        SELECT string_agg(format('''%s'', t1.%I', col, col), ', ')
        FROM unnest(_columns_t1) col
    );
    
    _select_t2 := (
        SELECT string_agg(format('''%s'', t2.%I', col, col), ', ')
        FROM unnest(_columns_t2) col
    );

    RETURN QUERY EXECUTE format(
        'SELECT 
            jsonb_build_object(%s, %s) as data,
            t1.validstart as ValidStart_T1,
            t1.validend as ValidEnd_T1,
            t2.validstart as ValidStart_T2,
            t2.validend as ValidEnd_T2
         FROM %I t1
         INNER JOIN %I t2 ON t1.%I = t2.%I
         WHERE temporal_intersects(t1.validstart, t1.validend, t2.validstart, t2.validend)
         ORDER BY t1.validstart, t2.validstart',
        _select_t1, _select_t2,
        _table1, _table2, _join_column, _join_column
    );
END;
$$;


ALTER FUNCTION public.temporal_join(_table1 text, _table2 text, _join_column text, _columns_t1 text[], _columns_t2 text[]) OWNER TO postgres;

--
-- Name: temporal_projection(text, text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.temporal_projection(_table_name text, _columns text[]) RETURNS TABLE(data jsonb, validstart timestamp without time zone, validend timestamp without time zone)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    _cols_json TEXT;
BEGIN
    _cols_json := (
        SELECT string_agg(format('''%s'', %I', col, col), ', ')
        FROM unnest(_columns) col
    );

    RETURN QUERY EXECUTE format(
        'SELECT jsonb_build_object(%s) as data, validstart, validend
         FROM %I
         ORDER BY validstart',
        _cols_json, _table_name
    );
END;
$$;


ALTER FUNCTION public.temporal_projection(_table_name text, _columns text[]) OWNER TO postgres;

--
-- Name: temporal_selection(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.temporal_selection(_table_name text, _where_condition text) RETURNS TABLE(data jsonb, validstart timestamp without time zone, validend timestamp without time zone)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN QUERY EXECUTE format(
        'SELECT row_to_json(t.*)::jsonb as data, t.validstart, t.validend
         FROM %I t
         WHERE %s
         ORDER BY validstart',
        _table_name, _where_condition
    );
END;
$$;


ALTER FUNCTION public.temporal_selection(_table_name text, _where_condition text) OWNER TO postgres;

--
-- Name: temporal_set_difference(text, text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.temporal_set_difference(_table_name text, _id_column text, _condition_include text, _condition_exclude text) RETURNS TABLE(data jsonb, validstart timestamp without time zone, validend timestamp without time zone)
    LANGUAGE plpgsql STABLE
    AS $_$
BEGIN
  RETURN QUERY EXECUTE format(
    $q$
    WITH
    set_a AS (
      SELECT
        %1$I AS id,
        row_to_json(t.*)::jsonb AS data,
        tsrange(
          t.validstart,
          COALESCE(t.validend, 'infinity'::timestamp),
          '[)'
        ) AS a_rng
      FROM %2$I t
      WHERE %3$s
    ),
    set_b AS (
      SELECT
        %1$I AS id,
        tsrange(
          t.validstart,
          COALESCE(t.validend, 'infinity'::timestamp),
          '[)'
        ) AS b_rng
      FROM %2$I t
      WHERE %4$s
    ),
    b_merged AS (
      SELECT
        id,
        range_agg(b_rng) AS b_mr
      FROM set_b
      GROUP BY id
    ),
    diff AS (
      SELECT
        a.data,
        (a.a_rng::tsmultirange - COALESCE(b.b_mr, '{}'::tsmultirange)) AS diff_mr
      FROM set_a a
      LEFT JOIN b_merged b USING (id)
    )
    SELECT
      data,
      lower(rng) AS validstart,
      NULLIF(upper(rng), 'infinity'::timestamp) AS validend
    FROM diff
    CROSS JOIN LATERAL unnest(diff_mr) AS rng
    ORDER BY validstart
    $q$,
    _id_column,
    _table_name,
    _condition_include,
    _condition_exclude
  );
END;
$_$;


ALTER FUNCTION public.temporal_set_difference(_table_name text, _id_column text, _condition_include text, _condition_exclude text) OWNER TO postgres;

--
-- Name: temporal_speed(text, text, integer, text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.temporal_speed(_table_name text, _id_col text, _id_val integer, _target_col text, _start_time timestamp without time zone, _end_time timestamp without time zone) RETURNS double precision
    LANGUAGE plpgsql STABLE
    AS $$
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
$$;


ALTER FUNCTION public.temporal_speed(_table_name text, _id_col text, _id_val integer, _target_col text, _start_time timestamp without time zone, _end_time timestamp without time zone) OWNER TO postgres;

--
-- Name: temporal_timeslice(text, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.temporal_timeslice(_table_name text, _timeslice timestamp without time zone) RETURNS TABLE(data jsonb, validstart timestamp without time zone, validend timestamp without time zone)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN QUERY EXECUTE format(
        'SELECT row_to_json(t.*)::jsonb as data, t.validstart, t.validend
         FROM %I t
         WHERE t.validstart <= %L::TIMESTAMP
         AND (t.validend IS NULL OR t.validend > %L::TIMESTAMP)
         ORDER BY t.validstart',
        _table_name, _timeslice, _timeslice
    );
END;
$$;


ALTER FUNCTION public.temporal_timeslice(_table_name text, _timeslice timestamp without time zone) OWNER TO postgres;

--
-- Name: temporal_timeslice(text, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.temporal_timeslice(_table_name text, _timeslice timestamp with time zone) RETURNS TABLE(data jsonb, validstart timestamp without time zone, validend timestamp without time zone)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN QUERY 
    SELECT * FROM temporal_timeslice(_table_name, _timeslice::TIMESTAMP);
END;
$$;


ALTER FUNCTION public.temporal_timeslice(_table_name text, _timeslice timestamp with time zone) OWNER TO postgres;

--
-- Name: temporal_trend(text, text, integer, text, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.temporal_trend(_table_name text, _id_col text, _id_val integer, _target_col text, _start_time timestamp without time zone, _end_time timestamp without time zone) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
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
$$;


ALTER FUNCTION public.temporal_trend(_table_name text, _id_col text, _id_val integer, _target_col text, _start_time timestamp without time zone, _end_time timestamp without time zone) OWNER TO postgres;

--
-- Name: temporal_union(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.temporal_union(_table_name text, _condition1 text, _condition2 text) RETURNS TABLE(data jsonb, validstart timestamp without time zone, validend timestamp without time zone)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN QUERY EXECUTE format(
        '(SELECT row_to_json(t.*)::jsonb as data, t.validstart, t.validend
          FROM %I t
          WHERE %s)
         
         UNION
         
         (SELECT row_to_json(t.*)::jsonb as data, t.validstart, t.validend
          FROM %I t
          WHERE %s)
         
         ORDER BY validstart',
        _table_name, _condition1, _table_name, _condition2
    );
END;
$$;


ALTER FUNCTION public.temporal_union(_table_name text, _condition1 text, _condition2 text) OWNER TO postgres;

--
-- Name: updaterawatinap(integer, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updaterawatinap(p_idpasien integer, p_ruangperawatan character varying, p_diagnosis character varying, p_dokterpenanggungjawab character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.updaterawatinap(p_idpasien integer, p_ruangperawatan character varying, p_diagnosis character varying, p_dokterpenanggungjawab character varying) OWNER TO postgres;

--
-- Name: updatetandavital(integer, numeric, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatetandavital(p_idrawatinap integer, p_temperature numeric, p_systolic integer, p_diastolic integer, p_heartrate integer, p_respiratoryrate integer, p_spo2 integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM TandaVital
        WHERE IDRawatInap = p_IDRawatInap
          AND ValidEnd IS NULL
    ) THEN
        UPDATE TandaVital
        SET Temperature = p_Temperature,
            Systolic = p_Systolic,
            Diastolic = p_Diastolic,
            HeartRate = p_HeartRate,
            RespiratoryRate = p_RespiratoryRate,
            SPO2 = p_SPO2
        WHERE IDRawatInap = p_IDRawatInap
          AND ValidEnd IS NULL;
    END IF;
END;
$$;


ALTER FUNCTION public.updatetandavital(p_idrawatinap integer, p_temperature numeric, p_systolic integer, p_diastolic integer, p_heartrate integer, p_respiratoryrate integer, p_spo2 integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: pasien; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pasien (
    idpasien integer NOT NULL,
    nama character varying(250) NOT NULL,
    tanggallahir date NOT NULL,
    jeniskelamin character(1) NOT NULL,
    alamat character varying(250) NOT NULL,
    CONSTRAINT pasien_jeniskelamin_check CHECK ((jeniskelamin = ANY (ARRAY['L'::bpchar, 'P'::bpchar])))
);


ALTER TABLE public.pasien OWNER TO postgres;

--
-- Name: pasien_idpasien_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pasien_idpasien_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pasien_idpasien_seq OWNER TO postgres;

--
-- Name: pasien_idpasien_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pasien_idpasien_seq OWNED BY public.pasien.idpasien;


--
-- Name: rawatinap; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rawatinap (
    idrawatinap integer NOT NULL,
    idpasien integer NOT NULL,
    ruangperawatan character varying(100) NOT NULL,
    diagnosis character varying(500),
    dokterpenanggungjawab character varying(250),
    validstart timestamp without time zone NOT NULL,
    validend timestamp without time zone,
    CONSTRAINT chk_rawatinap_time CHECK (((validend IS NULL) OR (validend > validstart)))
);


ALTER TABLE public.rawatinap OWNER TO postgres;

--
-- Name: rawatinap_idrawatinap_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rawatinap_idrawatinap_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rawatinap_idrawatinap_seq OWNER TO postgres;

--
-- Name: rawatinap_idrawatinap_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rawatinap_idrawatinap_seq OWNED BY public.rawatinap.idrawatinap;


--
-- Name: tandavital; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tandavital (
    idvital integer NOT NULL,
    idrawatinap integer,
    temperature numeric(4,2) NOT NULL,
    systolic integer NOT NULL,
    diastolic integer NOT NULL,
    heartrate integer NOT NULL,
    respiratoryrate integer NOT NULL,
    spo2 integer NOT NULL,
    validstart timestamp without time zone NOT NULL,
    validend timestamp without time zone,
    CONSTRAINT chk_vital_time CHECK (((validend IS NULL) OR (validend > validstart)))
);


ALTER TABLE public.tandavital OWNER TO postgres;

--
-- Name: tandavital_idvital_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tandavital_idvital_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tandavital_idvital_seq OWNER TO postgres;

--
-- Name: tandavital_idvital_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tandavital_idvital_seq OWNED BY public.tandavital.idvital;


--
-- Name: pasien idpasien; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pasien ALTER COLUMN idpasien SET DEFAULT nextval('public.pasien_idpasien_seq'::regclass);


--
-- Name: rawatinap idrawatinap; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rawatinap ALTER COLUMN idrawatinap SET DEFAULT nextval('public.rawatinap_idrawatinap_seq'::regclass);


--
-- Name: tandavital idvital; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tandavital ALTER COLUMN idvital SET DEFAULT nextval('public.tandavital_idvital_seq'::regclass);


--
-- Name: pasien pasien_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pasien
    ADD CONSTRAINT pasien_pkey PRIMARY KEY (idpasien);


--
-- Name: rawatinap rawatinap_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rawatinap
    ADD CONSTRAINT rawatinap_pkey PRIMARY KEY (idrawatinap);


--
-- Name: tandavital tandavital_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tandavital
    ADD CONSTRAINT tandavital_pkey PRIMARY KEY (idvital);


--
-- Name: rawatinap rawatinap_idpasien_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rawatinap
    ADD CONSTRAINT rawatinap_idpasien_fkey FOREIGN KEY (idpasien) REFERENCES public.pasien(idpasien);


--
-- Name: tandavital tandavital_idrawatinap_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tandavital
    ADD CONSTRAINT tandavital_idrawatinap_fkey FOREIGN KEY (idrawatinap) REFERENCES public.rawatinap(idrawatinap);


--
-- PostgreSQL database dump complete
--

