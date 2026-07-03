@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo ComfyUI Installation Script - NVIDIA
echo UV Package Manager with Python 3.12 and CUDA 13.0
echo ========================================
echo.

:: Set variables
set VENV_DIR=%cd%\venv
set COMFYUI_REPO=https://github.com/Comfy-Org/ComfyUI.git
set MANAGER_REPO=https://github.com/Comfy-Org/ComfyUI-Manager.git
set CONFIG_URL=https://raw.githubusercontent.com/vjumpkung/vjump-comfyui-runpod-template/refs/heads/main/src/config.ini
set FLASH_ATTN_2_URL=https://huggingface.co/ussoewwin/Flash-Attention-2_for_Windows/resolve/main/flash_attn-2.8.3%2Bcu130torch2.10.0cxx11abiTRUE-cp312-cp312-win_amd64.whl
set NUNCHAKU_URL=https://github.com/nunchaku-ai/nunchaku/releases/download/v1.2.1/nunchaku-1.2.1+cu13.0torch2.10-cp312-cp312-win_amd64.whl

:: Create run script
echo Creating run script...
(
echo @echo off
echo.
echo :: Get the directory where this script is located
echo set SCRIPT_DIR=%%~dp0
echo set SCRIPT_DIR=%%SCRIPT_DIR:~0,-1%%
echo.
echo :: Activate virtual environment
echo call "%%SCRIPT_DIR%%\venv\Scripts\activate.bat"
echo.
echo :: Change to ComfyUI directory
echo cd /d "%%SCRIPT_DIR%%\ComfyUI"
echo.
echo :: Run ComfyUI
echo echo Starting ComfyUI...
echo python main.py --auto-launch --preview-method auto %%*
echo.
echo pause
) > run_comfyui.bat

:: Step 1: Install UV
echo [Step 1/11] Installing UV package manager...
where uv >nul 2>&1
if errorlevel 1 (
    echo Installing UV...
    powershell -ExecutionPolicy ByPass -Command "irm https://astral.sh/uv/install.ps1 | iex"
    if errorlevel 1 (
        echo Error: Failed to install UV
        exit /b 1
    )
    echo UV installed successfully!
) else (
    echo UV already installed, skipping installation.
)
echo.

:: Step 2: Create UV virtual environment with Python 3.12
echo [Step 2/11] Creating UV virtual environment with Python 3.12...
if not exist "%VENV_DIR%" (
    echo Creating virtual environment...
    uv venv "%VENV_DIR%" --python 3.12 --seed
    if errorlevel 1 (
        echo Error: Failed to create virtual environment
        exit /b 1
    )
    echo Virtual environment created successfully!
) else (
    echo Virtual environment already exists at %VENV_DIR%, skipping creation.
)
echo.

:: Step 3: Activate virtual environment
echo [Step 3/11] Activating virtual environment...
call "%VENV_DIR%\Scripts\activate.bat"
if errorlevel 1 (
    echo Error: Failed to activate virtual environment
    exit /b 1
)
echo Virtual environment activated successfully!
echo.

:: Verify Python installation
echo Verifying Python installation...
python --version
python -c "import sys;print(sys.executable)"
if errorlevel 1 (
    echo Error: Python verification failed
    exit /b 1
)
echo.

:: Install pip and uv for legacy support
echo Installing pip and uv for legacy support...
python -m pip install --upgrade pip
python -m pip install uv comfy-cli
if errorlevel 1 (
    echo Warning: Failed to install pip/uv (continuing anyway)
)
echo.

:: Step 4: Clone ComfyUI repository
echo [Step 4/11] Cloning ComfyUI repository...
if not exist "ComfyUI" (
    git clone "%COMFYUI_REPO%"
    if errorlevel 1 (
        echo Error: Failed to clone ComfyUI repository
        exit /b 1
    )
) else (
    echo ComfyUI repository already exists, skipping clone.
)
echo.

:: Step 5: Clone ComfyUI-Manager into custom_nodes
echo [Step 5/11] Cloning ComfyUI-Manager repository...
if not exist "ComfyUI\custom_nodes" (
    mkdir "ComfyUI\custom_nodes"
)

if not exist "ComfyUI\custom_nodes\ComfyUI-Manager" (
    cd ComfyUI\custom_nodes
    git clone "%MANAGER_REPO%"
    if errorlevel 1 (
        echo Error: Failed to clone ComfyUI-Manager repository
        cd ..\..
        exit /b 1
    )
    cd ..\..
) else (
    echo ComfyUI-Manager already exists, skipping clone.
)
echo.

