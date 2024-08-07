import {type CookieOptions, createServerClient} from '@supabase/ssr'
import type {AstroCookies} from "astro";
import type {Database} from './database.types'


export function createSupabaseClient(cookies: AstroCookies) {
    return createServerClient<Database>(
        import.meta.env.PUBLIC_DB_URL,
        import.meta.env.PUBLIC_DB_KEY,
        {
            auth: {flowType: "pkce"},
            cookies: {
                get(key: string) {
                    return cookies.get(key)?.value;
                },
                set(key: string, value: string, options: CookieOptions) {
                    cookies.set(key, value, options);
                },
                remove(key: string, options) {
                    cookies.delete(key, options);
                },
            },
        }
    )
}
