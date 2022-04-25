
SELECT ARRAY['a']
UNION
SELECT ARRAY['a']
UNION
SELECT ARRAY['b', 'a']
UNION
SELECT ARRAY['a', 'b']
;




SELECT hstore('a', '')
UNION
SELECT hstore('a', '')
UNION
SELECT hstore('a', '') || hstore('b', '')
UNION
SELECT hstore('a', '') || hstore('b', '')
UNION
SELECT hstore('b', '') || hstore('a', '')
UNION
SELECT hstore('b', '') || hstore('b', '') || hstore('a', '')
;



WITH 
    ignore_table(id, number) AS
    (
        SELECT '1', 1
        UNION
        SELECT '2', 2
    ),
    data_table(id, number, name) AS
    (
        SELECT '1', 1, 'name1'
        UNION
        SELECT '2', 1, 'name2'
        UNION
        SELECT '1', 2, 'name3'
        UNION
        SELECT '2', 2, 'name4'
    ),
    target_ids(id, number) AS 
    (
        SELECT id, number FROM data_table
        EXCEPT
        SELECT id, number FROM ignore_table
    )
SELECT *
FROM data_table T
    RIGHT JOIN target_ids D
        ON T.id = D.id AND T.number = D.number;


WITH 
    geom_table(point1, line1) AS
    (
        SELECT
            ST_Transform(ST_SetSRID(ST_POINT(139.717, 35.633), 4326), 3857) AS point1,
            ST_Transform(ST_SetSRID(ST_MakeLine(ST_POINT(139.717, 35.640), ST_POINT(139.717, 35.650)), 4326), 3857) AS line1
    ),
    merged_table(union_geom, collect_geom) AS
    (
        SELECT
            ST_Union(T.point1, T.line1),
            ST_Collect(T.point1, T.line1)
        FROM geom_table T
    )
SELECT
    ST_AsText(union_geom),
    ST_AsText(collect_geom),
    ST_MemSize(union_geom) AS union_size,
    ST_MemSize(collect_geom) AS collect_size,
    ST_MemSize(ST_Union(collect_geom, collect_geom)) AS collect_and_union_size
FROM merged_table T;
