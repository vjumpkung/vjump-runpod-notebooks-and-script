#!/bin/bash

echo "Updating kohya-ss GUI"

git pull
cd kohya_ss && python ./setup/validate_requirements.py

echo "Update Completed"
