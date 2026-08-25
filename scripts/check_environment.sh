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
            openroad|klayout|sta) ;;
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
    echo "Full RTL-to-GDSII flow is not ready on this host."
    echo "Missing OpenROAD and/or KLayout. Native sc-install requires sudo; Docker is the supported fallback when WSL integration is enabled."
fi

exit "${status}"
