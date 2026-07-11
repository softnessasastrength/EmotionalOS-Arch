#!/usr/bin/env bash
set -euo pipefail

bash -n scripts/*.sh
python -m py_compile installer/emotionalos-install
python installer/emotionalos-install --help >/dev/null
for required in archinstall plasma-desktop sddm networkmanager pipewire libreoffice-fresh okular; do
  grep -Fxq "$required" profile/packages.x86_64 || {
    echo "missing required package: $required" >&2
    exit 1
  }
done
grep -q 'Jguer/yay' scripts/customize-airootfs.sh
grep -q 'EmotionalOS-Healing-Suite' scripts/customize-airootfs.sh
echo 'Source checks passed.'
