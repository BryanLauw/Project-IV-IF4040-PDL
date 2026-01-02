-- Helper function to handle NULL as infinity
CREATE OR REPLACE FUNCTION get_end_time(ts TIMESTAMP) 
RETURNS TIMESTAMP AS $$
BEGIN
    RETURN COALESCE(ts, 'infinity'::TIMESTAMP);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Helper function to check temporal intersection
CREATE OR REPLACE FUNCTION temporal_intersects(s1 TIMESTAMP, e1 TIMESTAMP, s2 TIMESTAMP, e2 TIMESTAMP) 
RETURNS BOOLEAN AS $$
BEGIN 
    RETURN s1 < get_end_time(e2) AND s2 < get_end_time(e1); 
END; 
$$ LANGUAGE plpgsql IMMUTABLE;


-- ============================================
-- 1. TEMPORAL PROJECTION
-- ============================================
CREATE OR REPLACE FUNCTION temporal_projection(
    _table_name TEXT,
    _columns TEXT[]
)
RETURNS TABLE (
    data JSONB,
    ValidStart TIMESTAMP,
    ValidEnd TIMESTAMP
)
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
$$ LANGUAGE plpgsql STABLE;


-- ============================================
-- 2. TEMPORAL SELECTION
-- ============================================
CREATE OR REPLACE FUNCTION temporal_selection(
    _table_name TEXT,
    _where_condition TEXT
)
RETURNS TABLE (
    data JSONB,
    ValidStart TIMESTAMP,
    ValidEnd TIMESTAMP
)
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
$$ LANGUAGE plpgsql STABLE;


-- ============================================
-- 3. TEMPORAL UNION
-- ============================================
CREATE OR REPLACE FUNCTION temporal_union(
    _table_name TEXT,
    _condition1 TEXT,
    _condition2 TEXT
)
RETURNS TABLE (
    data JSONB,
    ValidStart TIMESTAMP,
    ValidEnd TIMESTAMP
)
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
$$ LANGUAGE plpgsql STABLE;


-- ============================================
-- 4. TEMPORAL SET DIFFERENCE
-- ============================================
CREATE OR REPLACE FUNCTION temporal_set_difference(
    _table_name TEXT,
    _id_column TEXT,
    _condition_include TEXT,
    _condition_exclude TEXT
)
RETURNS TABLE (
    data JSONB,
    validstart TIMESTAMP,
    validend TIMESTAMP
)
AS $$
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
$$ LANGUAGE plpgsql STABLE;



-- ============================================
-- 5. TEMPORAL JOIN
-- ============================================
CREATE OR REPLACE FUNCTION temporal_join(
    _table1 TEXT,
    _table2 TEXT,
    _join_column TEXT,
    _columns_t1 TEXT[],
    _columns_t2 TEXT[]
)
RETURNS TABLE (
    data JSONB,
    ValidStart_T1 TIMESTAMP,
    ValidEnd_T1 TIMESTAMP,
    ValidStart_T2 TIMESTAMP,
    ValidEnd_T2 TIMESTAMP
)
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
$$ LANGUAGE plpgsql STABLE;


-- ============================================
-- 6. TEMPORAL TIMESLICE
-- ============================================
CREATE OR REPLACE FUNCTION temporal_timeslice(
    _table_name TEXT,
    _timeslice TIMESTAMP
)
RETURNS TABLE (
    data JSONB,
    validstart TIMESTAMP,
    validend TIMESTAMP
)
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
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION temporal_timeslice(
    _table_name TEXT,
    _timeslice TIMESTAMPTZ
)
RETURNS TABLE (
    data JSONB,
    validstart TIMESTAMP,
    validend TIMESTAMP
)
AS $$
BEGIN
    RETURN QUERY 
    SELECT * FROM temporal_timeslice(_table_name, _timeslice::TIMESTAMP);
END;
$$ LANGUAGE plpgsql STABLE;


-- ============================================
-- VERIFICATION
-- ============================================

SELECT 
    'General Temporal Operations Installed' as Status,
    COUNT(*) as Count
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'temporal_projection',
    'temporal_selection',
    'temporal_union',
    'temporal_set_difference',
    'temporal_join',
    'temporal_timeslice',
    'get_end_time',
    'temporal_intersects'
  );