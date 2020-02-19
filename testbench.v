/*
Title: Test Bench for Reverse Polish Notation Calculator
Author: Supawat Tamsri <supawat.tamsri@outlook.com>
*/
module testbenchmodule();
	/*--- Clock ---*/
	reg CLK;	  
	initial CLK <= 0;
	always #50 CLK <= ~CLK;
	/*--- Reset ---*/
	reg RST;
	initial
		begin
			RST <= 1'b0;
			RST <= #50 1'b1;
			RST <= #500 1'b0;
		end	
	// FILE INPUT
	integer file_input;
	reg input_stb;
	reg [31:0] input_data;
	integer scan_file;
	// FILE OUTPUT
	integer file_output;
	wire output_stb;
	
	/*--- Between Modules ---*/
		// testbench to converter
	reg is_input_operator;
	wire input_converter_ack;
	   // converter to calculator
	wire output_converer_stb;
	wire [31:0] output_converter_data;
	wire is_output_converter_operator;
	wire output_converter_ack;
	   // calculator to testbench
	wire output_calcualtor_stb;
	wire [31:0] output_calculator_data;
	reg output_calculator_ack;
	
	/*--- Flags ---*/
	reg already_wrote;
	reg already_number;
	reg last_calculation;  
	
	/*---------------------- Initialization ------------------------*/
	initial
		begin
		file_input <= $fopen("input.txt","r");
		input_stb <= 1'b0;
		file_output <= $fopen("output.txt","w");
		input_stb <= 1'b0;
		is_input_operator <= 1'bx;
		output_calculator_ack <= 1'b0;
		input_data <= 32'bx;
		already_wrote <= 1'b0;
		already_number <= 1'b0;
		last_calculation <= 1'b0;
		if(file_input == 0)
			begin
				$display("input file is null");
				$finish;
			end
		end
	/*---------------------- Program ------------------------*/	
	
	/* Read files*/ 
	always@(posedge CLK or posedge RST)
		if(RST)
			begin
			// Reset Registers
			input_stb <= 1'b0;
			is_input_operator <= 1'bx;
			output_calculator_ack <= 1'b0;
			input_data <= 32'bx;
			already_wrote <= 1'b0;
			already_number <= 1'b0; 
			last_calculation <= 1'b0;
			end
		else if(!input_stb)
			begin /* Start Scanning Files*/
				if(!already_number)	 /*--- Scanning Numbers---*/
					begin /*--- Beginning Scanning Numbers---*/
						scan_file = $fscanf(file_input, "%d", input_data); #10;
						if(scan_file)
							begin
							input_stb <= 1'b1;
							already_number <= 1'b1; 
							is_input_operator <= 1'b0;
							scan_file <= 1'b0;
							end
					end	/*--- Ending Scanning Numbers---*/
				else 				/*--- Scanning Numbers---*/
					begin /*--- Beginning Scanning Operators---*/
						// scan operator
					   	scan_file = $fscanf(file_input, "%s", input_data); #10;
						if(scan_file)
							begin /*begin scanning*/
								if(input_data === 32'h2A )
									// operator == '*' == '001'
									input_data <= 32'b001;
								else if(input_data === 32'h2B)
									// operator == '+' == '010'
									input_data <= 32'b010;
								else if(input_data === 32'h2D)
									// operator == '-' == '011'
									input_data <= 32'b011;
								else if(input_data === 32'h3D)
									// operator == '=' == '100'
									input_data <= 32'b100;
								else
									begin
									$display("Unknown Operators");
									$finish;
									end
								input_stb <= 1'b1;
								is_input_operator <= 1'b1;
								already_number <= 1'b0; 
								scan_file <= 1'b0;
								if ($feof(file_input)) last_calculation <= 1'b1;
							end /*end scanning*/
					end /*--- Ending Scanning Operators---*/
				
				end	/* End Scanning Files*/
			 

	
	/* End Reading FIle */	
			
	/* Writing file */
	always@(posedge CLK or posedge RST)
		begin
		if(output_stb && !already_wrote)
			begin
			$fwrite(file_output, "%d\n", $signed(output_calculator_data));
			output_calculator_ack <= 1'b1;
			already_wrote <= 1'b1;
			if(last_calculation)
				begin
					$display("Calculated Successfully");
					$fclose(file_input);
					$fclose(file_output);
					$finish;
				end	
			end
		
		end
	/* End Writing file */
			
	/* Communicate with modules*/
	always@(posedge CLK or posedge RST)
		begin
		if(input_converter_ack && !scan_file) // stop sendning current input_data (trigger scan)
			begin
				input_stb <= 1'b0;
				input_data <= 32'bx;
			end
		if(output_calculator_ack) // triggering ack back
			begin
				output_calculator_ack <= 1'b0;
				already_wrote <= 1'b0;
				already_number <= 1'b0;
			end
		end
	/*---------------------- End Program ------------------------*/
	

converter first_module(	
	.CLK(CLK),
	.RST(RST),	   
	// Input variables
	.input_stb(input_stb),
	.input_data(input_data),
	.is_input_operator(is_input_operator),
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

