# Reverse Polish Notation Calculator in Verilog
RPN calculator in Verilog reads the input file and writes the calculation result to the output file. The program performs 32-bit signed bit calculations parallelly between modules and testbench. the calculator consists only operator *, +, -, and = at the end of the equation.  
## Main Modules
#### Infix to Postfix Converter
The module in "converter.v" does receive the input from testbench and convert output to "calculator.v" following Shunting-Yard Algorithm. 
#### Postfix Calculator
the module evaluates the input numbers and operation and store it until "=" appears in the module and push the result out to the testbench.

### Varibles
for the performance, the variables are defined to minimum default length, can be changed as demand.
#### Registers 
* Output: 32 bits
* Converter State: 3 bits
* Calculator State: 4 bits
* Operator Stack Width: 3 bits
* Operator Stack Depth: 20 operators
* Number Stack Width: 32 bits
* Number Stack Depth: 20 numbers
#### Operators
* '*' Operator defined as 001
* '+' Operator defined as 010
* '-' Operator defined as 011
* '=' Operator defined as 100

## Getting Started
1) Import code to Active-HDL
2) Run the simulation

## Testing
Testing can be performed by,
* Generate input.txt for the testbench by executing "tools/equations-generator.py"
* Run the simulation and receive the result in output.txt 
* Execute "tools/check-expected-output.py" and the check result is in "tools/check.txt"