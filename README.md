3.  **Connection**: The AI PC sends commands over the local network (UDP) to the Gaming PC.
4.  **Execution**: MakcuRelay receives these commands and forwards them to a connected Arduino device, which physically moves the mouse on the Gaming PC.

This architecture provides the highest level of isolation, as the cheat software is not running on the same machine as the game / anti-cheat.

## Features

*   **Ultra-Low Latency UDP**: Uses a custom UDP protocol to minimize network delay (<1ms on LAN).
*   **Secure Forwarding**: Only accepts commands from authorized IPs (configurable).
*   **Hardware Integration**: Seamlessly talks to Arduino devices flashed with MakcuFlasher firmware.

## Prerequisites

*   **Gaming PC**: Windows 10/11, Arduino Device (flashed), Python 3.10+.
*   **AI PC**: Windows 10/11, NeedAimBot installed.
*   **Network**: Both PCs must be on the same high-speed Local Area Network (Ethernet recommended).

## Setup Guide

### 1. Gaming PC (Receiver)
1.  Connect your flashed Arduino device to this PC.
2.  Install Python dependencies:
    ```bash
    pip install pyserial
    ```
3.  Run the relay script:
    ```bash
    python MakcuRelay.py
    ```
    *   *Optional arguments*: You may need to specify COM port or baud rate if not auto-detected.
4.  Note the Gaming PC's local IP address (e.g., `192.168.1.20`).

### 2. AI PC (Sender)
1.  Navigate to your **NeedAimBot** folder.
2.  Open `config.ini`.
3.  Configure the `[MAKCU]` section:
    ```ini
    [Mouse]
    input_method = MAKCU

    [MAKCU]
    makcu_remote_ip = 192.168.1.20  ; IP of the Gaming PC
    makcu_remote_port = 5005        ; Default port
    ```
4.  Run NeedAimBot.

## Troubleshooting

*   **Connection Timeout**: Ensure Windows Firewall is allowing traffic on port 5005 (UDP) on the Gaming PC.
*   **Lag**: Use a wired Ethernet connection. Wi-Fi can introduce inconsistent latency.
*   **Arduino Error**: Ensure no other application (like a slicer or serial monitor) is using the COM port on the Gaming PC.

## Disclaimer

Using Dual-PC hardware setups is an advanced method to bypass anti-cheat protections. While safer than single-PC software, it is not immune to detection (e.g., heuristic analysis of mouse movement). Use at your own risk.
