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

create_disk() {
    gum style --foreground 212 --bold "Create new QCOW2 disk image"

    disk=$(gum input --placeholder "Disk name (example: debian.qcow2)")
    [[ -z "$disk" ]] && return

    size=$(gum input --placeholder "Size (example: 20G)")
    [[ -z "$size" ]] && return

    gum spin --spinner line --title "Creating disk..." -- \
        qemu-img create -f qcow2 "$VM_DIR/$disk" "$size"

    gum style --foreground 46 "Disk created at $VM_DIR/$disk"
    pause
}
