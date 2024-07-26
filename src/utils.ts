import {DateTime, type DurationLike} from "luxon";
import type {PostgrestMaybeSingleResponse, PostgrestResponse, PostgrestSingleResponse} from "@supabase/supabase-js";

export function formatDateForTitle(date: string) {
    return DateTime.fromISO(date).toFormat('ccc, LLL d');
}

export function formatDateForSubtitle(date: string) {
    return DateTime.fromISO(date).toFormat('LLL d');
}

export function calendarAddition(date: string, duration: DurationLike) {
    return DateTime.fromISO(date).plus(duration)
}

export function parseDateTimeFromFormData(formData: FormData, key: string) {
    const value = parseStringFromFormData(formData, key)
    if (value) {
        return DateTime.fromISO(value)
    }
    return DateTime.invalid('value undefined')
}

export function parseStringFromFormData(formData: FormData, key: string) {
    return parseFormData(formData, key, String);
}

export function parseNumberFromFormData(formData: FormData, key: string) {
    return parseFormData(formData, key, Number);
}

export function parseFormData(formData: FormData, key: string, Type: typeof Number): number | undefined
export function parseFormData(formData: FormData, key: string, Type: typeof String): string | undefined
export function parseFormData(formData: FormData, key: string, Type: typeof Number | typeof String) {
    return formData.has(key) ? Type(formData.get(key)) : undefined;
}

type PostgrestResponses<T> = PostgrestSingleResponse<T> | PostgrestMaybeSingleResponse<T> | PostgrestResponse<T>

export async function safeOperation<Result>(query: PromiseLike<PostgrestResponse<Result>>, errorMsg?: string): Promise<Result[]>
export async function safeOperation<Result>(query: PromiseLike<PostgrestMaybeSingleResponse<Result>>, errorMsg?: string): Promise<Result | null>
export async function safeOperation<Result>(query: PromiseLike<PostgrestSingleResponse<Result>>, errorMsg?: string): Promise<Result>
export async function safeOperation<Result>(query: PromiseLike<PostgrestResponses<Result>>, errorMsg?: string) {
    const {data, error} = await query
    if (error) {
        console.error(errorMsg ? errorMsg : error.message)
        throw new Error(errorMsg ? errorMsg : error.message)
    }
    return data
}
