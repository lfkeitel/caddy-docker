package caddymain

import (
	"os"

	"github.com/mholt/caddy/telemetry"
)

var enableTelemetry = false

func init() {
	switch os.Getenv("CADDY_TELEMETRY_ENABLE") {
	case "1", "true", "t":
		enableTelemetry = true
	}

	telemEndpoint := os.Getenv("CADDY_TELEMETRY_ENDPOINT")
	if telemEndpoint != "" {
		telemetry.Endpoint = telemEndpoint
	}
}
