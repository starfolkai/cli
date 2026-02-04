#!/bin/sh
set -e

# SFK CLI Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/starfolkai/cli/main/install.sh | sh

REPO="starfolkai/cli"
BINARY_NAME="sfk"
INSTALL_DIR="${SFK_INSTALL_DIR:-$HOME/.local/bin}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { printf "${GREEN}info${NC}: %s\n" "$1"; }
warn() { printf "${YELLOW}warn${NC}: %s\n" "$1"; }
error() { printf "${RED}error${NC}: %s\n" "$1" >&2; exit 1; }

detect_platform() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)

    case "$OS" in
        linux) OS="linux" ;;
        darwin) OS="darwin" ;;
        *) error "Unsupported OS: $OS" ;;
    esac

    case "$ARCH" in
        x86_64|amd64) ARCH="x86_64" ;;
        aarch64|arm64) ARCH="aarch64" ;;
        *) error "Unsupported architecture: $ARCH" ;;
    esac

    PLATFORM="${BINARY_NAME}-${OS}-${ARCH}"
}

get_latest_version() {
    # Try API first (may fail due to rate limiting)
    VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" 2>/dev/null | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

    # If API fails, use GitHub's redirect to get version from Location header
    if [ -z "$VERSION" ]; then
        VERSION=$(curl -sI "https://github.com/${REPO}/releases/latest" 2>/dev/null | grep -i '^location:' | sed -E 's|.*/tag/([^[:space:]]+).*|\1|')
    fi

    if [ -z "$VERSION" ]; then
        error "Could not determine latest version. Check https://github.com/${REPO}/releases"
    fi
}

download_and_install() {
    DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${PLATFORM}.tar.gz"

    info "Downloading SFK CLI ${VERSION} for ${OS}/${ARCH}..."

    TMPDIR=$(mktemp -d)
    trap "rm -rf $TMPDIR" EXIT

    curl -fsSL "$DOWNLOAD_URL" -o "$TMPDIR/sfk.tar.gz"
    tar -xzf "$TMPDIR/sfk.tar.gz" -C "$TMPDIR"

    info "Installing to ${INSTALL_DIR}..."
    mkdir -p "$INSTALL_DIR"
    mv "$TMPDIR/$PLATFORM" "$INSTALL_DIR/$BINARY_NAME"
    chmod +x "$INSTALL_DIR/$BINARY_NAME"
}

check_path() {
    case ":$PATH:" in
        *":$INSTALL_DIR:"*) return 0 ;;
    esac
    return 1
}

path_instructions() {
    SHELL_NAME=$(basename "$SHELL")
    case "$SHELL_NAME" in
        bash) RC_FILE="$HOME/.bashrc" ;;
        zsh) RC_FILE="$HOME/.zshrc" ;;
        fish) RC_FILE="$HOME/.config/fish/config.fish" ;;
        *) RC_FILE="your shell rc file" ;;
    esac

    warn "$INSTALL_DIR is not in your PATH"
    echo ""
    echo "Add it by running:"
    echo ""
    if [ "$SHELL_NAME" = "fish" ]; then
        echo "  fish_add_path $INSTALL_DIR"
    else
        echo "  echo 'export PATH=\"\$PATH:$INSTALL_DIR\"' >> $RC_FILE"
    fi
    echo ""
    echo "Then restart your shell or run: source $RC_FILE"
}

main() {
    echo ""
    echo "  ███████╗███████╗██╗  ██╗"
    echo "  ██╔════╝██╔════╝██║ ██╔╝"
    echo "  ███████╗█████╗  █████╔╝ "
    echo "  ╚════██║██╔══╝  ██╔═██╗ "
    echo "  ███████║██║     ██║  ██╗"
    echo "  ╚══════╝╚═╝     ╚═╝  ╚═╝"
    echo ""
    echo "  Your Agent gets a Laptop in the Cloud"
    echo ""

    detect_platform
    get_latest_version
    download_and_install

    echo ""
    printf "${GREEN}Successfully installed SFK CLI ${VERSION}!${NC}\n"
    echo ""

    if ! check_path; then
        path_instructions
    else
        echo "Run 'sfk --help' to get started."
    fi
    echo ""
}

main
