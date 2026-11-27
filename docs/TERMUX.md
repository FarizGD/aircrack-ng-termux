# Termux and Android notes

This repository is based on the upstream Aircrack-ng source tree. Android is not a conventional GNU/Linux distribution: Termux uses Android's Bionic C library, its own package prefix, and the Android kernel. A successful native compile therefore does not imply that every upstream feature or hardware-dependent operation is available.

## Scope of this porting work

The Termux-specific work starts with compatibility assessment, build-environment diagnostics, packaging conventions, and documentation. It does not promise that every upstream component can run on every Android device.

The diagnostic helper is read-only:

```sh
bash scripts/check-termux-environment.sh
```

It reports the Termux prefix, Android and kernel versions, available build tools, selected package states, privilege availability, and visible network interfaces. It does not change device settings or test packet injection.

## Prepare a Termux build environment

Update Termux packages first:

```sh
pkg update && pkg upgrade
pkg install git clang make autoconf automake libtool pkg-config openssl zlib
```

Additional optional libraries may be needed depending on which upstream components are being evaluated. Check package availability with `pkg search` rather than assuming Debian package names or paths apply to Termux.

Keep all build and install paths inside Termux's prefix (normally `$PREFIX`). Do not copy binaries or shared libraries from a glibc-based Linux distribution into Termux. Android uses Bionic, and those binaries are generally not ABI-compatible.

## Device and driver limitations

- Root access is not equivalent to wireless monitor-mode or packet-injection support.
- Support depends on the Wi-Fi chipset, vendor driver, kernel configuration, firmware, and Android build.
- Many internal phone Wi-Fi drivers expose only normal managed-mode networking.
- External USB Wi-Fi adapters additionally require compatible USB host hardware, kernel drivers, firmware, and permissions.
- SELinux and Android process restrictions can affect access even when a device is rooted.
- A successful build only verifies compilation and linking. It does not validate hardware capabilities.

## Environment report

When reporting a build or compatibility issue, include the output of the diagnostic helper and the exact failing command. Remove serial numbers, device identifiers, MAC addresses, and other private values before sharing logs.

## Current status

This documentation and diagnostic helper are groundwork, not a claim that the complete upstream suite has been ported or tested on Android. Components requiring platform-specific APIs or kernel support need separate compatibility work and device testing.
