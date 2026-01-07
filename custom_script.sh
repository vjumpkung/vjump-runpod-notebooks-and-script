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
    yes | comfy --workspace $WORKSPACE update all >>$PROGRAM_LOG
    echo "Update ComfyUI Completed" >>$PROGRAM_LOG
}

install_custom_nodes() {
    # Step 11: Install custom nodes using git clone
    echo ""
    echo "========================================"
    echo "   Installing Custom Nodes (14 nodes)   "
    echo "========================================"
    echo "This may take several minutes..."
    echo ""
    echo "Custom Nodes to be installed:"
    echo "  [01/14] ComfyUI-Impact-Pack       - Advanced image processing"
    echo "  [02/14] ComfyUI-GGUF              - GGUF model support"
    echo "  [03/14] ComfyUI-KJNodes           - General utility nodes"
    echo "  [04/14] comfyui_controlnet_aux    - ControlNet preprocessors"
    echo "  [05/14] ComfyUI-VideoHelperSuite  - Video processing tools"
    echo "  [06/14] rgthree-comfy             - Workflow enhancements"
    echo "  [07/14] ComfyUI-Crystools         - Crystal tools collection"
    echo "  [08/14] ComfyUI-WanVideoWrapper   - Wan Video integration"
    echo "  [09/14] ComfyUI-Custom-Scripts    - Custom JavaScript scripts"
    echo "  [10/14] was-node-suite-comfyui    - WAS Node Suite"
    echo "  [11/14] ComfyUI-QwenVL            - QwenVL model support"
    echo "  [12/14] ComfyUI-nunchaku          - Nunchaku acceleration"
    echo "  [13/14] RES4LYF                   - Resolution tools"
    echo "  [14/14] ComfyUI-LTXVideo          - LTX Video generation"
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
    }

    # Clone and install each custom node
    install_node "https://github.com/ltdrdata/ComfyUI-Impact-Pack.git" "ComfyUI-Impact-Pack" "01/14"
    install_node "https://github.com/city96/ComfyUI-GGUF.git" "ComfyUI-GGUF" "02/14"
    install_node "https://github.com/kijai/ComfyUI-KJNodes.git" "ComfyUI-KJNodes" "03/14"
    install_node "https://github.com/Fannovel16/comfyui_controlnet_aux.git" "comfyui_controlnet_aux" "04/14"
    install_node "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git" "ComfyUI-VideoHelperSuite" "05/14"
    install_node "https://github.com/rgthree/rgthree-comfy.git" "rgthree-comfy" "06/14"
    install_node "https://github.com/crystian/ComfyUI-Crystools.git" "ComfyUI-Crystools" "07/14"
    install_node "https://github.com/kijai/ComfyUI-WanVideoWrapper.git" "ComfyUI-WanVideoWrapper" "08/14"
    install_node "https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git" "ComfyUI-Custom-Scripts" "09/14"
    install_node "https://github.com/ltdrdata/was-node-suite-comfyui.git" "was-node-suite-comfyui" "10/14"
    install_node "https://github.com/1038lab/ComfyUI-QwenVL.git" "ComfyUI-QwenVL" "11/14"
    install_node "https://github.com/nunchaku-tech/ComfyUI-nunchaku.git" "ComfyUI-nunchaku" "12/14"
    install_node "https://github.com/ClownsharkBatwing/RES4LYF.git" "RES4LYF" "13/14"
    install_node "https://github.com/Lightricks/ComfyUI-LTXVideo.git" "ComfyUI-LTXVideo" "14/14"

    # restore dependencies
    cd /notebooks/ComfyUI/custom_nodes/ComfyUI-Manager
    python cm-cli.py restore-dependencies

    # Return to ComfyUI directory
    cd /notebooks/ComfyUI
    echo ""
}

start_ssh_server() {
    bash -c 'apt update;DEBIAN_FRONTEND=noninteractive apt-get install openssh-server -y;mkdir -p ~/.ssh;cd $_;chmod 700 ~/.ssh;echo "$PUBLIC_KEY" >> authorized_keys;chmod 700 authorized_keys;service ssh start;'
}

start_ssh_server
make_directory
update_model_path
update_comfyui
install_custom_nodes
