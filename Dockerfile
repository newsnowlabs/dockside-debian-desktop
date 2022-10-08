FROM node:16-bullseye as stage1

# Use bash shell for 'RUN' commands
SHELL ["/bin/bash", "-c"]

# Install packages
# - python3-numpy is needed to support build on linux/arm/v7
RUN  apt-get update && \
     apt-get install -y curl zip unzip sudo && \
     apt-get install -y python3 python3-numpy git procps tigervnc-standalone-server firefox-esr libpci3 libegl1 menu python3-setuptools openbox fbpanel mlterm sakura && \
     apt-get clean && rm -rf /var/lib/apt/lists/*

FROM stage1 as stage2

# Install websockify
RUN  git clone https://github.com/novnc/websockify /opt/websockify && \
     cd /opt/websockify && python3 setup.py install

FROM stage2 as stage3

# Create dockside user
RUN adduser --home /home/dockside --shell /bin/bash --disabled-password dockside && chown dockside /opt
USER dockside
WORKDIR /home/dockside

# Install noVNC and configure password
RUN  curl --location --silent https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.tar.gz | tar xz -C /opt && \
     cd /opt/noVNC* && ln vnc.html index.html && \
     mkdir -p ~/.vnc && echo dockside | tigervncpasswd -f >~/.vnc/passwd && chmod 600 ~/.vnc/passwd && \
     mkdir -p ~/.local/share

# Add config for openbox, fbpanel, sakkura, ...
ADD --chown=dockside:dockside ./config /home/dockside/.config

ENV SHELL="/bin/bash"
CMD ["/bin/bash"]
