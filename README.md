# QMENU — QEMU Terminal Manager (TUI)

QMENU is a text-based user interface (TUI) that simplifies working with QEMU/KVM.  
It provides a straightforward way to create, manage, and launch virtual machines without memorizing long or complex command lines.

QMENU is written in **Bash**, uses **Gum** for the TUI layer, and aims to be lightweight, modular, and easy to extend.

---

## ✨ Features

- **Step-by-step VM creation wizard**
- **Create qcow2 disk images**
- **Start existing VMs (auto-detect qcow2 files)**
- **VM Library** (scan and list all VMs)
- **Basic snapshot management**
- **Network configuration** (NAT, isolated, bridge, tap, virtio, e1000)
- **Hardware configuration module**
- **Advanced system information panel**
- **Offline installer (includes Gum binary)**

---

## 📦 Requirements

- QEMU + KVM  
- Bash 5+  
- fzf  
- iproute2  
- bridge-utils (for bridge mode)  
- Gum (included in the installer)

Compatible with:

- **Debian / Ubuntu**
- **Arch Linux**
- **Fedora**
- Any Linux distribution with QEMU/KVM support

---

## 🔧 Installation

```bash
git clone https://github.com/YOUR-USERNAME/qmenu
cd qmenu
chmod +x install.sh
./install.sh
```

After installation:

```bash
qmenu
```

---

## 📁 Default directories

QMENU uses the **Linux XDG-standard paths** to store your VM data:

```
~/.local/share/qmenu/vms   → VM disks (.qcow2)
~/.local/share/qmenu/isos  → ISO files for installation
~/.local/share/qmenu/logs  → Log files
~/.config/qmenu            → User configuration (defaults.conf)
```

### 📥 Adding your own ISOs or VMs

To make QMENU auto-detect your files:

- Put **ISO files** in:
  ```
  ~/.local/share/qmenu/isos
  ```

- Put **existing qcow2 VMs** in:
  ```
  ~/.local/share/qmenu/vms
  ```

They will automatically appear in the **VM Library**, **Start VM**, and **Snapshot** menus.

---

## 🖥 Usage

Running `qmenu` opens a full TUI menu with:

- **Create VM**  
- **Create disk image**  
- **Start existing VM**  
- **VM Library**  
- **Snapshot Manager**  
- **Network Settings**  
- **Hardware Settings**  
- **Advanced Options**  
- **Exit**

---

## 🧱 Project structure

```
qmenu/
│
├── main.sh
├── install.sh
├── LICENSE
├── README.md
│
├── modules/
│   ├── vm_wizard.sh
│   ├── vm_start.sh
│   ├── vm_list.sh
│   ├── snapshot.sh
│   ├── network.sh
│   ├── hardware.sh
│   ├── disk.sh
│   ├── detect.sh
│   └── advanced.sh
│
├── helpers/
│   ├── gum.b64
│   ├── colors.sh
│   ├── menu_utils.sh
│   ├── log.sh
│   └── validate.sh
│
└── config/
    └── defaults.conf
```

---

## 🚀 Roadmap (planned)

- Export/import VMs (`.qmenu` bundles)  
- Snapshot trees  
- QEMU log viewer  
- Portable mode  
- VM templates (Debian, Arch, Kali, Windows…)  
- CPU/RAM presets  
- Headless mode profiles  
- Hardware/KVM compatibility checks  

---

## 👤 Author

Developed by **Adrián Rodríguez**

---

## 📄 License

Released under the **GNU General Public License v3.0 (GPL-3.0)**.  
This ensures QMENU and all derivative works remain free and open-source.
