#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
iso="$(find "${ROOT_DIR}/build/out" -maxdepth 1 -type f -name '*.iso' -print -quit 2>/dev/null || true)"
[[ -n "$iso" ]] || { echo 'error: no ISO found; run sudo make build first' >&2; exit 1; }
command -v qemu-system-x86_64 >/dev/null || { echo 'error: qemu-system-x86_64 is required' >&2; exit 1; }

mkdir -p "${ROOT_DIR}/build/vm"
disk="${ROOT_DIR}/build/vm/emotionalos-test.qcow2"
[[ -f "$disk" ]] || qemu-img create -f qcow2 "$disk" 40G

accel=tcg
cpu=max
if [[ -r /dev/kvm && -w /dev/kvm ]]; then
  accel=kvm
  cpu=host
fi

exec qemu-system-x86_64 \
  -machine "q35,accel=${accel}" \
  -cpu "$cpu" \
  -m "${VM_MEMORY_MB:-6144}" \
  -smp "${VM_CPUS:-4}" \
  -boot order=d \
  -cdrom "$iso" \
  -drive "file=${disk},format=qcow2,if=virtio" \
  -device virtio-vga \
  -display gtk
