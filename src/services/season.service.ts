import type {SupabaseClient} from "@supabase/supabase-js";
import type {Database, TablesInsert} from "./database.types";
import type {AstroCookies} from "astro";
import {createSupabaseClient} from "./supabase.service";
import {safeOperation} from "../utils";
import type {DateTime} from "luxon";
import type {User} from "@supabase/auth-js";

export class SeasonService {
    private readonly client: SupabaseClient<Database>

    public constructor(cookies: AstroCookies) {
        this.client = createSupabaseClient(cookies)
    }

    public async getSeasons() {
        return safeOperation(
            this.client.from('seasons')
                .select()
                .order('created_at', {ascending: false})
        )
    }

    public async createSeason({name, start, end}: { name: string, start: DateTime<true>, end: DateTime<true> }) {
        console.log('createSeason', {name, start: start.toISODate(), end: end.toISODate()})
        const user = await this.assertUser()
        const season = await safeOperation(
            this.client.from('seasons')
                .insert({name, owner: user.id} as TablesInsert<'seasons'>) // the id is auto generated via a trigger
                .select()
                .single()
        )
        if (!season) {
            throw new Error('No season created')
        }
        const numWeeks = Math.ceil(end.diff(start).as('weeks'))
        const weeks = new Array<number>(numWeeks).fill(0)
            .map((_, i) => {
                const week_start = start.plus({weeks: i})
                const week_end = week_start.plus({days: 6})
                return {
                    season_id: season.id,
                    start: week_start.toISODate(),
                    end: week_end.toISODate()
                } satisfies TablesInsert<'weeks'>
            })
        console.log('createSeason', {weeks})
        await safeOperation(
            this.client.from('weeks')
                .insert(weeks)
        )
        return season
    }

    private async assertUser() {
        const {data: {user}, error} = await this.client.auth.getUser()
        if (error) {
            console.error('Could not get user')
            throw new Error('Could not get user')
        }
        return user as User
    }
}

