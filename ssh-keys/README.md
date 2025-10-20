# SSH Keys Directory

Place your team's SSH private keys in this directory. The Swarm-SSH container will use these keys to authenticate when connecting to other containers.

## Supported Key Types

- RSA keys: `id_rsa` (private) and `id_rsa.pub` (public)
- Ed25519 keys: `id_ed25519` (private) and `id_ed25519.pub` (public)
- Any other SSH private/public key pairs

## Example Structure

```
ssh-keys/
├── id_rsa              # Private key (keep secure!)
├── id_rsa.pub          # Public key
├── id_ed25519          # Alternative private key
└── id_ed25519.pub      # Alternative public key
```

## Generating SSH Keys

If you don't have SSH keys yet, generate them with:

```bash
# Generate RSA key
ssh-keygen -t rsa -b 4096 -f ssh-keys/id_rsa -N ""

# Or generate Ed25519 key (more modern)
ssh-keygen -t ed25519 -f ssh-keys/id_ed25519 -N ""
```

## Security Notes

- **Never commit private keys to version control!**
- This directory is included in `.gitignore` to prevent accidental commits
- Set proper permissions: `chmod 600 ssh-keys/id_*` (private keys)
- Set proper permissions: `chmod 644 ssh-keys/*.pub` (public keys)

## Using with Swarm-SSH

The container will automatically detect and use available keys from this directory.
