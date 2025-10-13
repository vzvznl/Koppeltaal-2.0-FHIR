#!/bin/bash
set -e

# If no arguments provided, default to 'build'
if [ $# -eq 0 ]; then
    exec make build
else
    # Pass all arguments to make
    exec make "$@"
fi