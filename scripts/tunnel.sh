#!/bin/bash

PORT=2000

# Check if ngrok is installed
if ! command -v ngrok &> /dev/null
then
  echo "ngrok not found. Please install it first: https://ngrok.com/download"
  exit 1
fi

# Start ngrok in the background, logging to ngrok.log
ngrok http $PORT --log=stdout > ngrok.log 2>&1 &

NGROK_PID=$!

echo "Starting ngrok tunnel on port $PORT..."

# Wait for ngrok to initialize
sleep 5

# Query ngrok local API for tunnel info
PUBLIC_URL=$(curl --silent http://127.0.0.1:4040/api/tunnels | \
  grep -oP '"public_url":"\Khttps://[^"]+')

if [ -z "$PUBLIC_URL" ]; then
  echo "Failed to get public URL from ngrok"
  kill $NGROK_PID
  exit 1
fi

echo "Ngrok tunnel URL: $PUBLIC_URL"
echo ""
echo "Add this to your .env file:"
echo "TUNNEL=$PUBLIC_URL"

echo ""
echo "Press Ctrl+C to stop ngrok."

# Wait for ngrok to exit (keep script running)
wait $NGROK_PID
