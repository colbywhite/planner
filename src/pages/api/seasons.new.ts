import type {APIRoute} from "astro";
import {parseDateTimeFromFormData, parseStringFromFormData} from "../../utils";
import {SeasonService} from "../../services/season.service";

export const POST: APIRoute = async ({request, cookies, redirect}) => {
    const formData = await request.formData()

    // TODO: better validation
    const name = parseStringFromFormData(formData, 'name')
    const start = parseDateTimeFromFormData(formData, 'start')
    const end = parseDateTimeFromFormData(formData, 'end')
    if (name === undefined || !start.isValid || !end.isValid || start >= end) {
        throw new Error('Bad input')
    }
    const season = await new SeasonService(cookies).createSeason({name, start, end})
    return redirect(`/${season.id}`)
}
