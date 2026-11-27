# Passive PCAP metadata utility

`pcap-summary` reads classic PCAP files and reports capture metadata, packet count, original byte totals, timestamp range, truncation count, and a histogram of captured lengths. It does not decode packet contents or interpret wireless/security exchanges.

Usage:

```sh
python pcap-summary.py capture.pcap
python pcap-summary.py capture.pcap --json
```

Classic PCAP is supported in little/big-endian microsecond and nanosecond formats. PCAPNG is not currently supported. The file is opened read-only.
