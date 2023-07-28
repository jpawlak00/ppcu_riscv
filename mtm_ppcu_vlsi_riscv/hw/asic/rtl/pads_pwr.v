// Library - PPCU_VLSI_RISCV, Cell - pads_pwr, View - schematic
// LAST TIME SAVED: Apr  6 13:36:45 2020
// NETLIST TIME: Apr  6 16:46:17 2020
`timescale 1ns / 1ns

// TODO: provide proper number of power pads
// Note: the module must be set to "dont_touch" in the constraints

`ifdef KMIE_IMPLEMENT_ASIC

module pads_pwr ( );

//-- pad instances are note connected

//------------------------------------------------------------------------------
// TODO: add the correct number of the power pads
//------------------------------------------------------------------------------

// core vdd
PVDD1DGZ VDD1_1_ ( .VDD() );
PVDD1DGZ VDD1_0_ ( .VDD() );
    
// io vdd    
PVDD2DGZ VDD2_1_ ( .VDDPST() );
PVDD2DGZ VDD2_0_ ( .VDDPST() );
    
// io power on control (only one)
PVDD2POC VDD2POC ( .VDDPST() );
    
// common ground    
PVSS3DGZ VSS3_1_ ( .VSS() );
PVSS3DGZ VSS3_0_ ( .VSS() );

endmodule

`endif