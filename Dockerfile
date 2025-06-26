FROM oven/bun:1.1.13

WORKDIR /app

# Install curl
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Download and install Ollama ARM64 Linux binary
RUN curl -L -o /tmp/ollama-linux-arm64.tgz https://ollama.com/download/ollama-linux-arm64.tgz \
    && tar -xzf /tmp/ollama-linux-arm64.tgz -C /usr/local/bin \
    && rm /tmp/ollama-linux-arm64.tgz \
    && chmod +x /usr/local/bin/ollama

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY . .

ENV PORT=2000
EXPOSE 2000

CMD ["bun", "start"]
