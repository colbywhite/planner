import type {APIRoute} from "astro";
import {signInWithGithub} from "../../services/auth.service";
import {createSupabaseClient} from "../../services/supabase.service";

export const GET: APIRoute = async ({request, cookies, redirect}) => {
    console.log('/auth/login', request.referrer, request.headers)
    const client = createSupabaseClient(cookies)
    const redirectUrl = await signInWithGithub(client, request.url)
    return redirect(redirectUrl || '/')
}