:: Download and set config file
echo Downloading and setting config file...
set CONFIG_DIR=ComfyUI\user\__manager
if not exist "%CONFIG_DIR%" (
    mkdir "%CONFIG_DIR%" 2>nul
    if errorlevel 1 (
        echo Creating directories recursively...
        if not exist "ComfyUI\user" mkdir "ComfyUI\user"
        if not exist "ComfyUI\user\__manager" mkdir "ComfyUI\user\__manager"
    )
)

curl -L -o "%CONFIG_DIR%\config.ini" "%CONFIG_URL%"
if errorlevel 1 (
    echo Warning: Failed to download config file
) else (
    echo Config file downloaded successfully to %CONFIG_DIR%\config.ini
)
echo.

:: Step 6: Install PyTorch 2.9.1 with CUDA 13.0
echo [Step 6/11] Installing PyTorch 2.10.0 with CUDA 13.0...
echo This may take several minutes...
python -m uv pip install torch==2.10.0 torchvision==0.25.0 torchaudio==2.10.0 --extra-index-url https://download.pytorch.org/whl/cu130
if errorlevel 1 (
    echo Error: Failed to install PyTorch
    exit /b 1
)
echo PyTorch installed successfully!
echo.

:: Step 7: Install triton-windows and dependencies
echo [Step 7/11] Installing triton-windows and dependencies...
python -m uv pip install "triton-windows<3.7"
if errorlevel 1 (
    echo Warning: Failed to install triton-windows (may not be critical)
)

python -m uv pip install huggingface_hub
if errorlevel 1 (
    echo Warning: Failed to install huggingface_hub
)
echo.

:: Step 8: Download and Install sageattention
echo.
echo ========================================
echo [Step 8/11] Installing Performance Acceleration Wheels
echo ========================================
echo.
echo ^> Downloading flash_attn_2, flash_attn_3, sageattention, llama-cpp-python
uvx hf download ussoewwin/Flash-Attention-2_for_Windows flash_attn-2.8.3+cu130torch2.10.0cxx11abiTRUE-cp312-cp312-win_amd64.whl --local-dir .
if errorlevel 1 (
    echo   [X] Failed to download sageattention wheel file
) else (
    echo   [OK] Downloaded successfully
    echo   ^> Installing sageattention...
    python -m uv pip install "transformers==5.5.0" onnx "numpy<2.3" "pillow<12"
    python -m uv pip install --pre --index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/ort-cuda-13-nightly/pypi/simple/ onnxruntime-gpu --no-deps
    python -m uv pip install "https://github.com/JamePeng/llama-cpp-python/releases/download/v0.3.34-cu130-Basic-win-20260331/llama_cpp_python-0.3.34+cu130.basic-cp312-cp312-win_amd64.whl"
    python -m uv pip install "https://github.com/woct0rdho/SageAttention/releases/download/v2.2.0-windows.post4/sageattention-2.2.0+cu130torch2.9.0andhigher.post4-cp39-abi3-win_amd64.whl"
    python -m uv pip install flash_attn_3 --find-links https://windreamer.github.io/flash-attention3-wheels/cu130_torch2100
    python -m uv pip install flash_attn-2.8.3+cu130torch2.10.0cxx11abiTRUE-cp312-cp312-win_amd64.whl
    python -m uv pip install "%NUNCHAKU_URL%" --no-deps
    if errorlevel 1 (
        echo   [X] Installation failed
    ) else (
        echo   [OK] flash_attn_2, flash_attn_3, sageattention, llama-cpp-python!
        del flash_attn-2.8.3+cu130torch2.10.0cxx11abiTRUE-cp312-cp312-win_amd64.whl
    )
)
echo.

:: Step 9: Download and Install nunchaku
echo.
echo ========================================
echo [Step 9/11] SKIPPED
echo ========================================
echo.

:: Step 10: Install ComfyUI and ComfyUI-Manager dependencies
echo [Step 10/11] Installing ComfyUI dependencies...
cd ComfyUI
if exist "requirements.txt" (
    python -m uv pip install -r requirements.txt
    if errorlevel 1 (
        echo Error: Failed to install ComfyUI requirements
        cd ..
        exit /b 1
    )
)

echo Installing ComfyUI-Manager dependencies...
cd custom_nodes\ComfyUI-Manager
if exist "requirements.txt" (
    python -m uv pip install -r requirements.txt
    if errorlevel 1 (
        echo Warning: Failed to install ComfyUI-Manager requirements
    )
)
cd ..\..
echo.

