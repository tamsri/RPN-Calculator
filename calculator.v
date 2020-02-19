/*
Title: Polish Postfix Notation Calculator
Author: Supawat Tamsri <supawat.tamsri@outlook.com>
Source: https://github.com/SupawatDev/RPN-Calculator/
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
	output reg	[31:0] output_data,
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
				output_data <= 32'bx;
				output_stb <= 0;
				input_ack <= 0;
				/*State Registers*/
				state <= 0;
				right_number <= 32'bx;
				left_number <= 32'bx;
				/*Stack Registers*/
				push_stb <= 0;
				pop_stb <= 0;
				push_data <= 32'bx;
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
		/*State Description
		Symbols representation
			'*' == 001
			'+' == 010
			'-' == 011
			'=' == 100
	States
	0: Check type of input after input_stb
		- if a number, push to the stack, go state 7
		- if an operator,
				if "=", go to state 1
				else, go state 2 (compare ops)
	1: end the calculation
		- pop the top stack out
	2: store the top stack to right number
	3: wait for right get stored, pop top stack out
		- go state 4
	4: store another top stack to left number
		- go state 5
	5: wait for the left get stored
		- operate the right and left numbers following input operator
		- put the result to push_data
		- go state 6
	6: wait for push_data get stored
		- push the result to stack
		- go state 7
	7: end of states
		- Flip the triggering back to normal
		- Go to state 0
	8: Wait for output to ackowledge
		- Go back to state 0
	*/ 
	always@(posedge CLK or posedge RST)
		if(RST)
			begin
				/*IO Registers*/
				output_data <= 32'bx;
				output_stb <= 1'b0;
				input_ack <= 1'b0;
				/*State Registers*/
				state <= 4'd0;
				right_number <= 32'bx;
				left_number <= 32'bx;
				/*Stack Registers*/
				push_stb <= 1'b0;
				pop_stb <= 1'b0;
				push_data <= 32'bx;
			end
		else
		case(state)
			0: // Check type of input after input_stb
			begin
				if(input_stb)
					begin
						if(is_input_operator === 1'b1) // input is an operator
								if(input_data[2] === 1'b1) state <= 1; // input is '='
								else state <= 4'd2;
						else // input is a number
							begin
								push_data <= input_data;
								push_stb <= 1'b1;
								state <= 4'd7;
								input_ack <= 1'b1;	
							end
					end
			end	 
			1: // End the calculation
			begin
				output_data <= pop_data;
				pop_stb <= 1'b1;
				push_stb <= 1'b0;
				output_stb <= 1'b1;
				state <= 4'd8;
				input_ack <= 1'b1;
			end
			2: // Pop the top number to right_number;
			begin
				right_number <= pop_data;
				pop_stb <= 1'b1;
				state <= 4'd3;
			end
			3: // Pop the top number to left_number;
			begin
				if(right_number !== 32'bx) // wait for the register get stored 
					begin
					pop_stb <= 1'b0;
					state <= 4'd4;
					end
			end	
			4:	// Assign pop_data to left_number 
			begin
				left_number <= pop_data;
				pop_stb <= 1'b1;
				state <= 4'd5;
			end
			5: // Operate left_number and right_number
			begin
				if(left_number !== 32'bx)// wait for the register get stored 
					begin
						pop_stb <= 1'b0;
						state <= 4'd6;
						if(input_data[1:0] == 2'b01)
							push_data <= left_number*right_number;
						else if(input_data[1:0] == 2'b10)
							push_data <= left_number+right_number;
						else if (input_data[1:0] == 2'b11)
							push_data <= left_number-right_number;
					end
			end
			6:	// Wait for push_data get stored
			begin
				pop_stb <=0;
				if(push_data !== 32'bx)
					begin
						push_stb <= 1'b1;
						input_ack <= 1'b1;
						state <= 4'd7;
					end
			end
			7: // End states
			begin
				input_ack <= 1'b0;
				output_stb <= 1'b0;
				pop_stb <= 1'b0;
				push_stb <= 1'b0;
				state <= 4'd0;
				right_number <= 32'bx;
				left_number <= 32'bx;
				push_data <= 32'bx;
			end
			8: // Wait for output_ack
			begin 
				pop_stb <= 1'b0;
				input_ack <= 1'b0;
				if(output_ack)
					begin
						output_stb <= 1'b0;
						output_data <= 32'bx;
						state <= 4'd0;
					end
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

