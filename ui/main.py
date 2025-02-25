import ipywidgets as widgets
from IPython.display import display
import subprocess
import os
import shlex
import requests
import torch
import hashlib
import json


platform_id = "OTHER"

if "RUNPOD_POD_ID" in os.environ.keys():
    platform_id = "RUNPOD"
elif "PAPERSPACE_FQDN" in os.environ.keys():
    platform_id = "PAPERSPACE"

model_list_url = "https://pastebin.com/raw/xQpdW2ka"


class Envs:
    def __init__(self):
        self.CIVITAI_TOKEN = ""
        self.HUGGINGFACE_TOKEN = ""

    def get_enviroment_variable(self):
        if "CIVITAI_TOKEN" in os.environ.keys() and self.CIVITAI_TOKEN == "":
            self.CIVITAI_TOKEN = os.environ["CIVITAI_TOKEN"]
        if "HUGGINGFACE_TOKEN" in os.environ.keys() and self.HUGGINGFACE_TOKEN == "":
            self.HUGGINGFACE_TOKEN = os.environ["HUGGINGFACE_TOKEN"]


envs = Envs()
envs.get_enviroment_variable()


def test():
    status_header = widgets.HTML('<h2 style="width: 250px;">Import สำเร็จ!</h2>')
    headers = widgets.HBox([status_header])
    display(headers)


def setup():

    if not torch.cuda.is_available():
        warn = widgets.HTML('<h3 style="width: 500px;">ไม่พบ CUDA โปรดสร้าง Pod ใหม่</h3>')
        headers = widgets.HBox([warn])
        display(headers)
    else:
        warn = widgets.HTML('<h3 style="width: 500px;">พบ CUDA :)</h3>')
        headers = widgets.HBox([warn])
        display(headers)

    if len(envs.CIVITAI_TOKEN) > 0:
        civitapikey = "Imported From Environment Variable"
    else:
        civitapikey = ""
    if len(envs.HUGGINGFACE_TOKEN) > 0:
        huggingfacekey = "Imported From Environment Variable"
    else:
        huggingfacekey = ""

    settings = []
    input_list = [
        (
            "CIVITAI_TOKEN",
            "CivitAI API Key",
            "Paste your API key here",
            civitapikey,
        ),
        (
            "HUGGINGFACE_TOKEN",
            "Huggingface API Key",
            "Paste your API key here",
            huggingfacekey,
        ),
    ]

    save_button = widgets.Button(description="Save", button_style="primary")
    output = widgets.Output()

    for key, input_label, placeholder, input_value in input_list:
        label = widgets.Label(input_label, layout=widgets.Layout(width="100px"))
        textfield = widgets.Text(
            placeholder=placeholder,
            value=input_value,
            layout=widgets.Layout(width="400px"),
        )
        settings.append((key, textfield))
        row = [label, textfield]
        print("")
        display(widgets.HBox(row))

    def on_save(button):
        output.clear_output()
        with output:
            for key, textInput in settings:
                if key == "CIVITAI_TOKEN":
                    if (
                        textInput.value != "Imported From Environment Variable"
                        or textInput.value != ""
                    ):
                        envs.CIVITAI_TOKEN = textInput.value
                elif key == "HUGGINGFACE_TOKEN":
                    if (
                        textInput.value != "Imported From Environment Variable"
                        or textInput.value != ""
                    ):
                        envs.HUGGINGFACE_TOKEN = textInput.value
            print("\nSaved ✔")

    save_button.on_click(on_save)
    display(save_button, output)


def completed_message():
    completed = widgets.Button(
        description="Completed", button_style="success", icon="check"
    )
    print("\n")
    display(completed)


check_types = [
    "CatVTON",
    "LLM",
    "animatediff_models",
    "animatediff_motion_lora",
    "checkpoints",
    "clip",
    "clip_vision",
    "configs",
    "controlnet",
    "diffusers",
    "diffusion_models",
    "embeddings",
    "facedetection",
    "facerestore_models",
    "gligen",
    "grounding-dino",
    "hypernetworks",
    "insightface",
    "ipadapter",
    "loras",
    "mmdets",
    "nsfw_detector",
    "onnx",
    "photomaker",
    "reactor",
    "rembg",
    "reswapper",
    "sam2",
    "sams",
    "style_models",
    "text_encoders",
    "ultralytics",
    "unet",
    "upscale_models",
    "vae",
    "vae_approx",
]


