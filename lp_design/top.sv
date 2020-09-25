//----------------------------------------------------------------------------
// This design allows experimentation with various parts of the ICE40 FPGA.
//----------------------------------------------------------------------------
`include "gfcm.sv"
`include "ice40_resetn.v"

`default_nettype none
parameter CTR_SIZE=24;

module top
(
    // outputs
    output  logic        led_red,       // Red
    output  logic        led_blue,       // Blue
    output  logic        led_green        // Green

);

`ifndef SIM
    parameter index=19;
`else
    parameter index=10;
`endif

    // Clock and reset blocks:
    logic clk_lf, clk_hf, clk;
    logic clk_sel;
`ifndef SIM
    SB_LFOSC  u_lf_osc(.CLKLFPU(1'b1), .CLKLFEN(1'b1), .CLKLF(clk_lf));
    SB_HFOSC  #(.CLKHF_DIV("0b10")) u_hf_osc (.CLKHFPU(1'b1), .CLKHFEN(clk_sel), .CLKHF(clk_hf));
`else
    initial begin
        clk_lf = 1'b0;
        clk_hf = 1'b0;
    end

    always clk_lf = #1000 ~clk_lf;
    always clk_hf = #10 ~clk_hf;

`endif
    logic reset_n, reset;
    ice40_resetn u_reset(.clk(clk_lf), .resetn(reset_n));
    assign reset = ~reset_n;

    // Glitch-free clock mux
    gfcm u_gfcm(.reset(reset), .clk1(clk_lf), .clk2(clk_hf), .sel(clk_sel), .outclk(clk));

    // Simple counter as the design
    logic [index+1:0] cntr;
    initial cntr <= 0;

    always @(posedge clk) begin
       cntr <= cntr + 1'b1;
    end

    // Lets switch between clocks once in a while
    logic [14:0] sel_cntr;
    initial sel_cntr <= 0;
    always @(posedge clk_lf)
        sel_cntr <= sel_cntr + 1'b1;

    assign clk_sel = &{sel_cntr[14:9]};

// LED driver
    SB_RGBA_DRV RGB_DRIVER (
      .RGBLEDEN (1'b1),
      .RGB0PWM  (cntr[index]&cntr[index-1]),
      .RGB1PWM  (cntr[index]&~cntr[index-1]),
      .RGB2PWM  (~cntr[index]&cntr[index-1]),
      .CURREN   (1'b1),
      .RGB0     (led_green),
      .RGB1     (led_blue),
      .RGB2     (led_red)
    );
    defparam RGB_DRIVER.RGB0_CURRENT = "0b000001";
    defparam RGB_DRIVER.RGB1_CURRENT = "0b000001";
    defparam RGB_DRIVER.RGB2_CURRENT = "0b000001";

endmodule
