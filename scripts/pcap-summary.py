#!/usr/bin/env python3
"""Read-only metadata summary for classic PCAP files (no payload decoding)."""
import argparse
import json
import struct
import sys
from collections import Counter
from pathlib import Path

MAGIC = {
    b"\xd4\xc3\xb2\xa1": ("<", 1_000_000),
    b"\xa1\xb2\xc3\xd4": (">", 1_000_000),
    b"\x4d\x3c\xb2\xa1": ("<", 1_000_000_000),
    b"\xa1\xb2\x3c\x4d": (">", 1_000_000_000),
}

def summarize(path):
    with path.open("rb") as f:
        magic = f.read(4)
        if magic not in MAGIC:
            raise ValueError("not a supported classic PCAP file (PCAPNG is not supported)")
        endian, scale = MAGIC[magic]
        rest = f.read(20)
        if len(rest) != 20:
            raise ValueError("truncated PCAP global header")
        major, minor, _zone, _sigfigs, snaplen, linktype = struct.unpack(endian + "HHIIII", rest)
        packets = 0
        total_bytes = 0
        lengths = Counter()
        truncated = 0
        first_ts = last_ts = None
        while True:
            hdr = f.read(16)
            if not hdr:
                break
            if len(hdr) != 16:
                raise ValueError(f"truncated packet header at packet {packets + 1}")
            sec, frac, incl, orig = struct.unpack(endian + "IIII", hdr)
            if incl > snaplen and snaplen:
                raise ValueError(f"packet {packets + 1} exceeds declared snaplen")
            payload = f.read(incl)
            if len(payload) != incl:
                raise ValueError(f"truncated packet data at packet {packets + 1}")
            ts = sec + frac / scale
            first_ts = ts if first_ts is None else first_ts
            last_ts = ts
            packets += 1
            total_bytes += incl
            lengths[str(incl)] += 1
            if incl < orig:
                truncated += 1
        return {
            "file": str(path),
            "pcap_version": f"{major}.{minor}",
            "link_type": linktype,
            "snaplen": snaplen,
            "packet_count": packets,
            "captured_bytes": total_bytes,
            "truncated_packets": truncated,
            "first_timestamp": first_ts,
            "last_timestamp": last_ts,
            "captured_length_histogram": dict(sorted(lengths.items(), key=lambda x: int(x[0]))),
        }

def main():
    parser = argparse.ArgumentParser(description="Summarize classic PCAP metadata without decoding packet payloads.")
    parser.add_argument("pcap", type=Path, help="input PCAP file")
    parser.add_argument("--json", action="store_true", help="emit JSON")
    args = parser.parse_args()
    try:
        result = summarize(args.pcap)
    except (OSError, ValueError, struct.error) as exc:
        print(f"pcap-summary: {exc}", file=sys.stderr)
        return 2
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        for key, value in result.items():
            print(f"{key}: {value}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
