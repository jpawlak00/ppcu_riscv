#!/bin/bash -e
#
# Copyright (C) 2023  AGH University of Science and Technology
#

function usage {
    echo "usage: $(basename "$0") [options]"
    echo "  options:"
    echo "      -d,     enable debug mode (dumps memories contents to files at time 0,"
    echo "              after a boot, and at the end of simulation."
    echo "      -g,     show simulation in SimVision"
    echo "      -s,     specify a seed for simulation (generated automatically if not specified)"
    exit 1
}

function compile_program {
    cmake -S ../../../sw -B ../../../sw/build && \
    cmake --build ../../../sw/build -j "$(nproc)"
}

function generate_boot_mem {
    boot_mem_generator.py ../../../sw/build/bootloader/bootloader.bin ../../rtl/soc/memories/boot_mem.sv
}

function generate_mem_init_file {
    local mem_file="TS1N40LPB4096X32M4M_initial.cde"

    echo "" > ${mem_file}
    for i in {1..4096}; do
        printf "%08x\n" $(( ${seed} * 65536 + ${seed} )) >> ${mem_file}
    done
}

function execute_test {
    local xrun_args=""

    # TSMC params
    xrun_args+="-define TSMC_INITIALIZE_MEM "
    xrun_args+="-define UNIT_DELAY "                 # disable all timing checks in the memory
    xrun_args+="-exclude_file xminitialize.exclude "
    xrun_args+="-xmhierarchy \"tb_mtm_riscv_soc\" "
    xrun_args+="-v /cad/dk/PDK_CRN45GS_DGO_11_25/digital/Front_End/verilog/tpfn40lpgv2od3_120a/tpfn40lpgv2od3.v "
    xrun_args+="-v /cad/dk/PDK_CRN45GS_DGO_11_25/IMEC_RAM_generator/ram/ts1n40lpb4096x32m4m_250a/VERILOG/ts1n40lpb4096x32m4m_250a_tt1p1v25c.v "
    xrun_args+="+nowarnTRNNOP "

    # Simulation config
    xrun_args+="-64bit "
    xrun_args+="-define KMIE_IMPLEMENT_ASIC "
    xrun_args+="-F functional.f "
    xrun_args+="-l ${log_file} "
    xrun_args+="-q "
    xrun_args+="-timescale 1ns/1ps "
    xrun_args+="-xminitialize rand_2state:${seed} "
    xrun_args+="+nowarnDSEM2009 "
    xrun_args+="+nowarnDSEMEL "
    xrun_args+="+nowarnZROMCW "

    if [[ ${debug} ]]; then
        xrun_args+="-define DEBUG "
    fi

    if [[ ${gui} ]]; then
        xrun_args+="-fsmdebug "
        xrun_args+="-gui "
        xrun_args+="-linedebug "
        xrun_args+="-xmdebug "
    fi

    xrun "${xrun_args}"
    local status=$?

    # if the a test fails, store xrun warnings and errors in a separate file
    if [[ ${status} != "0" ]]; then
        echo ${log_sep} |& tee -a ${log_file}
        echo "-- xrun exited with status ${status}, " `grep -c "*E" ${log_file}` "errors in ${log_file}". |& tee -a ${log_file}
        echo "SEED ${seed}" >> seed.xrun.errors
        egrep "\*[WE]." ${log_file} >> seed.xrun.errors
        echo "" >> seed.xrun.errors
    fi
}

function verify_test_results {
    # compare the led[3:0] waves with reference and report

    if [[ -e led_waves.txt ]] ; then
        # sum of inserted+deleted reported by diff
        led_diffs=$(diff ../common/led_waves_correct.txt led_waves.txt | diffstat | tail -1 | perl -lane 'print $F[3]+$F[5]')
        echo ${log_sep} |& tee -a ${log_file}

        if (( ${led_diffs} == 0 )); then
            echo "-- Simlation PASSED. led[3:0] waves OK. SEED=${seed}" |& tee -a ${log_file}
            echo ${log_sep} |& tee -a ${log_file}
            echo ${seed} >> seed.passed
            return 0
        elif (( ${led_diffs} < 5 )); then
            echo "-- Simlation PASSED. led[3:0] waves minor difference (diff: $led_diffs). SEED=${seed}" |& tee -a ${log_file}
            echo ${log_sep} |& tee -a ${log_file}
            echo ${seed} >> seed.passed
            return 0
        else
            echo "-- Simlation FAILED led[3:0] waves incorrect (diff: $led_diffs). SEED=${seed}" |& tee -a ${log_file}
            echo ${log_sep} |& tee -a ${log_file}
            echo ${seed} "wrong output waveforms" >> seed.failed
            return 1
        fi
    fi
}

while getopts dgs: option; do
    case ${option} in
        d) debug=1;;
        g) gui=1;;
        s) seed=${OPTARG};;
        *) usage;;
    esac
done

if [[ ${seed} ]]; then
    echo "INFO: used provided seed value (${seed})"
else
    seed=$((RANDOM % 1000))
    echo "INFO: used generated seed value (${seed})"
fi

. /cad/env/cadence_path.XCELIUM1909

log_file=xrun.log.${seed}
log_sep="------------------------------------------------------------------------------"

cd $(dirname $(readlink -e "$0"))/../hw/sim/functional

compile_program
generate_boot_mem
generate_mem_init_file
execute_test
verify_test_results
