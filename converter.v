/*
Title: Polish Postfix Notation Converter (Shunting-yard algorithm)
Author: Supawat Tamsri <supawat.tamsri@outlook.com>
*/
module converter(	
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
	output 	reg is_output_operator,
	input 	wire output_ack,
);


// Stack Variables
reg push_to_stack_stb; 	// tell stack to remember data
reg pop_from_stack_stb;	// tell stack to pop the top
wire [2:0] pop_data; 	// data from stack 

// States Variables
reg [3:0] state;

// Initialize registers
initial
	begin
	/*IO Registers*/
	input_ack <= 0;
	output_stb <= 0;
	output_data <= 0;
	is_output_operator <= 0;
	/*Stack Registers*/
	push_to_stack_stb <= 0;
	pop_from_stack_stb <= 0;
	/*State Registers*/
	state <= 0;
	end
	
/*
	Symbols representation
	'*' == 001
	'+' == 010
	'-' == 011
	'=' == 100
*/
/*
State Description
0: Check type of input after input_stb
	- deactivate previous stb, ack.
	- check type of input
		if operator == '=', set output_dat, go state:3
		else if stack is empty, go to state:5
		else go to state:4
1: input is number, return input
	- return numbers
	- go to state:2
2: wait for o_ack and go back to state:0
	- wait for output_ack
	- then set output_stb <= 0
3: return an operator and go to state:2
	- deactivate stack stbs (from 4)
	- return operator
	- goto state:2 to wait
4: compare operators.
	- check if priority(input) > priority(pop_data)
		lower, set output = top_stack, push input to stack, go state:3
		higher, go to state:5
5: push the input operator to stack
	- Push input operator to stack
	- set input_ack
	- goto state:0
*/
always @(posedge CLK or posedge RST)
   case(state)
	   0: //Check type of input after input_stb
	   begin
		input_ack <= 0;  // (deactivate input_ack)
		push_to_stack_stb <= 0; // (if comes from state:5)
	   	if(input_stb)
		   	begin						  
				/*input is an operator*/
			  	if(is_input_operator)
					if(input_data[2]) // input operator is '='
						begin
							output_data <= input_data;
							state <= 3;
						end
				  	else if(pop_data[2:0] === 3'bx ) 
						state <= 5; // if stack is empty, go to state:6
					else 
						state <= 4; // compare operators
				/*input is a number*/
				else state <= 1;
			end
		end
	   1: //input is a number, return input number
	   	begin
		  	 output_data <= input_data;
			 output_stb = 1;
			 is_output_operator <= 0; 
			 state <= 2; 	// wait for the ack from output
		end
	   	2: // Wait for output_ack from calculator
	   begin
		   if (output_ack)	// testbench already got output
			   	begin
				   output_std <= 0;
				   input_ack <= 1;
				   state <=0;
				end
		end
		3: // push an operators out
		begin 
			pop_from_stack_stb <= 0; //(if from state:4)
			push_from_stack_stb <= 0; 	 //(if from state:4)
			is_output_operator <= 1;
			output_stb <= 1;
			state <= 2;
		end	
		4: // Compare operators
		begin
			if(input_data[1] > pop_data[1])
				// When op1 has lower priority than stack
				begin
					output_data <= pop_data;   	// take top stack out to output
					pop_from_stack_stb <= 1;	// pop top out from stack
					push_to_stack_stb <=1;    	// push input_operator to stack
					state <= 3;				  	// go to state 3
				end
			else
				// When op1 has higher priority than stack
					state <= 5;
		end
		5: // Push an input operator to stack
		   begin
				push_to_stack_stb <= 1;
				input_ack <= 1;
				state <= 0;
			end
	   endcase
	   
stack #(
.WIDTH(3),
.DEPTH(20)
) operator_stack(
.CLK(CLK),
.RST(RST),
.PUSH_STB(push_to_stack_stb),
.PUSH_DAT(input_data[2:0]),
.POP_STB(pop_from_stack_stb),
.POP_DAT(pop_data)
);
endmodule