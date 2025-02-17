#!/bin/bash

export PLATFORM_ID="RUNPOD"

# Download notebooks
download_notebooks() {
    curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/$BRANCH_ID/start_comfyui_here.ipynb >start_comfyui_here.ipynb
    curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/$BRANCH_ID/resource_manager.ipynb >resource_manager.ipynb
    curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/$BRANCH_ID/ui/main.py >./ui/main.py
    curl https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/$BRANCH_ID/ui/google_drive_download.py >./ui/google_drive_download.py
}

download_model() {
    if [[ -z $PRE_DOWNLOAD_MODEL_URL ]]; then
        echo "No PRE_DOWNLOAD_MODEL_URL provided SKIP!"
    else
        python pre_download_model --input $PRE_DOWNLOAD_MODEL_URL
    fi
}

# Start jupyter lab
start_jupyter() {
    echo "Starting Jupyter Lab..."
    cd /notebooks/ &&
        nohup jupyter lab \
            --allow-root \
            --ip=0.0.0.0 \
            --no-browser \
            --ServerApp.trust_xheaders=True \
            --ServerApp.disable_check_xsrf=False \
            --ServerApp.allow_remote_access=True \
            --ServerApp.allow_origin='*' \
            --ServerApp.allow_credentials=True \
            --FileContentsManager.delete_to_trash=False \
            --FileContentsManager.always_delete_dir=True \
            --FileContentsManager.preferred_dir=/notebooks \
            --ContentsManager.allow_hidden=True \
            --LabServerApp.copy_absolute_path=True \
            --ServerApp.token='' \
            --ServerApp.password='' &>./jupyter.log &
    echo "Jupyter Lab started"
}

# Export env vars
export_env_vars() {
    echo "Exporting environment variables..."
    printenv | grep -E '^RUNPOD_|^PATH=|^_=' | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >>/etc/rp_environment
    echo 'source /etc/rp_environment' >>~/.bashrc
}

make_directory() {
    mkdir -p /notebooks/my-runpod-volume/models/{CatVTON,LLM,animatediff_models,animatediff_motion_lora,ckpts,clip,clip_vision,configs,controlnet,diffusers,diffusion_models,embeddings,facedetection,facerestore_models,gligen,grounding-dino,hypernetworks,insightface,ipadapter,loras,mmdets,nsfw_detector,onnx,photomaker,reactor,rembg,reswapper,sam2,sams,style_models,text_encoders,ultralytics,unet,upscale_models,vae,vae_approx}
}

echo "Pod Started"
start_jupyter
export_env_vars
make_directory
download_notebooks
download_model
echo "Start script(s) finished, pod is ready to use."
sleep infinity
