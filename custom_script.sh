#!/bin/bash

# Set COMFYUI_CUSTOM_NODES_LIST in RunPod to override this default. It accepts
# the same JSON payload as POST /api/install_custom_node. See
# example_custom_nodes.json for a copyable example.
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
        "https://github.com/ltdrdata/was-node-suite-comfyui.git",
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

    local PARSED_NODES
    if ! PARSED_NODES="$(python3 <<'PY'
import json
import os
import re
import sys
from urllib.parse import unquote, urlsplit

try:
    payload = json.loads(os.environ["COMFYUI_CUSTOM_NODES_LIST"])
except (KeyError, json.JSONDecodeError) as error:
    print(f"Invalid COMFYUI_CUSTOM_NODES_LIST JSON: {error}", file=sys.stderr)
    raise SystemExit(1)

urls = payload.get("urls") if isinstance(payload, dict) else payload
if not isinstance(urls, list):
    print("COMFYUI_CUSTOM_NODES_LIST must contain a JSON array or an object with a 'urls' array.", file=sys.stderr)
    raise SystemExit(1)

for index, repository_url in enumerate(urls):
    if not isinstance(repository_url, str):
        print(f"Custom node URL at index {index} must be a string.", file=sys.stderr)
        raise SystemExit(1)

    parsed = urlsplit(repository_url)
    name = unquote(parsed.path.rstrip("/").rsplit("/", 1)[-1])
    if name.lower().endswith(".git"):
        name = name[:-4]

    if (
        parsed.scheme not in {"http", "https"}
        or not parsed.netloc
        or parsed.username is not None
        or parsed.password is not None
        or not re.fullmatch(r"[A-Za-z0-9._-]+", name)
    ):
        print(f"Invalid custom node repository URL at index {index}: {repository_url}", file=sys.stderr)
        raise SystemExit(1)

    print(f"{name}\t{repository_url}")
PY
)"; then
        return 1
    fi

    if [ -z "$PARSED_NODES" ]; then
        echo "No custom nodes configured; skipping custom node installation"
        cd /notebooks/ComfyUI
        return 0
    fi

    local CUSTOM_NODE_ENTRIES=()
    mapfile -t CUSTOM_NODE_ENTRIES <<< "$PARSED_NODES"
    local TOTAL_NODES="${#CUSTOM_NODE_ENTRIES[@]}"
    local NODE_INDEX=1
    local ENTRY
    local REPO_NAME
    local REPO_URL

    for ENTRY in "${CUSTOM_NODE_ENTRIES[@]}"; do
        REPO_NAME="${ENTRY%%$'\t'*}"
        REPO_URL="${ENTRY#*$'\t'}"
        install_node "$REPO_URL" "$REPO_NAME" "$(printf '%02d/%02d' "$NODE_INDEX" "$TOTAL_NODES")"
        NODE_INDEX=$((NODE_INDEX + 1))
    done

    # Return to ComfyUI directory
    cd /notebooks/ComfyUI
    echo ""
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
