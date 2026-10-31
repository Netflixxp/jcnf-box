"""Check current menu script endpoints without executing downloaded code."""
import concurrent.futures
import pathlib
import re
import sys
import urllib.request

root = pathlib.Path(__file__).resolve().parents[1]
urls = set()
for entry in ("jcnfbox.sh", "jcnfbox-en.sh"):
    urls.update(re.findall(r"run_remote (https://[^\s]+)", (root / entry).read_text(encoding="utf-8")))


def check(url):
    try:
        request = urllib.request.Request(url, headers={"User-Agent": "jcnf-box-link-check"})
        with urllib.request.urlopen(request, timeout=45) as response:
            sample = response.read(1024).lstrip().lower()
            if b"<html" in sample or b"<!doctype html" in sample or not sample:
                return url, "ERROR: HTML or empty response"
            if not response.url.startswith("https://"):
                return url, "ERROR: insecure redirect"
            return url, "OK"
    except Exception as exc:
        return url, f"ERROR: {exc}"


if __name__ == "__main__":
    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        results = list(pool.map(check, sorted(urls)))
    for url, status in results:
        print(f"{status} {url}")
    sys.exit(any(status != "OK" for _, status in results))
