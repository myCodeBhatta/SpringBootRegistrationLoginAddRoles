
#!/bin/bash

# Set the main directory to search
TARGET_DIR="/path/to/your/folder"

# Loop through each subfolder in the target directory
for subfolder in "$TARGET_DIR"/*/; do
    # Get the name of the subfolder
    subfolder_name=$(basename "$subfolder")
    
    # Count the number of .war files in the current subfolder
    war_count=$(find "$subfolder" -maxdepth 1 -type f -name "*.war" | wc -l)
    
    # Print the subfolder name and the .war file count
    echo "Subfolder: $subfolder_name, .war file count: $war_count"
done



#!/bin/bash

# Set the main directory to search
TARGET_DIR="/path/to/your/folder"

# Define the expected count of .war files for each subfolder in an associative array
# Format: ["subfolder_name"]=expected_count
declare -A expected_counts
expected_counts["subfolder1"]=3
expected_counts["subfolder2"]=5
expected_counts["subfolder3"]=2

# Loop through each subfolder in the target directory
for subfolder in "$TARGET_DIR"/*/; do
    # Get the name of the subfolder
    subfolder_name=$(basename "$subfolder")
    
    # Count the number of .war files, excluding "healthcheck.war" and "service.war"
    war_count=$(find "$subfolder" -maxdepth 1 -type f -name "*.war" ! -name "healthcheck.war" ! -name "service.war" | wc -l)
    
    # Check if there's an expected count for this subfolder
    if [[ -v expected_counts["$subfolder_name"] ]]; then
        expected_count=${expected_counts["$subfolder_name"]}
        
        # Compare the actual count to the expected count
        if [[ "$war_count" -eq "$expected_count" ]]; then
            echo "Subfolder: $subfolder_name - .war file count matches the expected count: $war_count"
        else
            echo "Subfolder: $subfolder_name - WARNING: .war file count ($war_count) does NOT match the expected count ($expected_count)"
        fi
    else
        # If no expected count is defined for this subfolder, just print the count
        echo "Subfolder: $subfolder_name - .war file count: $war_count (no expected count defined)"
    fi
done


    
