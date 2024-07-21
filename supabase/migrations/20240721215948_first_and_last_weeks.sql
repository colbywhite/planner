CREATE OR REPLACE FUNCTION get_closest_week_id(date DATE)
    RETURNS UUID AS $BODY$
DECLARE
    closest_week_id UUID;
BEGIN
    SELECT w.id
    INTO closest_week_id
    FROM weeks w
    ORDER BY LEAST(
                     ABS(w.start - date),
                     ABS(w.end - date)
             )
    LIMIT 1;

    RETURN closest_week_id;
END;
$BODY$ LANGUAGE plpgsql;
