#!/usr/bin/env bash
set -euo pipefail

# Replace with your values
EC2_USER="${EC2_USER:-ec2-user}"            # or ubuntu
EC2_HOST="${EC2_HOST:-<EC2_PUBLIC_IP>}"
SSH_KEY="${SSH_KEY:-~/.ssh/mykey.pem}"
REMOTE_DIR="${REMOTE_DIR:-/home/${EC2_USER}/app}"
IMAGE="${DOCKERHUB_USERNAME}/${PROD_REPO}:${TAG:-latest}"

echo "Deploying ${IMAGE} to ${EC2_HOST}"

# Ensure image exists in docker hub (build & push earlier)
ssh -o StrictHostKeyChecking=no -i "${SSH_KEY}" "${EC2_USER}@${EC2_HOST}" "mkdir -p ${REMOTE_DIR}"

# Create a docker-compose.yml remotely (simple)
ssh -i "${SSH_KEY}" "${EC2_USER}@${EC2_HOST}" "cat > ${REMOTE_DIR}/docker-compose.yml <<'EOF'
version: '3.8'
services:
  web:
    image: ${IMAGE}
    ports:
      - '80:80'
    restart: unless-stopped
EOF"

# Pull and restart
ssh -i "${SSH_KEY}" "${EC2_USER}@${EC2_HOST}" <<EOF
cd ${REMOTE_DIR}
docker pull ${IMAGE}
docker-compose down || true
docker-compose up -d
EOF

echo "Deployment complete. Visit http://${EC2_HOST}/"
