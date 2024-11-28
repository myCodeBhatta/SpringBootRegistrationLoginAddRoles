#!/bin/bash

# Function to get the PID of a Java instance
get_pid() {
    local instance_name="$1" # Accept the Java instance name as an argument
    local pid=$(pgrep -f "$instance_name")
    echo "$pid"
}

# Function to stop a process by PID
stop_process_by_pid() {
    local pid="$1" # PID to stop
    if [ -n "$pid" ]; then
        kill "$pid"
        echo "Sent kill signal to process with PID: $pid"
    else
        echo "No PID provided to stop."
    fi
}

# Function to check if a process is stopped
wait_for_process_stop() {
    local instance_name="$1" # Java instance name to identify the PID
    local retries="$2"       # Number of retries to check
    local interval="$3"      # Time interval between checks

    for attempt in $(seq 1 "$retries"); do
        local pid=$(get_pid "$instance_name")
        if [ -z "$pid" ]; then
            echo "Process for instance '$instance_name' has stopped."
            return 0
        fi
        echo "Waiting for process to stop (Attempt $attempt/$retries)..."
        sleep "$interval"
    done

    echo "Process for instance '$instance_name' did not stop after $retries attempts."
    return 1
}

# Function to check actuator URL status
get_actuator_status() {
    local url="$1" # Actuator URL to check
    local status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    echo "$status_code"
}

# Function to wait for actuator to confirm the instance is stopped
wait_for_actuator_stop() {
    local url="$1"      # Actuator URL
    local retries="$2"  # Number of retries to check
    local interval="$3" # Time interval between checks

    for attempt in $(seq 1 "$retries"); do
        local status_code=$(get_actuator_status "$url")
        if [ "$status_code" -ne 200 ]; then
            echo "Actuator confirms instance is stopped (Status code: $status_code)."
            return 0
        fi
        echo "Actuator still indicates instance is running (Status code: $status_code). Waiting (Attempt $attempt/$retries)..."
        sleep "$interval"
    done

    echo "Actuator did not confirm instance stop after $retries attempts."
    return 1
}

# Main logic to stop a Java instance
stop_java_instance() {
    local instance_name="$1" # Java instance name
    local actuator_url="$2"  # Actuator URL
    local retries=3          # Number of retries for checks
    local interval=2         # Time interval between retries

    # Get the PID of the Java instance
    local pid=$(get_pid "$instance_name")
    if [ -z "$pid" ]; then
        echo "Java instance '$instance_name' is not running."
        return 0
    fi

    # Stop the Java instance
    echo "Stopping Java instance '$instance_name' with PID: $pid"
    stop_process_by_pid "$pid"

    # Wait for the process to stop
    if ! wait_for_process_stop "$instance_name" "$retries" "$interval"; then
        echo "Failed to stop the Java instance process."
        return 1
    fi

    # Check the actuator status to ensure the instance is stopped
    if ! wait_for_actuator_stop "$actuator_url" "$retries" "$interval"; then
        echo "Actuator did not confirm that the instance has stopped."
        return 1
    fi

    echo "Java instance '$instance_name' has been stopped successfully."
    return 0
}

# Run the script with instance name and actuator URL
# Replace "your-java-instance-name" and "http://localhost:8080/actuator/health" with actual values
INSTANCE_NAME="your-java-instance-name"
ACTUATOR_URL="http://localhost:8080/actuator/health"

stop_java_instance "$INSTANCE_NAME" "$ACTUATOR_URL"
