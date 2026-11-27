#!/data/data/com.termux/files/usr/bin/bash
# Read-only Android hardware, ABI and kernel capability report.
set -u
section() { printf "\n== %s ==\n" "$1"; }
getprop_safe() { getprop "$1" 2>/dev/null || printf "unavailable"; }
section "Device"
printf "Manufacturer: %s\n" "$(getprop_safe ro.product.manufacturer)"
printf "Brand: %s\n" "$(getprop_safe ro.product.brand)"
printf "Model: %s\n" "$(getprop_safe ro.product.model)"
printf "Device: %s\n" "$(getprop_safe ro.product.device)"
printf "Android: %s (SDK %s)\n" "$(getprop_safe ro.build.version.release)" "$(getprop_safe ro.build.version.sdk)"
printf "Build fingerprint: %s\n" "$(getprop_safe ro.build.fingerprint)"
section "ABI"
printf "Primary ABI: %s\n" "$(getprop_safe ro.product.cpu.abi)"
printf "Supported ABIs: %s\n" "$(getprop_safe ro.product.cpu.abilist)"
printf "Kernel machine: %s\n" "$(uname -m 2>/dev/null || echo unknown)"
printf "Kernel: %s\n" "$(uname -r 2>/dev/null || echo unknown)"
section "Memory"
if [ -r /proc/meminfo ]; then grep -E "^(MemTotal|MemAvailable|SwapTotal|SwapFree):" /proc/meminfo; else echo "/proc/meminfo unavailable"; fi
section "Storage"
df -h "$HOME" 2>/dev/null || true
section "CPU"
if [ -r /proc/cpuinfo ]; then grep -m1 -E "^(Hardware|model name|Processor):" /proc/cpuinfo || true; grep -m1 "^Features" /proc/cpuinfo || true; fi
section "Graphics devices (read-only)"
for d in /dev/dri/* /dev/kgsl-3d0 /dev/mali*; do [ -e "$d" ] && ls -l "$d"; done
section "Android security"
printf "SELinux: %s\n" "$(getenforce 2>/dev/null || echo unavailable)"
printf "Verified boot: %s\n" "$(getprop_safe ro.boot.verifiedbootstate)"
printf "Bootloader lock: %s\n" "$(getprop_safe ro.boot.flash.locked)"
section "Note"
echo "This report only reads Android properties and procfs/sysfs; it makes no changes."
