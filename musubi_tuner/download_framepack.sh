#!/usr/bin/env bash
set -euo pipefail

# FramePack (FramePackI2V_HY) Model Download Script using the Hugging Face CLI
# DiT comes as 3 sharded safetensors; point --dit at the first shard during training.

echo "Starting FramePack model downloads..."

command -v hf >/dev/null 2>&1 || {
  echo "Error: Hugging Face CLI not found."
  echo "Install it with: pip install -U huggingface_hub"
  exit 1
}

mkdir -p diffusion_models vae text_encoders image_encoder

echo "Downloading FramePackI2V_HY DiT (shard 1/3)..."
hf download \
  lllyasviel/FramePackI2V_HY \
  diffusion_pytorch_model-00001-of-00003.safetensors \
  --local-dir ./diffusion_models

echo "Downloading FramePackI2V_HY DiT (shard 2/3)..."
hf download \
  lllyasviel/FramePackI2V_HY \
  diffusion_pytorch_model-00002-of-00003.safetensors \
  --local-dir ./diffusion_models

echo "Downloading FramePackI2V_HY DiT (shard 3/3)..."
hf download \
  lllyasviel/FramePackI2V_HY \
  diffusion_pytorch_model-00003-of-00003.safetensors \
  --local-dir ./diffusion_models

echo "Downloading FramePackI2V_HY DiT (shard index)..."
hf download \
  lllyasviel/FramePackI2V_HY \
  diffusion_pytorch_model.safetensors.index.json \
  --local-dir ./diffusion_models

echo "Downloading HunyuanVideo VAE..."
vae_path="$(
  hf download \
    Comfy-Org/HunyuanVideo_repackaged \
    split_files/vae/hunyuan_video_vae_bf16.safetensors \
    --quiet
)"
cp --reflink=auto "$vae_path" ./vae/hunyuan_video_vae_bf16.safetensors

echo "Downloading LLaVA-LLaMA3 text encoder..."
encoder1_path="$(
  hf download \
    Comfy-Org/HunyuanVideo_repackaged \
    split_files/text_encoders/llava_llama3_fp16.safetensors \
    --quiet
)"
cp --reflink=auto "$encoder1_path" ./text_encoders/llava_llama3_fp16.safetensors

echo "Downloading CLIP-L text encoder..."
encoder2_path="$(
  hf download \
    Comfy-Org/HunyuanVideo_repackaged \
    split_files/text_encoders/clip_l.safetensors \
    --quiet
)"
cp --reflink=auto "$encoder2_path" ./text_encoders/clip_l.safetensors

echo "Downloading SigLIP image encoder..."
hf download \
  Comfy-Org/sigclip_vision_384 \
  sigclip_vision_patch14_384.safetensors \
  --local-dir ./image_encoder

echo "All downloads completed!"
echo
echo "Files downloaded to:"
echo "  - diffusion_models/diffusion_pytorch_model-0000{1,2,3}-of-00003.safetensors (+ index)"
echo "  - vae/hunyuan_video_vae_bf16.safetensors"
echo "  - text_encoders/llava_llama3_fp16.safetensors"
echo "  - text_encoders/clip_l.safetensors"
echo "  - image_encoder/sigclip_vision_patch14_384.safetensors"
