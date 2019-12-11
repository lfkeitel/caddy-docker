package caddymain

import (
	"os"

	"github.com/caddyserver/caddy/telemetry"
)

func init() {
	EnableTelemetry = false

	switch os.Getenv("CADDY_TELEMETRY_ENABLE") {
	case "1", "true", "t":
		EnableTelemetry = true
	}

	telemEndpoint := os.Getenv("CADDY_TELEMETRY_ENDPOINT")
	if telemEndpoint != "" {
		telemetry.Endpoint = telemEndpoint
	}
}
