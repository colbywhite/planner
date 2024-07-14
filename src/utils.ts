import {DateTime, type DurationLike} from "luxon";

export function formatDate(date: string) {
    return DateTime.fromISO(date).toFormat('ccc, LLL d');
}

export function calendarAddition(date: string, duration: DurationLike) {
    return DateTime.fromISO(date).plus(duration)
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
