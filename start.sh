#!/bin/sh
set -eu

# Configurable via envs
PB_VERSION="${PB_VERSION:-0.22.15}"
PB_ARCH="${PB_ARCH:-linux_amd64}"
PORT="${PORT:-8090}"

# When running on Railway we may have a persistent volume mounted at
# $RAILWAY_VOLUME_MOUNT_PATH. Allow overriding the PocketBase data
# directories so data survives across deploys.
VOLUME_ROOT="${RAILWAY_VOLUME_MOUNT_PATH:-.}"
# Normalise by stripping the trailing slash (except when it is just "/").
case "${VOLUME_ROOT}" in
  "/")
    NORMALISED_VOLUME_ROOT=""
    ;;
  *)
    NORMALISED_VOLUME_ROOT="${VOLUME_ROOT%/}"
    ;;
esac

PB_DATA_DIR="${PB_DATA_DIR:-${NORMALISED_VOLUME_ROOT}/pb_data}"
PB_PUBLIC_DIR="${PB_PUBLIC_DIR:-${NORMALISED_VOLUME_ROOT}/pb_public}"
PB_MIGRATIONS_DIR="${PB_MIGRATIONS_DIR:-${NORMALISED_VOLUME_ROOT}/pb_migrations}"

echo "Preparing PocketBase (v${PB_VERSION})..."

# Ensure data dirs exist
mkdir -p "${PB_DATA_DIR}" "${PB_PUBLIC_DIR}" "${PB_MIGRATIONS_DIR}"

# Download pocketbase if binary not present
if [ ! -x "./pocketbase" ]; then
  echo "Downloading pocketbase..."
  curl -L -o pb.zip "https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_${PB_ARCH}.zip"
  unzip -o pb.zip && rm -f pb.zip
  chmod +x pocketbase
fi

echo "Using data directory: ${PB_DATA_DIR}"
echo "Using public directory: ${PB_PUBLIC_DIR}"
echo "Using migrations directory: ${PB_MIGRATIONS_DIR}"

echo "Starting PocketBase on 0.0.0.0:${PORT}..."
exec ./pocketbase serve \
  --http 0.0.0.0:${PORT} \
  --dir "${PB_DATA_DIR}" \
  --publicDir "${PB_PUBLIC_DIR}" \
  --migrationsDir "${PB_MIGRATIONS_DIR}"
