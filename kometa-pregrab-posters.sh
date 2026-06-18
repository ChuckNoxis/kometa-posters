#!/bin/bash

set -e

set -o allexport
source /home/noxis/kometa/.env
set +o allexport

DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL}"
REPO_PATH_KOMETA_GIT="${REPO_PATH_KOMETA_GIT}"

# Function to send alerts to Discord
send_discord_alert() {
  local message=$1
  curl -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"${message}\"}" \
    "${DISCORD_WEBHOOK_URL}"
}

# If a command fails, send alert
trap 'send_discord_alert "Pre-Kometa job failed at $(date): $BASH_COMMAND"' ERR

cd "${REPO_PATH_KOMETA_GIT}"
echo "=== [Pre-Kometa Job] Starting at $(date) ==="
# Pull latest from Git
echo "Pulling latest from Git..."
git pull

echo "Running grab-all-posters.py inside Docker..."
docker run --rm \
  --name "grab-plex-posters" \
  --hostname "grab-posters-script" \
  -e "PLEXAPI_HEADER_IDENTIFIER=grab-posters" \
  -v "${REPO_PATH_KOMETA_GIT}/config/assets:/app/assets" \
  grab-plex-posters

# Commit and push if changes occurred in the assets folder only
if [[ $(git status --porcelain config/assets) ]]; then
  echo "Changes in assets detected. Committing and pushing..."
  git add config/assets
  git commit -m "chore(assets): Automatic posters update $(date '+%Y-%m-%d')"
  git push
else
  echo "No changes to commit in assets."
fi

echo "=== [Pre-Kometa Job] Done ==="
