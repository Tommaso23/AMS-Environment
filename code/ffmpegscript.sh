#!/bin/bash

# Check if two arguments (ffmpeg command and output directory) are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <ffmpeg_command> <output_directory>"
    exit 1
fi

# Get the input and output file paths, and the output directory from the arguments
FFMPEG_COMMAND="$1"
OUTPUT_DIR="$2"
CHANGE_STATUS_API="$3"

# Create the output directory if it doesn't exist
mkdir -p "/mnt/azfile/$OUTPUT_DIR/output"

# Run ffmpeg command
eval "$FFMPEG_COMMAND"

# Capture the exit status
EXIT_STATUS=$?

#Create the JSON object
JSON_DATA="{\"exitStatus\": $EXIT_STATUS, \"jobId\": \"$OUTPUT_DIR\"}"

# Check if the ffmpeg command succeeded
if [ $EXIT_STATUS -eq 0 ]; then
	curl -X POST -H "Content-Type: application/json" -d "$JSON_DATA" "$CHANGE_STATUS_API"

	# curl -X POST -H "Content-Type: application/json" -d "$JSON_DATA" https://tom-encoder-fa-api.azurewebsites.net/api/encoderJobs/changeStatus?clientId=blobs_extension
    echo "Encoding completed successfully!"
else
	curl -X POST -H "Content-Type: application/json" -d "$JSON_DATA" https://tom-encoder-fa-api.azurewebsites.net/api/encoderJobs/changeStatus?clientId=blobs_extension
    echo "Error during encoding. Exit status: $EXIT_STATUS"
fi