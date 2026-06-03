function parseDate(str) {
  const parts = String(str).split('-').map(Number);
  if (parts.length !== 3 || parts.some(Number.isNaN)) return null;
  const d = new Date(parts[0], parts[1] - 1, parts[2]);
  if (Number.isNaN(d.getTime())) return null;
  return d;
}

function formatDate(d) {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

function addDays(dateStr, n) {
  const d = parseDate(dateStr);
  d.setDate(d.getDate() + n);
  return formatDate(d);
}

function addDaysFromToday(n) {
  const d = new Date();
  d.setDate(d.getDate() + n);
  return formatDate(d);
}

function dateRangeInclusive(start, end) {
  const dates = [];
  let cur = start;
  while (cur <= end) {
    dates.push(cur);
    cur = addDays(cur, 1);
  }
  return dates;
}

function todayStr() {
  return formatDate(new Date());
}

function parseDateTime(iso) {
  const d = new Date(iso);
  return Number.isNaN(d.getTime()) ? null : d;
}

function hoursBetween(startIso, endIso) {
  const s = parseDateTime(startIso);
  const e = parseDateTime(endIso);
  if (!s || !e || e <= s) return 0;
  return (e - s) / (60 * 60 * 1000);
}

function hoursUntilPickup(pickupIso) {
  const now = new Date();
  const pickup = parseDateTime(pickupIso);
  if (!pickup) return 0;
  return (pickup - now) / (60 * 60 * 1000);
}

module.exports = {
  parseDate,
  formatDate,
  addDays,
  addDaysFromToday,
  dateRangeInclusive,
  todayStr,
  parseDateTime,
  hoursBetween,
  hoursUntilPickup,
};
