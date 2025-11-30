# QMENU - QEMU Terminal Manager
# Copyright (C) 2025  Adrián
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


#!/usr/bin/env bash
set -e

echo "=========================================="
echo "      Q M E N U   I N S T A L L E R"
echo "=========================================="


# ------------------------------------------
# Detect distro
# ------------------------------------------
detect_distro() {
    if command -v apt >/dev/null 2>&1; then
        DISTRO="debian"
    elif command -v pacman >/dev/null 2>&1; then
        DISTRO="arch"
    elif command -v dnf >/dev/null 2>&1; then
        DISTRO="fedora"
    else
        DISTRO="unknown"
    fi
}

detect_distro
echo "Detected distro: $DISTRO"


# ------------------------------------------
# Install dependencies
# ------------------------------------------
install_deps() {
    echo "[1/5] Installing QMENU dependencies..."

    case "$DISTRO" in
        debian)
            sudo apt install -y qemu-system-x86 qemu-utils fzf bridge-utils iproute2 || true
            ;;
        arch)
            sudo pacman -Sy --noconfirm qemu qemu-img fzf bridge-utils iproute2 || true
            ;;
        fedora)
            sudo dnf install -y qemu qemu-img fzf bridge-utils iproute || true
            ;;
    esac

    echo "Dependencies installed."
}


# ------------------------------------------
# Create user directories (standard Linux path)
# ------------------------------------------
setup_dirs() {
    echo "[2/5] Creating QMENU directories..."

    mkdir -p "$HOME/.local/share/qmenu/vms"
    mkdir -p "$HOME/.local/share/qmenu/isos"
    mkdir -p "$HOME/.local/share/qmenu/logs"
    mkdir -p "$HOME/.config/qmenu"

    echo "Directories ready ✔"
}


# ------------------------------------------
# Copy project into /opt/qmenu
# ------------------------------------------
install_qmenu() {
    echo "[3/5] Copying QMENU into /opt/qmenu..."

    sudo rm -rf /opt/qmenu 2>/dev/null || true
    sudo mkdir -p /opt/qmenu

    # Copy entire repo
    sudo rsync -av . /opt/qmenu/ >/dev/null

    # Copy default config to user
    cp config/defaults.conf "$HOME/.config/qmenu/defaults.conf"

    echo "QMENU copied to /opt/qmenu ✔"
}


# ------------------------------------------
# Install Gum (from embedded gum.b64)
# ------------------------------------------
install_gum() {
    echo "[4/5] Installing Gum (offline/local)..."

    if command -v gum >/dev/null 2>&1; then
        echo "gum already installed ✔"
        return
    fi

    if [[ ! -f "/opt/qmenu/helpers/gum.b64" ]]; then
        echo "ERROR: /opt/qmenu/helpers/gum.b64 not found!"
        exit 1
    fi

    base64 -d /opt/qmenu/helpers/gum.b64 > gum
    sudo mv gum /usr/local/bin/gum
    sudo chmod 755 /usr/local/bin/gum

    echo "Gum installed successfully ✔"
}


# ------------------------------------------
# Register global command
# ------------------------------------------
register_command() {
    echo "[5/5] Creating global 'qmenu' command..."

    sudo rm -f /usr/local/bin/qmenu 2>/dev/null || true

    sudo bash -c 'cat << EOF > /usr/local/bin/qmenu
#!/bin/bash
exec /opt/qmenu/main.sh "\$@"
EOF'

    sudo chmod 755 /usr/local/bin/qmenu

    echo "'qmenu' command registered ✔"
}


# ------------------------------------------
# RUN INSTALLER
# ------------------------------------------
install_deps
setup_dirs
install_qmenu
install_gum
register_command

echo ""
echo "=========================================="
echo " QMENU successfully installed! 🎉"
echo "=========================================="
echo ""
echo "Run it with:"
echo "   qmenu"
echo ""
echo "VMs directory:   ~/.local/share/qmenu/vms"
echo "ISOs directory:  ~/.local/share/qmenu/isos"
echo "Logs directory:  ~/.local/share/qmenu/logs"
echo "Config file:     ~/.config/qmenu/defaults.conf"
echo ""
echo "Enjoy! 🚀"
