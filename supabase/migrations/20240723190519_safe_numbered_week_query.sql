CREATE OR REPLACE FUNCTION safely_get_numbered_week(seasonName VARCHAR, weekNumber INT)
    RETURNS TABLE
            (
                id         UUID,
                created_at TIMESTAMP WITH TIME ZONE,
                start      DATE,
                "end"      DATE,
                subtitle   VARCHAR(255),
                season_id  UUID,
                total      BIGINT,
                number     BIGINT,
                tasks      JSONB,
                season     JSON
            )
AS
$BODY$
BEGIN
    RETURN QUERY
        SELECT nw.id,
               nw.created_at,
               nw.start,
               nw."end",
               nw.subtitle,
               nw.season_id,
               nw.total,
               nw.number,
               jsonb_agg(t.*)   AS tasks,
               row_to_json(s.*) AS season
        FROM numbered_weeks nw
                 JOIN seasons s ON nw.season_id = s.id
                 LEFT JOIN tasks t ON nw.id = t.week_id
        WHERE nw.number = LEAST(GREATEST(weekNumber, 1), nw.total)
          AND s.name = seasonName
        GROUP BY nw.id,
                 nw.created_at,
                 nw.start,
                 nw."end",
                 nw.subtitle,
                 nw.season_id,
                 nw.total,
                 nw.number,
                 s.id,
                 s.name,
                 s.created_at
        LIMIT 1;
END;
$BODY$ LANGUAGE plpgsql;
