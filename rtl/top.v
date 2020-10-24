//-----------------------------------------------------------------------------
// top.v created at 2020/6/9 by liam.
// A demo using picosoc. 
//-----------------------------------------------------------------------------


module top(
    input         sys_clk,
    input         sys_rst_n,
    input         rx,
    output        tx,
    output [15:0] led
);

    wire clk;
    wire rst_n;
    wire locked;

    picosoc #(
        .UART_BAUD(32'd271),
        .ENABLE_SIMULATION(0)
    ) (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .tx(tx),
        .io(led),
        .pwm_out(),
        .irq_5(1'b0),
        .irq_6(1'b0),
        .irq_7(1'b0)
    );

    rst_n_sync_gen rst_n_sync(
        .clk(clk),
        .rst_n_async(sys_rst_n & locked),
        .rst_n(rst_n)
    );

    //Using Xilinx primitive
    pll pll_clk(
        .clk_in(sys_clk),
        .clk_out(clk),
        .rst(~sys_rst_n),
        .locked(locked)
    );

endmodule


module rst_n_sync_gen(
    input  rst_n_async,
    input  clk,
    output rst_n
);

    reg [7:0] x = 8'hff;

    always @(posedge clk) begin
        if (!rst_n_async)
            x <= 8'hff;
        else
            x <= {x[6:0], 1'b0};
    end

    assign rst_n = !x[7];

endmodule


module pll(
    input clk_in,
    input rst,
    output clk_out,
    output locked
);


    wire clk_in_buf;
    wire clk_out_pre;
    wire clk_fb_out;
    wire clk_fb_out_buf;

    // Input buffer
    IBUF clk_in_IBUF(
        .O  (clk_in_buf),
        .I  (clk_in)
    );

    // Output buffer
    BUFG clk_out_BUFG(
        .O  (clk_out),
        .I  (clk_out_pre)
    );

    // Output feedback buffer
    BUFG clk_fb_out_BUFG(
        .O  (clk_fb_out_buf),
        .I  (clk_fb_out)
    );

    // PLL
    (* BOX_TYPE = "PRIMITIVE" *)
    PLLE2_ADV #(
        .BANDWIDTH            ("OPTIMIZED"),
        .COMPENSATION         ("ZHOLD"),
        .STARTUP_WAIT         ("FALSE"),
        .DIVCLK_DIVIDE        (4),
        .CLKFBOUT_MULT        (35),
        .CLKFBOUT_PHASE       (0.000),
        .CLKOUT0_DIVIDE       (7),
        .CLKOUT0_PHASE        (0.000),
        .CLKOUT0_DUTY_CYCLE   (0.500),
        .CLKIN1_PERIOD        (10.000)
    ) plle2_adv_inst(
        .CLKFBOUT            (clk_fb_out),
        .CLKOUT0             (clk_out_pre),
        .CLKOUT1             (),
        .CLKOUT2             (),
        .CLKOUT3             (),
        .CLKOUT4             (),
        .CLKOUT5             (),
        // Input clock control
        .CLKFBIN             (clk_fb_out_buf),
        .CLKIN1              (clk_in_buf),
        .CLKIN2              (1'b0),
        // Tied to always select the primary input clock
        .CLKINSEL            (1'b1),
        // Ports for dynamic reconfiguration
        .DADDR               (7'h0),
        .DCLK                (1'b0),
        .DEN                 (1'b0),
        .DI                  (16'h0),
        .DO                  (),
        .DRDY                (),
        .DWE                 (1'b0),
        // Other control and status signals
        .LOCKED              (locked),
        .PWRDWN              (1'b0),
        .RST                 (rst)
    );

endmodule
