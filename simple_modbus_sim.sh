#!/bin/bash

# Function to start the Python Modbus simulator
start_simulator() {
    echo "Starting Modbus simulator..."
    nohup python simple-modbus_sim.py >/dev/null 2>&1
    pid=$!
    echo $pid > modbus_simulator.pid
    if [ -z "$pid" ]; then
        echo "Failed to start Modbus simulator."
    else
        echo "Modbus simulator started with PID $pid."
    fi
}

# Function to stop the Python Modbus simulator
stop_simulator() {
    echo "Stopping Modbus simulator..."
    if [ -f modbus_simulator.pid ]; then
        pid=$(cat modbus_simulator.pid)
        if kill -0 $pid 2>/dev/null; then
            kill $pid
            echo "Modbus simulator stopped."
        else
            echo "No running simulator with PID $pid."
        fi
        rm -f modbus_simulator.pid
    else
        echo "No PID file found. Is the simulator running?"
    fi
}

# Main function to handle user commands
main() {
    echo "Modbus Simulator Control Script"
    read -p "Enter command (start/stop): " command
    case "$command" in
        start)
            start_simulator
            ;;
        stop)
            stop_simulator
            ;;
        *)
            echo "Invalid command."
            ;;
    esac
}

main
