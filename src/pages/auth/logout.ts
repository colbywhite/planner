import type {APIRoute} from "astro";
import {signOut} from "../../services/auth.service";

export const GET: APIRoute = async ({redirect}) => {
    await signOut()
    return redirect('/')
}
