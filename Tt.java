
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
