FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99

# Install base packages, build tools, Python 3.12, Electron/X11 deps, and utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    wget \
    tar \
    xz-utils \
    build-essential \
    cmake \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    libgtk-3-0 \
    libnotify4 \
    libnss3 \
    libxss1 \
    libasound2t64 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libgbm1 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libpango-1.0-0 \
    libcairo2 \
    libxshmfence1 \
    xvfb \
    x11vnc \
    fluxbox \
    novnc \
    websockify \
    qrencode \
    dbus-x11 \
    fonts-noto-color-emoji \
    fonts-dejavu-core \
    gosu \
    sudo \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Intel graphics, Level Zero, OpenCL, OpenVINO dependencies, and hardware tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    gpg-agent \
    pciutils \
    clinfo \
    libtbb12 \
    libhwloc15 \
    libgomp1 \
    libnuma1 \
    libfuse2t64 \
    ocl-icd-libopencl1 \
    mesa-vulkan-drivers \
    libdrm-intel1 \
    && add-apt-repository -y ppa:kobuk-team/intel-graphics \
    && curl -fsSL https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor -o /usr/share/keyrings/intel-oneapi-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/intel-oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" > /etc/apt/sources.list.d/oneAPI.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    intel-opencl-icd \
    libze1 \
    libze-intel-gpu1 \
    && rm -rf /var/lib/apt/lists/*

# Install uv system-wide
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.local/bin/uv /usr/local/bin/uv && \
    chmod 755 /usr/local/bin/uv

# Install signal-cli 0.14.8 native Linux binary system-wide
RUN curl -sL https://github.com/AsamK/signal-cli/releases/download/v0.14.8/signal-cli-0.14.8-Linux-native.tar.gz | \
    tar -xz -C /tmp && \
    mv /tmp/signal-cli /usr/local/bin/signal-cli && \
    chmod 755 /usr/local/bin/signal-cli

# Rename existing ubuntu user (uid 1000) to lstrano
RUN usermod -l lstrano -d /home/lstrano -m ubuntu && \
    groupmod -n lstrano ubuntu && \
    echo "lstrano ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/lstrano && \
    chmod 0440 /etc/sudoers.d/lstrano && \
    mkdir -p /app /home/lstrano/.config /home/lstrano/.cache /home/lstrano/.local && \
    chown -R lstrano:lstrano /app /home/lstrano

USER lstrano
ENV HOME=/home/lstrano
ENV PATH="/usr/local/bin:/home/lstrano/.local/bin:${PATH}"
ENV AIPG_SIGNAL_CLI_PATH=/usr/local/bin/signal-cli

WORKDIR /app
COPY --chown=lstrano:lstrano docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 6080 5900

ENTRYPOINT ["/entrypoint.sh"]
