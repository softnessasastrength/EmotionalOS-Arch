#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo 'error: run with sudo; mkarchiso requires root' >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-${ROOT_DIR}/build}"
PROFILE_DIR="${BUILD_DIR}/profile"
WORK_DIR="${BUILD_DIR}/work"
OUT_DIR="${BUILD_DIR}/out"

for command in mkarchiso rsync pacman; do
  command -v "$command" >/dev/null 2>&1 || {
    echo "error: missing $command; install archiso and rsync on an Arch Linux host" >&2
    exit 1
  }
done

BASE_PROFILE="${ARCHISO_BASE_PROFILE:-/usr/share/archiso/configs/releng}"
[[ -d "$BASE_PROFILE" ]] || { echo "error: releng profile not found: $BASE_PROFILE" >&2; exit 1; }

rm -rf "$PROFILE_DIR" "$WORK_DIR"
mkdir -p "$BUILD_DIR" "$OUT_DIR"
rsync -a "$BASE_PROFILE/" "$PROFILE_DIR/"

# Add EmotionalOS packages without replacing Arch's maintained releng list.
cat "${ROOT_DIR}/profile/packages.x86_64" >> "$PROFILE_DIR/packages.x86_64"
sort -u -o "$PROFILE_DIR/packages.x86_64" "$PROFILE_DIR/packages.x86_64"

rsync -a "${ROOT_DIR}/profile/airootfs/" "$PROFILE_DIR/airootfs/"
install -Dm0755 "${ROOT_DIR}/installer/emotionalos-install" \
  "$PROFILE_DIR/airootfs/usr/local/bin/emotionalos-install"
install -Dm0755 "${ROOT_DIR}/scripts/customize-airootfs.sh" \
  "$PROFILE_DIR/airootfs/root/customize_airootfs.sh"

# Keep the upstream boot modes but apply our identity.
sed -i 's/^iso_name=.*/iso_name="emotionalos-arch"/' "$PROFILE_DIR/profiledef.sh"
sed -i 's/^iso_label=.*/iso_label="EMOTIONALOS_ARCH_$(date +%Y%m)"/' "$PROFILE_DIR/profiledef.sh"
sed -i 's/^iso_publisher=.*/iso_publisher="EmotionalOS <https:\/\/github.com\/softnessasastrength\/EmotionalOS-Arch>"/' "$PROFILE_DIR/profiledef.sh"
sed -i 's/^iso_application=.*/iso_application="EmotionalOS Arch KDE Live\/Install Environment"/' "$PROFILE_DIR/profiledef.sh"

export HEALING_SUITE_REF="${HEALING_SUITE_REF:-main}"
export YAY_REF="${YAY_REF:-next}"
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$PROFILE_DIR"

iso="$(find "$OUT_DIR" -maxdepth 1 -type f -name '*.iso' -print -quit)"
[[ -n "$iso" ]] || { echo 'error: mkarchiso completed without producing an ISO' >&2; exit 1; }
sha256sum "$iso" > "$iso.sha256"
printf '\nBuilt: %s\nChecksum: %s.sha256\n' "$iso" "$iso"
