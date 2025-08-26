#!/usr/bin/env bash

# rclone-prune: Clean up crypt remotes with size reporting
# This script runs rclone cleanup --b2-hard-delete against all crypt remotes
# and reports the size before and after cleanup
#
# Usage: rclone-prune [remote_name]
#   If remote_name is provided, only that remote will be processed
#   If no argument is provided, all crypt remotes will be processed

set -e

# Function to get all crypt remotes
get_crypt_remotes() {
    rclone listremotes --type crypt
}

# Function to validate if a remote is a crypt remote
is_crypt_remote() {
    local remote="$1"
    rclone listremotes --type crypt | grep -q "^${remote}$"
}

# Function to print remote size
print_remote_size() {
    local remote="$1"
    echo "=== Size of ${remote} ==="
    rclone size "${remote}" || echo "Failed to get size for ${remote}"
    echo
}

# Function to cleanup remote
cleanup_remote() {
    local remote="$1"
    echo "=== Cleaning up ${remote} ==="
    rclone cleanup "${remote}" --b2-hard-delete || echo "Failed to cleanup ${remote}"
    echo
}

# Main execution
echo "Starting rclone-prune script..."
echo "=================================="
echo

# Check if a specific remote was provided
if [ $# -eq 1 ]; then
    remote_name="$1"
    
    # Validate that the provided remote is a crypt remote
    if ! is_crypt_remote "$remote_name"; then
        echo "Error: '$remote_name' is not a valid crypt remote."
        echo "Available crypt remotes:"
        get_crypt_remotes | sed 's/^/  - /'
        exit 1
    fi
    
    echo "Processing single remote: ${remote_name}"
    echo "----------------------------------------"
    
    # Print size before cleanup
    echo "BEFORE cleanup:"
    print_remote_size "${remote_name}"
    
    # Run cleanup
    cleanup_remote "${remote_name}"
    
    # Print size after cleanup
    echo "AFTER cleanup:"
    print_remote_size "${remote_name}"
    
    echo "========================================"
    echo
else
    # Get all crypt remotes
    crypt_remotes=$(get_crypt_remotes)

    if [ -z "$crypt_remotes" ]; then
        echo "No crypt remotes found."
        exit 0
    fi

    echo "Found crypt remotes:"
    echo "$crypt_remotes" | sed 's/^/  - /'
    echo

    # Process each crypt remote
    while IFS= read -r remote; do
        if [ -n "$remote" ]; then
            echo "Processing remote: ${remote}"
            echo "----------------------------------------"
            
            # Print size before cleanup
            echo "BEFORE cleanup:"
            print_remote_size "${remote}"
            
            # Run cleanup
            cleanup_remote "${remote}"
            
            # Print size after cleanup
            echo "AFTER cleanup:"
            print_remote_size "${remote}"
            
            echo "========================================"
            echo
        fi
    done <<< "$crypt_remotes"
fi

echo "rclone-prune script completed."
