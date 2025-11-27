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
# QMENU - Advanced Options / System Info
# ==========================================

advanced_options() {
    while true; do
        clear
        gum style --border double --padding "1 2" \
            --border-foreground 135 \
            "A D V A N C E D   O P T I O N S"

        choice=$(gum choose \
            "Host info (CPU / RAM / virtualization)" \
            "KVM / virtualization support" \
            "QEMU & tools versions" \
            "Show QMENU runtime config" \
            "Reset QMENU runtime defaults" \
            "Debug: CPU flags (/proc/cpuinfo)" \
            "Back")

        case "$choice" in
            "Host info (CPU / RAM / virtualization)")
                adv_host_info
                ;;

            "KVM / virtualization support")
                adv_kvm_info
                ;;

            "QEMU & tools versions")
                adv_versions
                ;;

            "Show QMENU runtime config")
                adv_show_qmenu_config
                ;;

            "Reset QMENU runtime defaults")
                adv_reset_runtime_defaults
                ;;

            "Debug: CPU flags (/proc/cpuinfo)")
                adv_cpu_flags
                ;;

            "Back")
                break
                ;;
        esac
    done
}

# -----------------------------
# Host info: CPU, RAM, virtualización
# -----------------------------
adv_host_info() {
    CPU_INFO=$(lscpu 2>/dev/null | egrep 'Model name|CPU\(s\)|Thread|Core' || echo "lscpu not available")
    RAM_INFO=$(free -h 2>/dev/null || echo "free not available")
    VIRT_DETECT=$(systemd-detect-virt 2>/dev/null || echo "unknown")

    INFO=$(cat <<EOF
[ CPU ]
$CPU_INFO

[ RAM ]
$RAM_INFO

[ Virtualization detector ]
systemd-detect-virt → $VIRT_DETECT
EOF
)
    echo "$INFO" | gum style --border normal --padding "1 2"
    pause
}

# -----------------------------
# KVM / virtualization support
# -----------------------------
adv_kvm_info() {
    HAS_KVM_DEV="NO"
    [[ -e /dev/kvm ]] && HAS_KVM_DEV="YES"

    KVM_MODULES=$(lsmod 2>/dev/null | grep -E '^kvm' || echo "No kvm modules loaded")
    VIRT_FLAGS=$(grep -m1 -E 'vmx|svm' /proc/cpuinfo 2>/dev/null || echo "No vmx/svm flags detected")

    INFO=$(cat <<EOF
[ /dev/kvm ]
Exists: $HAS_KVM_DEV

[ KVM modules ]
$KVM_MODULES

[ CPU virtualization flags ]
$VIRT_FLAGS
EOF
)
    echo "$INFO" | gum style --border normal --padding "1 2"
    pause
}

# -----------------------------
# QEMU / gum / fzf versions
# -----------------------------
adv_versions() {
    QEMU_SYS=$(qemu-system-x86_64 --version 2>/dev/null | head -n1 || echo "qemu-system-x86_64 not found")
    QEMU_IMG=$(qemu-img --version 2>/dev/null | head -n1 || echo "qemu-img not found")
    GUM_VER=$(gum --version 2>/dev/null || echo "gum not found")
    FZF_VER=$(fzf --version 2>/dev/null || echo "fzf not found")

    INFO=$(cat <<EOF
[ QEMU ]
$QEMU_SYS
$QEMU_IMG

[ TUI tools ]
gum  → $GUM_VER
fzf  → $FZF_VER
EOF
)
    echo "$INFO" | gum style --border normal --padding "1 2"
    pause
}

# -----------------------------
# Show QMENU runtime config
# -----------------------------
adv_show_qmenu_config() {
    INFO=$(cat <<EOF
[ Paths ]
VM_DIR    = $VM_DIR
ISO_DIR   = $ISO_DIR

[ VM defaults ]
DEFAULT_RAM      = $DEFAULT_RAM
DEFAULT_CPUS     = $DEFAULT_CPUS
DEFAULT_MACHINE  = $DEFAULT_MACHINE
DEFAULT_CPU      = $DEFAULT_CPU
DEFAULT_DISPLAY  = $DEFAULT_DISPLAY

[ Network ]
DEFAULT_NIC      = $DEFAULT_NIC

[ Snapshots ]
SNAPSHOT_PREFIX  = $SNAPSHOT_PREFIX
EOF
)
    echo "$INFO" | gum style --border normal --padding "1 2"
    pause
}

# -----------------------------
# Reset QMENU runtime defaults
# (solo para esta sesión)
# -----------------------------
adv_reset_runtime_defaults() {
    gum style --foreground 214 "Resetting QMENU runtime defaults (this session only)..."

    DEFAULT_RAM="4096"
    DEFAULT_CPUS="4"
    DEFAULT_MACHINE="q35,accel=kvm"
    DEFAULT_CPU="host"
    DEFAULT_DISPLAY="gtk,gl=on"
    DEFAULT_NIC="user,model=virtio-net-pci"

    adv_show_qmenu_config
}

# -----------------------------
# Debug CPU flags
# -----------------------------
adv_cpu_flags() {
    FLAGS_LINE=$(grep -m1 '^flags' /proc/cpuinfo 2>/dev/null || echo "No flags line found in /proc/cpuinfo")
    echo "$FLAGS_LINE" | fold -s -w 80 | gum style --border normal --padding "1 2"
    pause
}
