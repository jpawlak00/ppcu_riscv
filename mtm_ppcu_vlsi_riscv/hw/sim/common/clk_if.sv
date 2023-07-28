/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

interface clk_if (
    output logic clk
);


/**
 * Tasks and functions definitions
 */

function void init();
    clk = 1'b0;
endfunction

task run();
    forever
        clk = #10 ~clk;
endtask

endinterface
