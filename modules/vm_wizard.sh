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
# QMENU - Create VM (Guided Steps)
# ==========================================

vm_wizard() {

    # ===== Step 1: ISO =====
    gum style --border double --padding "1 2" --border-foreground 33 \
        "CREATE VM  •  Step 1/6" \
        "Select installation ISO"

    ISO=$(list_isos | gum filter --placeholder "Choose ISO...")
    [[ -z "$ISO" ]] && { gum style --foreground 196 "No ISO selected."; return; }


    # ===== Step 2: Name =====
    gum style --border double --padding "1 2" --border-foreground 33 \
        "CREATE VM  •  Step 2/6" \
        "Enter VM name"

    NAME=$(gum input --placeholder "Example: kali-test")
    [[ -z "$NAME" ]] && { gum style --foreground 196 "Name cannot be empty."; return; }

    DISK="$VM_DIR/${NAME}.qcow2"


    # ===== Step 3: RAM =====
    gum style --border double --padding "1 2" --border-foreground 33 \
        "CREATE VM  •  Step 3/6" \
        "Enter RAM (MB)"

    RAM=$(gum input --placeholder "Default: ${QMENU_RAM_MB}")
    RAM=${RAM:-$QMENU_RAM_MB}


    # ===== Step 4: CPUs =====
    gum style --border double --padding "1 2" --border-foreground 33 \
        "CREATE VM  •  Step 4/6" \
        "Number of CPUs"

    CPUS=$(gum input --placeholder "Default: ${QMENU_CORES}")
    CPUS=${CPUS:-$QMENU_CORES}


    # ===== Step 5: Disk size =====
    gum style --border double --padding "1 2" --border-foreground 33 \
        "CREATE VM  •  Step 5/6" \
        "Disk size"

    SIZE=$(gum input --placeholder "Example: 20G")
    [[ -z "$SIZE" ]] && { gum style --foreground 196 "Disk size required."; return; }


    # ===== Step 6: Summary =====
    SUMMARY=$(cat <<EOF
ISO:        $ISO
Name:       $NAME
RAM:        $RAM MB
CPUs:       $CPUS
Disk:       $SIZE → $DISK
Machine:    $QMENU_MACHINE
CPU model:  $QMENU_CPU_MODEL
EOF
)

    gum style --border double --padding "1 2" --border-foreground 212 \
        "CREATE VM  •  Step 6/6" \
        "Review settings"

    echo "$SUMMARY" | gum style --foreground 250 --border normal --padding "1 2"
    gum confirm "Create VM with these settings?" || return


    # Create disk
    gum spin --spinner line --title "Creating disk..." -- \
        qemu-img create -f qcow2 "$DISK" "$SIZE"

    gum style --foreground 46 "Disk created."
    gum style --foreground 33 "Launching installer..."


    # ===== Launch installation =====
    qemu-system-x86_64 \
        -machine "$QMENU_MACHINE" \
        -cpu "$QMENU_CPU_MODEL" \
        -smp "$CPUS" \
        -m "$RAM" \
        -device virtio-scsi-pci,id=scsi0 \
        -drive file="$DISK",format=qcow2,if=none,id=drive-scsi-disk0 \
        -device scsi-hd,drive=drive-scsi-disk0,bus=scsi0.0 \
        -cdrom "$ISO" \
        -display "$QMENU_DISPLAY" \
        -nic "$QMENU_NIC"

    gum style --foreground 46 "VM installation finished."
}
