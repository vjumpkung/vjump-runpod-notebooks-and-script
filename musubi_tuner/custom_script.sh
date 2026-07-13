update_musubi_tuner() {
    cd /notebooks/musubi-tuner && git fetch && git pull --ff-only && uv pip install -e . && cd /notebooks
}

update_musubi_tuner

echo "downloading scripts"

wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_qwen_image_fp8.sh -O download_qwen_image_fp8.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_qwen_image_fp16.sh -O download_qwen_image_fp16.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_qwen_image_edit_fp16.sh -O download_qwen_image_edit_fp16.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_qwen_image_edit_2509_fp16.sh -O download_qwen_image_edit_2509_fp16.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/qwen_image_training_script.sh -O qwen_image_training_script.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/musubi_tuner_notebooks.ipynb -O musubi_tuner_notebooks.ipynb
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/wan22_training_script.sh -O wan22_training_script.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_wan22_t2v_14B_fp16.sh -O download_wan22_t2v_14B_fp16.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_wan22_i2v_14B_fp16.sh -O download_wan22_i2v_14B_fp16.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_wan21_i2v_14B_fp16.sh -O download_wan21_i2v_14B_fp16.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_z_image_turbo_bf16.sh -O download_z_image_turbo_bf16.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/z_image_turbo_training_script.sh -O z_image_turbo_training_script.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_z_image_base_bf16.sh -O download_z_image_base_bf16.sh

# FLUX.2 [dev]
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_flux2_dev.sh -O download_flux2_dev.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/flux2_training_script.sh -O flux2_training_script.sh

# FLUX.1 Kontext [dev]
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_flux_kontext_dev.sh -O download_flux_kontext_dev.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/flux_kontext_training_script.sh -O flux_kontext_training_script.sh

# Krea 2
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_krea2.sh -O download_krea2.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/krea2_training_script.sh -O krea2_training_script.sh

# Ideogram 4
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_ideogram4.sh -O download_ideogram4.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/ideogram4_training_script.sh -O ideogram4_training_script.sh

# HiDream-O1-Image
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_hidream_o1.sh -O download_hidream_o1.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/hidream_o1_training_script.sh -O hidream_o1_training_script.sh

# FramePack
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_framepack.sh -O download_framepack.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/framepack_training_script.sh -O framepack_training_script.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/framepack_1f_training_script.sh -O framepack_1f_training_script.sh

# HunyuanVideo
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_hunyuan_video.sh -O download_hunyuan_video.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/hunyuan_video_training_script.sh -O hunyuan_video_training_script.sh

# HunyuanVideo 1.5
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_hunyuan_video_1_5.sh -O download_hunyuan_video_1_5.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/hunyuan_video_1_5_training_script.sh -O hunyuan_video_1_5_training_script.sh

# Kandinsky 5
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/download_kandinsky5_t2v.sh -O download_kandinsky5_t2v.sh
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/kandinsky5_training_script.sh -O kandinsky5_training_script.sh

# Wan 2.1 one-frame (reuses the Wan download scripts)
wget https://raw.githubusercontent.com/vjumpkung/vjump-runpod-notebooks-and-script/refs/heads/main/musubi_tuner/wan_1f_training_script.sh -O wan_1f_training_script.sh
