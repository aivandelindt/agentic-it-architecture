#!/usr/bin/env bash
# Extract and download images referenced by a web page.
#
# Usage:
#   ./fetch-images.sh [URL] [OUTPUT_DIR]
#
# Examples:
#   ./fetch-images.sh
#   ./fetch-images.sh https://www.deloitte.com/nl/nl/issues/deloitte-ai-institute.html
#   ./fetch-images.sh https://example.com/page ./images

set -euo pipefail

DEFAULT_URL="https://www.deloitte.com/nl/nl/issues/deloitte-ai-institute.html"
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

url="${1:-$DEFAULT_URL}"
output_dir="${2:-./images}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [URL] [OUTPUT_DIR]

  URL         Page to scrape (default: $DEFAULT_URL)
  OUTPUT_DIR  Directory for downloaded images (default: ./images)

Environment:
  LIST_ONLY=1   Print URLs without downloading
  SKIP_ICONS=1  Skip favicons and small apple-touch icons (default: 1)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}

require_command curl
require_command python3

mkdir -p "$output_dir"

tmp_html="$(mktemp "${TMPDIR:-/tmp}/fetch-images.XXXXXX")"
trap 'rm -f "$tmp_html"' EXIT

echo "Fetching: $url"
curl -fsSL -A "$USER_AGENT" "$url" -o "$tmp_html"

mapfile -t image_urls < <(
  python3 - "$url" "$tmp_html" <<'PY'
import html
import re
import sys
from urllib.parse import urljoin, urlparse, urlunparse

page_url = sys.argv[1]
html_path = sys.argv[2]
text = open(html_path, encoding="utf-8", errors="replace").read()

# Attributes and CSS patterns that commonly reference images.
attr_pattern = re.compile(
    r"""(?:src|href|content|data-src|data-lazy-src|poster)\s*=\s*["']([^"']+)["']""",
    re.IGNORECASE,
)
srcset_pattern = re.compile(r"""srcset\s*=\s*["']([^"']+)["']""", re.IGNORECASE)
css_url_pattern = re.compile(
    r"""url\(\s*['"]?([^'")]+)['"]?\s*\)""",
    re.IGNORECASE,
)

image_ext = re.compile(
    r"\.(?:jpe?g|png|gif|webp|svg|avif|bmp|ico)(?:\?|$|#)",
    re.IGNORECASE,
)
non_image_ext = re.compile(
    r"\.(?:js|css|mpd|mp4|json|xml|html?)(?:\?|$|#)",
    re.IGNORECASE,
)
image_host = re.compile(r"/is/image/", re.IGNORECASE)
dam_image = re.compile(r"/content/dam/.*\.(?:jpe?g|png|gif|webp|svg|avif|bmp|ico)", re.IGNORECASE)

def normalize(raw: str) -> str | None:
    raw = html.unescape(raw.strip())
    if not raw or raw.startswith(("data:", "javascript:", "mailto:", "#")):
        return None

    # srcset entries look like: "url 375w, url 480w"
    if re.search(r"\s+\d+[wx]\b", raw):
        parts = []
        for chunk in raw.split(","):
            chunk = chunk.strip()
            if not chunk:
                continue
            parts.append(chunk.split()[0])
        return "\n".join(filter(None, (normalize(part) for part in parts)))

    absolute = urljoin(page_url, raw)
    parsed = urlparse(absolute)
    if parsed.scheme not in ("http", "https"):
        return None

    cleaned = urlunparse(parsed._replace(fragment=""))
    path_and_query = f"{parsed.path}?{parsed.query}" if parsed.query else parsed.path

    if non_image_ext.search(path_and_query):
        return None
    if "{width}" in cleaned.lower() or "%7b.width%7d" in cleaned.lower():
        return None
    if image_ext.search(path_and_query) or image_host.search(cleaned) or dam_image.search(cleaned):
        return cleaned
    return None

candidates: list[str] = []
for pattern in (attr_pattern, srcset_pattern):
    for match in pattern.finditer(text):
        value = normalize(match.group(1))
        if value:
            if "\n" in value:
                candidates.extend(value.splitlines())
            else:
                candidates.append(value)

for match in css_url_pattern.finditer(text):
    value = normalize(match.group(1))
    if value:
        candidates.append(value)

seen: set[str] = set()
unique: list[str] = []
for candidate in candidates:
    if candidate not in seen:
        seen.add(candidate)
        unique.append(candidate)

def dedupe_responsive_variants(urls: list[str]) -> list[str]:
    best: dict[str, tuple[int, str]] = {}

    for item in urls:
        parsed = urlparse(item)
        key = parsed.path
        score = 0

        wid_match = re.search(r"[?&]wid=(\d+)", parsed.query, re.I)
        if wid_match:
            score = int(wid_match.group(1))
        else:
            size_match = re.search(r":(\d+)-x-(\d+)", parsed.path)
            if size_match:
                score = max(int(size_match.group(1)), int(size_match.group(2)))

        current = best.get(key)
        if current is None or score >= current[0]:
            best[key] = (score, item)

    return [entry[1] for entry in best.values()]

unique = dedupe_responsive_variants(unique)

for item in unique:
    print(item)
PY
)

