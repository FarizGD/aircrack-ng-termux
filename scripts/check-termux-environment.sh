#!/data/data/com.termux/files/usr/bin/bash
# Read-only diagnostics for Termux/Android compatibility.
set -u

section() { printf '\n== %s ==\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

section "Termux"
printf 'PREFIX: %s\n' "${PREFIX:-unknown}"
printf 'HOME: %s\n' "${HOME:-unknown}"
printf 'Shell: %s\n' "${SHELL:-unknown}"
printf 'Architecture: %s\n' "$(uname -m 2>/dev/null || printf unknown)"
printf 'Kernel: %s\n' "$(uname -sr 2>/dev/null || printf unknown)"
printf 'Android release: %s\n' "$(getprop ro.build.version.release 2>/dev/null || printf unavailable)"
printf 'Android SDK: %s\n' "$(getprop ro.build.version.sdk 2>/dev/null || printf unavailable)"
printf 'SELinux: %s\n' "$(getenforce 2>/dev/null || printf unavailable)"

section "Privileges"
if have id; then id; fi
if have su && su -c id >/dev/null 2>&1; then
    printf 'Root command: available\n'
else
    printf 'Root command: unavailable to this shell\n'
fi

section "Build tools"
for tool in clang make cmake autoconf automake libtool pkg-config git; do
    if have "$tool"; then
        printf '%-12s %s\n' "$tool" "$(command -v "$tool")"
    else
        printf '%-12s missing\n' "$tool"
    fi
done

section "Termux packages"
if have dpkg-query; then
    for package in clang make autoconf automake libtool pkg-config openssl zlib libnl libpcap sqlite pcre2; do
        if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'install ok installed'; then
            printf '%-12s installed\n' "$package"
        else
            printf '%-12s not installed\n' "$package"
        fi
    done
else
    printf 'dpkg-query unavailable\n'
fi

section "Network interfaces (read-only)"
if [ -d /sys/class/net ]; then
    for iface in /sys/class/net/*; do
        [ -e "$iface" ] || continue
        name=${iface##*/}
        printf '%s' "$name"
        [ -d "$iface/wireless" ] && printf ' [wireless]'
        [ -r "$iface/operstate" ] && printf ' state=%s' "$(cat "$iface/operstate")"
        printf '\n'
    done
else
    printf '/sys/class/net unavailable\n'
fi

section "Notes"
printf '%s\n' \
    "This script only reads system information; it does not change device settings." \
    "Root access alone does not guarantee monitor mode or packet-injection support." \
    "Wi-Fi capabilities depend on the chipset, vendor driver, kernel, firmware, and Android build." \
    "Do not infer support from the presence of a wireless interface."
