#!/usr/bin/env bash
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="${ROOT}/.sc-tools/bin:${ROOT}/.sc-tools/oss-cad-suite/bin:${PATH}"

status=0

have() {
    command -v "$1" >/dev/null 2>&1
}

section() {
    printf '\n== %s ==\n' "$1"
}

section "Host"
uname -a
if [ -r /etc/os-release ]; then
    . /etc/os-release
    echo "${PRETTY_NAME}"
fi
python3 --version

section "SiliconCompiler"
if [ -x "${ROOT}/.venv/bin/python" ]; then
    "${ROOT}/.venv/bin/python" - <<'PY'
import siliconcompiler
print(f"siliconcompiler {siliconcompiler.__version__}")
PY
else
    echo "missing .venv/bin/python"
    status=1
fi

section "EDA Tools"
for tool in verilator yosys openroad sta klayout sv2v; do
    if have "${tool}"; then
        printf '%-10s %s\n' "${tool}" "$(command -v "${tool}")"
    else
        printf '%-10s %s\n' "${tool}" "MISSING"
        case "${tool}" in
            openroad|klayout|sta|sv2v) ;;
            *) status=1 ;;
        esac
    fi
done

section "Versions"
have verilator && verilator --version || true
have yosys && yosys -V || true
have openroad && openroad -version || true
have sta && sta -version || true
have klayout && klayout -v || true

section "Docker Runner"
SC_DOCKER_IMAGE="${SC_DOCKER_IMAGE:-ghcr.io/siliconcompiler/sc_runner:v0.38.2}"
if have docker; then
    if docker info >/dev/null 2>&1; then
        echo "Docker daemon reachable"
        echo "SiliconCompiler runner: ${SC_DOCKER_IMAGE}"
        docker run --rm "${SC_DOCKER_IMAGE}" openroad -version || status=1
    else
        echo "Docker client found, but the daemon/socket is not reachable from this shell."
        echo "If using Docker Desktop, enable WSL integration for this distro or fix /var/run/docker.sock permissions."
    fi
else
    echo "Docker client not found"
fi

section "RTL Checks"
if have verilator; then
    verilator --lint-only -Wall "${ROOT}/designs/example/tiny_counter.v" || status=1
else
    echo "Skipping Verilator lint: verilator not found"
    status=1
fi

if have yosys; then
    yosys -q -p "read_verilog ${ROOT}/designs/example/tiny_counter.v; hierarchy -top tiny_counter; proc; opt; synth -top tiny_counter; stat" || status=1
else
    echo "Skipping Yosys synthesis: yosys not found"
    status=1
fi

section "Physical Flow Readiness"
if have openroad && have klayout; then
    echo "OpenROAD and KLayout are available. Run:"
    echo "  PATH=\"${ROOT}/.sc-tools/bin:${ROOT}/.sc-tools/oss-cad-suite/bin:\$PATH\" .venv/bin/python flows/example_flow.py"
else
    echo "OpenROAD and/or KLayout are not available natively."
    echo "Docker is the supported fallback when WSL integration is enabled. Run:"
    echo "  .venv/bin/python flows/example_flow.py --scheduler docker --docker-image ${SC_DOCKER_IMAGE}"
fi

exit "${status}"
