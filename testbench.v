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
	/*---------------------- Program ------------------------*/
	// FILE INPUT
	integer file_input;
	reg input_stb;
	reg [31:0] input_data;
	reg end_read;
	integer scan_file;
	// FILE OUTPUT
	integer file_output;
	wire output_stb;
	// Between Modules
		// testbench to converter
	reg is_input_converter_operator;
	wire input_converter_ack;
	   // converter to calculator
	wire output_converer_stb;
	wire [31:0] output_converter_data;
	wire is_output_converter_operator;
	wire output_converter_ack;
	   // calculator to testbench
	wire output_calcualtor_stb;
	wire [63:0] output_calculator_data;
	reg output_calculator_ack;
	
	initial
		begin
		file_input <= $fopen("input.txt","r");
		input_stb <= 1'b0;
		file_output <= $fopen("output.txt","w");
		end_read <= 0;
		
		input_stb <= 1'b0;
		is_input_converter_operator <= 1'bx;
		output_calculator_ack <= 1'b0;
		input_data <= 32'bx;
		if (file_input == 0)
			begin
				$display("input file is null");
				$finish;
				end_read <= 1;
			end
		end
		
	/* Read files*/ 
	always@(posedge CLK or posedge RST)
		if(RST)
		begin
			// reset registers
			input_stb <= 1'b0;
			is_input_converter_operator <= 1'bx;
			output_calculator_ack <= 1'b0;
			input_data <= 32'bx;
		end
		else
		if(!input_stb && !end_read)
			begin			  
			scan_file = $fscanf(file_input, "%s", input_data);
			#10;
			if(scan_file)
					begin
				if(input_data == 8'h2A )
					begin // operator == '*'
							input_data <= 8'b001;
							is_input_converter_operator <= 1;
					end
				else if(input_data == 8'h2B)
					begin // operator == '+'
							input_data <= 8'b010;
							is_input_converter_operator <= 1;
					end
				else if(input_data == 8'h2D)
					begin // operator == '-'
							input_data <= 8'b011;
							is_input_converter_operator <= 1; 
					end
				else if(input_data == 8'h3D)
					begin // operator == '='
						  	input_data <= 8'b100;
							is_input_converter_operator <= 1;
							end_read <= 1;
					end
				else
					begin
						input_data <= input_data - 48;
						is_input_converter_operator <= 0;
					end
				input_stb <= 1;
				scan_file <= 0;
				end
			else
				begin
					input_data <= 32'bx;
					is_input_converter_operator <= 1'bx;
					input_stb <= 0;
				end
			end
	/* Write file */
	always@(posedge CLK or posedge RST)
		if(output_stb)
			begin
			$fwrite(file_output, "%d", output_calculator_data);
			output_calculator_ack <= 1;
			end
	/* Communicate with modules*/
	always@(posedge CLK or posedge RST)
		if(input_converter_ack) input_stb <= 0;
	/*---------------------- End ------------------------*/
	

converter first_module(	
	.CLK(CLK),
	.RST(RST),	   
	// Input variables
	.input_stb(input_stb),
	.input_data(input_data),
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

