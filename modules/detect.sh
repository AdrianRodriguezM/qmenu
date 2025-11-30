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

# ====================================================
# QMENU - Detection module
# Detect qcow2 disks, ISOs, snapshots and capabilities
# ====================================================



check_kvm() {
    if [[ -e /dev/kvm ]]; then
        echo "KVM: available"
    else
        echo "KVM: NOT available (QEMU will use TCG)"
    fi
}


list_qcow2() {
    find "$VM_DIR" -maxdepth 1 -type f -name "*.qcow2" 2>/dev/null
}


list_isos() {
    find "$ISO_DIR" -maxdepth 1 -type f -name "*.iso" 2>/dev/null
}


detect_snapshots() {
    local disk="$1"
    qemu-img snapshot -l "$disk" 2>/dev/null \
        | sed '1,2d' \
        | awk '{print $2}'
}
