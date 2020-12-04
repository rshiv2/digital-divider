`define WAIT        2'b00
`define SHIFT_QUO   2'b01
`define SHIFT_DIV   2'b10

module divider(
    input wire clk, reset,
    input wire solve,
    input wire [7:0] input_divisor, input_remainder,
    output wire [7:0] quotient, output_remainder);
    
// ITERATION LOGIC
wire [4:0] num_iterations;
reg [4:0] d;

always @(*) begin
    if (state == `WAIT)
        d = 4'd0;
    else if (state == `SHIFT_DIV)
        d = num_iterations + 1;
    else
        d = num_iterations;
end

dffr #(5) iteration_dff (.clk(clk), .r(reset), .d(d), .q(num_iterations));


// SEQUENTIAL LOGIC
wire [2:0] state; reg [2:0] next;
dffr #(3) state_dff (.clk(clk), .r(reset), .d(next), .q(state));

always @(*) begin
    case(state)
        `WAIT:      next = solve ? `SHIFT_QUO : `WAIT;
        `SHIFT_QUO: next = num_iterations == 5'd8 ? `WAIT : `SHIFT_DIV; // not sure whether the ternary/branch backto WAIT should be here
        `SHIFT_DIV: next = `SHIFT_QUO;                                  // or here
    endcase
end


// DIVISOR LOGIC
wire [15:0] divisor;
reg [15:0] divisor_d;

always @(*) begin
    if (state == `WAIT && solve)
        divisor_d = {input_divisor, 8'b0};
    else if (state == `SHIFT_DIV)
        divisor_d = divisor >> 1'd1;
    else
        divisor_d = divisor;
end

dffr #(16) divisor_dff(.clk(clk), .r(reset), .d(divisor_d), .q(divisor));


// REMAINDER LOGIC
wire [15:0] remainder;
wire [15:0] diff = remainder - divisor;
reg [15:0] remainder_d;

always @(*) begin
    if (state == `WAIT && solve)
        remainder_d = input_remainder;
    else if (diff[15])
        remainder_d = remainder;        // if remainder < divisor, keep remainder the same
    else
        remainder_d = diff;             // if remainder > divisor, set remainder equal to difference
end

dffr #(16) remainder_dff (.clk(clk), .r(reset), .d(remainder_d), .q(remainder));

// QUOTIENT LOGIC
wire LSB = ~diff[15];
wire [7:0] quotient_d = {quotient[6:0], LSB};
dffre #(8) quotient_dff(.clk(clk), .r(reset), .en(state == `SHIFT_QUO), .d(quotient_d), .q(quotient));

assign output_remainder = remainder[7:0];
endmodule
