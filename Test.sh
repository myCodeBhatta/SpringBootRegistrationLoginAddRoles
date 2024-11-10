#!/bin/bash

# Configuration
APP_NAME="API-Gateway"
ACTUATOR_HEALTH_URL="http://localhost:8080/actuator/health"  # Update with your actuator health URL
JAR_NAME="api-gateway"  # Update with the exact name or unique part of the JAR file if needed

# Function to get the PID of the application
get_pid() {
    echo $(pgrep -f "$JAR_NAME")
}

# Function to check the health of the application
check_health() {
    local health_status
    health_status=$(curl -s $ACTUATOR_HEALTH_URL | grep -o '"status":"UP"')
    if [[ "$health_status" == '"status":"UP"' ]]; then
        echo "$APP_NAME is running."
        return 0
    else
        echo "$APP_NAME is not healthy or not running."
        return 1
    fi
}

# Start of the script
echo "Checking if $APP_NAME is running..."

# Check if the application is running by checking the health endpoint and PID
if check_health && [[ -n $(get_pid) ]]; then
    echo "$APP_NAME is confirmed to be running. Proceeding to stop the instance."

    # Get the PID
    PID=$(get_pid)
    echo "Stopping $APP_NAME with PID $PID..."
    kill "$PID"

    # Check if the application has stopped
    for attempt in {1..2}; do
        echo "Checking status of $APP_NAME after stop attempt $attempt..."
        sleep 2
        if ! check_health && [[ -z $(get_pid) ]]; then
            echo "$APP_NAME has been successfully stopped."
            exit 0
        fi
    done

    # If still running, provide feedback
    echo "Warning: $APP_NAME did not stop successfully after multiple checks."
else
    echo "$APP_NAME is not currently running. No action needed."
fi
