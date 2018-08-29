module flipflop (
    input clk,  // clock
    input d,
    output reg q );

    always @(posedge clk)   // on positive edge
        q <= d; // assign d to (reg)q
endmodule
