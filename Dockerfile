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

