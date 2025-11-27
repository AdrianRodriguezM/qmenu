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
# QMENU - VM Library (TUI Modern Edition)
# ==========================================

vm_library() {

    # -----------------------------
    # SELECT VM
    # -----------------------------
    gum style --border double --padding "1 2" \
        --border-foreground 33 \
        "V M   L I B R A R Y"

    VM=$(list_qcow2 | gum filter --placeholder "Select VM...")
    [[ -z "$VM" ]] && { gum style --foreground 196 "No VM selected."; return; }

    # -----------------------------
    # VM INFO PANEL
    # -----------------------------
    DISK_SIZE=$(qemu-img info "$VM" | grep "virtual size" | sed 's/virtual size: //')
    BACKING=$(detect_backing "$VM")
    SNAPSHOTS=$(detect_snapshots "$VM" | wc -l)

    INFO=$(cat <<EOF
VM:            $(basename "$VM")
Path:          $VM
Disk size:     $DISK_SIZE
Snapshots:     $SNAPSHOTS
Backing file:  ${BACKING:-None}
EOF
)

    gum style --border normal --padding "1 2" --border-foreground 240 "$INFO"

    # -----------------------------
    # ACTION MENU
    # -----------------------------
    ACTION=$(gum choose \
        "Start VM" \
        "Start in snapshot mode" \
        "List snapshots" \
        "Create snapshot" \
        "Delete snapshot" \
        "Disk info" \
        "Back")

    case "$ACTION" in

        "Start VM")
            qemu-system-x86_64 \
                -machine "$DEFAULT_MACHINE" \
                -cpu "$DEFAULT_CPU" \
                -smp "$DEFAULT_CPUS" \
                -m "$DEFAULT_RAM" \
                -device virtio-scsi-pci,id=scsi0 \
                -drive file="$VM",format=qcow2,if=none,id=drive-scsi-disk0 \
                -device scsi-hd,drive=drive-scsi-disk0,bus=scsi0.0 \
                -display "$DEFAULT_DISPLAY" \
                -nic "$DEFAULT_NIC"
            ;;

        "Start in snapshot mode")
            qemu-system-x86_64 -snapshot \
                -machine "$DEFAULT_MACHINE" \
                -cpu "$DEFAULT_CPU" \
                -smp "$DEFAULT_CPUS" \
                -m "$DEFAULT_RAM" \
                -drive file="$VM",format=qcow2,if=none,id=drive-scsi-disk0 \
                -device virtio-scsi-pci,id=scsi0 \
                -device scsi-hd,drive=drive-scsi-disk0,bus=scsi0.0 \
                -display "$DEFAULT_DISPLAY" \
                -nic "$DEFAULT_NIC"
            ;;

        "List snapshots")
            detect_snapshots "$VM" | gum style --border normal --padding "1 2"
            pause
            ;;

        "Create snapshot")
            NAME=$(gum input --placeholder "Snapshot name (leave empty for auto)")
            [[ -z "$NAME" ]] && NAME="${SNAPSHOT_PREFIX}$(date +%s)"

            gum spin --spinner pulse --title "Creating snapshot..." -- \
                qemu-img snapshot -c "$NAME" "$VM"

            gum style --foreground 46 "Snapshot created: $NAME"
            pause
            ;;

        "Delete snapshot")
            SNAP=$(detect_snapshots "$VM" | gum filter --placeholder "Select snapshot to delete...")
            [[ -z "$SNAP" ]] && { gum style --foreground 196 "No snapshot selected."; return; }

            gum confirm "Delete snapshot: $SNAP ?" || return

            gum spin --spinner monkey --title "Deleting snapshot..." -- \
                qemu-img snapshot -d "$SNAP" "$VM"

            gum style --foreground 196 "Snapshot deleted: $SNAP"
            pause
            ;;

        "Disk info")
            qemu-img info "$VM" | gum style --border normal --padding "1 2"
            pause
            ;;

        "Back") return ;;
    esac
}

