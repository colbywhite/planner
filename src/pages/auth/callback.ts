import {type APIRoute} from 'astro'
import {createSupabaseClient} from "../../services/supabase.service";

export const GET: APIRoute = async ({request, cookies, redirect}) => {
    const client = createSupabaseClient(cookies)
    const requestUrl = new URL(request.url)
    const code = requestUrl.searchParams.get('code')
    const next = requestUrl.searchParams.get('next') || '/'

    if (!code) {
        return new Response("No code provided", {status: 400});
    }

    const {error} = await client.auth.exchangeCodeForSession(code)
    if (error) {
        console.error("Could not create session", error)
        return new Response("Could not create session", {status: 500});
    }
    return redirect(next)
}
