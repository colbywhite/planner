CREATE OR REPLACE FUNCTION url_friendly_text(text TEXT) RETURNS TEXT AS
$BODY$
DECLARE
    url_friendly_text TEXT;
BEGIN
    -- replace non-alphanumeric chars with underscore
    url_friendly_text := regexp_replace(lower(text), '[^a-z0-9]+', '_', 'g');
    -- trim trailing/leading underscores
    url_friendly_text := regexp_replace(url_friendly_text, '^_|_$', '', 'g');
    RETURN url_friendly_text;
END;
$BODY$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_url_friendly_id() RETURNS TRIGGER AS
$BODY$
BEGIN
    NEW.id := url_friendly_text(NEW.name);
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql;

-- handle dependencies
ALTER TABLE "weeks"
    DROP CONSTRAINT IF EXISTS weeks_season_id_fkey;
ALTER TABLE "seasons"
    DROP CONSTRAINT IF EXISTS seasons_pkey;
DROP POLICY IF EXISTS "Users can modify weeks only for their own seasons" ON weeks;
DROP POLICY IF EXISTS "Users can modify tasks only for their own seasons" ON tasks;
DROP VIEW IF EXISTS numbered_weeks;

ALTER TABLE "seasons"
    ALTER COLUMN "id" SET DATA TYPE VARCHAR(255),
    ALTER COLUMN "id" DROP DEFAULT;
ALTER TABLE weeks
    ALTER COLUMN season_id SET DATA TYPE VARCHAR(255);

-- update season id values
UPDATE "weeks"
SET season_id = url_friendly_text((SELECT name FROM "seasons" WHERE "seasons".id = "weeks".season_id));
UPDATE "seasons"
SET id = url_friendly_text("name");

-- trigger to auto generate the id based on name
CREATE TRIGGER set_url_friendly_id_trigger
    BEFORE INSERT
    ON "seasons"
    FOR EACH ROW
EXECUTE FUNCTION set_url_friendly_id();

-- bring back dependencies
ALTER TABLE "seasons"
    ADD PRIMARY KEY ("id");
ALTER TABLE "weeks"
    ADD CONSTRAINT weeks_season_id_fkey FOREIGN KEY ("season_id") REFERENCES "seasons" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE;
CREATE POLICY "Users can modify weeks only for their own seasons"
    ON "weeks"
    AS PERMISSIVE
    FOR ALL
    TO authenticated
    USING (EXISTS (SELECT 1
                   FROM "seasons"
                   WHERE "seasons"."id" = "weeks"."season_id"
                     AND "seasons"."owner" = auth.uid()))
    WITH CHECK (EXISTS (SELECT 1
                        FROM "seasons"
                        WHERE "seasons"."id" = "weeks"."season_id"
                          AND "seasons"."owner" = auth.uid()));
CREATE POLICY "Users can modify tasks only for their own seasons"
    ON "tasks"
    AS PERMISSIVE
    FOR ALL
    TO authenticated
    USING (EXISTS (SELECT 1
                   FROM "weeks"
                            JOIN "seasons" ON "weeks"."season_id" = "seasons"."id"
                   WHERE "weeks"."id" = "tasks"."week_id"
                     AND "seasons"."owner" = auth.uid()))
    WITH CHECK (EXISTS (SELECT 1
                        FROM "weeks"
                                 JOIN "seasons" ON "weeks"."season_id" = "seasons"."id"
                        WHERE "weeks"."id" = "tasks"."week_id"
                          AND "seasons"."owner" = auth.uid()));
CREATE VIEW numbered_weeks AS
SELECT
    w.*,
    COUNT(*) OVER (PARTITION BY w.season_id) AS total,
    ROW_NUMBER() OVER (PARTITION BY w.season_id ORDER BY w.start) AS number
FROM
    public.weeks w
        JOIN
    public.seasons s ON w.season_id = s.id;

-- update functions using season names
DROP FUNCTION safely_get_numbered_week(seasonName VARCHAR, weekNumber INT);
CREATE OR REPLACE FUNCTION safely_get_numbered_week(seasonId VARCHAR, weekNumber INT)
    RETURNS TABLE
            (
                id         UUID,
                created_at TIMESTAMP WITH TIME ZONE,
                start      DATE,
                "end"      DATE,
                subtitle   VARCHAR(255),
                season_id  VARCHAR(255),
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
          AND nw.season_id = seasonId
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


DROP FUNCTION get_closest_week_id(date DATE, seasonName VARCHAR);
CREATE OR REPLACE FUNCTION get_closest_week_id(date DATE, seasonId VARCHAR)
    RETURNS UUID AS
$BODY$
DECLARE
    closest_week_id UUID;
BEGIN
    SELECT w.id
    INTO closest_week_id
    FROM weeks w
    WHERE w.season_id = seasonId
    ORDER BY LEAST(
                     ABS(w.start - date),
                     ABS(w.end - date)
             )
    LIMIT 1;

    RETURN closest_week_id;
END;
$BODY$ LANGUAGE plpgsql;
