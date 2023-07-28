/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

module gpio
    import gpio_csr::*;
(
    input logic         clk,
    input logic         rst_n,

    data_bus.slave      dbus,

    output logic [31:0] dout,
    input logic [31:0]  din
);


/**
 * Local variables and signals
 */

gpio_csr_t csr, csr_nxt;


/**
 * Signals assignments
 */

assign dout = csr.odr;


/**
 * Tasks and functions definitions
 */

function automatic logic is_offset_valid(logic [11:0] offset);
    return offset inside {GPIO_ODR_OFFSET, GPIO_IDR_OFFSET};
endfunction

function automatic logic is_reg_written(logic [11:0] offset);
    return dbus.req && dbus.we && dbus.addr[11:0] == offset;
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
    if (!rst_n)
        csr <= '0;
    else
        csr <= csr_nxt;
end

always_comb begin
    csr_nxt = csr;

    if (dbus.req && dbus.we) begin
        case (dbus.addr[11:0])
        GPIO_ODR_OFFSET:    csr_nxt.odr = dbus.wdata;
        GPIO_IDR_OFFSET:    csr_nxt.idr = dbus.wdata;
        endcase
    end

    csr_nxt.idr = din;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dbus.rdata <= 32'b0;
    end else begin
        if (dbus.req) begin
            case (dbus.addr[11:0])
            GPIO_ODR_OFFSET:    dbus.rdata <= csr.odr;
            GPIO_IDR_OFFSET:    dbus.rdata <= csr.idr;
            endcase
        end
    end
end

endmodule
