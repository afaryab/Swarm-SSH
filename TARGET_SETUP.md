# Target Container Setup Guide

This guide explains how to set up target containers to accept SSH connections from the Swarm-SSH client.

## Prerequisites

Your target containers need to:
1. Have an SSH server installed and running
2. Have your public SSH key in the authorized_keys file
3. Be on the same Docker network as the Swarm-SSH client

## Option 1: Alpine-based Containers

For Alpine Linux containers, add the following to your Dockerfile or startup command:

```dockerfile
FROM alpine:latest

# Install OpenSSH server
RUN apk add --no-cache openssh

# Generate host keys
RUN ssh-keygen -A

# Create .ssh directory for root
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Copy your public key (replace with your actual public key)
COPY authorized_keys /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# Configure SSH
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Start SSH server
CMD ["/usr/sbin/sshd", "-D", "-e"]
```

## Option 2: Ubuntu/Debian-based Containers

For Ubuntu or Debian containers:

```dockerfile
FROM ubuntu:latest

# Install OpenSSH server
RUN apt-get update && \
    apt-get install -y openssh-server && \
    rm -rf /var/lib/apt/lists/*

# Create .ssh directory
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Copy your public key
COPY authorized_keys /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# Configure SSH
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Create privilege separation directory
RUN mkdir -p /run/sshd

# Start SSH server
CMD ["/usr/sbin/sshd", "-D"]
```

## Option 3: Adding SSH to Existing Containers

If you have existing containers, you can add SSH support via docker-compose:

```yaml
version: '3.8'

services:
  myapp:
    image: myapp:latest
    # ... your existing configuration ...
    
    # Add SSH setup as part of the entrypoint
    entrypoint: >
      sh -c "
      apk add --no-cache openssh &&
      ssh-keygen -A &&
      mkdir -p /root/.ssh &&
      chmod 700 /root/.ssh &&
      cat /tmp/ssh-key.pub > /root/.ssh/authorized_keys &&
      chmod 600 /root/.ssh/authorized_keys &&
      /usr/sbin/sshd &&
      exec /your-original-entrypoint
      "
    
    volumes:
      - ./ssh-keys/id_rsa.pub:/tmp/ssh-key.pub:ro
```

## Option 4: Quick Setup Script

Create a setup script in your container:

```bash
#!/bin/sh
# setup-ssh.sh

# Install SSH (Alpine)
apk add --no-cache openssh

# Or for Ubuntu/Debian:
# apt-get update && apt-get install -y openssh-server

# Generate host keys
ssh-keygen -A

# Setup SSH directory
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Add your public key (replace with actual key)
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... your-key-here" > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Configure SSH for key authentication
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Start SSH server
/usr/sbin/sshd -D -e
```

## Adding Your Public Key

### Method 1: Build-time (Dockerfile COPY)

Create an `authorized_keys` file with your public key:

```bash
cat ssh-keys/id_rsa.pub > authorized_keys
```

Then in your Dockerfile:
```dockerfile
COPY authorized_keys /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys
```

### Method 2: Runtime (Volume Mount)

Mount your public key as a volume:

```yaml
services:
  myapp:
    volumes:
      - ./ssh-keys/id_rsa.pub:/tmp/pubkey:ro
    command: >
      sh -c "
      cp /tmp/pubkey /root/.ssh/authorized_keys &&
      chmod 600 /root/.ssh/authorized_keys &&
      /usr/sbin/sshd -D
      "
```

### Method 3: Environment Variable

Pass the public key as an environment variable:

```yaml
services:
  myapp:
    environment:
      - SSH_PUBLIC_KEY=ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ...
    command: >
      sh -c "
      echo $SSH_PUBLIC_KEY > /root/.ssh/authorized_keys &&
      chmod 600 /root/.ssh/authorized_keys &&
      /usr/sbin/sshd -D
      "
```

## Testing SSH Access

Once your target container is set up, test SSH access:

```bash
# From your host
ssh -i ssh-keys/id_rsa root@<container-ip>

# Or use the Swarm-SSH container
docker run -it --rm \
  -v $(pwd)/ssh-keys:/ssh-keys:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --network <your-network> \
  afaryab/swarm-ssh:latest
```

## Common SSH Server Configurations

### Minimal sshd_config

```
PermitRootLogin yes
PubkeyAuthentication yes
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
```

### Starting SSH Server

Different ways to start SSH server:

```bash
# Foreground with error logging (recommended for Docker)
/usr/sbin/sshd -D -e

# Background mode
/usr/sbin/sshd

# With custom config
/usr/sbin/sshd -D -e -f /etc/ssh/sshd_config
```

## Security Best Practices

1. **Disable Password Authentication**: Always use key-based authentication
2. **Don't expose SSH ports**: Keep SSH internal to Docker network
3. **Use non-root user**: Create a dedicated SSH user instead of root
4. **Rotate Keys Regularly**: Update SSH keys periodically
5. **Use Secrets**: In production, use Docker secrets for sensitive data

## Troubleshooting

### SSH Connection Refused

- Check if SSH server is running: `ps aux | grep sshd`
- Check SSH server logs: `cat /var/log/auth.log` or check container logs
- Verify SSH is listening: `netstat -tlnp | grep 22`

### Permission Denied (publickey)

- Check authorized_keys permissions: should be 600
- Check .ssh directory permissions: should be 700
- Verify public key is in authorized_keys
- Check SSH server config allows PublicKey authentication

### Container Name Not Resolving

- Ensure containers are on the same network
- Use container IP if name resolution fails
- Check Docker network DNS: `docker network inspect <network-name>`

## Example Complete Setup

Here's a complete docker-compose.yml with SSH-enabled services:

```yaml
version: '3.8'

services:
  swarm-ssh:
    image: afaryab/swarm-ssh:latest
    stdin_open: true
    tty: true
    volumes:
      - ./ssh-keys:/ssh-keys:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - app-net

  web:
    image: nginx:alpine
    volumes:
      - ./ssh-keys/id_rsa.pub:/tmp/key.pub:ro
    networks:
      - app-net
    command: >
      sh -c "
      apk add --no-cache openssh &&
      ssh-keygen -A &&
      mkdir -p /root/.ssh &&
      cp /tmp/key.pub /root/.ssh/authorized_keys &&
      chmod 600 /root/.ssh/authorized_keys &&
      /usr/sbin/sshd &&
      nginx -g 'daemon off;'
      "

  api:
    image: node:alpine
    volumes:
      - ./ssh-keys/id_rsa.pub:/tmp/key.pub:ro
    networks:
      - app-net
    command: >
      sh -c "
      apk add --no-cache openssh &&
      ssh-keygen -A &&
      mkdir -p /root/.ssh &&
      cp /tmp/key.pub /root/.ssh/authorized_keys &&
      chmod 600 /root/.ssh/authorized_keys &&
      /usr/sbin/sshd &&
      node server.js
      "

networks:
  app-net:
    driver: bridge
```

This setup allows the Swarm-SSH container to SSH into both the `web` and `api` containers.
