//-----------------------------------------------------------------------------
// bram.v created on 2020/6/8 by liam.
// Implement a 16k x 32bit memory (64kb)  with valid-ready interface. 
// Implement a 32k x 32bit memory (128kb) with valid-ready interface. 
//
// Add bram module for simulation on 2020/07/19
// Implement a 16k x 32bit memory with valid-ready interface. 
// 16k x 32bit -> 2^14 -> addr[15:2]
//-----------------------------------------------------------------------------


// For simulation
module bram #(
    parameter integer ADDRWIDTH = 14,
    parameter integer WORDS     = 1 << ADDRWIDTH
) (   
    input             clk,
    input             rst_n,
    input             mem_valid,
    output reg        mem_ready,
    input      [31:0] mem_addr,
    input      [31:0] mem_wdata,
    input      [ 3:0] mem_wstrb,
    output reg [31:0] mem_rdata
);

    (* ram_style = "block" *)
    reg [31:0] mem [0:WORDS - 1]; 
    
    //load the program
    initial $readmemh("./../src/firmware/firmware.hex", mem);

    always @(posedge clk) begin
        if (!rst_n) begin
            mem_rdata <= 32'h 0000_0000;
        end else begin
            if (mem_addr[31:ADDRWIDTH + 2] == {(32 - (ADDRWIDTH + 2)){1'b0}} && mem_valid) begin
                mem_rdata <= mem[mem_addr[ADDRWIDTH + 2 - 1:2]];
                if (mem_wstrb[0]) mem[mem_addr[ADDRWIDTH + 2 - 1:2]][ 7: 0] <= mem_wdata[ 7: 0];
                if (mem_wstrb[1]) mem[mem_addr[ADDRWIDTH + 2 - 1:2]][15: 8] <= mem_wdata[15: 8];
                if (mem_wstrb[2]) mem[mem_addr[ADDRWIDTH + 2 - 1:2]][23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3]) mem[mem_addr[ADDRWIDTH + 2 - 1:2]][31:24] <= mem_wdata[31:24];
            end
        end
    end

    always @(posedge clk) begin
        mem_ready <= mem_valid && !mem_ready;
    end

endmodule


// Using one slice of RAMB36E1 to implement a write-first single port ram
module bram_4k_8bit(
    input             clk,
    input             en,
    input             we,
    input      [11:0] addr,
    input      [ 7:0] din,
    output reg [ 7:0] dout
);

    (* ram_style = "block" *)   //using block ram when synthesis in vivado
    reg [7:0] mem[0:4095];

    always @(posedge clk) begin
        if (en) begin
            if (we) begin
                mem[addr] <= din;
                dout <= din;
            end else begin
                dout <= mem[addr];
            end
        end
    end

endmodule


module bram_4k_32bit(
    input         clk,
    input         en,
    input  [ 3:0] we,
    input  [11:0] addr,
    input  [31:0] din,
    output [31:0] dout
);

    bram_4k_8bit bram_4k_8bit_0(clk, en, we[0], addr, din[ 7: 0], dout[ 7: 0]);
    bram_4k_8bit bram_4k_8bit_1(clk, en, we[1], addr, din[15: 8], dout[15: 8]);
    bram_4k_8bit bram_4k_8bit_2(clk, en, we[2], addr, din[23:16], dout[23:16]);
    bram_4k_8bit bram_4k_8bit_3(clk, en, we[3], addr, din[31:24], dout[31:24]);

endmodule


module bram_16k_32bit(
    input         clk,
    input         rst_n,
    input         mem_valid,
    output        mem_ready,
    input  [31:0] mem_addr,
    input  [31:0] mem_wdata,
    input  [ 3:0] mem_wstrb,
    output [31:0] mem_rdata
);

    wire [31:0] ram_rdata_0;
    wire [31:0] ram_rdata_1;
    wire [31:0] ram_rdata_2;
    wire [31:0] ram_rdata_3;

    reg  [31:0] ram_rdata_reg0;
    reg  [31:0] ram_rdata_reg1;
    reg  [31:0] ram_rdata_reg2;
    reg  [31:0] ram_rdata_reg3;

    reg  [31:0] mem_addr_reg0;
    reg  [31:0] mem_addr_reg1;
    reg         mem_valid_reg;
    reg         ram_ready_reg0;
    reg         ram_ready_reg1;

    always @(posedge clk) begin
        if (!rst_n) begin
            mem_addr_reg0  <= 0;
            mem_addr_reg1  <= 0;
            mem_valid_reg  <= 0;
            ram_ready_reg0 <= 0;
            ram_ready_reg1 <= 0;
        end else begin
            if ((mem_valid == 1) && (mem_valid_reg == 0))
                ram_ready_reg0 <= 1;
            if (ram_ready_reg0 == 1)
                ram_ready_reg0 <= 0;
            
            ram_ready_reg1 <= ram_ready_reg0;
            mem_valid_reg  <= mem_valid;          
            mem_addr_reg0  <= mem_addr;
            mem_addr_reg1  <= mem_addr_reg0;
        end
    end

    assign mem_ready = (|mem_wstrb == 1) ? ram_ready_reg0 : ram_ready_reg1;

    always @(posedge clk) begin
        ram_rdata_reg0 <= ram_rdata_0;
        ram_rdata_reg1 <= ram_rdata_1;
        ram_rdata_reg2 <= ram_rdata_2;
        ram_rdata_reg3 <= ram_rdata_3;
    end

    assign mem_rdata = 
        (mem_valid && (mem_addr_reg1[15:14] == 2'b00)) ? ram_rdata_reg0 :
        (mem_valid && (mem_addr_reg1[15:14] == 2'b01)) ? ram_rdata_reg1 :
        (mem_valid && (mem_addr_reg1[15:14] == 2'b10)) ? ram_rdata_reg2 :
        (mem_valid && (mem_addr_reg1[15:14] == 2'b11)) ? ram_rdata_reg3 : 32'h0000_0000;

    bram_4k_32bit bram_4k_32bit_0(
        .clk(clk),
        .en(mem_valid && !mem_addr[31]),
        .we((mem_valid && !mem_ready && (mem_addr[15:14] == 2'b00)) ? mem_wstrb : 4'b0),
        .addr(mem_addr[13:2]),
        .din(mem_wdata),
        .dout(ram_rdata_0)
    );
    bram_4k_32bit bram_4k_32bit_1(
        .clk(clk),
        .en(mem_valid && !mem_addr[31]),
        .we((mem_valid && !mem_ready && (mem_addr[15:14] == 2'b01)) ? mem_wstrb : 4'b0),
        .addr(mem_addr[13:2]),
        .din(mem_wdata),
        .dout(ram_rdata_1)
    );
    bram_4k_32bit bram_4k_32bit_2(
        .clk(clk),
        .en(mem_valid && !mem_addr[31]),
        .we((mem_valid && !mem_ready && (mem_addr[15:14] == 2'b10)) ? mem_wstrb : 4'b0),
        .addr(mem_addr[13:2]),
        .din(mem_wdata),
        .dout(ram_rdata_2)
    );
    bram_4k_32bit bram_4k_32bit_3(
        .clk(clk),
        .en(mem_valid && !mem_addr[31]),
        .we((mem_valid && !mem_ready && (mem_addr[15:14] == 2'b11)) ? mem_wstrb : 4'b0),
        .addr(mem_addr[13:2]),
        .din(mem_wdata),
        .dout(ram_rdata_3)
    );

endmodule


module bram_32k_32bit(
    input         clk,
    input         rst_n,
    input         mem_valid,
    output        mem_ready,
    input  [31:0] mem_addr,
    input  [31:0] mem_wdata,
    input  [ 3:0] mem_wstrb,
    output [31:0] mem_rdata
);

    wire [31:0] ram_rdata_0;
    wire [31:0] ram_rdata_1;
    wire [31:0] ram_rdata_2;
    wire [31:0] ram_rdata_3;
    wire [31:0] ram_rdata_4;
    wire [31:0] ram_rdata_5;
    wire [31:0] ram_rdata_6;
    wire [31:0] ram_rdata_7;
    
    reg  [31:0] ram_rdata_reg0;
    reg  [31:0] ram_rdata_reg1;
    reg  [31:0] ram_rdata_reg2;
    reg  [31:0] ram_rdata_reg3;
    reg  [31:0] ram_rdata_reg4;
    reg  [31:0] ram_rdata_reg5;
    reg  [31:0] ram_rdata_reg6;
    reg  [31:0] ram_rdata_reg7;
    
    reg  [31:0] mem_addr_reg0;
    reg  [31:0] mem_addr_reg1;
    reg         mem_valid_reg;
    reg         ram_ready_reg0;
    reg         ram_ready_reg1;

    always @(posedge clk) begin
        if (!rst_n) begin
            mem_addr_reg0  <= 0;
            mem_addr_reg1  <= 0;
            mem_valid_reg  <= 0;
            ram_ready_reg0 <= 0;
            ram_ready_reg1 <= 0;
        end else begin
            if ((mem_valid == 1) && (mem_valid_reg == 0))
                ram_ready_reg0 <= 1;
            if (ram_ready_reg0 == 1)
                ram_ready_reg0 <= 0;
            
            ram_ready_reg1 <= ram_ready_reg0;
            mem_valid_reg  <= mem_valid;          
            mem_addr_reg0  <= mem_addr;
            mem_addr_reg1  <= mem_addr_reg0;
        end
    end

    assign mem_ready = (|mem_wstrb == 1) ? ram_ready_reg0 : ram_ready_reg1;

    always @(posedge clk) begin
        ram_rdata_reg0 <= ram_rdata_0;
        ram_rdata_reg1 <= ram_rdata_1;
        ram_rdata_reg2 <= ram_rdata_2;
        ram_rdata_reg3 <= ram_rdata_3;
        ram_rdata_reg4 <= ram_rdata_4;
        ram_rdata_reg5 <= ram_rdata_5;
        ram_rdata_reg6 <= ram_rdata_6;
        ram_rdata_reg7 <= ram_rdata_7;
    end

    assign mem_rdata = 
        (mem_valid && (mem_addr_reg1[16:14] == 3'b000)) ? ram_rdata_reg0 :
        (mem_valid && (mem_addr_reg1[16:14] == 3'b001)) ? ram_rdata_reg1 :
        (mem_valid && (mem_addr_reg1[16:14] == 3'b010)) ? ram_rdata_reg2 :
        (mem_valid && (mem_addr_reg1[16:14] == 3'b011)) ? ram_rdata_reg3 :
        (mem_valid && (mem_addr_reg1[16:14] == 3'b100)) ? ram_rdata_reg4 :
        (mem_valid && (mem_addr_reg1[16:14] == 3'b101)) ? ram_rdata_reg5 :
        (mem_valid && (mem_addr_reg1[16:14] == 3'b110)) ? ram_rdata_reg6 :
        (mem_valid && (mem_addr_reg1[16:14] == 3'b111)) ? ram_rdata_reg7 : 32'h0000_0000;
    
    bram_4k_32bit bram_4k_32bit_0(
        .clk(clk),
        .en(mem_valid && !mem_addr[31]),
        .we((mem_valid && !mem_ready && (mem_addr[16:14] == 3'b000)) ? mem_wstrb : 4'b0),
        .addr(mem_addr[13:2]),
        .din(mem_wdata),
        .dout(ram_rdata_0)
    );
    bram_4k_32bit bram_4k_32bit_1(
        .clk(clk),
        .en(mem_valid && !mem_addr[31]),
        .we((mem_valid && !mem_ready && (mem_addr[16:14] == 3'b001)) ? mem_wstrb : 4'b0),
        .addr(mem_addr[13:2]),
        .din(mem_wdata),
        .dout(ram_rdata_1)
    );
    bram_4k_32bit bram_4k_32bit_2(
        .clk(clk),
        .en(mem_valid && !mem_addr[31]),
        .we((mem_valid && !mem_ready && (mem_addr[16:14] == 3'b010)) ? mem_wstrb : 4'b0),
        .addr(mem_addr[13:2]),
        .din(mem_wdata),
        .dout(ram_rdata_2)
    );
    bram_4k_32bit bram_4k_32bit_3(
        .clk(clk),
        .en(mem_valid && !mem_addr[31]),
        .we((mem_valid && !mem_ready && (mem_addr[16:14] == 3'b011)) ? mem_wstrb : 4'b0),
        .addr(mem_addr[13:2]),
        .din(mem_wdata),
        .dout(ram_rdata_3)
    );
    bram_4k_32bit bram_4k_32bit_4(
        .clk(clk),
        .en(mem_valid && !mem_addr[31]),
        .we((mem_valid && !mem_ready && (mem_addr[16:14] == 3'b100)) ? mem_wstrb : 4'b0),
        .addr(mem_addr[13:2]),
        .din(mem_wdata),
        .dout(ram_rdata_4)
    );
    bram_4k_32bit bram_4k_32bit_5(
        .clk(clk),
        .en(mem_valid && !mem_addr[31]),
        .we((mem_valid && !mem_ready && (mem_addr[16:14] == 3'b101)) ? mem_wstrb : 4'b0),
        .addr(mem_addr[13:2]),
        .din(mem_wdata),
        .dout(ram_rdata_5)
    );
    bram_4k_32bit bram_4k_32bit_6(
        .clk(clk),
        .en(mem_valid && !mem_addr[31]),
        .we((mem_valid && !mem_ready && (mem_addr[16:14] == 3'b110)) ? mem_wstrb : 4'b0),
        .addr(mem_addr[13:2]),
        .din(mem_wdata),
        .dout(ram_rdata_6)
    );
    bram_4k_32bit bram_4k_32bit_7(
        .clk(clk),
        .en(mem_valid && !mem_addr[31]),
        .we((mem_valid && !mem_ready && (mem_addr[16:14] == 3'b111)) ? mem_wstrb : 4'b0),
        .addr(mem_addr[13:2]),
        .din(mem_wdata),
        .dout(ram_rdata_7)
    );

endmodule
