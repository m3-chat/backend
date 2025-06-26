FROM oven/bun:1.1.13

WORKDIR /app

# Install curl
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Download and install Ollama
RUN mkdir -p /usr/local/bin && \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
    curl -L --fail --retry 3 -o /tmp/ollama-linux-amd64.tgz https://ollama.com/download/ollama-linux-amd64.tgz && \
    mkdir -p /tmp/ollama-extract && \
    tar -tzf /tmp/ollama-linux-amd64.tgz && \
    tar -xzf /tmp/ollama-linux-amd64.tgz -C /tmp/ollama-extract && \
    cp $(find /tmp/ollama-extract -type f -name 'ollama') /usr/local/bin/ollama && \
    rm -rf /tmp/ollama-extract /tmp/ollama-linux-amd64.tgz && \
    chmod +x /usr/local/bin/ollama; \
    elif [ "$ARCH" = "aarch64" ]; then \
    curl -L --fail --retry 3 -o /tmp/ollama-linux-arm64.tgz https://ollama.com/download/ollama-linux-arm64.tgz && \
    mkdir -p /tmp/ollama-extract && \
    tar -tzf /tmp/ollama-linux-arm64.tgz && \
    tar -xzf /tmp/ollama-linux-arm64.tgz -C /tmp/ollama-extract && \
    cp $(find /tmp/ollama-extract -type f -name 'ollama') /usr/local/bin/ollama && \
    rm -rf /tmp/ollama-extract /tmp/ollama-linux-arm64.tgz && \
    chmod +x /usr/local/bin/ollama; \
    else \
    echo "Unsupported architecture: $ARCH" && exit 1; \
    fi


COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY . .

ENV PORT=2000
EXPOSE 2000

# Create startup script
RUN echo '#!/bin/bash\n\
    echo "Starting Ollama server..."\n\
    ollama serve > /var/log/ollama.log 2>&1 &\n\
    OLLAMA_PID=$!\n\
    \n\
    # Wait for Ollama to be ready\n\
    echo "Waiting for Ollama server to be ready..."\n\
    max_attempts=30\n\
    attempt=0\n\
    while [ $attempt -lt $max_attempts ]; do\n\
    if curl -s http://localhost:11434/api/version > /dev/null; then\n\
    echo "Ollama server is ready!"\n\
    break\n\
    fi\n\
    attempt=$((attempt+1))\n\
    echo "Waiting for Ollama server (attempt $attempt/$max_attempts)..."\n\
    sleep 1\n\
    done\n\
    \n\
    if [ $attempt -eq $max_attempts ]; then\n\
    echo "Ollama server failed to start in time. Check logs at /var/log/ollama.log"\n\
    exit 1\n\
    fi\n\
    \n\
    # Start the main application\n\
    echo "Starting Bun application..."\n\
    exec bun start\n\
    ' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]
