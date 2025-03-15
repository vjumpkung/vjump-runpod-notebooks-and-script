#!/bin/bash

echo "Updating WebUI Forge GUI"

cd stable-diffusion-webui-forge && git pull --ff-only

curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/webui-forge/run_kohya_ss_gui.ipynb >run_kohya_ss_gui.ipynb
curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/webui-forge/ui/main.py >./ui/main.py
curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/webui-forge/ui/google_drive_download.py >./ui/google_drive_download.py

echo "Update Completed"
