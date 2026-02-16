#!/bin/bash

export COMFYUI_CUSTOM_NODES_LIST=${COMFYUI_CUSTOM_NODES_LIST:-""}

update_model_path() {
    curl -s https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/extra_model_paths.yaml >/notebooks/ComfyUI/extra_model_paths.yaml
}

make_directory() {
    mkdir -p /notebooks/my-runpod-volume/models/{ultralytics_segm,ultralytics_bbox,detection}
    mkdir -p /notebooks/ComfyUI/user/default/workflows/
}

update_comfyui() {
    WORKSPACE="/notebooks/ComfyUI"
    echo "Updating ComfyUI" >>$PROGRAM_LOG
    cd $WORKSPACE
    git fetch >>$PROGRAM_LOG
    git pull --ff-only >>$PROGRAM_LOG
    uv pip install -r requirements.txt >>$PROGRAM_LOG
    echo "Update ComfyUI Completed" >>$PROGRAM_LOG
}

install_custom_nodes() {
    uv pip install onnxruntime-gpu
    uv pip install PyWavelets

    # Step 11: Install custom nodes using git clone
    echo ""
    echo "========================================"
    echo "   Installing Custom Nodes (14 nodes)   "
    echo "========================================"
    echo "This may take several minutes..."
    echo ""
    echo "Custom Nodes to be installed:"
    echo "  ComfyUI-Impact-Pack     "
    echo "  ComfyUI-GGUF            "
    echo "  ComfyUI-KJNodes         "
    echo "  comfyui_controlnet_aux  "
    echo "  ComfyUI-VideoHelperSuite"
    echo "  rgthree-comfy           "
    echo "  ComfyUI-Crystools       "
    echo "  ComfyUI-WanVideoWrapper "
    echo "  ComfyUI-Custom-Scripts  "
    echo "  was-node-suite-comfyui  "
    echo "  ComfyUI-QwenVL          "
    echo "  ComfyUI-MelBandRoFormer "
    echo "  RES4LYF                 "
    echo "  ComfyUI-LTXVideo        "
    echo "  ComfyUI-InfiniteTalk-Native-Sampler by VJUMPKUNG "
    echo ""

    # Navigate to custom_nodes directory
    cd /notebooks/ComfyUI/custom_nodes || {
        echo "Error: Failed to enter custom_nodes directory"
        return 1
    }

    # Function to install a single node
    install_node() {
        local REPO_URL="$1"
        local REPO_NAME="$2"
        local NODE_NUM="$3"

        echo ""
        echo "========================================"
        echo "[$NODE_NUM] $REPO_NAME"
        echo "========================================"

        # Clone repository if it doesn't exist
        if [ ! -d "$REPO_NAME" ]; then
            echo "> Cloning repository..."
            echo "  URL: $REPO_URL"
            if git clone "$REPO_URL" 2>/dev/null; then
                echo "  [OK] Clone successful"
            else
                echo "  [X] Failed to clone - continuing with next node..."
                return 1
            fi
        else
            echo "> Repository already exists, skipping clone"
        fi


        # Enter the repository directory
        cd "$REPO_NAME" || {
            echo "  [X] Failed to enter directory - continuing with next node..."
            return 1
        }

        # Check for install.py and run it, otherwise use requirements.txt
        if [ -f "install.py" ]; then
            echo "> Running install.py..."
            if python install.py 2>/dev/null; then
                echo "  [OK] Installed via install.py"
            else
                echo "  [!] install.py failed - continuing anyway..."
            fi
        fi

        if [ -f "requirements.txt" ]; then
            echo "> Installing dependencies from requirements.txt..."
            if python -m uv pip install -r requirements.txt 2>/dev/null; then
                echo "  [OK] Dependencies installed successfully"
            else
                echo "  [!] Failed to install requirements - continuing anyway..."
            fi
        else
            if [ ! -f "install.py" ]; then
                echo "> No install.py or requirements.txt found"
            fi
        fi

        echo "  [DONE] $REPO_NAME processing completed"

        # Return to custom_nodes directory
        cd ..
    }

    # Clone and install each custom node
    install_node "https://github.com/ltdrdata/ComfyUI-Impact-Pack.git" "ComfyUI-Impact-Pack" "01/15"
    install_node "https://github.com/city96/ComfyUI-GGUF.git" "ComfyUI-GGUF" "02/15"
    install_node "https://github.com/kijai/ComfyUI-KJNodes.git" "ComfyUI-KJNodes" "03/15"
    install_node "https://github.com/Fannovel16/comfyui_controlnet_aux.git" "comfyui_controlnet_aux" "04/15"
    install_node "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git" "ComfyUI-VideoHelperSuite" "05/15"
    install_node "https://github.com/rgthree/rgthree-comfy.git" "rgthree-comfy" "06/15"
    install_node "https://github.com/crystian/ComfyUI-Crystools.git" "ComfyUI-Crystools" "07/15"
    install_node "https://github.com/kijai/ComfyUI-WanVideoWrapper.git" "ComfyUI-WanVideoWrapper" "08/15"
    install_node "https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git" "ComfyUI-Custom-Scripts" "09/15"
    install_node "https://github.com/ltdrdata/was-node-suite-comfyui.git" "was-node-suite-comfyui" "10/15"
    install_node "https://github.com/1038lab/ComfyUI-QwenVL.git" "ComfyUI-QwenVL" "11/15"
    install_node "https://github.com/kijai/ComfyUI-MelBandRoFormer.git" "ComfyUI-MelBandRoFormer" "12/15"
    install_node "https://github.com/ClownsharkBatwing/RES4LYF.git" "RES4LYF" "13/15"
    install_node "https://github.com/Lightricks/ComfyUI-LTXVideo.git" "ComfyUI-LTXVideo" "14/15"
    install_node "https://github.com/vjumpkung/comfyui-infinitalk-native-sampler.git" "ComfyUI-InfiniteTalk-Native-Sampler" "15/15"

    # Return to ComfyUI directory
    cd /notebooks/ComfyUI
    echo ""
}

start_ssh_server() {
    bash -c 'apt update;DEBIAN_FRONTEND=noninteractive apt-get install openssh-server -y;mkdir -p ~/.ssh;cd $_;chmod 700 ~/.ssh;echo "$PUBLIC_KEY" >> authorized_keys;chmod 700 authorized_keys;service ssh start;'
}

install_runpodctl() {
    # Download and install via wget
    wget -qO- cli.runpod.net | sudo bash
}

start_ssh_server
install_runpodctl
make_directory
update_model_path
update_comfyui
install_custom_nodes
