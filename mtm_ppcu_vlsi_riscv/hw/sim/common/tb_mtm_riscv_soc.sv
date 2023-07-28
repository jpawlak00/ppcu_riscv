/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

module tb_mtm_riscv_soc ();


/**
 * Local variables and signals
 */

logic        clk, rst_n;
logic [31:0] gpio_dout, gpio_din;
logic        uart_sout, uart_sin;

event        application_started;


/**
 * Interfaces instantiation
 */

clk_if u_clk_if (
    .clk
);

rst_if u_rst_if (
    .rst_n,
    .clk
);

uart_if u_uart_if (
    .sin(uart_sin),
    .en(),
    .clk_divider_valid(),
    .clk_divider(),
    .tx_data_valid(),
    .tx_data(),
    .clk,
    .rst_n,
    .sout(uart_sout),
    .sck(),
    .sck_rising_edge(u_mtm_riscv_chip.u_soc.u_uart.sck_rising_edge),
    .transmitter_busy(),
    .receiver_busy(),
    .rx_data_valid(),
    .rx_data(),
    .rx_error()
);


/**
 * Submodules placement
 */

 mtm_riscv_chip u_mtm_riscv_chip (
    .clk,
    .rst_n,

    .gpio_dout(gpio_dout[3:0]),
    .gpio_din(gpio_din[3:0]),

    .uart_sout,
    .uart_sin
);


/**
 * Task and functions definitions
 */

task initialize_code_ram();
    $readmemh("../../../sw/build/app/app.mem",
`ifdef KMIE_POST_LAYOUT_SIM
        u_mtm_riscv_chip.u_soc.u_code_ram_u_ram.u_TS1N40LPB4096X32M4M.MEMORY);
`elsif KMIE_IMPLEMENT_ASIC
        u_mtm_riscv_chip.u_soc.u_code_ram.u_ram.u_TS1N40LPB4096X32M4M.MEMORY);
`endif
endtask


/**
 * Test
 */

localparam       ON                 = 3, OFF = 4;
localparam       UNIQUE             = 32, UNIQUE0 = 64, PRIORITY = 128;

initial begin
    string message;

    u_uart_if.init();

    u_uart_if.read_first_message(message);
    $display("core: %s", message);

    forever begin
        u_uart_if.read(message);
        $display("core: %s", message);

        if (message == "INFO: application started")
            ->application_started;
    end
end

initial begin
    u_rst_if.init();

`ifdef DEBUG
    dump_memories();
`endif

    gpio_din = 32'h8;       /* skip codeload */

    $assertoff; // Disable time 0 assertions
    // Turn OFF the violation reporting for unique case, unique0 case, priority case, unique if, etc.
    $assertcontrol( OFF , UNIQUE | UNIQUE0 | PRIORITY );

    u_rst_if.reset();

    initialize_code_ram();

    $asserton;  // Enable assertions after reset
    // Turn ON the violation reporting for unique case, unique0 case, priority case, unique if, etc.
    $assertcontrol( ON , UNIQUE | UNIQUE0 | PRIORITY );

    wait (application_started.triggered);
    $display("%0t main: application started", $time);

`ifdef DEBUG
    dump_memories();
`endif

    #63ms;

`ifdef DEBUG
    dump_memories();
`endif

    $finish;
end


/**
 * Monitoring
 */

initial begin : watchdog
    $timeformat(-9, 0, " ns", 0);

`ifdef KMIE_POST_LAYOUT_SIM
    #50ms;
`elsif KMIE_IMPLEMENT_ASIC
    #1.5s;
`endif

    $display("%0t watchdog timeout!",$time);
`ifdef DEBUG
    dump_memories();
`endif
    $finish;
end

always begin : timestamp
    #1ms $display("%0t timestamp", $time);
end


/**
 * Write gpio_dout[3:0] waveforms to file.
 */

integer F;

`ifdef KMIE_POST_LAYOUT_SIM
logic [3:0] gpio_dout_prev;
`endif

initial begin
    F = $fopen("led_waves.txt");

`ifdef KMIE_POST_LAYOUT_SIM
    gpio_dout_prev = 4'bxxxx;
`endif

    #1ns;
    wait (application_started.triggered);

`ifdef KMIE_POST_LAYOUT_SIM
    forever begin
        @(posedge clk) ;
        if(gpio_dout_prev !== gpio_dout[3:0]) begin
            $fdisplay(F, "%b", gpio_dout[3:0]);
            gpio_dout_prev = gpio_dout[3:0];
        end
    end
`elsif KMIE_IMPLEMENT_ASIC
    $fmonitor(F, "%b", gpio_dout[3:0]);
`endif
end

final begin
    $fclose(F);
end


/**
 * Clock generation
 */

initial begin
    u_clk_if.init();
    u_clk_if.run();
end


/**
 * Memory dump functions.
 */

task dump_memories();
`ifdef KMIE_IMPLEMENT_ASIC
    dump_memory_code_TS1N40LPB4096X32M4M();
    dump_memory_data_TS1N40LPB4096X32M4M();
`endif
endtask

// -----------------------------------------------------------------------------
// generic memory dump
`define DUMP_MEMORY_TASK(NAME, MEM_SIZE, MEM_VAR) \
task automatic NAME (); \
    integer mem_f; \
    string file_name; \
    begin \
        file_name = $sformatf("%s_%0d.hex", `"NAME`", $realtime); \
        $display("%0t Dumping memory: %s", $time, `"MEM_VAR`"); \
        $display("          File name: %s", file_name); \
        mem_f = $fopen(file_name); \
        for(int i=0; i < MEM_SIZE; i++) begin \
            $fdisplay(mem_f, "%X", MEM_VAR[i]); \
        end \
        $fclose(mem_f); \
    end \
endtask


// -----------------------------------------------------------------------------
// ASIC memories

`ifdef KMIE_IMPLEMENT_ASIC

`define DUMP_MEMORY_TASK_TS1N40LPB4096X32M4M(NAME, MEM_VAR) \
task automatic NAME (); \
    integer mem_f; \
    string file_name; \
    begin \
        file_name = $sformatf("%s_%0d.hex", `"NAME`", $realtime); \
        $display("%0t Dumping memory: %s", $time, `"MEM_VAR`"); \
        $display("          File name: %s", file_name); \
        mem_f = $fopen(file_name); \
        for (int row = 0; row <= 1024-1; row++) begin \
            for (int col = 0; col <= 4-1; col++) begin \
                $fdisplay(mem_f, "%X", MEM_VAR[row][col] ); \
            end \
        end \
        $fclose(mem_f); \
    end \
endtask

`ifdef KMIE_POST_LAYOUT_SIM
    `DUMP_MEMORY_TASK_TS1N40LPB4096X32M4M(dump_memory_code_TS1N40LPB4096X32M4M, u_mtm_riscv_chip.u_soc.u_code_ram_u_ram.u_TS1N40LPB4096X32M4M.MEMORY)
`elsif KMIE_IMPLEMENT_ASIC
    `DUMP_MEMORY_TASK_TS1N40LPB4096X32M4M(dump_memory_code_TS1N40LPB4096X32M4M, u_mtm_riscv_chip.u_soc.u_code_ram.u_ram.u_TS1N40LPB4096X32M4M.MEMORY)
`endif

`DUMP_MEMORY_TASK_TS1N40LPB4096X32M4M(dump_memory_data_TS1N40LPB4096X32M4M, u_mtm_riscv_chip.u_soc.u_data_ram.u_ram.u_TS1N40LPB4096X32M4M.MEMORY)

`endif
// -----------------------------------------------------------------------------

endmodule
