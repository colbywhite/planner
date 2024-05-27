import type {APIRoute} from "astro";
import {signOut} from "../../services/auth.service";
import {createSupabaseClient} from "../../services/supabase.service.ts";

export const GET: APIRoute = async ({redirect, cookies}) => {
    const client = createSupabaseClient(cookies)
    await signOut(client)
    return redirect('/')
}
