FROM oven/bun:1.1.13

WORKDIR /app

# Install curl
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Download and install Ollama
RUN mkdir -p /usr/local/bin && \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
    curl -L --fail --retry 3 -o /tmp/ollama-linux-amd64.tgz https://ollama.com/download/ollama-linux-amd64.tgz && \
    tar -xzf /tmp/ollama-linux-amd64.tgz --strip-components=1 -C /usr/local/bin && \
    rm /tmp/ollama-linux-amd64.tgz && \
    chmod +x /usr/local/bin/ollama; \
    elif [ "$ARCH" = "aarch64" ]; then \
    curl -L --fail --retry 3 -o /tmp/ollama-linux-arm64.tgz https://ollama.com/download/ollama-linux-arm64.tgz && \
    tar -xzf /tmp/ollama-linux-arm64.tgz --strip-components=1 -C /usr/local/bin && \
    rm /tmp/ollama-linux-arm64.tgz && \
    chmod +x /usr/local/bin/ollama; \
    else \
    echo "Unsupported architecture: $ARCH" && exit 1; \
    fi


COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY . .

ENV PORT=2000
EXPOSE 2000

CMD ["bun", "start"]
