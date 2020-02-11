/*
Title: Test Bench for Reverse Polish Notation Calculator
Author: Supawat Tamsri <supawat.tamsri@outlook.com>
*/
module testbenchmodule();
	// Clock Setup
	reg CLK;	  
	initial CLK <= 0;
	always #50 CLK <= ~CLK;
	// Reset Setup
	reg RST;
	initial
		begin
			RST <= 0;
			RST <= #50 1;
			RST <= #500 0;
		end
	// FILE INPUT
	integer file_input;
	reg input_stb;
	// FILE OUTPUT
	integer file_output;
	wire output_stb;
	// Initialize Files
	initial
		begin
			file_input = $fopen("input.txt","r");
			input_stb = 0;
			file_output = $fopen("output.txt","w");
		end
	/* Read files*/ 
	always@(posedge CLK or posedge RST)
		if(!RST)
			begin

			end
	/* Write file */
	always@(posedge CLK or posedge RST)
		if(output_stb)
			begin
			$fwrite(file_output, "%d\n", output_calculator_data);
			output_calculator_ack <= 1;
			end
			
	reg input_converter_stb;
	reg [31:0] input_converter_data; 
	reg is_input_converter_operator;
	wire input_converter_ack;
	
	wire output_converer_stb;
	wire [31:0] output_converter_data;
	wire is_output_converter_operator;
	wire output_converter_ack;
	
	wire output_calcualtor_stb;
	wire [63:0] output_calculator_data;
	reg output_calculator_ack;

converter first_module(	
	.CLK(CLK),
	.RST(RST),	   
	// Input variables
	.input_stb(input_stb),
	.input_data(input_converter_data),
	.is_input_operator(is_input_converter_operator),
	.input_ack(input_converter_ack),	
	// Output variables
	.output_stb(output_converter_stb),
	.output_data(output_converter_data),
	.is_output_operator(is_output_converter_operator),
	.output_ack(output_converter_ack)
);

calculator second_module(
 	.CLK(CLK),
	.RST(RST),	   
	// Input variables
	.input_stb(output_converter_stb),
	.input_data(output_converter_data),
	.is_input_operator(is_output_converter_operator),
	.input_ack(output_converter_ack),	
	// Output variables
	.output_stb(output_stb),
	.output_data(output_calculator_data),
	.output_ack(output_calculator_ack)
);
	
endmodule		 	

