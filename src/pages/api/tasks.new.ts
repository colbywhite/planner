import type {APIRoute} from "astro";
import {parseStringFromFormData} from "../../utils";
import {SeasonService} from "../../services/season.service";

export const POST: APIRoute = async ({request, cookies, redirect}) => {
    const formData = await request.formData()
    const redirectPath = request.headers.get('referer') || '/'

    // TODO: better validation
    const emoji = parseStringFromFormData(formData, 'emoji')
    const name = parseStringFromFormData(formData, 'name')
    const week_id = parseStringFromFormData(formData, 'week')
    const season_id = parseStringFromFormData(formData, 'season')
    if (emoji === undefined || name === undefined || week_id === undefined || season_id === undefined) {
        throw new Error('Bad input')
    }
    await new SeasonService(cookies, season_id).addTasks({emoji, name, week_id})
    return redirect(redirectPath)
}
