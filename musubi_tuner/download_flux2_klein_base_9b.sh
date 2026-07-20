#!/usr/bin/env bash
set -euo pipefail

# FLUX.2 [klein] base 9B download script for Musubi Tuner.
# Before running, accept the terms for the FLUX.2-dev, Klein base 9B, and
# Klein 9B repositories, then authenticate with:
#   hf auth login

echo "Starting FLUX.2 [klein] base 9B model downloads..."

command -v hf >/dev/null 2>&1 || {
  echo "Error: Hugging Face CLI not found."
  echo "Install it with: pip install -U huggingface_hub"
  exit 1
}

hf auth whoami >/dev/null 2>&1 || {
  echo "Error: Hugging Face authentication is required."
  echo "Accept the model terms on Hugging Face, then run: hf auth login"
  exit 1
}

mkdir -p diffusion_models vae text_encoders/qwen3_8b

download_file() {
  local repo="$1"
  local remote_path="$2"
  local destination="$3"
  local cached_path

  cached_path="$(hf download "$repo" "$remote_path" --quiet)"
  cp --reflink=auto "$cached_path" "$destination"
}

echo "Downloading FLUX.2 Klein base 9B DiT..."
download_file \
  black-forest-labs/FLUX.2-klein-base-9B \
  flux-2-klein-base-9b.safetensors \
  ./diffusion_models/flux-2-klein-base-9b.safetensors

echo "Downloading FLUX.2 AE..."
download_file \
  black-forest-labs/FLUX.2-dev \
  ae.safetensors \
  ./vae/ae.safetensors

echo "Downloading Qwen3 8B text encoder shards..."
download_file \
  black-forest-labs/FLUX.2-klein-9B \
  text_encoder/model-00001-of-00004.safetensors \
  ./text_encoders/qwen3_8b/model-00001-of-00004.safetensors
download_file \
  black-forest-labs/FLUX.2-klein-9B \
  text_encoder/model-00002-of-00004.safetensors \
  ./text_encoders/qwen3_8b/model-00002-of-00004.safetensors
download_file \
  black-forest-labs/FLUX.2-klein-9B \
  text_encoder/model-00003-of-00004.safetensors \
  ./text_encoders/qwen3_8b/model-00003-of-00004.safetensors
download_file \
  black-forest-labs/FLUX.2-klein-9B \
  text_encoder/model-00004-of-00004.safetensors \
  ./text_encoders/qwen3_8b/model-00004-of-00004.safetensors

echo "All downloads completed!"
echo
echo "Use these Musubi Tuner settings:"
echo "  --model_version klein-base-9b"
echo "  --dit diffusion_models/flux-2-klein-base-9b.safetensors"
echo "  --vae vae/ae.safetensors"
echo "  --text_encoder text_encoders/qwen3_8b/model-00001-of-00004.safetensors"
