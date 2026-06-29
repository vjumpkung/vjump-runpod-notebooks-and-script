#!/bin/bash

# path of musubi-tuner directory
MUSUBI_TUNER_PATH="./musubi-tuner" # no slash suffix like /path/ use /path

# path of dataset configuration see more details at https://github.com/kohya-ss/musubi-tuner/blob/main/src/musubi_tuner/dataset/dataset_config.md
dataset_config="dataset_config.toml"

# setup output path and your lora name
output_name="your_lora_name"
output_dir="./lora_training/outputs"

# epochs
max_train_epochs=16
save_every_n_epochs=1

# load diffusion model
# NOTE: HiDream-O1 is a single checkpoint. The VAE / tokenizer / text encoders are
#       auto-loaded from the official HiDream-ai repo (selected by --model_type),
#       so there are no --vae / --text_encoder arguments.
dit="./diffusion_models/hidream_o1_image_bf16.safetensors" # HiDream-O1 DiT (bf16)

# model variant + task
model_type="full" # full or dev (dev uses noise_scale 7.5 / clip_std 2.5)
task="t2i" # t2i (text-to-image) or i2i (image/control-conditioned)

# full-model noise schedule (for dev: 7.5 / 7.5 / 2.5)
noise_scale_start=8.0
noise_scale_end=8.0
noise_clip_std=0.0

# network settings
network_module="networks.lora_hidream_o1"
network_dim=32
network_alpha=16
# network_args= # for i2i visual conv layers use: network_args="conv_dim=4 conv_alpha=1"

# setting optimizer
optimizer_type="adamw8bit" # adamw, adamw8bit others optimizer should install library manually
# optimizer_args="weight_decay=0.01 eps=1e-7"

# setting leraning rate
learning_rate=4e-5 # recommended default for HiDream-O1 LoRA
lr_scheduler="cosine" # linear, cosine, cosine_with_restarts, polynomial, constant (default), constant_with_warmup, adafactor
lr_warmup_steps=0.05 # 0-1

# advance learning rate settings (uncomment below to use)
# lr_scheduler_power=1 # using with polynomial
# lr_scheduler_min_lr_ratio # using with cosine_with_min_lr
# lr_scheduler_num_cycles=3 # using with cosine_with_restarts

# optimization (reduce VRAM usage)

# must use dont change
mixed_precision="bf16"

# reduce vram usage (max blocks_to_swap=24; i2i + flash_attn + block swap needs dataset batch_size 1)
blocks_to_swap=0
# use_pinned_memory_for_block_swap=true # may increase shared GPU memory on Windows

# advanced settings (If you know what is this then uncomment in each args)
# save_state=true
timestep_sampling="uniform" # matches official SFT recipe
weighting_scheme="none" # matches official SFT recipe
gradient_checkpointing=true
seed=42
persistent_data_loader_workers=true
max_data_loader_n_workers=2 # for faster dataset loading

# attention (select sdpa or flash_attn; flash_attn recommended for 2K resolution)
sdpa=true
# flash_attn=true

cache_pixel_batch_size=1
cache_text_encoder_batch_size=16

# huggingface_hub uploading (uncomment below to use)

# huggingface_repo_id=
# huggingface_repo_type=
# huggingface_path_in_repo=

# huggingface_token= # keep it secret
# huggingface_repo_visibility="private"
# async_upload=true

# for people who knows how to use args
extra_args=""

# Build command line arguments DON'T TOUCH
args=()
# Add string arguments
[[ -n "$dataset_config" ]] && args+=("--dataset_config" "$dataset_config")
[[ -n "$output_name" ]] && args+=("--output_name" "$output_name")
[[ -n "$output_dir" ]] && args+=("--output_dir" "$output_dir")
[[ -n "$dit" ]] && args+=("--dit" "$dit")
[[ -n "$model_type" ]] && args+=("--model_type" "$model_type")
[[ -n "$task" ]] && args+=("--task" "$task")
[[ -n "$network_module" ]] && args+=("--network_module" "$network_module")
[[ -n "$optimizer_type" ]] && args+=("--optimizer_type" "$optimizer_type")
[[ -n "$lr_scheduler" ]] && args+=("--lr_scheduler" "$lr_scheduler")
[[ -n "$mixed_precision" ]] && args+=("--mixed_precision" "$mixed_precision")
[[ -n "$timestep_sampling" ]] && args+=("--timestep_sampling" "$timestep_sampling")
[[ -n "$weighting_scheme" ]] && args+=("--weighting_scheme" "$weighting_scheme")

