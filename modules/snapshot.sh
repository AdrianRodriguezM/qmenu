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
# QMENU - Snapshot Manager (TUI Modern Edition)
# ==========================================


snapshot_manager() {

    gum style --border double --padding "1 2" --border-foreground 212 \
        "SNAPSHOT MANAGER"

    VM=$(list_qcow2 | gum filter --placeholder "Select VM...")
    [[ -z "$VM" ]] && { gum style --foreground 196 "No VM selected."; return; }

    ACTION=$(gum choose \
        "List snapshots" \
        "Create snapshot" \
        "Apply snapshot" \
        "Delete snapshot" \
        "Back")

    case "$ACTION" in
        "List snapshots") snapshot_list_tui "$VM" ;;
        "Create snapshot") snapshot_create_tui "$VM" ;;
        "Apply snapshot") snapshot_apply_tui "$VM" ;;
        "Delete snapshot") snapshot_delete_tui "$VM" ;;
        "Back") return ;;
    esac
}


# LIST
snapshot_list_tui() {
    VM="$1"
    gum style --border double --padding "1 2" --border-foreground 212 \
        "Snapshots in: $VM"

    detect_snapshots "$VM" | gum style --padding "1 2"
    pause
}


# CREATE
snapshot_create_tui() {
    VM="$1"

    NAME=$(gum input --placeholder "Snapshot name")
    [[ -z "$NAME" ]] && NAME="${SNAPSHOT_PREFIX}$(date +%s)"

    gum spin --spinner pulse --title "Creating snapshot..." -- \
        qemu-img snapshot -c "$NAME" "$VM"

    gum style --foreground 46 "Snapshot created: $NAME"
    pause
}


# APPLY
snapshot_apply_tui() {
    VM="$1"

    SNAP=$(detect_snapshots "$VM" | gum filter --placeholder "Select snapshot")
    [[ -z "$SNAP" ]] && { gum style --foreground 196 "No snapshot selected."; return; }

    gum confirm "Apply '$SNAP' ?" || return

    gum spin --spinner globe --title "Applying snapshot..." -- \
        qemu-img snapshot -a "$SNAP" "$VM"

    gum style --foreground 46 "Snapshot applied."
    pause
}


# DELETE
snapshot_delete_tui() {
    VM="$1"

    SNAP=$(detect_snapshots "$VM" | gum filter --placeholder "Select snapshot")
    [[ -z "$SNAP" ]] && { gum style --foreground 196 "No snapshot selected."; return; }

    gum confirm "Delete '$SNAP' ?" || return

    gum spin --spinner line --title "Deleting snapshot..." -- \
        qemu-img snapshot -d "$SNAP" "$VM"

    gum style --foreground 196 "Snapshot deleted."
    pause
}
