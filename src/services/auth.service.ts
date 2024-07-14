import {createSupabaseClient} from "./supabase.service";

export async function signInWithGithub(client: ReturnType<typeof createSupabaseClient>, origin: string) {
    const {data, error} = await client.auth.signInWithOAuth({
        provider: 'github',
        options: {
            redirectTo: new URL('/auth/callback', origin).toString(),
        },
    })
    if (error) {
        throw error
    }
    return data.url
}

export async function signOut(client: ReturnType<typeof createSupabaseClient>) {
    const {error} = await client.auth.signOut()
    if (error) {
        throw error
    }
}
