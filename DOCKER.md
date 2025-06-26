# DOCKER.md

This document guides you through using Docker to run the M3 Chat backend services, including the Elysia Bun API server and the Go-based ngrok tunnel for public exposure.

---

## Table of Contents

- [Overview](#overview)
- [Dockerfiles](#dockerfiles)

  - [Dockerfile (Elysia Bun API)](#dockerfile-elysia-bun-api)
  - [Dockerfile.tunnel (Go ngrok Tunnel)](#dockerfiletunnel-go-ngrok-tunnel)

- [docker-compose.yml](#docker-composeyml)
- [Setup Instructions](#setup-instructions)
- [Running the Services](#running-the-services)
- [Testing and Troubleshooting](#testing-and-troubleshooting)
- [Environment Variables](#environment-variables)

---

## Overview

The backend consists of two main components:

1. **Elysia API server:** Runs on Bun, serves your API at port 2000.
2. **Ngrok Tunnel:** A Go app that exposes your local API to the internet via ngrok and proxies requests to the Elysia API.

We use Docker and Docker Compose to build and run these services together in a networked environment.

---

## Dockerfiles

### Dockerfile (Elysia Bun API)

This builds the Bun environment and runs your Elysia backend.

```dockerfile
FROM oven/bun:1.1.13

WORKDIR /app

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY . .

ENV PORT=2000
EXPOSE 2000

CMD ["bun", "start"]
```

- Installs dependencies using `bun install`.
- Exposes port 2000 for API access.
- Runs `bun start` to start the server.

---

### Dockerfile.tunnel (Go ngrok Tunnel)

This builds the Go tunnel app that uses ngrok to expose the API publicly.

```dockerfile
FROM golang:1.24-alpine AS builder

WORKDIR /app
COPY ./scripts/ngrok/main.go .
COPY go.mod go.sum ./
RUN go mod tidy && go build -o tunnel main.go

FROM alpine
WORKDIR /app
COPY --from=builder /app/tunnel .
CMD ["./tunnel"]
```

- Uses Go 1.24 Alpine image to build the binary.
- Copies the built binary into a minimal Alpine image.
- Runs the tunnel on container start.

---

## docker-compose.yml

This orchestrates the two services and connects them on a shared network.

```yaml
version: "3.8"

services:
  elysia-api:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "2000:2000"
    networks:
      - m3net

  ngrok-tunnel:
    build:
      context: .
      dockerfile: Dockerfile.tunnel
    environment:
      NGROK_AUTHTOKEN: ${NGROK_AUTHTOKEN}
    networks:
      - m3net
    depends_on:
      - elysia-api

networks:
  m3net:
    driver: bridge
```

- Both containers share the `m3net` bridge network, allowing the tunnel container to reach the API container by the hostname `elysia-api`.
- The ngrok token is injected via environment variable.

---

## Setup Instructions

1. **Set your ngrok auth token**

   Create a `.env` file in the project root with:

   ```
   NGROK_AUTHTOKEN=your_ngrok_auth_token_here
   PORT=api_localhost_port (2000 by default)
   ```

2. **Build the Docker images**

   ```bash
   docker-compose build
   ```

3. **Run the services**

   ```bash
   docker-compose up
   ```

---

## Running the Services

- The Elysia API will be available on your host at `http://localhost:2000` (or the port specified in your `.env`).

- The ngrok tunnel will start and expose your API publicly, printing a URL like:

  ```
    ngrok tunnel started at: https://abc123.ngrok.io
  ```

- Use the public URL to access your API remotely.

---

## Testing and Troubleshooting

- **Test API locally:**

  ```bash
  curl http://localhost:2000/api/models
  ```

- **Test via ngrok tunnel:**

  Use the tunnel URL printed by the tunnel container.

  ```bash
  curl -H "ngrok-skip-browser-warning: true" https://abc123.ngrok.io/api/models
  ```

- **Common issues:**

  - Tunnel container cannot reach API container?
    Ensure both are on the same Docker network (`m3net`) and use the service name `elysia-api` in your tunnel proxy.

  - Build errors related to Go version?
    Update your `Dockerfile.tunnel` to use a Go version matching your `go.mod` requirement.

---

## Environment Variables

| Variable          | Description                     | Required      |
| ----------------- | ------------------------------- | ------------- |
| `NGROK_AUTHTOKEN` | Your ngrok authentication token | Yes           |
| `PORT`            | Port your Elysia API listens on | Default: 2000 |
