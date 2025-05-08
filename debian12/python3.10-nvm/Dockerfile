# Dockerfile
FROM debian:bookworm

# Non-root user for testing
RUN useradd -m test

# Copy your setup script into the container
COPY python3.10-nvm/setup.sh /root/setup.sh

# Pre-install basic deps
RUN apt update && apt install -y sudo wget gnupg curl

# Allow testuser to use sudo without password
RUN echo "test ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to non-root and run setup as testuser
USER test
WORKDIR /home/test
