`include "memory_protection.v"
`include "irq_detect.v"
`include "irq_disable_detect.v"
`include "atomicity.v"

`ifdef OMSP_NO_INCLUDE
`else
`include "openMSP430_defines.v"
`endif

module garota (
    clk,
    pc,
    data_en,
    data_wr,
    data_addr,
    
    dma_addr,
    dma_en,

    irq,
    
    gie,
    
    reset
);

input           clk;
input   [15:0]  pc;
input           data_en;
input           data_wr;
input   [15:0]  data_addr;
input   [15:0]  dma_addr;
input           dma_en;
input           irq;
input           gie;
output          reset;

parameter RESET_HANDLER = 16'h0000;

parameter PMEM_BASE = 16'hE000;
parameter PMEM_SIZE = 16'h1FFF;
//
parameter INIT_BASE = 16'hE000;
parameter INIT_SIZE = 16'h0040;
//
parameter TCB_BASE = 16'hFAE0;
parameter TCB_SIZE = 16'h03FC;
//
parameter UART_BASE = 16'h0080;
parameter UART_SIZE = 16'h0010;
//
parameter INTR_BASE = 16'h0130;
parameter INTR_SIZE = 16'h00D0;
//
parameter P1_BASE = 16'h0020;
parameter P1_SIZE = 16'h0006;

// TAROT ///////////////////////
wire   pmem_read_only_reset;
memory_protection #(
    .PROTECTED_BASE  (PMEM_BASE),
    .PROTECTED_SIZE  (PMEM_SIZE),
    .TCB_BASE  (TCB_BASE),
    .TCB_SIZE  (TCB_SIZE),
    .RESET_HANDLER  (RESET_HANDLER)
) memory_protection_0 (
    .clk        (clk),
    .pc         (pc),
    .data_addr  (data_addr),
    .w_en       (data_wr),
	.dma_addr	(dma_addr),
    .dma_en     (dma_en),

    .reset      (pmem_read_only_reset) 
);


wire   irqcfg_protection_reset1;
memory_protection #(
    .PROTECTED_BASE  (UART_BASE),
    .PROTECTED_SIZE  (UART_SIZE),
    .TCB_BASE  (TCB_BASE),
    .TCB_SIZE  (TCB_SIZE),
    .RESET_HANDLER  (RESET_HANDLER)
) interrupt_protection_uart (
    .clk        (clk),
    .pc         (pc),
    .data_addr  (data_addr),
    .w_en       (data_wr),
	.dma_addr	(dma_addr),
    .dma_en     (dma_en),

    .reset      (irqcfg_protection_reset1) 
);

wire   irqcfg_protection_reset2;
memory_protection #(
    .PROTECTED_BASE  (INTR_BASE),
    .PROTECTED_SIZE  (INTR_SIZE),
    .TCB_BASE  (TCB_BASE),
    .TCB_SIZE  (TCB_SIZE),
    .RESET_HANDLER  (RESET_HANDLER)
) interrupt_protection_timer (
    .clk        (clk),
    .pc         (pc),
    .data_addr  (data_addr),
    .w_en       (data_wr),
	.dma_addr	(dma_addr),
    .dma_en     (dma_en),

    .reset      (irqcfg_protection_reset2) 
);

wire   irqcfg_protection_reset3;
memory_protection #(
    .PROTECTED_BASE  (P1_BASE),
    .PROTECTED_SIZE  (P1_SIZE),
    .TCB_BASE  (TCB_BASE),
    .TCB_SIZE  (TCB_SIZE),
    .RESET_HANDLER  (RESET_HANDLER)
) interrupt_protection_gpio (
    .clk        (clk),
    .pc         (pc),
    .data_addr  (data_addr),
    .w_en       (data_wr),
	.dma_addr	(dma_addr),
    .dma_en     (dma_en),

    .reset      (irqcfg_protection_reset3) 
);

wire    atomicity_tcb;
atomicity #(
    .SMEM_BASE  (TCB_BASE),
    .SMEM_SIZE  (TCB_SIZE),
    .RESET_HANDLER  (RESET_HANDLER)
) atomicity_tcb_0 (
    .clk        (clk),
    .pc         (pc),
    .irq        (irq),
    .reset      (atomicity_tcb)
);

wire    irq_tcb;
irq_detect #(
    .PROTECTED_BASE  (TCB_BASE),
    .PROTECTED_SIZE  (TCB_SIZE),
    .RESET_HANDLER  (RESET_HANDLER)
) irq_tcb_0 (
    .clk        (clk),
    .pc         (pc),
    .irq        (irq),
	.dma_en		(dma_en),
    .reset      (irq_tcb)
);

wire    no_irq_disable;
irq_disable_detect #(
    .TCB_BASE  (TCB_BASE),
    .TCB_SIZE  (TCB_SIZE),
    .RESET_HANDLER  (RESET_HANDLER)
) irq_disable_detect_0 (
    .clk        (clk),
    .pc         (pc),
    .gie        (gie),
    .reset      (no_irq_disable)
);

// END_TAROT ///////////////////////

wire garota_rst = pmem_read_only_reset | irqcfg_protection_reset1 | irqcfg_protection_reset2 | irqcfg_protection_reset3 | atomicity_tcb | irq_tcb | no_irq_disable;
assign reset = garota_rst;  

endmodule
