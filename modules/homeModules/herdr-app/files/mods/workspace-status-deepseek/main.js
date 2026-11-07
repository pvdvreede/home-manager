import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, agents, theme, run, window, keys, appHome, readTextFile } from "herdr";

const BALANCE_URL = "https://api.deepseek.com/user/balance";
const KEY_FILE = "deepseek.key";
const POLL_MS = 2 * 60 * 1000;
const SYMBOL = { USD: "$", CNY: "\u00a5" };

const H = 3600_000; // one hour in ms

/** Peak windows in UTC hours [start, end), applied on Beijing weekdays. */
const PEAK_WINDOWS = [
  [1, 4],
  [6, 10],
];

/**
 * Chinese public holidays (official State Council dates) are off-peak in full.
 * Make-up workdays (调休) need no entry: they always land on a Sat/Sun, which is
 * off-peak anyway, so only weekday holidays can change a decision.
 * Refresh once a year when the State Council publishes the next year's dates.
 */
const CHINA_HOLIDAY_RANGES = [
  ["2026-01-01", "2026-01-03"], // New Year
  ["2026-02-15", "2026-02-23"], // Spring Festival
  ["2026-04-04", "2026-04-06"], // Ching Ming
  ["2026-05-01", "2026-05-05"], // Labour Day
  ["2026-06-19", "2026-06-21"], // Dragon Boat
  ["2026-09-25", "2026-09-27"], // Mid-Autumn
  ["2026-10-01", "2026-10-07"], // National Day
];

// Beijing calendar-day keys ("YYYY-MM-DD"), expanded once at load (UTC math, no DST).
const HOLIDAY_DAYS = new Set();
for (const [from, to] of CHINA_HOLIDAY_RANGES) {
  const end = Date.parse(`${to}T00:00:00Z`);
  for (let t = Date.parse(`${from}T00:00:00Z`); t <= end; t += 24 * H) {
    HOLIDAY_DAYS.add(new Date(t).toISOString().slice(0, 10));
  }
}

/** True when DeepSeek bills off-peak at `date`. */
function isOffPeak(date) {
  const bj = new Date(date.getTime() + 8 * H); // Beijing time (UTC+8)
  const dow = bj.getUTCDay();
  if (dow === 0 || dow === 6) return true; // Beijing weekend
  if (HOLIDAY_DAYS.has(bj.toISOString().slice(0, 10))) return true;
  const h = date.getUTCHours();
  return !PEAK_WINDOWS.some(([start, end]) => h >= start && h < end);
}

/** First instant where the peak/off-peak state flips, or null if none within the scan window. */
function nextPriceChange(date) {
  const now = date.getTime();
  const day = Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate());
  const state = isOffPeak(date);
  const candidates = [];
  // Spring Festival is ~9.5 contiguous off-peak days, so scan three weeks ahead.
  for (let i = 0; i < 21; i++) {
    const d = day + i * 24 * H;
    for (const h of [1, 4, 6, 10]) candidates.push(d + h * H);
    candidates.push(d - 8 * H); // Beijing midnight (holiday boundaries)
  }
  for (const t of candidates.sort((a, b) => a - b)) {
    if (t > now && isOffPeak(new Date(t + 1)) !== state) return new Date(t);
  }
  return null;
}

function formatHM(m) {
  if (m <= 0) return "";
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  const min = m % 60;
  return min === 0 ? `${h}h` : `${h}h${String(min).padStart(2, "0")}m`;
}

/** Time until the next switch: "8d22h", "27h", "1h30m", "45m". */
function formatCountdown(date) {
  const next = nextPriceChange(date);
  if (!next) return "";
  const m = Math.ceil((next.getTime() - date.getTime()) / 60000);
  if (m >= 48 * 60) return `${Math.floor(m / 1440)}d${formatHM(m % 1440)}`;
  return formatHM(m);
}

/** Local wall-clock instant the current period ends at: "14:00", "Mon 09:00", "03-01 14:00". */
function formatEndLocal(date) {
  const next = nextPriceChange(date);
  if (!next) return "";
  const clock = `${String(next.getHours()).padStart(2, "0")}:${String(next.getMinutes()).padStart(2, "0")}`;
  const dayStart = (d) => new Date(d.getFullYear(), d.getMonth(), d.getDate()).getTime();
  const dayDiff = Math.round((dayStart(next) - dayStart(date)) / (24 * H));
  if (dayDiff === 0) return clock;
  if (dayDiff === 1) return `${["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][next.getDay()]} ${clock}`;
  const mmdd = `${String(next.getMonth() + 1).padStart(2, "0")}-${String(next.getDate()).padStart(2, "0")}`;
  return `${mmdd} ${clock}`;
}

export default class WorkspaceStatusDeepSeek extends View {
  // The palette key as actually bound, not a hardcoded one; without a
  // binding the hint stays useful ("commands") instead of lying.
  hint(t) {
    const mac = window()?.platform === "macos";
    const mod = { cmd: mac ? "⌘" : "Ctrl+", ctrl: mac ? "⌃" : "Ctrl+", shift: mac ? "⇧" : "Shift+", alt: mac ? "⌥" : "Alt+", option: mac ? "⌥" : "Alt+" };
    const b = keys().find((k) => k.section === "global" && k.action === "app.palette");
    const parts = b && b.keys.endsWith("--") ? [...b.keys.slice(0, -2).split("-"), "-"] : b?.keys.split("-");
    const key = parts && parts.map((p) => mod[p.toLowerCase()] ?? p.toUpperCase()).join("");
    return key ? `${key}  commands` : "commands";
  }

