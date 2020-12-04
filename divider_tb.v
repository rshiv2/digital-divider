`timescale 1ns / 1ps

module divider_tb();
    reg clk, reset, solve;
    
    reg [7:0] divisor, dividend;
    wire [7:0] quotient;
    wire [7:0] remainder = dividend;
    
    divider DUT(
        .clk(clk),
        .reset(reset),
        
        .solve(solve),
        .input_divisor(divisor),
        .input_remainder(dividend),
        .quotient(quotient),
        .output_remainder(remainder)
    );
    
    initial begin
        clk = 1'b0; reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        divisor = 8'd2;
        dividend = 8'd17;
        solve = 1'b0;
        #20;
        
        repeat (2) #10 solve = ~solve;
        
        #250;
        
        divisor = 8'd6;
        dividend = 8'd255;
        repeat (2) #10 solve = ~solve;
        
        #250;
        
        divisor = 8'd2;
        dividend = 8'd17;
        #4;
        solve = 1'b1;
        #16;
        solve = 1'b0;
        
        #250
        $finish;
    end
endmodule
