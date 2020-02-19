/*
Title: Implemented Stack for adjustable bit length and stack depth
Author: Supawat Tamsri <supawat.tamsri@outlook.com>
Source: https://github.com/SupawatDev/RPN-Calculator/
*/
module stack	  
#( 
// default: 32-bits data with 100 layers of stack. 
parameter WIDTH = 32,
parameter DEPTH = 100
)
(                            
input  wire        CLK,      
input  wire        RST,                      
input  wire        PUSH_STB, 
input  wire [WIDTH-1:0] PUSH_DAT,                            
input  wire        POP_STB,  
output wire [WIDTH-1:0] POP_DAT  
);                           
reg    	[DEPTH-1:0] ptr;
reg		[WIDTH-1:0] stack[0:DEPTH-1];

always@(posedge CLK or posedge RST)
begin
 if(RST) ptr <= 0;
 else if(PUSH_STB)
  ptr <= ptr + 1;  
 else if(POP_STB)
  ptr <= ptr - 1;
end
always@(posedge CLK or posedge RST)
	if(PUSH_STB)
			stack[ptr] <= PUSH_DAT;
assign 	POP_DAT = stack[ptr-1];

endmodule
