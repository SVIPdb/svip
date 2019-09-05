#!/usr/bin/env bash

TARGET_HOST="svip-test"

npm run build-external || { echo 'Build failed, aborting' >&2; exit 1; }

ssh -o ClearAllForwardings=yes ${TARGET_HOST} << EOF
  cd /data/svip_staging/coordinator
  export BACKUP_DIR="/data/svip_staging/coordinator/svip-o-vue-backups/$( date +'%F_%T' )"
  mkdir \${BACKUP_DIR} || { echo 'Failed to create backup directory (\${BACKUP_DIR}), exiting...' >&2; exit 1; }
  mv svip-o-vue_built/* \${BACKUP_DIR}
  echo "Created backup in \${BACKUP_DIR}..."
EOF

scp -r ./dist/* ${TARGET_HOST}:/data/svip_staging/coordinator/svip-o-vue_built
