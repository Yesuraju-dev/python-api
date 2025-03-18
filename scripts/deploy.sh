#!/bin/bash

AWS_REGION="us-west-2"
ECR_REPOSITORY="flask-api-repository"
DOCKER_IMAGE_NAME="flask-api"
ECR_URI=$(aws ecr describe-repositories --repository-names $ECR_REPOSITORY --query "repositories[0].repositoryUri" --output text)

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI

docker build -t $DOCKER_IMAGE_NAME .

docker tag $DOCKER_IMAGE_NAME:latest $ECR_URI:latest

docker push $ECR_URI:latest

echo "Docker image pushed to ECR: $ECR_URI:latest"

HEALTH_CHECK_URL="http://your-ecs-service-public-ip:5000"
STATUS_CODE=$(curl --write-out "%{http_code}" --silent --output /dev/null $HEALTH_CHECK_URL)

if [ $STATUS_CODE -eq 200 ]; then
  echo "Health check passed. Flask API is running!"
else
  echo "Health check failed."
  exit 1
fi
