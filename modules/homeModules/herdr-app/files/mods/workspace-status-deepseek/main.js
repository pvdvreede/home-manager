import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, agents, theme, run, window, keys, appHome, readTextFile } from "herdr";

const BALANCE_URL = "https://api.deepseek.com/user/balance";
const KEY_FILE = "deepseek.key";
const POLL_MS = 5 * 60 * 1000;
const SYMBOL = { USD: "$", CNY: "\u00a5" };

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
