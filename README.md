# Turing Smart Screen Python – Docker + NVIDIA GPU (CachyOS/Arch Linux)

This guide explains how to run the **Turing Smart Screen Python** application inside a Docker container with:

- **NVIDIA GPU support** (NVML)
- **CachyOS/Arch Linux compatibility**
- **Serial port access** (`/dev/ttyACM0`)
- **X11 display support**
- **Non‑interactive Docker builds** (no timezone prompts)

The instructions below ensure a fully reproducible setup.

---

## 📦 Requirements

### Hardware
- NVIDIA GPU (e.g., RTX 5060 Ti)
- USB‑connected Turing Smart Screen (usually `/dev/ttyACM0`)

### Software
- CachyOS / Arch Linux
- Docker + Docker Compose
- NVIDIA driver (version 550+ recommended)
- NVIDIA Container Toolkit

---

## 🟦 1. Install and Enable Docker (CachyOS/Arch Linux)

Install Docker and Docker Compose:

```bash
sudo pacman -Sy docker docker-compose
```

Enable and start Docker:

```bash
sudo systemctl enable --now docker
sudo systemctl start docker.socket
sudo systemctl start docker
```

Add your user to the Docker group:

```bash
sudo usermod -aG docker $USER
```

**Important:** Log out and back in so group membership takes effect.

---

## 🟦 2. Verify NVIDIA Driver

Check that the NVIDIA driver is working:

```bash
nvidia-smi
```

If the GPU appears, continue.

---

## 🟦 3. Install NVIDIA Container Toolkit

Do **NOT** install `nvidia-docker` — it does not exist on Arch.

Install the correct package:

```bash
sudo pacman -S nvidia-container-toolkit
```

Or via AUR:

```bash
paru -S nvidia-container-toolkit
```

Configure Docker to use the NVIDIA runtime:

```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

Test GPU access inside Docker:

```bash
docker run --rm --gpus all nvidia/cuda:12.4.0-base-ubuntu22.04 nvidia-smi
```

If the GPU is visible, the setup is correct.

---

## 🟦 4. Project Structure

Your project directory should contain:

```
Dockerfile
compose.yml
config.yaml
res/
tsr
requirements.txt
```

---

## 🟦 5. Dockerfile (NVIDIA + Python + timezone fix)

```dockerfile
FROM nvidia/cuda:12.4.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Budapest

WORKDIR /app

RUN apt-get update && apt-get install -y \
    tzdata \
    python3 \
    python3-pip \
    python3-tk \
    git \
    build-essential \
    libgl1 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxrandr2 \
    libxi6 \
    && apt-get clean

COPY . .

RUN pip install --no-cache-dir Cython \
    && pip install --no-cache-dir nvidia-ml-py3 \
    && pip install --no-cache-dir -r requirements.txt \
    && mv tsr /usr/local/bin \
    && chmod +x /usr/local/bin/tsr

CMD ["tsr"]
```

---

## 🟦 6. docker-compose.yml (GPU + X11 + serial port)

```yaml
services:
  app:
    build:
      context: .
    container_name: tsr
    runtime: nvidia
    environment:
      - DISPLAY=${DISPLAY}
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=all
    devices:
      - /dev/ttyACM0:/dev/ttyACM0
    volumes:
      - $HOME/.Xauthority:/root/.Xauthority:ro
      - ./config.yaml:/app/config.yaml:ro
      - ./res:/app/res:ro
    restart: unless-stopped
```

---

## 🟦 7. Build and Run the Container

```bash
docker compose build --no-cache
docker compose up -d
```

---

## 🟦 8. Common Issues & Fixes

### ❌ NVIDIA driver not detected inside container
```
WARNING: The NVIDIA Driver was not detected.
```

Fix:
- Ensure `runtime: nvidia` is set in compose
- Ensure `NVIDIA_VISIBLE_DEVICES=all`
- Ensure `nvidia-container-toolkit` is installed
- Restart Docker

---

### ❌ Serial port not found
```
Cannot find COM port automatically
```

Check the actual device:

```bash
ls -l /dev/ttyACM*
```

If it’s `/dev/ttyACM1`, update compose accordingly.

---

### ❌ Docker build hangs on timezone selection

Ensure these lines exist in the Dockerfile:

```
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Budapest
```

---

## 🟦 9. Reading GPU Info from Python (NVML)

```python
import pynvml

pynvml.nvmlInit()

count = pynvml.nvmlDeviceGetCount()
print("GPU count:", count)

for i in range(count):
    handle = pynvml.nvmlDeviceGetHandleByIndex(i)
    name = pynvml.nvmlDeviceGetName(handle).decode()
    print("GPU:", name)
```

---

## 📚 Further Information

For additional documentation, configuration details, and original project instructions, see the official repository:

👉 **Turing Smart Screen Python (original GitHub repo)**  
- https://github.com/mathoudebine/turing-smart-screen-python

---

## 🟩 Done

With the steps above, the Turing Smart Screen Python application runs fully inside Docker with NVIDIA GPU support on CachyOS/Arch Linux.
