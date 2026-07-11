# Building EmotionalOS Arch

## Supported build host

Use an up-to-date Arch Linux x86_64 host or VM. The build requires root because `mkarchiso` creates chroots and mounts filesystems.

```bash
sudo pacman -Syu --needed archiso rsync qemu-desktop edk2-ovmf git make python
make check
sudo make build
make test
```

The ISO and SHA-256 checksum are written under `build/out/`.

## Acceptance test

A candidate image is not shippable until it has been tested in a disposable VM:

1. Boot the ISO in UEFI mode when possible.
2. Confirm the Plasma live session starts automatically.
3. Confirm networking works.
4. Run `yay --version`.
5. Run `healing_tui`.
6. Launch `sudo emotionalos-install`.
7. Install to the 40 GB disposable QEMU disk.
8. Reboot from that disk and verify Plasma, SDDM, networking, audio, LibreOffice, and Okular.

## AWS

AWS EC2 does not normally boot an ISO directly. Build and test the ISO first, then install it into a raw or QCOW2 disk image in QEMU. Convert the installed disk to a supported import format and use AWS VM Import/Export or an image-building pipeline to produce an AMI. Do not upload an untested ISO and expect EC2 to boot it as installation media.

## Reproducibility notes

Arch is rolling release software. A build made on a later date may contain newer packages even from the same Git commit. Release candidates should record:

- repository commit SHA;
- Arch package database date;
- resulting ISO SHA-256;
- `yay` ref;
- Healing Suite ref;
- QEMU acceptance-test results.
