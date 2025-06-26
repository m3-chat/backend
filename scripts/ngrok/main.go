package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"path/filepath"

	"github.com/joho/godotenv"
	"golang.ngrok.com/ngrok"
	"golang.ngrok.com/ngrok/config"
)

func main() {
	rootEnvPath := filepath.Join("..", "..", ".env")
	_ = godotenv.Load(rootEnvPath)

	token := os.Getenv("NGROK_AUTHTOKEN")
	if token == "" {
		log.Fatal("Missing NGROK_AUTHTOKEN")
	}

	tun, err := ngrok.Listen(context.Background(), config.HTTPEndpoint(), ngrok.WithAuthtoken(token))
	if err != nil {
		log.Fatal("ngrok tunnel error:", err)
	}

	fmt.Println("ngrok tunnel started at:", tun.URL())

	port := os.Getenv("PORT")
	if port == "" {
		port = "2000"
	}
	target, _ := url.Parse("http://localhost:" + port)
	proxy := httputil.NewSingleHostReverseProxy(target)

	originalDirector := proxy.Director
	proxy.Director = func(req *http.Request) {
		originalDirector(req)
		req.Header.Set("ngrok-skip-browser-warning", "true")
	}

	err = http.Serve(tun, proxy)
	if err != nil {
		log.Fatal("error serving proxy:", err)
	}
}
