#!/bin/bash

echo "Updating kohya-ss GUI"

cd kohya_ss && git pull && python ./setup/validate_requirements.py

echo "Update Completed"
