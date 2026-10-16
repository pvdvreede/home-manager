{...}: {
  # `power-state` — read-only diagnostic that prints the current
  # power-management state of the machine (suspend mode, lid, TLP/PUP stack,
  # platform profile, CPU governor, battery health, sleep inhibitors).
  # Linux-only: on non-Linux hosts the sysfs/procfs reads simply come back
  # empty. Runs unprivileged; reads sysfs/procfs/systemd/TLP only.
  flake.homeModules.power-state = {pkgs, ...}: {
    home.packages = [
      (pkgs.writeShellScriptBin "power-state" ''
      #!/usr/bin/env bash
      # power-state.sh — print the current power-management state of this machine.
      # Read-only: reads sysfs/procfs/systemd/TLP. Safe to run anywhere.
      set -uo pipefail
      
      have() { command -v "$1" >/dev/null 2>&1; }
      svc()  { systemctl is-active "$1" 2>/dev/null; }
      rd()   { cat "$1" 2>/dev/null; }
      
      C_HDR=$'\033[1;36m'; C_OK=$'\033[32m'; C_WARN=$'\033[33m'
      C_BAD=$'\033[31m'; C_DIM=$'\033[2m'; C_OFF=$'\033[0m'
      
      hr() { printf '\n%s%s%s\n' "$C_HDR" "$1" "$C_OFF"; }
      kv() { printf '  %-24s %s\n' "$1:" "$2"; }
      line() { printf '  %s%s%s\n' "$2" "$1" "$C_OFF"; }
      
      # ---------------------------------------------------------------- header
      hr "Host"
      printf '  %s  %s  (%s)\n' \
        "$(hostname)" \
        "$( ( . /etc/os-release 2>/dev/null && printf '%s %s' "$NAME" "$VERSION_ID" ) || echo Linux )" \
        "$(uname -r)"
      
      case " $(rd /proc/cmdline) " in
        *" mem_sleep_default=deep "*)   BOOT_SLEEP=deep ;;
        *" mem_sleep_default=s2idle "*) BOOT_SLEEP=s2idle ;;
        *) BOOT_SLEEP="(not set)" ;;
      esac
      
      # ---------------------------------------------------------------- suspend
      hr "Suspend"
      mem="$(rd /sys/power/mem_sleep)"
      cur="$(printf '%s' "$mem" | sed -n 's/.*\[\([^]]*\)\].*/\1/p')"
      kv "mem_sleep selected"  "''${cur:-(unknown)}"
      kv "mem_sleep available" "$(printf '%s' "$mem" | tr -d '[]')"
      kv "state"               "$(rd /sys/power/state)"
      kv "boot default"        "$BOOT_SLEEP"
      
      # ---------------------------------------------------------------- lid
      hr "Lid"
      lid=""
      for f in /proc/acpi/button/lid/*/state; do
        [ -e "$f" ] || continue
        lid="$(awk '{print $2}' "$f")"
      done
      case "$lid" in
        closed) line "lid: closed" "$C_WARN" ;;
        open)   line "lid: open"   "$C_OK" ;;
        "")     line "lid: no lid switch (desktop?)" "$C_DIM" ;;
        *)      line "lid: $lid"   "$C_DIM" ;;
      esac
      if [ -r /etc/systemd/logind.conf ]; then
        grep -vE '^\s*(#|$)' /etc/systemd/logind.conf | sed 's/^/  logind  /'
      fi
      
      # ---------------------------------------------------------------- stack
      hr "Power management stack"
      for s in tlp power-profiles-daemon auto-cpufreq thermald tuned; do
        if systemctl list-unit-files "''${s}.service" 2>/dev/null | grep -q "^''${s}\.service"; then
          st="$(svc "$s")"
          case "$st" in
            active)   line "$(printf '%-22s active'   "$s")" "$C_OK" ;;
            inactive) line "$(printf '%-22s inactive' "$s")" "$C_DIM" ;;
            *)        line "$(printf '%-22s %s' "$s" "''${st:-unknown}")" "$C_BAD" ;;
          esac
        elif have "$s"; then
          line "$(printf '%-22s installed (no unit)' "$s")" "$C_DIM"
        fi
      done
      
      # which one is actually driving
      if [ "$(svc tlp)" = active ]; then
        line "-> in use: TLP" "$C_DIM"
        if have tlp-stat; then
          for k in "TLP profile" "Power source" "Suspend mode"; do
            v="$(tlp-stat -s 2>/dev/null | sed -n "s/^''${k} *=\s*//p")"
            [ -n "$v" ] && kv "$k" "$v"
          done
        fi
      elif [ "$(svc power-profiles-daemon)" = active ] && have powerprofilesctl; then
        line "-> in use: power-profiles-daemon" "$C_DIM"
        kv "Profile" "$(powerprofilesctl get 2>/dev/null)"
      elif [ "$(svc tuned)" = active ] && have tuned-adm; then
        line "-> in use: tuned" "$C_DIM"
      elif [ "$(svc auto-cpufreq)" = active ]; then
        line "-> in use: auto-cpufreq" "$C_DIM"
      else
        line "-> no active dynamic power daemon" "$C_WARN"
      fi
      
      # ---------------------------------------------------------------- platform
      if [ -r /sys/firmware/acpi/platform_profile ]; then
        hr "Platform profile"
        kv "active"  "$(rd /sys/firmware/acpi/platform_profile)"
        kv "choices" "$(rd /sys/firmware/acpi/platform_profile_choices)"
      fi
      
      # ---------------------------------------------------------------- cpu
      if [ -r /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        hr "CPU"
        kv "governor" "$(rd /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
        kv "driver"   "$(rd /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver)"
        [ -r /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference ] && \
          kv "EPP" "$(rd /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)"
        [ -r /sys/devices/system/cpu/intel_pstate/no_turbo ] && \
          kv "turbo disabled" "$(rd /sys/devices/system/cpu/intel_pstate/no_turbo)"
      fi
      
      # ---------------------------------------------------------------- battery/ac
      hr "Power sources"
      online=""
      for ps in /sys/class/power_supply/*; do
        [ -r "$ps/type" ] || continue
        case "$(rd "$ps/type")" in
          Mains|USB*|USB_PD) [ "$(rd "$ps/online")" = 1 ] && online=1 ;;
        esac
      done
      
      bat_found=0
      for ps in /sys/class/power_supply/BAT*; do
        [ -r "$ps/capacity" ] || continue
        bat_found=1
      
        pct="$(rd "$ps/capacity")"
        status="$(rd "$ps/status")"
        if [ -r "$ps/energy_now" ] && [ -s "$ps/energy_now" ]; then
          unit=Wh; now_f=$ps/energy_now; full_f=$ps/energy_full; des_f=$ps/energy_full_design
          rate_f=$ps/power_now; rate_unit=W; div=1000000; rdiv=1000000
        else
          unit=mAh; now_f=$ps/charge_now; full_f=$ps/charge_full; des_f=$ps/charge_full_design
          rate_f=$ps/current_now; rate_unit=mA; div=1000; rdiv=1000
        fi
        now="$(awk -v v="$(rd "$now_f")" -v d="$div" 'BEGIN{printf "%.0f", v/d}')"
        full="$(awk -v v="$(rd "$full_f")" -v d="$div" 'BEGIN{printf "%.0f", v/d}')"
        design="$(awk -v v="$(rd "$des_f")" -v d="$div" 'BEGIN{printf "%.0f", v/d}')"
        health=""
        [ -n "$full" ] && [ "$full" != 0 ] && [ -n "$design" ] && [ "$design" != 0 ] && \
          health="$(awk -v f="$full" -v d="$design" 'BEGIN{printf "%.1f", f*100/d}')"
      
        printf '  %s: ' "''${ps##*/}"
        if [ "''${pct:-100}" -le 15 ] 2>/dev/null; then line "''${pct}%" "$C_BAD"; else line "''${pct}%" "$C_OK"; fi
        kv "  status"   "$status"
        [ -n "$health" ] && kv "  health" "''${health}%   (''${full} / ''${design} ''${unit})"
        [ -n "$now" ]    && kv "  remaining" "''${now} ''${unit}"
        [ -r "$rate_f" ] && kv "  rate" "$(awk -v v="$(rd "$rate_f")" -v d="$rdiv" 'BEGIN{printf "%.2f", v/d}') ''${rate_unit}"
        kv "  cycles" "$(rd "$ps/cycle_count")"
        [ -r "$ps/charge_control_start_threshold" ] && \
          kv "  charge start/end" "$(rd "$ps/charge_control_start_threshold")% / $(rd "$ps/charge_control_end_threshold")%"
      done
      [ "$bat_found" -eq 0 ] && line "no battery (desktop / powered host)" "$C_DIM"
      
      case "$online" in
        1) line "External power: connected" "$C_OK" ;;
        *) line "External power: on battery" "$C_DIM" ;;
      esac
      
      # ---------------------------------------------------------------- inhibitors
      if have systemd-inhibit; then
        hr "Sleep inhibitors"
        if systemd-inhibit --list 2>/dev/null | grep -q WHO; then
          systemd-inhibit --list 2>/dev/null | sed -n '4,$p' | sed 's/^/  /'
        else
          line "none" "$C_DIM"
        fi
      fi
      
      echo
      '')
    ];
  };
}
