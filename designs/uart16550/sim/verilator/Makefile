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

.PHONY: all lint run clean

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

clean:
	rm -rf $(BUILD_DIR)
