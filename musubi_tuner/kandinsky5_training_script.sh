#!/bin/bash

# path of musubi-tuner directory
MUSUBI_TUNER_PATH="./musubi-tuner" # no slash suffix like /path/ use /path

# path of dataset configuration see more details at https://github.com/kohya-ss/musubi-tuner/blob/main/src/musubi_tuner/dataset/dataset_config.md
dataset_config="dataset_config.toml"

# setup output path and your lora name
output_name="your_lora_name"
output_dir="./lora_training/outputs"

# epochs
max_train_epochs=50
save_every_n_epochs=1

# task config preset (e.g. k5-pro-t2v-5s-sd ; for i2v use k5-pro-i2v-5s-sd + the i2v DiT)
task="k5-pro-t2v-5s-sd"

# load diffusion model, text encoders and vae
dit="./diffusion_models/kandinsky5pro_t2v_sft_5s.safetensors" # Kandinsky 5 Pro T2V SFT 5s
vae="./vae/hunyuan_video_vae.safetensors" # HunyuanVideo 3D VAE
# text encoders are HF model IDs (auto-downloaded) or local snapshot directories
text_encoder_qwen="Qwen/Qwen2.5-VL-7B-Instruct"
text_encoder_clip="openai/clip-vit-large-patch14"

# network settings
network_module="networks.lora_kandinsky"
network_dim=32
network_alpha=32
# network_args= # using with lora_plus

# setting optimizer
optimizer_type="adamw8bit" # adamw, adamw8bit others optimizer should install library manually
optimizer_args="weight_decay=0.001 betas=(0.9,0.95)"

# setting leraning rate
learning_rate=1e-4 # 1e-4 is standard learning rate
lr_scheduler="constant_with_warmup" # linear, cosine, cosine_with_restarts, polynomial, constant (default), constant_with_warmup, adafactor
lr_warmup_steps=100 # number of warmup steps

# advance learning rate settings (uncomment below to use)
# lr_scheduler_power=1 # using with polynomial
# lr_scheduler_min_lr_ratio # using with cosine_with_min_lr
# lr_scheduler_num_cycles=3 # using with cosine_with_restarts

# optimization (reduce VRAM usage)

# must use dont change
mixed_precision="bf16"

# fp8 for DiT (reduces memory, may impact quality)
fp8_base=true
# fp8_scaled=true

# reduce vram usage
blocks_to_swap=0

# gradient clipping
max_grad_norm=1.0

# Kandinsky5 scheduler scale (from task config; example uses 10.0)
scheduler_scale=10.0

# advanced settings (If you know what is this then uncomment in each args)
# save_state=true
timestep_sampling="shift"
discrete_flow_shift=5.0
gradient_checkpointing=true
seed=42
persistent_data_loader_workers=true
max_data_loader_n_workers=1 # for faster dataset loading

# attention (select sdpa, flash_attn, sage_attn or xformers)
sdpa=true
# flash_attn=true
# sage_attn=true
# xformers=true

cache_text_encoder_batch_size=4

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
[[ -n "$task" ]] && args+=("--task" "$task")
[[ -n "$dit" ]] && args+=("--dit" "$dit")
[[ -n "$vae" ]] && args+=("--vae" "$vae")
[[ -n "$text_encoder_qwen" ]] && args+=("--text_encoder_qwen" "$text_encoder_qwen")
[[ -n "$text_encoder_clip" ]] && args+=("--text_encoder_clip" "$text_encoder_clip")
[[ -n "$network_module" ]] && args+=("--network_module" "$network_module")
[[ -n "$optimizer_type" ]] && args+=("--optimizer_type" "$optimizer_type")
[[ -n "$lr_scheduler" ]] && args+=("--lr_scheduler" "$lr_scheduler")
[[ -n "$mixed_precision" ]] && args+=("--mixed_precision" "$mixed_precision")
[[ -n "$timestep_sampling" ]] && args+=("--timestep_sampling" "$timestep_sampling")

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
[[ -n "$discrete_flow_shift" ]] && args+=("--discrete_flow_shift" "$discrete_flow_shift")
[[ -n "$max_grad_norm" ]] && args+=("--max_grad_norm" "$max_grad_norm")
[[ -n "$scheduler_scale" ]] && args+=("--scheduler_scale" "$scheduler_scale")
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
[[ "$fp8_base" == true ]] && args+=("--fp8_base")
[[ "$fp8_scaled" == true ]] && args+=("--fp8_scaled")
[[ "$gradient_checkpointing" == true ]] && args+=("--gradient_checkpointing")
[[ "$persistent_data_loader_workers" == true ]] && args+=("--persistent_data_loader_workers")
[[ "$sdpa" == true ]] && args+=("--sdpa")
[[ "$flash_attn" == true ]] && args+=("--flash_attn")
[[ "$sage_attn" == true ]] && args+=("--sage_attn")
[[ "$xformers" == true ]] && args+=("--xformers")
[[ "$async_upload" == true ]] && args+=("--async_upload")

# Handle empty string variables for HuggingFace (only add if they have values)
[[ -n "$huggingface_repo_id" ]] && args+=("--huggingface_repo_id" "$huggingface_repo_id")
[[ -n "$huggingface_repo_type" ]] && args+=("--huggingface_repo_type" "$huggingface_repo_type")
[[ -n "$huggingface_path_in_repo" ]] && args+=("--huggingface_path_in_repo" "$huggingface_path_in_repo")
[[ -n "$huggingface_token" ]] && args+=("--huggingface_token" "$huggingface_token")
[[ -n "$huggingface_repo_visibility" ]] && args+=("--huggingface_repo_visibility" "$huggingface_repo_visibility")

[[ -n "$extra_args" ]] && args+=("$extra_args")

python ${MUSUBI_TUNER_PATH}/kandinsky5_cache_latents.py --dataset_config $dataset_config --vae $vae
python ${MUSUBI_TUNER_PATH}/kandinsky5_cache_text_encoder_outputs.py --dataset_config $dataset_config --text_encoder_qwen $text_encoder_qwen --text_encoder_clip $text_encoder_clip --batch_size $cache_text_encoder_batch_size
accelerate launch --dynamo_backend no --dynamo_mode default --mixed_precision $mixed_precision --num_processes 1 --num_machines 1 --num_cpu_threads_per_process 2 ${MUSUBI_TUNER_PATH}/kandinsky5_train_network.py ${args[@]}
