package main

import (
	transportHttp "github.com/andruixxd31/s3-bucket/internal/transport/http"
)

func main() {
	httpHandler := transportHttp.NewHandler()
	httpHandler.Serve()
}
