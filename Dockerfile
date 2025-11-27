ARG PYTHON_VERSION=3.12-alpine3.19
FROM python:${PYTHON_VERSION}

WORKDIR /app

COPY . .

# Install build tools and dependencies
# Avoid strict pins unless reproducibility demands it
RUN apk add --no-cache \
    build-base \            
    font-roboto-mono \      
    git \                   
    linux-headers \
    libdrm \
    libdrm-dev \
    mesa-dev \
    python3-tkinter=3.11.14-r0 \
 && pip3 install Cython \
 && pip3 install pyamdgpuinfo \
 && pip3 install --no-cache-dir -r requirements.txt \
 && mv tsr /usr/local/bin \
 && chmod +x /usr/local/bin/tsr

CMD ["tsr"]

