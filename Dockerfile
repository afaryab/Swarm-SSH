# Use Alpine Linux for a small image size
FROM alpine:3.19

# Install required packages
RUN apk add --no-cache \
    openssh-client \
    docker-cli \
    bash \
    curl \
    jq

# Create directory for SSH keys
RUN mkdir -p /ssh-keys

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
