#!/usr/bin/env bash

go mod init ngrok-tunnel

go get golang.ngrok.com/ngrok/v2
go get golang.ngrok.com/ngrok
go get golang.ngrok.com/ngrok/config
go get github.com/joho/godotenv
