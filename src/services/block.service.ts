import {createSupabaseClient} from "./supabase.service";
import type {Database} from "./database.types";
import type {AstroCookies} from "astro";

export type BlockInsert = Exclude<Database.public.Tables.Block.Row, 'id' | 'owner' | 'created_at'>

export class BlockService {
    private client: ReturnType<typeof createSupabaseClient>

    public constructor(cookies: AstroCookies) {
        this.client = createSupabaseClient(cookies)
    }

    public async getBlock(index: number) {
        const {data, error} = await this.client.from('Block')
            .select()
            .order('start', {ascending: true})
            .range(index, index + 1)
            .limit(1)
            .single()
        if (error) {
            throw error
        }
        return data
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
