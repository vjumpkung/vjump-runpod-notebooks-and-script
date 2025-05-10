import ipywidgets as widgets
from IPython.display import display, clear_output
import subprocess
import os
import shlex
import requests
import torch
import hashlib
import json
import sys
import threading
import time

platform_id = "OTHER"

if "RUNPOD_POD_ID" in os.environ.keys():
    platform_id = "RUNPOD"
elif "PAPERSPACE_FQDN" in os.environ.keys():
    platform_id = "PAPERSPACE"

with open("model_list.json") as fp:
    model_list = json.load(fp)


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
                        os.environ["CIVITAI_TOKEN"] = textInput.value
                elif key == "HUGGINGFACE_TOKEN":
                    if (
                        textInput.value != "Imported From Environment Variable"
                        or textInput.value != ""
                    ):
                        envs.HUGGINGFACE_TOKEN = textInput.value
                        os.environ["HUGGINGFACE_TOKEN"] = textInput.value
            print("\nSaved ✔")

    save_button.on_click(on_save)
    display(save_button, output)


def completed_message():
    msg = widgets.HTML(
        "<h3>Please copy path <code>/invokeai/models</code> into scan folder path</h3>"
    )
    completed = widgets.Button(
        description="Completed", button_style="success", icon="check"
    )
    print("\n")
    display(msg, completed)


check_types = [
    "checkpoints",
    "clip_vision",
    "controlnet",
    "embeddings",
    "gligen",
    "hypernetworks",
    "ipadapter",
    "loras",
    "unet",
    "upscale_models",
]


def download(name: str, url: str, type: str):
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

    destination = f"./models/{type}/"

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
        return True
    else:
        print(f"Download failed: {name}")
        return False


def select_download_model_list():
    models_header = widgets.HTML('<h3 style="width: 200px;">Model List</h3>')
    headers = widgets.HBox([models_header])
    display(headers)

    get_model_list = model_list

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
                isFailed = False
                completed_lst = []
                for _checkbox, _url in checkboxes:
                    if _checkbox.value:

                        dl_lst = requests.get(_url).json()

                        for i in dl_lst:
                            if i["type"] in ["text_encoders","clip","vae"]:
                                print(f"SKIP {i["name"]} because InvokeAI cannot import")
                                continue
                            
                            if download(
                                i["name"],
                                i["url"],
                                i["type"],
                            ):
                                completed_lst.append(f'{i["name"]} COMPLETED')
                            else:
                                completed_lst.append(f'{i["name"]} FAILED')
                                isFailed = True

                if not isFailed:
                    output.clear_output()
                for i in completed_lst:
                    print(i)
                completed_message()

            except KeyboardInterrupt:
                print("\n\n--Download Model interrupted--")

    download_button.on_click(on_press)

    display(download_button, output)


def download_models():
    models_header = widgets.HTML(
        """<h3 style="width: auto;">Download Model จาก Google Drive, CivitAI หรือ Huggingface</h3>
            <p>ตัวอย่าง Link CivitAI</p>
            <img src="https://res.cloudinary.com/dtyymlemv/image/upload/v1741153257/sd_workflows/hfu7ow2r4ntku0hckkhh.png" width=350>
            <p>https://civitai.com/api/download/models/1468390?type=Model&format=SafeTensor</p>
            <p>ตัวอย่าง Link Huggingface</p>
            <img src="https://res.cloudinary.com/dtyymlemv/image/upload/v1741153356/sd_workflows/shkjcfbc0kuqfuedcose.png" width=400>
            <p>https://huggingface.co/OnomaAIResearch/Illustrious-xl-early-release-v0/resolve/main/Illustrious-XL-v0.1.safetensors</p>
        """
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
                success = []
                if url_model.value != "":
                    if model_type.value in ["text_encoders","clip","vae"]:
                        print(f"SKIP {url_model.value} because InvokeAI cannot import")
                        raise ValueError
                    if download(
                        model_type.value,
                        url_model.value,
                        model_type.value,
                    ):
                        success.append((url_model.value, model_type.value))
                    else:
                        raise PermissionError
                output.clear_output()
                for u, t in success:
                    print(f"download {t} from {u} success")
                completed_message()

            except PermissionError:
                print("\n\nPlease Provide API Key before download")
            except KeyboardInterrupt:
                print("\n\n--Download Model interrupted--")

    download_button.on_click(on_press)

    display(download_button, output)


# Global flag to control the monitoring loop
monitoring_active = True


def create_stop_button():
    """Create a stop button that will terminate the log monitoring"""
    button = widgets.Button(
        description="Stop Monitoring",
        button_style="danger",
        tooltip="Click to stop monitoring the log file",
        icon="stop",
    )

    def on_button_clicked(b):
        global monitoring_active
        monitoring_active = False
        button.description = "Stopping..."
        button.button_style = "warning"
        button.disabled = True

    button.on_click(on_button_clicked)
    return button


# Function to continuously monitor and display log updates
def tail_log(log_file_path, refresh_interval=1):
    """
    Continuously monitor and display updates to a log file.

    Args:
        log_file_path (str): Path to the log file to monitor
        refresh_interval (float): How often to check for updates in seconds
    """
    global monitoring_active
    monitoring_active = True

    # Display stop button
    stop_button = create_stop_button()
    display(stop_button)

    # Create an output area for the logs
    log_output = widgets.Output()
    display(log_output)

    # Check if file exists
    if not os.path.exists(log_file_path):
        with log_output:
            print(f"Error: Log file '{log_file_path}' not found.")
        return

    # Function to be run in a separate thread
    def monitor_log():
        # Get initial file size
        file_size = os.path.getsize(log_file_path)

        try:
            with open(log_file_path, "r") as f:
                # Move to the end of the file
                f.seek(file_size)

                # Display the last few lines first
                f.seek(max(0, file_size - 2000))  # Go back 2000 bytes
                initial_content = f.read()
                with log_output:
                    print(initial_content, end="")

                # Continue monitoring for changes
                while monitoring_active:
                    # Check if file size has changed
                    current_size = os.path.getsize(log_file_path)

                    if current_size > file_size:
                        # Read only the new data
                        f.seek(file_size)
                        new_data = f.read()
                        with log_output:
                            print(new_data, end="", flush=True)
                        file_size = current_size

                    # If file has been truncated (rotated), start from beginning
                    elif current_size < file_size:
                        f.seek(0)
                        new_data = f.read()
                        with log_output:
                            clear_output(wait=True)
                            print(new_data, end="", flush=True)
                        file_size = current_size

                    time.sleep(refresh_interval)

            with log_output:
                print("\nLog monitoring stopped.")

        except Exception as e:
            with log_output:
                print(f"\nError monitoring log file: {e}")

    # Start monitoring in a separate thread
    thread = threading.Thread(target=monitor_log)
    thread.daemon = True  # Thread will exit when main program exits
    thread.start()
