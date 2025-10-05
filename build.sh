#!/usr/bin/env bash
set -euo pipefail

IMAGE="${DOCKERHUB_USERNAME}/${DOCKERHUB_REPO:-dev}"
TAG="${TAG:-latest}"

echo "Building image ${IMAGE}:${TAG}"
docker build -t "${IMAGE}:${TAG}" .

if [ -n "${DOCKERHUB_USERNAME:-}" ] && [ -n "${DOCKERHUB_PASSWORD:-}" ]; then
  echo "Logging in to Docker Hub"
  echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin
fi

echo "Pushing ${IMAGE}:${TAG}"
docker push "${IMAGE}:${TAG}"

echo "Done."

