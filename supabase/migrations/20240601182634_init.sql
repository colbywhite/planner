-- block
CREATE TABLE IF NOT EXISTS "blocks"
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

ALTER TABLE "blocks" ENABLE ROW LEVEL SECURITY;

create policy "Only authenticated users can modify blocks"
    on "public"."blocks"
    as restrictive
    for all
    to authenticated;

create policy "Users can only modify, view their own blocks"
    on "public"."blocks"
    as permissive
    for all
    to authenticated
    using (auth.uid() = owner)
    with check (auth.uid() = owner);

-- task
CREATE TABLE IF NOT EXISTS "tasks"
(
    "id" uuid DEFAULT uuid_generate_v4() NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    "name"       varchar(255) NOT NULL,
    "owner"      uuid         NOT NULL,
    "block_id"   uuid         NOT NULL,
    "emoji"      CHAR(1)      NOT NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY ("owner") REFERENCES "auth"."users" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY ("block_id") REFERENCES "blocks" ("id")
        ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE "tasks" ENABLE ROW LEVEL SECURITY;

create policy "Only authenticated users can modify tasks"
on "public"."tasks"
as restrictive
for all
to authenticated;

create policy "Users can only modify their own tasks"
on "public"."tasks"
as permissive
for all
to authenticated
using (auth.uid() = owner)
with check (auth.uid() = owner);

