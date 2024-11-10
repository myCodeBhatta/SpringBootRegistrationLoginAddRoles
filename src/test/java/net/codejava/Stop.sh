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
    local response_code
    response_code=$(curl -s -o /dev/null -w "%{http_code}" $ACTUATOR_HEALTH_URL)
    
    if [[ "$response_code" == "000" ]]; then
        echo "$APP_NAME is down (no response from health endpoint)."
        return 2  # Indicates down
    elif [[ "$response_code" == "200" ]]; then
        local health_status
        health_status=$(curl -s $ACTUATOR_HEALTH_URL | grep -o '"status":"UP"')
        if [[ "$health_status" == '"status":"UP"' ]]; then
            echo "$APP_NAME is running and healthy."
            return 0  # Indicates running and healthy
        else
            echo "$APP_NAME is responding but not healthy."
            return 1  # Indicates responding but not healthy
        fi
    else
        echo "$APP_NAME returned unexpected status code $response_code."
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
        if [[ $(check_health) == 2 && -z $(get_pid) ]]; then
            echo "$APP_NAME has been successfully stopped."
            exit 0
        fi
    done

    # Force kill if still running
    if [[ -n $(get_pid) ]]; then
        echo "$APP_NAME did not stop gracefully. Force killing..."
        kill -9 "$PID"
        
        # Final check to confirm force kill
        sleep 2
        if [[ $(check_health) == 2 && -z $(get_pid) ]]; then
            echo "$APP_NAME has been forcefully stopped."
        else
            echo "Warning: $APP_NAME could not be stopped even with force kill."
        fi
    fi
else
    echo "$APP_NAME is not currently running. No action needed."
fi