def download(name: str, url: str, type: str):
    import sys

    if "envs" not in globals():
        global envs
        envs = Envs()
        envs.get_enviroment_variable()

    if type not in check_types:
        print("Invalid Model Type")
        return sys.exit(1)

    destination = ""
    filename = ""

    if type == "checkpoints":
        type = "ckpts"

    destination = f"./my-runpod-volume/models/{type}/"

    print(f"Starting download: {name}\n")

    if "civitai" in url and envs.CIVITAI_TOKEN != "":
        if "?" in url:
            url += f"&token={envs.CIVITAI_TOKEN}"
        else:
            url += f"?token={envs.CIVITAI_TOKEN}"

    command = f"aria2c --console-log-level=error -c -x 16 -s 16 -k 1M {url} --dir={destination} --download-result=hide"

    if "huggingface" in url and envs.HUGGINGFACE_TOKEN != "":
        command += f' --header="Authorization: Bearer {envs.HUGGINGFACE_TOKEN}"'

    if "huggingface" in url:
        filename = url.split("/")[-1]
        command += f" -o {filename}"

    if "civitai" in url:
        command += " --content-disposition=true"

    if "drive.google.com" in url:
        command = (
            f"python ./ui/google_drive_download.py --path {destination} --url {url}"
        )

    process_success = True
    with subprocess.Popen(
        shlex.split(command),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    ) as sp:
        print("\033[?25l", end="")
        for line in sp.stdout:
            if line.startswith("[#"):
                text = "Download progress {}".format(line.strip("\n"))
                print("\r" + " " * 100 + "\r" + text, end="", flush=True)
                prev_line = text
            elif line.startswith("[COMPLETED]"):
                if prev_line != "":
                    print("", flush=True)
            else:
                print(line.strip(), flush=True)
        print("\033[?25h")

        # Check the return code of the process
        return_code = sp.wait()
        if return_code != 0:
            process_success = False

    if process_success:
        print(f"Download completed: {name}")
        return 0
    else:
        print(f"Download failed: {name}")
        return sys.exit(1)


def select_download_model_list():
    models_header = widgets.HTML('<h3 style="width: 200px;">Model List</h3>')
    headers = widgets.HBox([models_header])
    display(headers)

    get_model_list = requests.get(model_list_url).json()

    checkboxes = []

    for item in get_model_list:
        checkbox = widgets.Checkbox(
            value=False,
            description=item["name"],
            indent=False,
            layout={"width": "auto"},
        )
        val = item["url"]
        checkboxes.append((checkbox, val))
        display(checkbox)

    download_button = widgets.Button(description="Download", button_style="primary")

    output = widgets.Output()

    def on_press(button):
        with output:
            output.clear_output()
            try:
                for _checkbox, _url in checkboxes:
                    if _checkbox.value:
                        command = f"python pre_download_model.py --input {_url}"
                        with subprocess.Popen(
                            shlex.split(command),
                            stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT,
                            text=True,
                            bufsize=1,
                        ) as sp:
                            for line in sp.stdout:
                                print(line.strip())
                completed_message()

            except KeyboardInterrupt:
                print("\n\n--Download Model interrupted--")

    download_button.on_click(on_press)

    display(download_button, output)


def download_models():
    models_header = widgets.HTML(
        '<h3 style="width: auto;">Download Model จาก Google Drive, CivitAI หรือ Huggingface</h3>'
    )
    display(models_header)

    description = widgets.Label(
        "Please Select type (โปรดเลือกประเภทของ Model ก่อน Download)"
    )
    model_type = widgets.Dropdown(
        options=check_types,
        value="checkpoints",
        disabled=False,
    )
    title = widgets.Label(
        "Model Type (ประเภทของโมเดล) :", layout=widgets.Layout(width="auto")
    )
    display(description)
    dropdown = widgets.HBox([title, model_type])
    display(dropdown)

    textinputlayout = widgets.Layout(width="400px", height="40px")
    url_model = widgets.Text(
        value="",
        placeholder="Paste Huggingface or CivitAI model here",
        disabled=False,
        layout=textinputlayout,
    )
    textWidget = widgets.HBox([widgets.Label("Model url:"), url_model])

    display(textWidget)

    download_button = widgets.Button(description="Download", button_style="primary")
    output = widgets.Output()

    def on_press(button):
        with output:
            output.clear_output()
            try:
                if url_model.value != "":
                    download(
                        model_type.value,
                        url_model.value,
                        model_type.value,
                    )
                output.clear_output()
                completed_message()

            except KeyboardInterrupt:
                print("\n\n--Download Model interrupted--")

    download_button.on_click(on_press)

    display(download_button, output)


