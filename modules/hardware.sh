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

# Hardware Settings module for QMENU

HARDWARE_CONFIG_FILE="$CONFIG_DIR/defaults.conf"

hardware_update_key() {
    local key="$1"
    local value="$2"
    local file="$HARDWARE_CONFIG_FILE"

    if grep -q "^$key=" "$file"; then
        # Reemplaza la línea existente
        sed -i "s|^$key=.*|$key=\"$value\"|" "$file"
    else
        # Añade al final si no existe
        echo "$key=\"$value\"" >> "$file"
    fi

    # Actualiza también en la sesión actual
    eval "$key=\"$value\""
}

hardware_show_profile() {
    clear
    gum style \
        --border rounded \
        --padding "1 2" \
        --margin "1 0" \
        --border-foreground "$C_TITLE" \
"Current hardware profile:

  Machine type : ${QMENU_MACHINE:-q35,accel=kvm}
  CPU model    : ${QMENU_CPU_MODEL:-host}
  CPU cores    : ${QMENU_CORES:-4}
  RAM (MiB)    : ${QMENU_RAM_MB:-4096}"

    gum confirm "Back to Hardware Settings menu?" --default=true >/dev/null 2>&1 || true
}

hardware_set_cpu_cores() {
    # CPU model
    local cpu_choice
    cpu_choice=$(gum choose \
        "host (recommended)" \
        "max" \
        "qemu64" \
        "Custom…") || return

    local cpu_value
    case "$cpu_choice" in
        "host (recommended)") cpu_value="host" ;;
        "max") cpu_value="max" ;;
        "qemu64") cpu_value="qemu64" ;;
        "Custom…")
            cpu_value=$(gum input --placeholder "Enter CPU model (e.g. Skylake-Client)" --value "${QMENU_CPU_MODEL:-host}")
            [[ -z "$cpu_value" ]] && return
            ;;
    esac

    hardware_update_key "QMENU_CPU_MODEL" "$cpu_value"

    # Cores
    local cores
    cores=$(gum input --placeholder "Number of cores" --value "${QMENU_CORES:-4}") || return
    if ! [[ "$cores" =~ ^[0-9]+$ ]] || [[ "$cores" -lt 1 ]]; then
        gum style --foreground "$C_ERR" "Invalid core count."
        sleep 1
        return
    fi

    hardware_update_key "QMENU_CORES" "$cores"

    gum style --foreground "$C_OK" "CPU model and cores updated."
    sleep 1
}

hardware_set_ram() {
    local ram
    ram=$(gum input --placeholder "RAM in MiB (e.g. 4096)" --value "${QMENU_RAM_MB:-4096}") || return

    if ! [[ "$ram" =~ ^[0-9]+$ ]] || [[ "$ram" -lt 256 ]]; then
        gum style --foreground "$C_ERR" "Invalid RAM value (minimum 256 MiB)."
        sleep 1
        return
    fi

    hardware_update_key "QMENU_RAM_MB" "$ram"

    gum style --foreground "$C_OK" "RAM updated to ${ram} MiB."
    sleep 1
}

hardware_set_machine() {
    local choice
    choice=$(gum choose \
        "q35 (modern default)" \
        "pc (legacy)") || return

    local machine_value
    case "$choice" in
        "q35 (modern default)") machine_value="q35,accel=kvm" ;;
        "pc (legacy)") machine_value="pc,accel=kvm" ;;
    esac

    hardware_update_key "QMENU_MACHINE" "$machine_value"

    gum style --foreground "$C_OK" "Machine type updated to: $machine_value"
    sleep 1
}

hardware_reset_defaults() {
    hardware_update_key "QMENU_MACHINE" "q35,accel=kvm"
    hardware_update_key "QMENU_CPU_MODEL" "host"
    hardware_update_key "QMENU_CORES" "4"
    hardware_update_key "QMENU_RAM_MB" "4096"

    gum style --foreground "$C_OK" "Hardware profile reset to QMENU defaults."
    sleep 1
}

hardware_settings() {
    while true; do
        clear
        gum style \
            --border double \
            --align center \
            --padding "1 2" \
            --margin "1 0" \
            --border-foreground "$C_TITLE" \
"H A R D W A R E   S E T T I N G S"

        gum style \
            --margin "0 0 1 0" \
"Current:
  Machine : ${QMENU_MACHINE:-q35,accel=kvm}
  CPU     : ${QMENU_CPU_MODEL:-host}
  Cores   : ${QMENU_CORES:-4}
  RAM     : ${QMENU_RAM_MB:-4096} MiB"

        local choice
        choice=$(gum choose \
            "Show current hardware profile" \
            "Set CPU model & cores" \
            "Set RAM" \
            "Set machine type" \
            "Reset to QMENU defaults" \
            "Back") || return

        case "$choice" in
            "Show current hardware profile") hardware_show_profile ;;
            "Set CPU model & cores") hardware_set_cpu_cores ;;
            "Set RAM") hardware_set_ram ;;
            "Set machine type") hardware_set_machine ;;
            "Reset to QMENU defaults") hardware_reset_defaults ;;
            "Back") return ;;
        esac
    done
}
