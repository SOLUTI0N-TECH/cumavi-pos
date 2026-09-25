import type { OpeningHours, Store } from './entities';

export type StoreStatus =
  | { open: true; closes: string }
  | { open: false; opensAt?: { day: number; time: string } };

/** Weekday (1 = Monday) and `HH:mm` of [date] in [timeZone]. */
function localMoment(date: Date, timeZone: string): { day: number; time: string } {
  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone,
    weekday: 'short',
    hour: '2-digit',
    minute: '2-digit',
    hourCycle: 'h23',
  }).formatToParts(date);
  const value = (type: string) =>
    parts.find((part) => part.type === type)?.value ?? '';
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return {
    day: weekdays.indexOf(value('weekday')) + 1,
    time: `${value('hour')}:${value('minute')}`,
  };
}

/** Whether the store is open at [now], and when it closes or opens next. */
export function storeStatus(store: Store, now: Date = new Date()): StoreStatus {
  const { day, time } = localMoment(now, store.timeZone);
  const today = store.openingHours.find((hours) => hours.day === day);
  if (today && time >= today.opens && time < today.closes) {
    return { open: true, closes: today.closes };
  }
  return { open: false, opensAt: nextOpening(store.openingHours, day, time) };
}

function nextOpening(
  hours: OpeningHours[],
  day: number,
  time: string,
): { day: number; time: string } | undefined {
  for (let offset = 0; offset < 7; offset++) {
    const candidate = ((day - 1 + offset) % 7) + 1;
    const slot = hours.find((entry) => entry.day === candidate);
    if (!slot) continue;
    if (offset === 0 && time >= slot.opens) continue;
    return { day: candidate, time: slot.opens };
  }
  return undefined;
}
