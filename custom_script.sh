#!/bin/bash

ีupdate_model_path() {
    curl -s https://raw.githubusercontent.com/vjumpkung/vjump-comfyui-runpod-template/refs/heads/main/src/extra_model_paths.yaml >/notebooks/ComfyUI/extra_model_paths.yaml
}

make_directory() {
    mkdir -p /notebooks/my-runpod-volume/models/{ultralytics_segm,ultralytics_bbox}
    mkdir -p /notebooks/ComfyUI/user/default/workflows/
}

update_comfyui() {
    echo "Updating ComfyUI"
    yes | comfy --workspace /notebooks/ComfyUI update all
    echo "Update ComfyUI Completed"
}

download_workflows() {
    echo "downloading workflows"
    cd /notebooks/
    cd /notebooks/ComfyUI/user/default/workflows/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/flux_dev_example.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/hidream_dev_example.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/hidream_fast_example.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/hidream_full_example.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/hunyuan_video_image_to_video.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/hunyuan_video_text_to_video.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/image_to_video_wan_720p_example.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/image_to_video_wan_480p_example.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/sd15_txt2img_workflow.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/sdxl_txt2img_workflow.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/text_to_video_wan21_1_3B.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/text_to_video_wan21_14B.json
    cd /notebooks/
    echo "downloading workflows completed"
}

restore_snapshot() {
    echo "Restoring Snapshot from $SNAPSHOT_FILE_URL"
    if [[ -z $SNAPSHOT_FILE_URL ]]; then
        echo "No snapshot file restore skip..."
    else
        curl -s $SNAPSHOT_FILE_URL >./src/my_snapshot.json
        yes | comfy --workspace /notebooks/ComfyUI node restore-snapshot ./src/my_snapshot.json --pip-non-url
        echo "Restore Completed"
    fi
}

update_model_path
make_directory
restore_snapshot
update_comfyui
download_workflows
