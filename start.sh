#!/bin/bash

VENV_PATH="/root/venv"
PY_SCRIPT="/opt/turing-smart-screen-python/main.py"

if [ ! -d "$VENV_PATH" ]; then
    echo "Error: Virtual environment not found at: $VENV_PATH"
    exit 1
fi

sudo source ${VENV_PATH}/bin/activate
sudo "$VENV_PATH/bin/python3" "$PY_SCRIPT"

