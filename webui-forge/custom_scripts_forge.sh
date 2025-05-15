#!/bin/bash

echo "Updating WebUI Forge GUI"

cd stable-diffusion-webui-forge && git pull --ff-only

export TORCH_FORCE_WEIGHTS_ONLY_LOAD=1
pip install pydantic==2.8.0

cd /notebooks/
curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/webui-forge/launch_webui_forge.ipynb >launch_webui_forge.ipynb
curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/webui-forge/resource_manager.ipynb >resource_manager.ipynb
curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/webui-forge/ui/main.py >./ui/main.py
curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/webui-forge/ui/google_drive_download.py >./ui/google_drive_download.py

echo "Update Completed"
