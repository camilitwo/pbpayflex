#!/bin/sh
set -eu

# Configurable via envs
PB_VERSION="${PB_VERSION:-0.22.15}"
PB_ARCH="${PB_ARCH:-linux_amd64}"
PORT="${PORT:-8090}"

echo "Preparing PocketBase (v${PB_VERSION})..."

# Ensure data dirs exist
mkdir -p /pb_data /pb_public /pb_migrations

# Download pocketbase if binary not present
if [ ! -x "./pocketbase" ]; then
  echo "Downloading pocketbase..."
  curl -L -o pb.zip "https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_${PB_ARCH}.zip"
  unzip -o pb.zip && rm -f pb.zip
  chmod +x pocketbase
fi

echo "Starting PocketBase on 0.0.0.0:${PORT}..."
exec ./pocketbase serve --http 0.0.0.0:${PORT} --dir /pb_data --publicDir /pb_public --migrationsDir /pb_migrations
