# MakcuRelay

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/needitem/needaimbot?style=social)](https://github.com/needitem/needaimbot)
[![Part of NeedAimBot](https://img.shields.io/badge/Part%20of-NeedAimBot-blue)](https://github.com/needitem/needaimbot)

**MakcuRelay** is a lightweight UDP-to-serial relay that forwards mouse movement commands to MAKCU hardware devices. It receives delta X/Y coordinates via UDP and sends them to the MAKCU device over serial, enabling hardware-level mouse input for [NeedAimBot](https://github.com/needitem/needaimbot).

## How It Works

```
NeedAimBot                    MakcuRelay                   MAKCU Device
    |                             |                             |
    |  UDP: MOVE:dx,dy            |                             |
    |---------------------------->|                             |
    |                             |  Serial: km.move(dx,dy)     |
    |                             |---------------------------->|
    |                             |                             |  HID Mouse Move
    |                             |                             |--------------->
```

1. **NeedAimBot** detects targets and calculates mouse delta (dx, dy)
2. **MakcuRelay** receives `MOVE:dx,dy` via UDP
3. **MakcuRelay** sends `km.move(dx,dy)` to MAKCU over 4Mbps serial
4. **MAKCU device** executes the mouse movement as HID input

## Features

- **Simple relay**: UDP command in, serial command out
- **Ultra-low latency**: 4Mbps serial communication
- **Cross-platform**: Windows and Linux support


## Prerequisites

- **CMake** 3.10 or higher
- **C++17** compatible compiler
  - Windows: Visual Studio 2019+ or MinGW-w64
  - Linux: GCC 7+ or Clang 5+
- **MAKCU device** (Arduino/ESP32 with HID firmware)

## Installation

### Windows

```bash
# Clone the repository
git clone https://github.com/needitem/MakcuRelay.git
cd MakcuRelay

# Build using the provided script
build_windows.bat

# Or build manually with CMake
cmake -B build -G "Visual Studio 17 2022"
cmake --build build --config Release
```

### Linux

```bash
# Clone the repository
git clone https://github.com/needitem/MakcuRelay.git
cd MakcuRelay

# Build using the provided script
chmod +x build_linux.sh
./build_linux.sh

# Or build manually with CMake
cmake -B build
cmake --build build
```

## Usage

### Command Line

```bash
MakcuRelay [COM_PORT] [UDP_PORT]
```

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `COM_PORT` | `COM3` (Windows) / `/dev/ttyUSB0` (Linux) | Serial port connected to MAKCU device |
| `UDP_PORT` | `5005` | UDP port to listen for incoming commands |


### Examples

```bash
# Windows - Default settings
MakcuRelay.exe

# Windows - Custom COM port
MakcuRelay.exe COM5

# Windows - Custom COM port and UDP port
MakcuRelay.exe COM5 5010

# Linux - Default settings
./MakcuRelay

# Linux - Custom serial port
./MakcuRelay /dev/ttyACM0

# Linux - Custom serial port and UDP port
./MakcuRelay /dev/ttyACM0 5010
```

## UDP Protocol

### Incoming Commands (Port 5005)

Send these commands via UDP to control the mouse:

| Command | Format | Description |
|---------|--------|-------------|
| Move | `MOVE:x,y` | Move mouse by relative x,y pixels |
| Click | `CLICK:LEFT` or `CLICK:RIGHT` | Click and release mouse button |
| Press | `PRESS:LEFT` or `PRESS:RIGHT` | Press and hold mouse button |
| Release | `RELEASE:LEFT` or `RELEASE:RIGHT` | Release mouse button |
| Ping | `PING` | Latency test - echoes back immediately |

## Integration with NeedAimBot

MakcuRelay is designed to work with [NeedAimBot](https://github.com/needitem/needaimbot) for hardware-level mouse input. Configure NeedAimBot:

1. Set **Input Method** to `MAKCU`
2. Set **UDP Address** to the IP of the machine running MakcuRelay (default: `127.0.0.1`)
3. Set **UDP Port** to `5005`

### Setup Configurations

| Setup | Description |
|-------|-------------|
| **Single PC** | NeedAimBot + MakcuRelay + MAKCU on same PC |
| **Dual PC** | NeedAimBot on Game PC, MakcuRelay + MAKCU on separate Relay PC |

## Technical Specifications

| Specification | Value |
|---------------|-------|
| Serial Baud Rate | 4,000,000 bps (4Mbps) |
| UDP Protocol | IPv4, SOCK_DGRAM |
| Timeout | 50ms receive timeout |
| Buffer Size | 256 bytes |

## Troubleshooting

### Common Issues

**"Failed to open Makcu on COM3"**
- Verify the MAKCU device is connected
- Check Device Manager for correct COM port number
- Ensure no other application is using the port

**"WSAStartup failed"**
- Windows networking issue - restart the application

**"bind() failed"**
- Another application is using port 5005
- Specify a different port: `MakcuRelay.exe COM3 5010`

## License

MIT License - see [LICENSE](LICENSE) for details.

## Related Projects

- [NeedAimBot](https://github.com/needitem/needaimbot) - AI-powered aim assistant
- [HID_Mouse](https://github.com/needitem/HID_Mouse) - Arduino HID firmware for MAKCU devices

---

**Keywords**: MAKCU, MakcuRelay, hardware mouse spoofing, aim assist, dual PC setup, NeedAimBot, Arduino mouse relay, UDP mouse relay, low latency mouse, ESP32 HID, mouse emulator, hardware input
