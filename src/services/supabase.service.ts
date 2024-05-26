import {createClient} from '@supabase/supabase-js'

export const supabase = createClient(
    import.meta.env.PUBLIC_DB_URL,
    import.meta.env.PUBLIC_DB_KEY,
    {auth: {flowType: "pkce"}}
)
