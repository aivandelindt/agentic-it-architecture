#!/usr/bin/env bash
set -euo pipefail

# Idempotent dev-environment setup for the diagram-design plugin.
#
# Most verification/lint scripts run on the standard-library Python already
# present on the base image. The one extra dependency is Playwright + its pinned
# Chromium build, which scripts/lint-render.py uses as its pixel oracle. CI pins
# Playwright to this exact version (see the plugin's .github/workflows/ci.yml),
# and the Chromium build is chosen by that pin, so keep the two in lockstep.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="$REPO_ROOT/plugins/diagram-design"
VENV_DIR="$PLUGIN_DIR/.venv"
PLAYWRIGHT_VERSION="1.62.0"

# ensurepip is not bundled with the system python on this base image, and the
# venv module needs it to bootstrap pip.
if ! python3 -c "import ensurepip" >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo apt-get install -y -qq python3-venv
fi

# Create (or reuse) the venv that backs the Playwright render linter.
if [ ! -x "$VENV_DIR/bin/python" ]; then
  python3 -m venv "$VENV_DIR"
fi

# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"
python -m pip install --quiet --upgrade pip
python -m pip install --quiet "playwright==${PLAYWRIGHT_VERSION}"

# Chromium is the rendered-layout oracle for scripts/lint-render.py; the exact
# build is selected by the Playwright pin above.
playwright install --with-deps chromium

echo "diagram-design dev environment ready:"
echo "  python3 $(python3 --version 2>&1 | awk '{print $2}') / node $(node --version 2>/dev/null || echo 'n/a')"
python -c "import importlib.metadata as m; print('  playwright', m.version('playwright'))"
echo "  activate the render-linter venv with: source plugins/diagram-design/.venv/bin/activate"
