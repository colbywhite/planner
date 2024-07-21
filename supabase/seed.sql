INSERT INTO "auth"."users" (id,
                            instance_id,
                            aud,
                            role,
                            email,
                            encrypted_password,
                            email_confirmed_at,
                            invited_at,
                            confirmation_token,
                            confirmation_sent_at,
                            recovery_token,
                            recovery_sent_at,
                            email_change_token_new,
                            email_change,
                            email_change_sent_at,
                            last_sign_in_at,
                            raw_app_meta_data,
                            raw_user_meta_data,
                            is_super_admin,
                            created_at,
                            updated_at,
                            phone,
                            phone_confirmed_at,
                            phone_change,
                            phone_change_token,
                            phone_change_sent_at,
                            email_change_token_current,
                            email_change_confirm_status,
                            banned_until,
                            reauthentication_token,
                            reauthentication_sent_at,
                            is_sso_user,
                            deleted_at,
                            is_anonymous)
VALUES (uuid_generate_v4(), -- id
        '00000000-0000-0000-0000-000000000000', -- instance_id
        'authenticated', -- aud
        'authenticated', -- role
        'dev@colbywhite.dev', -- email
        '', -- encrypted_password
        CURRENT_TIMESTAMP, -- email_confirmed_at
        NULL, -- invited_at
        '', -- confirmation_token
        NULL, -- confirmation_sent_at
        '', -- recovery_token
        NULL, -- recovery_sent_at
        '', -- email_change_token_new
        '', -- email_change
        NULL, -- email_change_sent_at
        CURRENT_TIMESTAMP, -- last_sign_in_at
        '{
          "provider": "github",
          "providers": [
            "github"
          ]
        }', -- raw_app_meta_data
        '{
          "iss": "https://api.github.com",
          "sub": "3979735",
          "name": "Colby M. White",
          "email": "dev@colbywhite.dev",
          "full_name": "Colby M. White",
          "user_name": "colbywhite",
          "avatar_url": "https://avatars.githubusercontent.com/u/3979735?v=4",
          "provider_id": "3979735",
          "email_verified": true,
          "phone_verified": false,
          "preferred_username": "colbywhite"
        }', -- raw_user_meta_data
        NULL, -- is_super_admin
        CURRENT_TIMESTAMP, -- created_at
        CURRENT_TIMESTAMP, -- updated_at
        NULL, -- phone
        NULL, -- phone_confirmed_at
        '', -- phone_change
        '', -- phone_change_token
        NULL, -- phone_change_sent_at
        '', -- email_change_token_current
        0, -- email_change_confirm_status
        NULL, -- banned_until
        '', -- reauthentication_token
        NULL, -- reauthentication_sent_at
        FALSE, -- is_sso_user
        NULL, -- deleted_at
        FALSE -- is_anonymous
       );

INSERT INTO "seasons" ("name", "owner")
SELECT 'Fall ''24', "id"
FROM "auth"."users";

INSERT INTO "weeks" ("start", "end", "season_id")
SELECT (CURRENT_DATE at time zone 'America/Chicago')::date - 7, (CURRENT_DATE at time zone 'America/Chicago')::date - 1, "id"
FROM "seasons";

INSERT INTO "weeks" ("start", "end", "subtitle", "season_id")
SELECT (CURRENT_DATE at time zone 'America/Chicago')::date, (CURRENT_DATE at time zone 'America/Chicago')::date + 6, 'This week', "id"
FROM "seasons";

INSERT INTO "weeks" ("start", "end", "season_id")
SELECT (CURRENT_DATE at time zone 'America/Chicago')::date + 7, (CURRENT_DATE at time zone 'America/Chicago')::date + 13, "id"
FROM "seasons";

INSERT INTO "tasks" ("emoji", "name", "week_id")
SELECT '🔵', 'Duis porttitor massa nec odio lobortis lobortis', "id"
FROM "numbered_weeks"
WHERE number = 1;

INSERT INTO "tasks" ("emoji", "name", "week_id")
SELECT '🟠', 'Proin aliquet ligula a mattis mollis', "id"
FROM "numbered_weeks"
WHERE number = 1;

INSERT INTO "tasks" ("emoji", "name", "week_id")
SELECT '🔵', 'Maecenas quis ipsum cursus, euismod sapien semper, porttitor nisi', "id"
FROM "numbered_weeks"
WHERE number = 2;

INSERT INTO "tasks" ("emoji", "name", "week_id")
SELECT '🟠',
       'Nulla pharetra, magna eget fringilla faucibus, nisi eros malesuada lacus, et mattis felis mauris eget libero',
       "id"
FROM "numbered_weeks"
WHERE number = 2;

INSERT INTO "tasks" ("emoji", "name", "week_id")
SELECT '🔵', 'Vestibulum nisl erat, gravida non ultrices et, luctus at nisi', "id"
FROM "numbered_weeks"
WHERE number = 3;

INSERT INTO "tasks" ("emoji", "name", "week_id")
SELECT '🟠', 'Mauris turpis eros, mattis ut nunc eu, mattis euismod nibh', "id"
FROM "numbered_weeks"
WHERE number = 3;
