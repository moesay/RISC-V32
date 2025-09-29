# Mode config [ 0 / 1]
LINT_ONLY ?= 0

# ===== Files configs =====
SRC_DIR = ./src
TB_DIR = ./mod_test_benches

TB_FILES = $(wildcard $(TB_DIR)/*.sv)
SRC_FILES = $(wildcard $(SRC_DIR)/*.v)
FILTER_OUT_SRC_FILES = $(SRC_DIR)/risv.v $(SRC_DIR)/branchUnit.v
PIPELINING_SRC_FILES = $(filter-out $(FILTER_OUT_SRC_FILES), $(SRC_FILES))

INCLUDE_DIR = ./include
INCLUDE = types.sv params.vh

TEST_BINS_DIR = ./test_bins

# ===== Verilator configs =====
VERILATOR_BIN = verilator
VERILATOR_CMD = $(VERILATOR_BIN) $(VERILATOR_FLAGS)
VERILATOR_FLAGS = $(VERILATING_MODE) --trace --prefix $(@) -I$(INCLUDE_DIR)

# ===== Targets =====
TARGETS = imem regFile pc immGen decoder alu dmem branchUnit
TEST_PROGRAM ?= $(TEST_BINS_DIR)/pipe.bin

ifeq ($(LINT_ONLY), 0)
	VERILATING_MODE = --binary
else
	VERILATING_MODE = --lint-only --timing
endif

all:
	$(VERILATOR_BIN) $(VERILATOR_FLAGS) $(SRC_FILES) $(TB_DIR)/tb_risc.sv --top-module tb_risc -DTEST_PROGRAM=\"$(TEST_PROGRAM)\"

pipelined:
	$(VERILATOR_BIN) $(VERILATOR_FLAGS) $(PIPELINING_SRC_FILES) --top-module pipe_risc $(TB_DIR)/tb_risc.sv --top-module tb_risc -DTEST_PROGRAM=\"$(TEST_PROGRAM)\" -DPIPELINED

$(TARGETS):
	@echo "Verilating $(@)"
	$(VERILATOR_CMD) $(SRC_DIR)/$(@).v $(TB_DIR)/tb_$(@).sv $(INCLUDE) -DTEST_PROGRAM=\"$(TEST_PROGRAM)\"

.PHONY: test clean all wave

test:
	./tcl/run_tests.tcl

clean:
	rm *.vcd
	rm -rf ./obj_dir
	rm -rf ./work

run-%: %
	@echo "Running $(*)"
	./obj_dir/$(*)

test-%:
	./tcl/run_tests.tcl $*

asm-%:
	./test_bins/asm.py ./test_bins/$*.s
	mv $*.* ./test_bins/
	mv $*_filterlist.txt ./test_bins/

wave:
	gtkwave dump.vcd &
