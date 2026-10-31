#!/usr/bin/env bash
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Run as root.' >&2; exit 1; }
read -r -p '1: prefer IPv4, 2: prefer IPv6, 3: restore original: ' choice
case $choice in 1|2|3) ;; *) echo 'Invalid choice.'; exit 1 ;; esac
file=/etc/gai.conf
backup=/etc/gai.conf.jcnf-original
if [[ ! -e $backup ]]; then
    if [[ -e $file ]]; then cp -p "$file" "$backup"; else : > "$backup"; fi
fi
cp -p "$backup" "$file"
if [[ $choice != 3 ]]; then
    sed -i '/^[[:space:]]*precedence[[:space:]]/d' "$file"
    cat >> "$file" <<'TABLE'

# jcnf address precedence (glibc clients)
precedence ::1/128 50
precedence ::/0 40
precedence 2002::/16 30
precedence ::/96 20
TABLE
    if [[ $choice == 1 ]]; then
        echo 'precedence ::ffff:0:0/96 100' >> "$file"
    else
        echo 'precedence ::ffff:0:0/96 10' >> "$file"
    fi
fi
echo 'Updated glibc preference; applications may implement their own address selection.'
