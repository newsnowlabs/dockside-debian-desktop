#

# Build with: DOCKER_BUILDKIT=1 docker build -t nn-bullseye-nvm-node-vnc:latest .

FROM debian:bullseye

# Use bash shell for 'RUN' commands
SHELL ["/bin/bash", "-c"]

# Install packages
RUN  apt-get update && \
     apt-get install -y curl zip unzip sudo && \
     apt-get install -y python3 git procps tigervnc-standalone-server firefox-esr libpci3 libegl1 menu python3-setuptools openbox fbpanel mlterm sakura && \
     apt-get clean && rm -rf /var/lib/apt/lists/*

# Install websockify
RUN  git clone https://github.com/novnc/websockify /opt/websockify && \
     cd /opt/websockify && python3 setup.py install

# Create dockside user
RUN adduser --uid 1000 --home /home/dockside --shell /bin/bash --disabled-password dockside && chown dockside /opt
USER dockside
WORKDIR /home/dockside

# Install nvm, npm and node
RUN  curl --location --silent https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash && \
     export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" && \
     [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
     nvm install 10.12.0 && \
     nvm use 10.12.0 && \
     npm install -g nrm yarn

# Install noVNC and configure password
RUN  curl --location --silent https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.tar.gz | tar xz -C /opt && \
     cd /opt/noVNC* && ln vnc.html index.html && \
     mkdir -p ~/.vnc && echo dockside | tigervncpasswd -f >~/.vnc/passwd && chmod 600 ~/.vnc/passwd && \
     mkdir -p ~/.local/share

# Add config for openbox, fbpanel, sakkura, ...
ADD --chown=dockside:dockside ./config /home/dockside/.config

ENV SHELL="/bin/bash"
CMD ["/bin/bash"]
