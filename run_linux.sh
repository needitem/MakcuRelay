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
if [ $# -ge 2 ]; then
    SERIAL_PORT=$1
    UDP_PORT=$2
else
    echo "Scanning for serial ports..."
    ports=($(ls /dev/ttyUSB* /dev/ttyACM* /dev/ttyS* 2>/dev/null))
    
    if [ ${#ports[@]} -eq 0 ]; then
        echo "No serial ports found!"
        echo "Please check connection and try again."
        exit 1
    fi

    echo "Available Serial Ports:"
    for i in "${!ports[@]}"; do
        echo "[$i] ${ports[$i]}"
    done
    echo ""

    read -p "Select port number [0]: " port_index
    port_index=${port_index:-0}

    if [[ ! "$port_index" =~ ^[0-9]+$ ]] || [ "$port_index" -ge "${#ports[@]}" ]; then
        echo "Invalid selection."
        exit 1
    fi

    SERIAL_PORT=${ports[$port_index]}
    
    read -p "Enter UDP Port [5005]: " UDP_PORT
    UDP_PORT=${UDP_PORT:-5005}
fi

echo ""
echo "Selected Serial Port: $SERIAL_PORT"
echo "Selected UDP Port:    $UDP_PORT"
echo ""

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
