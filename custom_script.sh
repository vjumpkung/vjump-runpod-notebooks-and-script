#!/bin/bash

# Set COMFYUI_CUSTOM_NODES_LIST in RunPod to override this default. It accepts
# the same JSON payload as POST /api/install_custom_node, or an HTTP/HTTPS URL
# to a JSON file containing that payload. See example_custom_nodes.json for
# a copyable example.
DEFAULT_COMFYUI_CUSTOM_NODES_LIST='{
    "urls": [
        "https://github.com/pollockjj/ComfyUI-MultiGPU.git",
        "https://github.com/molbal/ComfyUI-GGUF.git",
        "https://github.com/kijai/ComfyUI-KJNodes.git",
        "https://github.com/Fannovel16/comfyui_controlnet_aux.git",
        "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git",
        "https://github.com/rgthree/rgthree-comfy.git",
        "https://github.com/crystian/ComfyUI-Crystools.git",
        "https://github.com/kijai/ComfyUI-WanVideoWrapper.git",
        "https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git",
        "https://github.com/WASasquatch/was-node-suite-comfyui.git",
        "https://github.com/1038lab/ComfyUI-QwenVL.git",
        "https://github.com/kijai/ComfyUI-MelBandRoFormer.git",
        "https://github.com/ClownsharkBatwing/RES4LYF.git",
        "https://github.com/kijai/ComfyUI-SolAttn_triton.git",
        "https://github.com/vjumpkung/comfyui-infinitetalk-native-sampler.git",
        "https://github.com/vjumpkung/comfyui-vjumpkung-runpod-template-resource-manager.git",
        "https://github.com/kijai/ComfyUI-WanAnimatePreprocess.git",
        "https://github.com/vjumpkung/comfyui-wan-animate-2-loop-sampler.git",
        "https://github.com/vjumpkung/comfyui-scail-2-loop-sampler.git"
    ]
}'
export COMFYUI_CUSTOM_NODES_LIST="${COMFYUI_CUSTOM_NODES_LIST:-$DEFAULT_COMFYUI_CUSTOM_NODES_LIST}"
# Override this when the Resource Manager API is hosted elsewhere.
export RESOURCE_MANAGER_API_URL="${RESOURCE_MANAGER_API_URL:-http://localhost:8000}"

update_model_path() {
    curl -s https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/extra_model_paths.yaml >/notebooks/ComfyUI/extra_model_paths.yaml
}

make_directory() {
    mkdir -p /notebooks/my-runpod-volume/models/{ultralytics_segm,ultralytics_bbox,detection}
    mkdir -p /notebooks/ComfyUI/user/default/workflows/
}

update_comfyui() {
    WORKSPACE="/notebooks/ComfyUI"
    echo "Updating ComfyUI" 
    cd $WORKSPACE
    git fetch
    git pull --ff-only 
    uv pip install -r requirements.txt 
    cd $WORKSPACE/custom_nodes/ComfyUI-Manager && git fetch && git pull && uv pip install -r requirements.txt && cd $WORKSPACE
    echo "Update ComfyUI Completed"
}

