package http

import (
	"encoding/json"
	"io"
	"net/http"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

type GetObjectRequest struct {
	Key      string `json:"key"`
	FileName string `json:"fileName"`
}

type UploadObjectRequest struct {
	Key      string `json:"key"`
	FileName string `json:"filename"`
}

func (h *Handler) ListBucketObjects(w http.ResponseWriter, r *http.Request) {
	output, err := h.S3Service.ListObjectsV2(r.Context(), &s3.ListObjectsV2Input{
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
	var gok UploadObjectRequest
	if err := json.NewDecoder(r.Body).Decode(&gok); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	file, err := os.Open(gok.FileName)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer file.Close()

	_, err = h.S3Service.PutObject(r.Context(), &s3.PutObjectInput{
		Bucket: aws.String("go-practice-bucket"),
		Key:    aws.String(gok.Key),
		Body:   file,
	})
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	if err := json.NewEncoder(w).Encode(Response{
		Status:  http.StatusOK,
		Message: "Object succesfully uploaded",
	}); err != nil {
		http.Error(w, err.Error(), http.StatusBadGateway)
		return
	}
	return
}

func (h *Handler) GetObject(w http.ResponseWriter, r *http.Request) {
	var gok GetObjectRequest
	if err := json.NewDecoder(r.Body).Decode(&gok); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	object, err := h.S3Service.GetObject(r.Context(), &s3.GetObjectInput{
		Bucket: aws.String("go-practice-bucket"),
		Key:    aws.String(gok.Key),
	})
	if err != nil {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}

	defer object.Body.Close()

	file, err := os.Create(gok.FileName)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer file.Close()

	body, err := io.ReadAll(object.Body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	_, err = file.Write(body)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	if err := json.NewEncoder(w).Encode(Response{
		Status:  http.StatusOK,
		Message: "File succesfully Downloaded",
	}); err != nil {
		http.Error(w, err.Error(), http.StatusBadGateway)
		return
	}
	return
}
