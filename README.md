# planner

[AHA stack](https://ahastack.dev/) web app

# local dev

```shell
yarn dev
```

## setup

If using supabase locally, `supabase start` (or `supabase status`) will output the url and key.

```
         API URL: http://127.0.0.1:54321
         anon key: a.long.jwt
```

This would mean the following local env variables need to be set for local dev.


```dotenv
PUBLIC_DB_URL=http://localhost:54321
PUBLIC_DB_KEY=a.long.jwt
```

For local auth use a dev [GitHub app](https://github.com/settings/developers) and save credentials in env variables.

```dotenv
SUPABASE_AUTH_GITHUB_CLIENT_ID=A_GITHUB_APP_FOR_DEV
SUPABASE_AUTH_GITHUB_SECRET=A_GITHUB_SECRET_FOR_DEV
```


