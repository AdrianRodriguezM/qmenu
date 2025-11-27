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
# QMENU - VM Start module
# ==========================================

start_vm() {
    gum style --foreground 212 --bold "Start existing VM"

    VM=$(list_qcow2 | fzf --prompt="Select VM > ")
    [[ -z "$VM" ]] && { gum style --foreground 196 "No VM selected."; pause; return; }

    # Override RAM / CPU with defaults unless user specifies
    RAM=$(gum input --placeholder "RAM in MB (default ${QMENU_RAM_MB})")
    RAM=${RAM:-$QMENU_RAM_MB}

    CPUS=$(gum input --placeholder "CPUs (default ${QMENU_CORES})")
    CPUS=${CPUS:-$QMENU_CORES}

    gum style --foreground 33 --bold "Starting VM..."

    qemu-system-x86_64 \
        -machine "$QMENU_MACHINE" \
        -cpu "$QMENU_CPU_MODEL" \
        -smp "$CPUS" \
        -m "$RAM" \
        -device virtio-scsi-pci,id=scsi0 \
        -drive file="$VM",format=qcow2,if=none,id=drive-scsi-disk0 \
        -device scsi-hd,drive=drive-scsi-disk0,bus=scsi0.0 \
        -display "$QMENU_DISPLAY" \
        -nic "$QMENU_NIC"

    pause
}
