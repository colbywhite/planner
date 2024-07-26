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

DO
$BODY$
    DECLARE
        user_id          UUID;
        summer_season_id VARCHAR(255);
        fall_season_id   VARCHAR(255);
    BEGIN
        SELECT id INTO user_id FROM auth.users WHERE email = 'dev@colbywhite.dev';

        INSERT INTO "seasons" ("name", "owner")
        VALUES ('Summer ''24', user_id)
        RETURNING id INTO summer_season_id;
        INSERT INTO "seasons" ("name", "owner")
        VALUES ('Fall ''24', user_id)
        RETURNING id INTO fall_season_id;

        -- summer weeks
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-07-29', '2024-08-04', summer_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-08-05', '2024-08-11', summer_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-08-12', '2024-08-18', summer_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-08-19', '2024-08-25', summer_season_id);

        -- fall weeks
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-08-26', '2024-09-01', fall_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-09-02', '2024-09-08', fall_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-09-09', '2024-09-15', fall_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-09-16', '2024-09-22', fall_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-09-23', '2024-09-29', fall_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-09-30', '2024-10-06', fall_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-10-07', '2024-10-13', fall_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-10-14', '2024-10-20', fall_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-10-21', '2024-10-27', fall_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-10-28', '2024-11-03', fall_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id", subtitle)
        VALUES ('2024-11-04', '2024-11-10', fall_season_id, 'Spring registration');
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-11-11', '2024-11-17', fall_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-11-18', '2024-11-24', fall_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id", subtitle)
        VALUES ('2024-11-25', '2024-12-01', fall_season_id, 'Thanksgiving');
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-12-02', '2024-12-08', fall_season_id);
        INSERT INTO "weeks" ("start", "end", "season_id")
        VALUES ('2024-12-09', '2024-12-15', fall_season_id);

        -- summer tasks
        INSERT INTO "tasks" ("emoji", "name", "week_id")
        SELECT '🔵', 'Duis porttitor massa nec odio lobortis lobortis', "id"
        FROM "numbered_weeks"
        WHERE number = 1
          AND season_id = summer_season_id;
        INSERT INTO "tasks" ("emoji", "name", "week_id")
        SELECT '🟠', 'Proin aliquet ligula a mattis mollis', "id"
        FROM "numbered_weeks"
        WHERE number = 2
          AND season_id = summer_season_id;

        -- fall tasks
        INSERT INTO "tasks" ("emoji", "name", "week_id")
        SELECT '🔵', 'Maecenas quis ipsum cursus, euismod sapien semper, porttitor nisi', "id"
        FROM "numbered_weeks"
        WHERE number = 1
          AND season_id = fall_season_id;
        INSERT INTO "tasks" ("emoji", "name", "week_id")
        SELECT '🟠',
               'Nulla pharetra, magna eget fringilla faucibus, nisi eros malesuada lacus, et mattis felis mauris eget libero',
               "id"
        FROM "numbered_weeks"
        WHERE number = 1
          AND season_id = fall_season_id;
        INSERT INTO "tasks" ("emoji", "name", "week_id")
        SELECT '🔵', 'Vestibulum nisl erat, gravida non ultrices et, luctus at nisi', "id"
        FROM "numbered_weeks"
        WHERE number = 2
          AND season_id = fall_season_id;
        INSERT INTO "tasks" ("emoji", "name", "week_id")
        SELECT '🟠', 'Mauris turpis eros, mattis ut nunc eu, mattis euismod nibh', "id"
        FROM "numbered_weeks"
        WHERE number = 2
          AND season_id = fall_season_id;
    END
$BODY$;
