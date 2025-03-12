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
./testssl.sh --fast "$TARGET" > testssl_output.txt

# Debug: Ensure output file is not empty
if ! [ -s testssl_output.txt ]; then
    echo "Error: testssl.sh did not produce any output. Check if testssl.sh is working correctly."
    exit 1
fi

# Extract TLS versions
echo "TLS Versions Supported:" > "$OUTPUT_FILE"
grep -E "TLS 1\.[0-3]" testssl_output.txt | grep -E "offered|not offered" >> "$OUTPUT_FILE"

# Extract Cipher Suites
echo -e "\nTLS Cipher Suites Supported:" >> "$OUTPUT_FILE"
awk '/Testing server.s cipher preferences/,/Server signature algorithm/' testssl_output.txt | grep -E "TLS|offered|WITH_" >> "$OUTPUT_FILE"

#Cleaning the output
sed 's/\x1b\[[0-9;]*m//g' "$OUTPUT_FILE" > cleaned_tls_info.txt

# Show the extracted information
cat "$OUTPUT_FILE"

echo "Extracted TLS information saved to $OUTPUT_FILE"
