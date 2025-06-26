package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/joho/godotenv"
	"golang.ngrok.com/ngrok"
	"golang.ngrok.com/ngrok/config"
)

func main() {
	// Get the absolute path to the project root
	rootEnvPath := filepath.Join("..", "..", ".env")
	godotenv.Load(rootEnvPath)

	token := os.Getenv("NGROK_AUTHTOKEN")
	if token == "" {
		log.Fatal("Missing NGROK_AUTHTOKEN")
	}

	tun, err := ngrok.Listen(
		context.Background(),
		config.HTTPEndpoint(),
		ngrok.WithAuthtoken(token),
	)
	if err != nil {
		log.Fatal("ngrok tunnel error:", err)
	}

	fmt.Println("✅ tunnel started at:", tun.URL())
}
