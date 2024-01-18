// main.go
package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	// "github.com/aws/aws-lambda-go/lambda"
)

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	fmt.Println(request.Body)

	response := events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       "Hello from Lambda!",
	}

	return response, nil
}

func main() {
	// lambda.Start(handler)
	handler(context.Background(), events.APIGatewayProxyRequest{})
}