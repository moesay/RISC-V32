# RISC-V RV32I Implementation
_Yet another RV32I Implementation? Yes, also for educational/practicing purposes. I know that you already know about it, but this is the README.md, I have to explain the project_ :( . \*grabs the mic\*


## Overview
This project implements a fully functional RISC-V RV32I ISA processor in Verilog/SystemVerilog, featuring:
* __Complete RV32I ISA support__: All base integer instructions
* __Single-cycle architecture__: Simple and efficient design
* __Modular design__: Clean separation of components
* __Comprehensive verification__: Extensive testbench suite


## Core Components

* **_risc.v_**: Top-level processor integration
* **_decoder.v_**: Instruction decoding and control signals
* **_alu.v_**:	Arithmetic Logic Unit with all RV32I operations
* **_regFile.v_**: 32-bit register file (x0-x31)
* **_imem.v_**: Instruction memory (word-aligned)
* **_dmem.v_**:	Data memory with byte/halfword/word support
* **_pc.v_**: Program counter with reset
* **_branchUnit.v_**: Branch and jump resolution
* **_immGen.v_**: Immediate value generation


## Getting Started

The project utilizes GNU `make` and TCL shell, `tclsh` for building and testing automation, `verilator` for simulation, `python` and a RISC-V toolchain for assembly generation. Ensure that all of them are installed on your machine.

Inside ```test_bins/```, there are a lot of ready-to-use binaries along with their sources. The script ```asm.py``` requires a RISC-V toolchain to run, as it's not an assembler. It's a script that triggers

1- The assembler to generate the ```.elf``` file.

2- ```objdump``` to get the binary that will be loaded to the ```dmem``` module.

3- Generates a filter list file to be used with GTKWave to read the instructions easily.


#### Available Make Recipes:
* ```make all```: Builds the whole project with the default test program loaded into ```dmem```.
* ```make all TEST_PROGRAM=<test_program.bin>```: Builds the whole project with ```<test_program>.bin``` loaded into ```dmem```.
* ```make <any_target_or_all> LINT_ONLY=1```: Only Lints the code and checks for syntax errors.
* ```make <target>```: Build a specific target with its coresponding testbench. Each module is a target.
* ```make run-<target>```: Runs a target.
* ```make asm-<asm_file_name>```: Assembles the passed file and generates the files mentioned above. The file has to be inside ```test_bins/``` and the name should be passed without the ```.s/.asm```extension.
* ```make wave```: Runs GTKWave and loads the latest ```dump.vcd``` file.
* ```make test```: Triggers TCL to run full system/integrity test.
* ```make test-<system_test>```: Runs a specific system test. Available tests are:
  *   basic_arithmetic
  * memory_ops
  * branches
  * jumps
  * load_store
  * full_rv32i


## Testing levels / Strategy
* Unit testing

Each Module has its own testbench to test its function individually. The results are not automatically checked; only SystemVerilog assertions are used. Maybe this is something for the future

* Integration Test

TCL is used to trigger the specific integration test, read the CPU registers (the TB dumps them), and check for some values; if they are correct, then the test is marked successful.

* System Test

TCL is also used to do full processor validation. System Test and Integration Test are automated using TCL.


## Future Enhancements

I will keep updating the project and implementing whatever I can, but on top of the list:
* RV32M extension
* RV32F extension
* RV32C extension
* Pipelined Implementation
