# MakcuRelay

Second‑PC helper for Makcu‑based 2PC aimbot setups.

MakcuRelay runs on the **second PC** (the one that has the Makcu board attached via USB/COM) and does only one job:

- Listen for simple UDP mouse commands from the **main PC** (where your AI / detection runs).
- Forward those commands to the local Makcu device over its COM port.

This lets you keep all heavy AI work on a powerful main PC, while still injecting mouse movement via Makcu on a separate machine.

---

## Protocol Overview

MakcuRelay listens on a configurable UDP port (default `5005`) and understands a small set of text commands:

- `MOVE:dx,dy`  
  Move the Makcu mouse by a relative offset (`dx`, `dy`), e.g. `MOVE:-5,12`.

- `PRESS:LEFT` / `PRESS:RIGHT`  
  Press and hold the left or right mouse button.

- `RELEASE:LEFT` / `RELEASE:RIGHT`  
  Release the left or right mouse button.

- `CLICK:LEFT` / `CLICK:RIGHT`  
  Convenience one‑shot click (press + release).

All commands are ASCII, newline not required (trailing whitespace is ignored).

The corresponding Makcu serial protocol messages are handled internally via `MakcuConnection`.

---

## Building (Windows, CMake)

Requirements:

- Windows 10/11 x64
- Visual Studio 2022 with C++ toolchain
- CMake 3.20+ in `PATH`

Build steps:

```powershell
git clone https://github.com/needitem/MakcuRelay.git
cd MakcuRelay

cmake -S . -B build
cmake --build build --config Release
```

The resulting executable will be at:

```text
build\Release\MakcuRelay.exe
```

---

## Usage

On the **second PC** (Makcu attached here):

1. Make sure your Makcu board is connected and appears as a COM port in Device Manager (e.g. `COM4`).  
2. Run MakcuRelay with the COM port (and optional UDP port):

   ```powershell
   # COM4, default UDP 5005
   MakcuRelay.exe COM4

   # COM5 with custom UDP port 6000
   MakcuRelay.exe COM5 6000
   ```

3. If initialization is successful, you should see a message similar to:

   ```text
   [Makcu] Connected at 4Mbps! PORT: COM4 (Native Windows API - Async I/O)
   [MakcuRelay] Listening for UDP commands (MOVE:x,y / PRESS:LEFT / RELEASE:LEFT / CLICK:LEFT|RIGHT)...
   ```

On the **main PC** (AI / aimbot here):

- Send UDP packets to `SECOND_PC_IP:UDP_PORT` using the protocol above.  
- A typical integration sends `MOVE:dx,dy` on each frame where the AI wants to move the crosshair, and `PRESS:LEFT` / `RELEASE:LEFT` for auto‑shoot.

Example pseudo‑code (C++):

```cpp
// Pseudocode, not a full implementation
SOCKET sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
sockaddr_in addr{};
addr.sin_family = AF_INET;
addr.sin_port = htons(5005);                // must match MakcuRelay
InetPtonA(AF_INET, "192.168.0.20", &addr.sin_addr); // second PC IP

// Send a relative movement
std::string msg = "MOVE:-5,12";
sendto(sock, msg.c_str(), (int)msg.size(), 0,
       reinterpret_cast<const sockaddr*>(&addr), sizeof(addr));
```

---

## Notes

- MakcuRelay is intentionally minimal: no GUI, no logging framework, no configuration files.
- Error messages (e.g. COM open failures) are printed to the console.
- If the COM port cannot be opened (`Unable to open port`), verify:
  - The correct COM port name (`COM4`, `COM5`, …).
  - No other program is using that port.
  - Makcu drivers/firmware are correctly installed.

---

## License

This project is released under the MIT License. See `LICENSE` if present in this repository.

