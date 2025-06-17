#!/usr/bin/env bash

cloudflared tunnel --url http://localhost:"$1" --config ./cloudflared.tunnel.config.yml