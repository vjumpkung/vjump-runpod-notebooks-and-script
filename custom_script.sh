#!/bin/bash

make_directory() {
    mkdir -p /notebooks/my-runpod-volume/models/{ultralytics_segm,ultralytics_bbox}
}

update_comfyui() {
    echo "Updating ComfyUI"
    comfy --workspace /notebooks/ComfyUI update all
    echo "Update ComfyUI Completed"
}

download_facerestore_model() {
    # Set the target directory
    TARGET_DIR="./ComfyUI/models/facerestore_models/"

    # Create the directory if it doesn't exist
    mkdir -p "$TARGET_DIR"

    # List of model URLs
    urls=(
        "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/facerestore_models/GFPGANv1.3.pth"
        "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/facerestore_models/GFPGANv1.4.pth"
        "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/facerestore_models/codeformer-v0.1.0.pth"
        "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/facerestore_models/GPEN-BFR-512.onnx"
    )

    # Download each file using wget
    for url in "${urls[@]}"; do
        wget -c "$url" -P "$TARGET_DIR"
    done
}

curl https://raw.githubusercontent.com/vjumpkung/vjump-comfyui-runpod-template/refs/heads/main/src/extra_model_paths.yaml >/notebooks/ComfyUI/extra_model_paths.yaml

make_directory
update_comfyui
download_facerestore_model
