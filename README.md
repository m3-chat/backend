# m3-chat Backend

This is the backend service for **m3-chat**, a 100% open-source and free AI chat web app powered by local AI models using [Ollama](https://ollama.com).

![Diagram](https://github.com/user-attachments/assets/841c7853-a643-425d-8913-1ef48d0f256f)

---

## Overview

The backend exposes an API endpoint that proxies requests to local AI models, streams responses back to the frontend in real-time, and manages communication with the Ollama CLI.

- **Tech stack:** C#, .NET, Cloudflare Tunnels
- **Streaming:** Uses child process streams for live AI responses
- **Port:** 2000 by default
- **CORS enabled** for frontend integration

---

## API Endpoint

### GET `/api/gen`

**Query Parameters:**

- `model` (string): The AI model to use (e.g., `llama3:8b`)
- `content` (string): The prompt or message content

Streams the AI-generated text response as plain text with chunked transfer encoding.

---

## Development

### Run locally

- Use [infra](https://github.com/m3-chat/infra/)
