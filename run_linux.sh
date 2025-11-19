#!/bin/bash

# MakcuRelay Linux Run Helper Script

EXECUTABLE="./MakcuRelay"
BUILD_SCRIPT="./build_linux.sh"

# Check if executable exists
if [ ! -f "$EXECUTABLE" ]; then
    echo "Executable not found. Building..."
    if [ -f "$BUILD_SCRIPT" ]; then
        bash "$BUILD_SCRIPT"
    else
        echo "Error: Build script $BUILD_SCRIPT not found!"
        exit 1
    fi
fi

# Function to list serial ports
list_ports() {
    echo "Available Serial Ports:"
    echo "-----------------------"
    ports=$(ls /dev/ttyUSB* /dev/ttyACM* /dev/ttyS* 2>/dev/null)
    if [ -z "$ports" ]; then
        echo "No serial ports found!"
        echo "Please check if your device is connected."
    else
        for port in $ports; do
            echo "  $port"
        done
    fi
    echo "-----------------------"
}

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: ./run_linux.sh [SERIAL_PORT] [UDP_PORT]"
    echo ""
    list_ports
    echo ""
    echo "Example: ./run_linux.sh /dev/ttyUSB0 5005"
    exit 1
fi

SERIAL_PORT=$1
UDP_PORT=$2

# Check if port exists
if [ ! -e "$SERIAL_PORT" ]; then
    echo "Error: Serial port $SERIAL_PORT does not exist."
    echo ""
    list_ports
    exit 1
fi

# Check permissions
if [ ! -r "$SERIAL_PORT" ] || [ ! -w "$SERIAL_PORT" ]; then
    echo "Warning: You may not have permission to access $SERIAL_PORT."
    echo "Try running: sudo usermod -a -G dialout $USER"
    echo "Then log out and log back in."
    echo "Or run with sudo (not recommended for regular use)."
    echo ""
    read -p "Attempt to run anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Run the application
echo "Starting MakcuRelay..."
$EXECUTABLE "$SERIAL_PORT" "$UDP_PORT"
