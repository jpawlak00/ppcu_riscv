/**
 * Copyright (C) 2022  AGH University of Science and Technology
 */

package gpio_csr;


/**
 * Memory map
 */

const logic [11:0] GPIO_ODR_OFFSET = 12'h000,   /* output data register */
                   GPIO_IDR_OFFSET = 12'h004;   /* input data register */


/**
 * User defined types
 */

typedef struct packed {
    logic [31:0] idr;
    logic [31:0] odr;
} gpio_csr_t;

endpackage
