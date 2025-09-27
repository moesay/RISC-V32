#!/usr/bin/tclsh

set PROJECT_DIR [pwd]
set SRC_DIR "$PROJECT_DIR/src"
set TB_DIR "$PROJECT_DIR/mod_test_benches"
set INCLUDE_DIR "$PROJECT_DIR/include"
set TEST_DIR "$PROJECT_DIR/test_bins"
set WORK_DIR "$PROJECT_DIR/work"
set SRC_FILES [glob $SRC_DIR/*.v]
set SINGLE_CYCLE_FILES [lsearch -not -inline -all $SRC_FILES "$SRC_DIR/pipelined*"]

file mkdir $WORK_DIR

set TEST_PROGRAMS {
  basic_arithmetic
  memory_ops
  branches
  jumps
  load_store
  full_rv32i
}

set SIM_TOOL "verilator"
set SIM_OPTIONS "--binary --trace --Mdir $WORK_DIR/sim_build -I$INCLUDE_DIR"

proc run_simulation {test_name} {
  global PROJECT_DIR SRC_DIR TEST_DIR WORK_DIR SIM_OPTIONS TB_DIR SINGLE_CYCLE_FILES

  puts "=== Running test: $test_name ==="

  set test_bin "$TEST_DIR/${test_name}.bin"
  set log_file "$WORK_DIR/${test_name}_sim.log"
  set result_file "$WORK_DIR/${test_name}_results.txt"

  if {![file exists $test_bin]} {
    puts "ERROR: Test binary $test_bin not found"
    return 0;
  }

  set cmd "verilator $SIM_OPTIONS \
    $TB_DIR/tb_risc.sv $SINGLE_CYCLE_FILES -o $WORK_DIR/sim_build/Vrisc_${test_name} -DTEST_PROGRAM=\\\"$test_bin\\\""
  exec sh -c $cmd > $log_file
  # exec sh -c $cmd
  # Run the simulation
  set sim_cmd "$WORK_DIR/sim_build/Vrisc_${test_name}"
  exec sh -c $sim_cmd > $result_file

  if {[file exists $result_file] && [file size $result_file] > 0} {
    return 1
  } else {
    return 0
  }
}

proc check_results {test_name} {
  global WORK_DIR

  set result_file "$WORK_DIR/${test_name}_results.txt"

  if {![file exists $result_file]} {
    puts "ERROR: Result file not found for test: $test_name"
    return 0
  }

  # Read and parse results
  set results [exec cat $result_file]

  # Test-specific result checking

  switch $test_name {
    "basic_arithmetic" {
      set r1 [regexp -line {^x1\s*=\s*([0-9]+)} $results -> v1]
      set r2 [regexp -line {^x2\s*=\s*([0-9]+)} $results -> v2]
      set r3 [regexp -line {^x3\s*=\s*([0-9]+)} $results -> v3]
      if {$r1 && $r2 && $r3} {
        if {$v1 == 5 && $v2 == 10 && $v3 == 15} {
          return 1
        }
      }
    }
    "memory_ops" {
      set r1 [regexp -line {^x1\s*=\s*([0-9]+)} $results -> v1]
      set r2 [regexp -line {^x2\s*=\s*([0-9]+)} $results -> v2]
      if {$r1 && $r2} {
        if {$v1 == 42 && $v2 == 43} {
          return 1
        }
      }
    }
    "branches" {
      set r1 [regexp -line {^x1\s*=\s*([0-9]+)} $results -> v1]
      set r2 [regexp -line {^x2\s*=\s*([0-9]+)} $results -> v2]
      set r3 [regexp -line {^x3\s*=\s*([0-9]+)} $results -> v3]
      set r4 [regexp -line {^x4\s*=\s*([0-9]+)} $results -> v4]
      set r10 [regexp -line {^x10\s*=\s*([0-9]+)} $results -> v10]
      if {$r1 && $r2 && $r3 && $r4 && $r10} {
        if {$v1 == 5 && $v2 == 5 && $v3 == 10 && $v4 == 3 && $v10 == 1} {
          return 1
        }
      }
    }
    "jumps" {
      set r1 [regexp -line {^x10\s*=\s*([0-9]+)} $results -> v1]
      set r2 [regexp -line {^x11\s*=\s*([0-9]+)} $results -> v2]
      if {$r1 && $r2} {
        if {$v1 == 1 && $v2 == 3} {
          return 1
        }
      }
    }
    "load_store" {
      if {[regexp -line {^x10\s*=\s*([0-9]+)} $results -> val]} {
        if {$val == 1} {
            return 1
        }
      }
    }
    "full_rv32i" {
      if {[regexp -line {^x10\s*=\s*([0-9]+)} $results -> val]} {
        if {$val == 1} {
            return 1
        }
      }
    }
    default {
      puts "WARNING: No specific check defined for test: $test_name"
      return 1
    }
  }
  return 0
}

proc main {} {
  global TEST_PROGRAMS

  puts "Starting RISC-V Verification Pipeline"
  puts "====================================="

  set passed 0
  set total [llength $TEST_PROGRAMS]

  foreach test $TEST_PROGRAMS {
    if {[run_simulation $test]} {
      if {[check_results $test]} {
        puts "$test: PASSED"
        incr passed
      } else {
        puts "$test: FAILED - Results mismatch"
      }
    } else {
      puts "$test: FAILED - Simulation error"
    }
    puts ""
  }

  puts "====================================="
  puts "Test Summary:"
  puts "Passed: $passed/$total"

  if {$passed == $total} {
    puts "ALL TESTS PASSED!"
    return 0
  } else {
    puts "SOME TESTS FAILED!"
    return 1
  }
}

proc run_single_test {test_name} {
  if {[run_simulation $test_name]} {
    if {[check_results $test_name]} {
      puts "$test_name: PASSED"
      return 0
    } else {
      puts "$test_name: FAILED"
      return 1
    }
  }
}

if {$argc > 0} {
  if {[catch {run_single_test [lindex $argv 0]} result]} {
    puts "ERROR: $result"
    exit 1
  }
  exit 0
} else {
  if {[catch {main} result]} {
    puts "ERROR: $result"
    exit 1
  }
}
exit $result
