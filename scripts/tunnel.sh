#!/bin/zsh

PORT=2000
LOGFILE="tunnel.log"

echo "Starting LocalXpose tunnel to localhost:$PORT (logging to $LOGFILE)..."

while true; do
  lx tunnel http --to localhost:$PORT >> "$LOGFILE" 2>&1
  if [[ $? -ne 0 ]]; then
    echo "Tunnel crashed. Restarting in 5 seconds..."
    sleep 5
  else
    echo "Tunnel exited normally."
    break
  fi
done
