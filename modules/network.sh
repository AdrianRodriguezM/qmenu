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



#!/bin/bash

# ==========================================
# QMENU - Network Settings (TUI Modern Edition)
# Includes: BRIDGED MODE (ADVANCED)
# ==========================================

network_settings() {

    gum style --border double --padding "1 2" \
        --border-foreground 39 \
        "N E T W O R K   S E T T I N G S"

    gum style --foreground 33 "Current NIC:"
    gum style --border normal --padding "1 2" "$DEFAULT_NIC"

    MODE=$(gum choose \
        "NAT (Default)" \
        "NAT + SSH port forward (2222 → 22)" \
        "Isolated (no network)" \
        "Intel e1000 (compatibility mode)" \
        "Virtio high-performance" \
        "Bridge mode (ADVANCED)" \
        "Reset to QMENU defaults" \
        "Back")

    case "$MODE" in

# ------------------------------------------------------------
# NAT DEFAULT
# ------------------------------------------------------------
        "NAT (Default)")
            DEFAULT_NIC="user,model=virtio-net-pci"
            gum style --foreground 46 "NIC set to: NAT (virtio)"
            ;;

# ------------------------------------------------------------
# NAT WITH SSH FORWARD
# ------------------------------------------------------------
        "NAT + SSH port forward (2222 → 22)")
            DEFAULT_NIC="user,model=virtio-net-pci,hostfwd=tcp::2222-:22"
            gum style --foreground 46 "NIC: NAT + SSH forward enabled"
            ;;

# ------------------------------------------------------------
# ISOLATED
# ------------------------------------------------------------
        "Isolated (no network)")
            DEFAULT_NIC="none"
            gum style --foreground 214 "NIC set to isolated mode"
            ;;

# ------------------------------------------------------------
# INTEL e1000
# ------------------------------------------------------------
        "Intel e1000 (compatibility mode)")
            DEFAULT_NIC="user,model=e1000"
            gum style --foreground 46 "NIC set to Intel e1000"
            ;;

# ------------------------------------------------------------
# VIRTIO PERFORMANCE
# ------------------------------------------------------------
        "Virtio high-performance")
            DEFAULT_NIC="user,model=virtio-net-pci"
            gum style --foreground 46 "NIC set to virtio high-performance"
            ;;

# ------------------------------------------------------------
# BRIDGED MODE (ADVANCED)
# ------------------------------------------------------------
        "Bridge mode (ADVANCED)")
            bridged_mode_setup
            ;;

# ------------------------------------------------------------
# RESET DEFAULTS
# ------------------------------------------------------------
        "Reset to QMENU defaults")
            DEFAULT_NIC="user,model=virtio-net-pci"
            gum style --foreground 46 "NIC reset to defaults"
            ;;

        "Back") return ;;
    esac

    pause
}


# ============================================================
#     BRIDGE MODE SETUP — ADVANCED
# ============================================================

bridged_mode_setup() {

    gum style --border double --padding "1 2" \
        --border-foreground 207 \
        "BRIDGE MODE (ADVANCED)"

    # ------------------------------------------------------------
    # Check if br0 exists
    # ------------------------------------------------------------
    if ! ip link show br0 &>/dev/null; then
        gum style --foreground 196 "ERROR: br0 not found."
        gum style --foreground 214 "You must create a bridge first:"
        echo ""
        echo "sudo ip link add name br0 type bridge"
        echo "sudo ip link set br0 up"
        echo "sudo ip link set eno1 master br0"
        echo ""
        pause
        return
    fi

    # ------------------------------------------------------------
    # Warn if on WiFi (bridging limited)
    # ------------------------------------------------------------
    ACTIVE_IFACE=$(ip route | grep default | awk '{print $5}')
    if [[ "$ACTIVE_IFACE" =~ wlan* ]]; then
        gum style --foreground 214 "WARNING: Bridged mode on WiFi may not work."
    fi

    # ------------------------------------------------------------
    # TAP DEVICE SETUP (smart handling)
    # ------------------------------------------------------------
    if ip link show tap0 &>/dev/null; then
        gum style --foreground 178 "tap0 already exists — reusing it."
    else
        gum style --foreground 33 "Creating tap0…"
        if ! sudo ip tuntap add dev tap0 mode tap user "$USER" 2>/dev/null; then
            gum style --foreground 196 "ERROR: Cannot create TAP device."
            gum style --foreground 214 "Fix with:"
            echo "sudo ip tuntap add dev tap0 mode tap user $USER"
            pause
            return
        fi
    fi

    # ------------------------------------------------------------
    # Bring interface up + attach to br0
    # ------------------------------------------------------------
    sudo ip link set tap0 up
    sudo brctl addif br0 tap0

    gum style --foreground 46 "tap0 is UP and attached to br0."

    # ------------------------------------------------------------
    # Apply QMENU NIC setting
    # ------------------------------------------------------------
    DEFAULT_NIC="tap,ifname=tap0,script=no,downscript=no"

    gum style --border normal --padding "1 2" \
        --foreground 46 \
        "Bridge mode enabled successfully!"
    gum style --padding "1 2" "$DEFAULT_NIC"
}
