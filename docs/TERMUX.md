# Termux and Android notes

This repository is based on the upstream Aircrack-ng source tree. Android is not a conventional GNU/Linux distribution: Termux uses Android's Bionic C library, its own package prefix, and the Android kernel. A successful native compile does not mean every upstream component or hardware feature is available.

## Port scope

The Termux work provides safe environment reporting, package groundwork, and capture-file metadata inspection. It does not claim to be a complete upstream suite port.

## Reports

Run these read-only reports:

\`\`\`sh
termux-environment-report
termux-hardware-report
\`\`\`

The environment report checks available tools, package states, permissions, and visible interfaces. The hardware report reports device/build properties, ABI, kernel, memory, storage, CPU feature flags, visible graphics devices, and verified-boot/lock state. Neither changes settings.

## Build prerequisites

\`\`\`sh
pkg update && pkg upgrade
pkg install git clang make autoconf automake libtool pkg-config openssl zlib
\`\`\`

Additional dependencies vary by component. Check Termux package names with \`pkg search\`. Keep build/install paths inside \`$PREFIX\`. Do not use glibc Linux binaries in Termux: Android uses Bionic.

## Hardware limitations

- Root does not automatically provide monitor-mode or injection support.
- Hardware support depends on chipset, driver, kernel configuration, firmware, and Android build.
- Internal Wi-Fi commonly supports managed networking only.
- USB Wi-Fi support requires compatible USB host hardware, drivers, firmware, and permissions.
- SELinux and Android restrictions may limit access.
- Compilation is not hardware validation.

Remove serial numbers, device IDs, MAC addresses, and private data before sharing diagnostic output.

## Status

This is compatibility groundwork, not a complete or verified Android port of upstream. Components need independent compatibility and testing.
