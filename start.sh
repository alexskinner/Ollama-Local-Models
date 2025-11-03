#!/bin/bash

# Default models if OLLAMA_MODEL is not set
DEFAULT_MODELS="gemma3:12b mxbai-embed-large"

# Use MODELS if set, else fallback to defaults
MODELS="${MODELS:-$DEFAULT_MODELS}"

# Split comma-separated list into space-separated (for looping)
MODELS=$(echo "$MODELS" | tr ',' ' ')

# Set temp OLLAMA_HOST for localhost-only server on a non-exposed port
export OLLAMA_HOST=127.0.0.1:11435

# Start temp Ollama server in the background for pulls/checks
ollama serve &

# Wait for the temp server to be ready (health check loop with timeout)
for i in {1..60}; do
    if curl --fail --silent --head http://127.0.0.1:11435; then
        break
    fi
    sleep 1
done

# If the loop timed out, exit with error
if [ "$i" -eq 60 ]; then
    echo "Error: Temp Ollama server failed to start within 60 seconds."
    exit 1
fi

# Check/pull each model if not already present (using temp server)
for MODEL in $MODELS; do
    if ! ollama list | grep -q "$MODEL"; then
        echo "Pulling $MODEL "
        ollama pull "$MODEL"
    else
        echo "Model $MODEL already exists, skipping pull."
    fi
done

# Kill the temp server process
pkill ollama

# Unset the temp OLLAMA_HOST to default 0.0.0.0:11434 for exposure
export OLLAMA_HOST=0.0.0.0:11434


echo "Starting the accessible server"

# Start the final Ollama server (now with models ready)
ollama serve