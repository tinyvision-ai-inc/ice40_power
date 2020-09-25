//----------------------------------------------------------------------------
// This design allows experimentation with various parts of the ICE40 FPGA.
//----------------------------------------------------------------------------

//`define BLANK
//`define EXTOSC
//`define LFOSC // Select the low frequency 10kHz clock
`define USE_PLL
//`define RGB_DRV
//`define MATH

`ifdef USE_PLL
`include "my_pll.v"
`endif

//`default_nettype none
parameter CTR_SIZE=24;

module rgb_blink
(
    // outputs
    output  wire        led_red,       // Red
    output  wire        led_blue,       // Blue
    output  wire        led_green,        // Green

`ifndef BLANK    
    output spi_sck_io,
    output spi_ssn_io,
    input  spi_miso_io,
    output spi_mosi_io,

    input gpio_23_io,
    input gpio_25_io,
    input gpio_26_io,
    input gpio_27_io,
    input gpio_32_io,
`ifdef EXTOSC
    input gpio_35_io,
`else
    //output gpio_35_io,
`endif
    input gpio_31_io,
    input gpio_37_io,
    input gpio_34_io,
    input gpio_43_io,
    input gpio_36_io,
    input gpio_42_io,
    input gpio_38_io,
    input gpio_28_io,
    input gpio_20_io,
    output gpio_10_io,
    input gpio_12_io,
    input gpio_21_io,
    input gpio_13_io,
    input gpio_19_io,
    input gpio_18_io,
    input gpio_11_io,
    input gpio_9_io,
    input gpio_6_io,
    input gpio_44_io,
    input gpio_4_io,
    input gpio_3_io,
    input gpio_48_io,
    input gpio_45_io,
    input gpio_47_io,
    input gpio_46_io,
    input gpio_2_io
`endif
);

`ifndef BLANK

    // Internal signals after the IO pads
    wire  spi_miso, spi_mosi, spi_sck, spi_ssn,
    gpio_23, gpio_25, gpio_26, gpio_27, gpio_32, gpio_31, gpio_37,
    gpio_34, gpio_43, gpio_36, gpio_42, gpio_38, gpio_28, gpio_20, gpio_10,
    gpio_12, gpio_21, gpio_13, gpio_19, gpio_18, gpio_11, gpio_9,  gpio_6,
    gpio_44, gpio_4,  gpio_3,  gpio_48, gpio_45, gpio_47, gpio_46, gpio_2;

    wire clk;
    reg         rstn;
    reg         int_osc;
    reg [CTR_SIZE-1:0]  frequency_counter_i;
    integer index; // Index into the clock divider
    wire munged;
    reg [7:0] ctr1, ctr2;
    wire [15:0] result;

    // Add pullups/downs to eperiment with what they do
    SB_IO #(.PIN_TYPE(6'b0000_01), .PULLUP(1'b1) ) io_spi_ssn (.PACKAGE_PIN(spi_ssn_io), .D_IN_0(spi_ssn) );
    SB_IO #(.PIN_TYPE(6'b0000_01), .PULLUP(1'b1) ) io_spi_sck (.PACKAGE_PIN(spi_sck_io), .D_IN_0(spi_sck) );
    SB_IO #(.PIN_TYPE(6'b0000_01), .PULLUP(1'b1) ) io_spi_miso (.PACKAGE_PIN(spi_miso_io), .D_IN_0(spi_miso) );

    SB_IO #(.PIN_TYPE(6'b0000_01), .PULLUP(1'b1) ) io_23 (.PACKAGE_PIN(gpio_23_io), .D_IN_0(gpio_23) );
    SB_IO #(.PIN_TYPE(6'b0000_01), .PULLUP(1'b1) ) io_25 (.PACKAGE_PIN(gpio_25_io), .D_IN_0(gpio_25) );
    SB_IO #(.PIN_TYPE(6'b0000_01), .PULLUP(1'b1) ) io_26 (.PACKAGE_PIN(gpio_26_io), .D_IN_0(gpio_26) );
    SB_IO #(.PIN_TYPE(6'b0000_01), .PULLUP(1'b1) ) io_27 (.PACKAGE_PIN(gpio_27_io), .D_IN_0(gpio_27) );

    // Assign a pin so it doesnt optimize anything away
    assign spi_mosi_io = munged;

    // Prevent optimization of all inputs
    assign munged = |{spi_miso,
    gpio_23, gpio_25, gpio_26, gpio_27, gpio_32, gpio_31, gpio_37,
    gpio_34, gpio_43, gpio_36, gpio_42, gpio_38, gpio_28, gpio_20, gpio_10,
    gpio_12, gpio_21, gpio_13, gpio_19, gpio_18, gpio_11, gpio_9,  gpio_6,
    gpio_44, gpio_4,  gpio_3,  gpio_48, gpio_45, gpio_47, gpio_46, gpio_2
    };

    // Output so that everything doesnt get optimized away
    assign gpio_10_io = frequency_counter_i[CTR_SIZE-1] | (&ctr1) | (&ctr2) | (&result);

    // Clock source:
    //   - External
    //   - Low freq oscillator
    //   - High frequency oscillator
`ifdef EXTOSC
    assign clk_osc = gpio_35_io; // Has to be used with the PLL!
`else 
    wire clk_osc;
    `ifdef LFOSC
        SB_LFOSC  u_OSC(.CLKLFPU(1), .CLKLFEN(1), .CLKLF(clk_osc));
        assign index = 15;
    `else
        SB_HFOSC  #(.CLKHF_DIV("0b10")) u_OSC (.CLKHFPU(1), .CLKHFEN(1), .CLKHF(clk_osc));
        assign index = CTR_SIZE-3;
    `endif
`endif

    // To use the PLL or not
`ifdef USE_PLL
   pll u_pll(.clock_in(clk_osc), .clock_out(clk), .locked() );
`else
    assign clk = clk_osc;
`endif

    // Simple counter to kick off things
    always @(posedge clk) begin
	    frequency_counter_i <= frequency_counter_i + 1'b1;
    end

    // Lets try some math and RAM accesses
`ifdef MATH
    always @(posedge clk) begin
        ctr1 <= ctr1 + 3;
        ctr2 <= ctr2 + 5;
    end
    assign result = ctr1 * ctr2;
`else
    assign result = 0;
`endif

// LED driver
`ifdef RGB_DRV
    SB_RGBA_DRV RGB_DRIVER (
      .RGBLEDEN (1'b1),
      .RGB0PWM  (frequency_counter_i[index+1]&frequency_counter_i[index]),
      .RGB1PWM  (frequency_counter_i[index+1]&~frequency_counter_i[index]),
      .RGB2PWM  (~frequency_counter_i[index+1]&frequency_counter_i[index]),
      .CURREN   (1'b1),
      .RGB0     (led_green),		//Actual Hardware connection
      .RGB1     (led_blue),
      .RGB2     (led_red)
    );
    defparam RGB_DRIVER.RGB0_CURRENT = "0b000001";
    defparam RGB_DRIVER.RGB1_CURRENT = "0b000001";
    defparam RGB_DRIVER.RGB2_CURRENT = "0b000001";
`else
    assign led_blue = 1'b1;
    assign led_red = 1'b0;
    assign led_green = 1'b1;
`endif

`else
    // BLANK design
    assign led_blue = 1'b0;
    assign led_red = 1'b1;
    assign led_green = 1'b1;
`endif

endmodule
