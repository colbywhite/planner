import type {
    PostgrestMaybeSingleResponse,
    PostgrestResponse,
    PostgrestSingleResponse,
    SupabaseClient
} from "@supabase/supabase-js";
import type {Database, Tables, TablesInsert} from "./database.types";
import type {AstroCookies} from "astro";
import {createSupabaseClient} from "./supabase.service";
import {DateTime} from "luxon";

// TODO why do the autogenerated types make views null
type NumberedWeeksTable = Tables<'weeks'> & {
    number: NonNullable<Tables<'numbered_weeks'>["number"]>,
    total: NonNullable<Tables<'numbered_weeks'>['total']>
}
type NumberedWeekWithSeason = NumberedWeeksTable & { season: Tables<'seasons'> }
type NumberedWeekWithTasks = NumberedWeeksTable & { tasks: Tables<'tasks'>[] } & { season: Tables<'seasons'> }

export class SeasonService {
    private readonly client: SupabaseClient<Database>

    public constructor(cookies: AstroCookies, private readonly seasonName = "Fall '24") {
        this.client = createSupabaseClient(cookies)
        // TODO assert that the season exists and has some weeks.
    }

    public async addTasks(insert: TablesInsert<'tasks'>) {
        // TODO check the week is a real week in the season
        console.log('addTasks', this.seasonName, insert)
        return safeOperation(
            this.client.from('tasks')
                .insert(insert)
                .select()
        )
    }
    public async getWeeks() {
        return safeOperation(
            this.client.from('numbered_weeks')
                .select('*, season:seasons(*)')
                .order('start', {ascending: true})
                .eq('seasons.name', this.seasonName)
                .returns<NumberedWeekWithSeason[]>()    // i don't know why they supabase types assume season could be null, but that's impossible due to the query
        )
    }

    public async safelyGetTasks(weekNum: number) {
        if (isNaN(weekNum)) {
            return this.safelyGetTasksForDate(DateTime.now())
        } else {
            return this.safelyGetTasksForWeekNumber(weekNum)
        }
    }

    /**
     * For a given date, get the tasks for the corresponding week.
     * If there is no corresponding week, return the tasks for the closest week.
     */
    public async safelyGetTasksForDate(date: DateTime<true>) {
        const week = await this.getTasksForDate(date)
        if (week) {
            return week
        }
        console.log('No week found for', date.toISODate())
        const closestWeekId = await this.getClosestWeekId(date)
        if (!closestWeekId) {
            throw new Error('There are no weeks for the season')
        }
        const closestWeek = await this.getTasksForWeek(closestWeekId)
        if (!closestWeek) {
            // TODO: this shouldn't be possible
            throw new Error('There are no weeks for the season')
        }
        return closestWeek
    }

    public async safelyGetTasksForWeekNumber(weekNum: number) {
        const result = await safeOperation(
            this.client.rpc('safely_get_numbered_week', {seasonname: this.seasonName, weeknumber: weekNum})
                .single<NumberedWeekWithTasks>(),
        )
        if (result === null) {
            throw new Error('There are no weeks for the season')
        }
        return result
    }

    /**
     * For a given date, get the tasks for the corresponding week.
     * @returns null if there is no corresponding week
     */
    public async getTasksForDate(date: DateTime<true>) {
        return safeOperation(
            this.client.from('numbered_weeks')
                .select('*, tasks(*), season:seasons(*)')
                .lte('start', date.toISODate())
                .gte('end', date.toISODate())
                .eq('seasons.name', this.seasonName)
                .maybeSingle<NumberedWeekWithTasks>()
        )
    }

    /**
     * @returns null if there is no week with the given id
     */
    public async getTasksForWeek(id: string) {
        return safeOperation(
            this.client.from('numbered_weeks')
                .select('*, tasks(*), season:seasons(*)')
                .eq('id', id)
                .eq('seasons.name', this.seasonName)
                .maybeSingle<NumberedWeekWithTasks>()
        )
    }

    private getClosestWeekId(date: DateTime<true>) {
        return safeOperation(
            this.client.rpc('get_closest_week_id', {date: date.toISODate()})
        )
    }
}

type PostgrestResponses<T> = PostgrestSingleResponse<T> | PostgrestMaybeSingleResponse<T> | PostgrestResponse<T>

async function safeOperation<Result>(query: PromiseLike<PostgrestResponse<Result>>): Promise<Result[]>
async function safeOperation<Result>(query: PromiseLike<PostgrestMaybeSingleResponse<Result>>): Promise<Result | null>
async function safeOperation<Result>(query: PromiseLike<PostgrestSingleResponse<Result>>): Promise<Result>
async function safeOperation<Result>(query: PromiseLike<PostgrestResponses<Result>>) {
    const {data, error} = await query
    if (error) {
        console.error('error executing operation', error)
        throw error
    }
    return data
}