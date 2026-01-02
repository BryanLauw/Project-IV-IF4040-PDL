/*
 * TEMPORAL COALESCE
 * 
 * Menggabungkan baris-baris temporal yang nilai non-temporalnya sama
 * dan intervalnya adjacent (ValidEnd_A = ValidStart_B) atau overlap.
 * 
 * Contoh: 3 record heartrate=85 jam 08-09, 09-10, 10-11 
 *         -> jadi 1 record jam 08-11 (coalesced_count=3)
 * 
 * NULL pada ValidEnd dianggap infinity.
 */


-- Generic coalesce untuk tabel apapun yang punya ValidStart/ValidEnd
-- Usage: SELECT * FROM temporal_coalesce('tandavital', ARRAY['heartrate'], 'idrawatinap = 224');
CREATE OR REPLACE FUNCTION temporal_coalesce(
    _table_name TEXT,
    _group_columns TEXT[],
    _where_clause TEXT DEFAULT NULL
)
RETURNS TABLE (
    data JSONB,
    validstart TIMESTAMP,
    validend TIMESTAMP,
    coalesced_count BIGINT
)
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
$$ LANGUAGE plpgsql STABLE;


-- Versi khusus TandaVital, return merged_ids buat tracking
-- Usage: SELECT * FROM coalesce_tandavital(224, ARRAY['heartrate']);
CREATE OR REPLACE FUNCTION coalesce_tandavital(
    _idrawatinap INT,
    _vital_columns TEXT[]
)
RETURNS TABLE (
    idrawatinap INT,
    vital_data JSONB,
    validstart TIMESTAMP,
    validend TIMESTAMP,
    coalesced_count BIGINT,
    merged_ids INT[]
)
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
$$ LANGUAGE plpgsql STABLE;
