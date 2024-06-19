import {createSupabaseClient} from "./supabase.service";
import type {Database} from "./database.types";
import type {AstroCookies} from "astro";

export type BlockInsert = Exclude<Database.public.Tables.Block.Row, 'id' | 'owner' | 'created_at'>

export class BlockService {
    private client: ReturnType<typeof createSupabaseClient>

    public constructor(cookies: AstroCookies) {
        this.client = createSupabaseClient(cookies)
    }

    public async countBlocks() {
        const {count, error} = await this.client.from('Block')
            .select('*', {count: 'exact', head: true})
        if (error) {
            throw error
        }
        return count
    }

    public async getBlock(index: number) {
        const lastBlockIndex = (await this.countBlocks()) - 1;
        const safeIndex = Math.max(0, Math.min(index, lastBlockIndex))
        const previousIndex = safeIndex - 1 >= 0 ? safeIndex - 1 : undefined
        const nextIndex = safeIndex + 1 <= lastBlockIndex ? safeIndex + 1 : undefined

        const {data, error} = await this.client.from('Block')
            .select()
            .order('start', {ascending: true})
            .range(safeIndex, safeIndex + 1)
            .limit(1)
            .single()
        if (error) {
            throw error
        }
        return {block: data, index: safeIndex, previousIndex, nextIndex}
    }

    public async createBlock(block: BlockInsert) {
        const {data: {user}} = await this.client.auth.getUser()
        if (user === null) {
            throw new Error('No user found')
        }
        console.log('createBlock', {...block, owner: user.id})
        return this.client.from('Block')
            .insert({...block, owner: user.id})
            .select()
    }
}
