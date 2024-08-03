# Build stage
FROM mcr.microsoft.com/devcontainers/base:jammy AS build

# Update package list and install necessary packages
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get dist-upgrade -y && \
    apt-get autoremove -y && \
    apt-get clean
    
RUN apt-get update && apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y ansible
RUN apt-get install -y ansible-lint
RUN apt-get install -y autojump
RUN apt-get install -y yamllint
RUN apt-get install -y zsh
RUN apt-get install -y npm
RUN apt-get install -y shellcheck && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install trivy
RUN wget https://github.com/aquasecurity/trivy/releases/download/v0.19.2/trivy_0.19.2_Linux-64bit.deb && \
    dpkg -i trivy_0.19.2_Linux-64bit.deb && \
    rm trivy_0.19.2_Linux-64bit.deb
RUN which autojump

# Install Zsh plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/zsh-users/zsh-autosuggestions/master/install.zsh)"

RUN npm install -g prettier

RUN apt-get update && apt-get install -y autojump
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
RUN chmod +x /usr/local/bin/yq
USER vscode
RUN sudo sed -i 's|/bin/bash|/usr/bin/zsh|g' /etc/passwd
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "pgrep", "zsh" ]
