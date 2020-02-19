import webbrowser

check_file = open("check.txt","w");
output = open("../../output.txt").readlines()
expect = open("./expect.txt").readlines()
correct = 0;
wrong = 0;
check_file.write( "Output".ljust(20) + "Result".ljust(10) + "Expected".ljust(15) + "Reason" + "\n");
check_file.write( "---------------------------------------------------------------\n");
for output_line, expect_line in zip(output,expect):
    if int(output_line) == int(expect_line):
        correct+=1;
        check_file.write( str(int(output_line)).ljust(20) + "==".ljust(10) + str(int(expect_line)) + "\n")
    else:
        wrong+=1;
        check_file.write( str(int(output_line)).ljust(20) + "!==".ljust(9) + str(int(expect_line)).ljust(15));
        if int(expect_line) > 2147483647 or int(expect_line) < -2147483647:
            check_file.write(" (The expected result is too high for a 32-bit signed int)\n");
        else:
            check_file.write(" (Critical Error!!) \n");
            
check_file.write("From " + str(correct+wrong) + " tests.\n");
check_file.write("The result is correct for " + str(correct)+" tests.\n");
check_file.write("the resilt is wrong for " + str(wrong)+ " tests.\n");
if correct+wrong > 0:
    check_file.write("Correct:" + str(correct*100/float(correct+wrong))+ "%\n");
    if(correct/float(correct+wrong) < 0.5):
        print("The result is too different, the test set may be not the same. ");


check_file.close();
    
print("Successfully check the output.txt and expect.txt");
print("The result is in check.txt");
input("Press any botton to continue to check.txt");
webbrowser.open("check.txt");
