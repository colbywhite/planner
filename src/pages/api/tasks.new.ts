import type {APIRoute} from "astro";
import {BlockService} from "../../services/block.service";
import {parseStringFromFormData} from "../../utils.ts";

export const POST: APIRoute = async ({request, cookies, redirect}) => {
    const formData = await request.formData()
    const redirectPath = request.headers.get('referer') || '/'

    // TODO: better validation
    const emoji = parseStringFromFormData(formData, 'emoji')
    const name = parseStringFromFormData(formData, 'name')
    const block_id = parseStringFromFormData(formData, 'block_id')
    const input = {emoji, name, block_id}
    await new BlockService(cookies).createTask(input)
    return redirect(redirectPath)
}
