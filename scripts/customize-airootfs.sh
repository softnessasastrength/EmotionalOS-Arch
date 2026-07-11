#!/usr/bin/env bash
set -euo pipefail

export HOME=/root
export LANG=C

systemctl enable NetworkManager.service
systemctl enable sddm.service
systemctl set-default graphical.target

install -d -m0755 /etc/emotionalos /etc/skel/.config
cat > /etc/emotionalos/release <<'EOF'
NAME="EmotionalOS Arch"
BASE="Arch Linux"
DESKTOP="KDE Plasma"
INSTALLER="EmotionalOS TUI + archinstall"
HEALING_SUITE="included"
STATUS="proof-of-concept"
EOF

cat > /etc/skel/.config/kdeglobals <<'EOF'
[General]
ColorScheme=BreezeDark
Name=EmotionalOS

[KDE]
SingleClick=false
EOF

# Build yay from its upstream source as an unprivileged user.
useradd -m -s /bin/bash builduser
printf 'builduser ALL=(ALL) NOPASSWD: /usr/bin/pacman\n' > /etc/sudoers.d/90-emotionalos-build
chmod 0440 /etc/sudoers.d/90-emotionalos-build

YAY_REF="${YAY_REF:-next}"
su - builduser -c "git clone --depth 1 --branch '${YAY_REF}' https://github.com/Jguer/yay.git /home/builduser/yay"
su - builduser -c 'cd /home/builduser/yay && makepkg --noconfirm --syncdeps --cleanbuild'
pacman -U --noconfirm /home/builduser/yay/yay-*.pkg.tar.zst

# Import Healing Suite source and install the command set into /usr/local/bin.
HEALING_SUITE_REF="${HEALING_SUITE_REF:-main}"
git clone --depth 1 --branch "$HEALING_SUITE_REF" \
  https://github.com/softnessasastrength/EmotionalOS-Healing-Suite.git /tmp/healing-suite
if [[ -x /tmp/healing-suite/tests/smoke.sh ]]; then
  (cd /tmp/healing-suite && ./tests/smoke.sh)
fi
install -m0755 /tmp/healing-suite/src/bin/* /usr/local/bin/

# Keep development dependencies out of the shipped image after builds finish.
pacman -Rns --noconfirm go base-devel || true
rm -rf /home/builduser /tmp/healing-suite /etc/sudoers.d/90-emotionalos-build
userdel builduser || true

# Friendly live-session entrypoints.
cat > /usr/local/bin/emotionalos-installer <<'EOF'
#!/usr/bin/env bash
exec sudo emotionalos-install "$@"
EOF
chmod 0755 /usr/local/bin/emotionalos-installer

test -x /usr/bin/yay
test -x /usr/local/bin/healing_tui
test -x /usr/local/bin/emotionalos-install
