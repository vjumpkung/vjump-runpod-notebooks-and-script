#!/bin/bash

mkdir -p /notebooks/my-runpod-volume/models/{ultralytics_segm,ultralytics_bbox,CatVTON,LLM,animatediff_models,animatediff_motion_lora,ckpts,clip,clip_vision,configs,controlnet,diffusers,diffusion_models,embeddings,facedetection,facerestore_models,gligen,grounding-dino,hypernetworks,insightface,ipadapter,loras,mmdets,nsfw_detector,onnx,photomaker,reactor,rembg,reswapper,sam2,sams,style_models,text_encoders,ultralytics,unet,upscale_models,vae,vae_approx}

echo "Updating ComfyUI"
comfy --workspace /notebooks/ComfyUI update all
echo "Update ComfyUI Completed"
