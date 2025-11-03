#!/bin/bash

# Start Ollama server in the background
ollama serve &

# Wait for the server to be ready (health check loop)
until curl --fail --silent --head http://localhost:11434; do
    sleep 1
done

# Check if models are already present; pull if not
if ! ollama list | grep -q "gemma3:12b"; then  
    ollama pull gemma3:12b
fi

if ! ollama list | grep -q "mxbai-embed-large"; then
    ollama pull mxbai-embed-large
fi

# Keep the container running (wait for the background process)
wait