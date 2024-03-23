package http

import (
	"context"
	"encoding/json"
	"net/http"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func (h *Handler) ListBucketObjects(w http.ResponseWriter, r *http.Request) {
	output, err := h.S3Service.ListObjectsV2(context.TODO(), &s3.ListObjectsV2Input{
		Bucket: aws.String("go-practice-bucket"),
	})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}

	var response []map[string]any
	for _, object := range output.Contents {
		obj := map[string]any{
			"key":  aws.ToString(object.Key),
			"size": object.Size,
		}
		response = append(response, obj)
	}

	respJSON, err := json.Marshal(response)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	_, err = w.Write(respJSON)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

func (h *Handler) UploadObject(w http.ResponseWriter, r *http.Request) {

}

func (h *Handler) GetObject(w http.ResponseWriter, r *http.Request) {

}
