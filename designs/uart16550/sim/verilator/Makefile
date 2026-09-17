SHELL := /bin/bash

ROOT := $(abspath ../../../..)
RTL_DIR := $(ROOT)/designs/uart16550/rtl/verilog
BUILD_DIR := $(ROOT)/build/uart16550/verilator
BIN := $(BUILD_DIR)/obj/Vuart_smoke_tb
RTL := $(wildcard $(RTL_DIR)/*.v)
TB := uart_smoke_tb.sv

VERILATOR ?= verilator
VERILATOR_FLAGS := --binary --timing --language 1800-2012 -Wall -Wno-fatal \
	-Wno-IMPLICIT -Wno-TIMESCALEMOD -Wno-DEFPARAM -Wno-WIDTHEXPAND \
	-Wno-UNUSEDSIGNAL -Wno-CASEX -Wno-BLKSEQ -Wno-PROCASSINIT

.PHONY: all lint run coverage trace clean

all: run

lint:
	@mkdir -p $(BUILD_DIR)
	$(VERILATOR) --lint-only --timing --language 1800-2012 -Wall -Wno-fatal \
		-Wno-IMPLICIT -Wno-TIMESCALEMOD -Wno-DEFPARAM -Wno-WIDTHEXPAND \
		-Wno-UNUSEDSIGNAL -Wno-CASEX -Wno-BLKSEQ -Wno-PROCASSINIT -I$(RTL_DIR) \
		--top-module uart_smoke_tb $(RTL) $(TB)

$(BIN): $(RTL) $(TB)
	@mkdir -p $(BUILD_DIR)
	$(VERILATOR) $(VERILATOR_FLAGS) -I$(RTL_DIR) --top-module uart_smoke_tb \
		--Mdir $(BUILD_DIR)/obj $(RTL) $(TB)

run: $(BIN)
	$(BIN)

coverage:
	$(ROOT)/scripts/run_verilator.sh --top uart_smoke_tb --tb $(ROOT)/designs/uart16550/sim/verilator/$(TB) \
		--include $(RTL_DIR) $(foreach file,$(RTL),--rtl $(file)) \
		--build-dir $(BUILD_DIR)/coverage --coverage

trace:
	@echo "Trace support requires a testbench with $$dumpfile/$$dumpvars."
	$(VERILATOR) $(VERILATOR_FLAGS) --trace -I$(RTL_DIR) --top-module uart_smoke_tb \
		--Mdir $(BUILD_DIR)/trace/obj $(RTL) $(TB)
	$(BUILD_DIR)/trace/obj/Vuart_smoke_tb

clean:
	rm -rf $(BUILD_DIR)
