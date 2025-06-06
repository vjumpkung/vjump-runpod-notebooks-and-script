#!/bin/bash

update_model_path() {
    curl -s https://raw.githubusercontent.com/vjumpkung/vjump-comfyui-runpod-template/refs/heads/main/src/extra_model_paths.yaml >/notebooks/ComfyUI/extra_model_paths.yaml
}

make_directory() {
    mkdir -p /notebooks/my-runpod-volume/models/{ultralytics_segm,ultralytics_bbox}
    mkdir -p /notebooks/ComfyUI/user/default/workflows/
}

update_comfyui() {
    echo "Updating ComfyUI" >>$PROGRAM_LOG
    yes | comfy --workspace /notebooks/ComfyUI update all >>$PROGRAM_LOG
    echo "Update ComfyUI Completed" >>$PROGRAM_LOG
}

download_workflows() {
    echo "downloading ComfyUI Native workflows"
    cd /notebooks/
    cd /notebooks/ComfyUI/user/default/workflows/ && wget -q https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/flux_dev_example.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget -q https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/hidream_dev_example.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget -q https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/hidream_fast_example.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget -q https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/hidream_full_example.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget -q https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/hunyuan_video_image_to_video.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget -q https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/hunyuan_video_text_to_video.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget -q https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/image_to_video_wan_720p_example.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget -q https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/image_to_video_wan_480p_example.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget -q https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/sd15_txt2img_workflow.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget -q https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/sdxl_txt2img_workflow.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget -q https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/text_to_video_wan21_1_3B.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget -q https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/text_to_video_wan21_14B.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget -q https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/vace_i2v.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget -q https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/vace_t2v.json
    cd /notebooks/ComfyUI/user/default/workflows/ && wget -q https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/workflows/vace_v2v.json
    cd /notebooks/
    echo "downloading ComfyUI Native workflows completed"
}

restore_snapshot() {
    echo "Restoring Snapshot from $SNAPSHOT_FILE_URL" >>$PROGRAM_LOG
    if [[ -z $SNAPSHOT_FILE_URL ]]; then
        echo "No snapshot file restore skip..." >>$PROGRAM_LOG
    else
        curl -s $SNAPSHOT_FILE_URL >./src/my_snapshot.json
        yes | comfy --workspace /notebooks/ComfyUI node restore-snapshot ./src/my_snapshot.json --pip-non-url >>$PROGRAM_LOG
        echo "Restore Completed" >>$PROGRAM_LOG
    fi
}

make_directory
update_model_path
download_workflows
restore_snapshot
update_comfyui
