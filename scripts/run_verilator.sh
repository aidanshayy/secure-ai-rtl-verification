#!/usr/bin/env bash
set -euo pipefail

usage() {
    sed -n '2,35p' "$0"
}

TOP=""
TB=""
BUILD_DIR="build/verilator"
RTL_FILES=()
INCLUDE_DIRS=()
COVERAGE=0
TRACE=0
LINT_ONLY=0

# Run one configured SystemVerilog/Verilog testbench with Verilator.
# Required: --top MODULE --tb FILE --rtl FILE (repeat --rtl for more files).
# Optional: --include DIR, --build-dir DIR, --coverage, --trace, --lint-only.
while (($#)); do
    case "$1" in
        --top) TOP="$2"; shift 2 ;;
        --tb) TB="$2"; shift 2 ;;
        --rtl) RTL_FILES+=("$2"); shift 2 ;;
        --include) INCLUDE_DIRS+=("$2"); shift 2 ;;
        --build-dir) BUILD_DIR="$2"; shift 2 ;;
        --coverage) COVERAGE=1; shift ;;
        --trace) TRACE=1; shift ;;
        --lint-only) LINT_ONLY=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "error: unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done

if [[ -z "$TOP" || -z "$TB" || ${#RTL_FILES[@]} -eq 0 ]]; then
    echo "error: --top, --tb, and at least one --rtl are required" >&2
    usage >&2
    exit 2
fi

VERILATOR_ARGS=(--language 1800-2012 -Wall -Wno-fatal --timing)
for include_dir in "${INCLUDE_DIRS[@]}"; do
    VERILATOR_ARGS+=("-I${include_dir}")
done

if ((LINT_ONLY)); then
    verilator --lint-only "${VERILATOR_ARGS[@]}" --top-module "$TOP" \
        "${RTL_FILES[@]}" "$TB"
    exit 0
fi

mkdir -p "$BUILD_DIR"
if ((COVERAGE)); then
    VERILATOR_ARGS+=(--coverage)
fi
if ((TRACE)); then
    VERILATOR_ARGS+=(--trace)
fi

BIN="$BUILD_DIR/obj/V${TOP}"
if ((COVERAGE)); then
    # --binary's generated main does not persist Verilator coverage. Build a
    # small timing-aware C++ harness that writes coverage.dat after $finish.
    sed "s/@TOP@/V${TOP}/g" "$(dirname "$0")/verilator_main.cpp.in" \
        > "$BUILD_DIR/verilator_main.cpp"
    MAIN_CPP="$(realpath "$BUILD_DIR/verilator_main.cpp")"
    verilator --cc --exe --build "${VERILATOR_ARGS[@]}" --Mdir "$BUILD_DIR/obj" \
        --top-module "$TOP" "${RTL_FILES[@]}" "$TB" "$MAIN_CPP"
else
    verilator --binary "${VERILATOR_ARGS[@]}" --Mdir "$BUILD_DIR/obj" \
        --top-module "$TOP" "${RTL_FILES[@]}" "$TB"
fi

"$BIN" "$@"

if ((COVERAGE)); then
    if command -v verilator_coverage >/dev/null 2>&1 && [[ -f coverage.dat ]]; then
        mv coverage.dat "$BUILD_DIR/coverage.dat"
        verilator_coverage --write-info "$BUILD_DIR/coverage.info" \
            "$BUILD_DIR/coverage.dat"
        echo "Coverage data: $BUILD_DIR/coverage.dat"
        echo "LCOV report:   $BUILD_DIR/coverage.info"
    else
        echo "warning: simulation passed but coverage.dat was not produced" >&2
    fi
fi
