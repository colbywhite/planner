import type {APIRoute} from "astro";
import {BlockService} from "../../services/block.service";
import {DateTime} from "luxon";

export const POST: APIRoute = async ({request, cookies, redirect}) => {
    const formData = await request.formData()

    // TODO: better validation
    const start = formData.get('start')
    if (typeof(start) !== 'string') {
        throw new Error("start must be a string");
    }
    const startDate = DateTime.fromISO(start)
    const endDate = startDate.plus({days: 6})
    const input = {
        start: startDate.toISODate(),
        end: endDate.toISODate()
    }
    const blockSvc = new BlockService(cookies);
    const {id} = await blockSvc.createBlock(input)
    const index = await blockSvc.getBlockIndex(id)
    return redirect(`/?block=${index + 1}`)
}
