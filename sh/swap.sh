#!/usr/bin/env bash
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Run as root.' >&2; exit 1; }
[[ ! -d /proc/vz ]] || { echo 'OpenVZ is unsupported.'; exit 1; }
read -r -p '1: add /swapfile, 2: remove /swapfile: ' action
case $action in
    1)
        [[ ! -e /swapfile && ! -L /swapfile ]] || { echo '/swapfile already exists.'; exit 1; }
        ! grep -qE '^[[:space:]]*/swapfile[[:space:]]' /etc/fstab || exit 1
        read -r -p 'Size in MiB: ' size
        [[ $size =~ ^[1-9][0-9]{0,6}$ ]] || { echo 'Invalid size.'; exit 1; }
        umask 077
        (set -o noclobber; : > /swapfile) || exit 1
        trap 'rm -f /swapfile' EXIT
        dd if=/dev/zero of=/swapfile bs=1M count="$size" status=progress
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        trap - EXIT
        cp -p /etc/fstab "/etc/fstab.jcnf.$(date +%Y%m%d%H%M%S).bak"
        printf '%s\n' '/swapfile none swap sw 0 0' >> /etc/fstab
        ;;
    2)
        [[ -f /swapfile && ! -L /swapfile ]] || { echo 'No regular /swapfile found.'; exit 1; }
        if awk 'NR>1 {print $1}' /proc/swaps | grep -qx /swapfile; then
            swapoff /swapfile
        fi
        cp -p /etc/fstab "/etc/fstab.jcnf.$(date +%Y%m%d%H%M%S).bak"
        sed -i '\|^[[:space:]]*/swapfile[[:space:]]|d' /etc/fstab
        rm -f /swapfile
        ;;
    *) echo 'Invalid choice.'; exit 1 ;;
esac
cat /proc/swaps
