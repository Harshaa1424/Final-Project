#!/usr/bin/env bash
set -euo pipefail

#########################
# Docker Hub Credentials
#########################
DOCKERHUB_USERNAME="harshaa1424"
PROD_REPO="finalproject"
TAG="latest"  # you can change this if needed
IMAGE="${DOCKERHUB_USERNAME}/${PROD_REPO}:${TAG}"

#########################
# Deployment Directory
#########################
REMOTE_DIR="${REMOTE_DIR:-$HOME/app}"

#########################
# Docker Hub Login
#########################
if [ -z "${DOCKERHUB_PASSWORD:-}" ]; then
  echo "Error: Please set your Docker Hub password in the environment variable DOCKERHUB_PASSWORD"
  exit 1
fi

echo "Logging in to Docker Hub..."
echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin

#########################
# Build & Push Image
#########################
echo "Building Docker image ${IMAGE}..."
docker build -t "${IMAGE}" .

echo "Pushing Docker image ${IMAGE}..."
docker push "${IMAGE}"

#########################
# Deploy with Docker Compose
#########################
echo "Deploying ${IMAGE} locally to ${REMOTE_DIR}..."
mkdir -p "${REMOTE_DIR}"

cat > "${REMOTE_DIR}/docker-compose.yml" <<EOF
version: '3.8'
services:
  web:
    image: ${IMAGE}
    ports:
      - '80:80'
    restart: unless-stopped
EOF

cd "${REMOTE_DIR}"
docker pull "${IMAGE}"
docker-compose down || true
docker-compose up -d

echo "Deployment complete. Visit http://localhost/ (or your CloudShell public IP if exposed)"

