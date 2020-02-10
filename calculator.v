module calculator(	
	input wire CLK,
	input wire RST,	   
	// Input variables
	input 	wire input_stb,
	input 	wire [31:0] input_data,
	input 	wire is_input_operator,
	output 	reg input_ack,	
	// Output variables
	output reg output_stb,
	output reg[31:0] output_data,
	input 	wire output_ack,
);
// Stack Variables
reg push_stack_stb;
reg [31:0] pop_stack_data;
reg pop_stack_stb;
reg [31:0] push_stack_data;

initial
	begin
		output_data = 0;
		output_stb = 0;
		input_ack = 0;
	end

always@(posedge CLK or posedge RST)
	if(output_ack)
		begin
			output_data <= 0;
			output_stb <= 0;
			input_ack <= 0;
		end
		
stack
#(
.WIDTH(32),
.DEPTH(20)
)number_stack(
.CLK(CLK),
.RST(RST),
.PUSH_STB(test_push_stb),
.PUSH_DAT(pop_stack_data),
.POP_STB(test_pop_stb),
.POP_DAT(test_pop_dat)

);
endmodule