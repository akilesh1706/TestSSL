#!/bin/bash

#Fix locale issue
export LC_ALL=C
export LANG=C

#Check if the JSON file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <json_file>"
    exit 1
fi

JSON_FILE=$1

# Check if jq is installed (used for parsing JSON)
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it using 'sudo apt install jq'."
    exit 1
fi

# Validate the JSON file
if ! jq empty "$JSON_FILE" 2>/dev/null; then
    echo "Error: Invalid JSON file."
    exit 1
fi

# Extract the list of targets from the JSON file
TARGETS=$(jq -r '.targets[]' "$JSON_FILE")

# Check if targets are present
if [ -z "$TARGETS" ]; then
    echo "Error: No targets found in the JSON file."
    exit 1
fi

# Create an output directory
OUTPUT_DIR="tls_info_outputs"
mkdir -p "$OUTPUT_DIR"

# Process each target
for TARGET in $TARGETS; do
    echo "Processing target: $TARGET"
    
    # Run the extract_tls_info1.sh script
    ./extract_tls_info1.sh "$TARGET"
    
    # Check if the cleaned_tls_info.txt file was generated
    if [ -f "cleaned_tls_info.txt" ]; then
        # Save the output to a separate file for each target
        mv "cleaned_tls_info.txt" "$OUTPUT_DIR/${TARGET}_tls_info.txt"
        echo "Output saved to $OUTPUT_DIR/${TARGET}_tls_info.txt"
    else
        echo "Error: No output generated for $TARGET."
    fi
done

echo "Processing complete. All outputs are saved in the $OUTPUT_DIR directory."