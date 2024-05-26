import {supabase} from "./supabase.service.ts";

export async function signInWithGithub(origin: string) {
    const {data, error} = await supabase.auth.signInWithOAuth({
        provider: 'github',
        options: {
            redirectTo: new URL('/auth/callback', origin).toString(),
        },
    })
    return data.url
}

export async function signOut() {
    const {error} = await supabase.auth.signOut()
}
