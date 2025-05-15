#!/bin/bash

curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/kohya_ss_notebooks/run_kohya_ss_gui.ipynb >run_kohya_ss_gui.ipynb
curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/kohya_ss_notebooks/ui/main.py >./ui/main.py
curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/kohya_ss_notebooks/ui/google_drive_download.py >./ui/google_drive_download.py

echo "Updating kohya-ss GUI"

pip install pydantic==2.8.0

cd kohya_ss && git pull --ff-only && python ./setup/validate_requirements.py --requirements requirements_runpod.txt

echo "Update Completed"