  init(_props, cx) {
    this.info = null;
    this.available = true;
    this.balance = null;
    this.peak = 0;
    this.error = null;
    this.busy = false;
    cx.timer.every(POLL_MS, (cx) => this.refresh(cx));
    // Re-render every minute so the peak/off-peak countdown stays live without
    // re-fetching the balance (which the 5-minute poll already owns).
    cx.timer.every(60_000, (cx) => cx.notify());
    this.refresh(cx);
  }

  async key() {
    const text = await readTextFile(`${appHome()}/${KEY_FILE}`);
    return (text ?? "").trim();
  }

  refresh(cx) {
    if (this.busy) return;
    this.busy = true;
    cx.spawn(async (cx) => {
      const key = await this.key();
      if (!key) {
        this.info = null;
        this.balance = null;
        this.peak = 0;
        this.error = null;
        this.busy = false;
        cx.notify();
        return;
      }
      try {
        const response = await fetch(BALANCE_URL, {
          headers: { Authorization: `Bearer ${key}`, Accept: "application/json" },
        });
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const body = await response.json();
        const info = body.balance_infos?.[0] ?? null;
        this.info = info;
        this.available = body.is_available !== false;
        this.balance = info ? Number(info.total_balance) : null;
        if (info && Number.isFinite(this.balance)) {
          const peakKey = `deepseek.peak.${info.currency}`;
          const peak = Number(localStorage.getItem(peakKey) ?? 0) || 0;
          this.peak = Math.max(peak, this.balance);
          if (this.peak > peak) localStorage.setItem(peakKey, String(this.peak));
        }
        this.error = null;
      } catch (error) {
        this.error = error?.message ?? String(error);
      }
      this.busy = false;
      cx.notify();
    });
  }

  detail() {
    if (this.error) return `DeepSeek: ${this.error}`;
    if (!this.info) return "DeepSeek: no balance reported";
    const s = SYMBOL[this.info.currency] ?? "";
    return [
      `total ${s}${Number(this.info.total_balance).toFixed(2)}`,
      `granted ${s}${Number(this.info.granted_balance).toFixed(2)}`,
      `topped up ${s}${Number(this.info.topped_up_balance).toFixed(2)}`,
      `peak ${s}${this.peak.toFixed(2)}`,
      this.available ? "calls available" : "calls blocked",
    ].join("\n");
  }

  // Green "off-peak" / red "peak" badge, plus the countdown to the next switch
  // and the local time the current period ends. Rendered to the left of the
  // spend. `ansi2` is the palette's green; `blocked` is the app's error red
  // (`done` is blue in every theme, so it can't carry the off-peak colour).
  billingBadge(t) {
    const now = new Date();
    const offPeak = isOffPeak(now);
    const cd = formatCountdown(now);
    const end = formatEndLocal(now);
    const label = offPeak ? "off-peak" : "peak";
    const suffix = end ? ` (until ${end})` : "";
    return div().text_color(offPeak ? t.ansi2 : t.blocked).child(cd ? `${label} ${cd}${suffix}` : label);
  }

  // Nothing to show without the key file: no label, no poll, no fetch.
  meter(t) {
    if (!this.info && !this.error) return null;
    const known = this.balance !== null && Number.isFinite(this.balance);
    const money = known ? `${SYMBOL[this.info.currency] ?? ""}${this.balance.toFixed(2)}` : "—";
    const share = known && this.peak > 0 ? Math.min(1, Math.max(0, this.balance / this.peak)) : 0;
    const color = this.error || !this.available ? t.blocked : share < 0.2 ? t.blocked : share < 0.5 ? t.working : t.accent;
    return h_flex()
      .id("deepseek-meter")
      .gap(6)
      .items_center()
      .cursor_pointer()
      .on_click((_e, cx) => this.refresh(cx))
      .tooltip(this.detail())
      .child(this.billingBadge(t))
      .child(div().text_color(this.error ? t.dim : color).child(this.error ? "DeepSeek: ?" : `DeepSeek remaining: ${money}`));
  }

  render() {
    const t = theme();
    const space = spaces().find(s => s.active);
    const list = agents();
    const needs = list.filter(a => a.status === "blocked").length;
    const label = (icon, text) => h_flex().gap(6).items_center().child(svg(`mods/workspace-chrome/${icon}.svg`).size(13)).child(text);
    const meter = this.meter(t);
    return h_flex().size_full().px(14).gap(16).items_center().bg(t.chrome).border_t(1).border_color(t.border).text_size(11.8).text_color(t.muted)
      .child(label(space?.machine ? "server" : "monitor", space?.machine ?? "This computer"))
      .when(Boolean(space?.branch), el => el.child(label("branch", space.branch)))
      .child(h_flex().gap(6).items_center().child(div().size(6).rounded(3).bg(t.dim)).child(`${list.length} agents`)
        .when(needs > 0, el => el.child(div().text_color(t.blocked).child(`· ${needs} needs you`))))
      .when(Boolean(meter), el => el.child(meter))
      .child(div().flex_1())
      .child(div().id("palette").text_color(t.dim).on_click(() => run("app.palette")).child(this.hint(t)));
  }
}
