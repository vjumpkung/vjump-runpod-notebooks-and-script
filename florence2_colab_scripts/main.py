import torch
from pathlib import Path
from functools import partial
from typing import Iterator, List, Tuple
from PIL import Image
from unittest.mock import patch
from transformers import AutoModelForCausalLM, AutoProcessor
from huggingface_hub import snapshot_download
from transformers.dynamic_module_utils import get_imports
import time
from tqdm import trange, tqdm
import os
from IPython.display import clear_output
import gc

os.chdir("/content/")
device = "cuda" if torch.cuda.is_available() else "cpu"
torch_dtype = torch.float16 if torch.cuda.is_available() else torch.float32


def fixed_get_imports(filename: str | Path) -> List[str]:
    imports = get_imports(filename)
    return (
        [imp for imp in imports if imp != "flash_attn"]
        if str(filename).endswith("modeling_florence2.py")
        else imports
    )


def download_and_load_model(
    model_name: str,
) -> Tuple[AutoModelForCausalLM, AutoProcessor]:
    device = "cuda" if torch.cuda.is_available() else "cpu"
    print(f"Device available: {device}")

    model_path = Path("models") / model_name.replace("/", "_")
    if not model_path.exists():
        print(f"Downloading {model_name} model to: {model_path}")
        snapshot_download(
            repo_id=model_name, local_dir=model_path, local_dir_use_symlinks=False
        )

    print(f"Loading model {model_name}...")
    with patch("transformers.dynamic_module_utils.get_imports", fixed_get_imports):
        model = AutoModelForCausalLM.from_pretrained(
            model_path, trust_remote_code=True, torch_dtype=torch_dtype
        ).to(device)
        processor = AutoProcessor.from_pretrained(model_path, trust_remote_code=True)
    print("Model loaded.")
    model = torch.compile(model, mode="reduce-overhead")
    return model, processor


def offload_model_to_ram(model: AutoModelForCausalLM, processor: AutoProcessor = None):
    """Offload model to RAM but keep it loaded"""
    print("Offloading model to RAM...")

    # Move model to CPU (RAM)
    if hasattr(model, "cpu"):
        model.cpu()

    # Clear GPU cache to free VRAM
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
        torch.cuda.synchronize()

    # Optional: Force garbage collection to clean up any GPU references
    gc.collect()

    print("Model offloaded to RAM. GPU memory freed.")
    return model, processor


def unload_model_completely(
    model: AutoModelForCausalLM, processor: AutoProcessor = None
):
    """Completely unload model and free all memory"""
    print("Completely unloading model...")

    # Move model to CPU first
    if hasattr(model, "cpu"):
        model.cpu()

    # Delete model and processor
    del model
    if processor is not None:
        del processor

    # Clear GPU cache if available
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
        torch.cuda.synchronize()

    # Force garbage collection
    gc.collect()

    print("Model completely unloaded and all memory cleared.")


def run_model_batch(
    model: AutoModelForCausalLM,
    processor: AutoProcessor,
    prompt: str,
    image: Image,
    task: str = "caption",
    num_beams: int = 3,
    max_new_tokens: int = 1024,
) -> List[str]:
    device = "cuda" if torch.cuda.is_available() else "cpu"
    inputs = processor(
        text=prompt, images=image, return_tensors="pt", do_rescale=False
    ).to(device)

    # Ensure inputs match the model's dtype
    input_ids = inputs["input_ids"]
    pixel_values = inputs["pixel_values"].to(dtype=torch_dtype)

    generated_ids = model.generate(
        input_ids=input_ids,
        pixel_values=pixel_values,
        max_new_tokens=max_new_tokens,
        do_sample=False,
        num_beams=num_beams,
    )

    generated_text = processor.batch_decode(generated_ids, skip_special_tokens=False)
    return generated_text[0].replace("</s>", "").replace("<s>", "").replace("<pad>", "")


