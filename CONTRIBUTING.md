# Contributing to Swarm-SSH

Thank you for your interest in contributing to Swarm-SSH! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Keep discussions professional

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:

1. **Clear title**: Describe the bug in one sentence
2. **Description**: What happened vs what you expected
3. **Steps to reproduce**: Detailed steps to reproduce the issue
4. **Environment**: 
   - OS and version
   - Docker version
   - Swarm-SSH version/tag
5. **Logs**: Relevant error messages or logs
6. **Screenshots**: If applicable

### Suggesting Enhancements

For feature requests or enhancements:

1. Check if the feature already exists or has been requested
2. Clearly describe the use case and benefits
3. Provide examples of how it would work
4. Consider backward compatibility

### Pull Requests

1. **Fork the repository** and create a new branch from `main`
2. **Make your changes** following the coding standards
3. **Test your changes** thoroughly
4. **Update documentation** if needed
5. **Commit your changes** with clear commit messages
6. **Submit a pull request** with a clear description

## Development Setup

### Prerequisites

- Docker 20.10 or later
- Git
- Text editor or IDE

### Local Setup

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/Swarm-SSH.git
cd Swarm-SSH

# Create a branch for your changes
git checkout -b feature/my-new-feature

# Make changes...

# Test the build
docker build -t swarm-ssh:dev .

# Test the functionality
docker-compose -f docker-compose.example.yml up
```

### Testing

Run the test script:

```bash
./test.sh
```

Test the Docker image:

```bash
# Build the image
docker build -t swarm-ssh:test .

# Run it with test containers
docker-compose -f docker-compose.example.yml up
```

### Code Style

- Use consistent indentation (2 or 4 spaces, no tabs)
- Follow shell scripting best practices
- Add comments for complex logic
- Keep functions small and focused
- Use meaningful variable names

### Commit Messages

Write clear commit messages:

```
Short summary (50 chars or less)

More detailed explanation if needed. Wrap at 72 characters.

- Bullet points are fine
- Use present tense ("Add feature" not "Added feature")
- Reference issues: "Fixes #123"
```

## Project Structure

```
Swarm-SSH/
├── .github/
│   └── workflows/
│       └── docker-publish.yml   # CI/CD workflow
├── ssh-keys/                     # Example SSH keys directory
│   └── README.md
├── Dockerfile                    # Main Docker image definition
├── entrypoint.sh                # Main container script
├── docker-compose.yml           # Production compose file
├── docker-compose.example.yml   # Example with test containers
├── test.sh                      # Test script
├── README.md                    # Main documentation
├── TARGET_SETUP.md              # Guide for setting up target containers
└── CONTRIBUTING.md              # This file
```

## Testing Guidelines

### Manual Testing

1. **Basic functionality**: Container can discover and list other containers
2. **SSH connection**: Can successfully SSH into target containers
3. **Error handling**: Properly handles missing SSH keys, no containers, etc.
4. **Docker Swarm mode**: Works in both Swarm and standalone mode
5. **Different networks**: Works with bridge and overlay networks

### Automated Testing

The project includes a test script (`test.sh`) that validates:
- File existence and structure
- Script syntax
- Docker build (when possible)

## Documentation

When making changes, update relevant documentation:

- **README.md**: For user-facing features
- **TARGET_SETUP.md**: For target container setup changes
- **Code comments**: For complex logic
- **CHANGELOG**: Add entry for notable changes

## Release Process

Releases are automated via GitHub Actions:

1. Update version numbers if applicable
2. Update CHANGELOG.md
3. Create and push a git tag: `git tag -a v1.0.0 -m "Release v1.0.0"`
4. GitHub Actions will build and publish to Docker Hub
5. A GitHub Release will be created automatically

## Getting Help

- **Issues**: Open an issue for bugs or questions
- **Discussions**: Use GitHub Discussions for general questions
- **Pull Requests**: Ask questions in PR comments

## Recognition

Contributors will be recognized in:
- GitHub contributors list
- Release notes for significant contributions
- README.md (for major features)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Don't hesitate to ask! Open an issue or discussion if you need help.

Thank you for contributing to Swarm-SSH! 🎉