install_custom_nodes() {
    local API_ENDPOINT="${RESOURCE_MANAGER_API_URL%/}/api/install_custom_node"
    local CUSTOM_NODES_JSON="$COMFYUI_CUSTOM_NODES_LIST"
    local ATTEMPT
    local RESPONSE

    case "$CUSTOM_NODES_JSON" in
        http://*|https://*)
            echo "Downloading custom node list..."
            if ! CUSTOM_NODES_JSON="$(curl --silent --show-error --fail --location \
                --url "$CUSTOM_NODES_JSON")"; then
                echo "Error: Could not download COMFYUI_CUSTOM_NODES_LIST JSON."
                return 1
            fi
            ;;
    esac

    if ! printf '%s\n' "$CUSTOM_NODES_JSON" | python3 -m json.tool >/dev/null 2>&1; then
        echo "Error: COMFYUI_CUSTOM_NODES_LIST must contain valid JSON or point to a valid JSON file."
        return 1
    fi

    echo ""
    echo "Waiting for Resource Manager API at $RESOURCE_MANAGER_API_URL..."

    for ATTEMPT in {1..30}; do
        if curl --silent --fail --output /dev/null \
            "${RESOURCE_MANAGER_API_URL%/}/api/checkcuda"; then
            break
        fi

        if [ "$ATTEMPT" -eq 30 ]; then
            echo "Error: Resource Manager API did not become ready after 60 seconds."
            return 1
        fi

        sleep 2
    done

    echo "Installing custom nodes through $API_ENDPOINT..."
    if RESPONSE="$(curl --silent --show-error --fail-with-body \
        --request POST \
        --header "Content-Type: application/json" \
        --data "$CUSTOM_NODES_JSON" \
        "$API_ENDPOINT")"; then
        if ! printf '%s\n' "$RESPONSE" | python3 -m json.tool 2>/dev/null; then
            printf '%s\n' "$RESPONSE"
        fi
        echo "Custom node installation request completed."
        return 0
    fi

    echo "Error: Custom node installation request failed."
    if [ -n "$RESPONSE" ]; then
        if ! printf '%s\n' "$RESPONSE" | python3 -m json.tool 2>/dev/null; then
            printf '%s\n' "$RESPONSE"
        fi
    fi
    return 1
}

start_ssh_server() {
    bash -c 'apt update;DEBIAN_FRONTEND=noninteractive apt-get install openssh-server -y;mkdir -p ~/.ssh;cd $_;chmod 700 ~/.ssh;echo "$PUBLIC_KEY" >> authorized_keys;chmod 700 authorized_keys;service ssh start;'
}

install_runpodctl() {
    # Download and install via wget
    wget -qO- cli.runpod.net | bash
}

install_additional() {
    uv pip install flatbuffers numpy packaging protobuf sympy coloredlogs onnx
    CUDA_VER=$(python -c "import torch; print(torch.version.cuda.replace('.', ''))" 2>/dev/null)
    if [ "$CUDA_VER" = "128" ]; then
        uv pip install https://github.com/JamePeng/llama-cpp-python/releases/download/v0.3.34-cu128-Basic-linux-20260331/llama_cpp_python-0.3.34+cu128.basic-cp312-cp312-linux_x86_64.whl
        uv pip install flash_attn_3 --find-links https://windreamer.github.io/flash-attention3-wheels/cu128_torch291
        uv pip install flash-attn==2.8.3
        uv pip install --pre --index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/ORT-Nightly/pypi/simple/ onnxruntime-gpu==1.24.0.dev20260127002
    elif [ "$CUDA_VER" = "124" ]; then
        uv pip install https://github.com/JamePeng/llama-cpp-python/releases/download/v0.3.34-cu124-Basic-linux-20260331/llama_cpp_python-0.3.34+cu124.basic-cp312-cp312-linux_x86_64.whl
        uv pip install flash-attn==2.8.3
        uv pip install --pre --index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/ORT-Nightly/pypi/simple/ onnxruntime-gpu==1.24.0.dev20260127002
    else
        echo "Unsupported or unknown CUDA version: $CUDA_VER"
    fi
    # test additional scripts
    python3 -c "import importlib.util; [print(f'{n}: ' + (getattr(importlib.import_module(m), '__version__', 'installed') if importlib.util.find_spec(m) else 'NOT installed')) for n, m in [('sageattention', 'sageattention'), ('flash-attn v2', 'flash_attn'), ('flash-attn v3', 'flash_attn_3'), ('llama-cpp-python', 'llama_cpp')]]"
}

start_ssh_server &
install_runpodctl &
make_directory
update_model_path
update_comfyui
install_additional
install_custom_nodes
