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
# QMENU - VM Creation module (virtio-scsi)
# ==========================================

create_vm_from_iso() {
    gum style --foreground 212 --bold "Create VM from ISO"

    # Select ISO
    ISO=$(list_isos | fzf --prompt="Select ISO > ")
    [[ -z "$ISO" ]] && { gum style --foreground 196 "No ISO selected."; pause; return; }

    # VM Name
    NAME=$(gum input --placeholder "VM name (disk will be created)")
    [[ -z "$NAME" ]] && return

    DISK="$VM_DIR/${NAME}.qcow2"

    # Disk size
    SIZE=$(gum input --placeholder "Disk size (e.g. 20G)")
    [[ -z "$SIZE" ]] && return

    # Create disk
    gum spin --spinner pulse --title "Creating disk..." -- \
        qemu-img create -f qcow2 "$DISK" "$SIZE"

    gum style --foreground 46 "Disk created: $DISK"

    # RAM
    RAM=$(gum input --placeholder "RAM in MB (default ${DEFAULT_RAM})")
    RAM=${RAM:-$DEFAULT_RAM}

    # CPUs
    CPUS=$(gum input --placeholder "CPUs (default ${DEFAULT_CPUS})")
    CPUS=${CPUS:-$DEFAULT_CPUS}

    gum style --foreground 33 --bold "Launching installer..."

    # ================================
    # PRO VIRTIO-SCSI TEMPLATE
    # ================================
    qemu-system-x86_64 \
        -machine "$DEFAULT_MACHINE" \
        -cpu "$DEFAULT_CPU" \
        -smp "$CPUS" \
        -m "$RAM" \
        -device virtio-scsi-pci,id=scsi0 \
        -drive file="$DISK",format=qcow2,if=none,id=drive-scsi-disk0 \
        -device scsi-hd,drive=drive-scsi-disk0,bus=scsi0.0 \
        -cdrom "$ISO" \
        -display "$DEFAULT_DISPLAY" \
        -nic "$DEFAULT_NIC"

    gum style --foreground 46 "Installer finished (VM closed)."
    pause
}
