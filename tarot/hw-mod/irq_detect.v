
module  irq_detect (
    clk,
    pc,
	irq,
	dma_en,

    reset
);
input           clk;
input   [15:0]  pc;
input			irq;
input			dma_en;

output          reset;

// MACROS ///////////////////////////////////////////
parameter PROTECTED_BASE = 16'h0010;
parameter PROTECTED_SIZE = 16'h0010;
/////////////////////////////////////////////////////



parameter LAST_PROTECTED_ADDR = PROTECTED_BASE + PROTECTED_SIZE - 2;

parameter RESET_HANDLER = 16'h0000;
parameter RUN  = 1'b0, KILL = 1'b1;
//-------------Internal Variables---------------------------
reg             state;
reg             key_res;
//

initial
    begin
        state = KILL;
        key_res = 1'b1;
    end

wire is_in_protected = pc >= PROTECTED_BASE && pc <= LAST_PROTECTED_ADDR;

wire invalid_irq = is_in_protected && (irq || dma_en);

always @(posedge clk)
if( state == RUN && invalid_irq) 
    state <= KILL;
else if (state == KILL && pc == RESET_HANDLER && !invalid_irq)
    state <= RUN;
else state <= state;

always @(posedge clk)
if (state == RUN && invalid_irq)
    key_res <= 1'b1;
else if (state == KILL && pc == RESET_HANDLER && !invalid_irq)
    key_res <= 1'b0;
else if (state == KILL)
    key_res <= 1'b1;
else if (state == RUN)
    key_res <= 1'b0;
else key_res <= 1'b0;

assign reset = key_res;

endmodule
