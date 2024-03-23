package http

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

type Handler struct {
	Router    *http.ServeMux
	Server    *http.Server
	S3Service *s3.Client
}

type Response struct {
	Status  int
	Message string
	Count   int
}

func NewHandler() *Handler {
	h := &Handler{}
	h.Router = http.NewServeMux()
	h.Server = &http.Server{
		Addr:    ":4009",
		Handler: h.Router,
	}

	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithSharedConfigProfile("andres-s3"))
	if err != nil {
		log.Fatal(err)
	}

	h.S3Service = s3.NewFromConfig(cfg)

	h.mapRoutes()
	return h
}

func (h *Handler) Serve() error {
	go func() {
		if err := h.Server.ListenAndServe(); err != nil {
			log.Println(err.Error())
		}
	}()

	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	<-c

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	log.Println("shut down gracefully")
	h.Server.Shutdown(ctx)

	return nil
}

func (h *Handler) mapRoutes() {
	h.Router.HandleFunc("/api/v1/list-objects", h.ListBucketObjects)
	h.Router.HandleFunc("/api/v1upload-object", h.UploadObject)
	h.Router.HandleFunc("/api/v1/get-object", h.GetObject)
}
