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

# training task: t2v (text-to-video) or i2v (image-to-video)
# for i2v: set dit to the i2v checkpoint AND keep image_encoder set below
task="t2v"

# load diffusion model, text encoders, vae and image encoder
dit="./diffusion_models/hunyuanvideo1.5_720p_t2v.safetensors" # use hunyuanvideo1.5_720p_i2v.safetensors for i2v
vae="./vae/hunyuanvideo15_vae.safetensors" # HunyuanVideo 1.5 VAE
text_encoder="./text_encoders/qwen_2.5_vl_7b.safetensors" # Qwen2.5-VL
byt5="./text_encoders/byt5_small_glyphxl_fp16.safetensors" # ByT5 (glyph)
image_encoder="./image_encoder/sigclip_vision_patch14_384.safetensors" # SigLIP (only used when task=i2v)

# network settings
network_module="networks.lora_hv_1_5"
network_dim=32
network_alpha=16
# network_args= # using with lora_plus

# setting optimizer
optimizer_type="adamw8bit" # adamw8bit; use Muon on PyTorch 2.9+ for best results
# optimizer_args="weight_decay=0.01 eps=1e-7"

# setting leraning rate
learning_rate=1e-4 # 1e-4 is standard learning rate
lr_scheduler="cosine" # linear, cosine, cosine_with_restarts, polynomial, constant (default), constant_with_warmup, adafactor
lr_warmup_steps=0.05 # 0-1

# advance learning rate settings (uncomment below to use)
# lr_scheduler_power=1 # using with polynomial
# lr_scheduler_min_lr_ratio # using with cosine_with_min_lr
# lr_scheduler_num_cycles=3 # using with cosine_with_restarts

# optimization (reduce VRAM usage)

# must use dont change
mixed_precision="bf16"

# using fp8 precision for DiT (enable BOTH together) for low VRAM
# fp8_base=true
# fp8_scaled=true
# fp8_vl=true # run Qwen2.5-VL text encoder in fp8 during caching

# reduce vram usage (max blocks_to_swap=51)
blocks_to_swap=0

# advanced settings (If you know what is this then uncomment in each args)
# save_state=true
timestep_sampling="shift"
discrete_flow_shift=2.0
gradient_checkpointing=true
weighting_scheme="none"
seed=42
persistent_data_loader_workers=true
max_data_loader_n_workers=2 # for faster dataset loading

# attention (select sdpa, flash_attn or xformers; add split_attn to save a little VRAM)
sdpa=true
# flash_attn=true
# xformers=true
# split_attn=true

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
[[ -n "$task" ]] && args+=("--task" "$task")
[[ -n "$dit" ]] && args+=("--dit" "$dit")
[[ -n "$vae" ]] && args+=("--vae" "$vae")
[[ -n "$text_encoder" ]] && args+=("--text_encoder" "$text_encoder")
[[ -n "$byt5" ]] && args+=("--byt5" "$byt5")
[[ "$task" == "i2v" && -n "$image_encoder" ]] && args+=("--image_encoder" "$image_encoder")
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
[[ -n "$discrete_flow_shift" ]] && args+=("--discrete_flow_shift" "$discrete_flow_shift")
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
[[ "$xformers" == true ]] && args+=("--xformers")
[[ "$split_attn" == true ]] && args+=("--split_attn")
[[ "$async_upload" == true ]] && args+=("--async_upload")

# Handle empty string variables for HuggingFace (only add if they have values)
[[ -n "$huggingface_repo_id" ]] && args+=("--huggingface_repo_id" "$huggingface_repo_id")
[[ -n "$huggingface_repo_type" ]] && args+=("--huggingface_repo_type" "$huggingface_repo_type")
[[ -n "$huggingface_path_in_repo" ]] && args+=("--huggingface_path_in_repo" "$huggingface_path_in_repo")
[[ -n "$huggingface_token" ]] && args+=("--huggingface_token" "$huggingface_token")
[[ -n "$huggingface_repo_visibility" ]] && args+=("--huggingface_repo_visibility" "$huggingface_repo_visibility")

[[ -n "$extra_args" ]] && args+=("$extra_args")

# i2v adds first-frame conditioning to the latent cache; t2v omits it
latents_cache_extra=""
[[ "$task" == "i2v" ]] && latents_cache_extra="--i2v --image_encoder $image_encoder"
te_cache_extra=""
[[ "$fp8_vl" == true ]] && te_cache_extra="--fp8_vl"

python ${MUSUBI_TUNER_PATH}/hv_1_5_cache_latents.py --dataset_config $dataset_config --vae $vae $latents_cache_extra
python ${MUSUBI_TUNER_PATH}/hv_1_5_cache_text_encoder_outputs.py --dataset_config $dataset_config --text_encoder $text_encoder --byt5 $byt5 --batch_size $cache_text_encoder_batch_size $te_cache_extra
accelerate launch --dynamo_backend no --dynamo_mode default --mixed_precision $mixed_precision --num_processes 1 --num_machines 1 --num_cpu_threads_per_process 2 ${MUSUBI_TUNER_PATH}/hv_1_5_train_network.py ${args[@]}
