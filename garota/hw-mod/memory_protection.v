
module  memory_protection (
    clk,
    pc,
    data_addr,
    w_en,
	dma_addr,
    dma_en,

    reset
);

input           clk;
input   [15:0]  pc;
input   [15:0]  data_addr;
input           w_en;
input   [15:0]  dma_addr;
input           dma_en;

output          reset;

// MACROS OVERWRITTEN BY EXTERNAL VALUES ///////////////////////////////////////////
parameter PROTECTED_BASE = 16'h0010;
parameter PROTECTED_SIZE = 16'h0010;
//
parameter TCB_BASE = 16'h0010;
parameter TCB_SIZE = 16'h0010;
/////////////////////////////////////////////////////

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

wire cpu_protected_access = (data_addr >= PROTECTED_BASE) && (data_addr < (PROTECTED_BASE + PROTECTED_SIZE)) && w_en;
wire dma_protected_access = (dma_addr >= PROTECTED_BASE) && (dma_addr < (PROTECTED_BASE + PROTECTED_SIZE)) && dma_en;

wire pc_not_in_tcb = (pc < TCB_BASE) || (pc > (TCB_BASE + TCB_SIZE - 2));
wire pc_in_tcb = !pc_not_in_tcb;

wire violation1 = cpu_protected_access && pc_not_in_tcb;
wire violation2 = dma_protected_access;

always @(posedge clk)
if( state == RUN && (violation1 || violation2))
    state <= KILL;
else if (state == KILL && pc == RESET_HANDLER && !violation1 && !violation2)
    state <= RUN;
else state <= state;

always @(posedge clk)
if (state == RUN && (violation1 || violation2))
    key_res <= 1'b1;
else if (state == KILL && pc == RESET_HANDLER && !violation1 && !violation2)
    key_res <= 1'b0;
else if (state == KILL)
    key_res <= 1'b1;
else if (state == RUN)
    key_res <= 1'b0;
else key_res <= 1'b0;

assign reset = key_res;

endmodule

