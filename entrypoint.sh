#!/bin/bash

set -e

echo "==================================="
echo "  Swarm-SSH Container Navigator"
echo "==================================="
echo ""

# Check if SSH keys directory is mounted
if [ ! -d "/ssh-keys" ]; then
    echo "ERROR: /ssh-keys directory not found!"
    echo "Please mount your SSH keys directory to /ssh-keys"
    exit 1
fi

# Check if any SSH keys are available
KEY_COUNT=$(find /ssh-keys -type f -name "*.pub" 2>/dev/null | wc -l)
if [ "$KEY_COUNT" -eq 0 ]; then
    echo "WARNING: No SSH public keys found in /ssh-keys"
    echo "Continuing anyway..."
fi

# Function to get neighboring containers in the Docker Swarm/network
get_containers() {
    echo "Discovering containers in the network..."
    
    # Try to get containers from Docker Swarm services
    if docker node ls &>/dev/null; then
        echo "Detected Docker Swarm mode"
        # Get all tasks/containers in the swarm
        docker service ls --format "{{.Name}}" 2>/dev/null || true
    else
        echo "Standalone Docker mode detected"
        # Get containers on the same network
        docker ps --format "{{.Names}}" 2>/dev/null || true
    fi
}

# Function to display menu and get user selection
show_menu() {
    local containers=("$@")
    
    if [ ${#containers[@]} -eq 0 ]; then
        echo "No containers found in the network."
        echo ""
        echo "This could mean:"
        echo "  1. No other containers are running"
        echo "  2. Docker socket is not mounted (use -v /var/run/docker.sock:/var/run/docker.sock)"
        echo "  3. You don't have permission to access Docker"
        exit 1
    fi
    
    echo ""
    echo "Available containers:"
    echo "-------------------"
    
    local i=1
    for container in "${containers[@]}"; do
        echo "  $i) $container"
        ((i++))
    done
    
    echo "  q) Quit"
    echo ""
    echo -n "Select a container to SSH into (1-${#containers[@]} or q): "
    
    read -r selection
    
    if [ "$selection" = "q" ] || [ "$selection" = "Q" ]; then
        echo "Exiting..."
        exit 0
    fi
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#containers[@]} ]; then
        echo "Invalid selection!"
        return 1
    fi
    
    echo "${containers[$((selection-1))]}"
    return 0
}

# Function to SSH into a container
ssh_to_container() {
    local container_name=$1
    
    echo ""
    echo "Attempting to SSH into: $container_name"
    
    # Try to resolve the container name to get IP
    # In Docker Swarm, service names are DNS resolvable
    local target="$container_name"
    
    # Try to find SSH key
    local ssh_key=""
    if [ -f "/ssh-keys/id_rsa" ]; then
        ssh_key="/ssh-keys/id_rsa"
    elif [ -f "/ssh-keys/id_ed25519" ]; then
        ssh_key="/ssh-keys/id_ed25519"
    else
        # Try to find any private key
        ssh_key=$(find /ssh-keys -type f ! -name "*.pub" | head -n 1)
    fi
    
    if [ -z "$ssh_key" ]; then
        echo "ERROR: No SSH private key found in /ssh-keys"
        exit 1
    fi
    
    echo "Using SSH key: $ssh_key"
    echo "Connecting to: $target"
    echo ""
    echo "If you're prompted for a username, try: root, ubuntu, or alpine"
    echo ""
    
    # Execute SSH with the found key
    # Add common SSH options for better compatibility
    ssh -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=10 \
        -i "$ssh_key" \
        "$target"
}

# Main execution
main() {
    # Get list of containers
    mapfile -t containers < <(get_containers)
    
    # Show menu and get selection
    selected_container=$(show_menu "${containers[@]}")
    
    if [ $? -eq 0 ] && [ -n "$selected_container" ]; then
        ssh_to_container "$selected_container"
    else
        echo "No valid selection made."
        exit 1
    fi
}

# Run main function
main
