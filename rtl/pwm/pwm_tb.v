`timescale 1 ns / 1 ps

module pwm_tb();
    reg         clk;
    reg         rst_n;
    reg         mem_valid;
    wire        mem_ready;
    reg  [31:0] mem_addr;
    reg  [31:0] mem_wdata;
    reg  [3: 0] mem_wstrb;
    wire [31:0] mem_rdata;
    wire        pwm_out;

    always #8 clk = ~clk;

    initial begin
        clk       = 1;
        rst_n     = 0;
        mem_addr  = 0;
        mem_wdata = {16'h1000, 16'h2000};
        mem_wstrb = 0;
        mem_valid = 0;
    end

    initial begin
        repeat (10) @(posedge clk);
        rst_n <= 1;
        repeat (800) @(posedge clk);
        $finish;
    end

    initial begin
        $dumpfile("wave_pwm.vcd");
        $dumpvars(0, pwm_tb);
    end

    pwm uut(
        .clk(clk),
        .rst_n(rst_n),
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),
        .pwm_out(pwm_out)
    );

    reg       counter1; 
    reg [7:0] counter2;

    always @(posedge clk) begin
        if (!rst_n) begin
            counter1 <= 0;
        end else begin
            counter1 <= counter1 + 1'b1;
            if (counter1 >= 1'b1) begin
                counter1  <= 0;
                mem_valid <= ~mem_valid;
                mem_wstrb <= ~mem_wstrb;
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            counter2 <= 0;
        end else begin
            counter2 <= counter2 + 1'b1;
            if (counter2 >= 16'h84) begin
                counter2   <= 0;
                mem_wdata <= mem_wdata + {16'h0, 16'h2000};
            end
        end
    end

endmodule