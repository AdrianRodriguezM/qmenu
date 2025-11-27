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
# QMENU - Validation helpers
# ==========================================

validate_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

validate_size() {
    [[ "$1" =~ ^[0-9]+[MG]$ ]]
}

validate_cpu() {
    validate_number "$1"
}

validate_ram() {
    validate_number "$1"
}

validate_qcow2() {
    [[ "$1" == *.qcow2 ]]
}

validate_iso() {
    [[ "$1" == *.iso ]]
}

validate_exists() {
    [[ -f "$1" ]]
}
