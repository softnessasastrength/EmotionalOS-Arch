# EmotionalOS Arch

An Arch Linux–based EmotionalOS edition featuring KDE Plasma, a calm TUI installer, Healing Suite integration, privacy-first defaults, and a minimal, human-centered desktop experience.

## Included in the proof of concept

- Arch Linux live environment built with the maintained ArchISO `releng` profile
- KDE Plasma, SDDM, NetworkManager, PipeWire, Dolphin, and Konsole
- LibreOffice and Okular
- `yay`, built from its upstream source as an unprivileged user
- EmotionalOS Healing Suite imported from its independent repository
- a calm `curses` frontend that launches Arch Linux's maintained `archinstall` installer
- BIOS/UEFI boot configuration inherited from upstream ArchISO
- QEMU test tooling
- CI capable of building and uploading the ISO as an artifact

## Build

Use an up-to-date Arch Linux x86_64 machine or VM:

```bash
sudo pacman -Syu --needed archiso rsync qemu-desktop edk2-ovmf git make python
make check
sudo make build
make test
```

The image and checksum are written to `build/out/`.

## Live commands

```bash
sudo emotionalos-install
healing_tui
yay --version
```

## Safety and status

This repository provides a complete first-cut image build path, but the resulting ISO must still complete a real QEMU installation test before being described as production-ready. The installer delegates disk operations to `archinstall`; review every storage selection carefully and test only against disposable virtual disks first.

See [docs/BUILDING.md](docs/BUILDING.md) for local, QEMU, and AWS guidance.
