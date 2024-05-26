import type {APIRoute} from "astro";
import {signInWithGithub} from "../../services/auth.service";

export const GET: APIRoute = async ({request, redirect}) => {
    const redirectUrl = await signInWithGithub(request.url)
    return redirect(redirectUrl || '/')
}