def main(caption_types, zip_location, TRIGGER_WORD):
    convert_types = {
        "natural_language": "<MORE_DETAILED_CAPTION>",
        "tags": "<GENERATE_TAGS>",
    }

    prompt = convert_types[caption_types]

    model_name = (
        "MiaoshouAI/Florence-2-large-PromptGen-v2.0"
        if caption_types == "tags"
        else "gokaygokay/Florence-2-Flux-Large"
    )

    model, processor = download_and_load_model(model_name)

    clear_output()

    import zipfile

    if zipfile.is_zipfile(zip_location):
        with zipfile.ZipFile(zip_location, "r") as zip_ref:
            zip_ref.extractall()

    location = zip_location.split(".zip")[0]

    os.chdir("/content/")
    # First get all directory and file paths to process
    all_dirs = [d[0] for d in os.walk(location)]
    total_dirs = len(all_dirs)

    try:
        # Use tqdm.notebook for directory iteration
        for dir in tqdm(all_dirs, desc="Processing directories"):
            os.chdir(dir)

            files_to_process = []
            for f in os.listdir("."):
                if os.path.isfile(f) and not f.endswith(".txt"):
                    files_to_process.append(f)

            # Use tqdm.notebook for file iteration within each directory
            for file_name in tqdm(
                files_to_process, desc=f"Processing files in {os.path.basename(dir)}"
            ):
                try:
                    if file_name.endswith(".txt"):
                        continue
                    with Image.open(file_name).convert("RGB") as img:
                        caption = run_model_batch(
                            model,
                            processor,
                            prompt,
                            img,
                            task=convert_types[caption_types],
                        )
                        caption_file_name = os.path.splitext(file_name)[0] + ".txt"
                        with open(caption_file_name, "w") as fp:
                            final_caption = ", ".join([TRIGGER_WORD, caption])
                            fp.write(final_caption)
                except Exception as e:
                    print(f"An error occurred while captioning {file_name}: {e}")

    finally:
        # Offload model to RAM (keeps model loaded but frees GPU memory)
        model, processor = offload_model_to_ram(model, processor)

        # Uncomment the line below if you want to completely unload the model instead:
        # unload_model_completely(model, processor)

    os.chdir("/content/")

    def zipdir(path, ziph):
        # ziph is zipfile handle
        for root, dirs, files in os.walk(path):
            for file in files:
                ziph.write(
                    os.path.join(root, file),
                    os.path.relpath(os.path.join(root, file), os.path.join(path, "..")),
                )

    new_dataset_filename = zip_location.split(".zip")
    new_dataset_filename = new_dataset_filename[0] + "_captioned.zip"
    with zipfile.ZipFile(new_dataset_filename, "w", zipfile.ZIP_DEFLATED) as zipf:
        zipdir(location, zipf)

    print("Caption Completed")


import json
import argparse  # Keep argparse for handling the path to the JSON file


def parse_arguments_from_json(json_file_path):
    """
    Parses arguments from a specified JSON file.
    """
    with open(json_file_path, "r") as f:
        config = json.load(f)
    return config

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Process images with caption types and trigger word using a JSON configuration file."
    )
    parser.add_argument(
        "--config",
        type=str,
        default="config.json",  # Default JSON config file name
        help="Path to the JSON configuration file (default: config.json)",
    )
    args = parser.parse_args()

    # Parse arguments from the specified JSON file
    config_data = parse_arguments_from_json(args.config)

    # Access the arguments
    # We use .get() with a default value to make the script more robust
    # in case a key is missing in the JSON file.
    zip_location = config_data.get("zip_location", "/content/processed_image.zip")
    caption_types = config_data.get("caption_types", "natural_language")
    trigger_word = config_data.get("trigger_word", "tha1mura1pa1nt1ng")

    print(f"Zip location: {zip_location}")
    print(f"Caption types: {caption_types}")
    print(f"Trigger word: {trigger_word}")

    main(caption_types, zip_location, trigger_word)
