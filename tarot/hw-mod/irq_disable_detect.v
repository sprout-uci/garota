module irq_disable_detect (
    clk,
    
    pc,
    gie,
        
    reset
);
input           clk;
input   [15:0]  pc;
input           gie;

output          reset;

// MACROS ///////////////////////////////////////////
//
parameter TCB_BASE = 16'h0010;
parameter TCB_SIZE = 16'h0010;
parameter LAST_TCB_ADDR = TCB_BASE + TCB_SIZE - 2;

parameter RESET_HANDLER = 16'h0000;

parameter ON  = 2'b0, OFF = 2'b1, KILL = 2'b10;
//-------------Internal Variables---------------------------
reg[1:0]             state;
reg             gie_reset;
//
initial
    begin
        state = KILL;
		gie_reset <= 1'b1;
    end

wire pc_not_in_tcb = (pc < TCB_BASE) || (pc > (TCB_BASE + TCB_SIZE - 2));
wire pc_in_tcb = !pc_not_in_tcb;

always @(posedge clk)
	if(state == KILL && pc == RESET_HANDLER && !gie)
        state <= OFF;
    else if(state == OFF && gie && pc_in_tcb)
        state <= ON;
    else if(state == OFF && gie && pc_not_in_tcb)
        state <= KILL;
    else if(state == ON && pc_not_in_tcb && !gie)
        state <= KILL;
    else if(state == ON && pc_in_tcb && !gie)
        state <= OFF;
    else state <= state;
    
always @(posedge clk)
	if(state == KILL && !(pc == RESET_HANDLER && !gie))
        gie_reset <= 1'b1;
    else if(state == OFF && gie && pc_not_in_tcb)
        gie_reset <= 1'b1;
    else if(state == ON && pc_not_in_tcb && !gie)
        gie_reset <= 1'b1;
    else gie_reset <= 1'b0;

        
assign reset = gie_reset;

endmodule
