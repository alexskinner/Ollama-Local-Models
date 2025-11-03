# Use the official Ollama image as the base
FROM ollama/ollama

# Install curl for health checking
RUN apt-get update && apt-get install -y curl

# Copy the custom startup script
COPY start.sh /start.sh

# Make the script executable
RUN chmod +x /start.sh

# Expose the Ollama API port
EXPOSE 11434

# Use the custom script as the entrypoint
ENTRYPOINT ["/start.sh"]