# SFK CLI

**Your Agent gets a Laptop in the Cloud**

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/starfolkai/cli/main/install.sh | sh
```

## Platforms

| Platform | Architecture |
|----------|--------------|
| Linux | x86_64, ARM64 |
| macOS | x86_64 (Intel), ARM64 (Apple Silicon) |

## Usage

```bash
# Authenticate with GitHub
sfk auth login

# Create a new devbox
sfk devbox new my-project

# Connect to your devbox
sfk devbox connect my-project

# List all devboxes
sfk devbox list

# Destroy a devbox
sfk devbox destroy my-project
```

## Documentation

Visit [starfolk.ai](https://starfolk.ai) for full documentation.