:: Step 11: Install custom nodes using git clone
echo.
echo ========================================
echo [Step 11/11] Installing Custom Nodes (13 nodes)
echo ========================================
echo This may take several minutes...
echo.
echo Custom Nodes to be installed:
echo   [01/12] ComfyUI-Impact-Pack
echo   [02/12] ComfyUI-GGUF
echo   [03/12] ComfyUI-KJNodes
echo   [04/12] comfyui_controlnet_aux
echo   [05/12] ComfyUI-VideoHelperSuite
echo   [06/12] rgthree-comfy
echo   [07/12] ComfyUI-Crystools
echo   [08/12] ComfyUI-WanVideoWrapper
echo   [09/12] ComfyUI-Custom-Scripts
echo   [10/12] was-node-suite-comfyui
echo   [11/12] ComfyUI-QwenVL
echo   [12/12] RES4LYF
echo.

:: Navigate to custom_nodes directory
cd custom_nodes
if errorlevel 1 (
    echo Error: Failed to enter custom_nodes directory
    cd ..
    exit /b 1
)

:: Clone and install each custom node
call :install_node "https://github.com/ltdrdata/ComfyUI-Impact-Pack.git" "ComfyUI-Impact-Pack" "01/12"
call :install_node "https://github.com/city96/ComfyUI-GGUF.git" "ComfyUI-GGUF" "02/12"
call :install_node "https://github.com/kijai/ComfyUI-KJNodes.git" "ComfyUI-KJNodes" "03/12"
call :install_node "https://github.com/Fannovel16/comfyui_controlnet_aux.git" "comfyui_controlnet_aux" "04/12"
call :install_node "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git" "ComfyUI-VideoHelperSuite" "05/12"
call :install_node "https://github.com/rgthree/rgthree-comfy.git" "rgthree-comfy" "06/12"
call :install_node "https://github.com/crystian/ComfyUI-Crystools.git" "ComfyUI-Crystools" "07/12"
call :install_node "https://github.com/kijai/ComfyUI-WanVideoWrapper.git" "ComfyUI-WanVideoWrapper" "08/12"
call :install_node "https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git" "ComfyUI-Custom-Scripts" "09/12"
call :install_node "https://github.com/ltdrdata/was-node-suite-comfyui.git" "was-node-suite-comfyui" "10/12"
call :install_node "https://github.com/1038lab/ComfyUI-QwenVL.git" "ComfyUI-QwenVL" "11/12"
call :install_node "https://github.com/ClownsharkBatwing/RES4LYF.git" "RES4LYF" "12/12"

:: Return to ComfyUI directory
cd ..
goto :continue_after_install_node

:install_node
set "REPO_URL=%~1"
set "REPO_NAME=%~2"
set "NODE_NUM=%~3"

echo.
echo ========================================
echo [%NODE_NUM%] %REPO_NAME%
echo ========================================

:: Clone repository if it doesn't exist
if not exist "%REPO_NAME%" (
    echo ^> Cloning repository...
    echo   URL: %REPO_URL%
    git clone "%REPO_URL%" 2>nul
    if errorlevel 1 (
        echo   [X] Failed to clone - continuing with next node...
        goto :eof
    )
    echo   [OK] Clone successful
) else (
    echo ^> Repository already exists, skipping clone
)

:: Enter the repository directory
cd "%REPO_NAME%"
if errorlevel 1 (
    echo   [X] Failed to enter directory - continuing with next node...
    goto :eof
)

:: Check for install.py and run it, otherwise use requirements.txt
if exist "install.py" (
    echo ^> Running install.py...
    python install.py 2>nul
    if errorlevel 1 (
        echo   [!] install.py failed - continuing anyway...
    ) else (
        echo   [OK] Installed via install.py
    )
)

if exist "requirements.txt" (
    echo ^> Installing dependencies from requirements.txt...
    python -m uv pip install -r requirements.txt 2>nul
    if errorlevel 1 (
        echo   [!] Failed to install requirements - continuing anyway...
    ) else (
        echo   [OK] Dependencies installed successfully
    )
) else (
    if not exist "install.py" (
        echo ^> No install.py or requirements.txt found
    )
)

echo   [DONE] %REPO_NAME% processing completed

:: Return to custom_nodes directory
cd ..
goto :eof

:continue_after_install_node
echo.

echo Cache Cleaning
python -c "import importlib; [print(f'{n}: ' + (getattr(importlib.import_module(m), '__version__', 'installed') if __import__('importlib.util', fromlist=['find_spec']).find_spec(m) else 'NOT installed')) for n, m in [('sageattention', 'sageattention'), ('flash-attn (v2/v3)', 'flash_attn'), ('llama-cpp-python', 'llama_cpp')]]"
python -m uv cache clean
python -m pip cache purge

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Virtual environment: %VENV_DIR%
echo Python version: 3.12
echo PyTorch version: 2.10.0+cu130
echo.
echo To run ComfyUI, use the run_comfyui.bat script:
echo   run_comfyui.bat
echo.
echo Or manually run:
echo   venv\Scripts\activate.bat
echo   cd ComfyUI
echo   python main.py
echo.
echo Press any key to exit...
pause > nul
