/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

interface rst_if (
    output logic rst_n,
    input logic  clk
);


/**
 * Tasks and functions definitions
 */

task init();
    $assertoff;
    @(posedge clk) ;
    @(negedge clk) ;
    rst_n = 1'b1;
endtask

task reset();
    @(negedge clk) ;
    $assertoff;
    rst_n = 1'b0;

    @(negedge clk) ;
    $asserton;
    rst_n = 1'b1;
endtask

endinterface
