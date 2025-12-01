#!/bin/bash

update_model_path() {
    curl -s https://raw.githubusercontent.com/vjumpkung/vjump-comfyui-runpod-template/refs/heads/main/src/extra_model_paths.yaml >/notebooks/ComfyUI/extra_model_paths.yaml
}

make_directory() {
    mkdir -p /notebooks/my-runpod-volume/models/{ultralytics_segm,ultralytics_bbox,detection}
    mkdir -p /notebooks/ComfyUI/user/default/workflows/
}

update_comfyui() {
    WORKSPACE="/notebooks/ComfyUI"
    echo "Updating ComfyUI" >>$PROGRAM_LOG
    yes | comfy --workspace $WORKSPACE update all --mode remote >>$PROGRAM_LOG
    echo "Update ComfyUI Completed" >>$PROGRAM_LOG
}

install_custom_nodes() {
    WORKSPACE="/notebooks/ComfyUI"
    nodes=("comfyui-impact-pack" "comfyui_ultimatesdupscale" "ComfyUI-GGUF" "comfyui-kjnodes" 
        "comfyui_controlnet_aux" "comfyui_ipadapter_plus" "comfyui-videohelpersuite" 
        "comfyui-inpaint-nodes" "rgthree-comfy" "comfyui-florence2" "ComfyUI-Crystools" "ComfyUI-Distributed")
    for node in "${nodes[@]}"; do
        echo installing $node >> $PROGRAM_LOG
        yes | comfy --workspace $WORKSPACE node install $node --mode remote >> $PROGRAM_LOG
    done
}

start_ssh_server() {
    bash -c 'apt update;DEBIAN_FRONTEND=noninteractive apt-get install openssh-server -y;mkdir -p ~/.ssh;cd $_;chmod 700 ~/.ssh;echo "$PUBLIC_KEY" >> authorized_keys;chmod 700 authorized_keys;service ssh start;'
}

start_ssh_server
make_directory
update_model_path
install_custom_nodes
update_comfyui