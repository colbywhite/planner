DROP FUNCTION get_closest_week_id(date DATE);

CREATE OR REPLACE FUNCTION get_closest_week_id(date DATE, seasonName VARCHAR)
    RETURNS UUID AS
$BODY$
DECLARE
    closest_week_id UUID;
BEGIN
    SELECT w.id
    INTO closest_week_id
    FROM weeks w
             JOIN seasons s ON w.season_id = s.id
    WHERE s.name = seasonName
    ORDER BY LEAST(
                     ABS(w.start - date),
                     ABS(w.end - date)
             )
    LIMIT 1;

    RETURN closest_week_id;
END;
$BODY$ LANGUAGE plpgsql;
