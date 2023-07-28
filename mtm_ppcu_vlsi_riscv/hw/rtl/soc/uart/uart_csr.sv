/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

package uart_csr;


/**
 * Memory map
 */

const logic [11:0] UART_CR_OFFSET = 12'h000,    /* control register */
                   UART_SR_OFFSET = 12'h004,    /* status register */
                   UART_TDR_OFFSET = 12'h008,   /* transmitter data register */
                   UART_RDR_OFFSET = 12'h00c,   /* receiver data register */
                   UART_CDR_OFFSET = 12'h010,   /* clock divider register */
                   UART_IER_OFFSET = 12'h014,   /* interrupt enable register */
                   UART_ISR_OFFSET = 12'h018;   /* interrupt status register */


/**
 * User defined types
 */

typedef struct packed {
    logic [30:0] res;
    logic        en;
} uart_cr_t;

typedef struct packed {
    logic [28:0] res;
    logic        rxerr;
    logic        txact;
    logic        rxne;
} uart_sr_t;

typedef struct packed {
    logic [23:0] res;
    logic [7:0]  data;
} uart_tdr_t;

typedef struct packed {
    logic [23:0] res;
    logic [7:0]  data;
} uart_rdr_t;

typedef struct packed {
    logic [23:0] res;
    logic [7:0]  data;
} uart_cdr_t;

typedef struct packed {
    logic [29:0] res;
    logic        txactie;
    logic        rxneie;
} uart_ier_t;

typedef struct packed {
    logic [29:0] res;
    logic        txactf;
    logic        rxnef;
} uart_isr_t;

typedef struct packed {
    uart_cr_t  cr;
    uart_sr_t  sr;
    uart_tdr_t tdr;
    uart_rdr_t rdr;
    uart_cdr_t cdr;
    uart_ier_t ier;
    uart_isr_t isr;
} uart_csr_t;

endpackage
