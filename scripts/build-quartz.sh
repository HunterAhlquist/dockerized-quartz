#!/bin/bash

QUARTZ_DIR="/usr/src/app/quartz"
VAULT_DIR="/vault"

if [ "$VAULT_DO_GIT_PULL_ON_UPDATE" = true ]; then
  echo "Executing git pull in /vault directory"
  cd $VAULT_DIR
  git pull
fi

cd $QUARTZ_DIR

echo "Running Quartz build..."
if [ -n "$NOTIFY_TARGET" ]; then
  apprise -vv --title="Dockerized Quartz" --body="Quartz build has been started." "$NOTIFY_TARGET"
fi

npx quartz build --directory /vault --output /usr/share/nginx/html
BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
  echo "Quartz build completed successfully."

  # Ensure proper permissions for nginx to serve static files
  echo "Setting permissions for static assets..."
  chmod -R 755 /usr/share/nginx/html
  find /usr/share/nginx/html -type f -exec chmod 644 {} \;

  # Specifically ensure assets, content, and static folders are accessible
  for dir in assets content static; do
    if [ -d "/usr/share/nginx/html/$dir" ]; then
      echo "Setting permissions for $dir folder..."
      chmod -R 755 "/usr/share/nginx/html/$dir"
      find "/usr/share/nginx/html/$dir" -type f -exec chmod 644 {} \;
    fi
  done

  if [ -n "$NOTIFY_TARGET" ]; then
    apprise -vv --title="Dockerized Quartz" --body="Quartz build completed successfully." "$NOTIFY_TARGET"
  fi
else
  echo "Quartz build failed."
  if [ -n "$NOTIFY_TARGET" ]; then
    apprise -vv --title="Dockerized Quartz" --body="Quartz build failed!" "$NOTIFY_TARGET"
  fi
  exit 1
fi