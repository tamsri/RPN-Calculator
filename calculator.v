/*
Title: Polish Postfix Notation Calculator
Author: Supawat Tamsri <supawat.tamsri@outlook.com>
*/
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
	output reg	[64:0] output_data,
	input 	wire output_ack,
);
// Stack Variables
reg push_stb;
wire [31:0] pop_data;
reg pop_stb;
reg [31:0] push_data;
reg [3:0] state;

reg [31:0] right_number;
reg [31:0] left_number;

initial
		begin
			/*IO Registers*/
			output_data <= 0;
			output_stb <= 0;
			input_ack <= 0;
			/*State Registers*/
			state <= 0;
			right_number <= 32'bx;
			left_number <= 32'bx;
			/*Stack Registers*/
			push_stb <= 0;
			pop_stb <= 0;
		end
	
/*
State Description
0: Check type of input after input_stb
1: if input is number, push to stack, input_ack = 1, go state:0
2: if input is operator, push top to right_number, go state 3 (wait for pop done next state)
3: assign another top to the left-side, go state 4 (wait for pop done next state)
4: stop pop, check type of operation, do operations and push result back to top stack (push_stb) go 0
5: finish all operations, output the data, go state 6
6: wait for the output_ack, then go state 0
*/
always@(posedge CLK or posedge RST)
	if(RST)
		begin
			/*IO Registers*/
			output_data <= 0;
			output_stb <= 0;
			input_ack <= 0;
			/*State Registers*/
			state <= 0;
			right_number <= 32'bx;
			left_number <= 32'bx;
			/*Stack Registers*/
			push_stb <= 0;
			pop_stb <= 0;
		end
	else
	case(state)
		0: // Check type of input after input_stb
		begin
			right_number <= 32'bx;
			left_number <= 32'bx;
			if(input_stb)
				begin
					if(is_input_operator === 1'b1)
						begin
						  	if(input_data[2] === 1'b1) 
								// input == '='
								state <= 5;
							else 
								state <= 2;
						end
					else
						state <= 1;
				end
		end
		1: // input is number, push to the stack, input_ack, and go state:0
		begin
			push_data <= input_data;
			push_stb <= 1;
			state <= 7;
			input_ack <= 1;
		end
		2: // pop the top number to right_number;
		begin
			right_number <= pop_data;
			pop_stb <= 1;
			state <= 3;
		end
		3: // pop the top number to left_number;
		begin
			pop_stb <= 0;
			if(right_number != 32'bx) // wait for the register get stored 
				begin
				left_number <= pop_data;
				state <= 4;
				end
		end	
		4: // operate left_number and right_number
		begin
			pop_stb <= 0;
			push_stb <= 1;
			state <= 0;
			if(input_data[1:0] == 2'b01)
				push_data <= left_number*right_number;
			else if(input_data[1:0] == 2'b10)
				push_data <= left_number+right_number;
			else if (input_data[1:0] == 2'b11)
				push_data <= left_number-right_number;
		end
		5: // end the calculation
		begin
			output_data <= pop_data;
			pop_stb <= 1;
			output_stb <= 1;
			state <= 7;
		end
		6: // wait for output_ack
		begin
			if(output_ack)
				begin
					output_stb <= 0;
					state <= 7;
					output_data <= 32'bx;
				end
		end
		7: // end state
		begin
			input_ack <= 0;
			output_stb <= 0;
			pop_stb <= 0;
			push_stb <= 0;
			state <= 0;
		end
	endcase
stack
#(
.WIDTH(32),
.DEPTH(20)
)number_stack(
.CLK(CLK),
.RST(RST),
.PUSH_STB(push_stb),
.PUSH_DAT(push_data),
.POP_STB(pop_stb),
.POP_DAT(pop_data)

);
endmodule		 

