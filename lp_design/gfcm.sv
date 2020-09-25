/* This is a Glitch free clock Mux. The design is based on the description provided
at: https://vlsitutorials.com/glitch-free-clock-mux/

TBD: Need to contrain the locations of the various cells properly so they're close to each other to avoid glitches.
*/

module gfcm (
    input reset, // Async reset!
    input clk1,
    input clk2,
    input sel,
    output outclk
);
    // Select double register
    reg [1:0] sync1, sync2;

    wire i_and1, i_and2;
    wire o_and1, o_and2;

    assign i_and1 = ~sel & ~sync2[1];
    assign i_and2 =  sel & ~sync1[1];

    always @ (posedge clk1 or posedge reset)
    if (reset == 1'b1)
        sync1 <= 0;
    else
        sync1 <= {sync1[0], i_and1};

    always @ (posedge clk2 or posedge reset)
    if (reset == 1'b1)
        sync2 <= 0;
    else
        sync2 <= {sync2[0], i_and2};

    assign o_and1 = clk1 & sync1[1];
    assign o_and2 = clk2 & sync2[1];

    assign outclk = o_and1 | o_and2;
endmodule
