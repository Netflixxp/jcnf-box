#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
for script in ./*.sh sh/*.sh; do bash -n "$script"; done
repo=$PWD
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export TEST_DIR=$tmp
for entry in jcnfbox.sh jcnfbox-en.sh; do
    (
        source "$entry"
        # An HTTP failure must not execute even a syntactically valid partial body.
        curl() { printf 'touch "$TEST_DIR/executed"\n' > "${@: -1}"; return 22; }
        if run_remote https://invalid.example/test; then exit 1; fi
        [[ ! -e $tmp/executed ]]
        # A 200 HTML/error page must not execute as Bash.
        curl() { printf '<html>error</html>\n' > "${@: -1}"; }
        if run_remote https://invalid.example/test; then exit 1; fi
        [[ ! -e $tmp/executed ]]
        # Valid downloads receive arguments and preserve their exit status.
        curl() { printf 'printf "%%s" "$1" > "$TEST_DIR/argument"\nexit 7\n' > "${@: -1}"; }
        status=0
        run_remote https://invalid.example/test 'two words' || status=$?
        [[ $status == 7 && $(cat "$tmp/argument") == 'two words' ]]
    )
    printf '0\n' | bash "$entry" >/dev/null
    bash "$entry" </dev/null >/dev/null
done
# Test the real mirror conversion expressions against legacy and deb822 fixtures.
mirror=mirrors.ustc.edu.cn
file=$tmp/sources
cat > "$file" <<'FIXTURE'
deb http://deb.debian.org/debian bookworm main non-free-firmware
URIs: http://security.debian.org/debian-security
Suites: trixie-security
URIs: http://ports.ubuntu.com/ubuntu-ports
deb https://archive.ubuntu.com/ubuntu noble main
deb https://vendor.example/repo stable main
FIXTURE
sed -n '/^    sed -E -i/,/"$file"$/p' sh/changesource.sh > "$tmp/conversion.sh"
source "$tmp/conversion.sh"
grep -q 'https://mirrors.ustc.edu.cn/debian bookworm' "$file"
grep -q 'https://mirrors.ustc.edu.cn/debian-security$' "$file"
grep -q 'https://mirrors.ustc.edu.cn/ubuntu-ports$' "$file"
grep -q 'https://mirrors.ustc.edu.cn/ubuntu noble' "$file"
grep -q 'Suites: trixie-security' "$file"
grep -q 'https://vendor.example/repo stable main' "$file"
mirror=mirrors.aliyun.com
source "$tmp/conversion.sh"
grep -q 'https://mirrors.aliyun.com/debian bookworm' "$file"
! grep -q 'mirrors.ustc.edu.cn' "$file"
# Guard against global rule flushing and unrelated swap shutdown.
! grep -Eq 'iptables -t nat -F (PREROUTING|POSTROUTING)|--policy FORWARD|iptables -D FORWARD' sh/iptables.sh
! grep -q 'swapoff -a' sh/swap.sh
echo 'Smoke tests passed.'
