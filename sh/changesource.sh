#!/usr/bin/env bash
# Preserve suites, components, signed-by and deb822 formatting.
set -euo pipefail
if [[ ${1:-} == --help ]]; then
    echo 'Usage: bash changesource.sh [cn|aliyun|restore]'
    echo 'Debian/Ubuntu only. Backups: /var/backups/jcnf-sources/'
    exit 0
fi
[[ $EUID == 0 ]] || { echo 'Run as root.' >&2; exit 1; }
. /etc/os-release
[[ $ID == debian || $ID == ubuntu ]] || { echo 'Only Debian/Ubuntu supported; no files changed.'; exit 1; }
backup=/var/backups/jcnf-sources
case ${1:-cn} in
    restore)
        [[ -d $backup/original ]] || { echo 'No backup found.'; exit 1; }
        cp -a "$backup/original/." /etc/apt/
        apt-get update
        exit
        ;;
    cn) mirror=mirrors.ustc.edu.cn ;;
    aliyun) mirror=mirrors.aliyun.com ;;
    *) echo 'Use cn, aliyun or restore; no files changed.'; exit 1 ;;
esac
shopt -s nullglob
files=(/etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources)
install -d -m 700 "$backup"
if [[ ! -d $backup/original ]]; then
    stage=$(mktemp -d "$backup/.original.XXXXXX")
    trap 'rm -rf "$stage"' EXIT
    [[ ! -f /etc/apt/sources.list ]] || cp -a /etc/apt/sources.list "$stage/"
    [[ ! -d /etc/apt/sources.list.d ]] || cp -a /etc/apt/sources.list.d "$stage/"
    mv "$stage" "$backup/original"
    trap - EXIT
fi
for file in "${files[@]}"; do
    [[ -f $file ]] || continue
    # Only replace official hosts; retain release names and third-party repos.
    sed -E -i \
        -e "s|https?://mirrors\\.(ustc.edu.cn\|aliyun.com)/|https://$mirror/|g" \
        -e "s|https?://(deb.debian.org/debian-security\|security.debian.org(/debian-security)?)|https://$mirror/debian-security|g" \
        -e "s|https?://deb.debian.org/debian([/[:space:]]\|$)|https://$mirror/debian\\1|g" \
        -e "s|https?://([a-z]{2}\\.)?archive.ubuntu.com/ubuntu|https://$mirror/ubuntu|g" \
        -e "s|https?://security.ubuntu.com/ubuntu|https://$mirror/ubuntu|g" \
        -e "s|https?://ports.ubuntu.com/ubuntu-ports|https://$mirror/ubuntu-ports|g" "$file"
done
if ! apt-get update; then
    echo "Update failed. Restore with: bash $0 restore" >&2
    exit 1
fi
