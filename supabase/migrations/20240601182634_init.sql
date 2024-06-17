-- Task Type
CREATE TABLE IF NOT EXISTS "Task Type"
(
    "id" uuid DEFAULT uuid_generate_v4() NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    "name"       varchar(255) NOT NULL,
    "emoji"      CHAR(1) NOT NULL,
    "owner"      uuid         NOT NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("owner") REFERENCES "auth"."users" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE "Task Type" ENABLE ROW LEVEL SECURITY;

create policy "Only authenticated users can modify Task Type"
on "public"."Task Type"
as restrictive
for all
to authenticated;

create policy "Users can only modify their own Task Type."
on "public"."Task Type"
as permissive
for all
to authenticated
using (auth.uid() = owner)
with check (auth.uid() = owner);

-- Task
CREATE TABLE IF NOT EXISTS "Task"
(
    "id" uuid DEFAULT uuid_generate_v4() NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    "name"       varchar(255) NOT NULL,
    "type"       uuid         NOT NULL,
    "owner"      uuid         NOT NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("owner") REFERENCES "auth"."users" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY ("type") REFERENCES "Task Type" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE "Task" ENABLE ROW LEVEL SECURITY;

create policy "Only authenticated users can modify Task"
on "public"."Task"
as restrictive
for all
to authenticated;

create policy "Users can only modify their own Task."
on "public"."Task"
as permissive
for all
to authenticated
using (auth.uid() = owner)
with check (auth.uid() = owner);

-- Block
CREATE TABLE IF NOT EXISTS "Block"
(
    "id" uuid DEFAULT uuid_generate_v4() NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    "start" date NOT NULL,
    "end" date NOT NULL,
    "subtitle" varchar ( 255 ),
    "owner" uuid NOT NULL,
    PRIMARY KEY ( "id" ),
    FOREIGN KEY ( "owner" ) REFERENCES "auth"."users" ( "id" )
        ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE "Block" ENABLE ROW LEVEL SECURITY;

create policy "Only authenticated users can modify Block"
on "public"."Block"
as restrictive
for all
to authenticated;

create policy "Users can only modify, view their own Block"
on "public"."Block"
as permissive
for all
to authenticated
using (auth.uid() = owner)
with check (auth.uid() = owner);

CREATE TABLE IF NOT EXISTS "Tasks Per Block"
(
    "id" uuid DEFAULT uuid_generate_v4() NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    "task"       uuid        NOT NULL,
    "block"      uuid        NOT NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("block") REFERENCES "Block" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY ("task") REFERENCES "Task" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE "Tasks Per Block" ENABLE ROW LEVEL SECURITY;

create policy "Only authenticated users can modify Tasks Per Block"
on "public"."Tasks Per Block"
as restrictive
for all
to authenticated;

create policy "Users can only modify, view their own Tasks Per Block"
on "public"."Tasks Per Block"
as permissive
for all
to authenticated
USING (
    EXISTS (
        SELECT 1
        FROM "public"."Block" b
        JOIN "public"."Task" t ON t.id = task
        WHERE b.id = block
        AND t.owner = b.owner
        AND auth.uid() = t.owner
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM "public"."Block" b
        JOIN "public"."Task" t ON t.id = task
        WHERE b.id = block
        AND t.owner = b.owner
        AND auth.uid() = t.owner
    )
);
