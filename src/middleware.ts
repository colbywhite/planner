import {defineMiddleware} from "astro:middleware";
import {createSupabaseClient} from "./services/supabase.service";

const LOGIN_ROUTE = '/login' as const
const AUTH_PARENT_ROUTE = '/auth' as const

export const onRequest = defineMiddleware(async ({url: {pathname}, redirect, cookies, locals}, next) => {
    console.log('middleware', {pathname, locals})
    if (pathname === LOGIN_ROUTE || pathname.startsWith(AUTH_PARENT_ROUTE)) {
        return next()
    }
    const client = createSupabaseClient(cookies)
    const {data: {user}} = await client.auth.getUser()
    console.log('middleware', {pathname, user, locals})
    if (user === null) {
        return redirect(LOGIN_ROUTE)
    }
    locals.user = user
    return next();
});