def run_snapshot(url):
    # --- Step 1: Fetch JSON data using requests ---
    # Replace with the actual URL you want to fetch from.
    response = requests.get(url)
    response.raise_for_status()  # will raise an error for bad responses
    json_data = response.json()

    # --- Step 2: Generate a random SHA256 hash ---
    # Create 32 random bytes and compute its SHA256 hash.
    random_bytes = os.urandom(32)
    hash_digest = hashlib.sha256(random_bytes).hexdigest()

    # Build the filename using the random hash.
    filename = f"./src/snapshot-{hash_digest}.json"

    # Ensure the directory exists.
    os.makedirs(os.path.dirname(filename), exist_ok=True)

    # Write the JSON data to the file.
    with open(filename, "w") as file:
        json.dump(json_data, file, indent=2)

    print(f"JSON data written to {filename}")

    # --- Step 3: Run the subprocess command ---
    # Command: comfy --workspace /notebooks/ComfyUI node restore-snapshot <filename> --pip-non-url

    command = f"comfy --workspace /notebooks/ComfyUI node restore-snapshot {filename} --pip-non-url"

    with subprocess.Popen(
        shlex.split(command),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    ) as sp:
        for i in sp.stdout:
            print(i.strip())


def restore_snapshot():

    header = widgets.HTML(
        '<h3 style="width: auto;">Restore ComfyUI Snapshot (Do not run ComfyUI process)</h3>'
    )
    display(header)

    textinputlayout = widgets.Layout(width="400px", height="40px")
    url_snapshot = widgets.Text(
        value="",
        placeholder="Paste ComfyUI Snapshot json url",
        disabled=False,
        layout=textinputlayout,
    )

    textWidget = widgets.HBox(
        [widgets.Label("Custom Node Pack URL (snapshot):"), url_snapshot]
    )
    display(textWidget)

    download_button = widgets.Button(description="Download", button_style="primary")
    output = widgets.Output()

    def on_press(button):
        with output:
            output.clear_output()
            try:
                if url_snapshot.value != "":
                    run_snapshot(url_snapshot.value)
                completed_message()

            except KeyboardInterrupt:
                print("\n\n--Snapshot restore interrupt--")

    download_button.on_click(on_press)

    display(download_button, output)


def launch_comfyui():
    os.makedirs("/notebooks/output_images/", exist_ok=True)
    models_header = widgets.HTML(
        '<h3 style="width: 250px;">เริ่มโปรแกรม ComfyUI ตรงนี้</h3>'
    )
    display(models_header)
    output = widgets.Output()

    def run_comfyui(button):

        os.chdir("/notebooks/")

        command = "python -u main.py --listen 0.0.0.0 --disable-auto-launch --output-directory /notebooks/output_images/"

        if platform_id == "RUNPOD":
            proxy_url = f'URL : https://{os.environ.get("RUNPOD_POD_ID")}-{8188}.proxy.runpod.net'
        elif platform_id == "PAPERSPACE":
            proxy_url = f'URL : https://tensorboard-{os.environ.get("PAPERSPACE_FQDN")}'

        os.chdir("/notebooks/ComfyUI/")  # Change to the ComfyUI directory

        try:
            # Start the subprocess with unbuffered output
            process = subprocess.Popen(
                shlex.split(command),
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,  # Line buffering
            )

            with output:
                output.clear_output()
                print("ComfyUI has been started")
                print(proxy_url)

                for i in process.stdout:
                    print(i.strip())

            # Wait for the subprocess to complete
            process.wait()

        except KeyboardInterrupt:
            process.terminate()
            output.clear_output()
            with output:
                print("\n--Process terminated--")
        finally:
            os.chdir("/notebooks/")  # Restore the working directory

    start_button = widgets.Button(description="START ComfyUI", button_style="primary")

    start_button.on_click(run_comfyui)

    display(start_button, output)
