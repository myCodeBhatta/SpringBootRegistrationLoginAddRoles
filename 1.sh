#!/bin/bash

# Function to get the PID of the Java instance
get_pid() {
    local pid=$(pgrep -f "your-java-instance-name") # Replace "your-java-instance-name" with your Java instance identifier
    echo "$pid"
}

# Function to check the actuator URL status
get_api_router_actuator_status() {
    local actuator_url="http://localhost:8080/actuator/health" # Replace with the actual actuator URL
    local status_code=$(curl -s -o /dev/null -w "%{http_code}" "$actuator_url")
    echo "$status_code"
}

# Main logic
stop_java_instance() {
    local retries=3
    local pid=$(get_pid)

    if [ -z "$pid" ]; then
        echo "Java instance is not running."
        return 0
    fi

    echo "Stopping Java instance with PID: $pid"
    kill "$pid"

    # Check if the process is stopped
    for i in $(seq 1 $retries); do
        sleep 2 # Wait for a couple of seconds
        pid=$(get_pid)
        if [ -z "$pid" ]; then
            echo "Java instance stopped successfully."
            break
        fi

        if [ "$i" -eq "$retries" ]; then
            echo "Failed to stop the Java instance after $retries attempts."
            return 1
        fi
    done

    # Verify with the actuator URL
    for i in $(seq 1 $retries); do
        sleep 2
        local status_code=$(get_api_router_actuator_status)
        if [ "$status_code" -ne 200 ]; then
            echo "Actuator confirms Java instance is stopped. Status code: $status_code"
            return 0
        fi

        if [ "$i" -eq "$retries" ]; then
            echo "Actuator still returns 200 after $retries attempts. Java instance might not have stopped properly."
            return 1
        fi
    done
}

# Execute the script
stop_java_instance