# Add numeric arguments
[[ -n "$max_train_epochs" ]] && args+=("--max_train_epochs" "$max_train_epochs")
[[ -n "$save_every_n_epochs" ]] && args+=("--save_every_n_epochs" "$save_every_n_epochs")
[[ -n "$network_dim" ]] && args+=("--network_dim" "$network_dim")
[[ -n "$network_alpha" ]] && args+=("--network_alpha" "$network_alpha")
[[ -n "$learning_rate" ]] && args+=("--learning_rate" "$learning_rate")
[[ -n "$lr_warmup_steps" ]] && args+=("--lr_warmup_steps" "$lr_warmup_steps")
[[ -n "$lr_scheduler_power" ]] && args+=("--lr_scheduler_power" "$lr_scheduler_power")
[[ -n "$lr_scheduler_min_lr_ratio" ]] && args+=("--lr_scheduler_min_lr_ratio" "$lr_scheduler_min_lr_ratio")
[[ -n "$lr_scheduler_num_cycles" ]] && args+=("--lr_scheduler_num_cycles" "$lr_scheduler_num_cycles")
[[ -n "$blocks_to_swap" ]] && args+=("--blocks_to_swap" "$blocks_to_swap")
[[ -n "$noise_scale_start" ]] && args+=("--noise_scale_start" "$noise_scale_start")
[[ -n "$noise_scale_end" ]] && args+=("--noise_scale_end" "$noise_scale_end")
[[ -n "$noise_clip_std" ]] && args+=("--noise_clip_std" "$noise_clip_std")
[[ -n "$seed" ]] && args+=("--seed" "$seed")
[[ -n "$max_data_loader_n_workers" ]] && args+=("--max_data_loader_n_workers" "$max_data_loader_n_workers")

# Handle array arguments (network_args and optimizer_args)
if [[ ${#network_args[@]} -gt 0 ]]; then
    result="--network_args"
    for arg in $network_args; do
        result="$result $arg"
    done
    args+=("$result")
fi

if [[ ${#optimizer_args[@]} -gt 0 ]]; then
    result="--optimizer_args"
    for arg in $optimizer_args; do
        result="$result $arg"
    done
    args+=("$result")
fi

# Add boolean flags (only if true)
[[ "$gradient_checkpointing" == true ]] && args+=("--gradient_checkpointing")
[[ "$use_pinned_memory_for_block_swap" == true ]] && args+=("--use_pinned_memory_for_block_swap")
[[ "$persistent_data_loader_workers" == true ]] && args+=("--persistent_data_loader_workers")
[[ "$sdpa" == true ]] && args+=("--sdpa")
[[ "$flash_attn" == true ]] && args+=("--flash_attn")
[[ "$async_upload" == true ]] && args+=("--async_upload")

# Handle empty string variables for HuggingFace (only add if they have values)
[[ -n "$huggingface_repo_id" ]] && args+=("--huggingface_repo_id" "$huggingface_repo_id")
[[ -n "$huggingface_repo_type" ]] && args+=("--huggingface_repo_type" "$huggingface_repo_type")
[[ -n "$huggingface_path_in_repo" ]] && args+=("--huggingface_path_in_repo" "$huggingface_path_in_repo")
[[ -n "$huggingface_token" ]] && args+=("--huggingface_token" "$huggingface_token")
[[ -n "$huggingface_repo_visibility" ]] && args+=("--huggingface_repo_visibility" "$huggingface_repo_visibility")

[[ -n "$extra_args" ]] && args+=("$extra_args")

python ${MUSUBI_TUNER_PATH}/hidream_o1_cache_pixel.py --dataset_config $dataset_config --batch_size $cache_pixel_batch_size
python ${MUSUBI_TUNER_PATH}/hidream_o1_cache_text_encoder_outputs.py --dataset_config $dataset_config --batch_size $cache_text_encoder_batch_size --model_type $model_type
accelerate launch --dynamo_backend no --dynamo_mode default --mixed_precision $mixed_precision --num_processes 1 --num_machines 1 --num_cpu_threads_per_process 2 ${MUSUBI_TUNER_PATH}/hidream_o1_train_network.py ${args[@]}
