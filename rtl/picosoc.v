//-----------------------------------------------------------------------------
// picosoc.v created at 2020/6/25 by liam.
// memory map:
// 64kb ram:  0000_0000 - 0000_ffff
// io:        8001_0000
// uart:      8002_0000
// pwm:       8003_0000
//-----------------------------------------------------------------------------


module picosoc(
    input        clk,
    input        rst_n,
    
    input        rx,
    output       tx,
    inout [31:0] io,
    output       pwm_out,
        
    input        irq_5,
    input        irq_6,
    input        irq_7
);

    parameter         ENABLE_SIMULATION = 0;
    parameter         UART_BAUD         = 32'd271;                         // 125 / (115200 * 4)
    parameter integer RAM_WORDS         = 16384;
    parameter integer IO_NUMBERS        = 32;
    parameter [31:0]  STACKADDR         = 32'h 0000_0000 + RAM_WORDS * 4;

    wire trap;
    wire mem_valid;
    wire mem_instr;
    wire mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [ 3:0] mem_wstrb;
    wire [31:0] mem_rdata;
    reg  [31:0] irq;

    wire irq_stall = 0;
    wire irq_uart;

    always @* begin
        irq    = 0;
        irq[3] = irq_stall;
        irq[4] = irq_uart;
        irq[5] = irq_5;
        irq[6] = irq_6;
        irq[7] = irq_7;
    end

    // picoRV32 CPU core
    picorv32 #(
        .ENABLE_IRQ(1),
        .STACKADDR(STACKADDR)
    ) picorv32_core(
        .clk(clk),
        .resetn(rst_n),
        .trap(trap),
        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),
        .irq(irq)
    );

    wire        ram_valid  = mem_valid && (mem_addr[31:16] == 16'h0000);
    wire        ram_ready;
    wire [31:0] ram_rdata;

    wire        io_valid   = mem_valid && (mem_addr[31:16] == 16'h8001);
    wire        io_ready;
    wire [31:0] io_rdata;

    wire        uart_valid = mem_valid && (mem_addr[31:16] == 16'h8002);
    wire        uart_ready;
    wire [31:0] uart_rdata;

    wire        pwm_valid  = mem_valid && (mem_addr[31:16] == 16'h8003);
    wire        pwm_ready;
    wire [31:0] pwm_rdata;

    bram_16k_32bit soc_ram_64kb(
        .clk(clk),
        .rst_n(rst_n),
        .mem_valid(ram_valid),
        .mem_ready(ram_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(ram_rdata)
    );

    gpio #(
        .IO_NUMBERS(IO_NUMBERS)
    ) soc_gpio(
        .clk(clk),
        .rst_n(rst_n),
        .mem_valid(io_valid),
        .mem_ready(io_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(io_rdata),
        .io(io)
    );

    uart_top #(
        .CLOCK_DIVIDE(UART_BAUD)
    ) soc_uart(
        .clk(clk),
        .resetn(rst_n),
        .mem_valid(uart_valid),
        .mem_ready(uart_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(uart_rdata),
        .tx(tx),
        .rx(rx),
        .irq(irq_uart)
    );

    pwm #(
        .BITWIDTH(16)
    ) soc_pwm(
        .clk(clk),
        .rst_n(rst_n),
        .mem_valid(pwm_valid),
        .mem_ready(pwm_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(pwm_rdata),
        .pwm_out(pwm_out)
    );

    assign mem_rdata = 
        ram_valid  ? ram_rdata  : 
        io_valid   ? io_rdata   : 
        uart_valid ? uart_rdata : 32'h 0000_0000;

    assign mem_ready = 
        (ram_valid  && ram_ready ) || 
        (io_valid   && io_ready  ) ||
        (uart_valid && uart_ready) ||
        (pwm_valid  && pwm_ready );

endmodule
