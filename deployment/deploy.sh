#!/usr/bin/env bash

case "$1" in
  dev) TARGET_HOST="svip-dev" BUILD_SCRIPT="build" ;;
  test) TARGET_HOST="svip-test" BUILD_SCRIPT="build-external" ;;
  *) echo "Target must be one of 'dev', 'test'"; exit -1 ;;
esac

echo "* Deploying w/target '$1' to ${TARGET_HOST}..."

BASE_DIR="/data/svip_staging/coordinator"

pushd ../svip-o-vue

# git diff-index --quiet HEAD -- || echo "Untracked data exists, bailing" && exit -2

npm run "${BUILD_SCRIPT}" || { echo "Build (mode: ${BUILD_SCRIPT}) failed, aborting" >&2; exit 1; }

ssh -o ClearAllForwardings=yes ${TARGET_HOST} << EOF
  export BACKUP_DIR="${BASE_DIR}/svip-o-vue-backups/$( date +'%F_%T' )"
  mkdir \${BACKUP_DIR} || { echo 'Failed to create backup directory (\${BACKUP_DIR}), exiting...' >&2; exit 1; }
  mv ${BASE_DIR}/svip-o-vue_built/* \${BACKUP_DIR}
  echo "Created backup in \${BACKUP_DIR}..."
EOF

scp -r ./dist/* ${TARGET_HOST}:${BASE_DIR}/svip-o-vue_built

popd
