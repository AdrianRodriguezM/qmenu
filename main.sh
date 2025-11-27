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
# QMENU - QEMU Terminal Manager (TUI Edition)
# Main controller script
# ==========================================

# Paths
CONFIG_DIR="$(dirname "$0")/config"
MODULE_DIR="$(dirname "$0")/modules"
HELPER_DIR="$(dirname "$0")/helpers"

# Load config
source "$CONFIG_DIR/defaults.conf"

# Load helpers
source "$HELPER_DIR/colors.sh"
source "$HELPER_DIR/menu_utils.sh"
source "$HELPER_DIR/log.sh"
source "$HELPER_DIR/validate.sh"

# Load modules
source "$MODULE_DIR/disk.sh"
source "$MODULE_DIR/vm_start.sh"
source "$MODULE_DIR/vm_list.sh"
source "$MODULE_DIR/snapshot.sh"
source "$MODULE_DIR/network.sh"
source "$MODULE_DIR/detect.sh"
source "$MODULE_DIR/tui.sh"
source "$MODULE_DIR/vm_wizard.sh"
source "$MODULE_DIR/advanced.sh"
source "$MODULE_DIR/hardware.sh"

# ------------------------------------------
# MAIN MENU (GUM TUI)
# ------------------------------------------
while true; do
    clear

    gum style \
        --border double \
        --align center \
        --padding "1 4" \
        --margin "1 0" \
        --border-foreground "$C_TITLE" \
"Q M E N U              
QEMU Terminal Manager    
created by Adrián       "

    choice=$(gum choose \
        "Create VM" \
        "Create disk image" \
        "Start existing VM" \
        "VM Library" \
        "Snapshot Manager" \
        "Network Settings" \
        "Hardware Settings" \
        "Advanced Options" \
        "Exit")

    case "$choice" in
        "Create VM") vm_wizard ;;      
        "Create disk image") create_disk ;;
        "Start existing VM") start_vm ;;
        "VM Library") vm_library ;;
        "Snapshot Manager") snapshot_manager ;;
        "Network Settings") network_settings ;;
        "Hardware Settings") hardware_settings ;;
        "Advanced Options") advanced_options ;;
        "Exit") exit 0 ;;
        *) echo "Invalid option"; sleep 1 ;;
    esac
done
