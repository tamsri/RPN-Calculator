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
	
	always@(posedge CLK or posedge RST)
		if(!RST)
			begin

			end
			
	always@(posedge CLK or posedge RST)
		if(output_stb)
			begin
			$fwrite(file_output, "%d\n", output_calculator_data);
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
	
	reg test_push_stb;
	reg [5:0] test_push_dat;
	reg test_pop_stb;
	wire [5:0] test_pop_dat;
	
	initial
		begin
			test_push_stb <= 0;
			test_push_dat <= 0;
			test_pop_stb <= 0;
			#1000;
			@(negedge CLK);
			test_push_stb <= 1;
			test_push_dat <= 8'd3; @(negedge CLK);
			test_push_dat <= 8'd12; @(negedge CLK);
			test_push_dat <= 8'd2; @(negedge CLK);
			test_push_dat <= 8'd18; @(negedge CLK);
			test_push_dat <= 4'd11; @(negedge CLK);
			test_push_stb <= 0;
			#1000;
			@(negedge CLK);
			test_pop_stb <= 1;	@(negedge CLK);
			test_pop_stb <= 0; 	   
			#1100;
			@(negedge CLK);
			test_pop_stb <= 1;	@(negedge CLK);
			test_pop_stb <= 0; 	   
			#1200;
			@(negedge CLK);
			test_pop_stb <= 1;	@(negedge CLK);
			test_pop_stb <= 0; 
		end
stack
#(
.WIDTH(4),
.DEPTH(10)
)test_stack(
.CLK(CLK),
.RST(RST),
.PUSH_STB(test_push_stb),
.PUSH_DAT(test_push_dat),
.POP_STB(test_pop_stb),
.POP_DAT(test_pop_dat)

);//*/
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
