# krypton-16

A bare-metal 16-bit x86 Real Mode inline network packet firewall and real-time payload decryption engine written in NASM assembly.

## Overview

Krypton-16 simulates a security appliance sitting directly on top of raw network memory buffers. When incoming packets land in RAM, the engine inspects packet boundaries, verifies payload integrity using string primitives, executes a multi-stage cipher decryption cascade, and safely dispatches validated system commands through isolated stack frames.

---
## Architectural Pipeline

The system processes network packets through a 5-phase sequential pipeline:

1. **Memory Frame Definition**: Maps raw network bytes into structured fields without high-level abstraction.
2. **Header & Boundary Inspection**: Validates the magic word (`0x504B` / `'KP'`) and payload length constraints.
3. **Wire Tamper Detection**: Sweeps the payload byte-by-byte using `LODSB` string primitives to calculate an 8-bit arithmetic checksum and compare it against expected header telemetry.
4. **Multi-Stage Decryption Cascade**: In-place decrypts valid payloads using a bitwise transformation sequence (`XOR` $\rightarrow$ `ROR` $\rightarrow$ `RCL` $\rightarrow$ `SUB`).
5. **Stack Frame Dispatcher**: Constructs an isolated base-pointer (`BP`) stack frame, extracts command instructions, executes the handler, and returns operational state in `AX`.

---

## Memory Frame Layout

Packet headers and payloads sit contiguously in memory according to the following offset map:

| Offset | Field Name          | Size    | Description                                    |
| :---   | :---                | :---    | :---                                           |
| `+0x00`| `magic_header`      | 2 Bytes | Magic word `'K'` `'P'` (`0x4B`, `0x50`)        |
| `+0x02`| `payload_len`       | 1 Byte  | Length of encrypted payload ($N$ bytes)         |
| `+0x03`| `expected_chksum`   | 1 Byte  | Expected 8-bit arithmetic checksum             |
| `+0x04`| `payload_data`      | $N$ Bytes| Encrypted network payload string               |

> **Note on Endianness**: x86 Real Mode utilizes little-endian ordering. Reading `+0x00` as a 16-bit word yields `AX = 0x504B` (`AH = 0x50`, `AL = 0x4B`).
