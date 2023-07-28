/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

interface uart_if (
    input logic        clk,
    input logic        rst_n,

    output logic       en,
    output logic       clk_divider_valid,
    output logic [7:0] clk_divider,
    output logic       tx_data_valid,
    output logic [7:0] tx_data,
    input logic        sck,
    input logic        sck_rising_edge,
    input logic        transmitter_busy,
    input logic        receiver_busy,
    input logic        rx_data_valid,
    input logic [7:0]  rx_data,
    input logic        rx_error,

    output logic       sin,
    input logic        sout
);


/**
 * Tasks and functions definitions
 */

task init();
    @(negedge clk) ;
    @(posedge rst_n) ;
    sin = 1'b1;
    en = 1'b0;
    clk_divider_valid = 1'b0;
    clk_divider = 8'h00;
endtask

task set_divider(input int divider);
    @(negedge clk) ;
    clk_divider = divider;
    clk_divider_valid = 1'b1;
    en = 1'b1;

    @(negedge clk) ;
    clk_divider_valid = 1'b0;
endtask

task send_bit_to_uart(input logic data);
    sin = data;
    for (int i = 0; i < 16; ++i)
        @(posedge sck_rising_edge) ;
endtask

task send_frame_to_uart(input logic start_bit, input logic [7:0] data_to_send, input logic stop_bit);
    send_bit_to_uart(start_bit);
    for (int i = 0; i < 8; ++i)
        send_bit_to_uart(data_to_send[i]);
    send_bit_to_uart(stop_bit);
endtask

task send_data_to_uart(output logic [7:0] received_data, input logic [7:0] data_to_send);
    send_frame_to_uart(1'b0, data_to_send, 1'b1);
    received_data = rx_data;
endtask

task receive_bit_from_uart(output logic received_bit);
    for (int i = 0; i < 16; ++i) begin
        @(posedge sck_rising_edge) ;
        if (i == 7)
            received_bit = sout;
    end
endtask

task receive_frame_from_uart(output logic start_bit, output logic [7:0] data, output logic stop_bit);
    @(negedge sout) ;
    receive_bit_from_uart(start_bit);
    for (int i = 0; i < 8; ++i)
        receive_bit_from_uart(data[i]);
    receive_bit_from_uart(stop_bit);
endtask

task receive_data_from_uart(output logic [7:0] received_data, input logic [7:0] data_to_send);
    logic start_bit, stop_bit;

    if (transmitter_busy)
        @(negedge transmitter_busy) ;

    @(negedge clk) ;
    tx_data = data_to_send;
    tx_data_valid = 1'b1;

    @(negedge clk) ;
    tx_data_valid = 1'b0;

    receive_frame_from_uart(start_bit, received_data, stop_bit);
endtask

task send_data(input logic [7:0] data);
    send_frame_to_uart(1'b0, data, 1'b1);
endtask

task receive_data(output logic [7:0] data);
    logic start_bit, stop_bit;

    receive_frame_from_uart(start_bit, data, stop_bit);
endtask


/* API for system tests */

task read_byte(output byte data);
    receive_data(data);
endtask

task read_word(output int data);
    for (int i = 0; i < 4; ++i) begin
        data <<= 8;
        read_byte(data[7:0]);
    end
endtask

task read(output string message);
    byte data;

    message = "";
    while (1) begin
        receive_data(data);
        if (data != "\n")
            message = {message, data};
        else
            break;
    end
endtask

task read_first_message(output string message);
    int len;

    read(message);
    len = message.len();

    for (int i = 0; i < len; ++i) begin
        /**
         * the first received character may be corrupted,
         * because it may be read before the iomux configuration
         */
        if (message.substr(i, i + 18 - 1) == "bootloader started") begin
            message = "INFO: bootloader started";
            break;
        end
    end
endtask

task write_byte(input byte data);
    send_frame_to_uart(1'b0, data, 1'b1);
endtask

task write_word(input int data);
    for (int i = 0; i < 4; ++i) begin
        write_byte(data[7:0]);
        data >>= 8;
    end
endtask

task write(input string message);
    message = {message, "\n"};
    foreach (message[i])
        write_byte(message[i]);
endtask

endinterface
