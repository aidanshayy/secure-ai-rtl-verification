SHELL := /bin/bash

ROOT := $(abspath ../../../..)
BUILD_DIR := $(ROOT)/build/D_Flip_Flop/verilator
SCRIPT := $(ROOT)/scripts/run_verilator.sh

RTL := $(ROOT)/designs/D_Flip_Flop/DFlipFlop.sv
TB := $(ROOT)/designs/D_Flip_Flop/tb_DFlipFlop.sv
TOP := tb

.PHONY: all lint run coverage clean

all: run

lint:
	$(SCRIPT) --top $(TOP) --tb $(TB) --rtl $(RTL) --lint-only

run:
	$(SCRIPT) --top $(TOP) --tb $(TB) --rtl $(RTL) --build-dir $(BUILD_DIR)

coverage:
	$(SCRIPT) --top $(TOP) --tb $(TB) --rtl $(RTL) --build-dir $(BUILD_DIR)/coverage --coverage

clean:
	rm -rf $(BUILD_DIR)
