package main

import (
	"context"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go/service/s3"
	"log"
)

const (
	AWS_S3_REGION = ""
	AWS_S3_BUCKET = ""
)

var awsS3Client *s3.Client

func main() {
	configS3()
}

func configS3() {

	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion(AWS_S3_REGION))
	if err != nil {
		log.Fatal(err)
	}

	awsS3Client = s3.NewFromConfig(cfg)
}
