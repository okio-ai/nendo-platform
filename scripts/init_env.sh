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

MAIN_REPOSITORIES=(
  "okio-ai/nendo-web"
  "okio-ai/nendo-server"
)
DEV_REPOSITORIES=(
    "okio-ai/nendo"
    "okio-ai/nendo_plugin_library_postgres"
    "okio-ai/nendo_plugin_embed_clap"
    "okio-ai/nendo_plugin_classify_core"
    "okio-ai/nendo_plugin_caption_lpmusiccaps"
    "okio-ai/nendo_plugin_stemify_demucs"
    "okio-ai/nendo_plugin_quantize_core"
    "okio-ai/nendo_plugin_loopify"
    "okio-ai/nendo_plugin_transcribe_whisper"
    "okio-ai/nendo_plugin_textgen"
    "okio-ai/nendo_plugin_voicegen_styletts2"
    "okio-ai/nendo_plugin_import_core"
    "okio-ai/nendo_plugin_musicgen"
  )

# clone all main repos
if check_ssh_access; then
  for repo in "${MAIN_REPOSITORIES[@]}"; do
    CLONE_URL="git@github.com:${repo}.git"
    git clone "${CLONE_URL}" "../repo/$(basename "${repo}")"
  done
else
  for repo in "${MAIN_REPOSITORIES[@]}"; do
    CLONE_URL="https://github.com/${repo}.git"
    git clone "${CLONE_URL}" "../repo/$(basename "${repo}")"
  done
fi

if [[ "$1" == "dev" ]]; then
  mkdir -p ../build/dependencies

  # clone all development repos
  if check_ssh_access; then
    for repo in "${DEV_REPOSITORIES[@]}"; do
      CLONE_URL="git@github.com:${repo}.git"
      git clone "${CLONE_URL}" "../build/dependencies/$(basename "${repo}")"
    done
  else
    for repo in "${DEV_REPOSITORIES[@]}"; do
      CLONE_URL="https://github.com/${repo}.git"
      git clone "${CLONE_URL}" "../build/dependencies/$(basename "${repo}")"
    done
  fi
fi

mkdir -p ../library
