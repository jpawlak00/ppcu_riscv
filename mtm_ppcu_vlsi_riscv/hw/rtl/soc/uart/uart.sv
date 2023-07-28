/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

module uart
    import uart_csr::*;
(
    input logic    clk,
    input logic    rst_n,

    data_bus.slave dbus,

    output logic   sout,
    input logic    sin
);


/**
 * Local variables and signals
 */

uart_csr_t  csr, csr_nxt;
logic [7:0] rx_data;
logic       tx_data_valid, rx_data_valid, clk_divider_valid, tx_busy, rx_error,
            sck_rising_edge;


/**
 * Submodules placement
 */

uart_clock_generator u_uart_clock_generator (
    .clk,
    .rst_n,

    .sck(),
    .rising_edge(sck_rising_edge),
    .falling_edge(),
    .en(csr.cr.en),
    .clk_divider_valid,
    .clk_divider(csr.cdr.data)
);

uart_transmitter u_uart_transmitter (
    .clk,
    .rst_n,

    .busy(tx_busy),
    .sck_rising_edge,
    .tx_data_valid,
    .tx_data(csr.tdr.data),

    .sout
);

uart_receiver u_uart_receiver (
    .clk,
    .rst_n,

    .busy(),
    .rx_data_valid,
    .rx_data,
    .error(rx_error),
    .sck_rising_edge,

    .sin
);


/**
 * Tasks and functions definitions
 */

function automatic logic is_offset_valid(logic [11:0] offset);
    return offset inside {
        UART_CR_OFFSET, UART_SR_OFFSET, UART_TDR_OFFSET, UART_RDR_OFFSET, UART_CDR_OFFSET,
        UART_IER_OFFSET, UART_ISR_OFFSET
    };
endfunction

function automatic logic is_reg_written(logic [11:0] offset);
    return dbus.req && dbus.we && dbus.addr[11:0] == offset;
endfunction

function automatic logic is_reg_read(logic [11:0] offset);
    return dbus.req && dbus.addr[11:0] == offset;
endfunction


/**
 * Properties and assertions
 */

assert property (@(negedge clk) dbus.req |-> is_offset_valid(dbus.addr[11:0])) else
    $warning("incorrect offset requested: 0x%x", dbus.addr[11:0]);


/**
 * Module internal logic
 */

always_comb begin
    dbus.gnt = dbus.req;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dbus.rvalid <= 1'b0;
    else
        dbus.rvalid <= dbus.gnt;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        csr <= {{7{32'b0}}};
        tx_data_valid <= 1'b0;
        clk_divider_valid <= 1'b0;
    end else begin
        csr <= csr_nxt;
        tx_data_valid <= is_reg_written(UART_TDR_OFFSET);
        clk_divider_valid <= is_reg_written(UART_CDR_OFFSET);
    end
end

always_comb begin
    csr_nxt = csr;

    if (dbus.req && dbus.we) begin
        case (dbus.addr[11:0])
        UART_CR_OFFSET:     csr_nxt.cr = dbus.wdata;
        UART_SR_OFFSET:     csr_nxt.sr = dbus.wdata;
        UART_TDR_OFFSET:    csr_nxt.tdr = dbus.wdata;
        UART_RDR_OFFSET:    csr_nxt.rdr = dbus.wdata;
        UART_CDR_OFFSET:    csr_nxt.cdr = dbus.wdata;
        UART_IER_OFFSET:    csr_nxt.ier = dbus.wdata;
        UART_ISR_OFFSET:    csr_nxt.isr = dbus.wdata;
        endcase
    end

    if (rx_error)
        csr_nxt.sr.rxerr = 1'b1;

    csr_nxt.sr.txact = tx_busy;

    if (rx_data_valid)
        csr_nxt.sr.rxne = 1'b1;
    else if (is_reg_read(UART_RDR_OFFSET))
        csr_nxt.sr.rxne = 1'b0;

    if (rx_data_valid)
        csr_nxt.rdr.data = rx_data;

    if (csr.sr.txact && !csr_nxt.sr.txact)
        csr_nxt.isr.txactf = 1'b1;

    if (!csr.sr.rxne && csr_nxt.sr.rxne)
        csr_nxt.isr.rxnef = 1'b1;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dbus.rdata <= 32'b0;
    end else begin
        if (dbus.req) begin
            case (dbus.addr[11:0])
            UART_CR_OFFSET:     dbus.rdata <= csr.cr;
            UART_SR_OFFSET:     dbus.rdata <= csr.sr;
            UART_TDR_OFFSET:    dbus.rdata <= csr.tdr;
            UART_RDR_OFFSET:    dbus.rdata <= csr.rdr;
            UART_CDR_OFFSET:    dbus.rdata <= csr.cdr;
            UART_IER_OFFSET:    dbus.rdata <= csr.ier;
            UART_ISR_OFFSET:    dbus.rdata <= csr.isr;
            endcase
        end
    end
end

endmodule
