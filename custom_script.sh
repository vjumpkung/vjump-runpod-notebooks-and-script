#!/bin/bash

make_directory() {
    mkdir -p /notebooks/my-runpod-volume/models/{ultralytics_segm,ultralytics_bbox}
}

update_comfyui() {
    echo "Updating ComfyUI"
    comfy --workspace /notebooks/ComfyUI update all
    echo "Update ComfyUI Completed"
}

restore_snapshot() {
    echo "Restoring Snapshot from $SNAPSHOT_FILE_URL"
    if [[ -z $SNAPSHOT_FILE_URL ]]; then
        echo "No snapshot file restore skip..."
    else
        curl $SNAPSHOT_FILE_URL >./src/my_snapshot.json
        comfy --workspace /notebooks/ComfyUI node restore-snapshot ./src/my_snapshot.json --pip-non-url
        echo "Restore Completed"
    fi
}

curl https://raw.githubusercontent.com/vjumpkung/vjump-comfyui-runpod-template/refs/heads/main/src/extra_model_paths.yaml >/notebooks/ComfyUI/extra_model_paths.yaml

make_directory
restore_snapshot
update_comfyui
