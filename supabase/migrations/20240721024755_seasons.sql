--- seasons
CREATE TABLE IF NOT EXISTS "seasons"
(
    "id"         uuid        DEFAULT uuid_generate_v4() NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT NOW()              NOT NULL,
    "name"       varchar(255)                           NOT NULL,
    "owner"      uuid                                   NOT NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("owner") REFERENCES "auth"."users" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO "seasons" ("name", "owner")
SELECT 'Fall ''24', "id"
FROM "auth"."users";

-- weeks/blocks
ALTER TABLE "blocks"
    RENAME TO "weeks";
ALTER TABLE "weeks"
    ADD COLUMN "season_id" uuid;
UPDATE "weeks"
SET "season_id" = s."id"
FROM "seasons" s
WHERE "weeks"."owner" = s."owner"
  AND s."name" = 'Fall ''24';
ALTER TABLE "weeks"
    ALTER COLUMN "season_id" SET NOT NULL;
ALTER TABLE "weeks"
    ADD CONSTRAINT "weeks_season_id_fkey"
        FOREIGN KEY ("season_id") REFERENCES "seasons" ("id")
            ON UPDATE CASCADE ON DELETE CASCADE;

-- tasks
ALTER TABLE "tasks"
    DROP CONSTRAINT "tasks_block_id_fkey";
ALTER TABLE "tasks"
    RENAME COLUMN "block_id" TO "week_id";
ALTER TABLE "tasks"
    ADD CONSTRAINT "tasks_week_id_fkey"
        FOREIGN KEY ("week_id") REFERENCES "weeks" ("id")
            ON UPDATE CASCADE ON DELETE CASCADE;


--- consolidate RLS to the season's owner field

--- drop unneeded owner fields
DROP VIEW IF EXISTS numbered_blocks;
DROP POLICY "Only authenticated users can modify blocks" ON "weeks";
DROP POLICY "Users can only modify, view their own blocks" ON "weeks";
DROP POLICY "Only authenticated users can modify tasks" ON "tasks";
DROP POLICY "Users can only modify their own tasks" ON "tasks";
ALTER TABLE "weeks"
    DROP COLUMN "owner";
ALTER TABLE "tasks"
    DROP COLUMN "owner";

ALTER TABLE "seasons"
    ENABLE ROW LEVEL SECURITY;
create policy "Only authenticated users can modify seasons"
    on "public"."seasons"
    as restrictive
    for all
    to authenticated;

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
