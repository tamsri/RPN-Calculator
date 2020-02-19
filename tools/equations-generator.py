import random
import time
import sys
ops = ['*', '+', '-'];
file_equation = open("../../input.txt","w");
file_expect = open("./expect.txt", "w");

test_n = input("Enter the number of test: ");
try:
    test_n = int(test_n);
except:
    print("Invalid input, test_n is set to 50 as default.");
    test_n = 100;

    
for i in range (0,test_n):
    equation = '';
    j =random.randrange(4,6,2)   
    for m in range(0,j):
        equation += str(random.randint(-200,200))+' ';
        if(m != j-1):
            equation += random.choice(ops) + ' ';
        else:
            equation += '=';
    file_expect.write(str(eval(equation[0:-1]))+'\n');        
    print("{0:d}) ".format(i+1) + equation, end ='\n');
    if(i==0):
        file_equation.write(equation);
    else:
        file_equation.write('\n'+equation);

file_equation.close();
file_expect.close();

print("Generated the input and expected file.");
print("Next, Execute run the simulation to get output.txt");
print("Finally, Compare the result with check-expected-output.py");
input("(Press any botton to exit)");
    
