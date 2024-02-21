#!/bin/bash
#
# Initialize local development environment for nendo
#
# Athor: Felix Lorenz
# License: WAT

check_ssh_access() {
    # Attempt to connect to GitHub via SSH and check for successful authentication
    ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"
    return $?
}

REPOSITORIES=(
  "okio-ai/nendo-web"
  "okio-ai/nendo-server"
)

# clone all main repos
if check_ssh_access; then
  for repo in "${REPOSITORIES[@]}"; do
    CLONE_URL="git@github.com:${repo}.git"
    git clone "${CLONE_URL}" "../repo/$(basename "${repo}")"
  done
else
  for repo in "${REPOSITORIES[@]}"; do
    CLONE_URL="https://github.com/${repo}.git"
    git clone "${CLONE_URL}" "../repo/$(basename "${repo}")"
  done
fi

mkdir -p ../library
