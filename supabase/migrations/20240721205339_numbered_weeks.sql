CREATE VIEW numbered_weeks AS
SELECT
    w.*,
    COUNT(*) OVER (PARTITION BY w.season_id) AS total,
    ROW_NUMBER() OVER (PARTITION BY w.season_id ORDER BY w.start) AS number
FROM
    public.weeks w
        JOIN
    public.seasons s ON w.season_id = s.id;
