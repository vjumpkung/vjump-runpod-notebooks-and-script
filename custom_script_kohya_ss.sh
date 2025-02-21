#!/bin/bash

echo "Updating kohya-ss GUI"

curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/kohya_ss_notebooks/run_kohya_ss_gui.ipynb >run_kohya_ss_gui.ipynb
curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/kohya_ss_notebooks/ui/main.py >./ui/main.py
curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/kohya_ss_notebooks/ui/google_drive_download.py >./ui/google_drive_download.py

cd kohya_ss && git pull && python ./setup/validate_requirements.py

echo "Update Completed"
