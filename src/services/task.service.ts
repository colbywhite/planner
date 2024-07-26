import type {SupabaseClient} from "@supabase/supabase-js";
import type {Database, Tables, TablesInsert} from "./database.types";
import type {AstroCookies} from "astro";
import {createSupabaseClient} from "./supabase.service";
import {DateTime} from "luxon";
import {safeOperation} from "../utils";

// TODO why do the autogenerated types make views null
type NumberedWeeksTable = Tables<'weeks'> & {
    number: NonNullable<Tables<'numbered_weeks'>["number"]>,
    total: NonNullable<Tables<'numbered_weeks'>['total']>
}
type NumberedWeekWithTasks = NumberedWeeksTable & { tasks: Tables<'tasks'>[] } & { season: Tables<'seasons'> }

export class TaskService {
    private readonly client: SupabaseClient<Database>

    public constructor(cookies: AstroCookies, private readonly season: string) {
        this.client = createSupabaseClient(cookies)
    }

    public async addTasks(insert: TablesInsert<'tasks'>) {
        console.log('addTasks', {...insert, season: this.season})
        await this.assertRelatedWeek(insert.week_id)
        return safeOperation(
            this.client.from('tasks')
                .insert(insert)
                .select()
        )
    }

    private async assertValidSeason(season_id: string) {
        await safeOperation(
            this.client
                .from('seasons')
                .select('id')
                .eq('id', season_id)
                .single(),
            `'${season_id}' is not a valid season`,
        )
    }

    private async assertRelatedWeek(week_id: string) {
        await this.assertValidSeason(this.season)
        await safeOperation(
            this.client
                .from('weeks')
                .select('season_id')
                .eq('id', week_id)
                .single(),
            `'${week_id}' does not belong to '${this.season}'`,
        )
    }

    private async assertRelatedTask(week_id: string, task_id: string) {
        await this.assertRelatedWeek(week_id)
        await safeOperation(
            this.client
                .from('tasks')
                .select('week_id')
                .eq('id', task_id)
                .single(),
            `'${task_id}' does not belong to '${week_id}'`,
        )
    }

    public async getWeeks() {
        await this.assertValidSeason(this.season)
        return safeOperation(
            this.client.from('numbered_weeks')
                .select()
                .order('start', {ascending: true})
                .eq('season_id', this.season)
                .returns<NumberedWeeksTable[]>()
        )
    }

    public async toggleTask(week: string, task: string){
        await this.assertRelatedTask(week, task)
        const updatedTask= await safeOperation(
            this.client.rpc('toggle_task_completion', {task_id: task})
        )
        if (!updatedTask) {
            throw new Error('Error toggling task')
        }
        return updatedTask
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
            this.client.rpc('safely_get_numbered_week', {seasonid: this.season, weeknumber: weekNum})
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
                .eq('season_id', this.season)
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
                .eq('season_id', this.season)
                .maybeSingle<NumberedWeekWithTasks>()
        )
    }

    private getClosestWeekId(date: DateTime<true>) {
        return safeOperation(
            this.client.rpc('get_closest_week_id', {date: date.toISODate(), seasonid: this.season})
        )
    }
}

