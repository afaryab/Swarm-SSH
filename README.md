# Swarm-SSH

A Docker container that provides interactive SSH access to neighboring containers in a Docker Swarm or Docker network. This tool makes it easy for teams to SSH into containers by providing an interactive menu of available containers.

## Features

- 🚀 **Interactive Container Selection**: Presents a menu of available containers in your Docker Swarm/network
- 🔐 **SSH Key Management**: Mount your team's SSH keys for secure authentication
- 🐳 **Docker Swarm Support**: Works with both Docker Swarm and standalone Docker
- 🌐 **Traefik Compatible**: Can be deployed alongside Traefik for service discovery
- 📦 **Lightweight**: Based on Alpine Linux for minimal image size
- 🔄 **Auto-deployed**: Automatically builds and publishes to Docker Hub on commits to main branch

## Quick Start

### Using Docker Command

```bash
# Pull the latest image
docker pull afaryab/swarm-ssh:latest

# Run interactively
docker run -it --rm \
  -v $(pwd)/ssh-keys:/ssh-keys:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --network swarm-network \
  afaryab/swarm-ssh:latest
```

### Using Docker Compose

1. Create a `docker-compose.yml` file (or use the provided one):

```yaml
version: '3.8'

services:
  swarm-ssh:
    image: afaryab/swarm-ssh:latest
    container_name: swarm-ssh-client
    stdin_open: true
    tty: true
    volumes:
      - ./ssh-keys:/ssh-keys:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - swarm-network

networks:
  swarm-network:
    driver: overlay
```

2. Run with Docker Compose:

```bash
docker-compose run --rm swarm-ssh
```

### Using in Docker Swarm

Deploy as a service in your Docker Swarm:

```bash
docker service create \
  --name swarm-ssh \
  --mount type=bind,src=/path/to/ssh-keys,dst=/ssh-keys,readonly \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock,readonly \
  --network swarm-network \
  --constraint 'node.role==manager' \
  afaryab/swarm-ssh:latest
```

## Setup

### 1. Prepare SSH Keys

Create a directory for your SSH keys:

```bash
mkdir -p ssh-keys
```

Generate SSH keys if you don't have them:

```bash
# Generate RSA key
ssh-keygen -t rsa -b 4096 -f ssh-keys/id_rsa -N ""

# Or generate Ed25519 key (recommended)
ssh-keygen -t ed25519 -f ssh-keys/id_ed25519 -N ""
```

**Important**: Make sure to copy the public key to the target containers' `~/.ssh/authorized_keys` file.

### 2. Mount Required Volumes

The container requires two volumes:

- **SSH Keys**: Mount your SSH keys directory to `/ssh-keys` (read-only recommended)
- **Docker Socket**: Mount `/var/run/docker.sock` to enable container discovery

### 3. Network Configuration

Connect the container to the same network as your target containers. For Docker Swarm, use an overlay network.

## How It Works

1. **Container Discovery**: The container uses the Docker API (via mounted socket) to discover other containers/services in the network
2. **Interactive Menu**: Displays a numbered list of available containers
3. **SSH Connection**: Once you select a container, it establishes an SSH connection using the mounted keys
4. **Swarm Mode Detection**: Automatically detects whether running in Docker Swarm or standalone mode

## Example Session

```
===================================
  Swarm-SSH Container Navigator
===================================

Discovering containers in the network...
Standalone Docker mode detected

Available containers:
-------------------
  1) web-server
  2) database
  3) redis-cache
  4) api-gateway
  q) Quit

Select a container to SSH into (1-4 or q): 2

Attempting to SSH into: database
Using SSH key: /ssh-keys/id_rsa
Connecting to: database

If you're prompted for a username, try: root, ubuntu, or alpine

[SSH session starts]
```

## Requirements

### For the Swarm-SSH Container

- Docker Engine 20.10+
- Access to Docker socket
- SSH keys mounted to `/ssh-keys`

### For Target Containers

- SSH server running (e.g., `openssh-server`)
- Your public key added to `~/.ssh/authorized_keys`
- Network connectivity to the Swarm-SSH container

## Configuration

### Environment Variables

Currently, the container uses sensible defaults. Future versions may support:

- `SSH_USER`: Default SSH username
- `SSH_PORT`: Default SSH port (22)
- `CONNECTION_TIMEOUT`: SSH connection timeout

### SSH Options

The container uses the following SSH options for better compatibility:

- `StrictHostKeyChecking=no`: Automatically accept new host keys
- `UserKnownHostsFile=/dev/null`: Don't save host keys
- `ConnectTimeout=10`: 10-second connection timeout

## Traefik Integration

When using with Traefik, ensure your services are on the same network:

```yaml
version: '3.8'

services:
  swarm-ssh:
    image: afaryab/swarm-ssh:latest
    networks:
      - traefik-public
    volumes:
      - ./ssh-keys:/ssh-keys:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro

networks:
  traefik-public:
    external: true
```

## Building from Source

Clone the repository and build:

```bash
git clone https://github.com/afaryab/Swarm-SSH.git
cd Swarm-SSH
docker build -t afaryab/swarm-ssh:latest .
```

## GitHub Actions Workflow

The repository includes a GitHub Actions workflow that:

- ✅ Builds the Docker image on every commit to `main`
- ✅ Publishes to Docker Hub automatically
- ✅ Creates GitHub releases when tags are pushed
- ✅ Supports multi-platform builds (amd64, arm64)

### Setting Up CI/CD

To enable automatic publishing to Docker Hub, add these secrets to your GitHub repository:

1. Go to Settings → Secrets and variables → Actions
2. Add the following secrets:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub password or access token

### Creating a Release

To create a new release:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

This will trigger the workflow to build, publish, and create a GitHub release.

## Troubleshooting

### No containers found

**Problem**: "No containers found in the network"

**Solutions**:
- Ensure Docker socket is mounted: `-v /var/run/docker.sock:/var/run/docker.sock`
- Check network connectivity
- Verify other containers are running: `docker ps`

### SSH connection fails

**Problem**: Cannot connect to selected container

**Solutions**:
- Ensure target container has SSH server running
- Verify public key is in target's `~/.ssh/authorized_keys`
- Check network connectivity: `docker network inspect <network-name>`
- Verify SSH key permissions: `chmod 600 ssh-keys/id_rsa`

### Permission denied

**Problem**: Cannot access Docker socket

**Solutions**:
- Run with appropriate permissions
- Ensure Docker socket has correct permissions
- In Swarm mode, deploy on manager nodes

## Security Considerations

- 🔒 Never commit private SSH keys to version control
- 🔒 Use read-only mounts for SSH keys: `:ro`
- 🔒 Limit Docker socket access to trusted containers only
- 🔒 Consider using Docker secrets for sensitive data in production
- 🔒 Regularly rotate SSH keys
- 🔒 Use strong passphrases for SSH keys in production

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - feel free to use this project for any purpose.

## Support

For issues, questions, or contributions, please visit:
- GitHub Issues: https://github.com/afaryab/Swarm-SSH/issues
- Docker Hub: https://hub.docker.com/r/afaryab/swarm-ssh