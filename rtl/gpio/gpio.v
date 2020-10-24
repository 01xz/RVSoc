//-----------------------------------------------------------------------------
// gpio.v created at 2020/6/9 by liam.
// Implement an 8bit-GPIO with valid-ready interface. 
//-----------------------------------------------------------------------------


module gpio #(
    parameter integer IO_NUMBERS = 8
) (
    input             clk,
    input             rst_n,
    input             mem_valid,
    output reg        mem_ready,
    input      [31:0] mem_addr,
    input      [31:0] mem_wdata,
    input      [ 3:0] mem_wstrb,
    output reg [31:0] mem_rdata,
    
    inout      [IO_NUMBERS-1:0] io
);

    reg [IO_NUMBERS-1:0] io_reg;

    always @(posedge clk) begin
        if(!rst_n) begin
            io_reg    <= 0;
            mem_rdata <= 0;
        end else begin
            if(mem_valid) begin
                if (|mem_wstrb == 1)
                    io_reg <= mem_wdata[IO_NUMBERS-1:0];
                else
                    mem_rdata <= io_reg;
            end
        end
    end

    always @(posedge clk) begin
        mem_ready <= mem_valid && !mem_ready;
    end

    assign io = io_reg;

endmodule