if ((${#image_urls[@]} == 0)); then
  echo "No image URLs found on page." >&2
  exit 1
fi

skip_icons="${SKIP_ICONS:-1}"
filtered_urls=()
for image_url in "${image_urls[@]}"; do
  if [[ "$skip_icons" == "1" ]] && [[ "$image_url" =~ apple-icon|favicon|/icons/ ]]; then
    continue
  fi
  filtered_urls+=("$image_url")
done

if ((${#filtered_urls[@]} == 0)); then
  echo "No image URLs left after filtering." >&2
  exit 1
fi

echo "Found ${#filtered_urls[@]} image URL(s):"
printf '  %s\n' "${filtered_urls[@]}"

if [[ "${LIST_ONLY:-0}" == "1" ]]; then
  exit 0
fi

sanitize_filename() {
  python3 - "$1" <<'PY'
import re
import sys
from urllib.parse import unquote, urlparse

url = sys.argv[1]
parsed = urlparse(url)
name = unquote(parsed.path.rstrip("/").split("/")[-1] or "image")

# Preserve extension hints from query string when path has none.
query = parsed.query.lower()
for fmt in ("webp", "jpeg", "jpg", "png", "gif", "svg", "avif"):
    if f"fmt=" in query and not re.search(r"\.[a-z0-9]+$", name, re.I):
        name = f"{name}.{fmt}"
        break

name = re.sub(r"[^\w.\-]+", "_", name)
name = name.strip("._") or "image.webp"
print(name[:180])
PY
}

downloaded=0
failed=0

for image_url in "${filtered_urls[@]}"; do
  filename="$(sanitize_filename "$image_url")"
  target="$output_dir/$filename"

  if [[ -e "$target" ]]; then
    base="${filename%.*}"
    ext="${filename##*.}"
    if [[ "$base" == "$ext" ]]; then
      ext=""
    fi
    n=2
    while [[ -e "$target" ]]; do
      if [[ -n "$ext" && "$filename" == *".$ext" ]]; then
        target="$output_dir/${base}-${n}.${ext}"
      else
        target="$output_dir/${filename}-${n}"
      fi
      n=$((n + 1))
    done
  fi

  echo "Downloading: $image_url"
  if curl -fsSL -A "$USER_AGENT" "$image_url" -o "$target"; then
    downloaded=$((downloaded + 1))
  else
    echo "  failed" >&2
    failed=$((failed + 1))
    rm -f "$target"
  fi
done

echo "Done. Downloaded $downloaded file(s) to $output_dir (${failed} failed)."
