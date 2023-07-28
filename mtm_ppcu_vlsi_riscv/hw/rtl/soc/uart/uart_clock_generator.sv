/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

module uart_clock_generator (
    input logic       clk,
    input logic       rst_n,

    output logic      sck,
    output logic      rising_edge,
    output logic      falling_edge,
    input logic       en,
    input logic       clk_divider_valid,
    input logic [7:0] clk_divider
);


/**
 * Local variables and signals
 */

logic       sck_nxt, rising_edge_nxt, falling_edge_nxt;
logic [7:0] counter, counter_nxt, counter_target, counter_target_nxt;


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sck <= 1'b0;
        rising_edge <= 1'b0;
        falling_edge <= 1'b0;
        counter_target <= 8'b0;
        counter <= 8'b0;
    end else begin
        sck <= sck_nxt;
        rising_edge <= rising_edge_nxt;
        falling_edge <= falling_edge_nxt;
        counter_target <= counter_target_nxt;
        counter <= counter_nxt;
    end
end

always_comb begin
    sck_nxt = 1'b0;
    rising_edge_nxt = 1'b0;
    falling_edge_nxt = 1'b0;
    counter_target_nxt = counter_target;
    counter_nxt = 8'b0;

    if (clk_divider_valid) begin
        counter_target_nxt = clk_divider;
    end else if (en) begin
        sck_nxt = sck;
        counter_nxt = counter + 1;

        if (counter_target == 8'b0) begin
            sck_nxt = ~sck;
            rising_edge_nxt = ~sck;
            falling_edge_nxt = sck;
            counter_nxt = 8'b0;
        end else if (counter == counter_target) begin
            sck_nxt = ~sck;
            rising_edge_nxt = ~sck;
            falling_edge_nxt = sck;
            counter_nxt = 8'b0;
        end
    end
end

endmodule
