#!/usr/bin/env python3
import subprocess
import sys
import os
import re

def assemble_and_extract(asm_file):
    if not asm_file.endswith(".s") or asm_file.endswith(".asm"):
        print("Error: Input must be an assembly file (.s / .asm)")
        sys.exit(1)

    base = os.path.splitext(os.path.basename(asm_file))[0]
    elf_file = base + ".elf"
    dump_file = base + ".dump"
    bin_file = base + ".bin"
    filter_file = base + "_filterlist.txt"

    subprocess.run(
        ["riscv64-unknown-elf-as", asm_file, "-o", elf_file],
        check=True
    )

    with open(dump_file, "w") as f:
        subprocess.run(
            ["riscv64-unknown-elf-objdump", "-d", elf_file],
            stdout=f,
            check=True
        )

    numeric_dump = subprocess.run(
        ["riscv64-unknown-elf-objdump", "-d", "-Mnumeric", elf_file],
        capture_output=True,
        text=True,
        check=True
    ).stdout.splitlines()

    opcodes = []
    with open(dump_file, "r") as f:
        for line in f:
            m = re.match(r"\s*[0-9a-f]+:\s+([0-9a-f]{8})\s", line)
            if m:
                opcodes.append(m.group(1))

    with open(bin_file, "w") as f:
        for opcode in opcodes:
            f.write(opcode + "\n")

    with open(filter_file, "w") as f:
        for line in numeric_dump:
            m = re.match(r"\s*[0-9a-f]+:\s+([0-9a-f]{8})\s+(.+)", line)
            if m:
                opcode = m.group(1)
                instr = m.group(2).strip()
                instr = " ".join(instr.split())
                f.write(f"{opcode} {instr}\n")

    print(f"Extracted {len(opcodes)} instructions -> {bin_file}")
    print(f"Generated filterlist -> {filter_file}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: asm.py <file.s>")
        sys.exit(1)

    assemble_and_extract(sys.argv[1])
