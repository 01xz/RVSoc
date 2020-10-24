//-----------------------------------------------------------------------------
// pwm.v created at 2020/6/27 by liam.
// Implement a 16-bit pwm generator.
//-----------------------------------------------------------------------------


module pwm #(
    parameter integer BITWIDTH = 16
)(
    input             clk,
    input             rst_n,
    input             mem_valid,
    output reg        mem_ready,
    input      [31:0] mem_addr,
    input      [31:0] mem_wdata,
    input      [ 3:0] mem_wstrb,
    output reg [31:0] mem_rdata,
    output reg        pwm_out
);

    reg [BITWIDTH - 1:0] counter;
    reg [BITWIDTH - 1:0] step;
    reg [BITWIDTH - 1:0] duty;

    always @(posedge clk) begin
        if (!rst_n) begin
            step <= 0;
            duty <= 0;
        end else begin
            if(mem_valid) begin
                if (|mem_wstrb == 1)
                    {step, duty} <= mem_wdata;
            end
        end
    end

    always @(posedge clk) begin
        mem_ready <= mem_valid && !mem_ready;
    end

    //pwm generate
    always @(posedge clk) begin
        if (!rst_n) begin
            counter <= {BITWIDTH{1'b0}};
        end else begin
            counter <= counter + step;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            pwm_out <= 1'b0;
        end else begin
            if (counter > duty) begin
                pwm_out <= 1'b1;
            end else begin
                pwm_out <= 1'b0;
            end
        end
    end

endmodule
