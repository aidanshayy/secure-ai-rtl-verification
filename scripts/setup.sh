#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="${ROOT}/.venv"
TOOLS="${ROOT}/.sc-tools"
OSS_TAG="2026-08-24"
OSS_FILE="oss-cad-suite-linux-x64-20260824.tgz"
OSS_URL="https://github.com/YosysHQ/oss-cad-suite-build/releases/download/${OSS_TAG}/${OSS_FILE}"
OSS_SHA256="9d7f79975ef624e1119fc9690fd9b9839b67026925aff3e2a1192d861b8dbb7c"

python3 -m venv "${VENV}"
"${VENV}/bin/pip" install --upgrade pip
"${VENV}/bin/pip" install -r "${ROOT}/requirements.txt"

if sudo -n true >/dev/null 2>&1; then
    echo "Non-interactive sudo is available; trying official SiliconCompiler ASIC/tool install."
    NPROC="${NPROC:-2}" SC_PREFIX="${TOOLS}" \
        "${VENV}/bin/sc-install" \
        -prefix "${TOOLS}" \
        -build_dir "${TOOLS}/build" \
        -jobs "${NPROC:-2}" \
        -group asic digital-simulation
else
    echo "Non-interactive sudo is not available; skipping native sc-install."
    echo "Installing OSS CAD Suite user-space fallback for Verilator/Yosys validation."
    mkdir -p "${TOOLS}/downloads"
    if [ ! -f "${TOOLS}/downloads/${OSS_FILE}" ]; then
        curl -L "${OSS_URL}" -o "${TOOLS}/downloads/${OSS_FILE}"
    fi
    echo "${OSS_SHA256}  ${TOOLS}/downloads/${OSS_FILE}" | sha256sum -c -
    if [ ! -d "${TOOLS}/oss-cad-suite" ]; then
        tar -xzf "${TOOLS}/downloads/${OSS_FILE}" -C "${TOOLS}"
    fi
fi

cat <<MSG

Setup complete.

Activate with:
  source .venv/bin/activate
  source .sc-tools/oss-cad-suite/environment  # when using the fallback bundle

Then check with:
  ./scripts/check_environment.sh
MSG
