#!/bin/bash
echo "Start Custom Script"

download_notebooks() {
    cd /invokeai/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/invokeai/model_manager.ipynb -O model_manager.ipynb
    cd /invokeai/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/invokeai/main.py -O main.py
    cd /invokeai/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/invokeai/model_list.json -O model_list.json
    cd /invokeai/ && wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/invokeai/google_drive_download.py -O google_drive_download.py
}

download_notebooks

echo "Custom Script Finished"
