#!/bin/bash

# Fix locale issue
export LC_ALL=C
export LANG=C

# Check if target is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <target>"
    exit 1
fi

TARGET=$1
OUTPUT_FILE="tls_info.txt"

# Run testssl.sh and capture output
./testssl.sh "$TARGET" > testssl_output.txt

# Debug: Ensure output file is not empty
if ! [ -s testssl_output.txt ]; then
    echo "Error: testssl.sh did not produce any output. Check if testssl.sh is working correctly."
    exit 1
fi

# Extract TLS versions
echo "TLS Versions Supported:" > "$OUTPUT_FILE"
grep -E "TLS (1(\.[0-3])?|1) .*offered" testssl_output.txt | grep -v "not offered" | sed 's/  */ /g' >> "$OUTPUT_FILE"

# Extract TLS cipher suites (Check for correct section in the output)
echo -e "\nTLS Cipher Suites Supported:" >> "$OUTPUT_FILE"
grep -A 10 "server cipher preference" testssl_output.txt | sed '/--/d' >> "$OUTPUT_FILE"

# Show the extracted information
cat "$OUTPUT_FILE"

echo "Extracted TLS information saved to $OUTPUT_FILE"
