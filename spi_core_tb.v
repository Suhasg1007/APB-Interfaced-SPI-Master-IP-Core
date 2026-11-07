`timescale 1ps/1ps
`define SPI_APB_DATA_WIDTH 8
`define SPI_REG_WIDTH 8
`define SPI_APB_ADDR_WIDTH 3

module spi_core_tb();
 
reg PCLK = 1'b0;
reg PRESET_n;
reg  [`SPI_APB_ADDR_WIDTH-1:0] PADDR;
reg  PWRITE;
reg  PSEL;
reg  PENABLE;
reg  [`SPI_APB_DATA_WIDTH-1:0] PWDATA;
wire [`SPI_APB_DATA_WIDTH-1:0] PRDATA;
wire PREADY;
wire PSLVERR;
reg  miso;
wire ss;
wire sclk;
wire spi_interrupt_request;
wire mosi;
integer i;
 
spi_core SPI_CORE (
    .PCLK                    (PCLK),
    .PRESET_n                (PRESET_n),
    .PADDR_i                 (PADDR),
    .PWRITE_i                (PWRITE),
    .PSEL_i                  (PSEL),
    .PENABLE_i               (PENABLE),
    .PWDATA_i                (PWDATA),
    .PRDATA_o                (PRDATA),      // notes had .PREADY_o(PRDATA)
    .PREADY_o                (PREADY),
    .PSLVERR_o               (PSLVERR),
    .miso_i                  (miso),
    .ss_o                    (ss),
    .sclk_o                  (sclk),
    .spi_interrupt_request_o (spi_interrupt_request),
    .mosi_o                  (mosi)
);
 
always #5 PCLK = ~PCLK;
 
task reset;
begin
    @(posedge PCLK)
    PRESET_n = 1'b0;
    @(posedge PCLK)
    PRESET_n = 1'b1;
end
endtask
 
// CR1 (addr 0), CR2 (addr 1), baud rate (addr 2): setup, access, wait PREADY
task write_registers(input [7:0] contr1_data,
                     input [7:0] contr2_data,
                     input [7:0] baud_data);
begin
    @(posedge PCLK)
    PADDR   = 3'b000;
    PWRITE  = 1'b1;
    PSEL    = 1'b1;
    PENABLE = 1'b0;
    PWDATA  = contr1_data;
 
    @(posedge PCLK)
    PADDR   = 3'b000;
    PWRITE  = 1'b1;
    PSEL    = 1'b1;
    PENABLE = 1'b1;
    PWDATA  = contr1_data;
 
    @(posedge PCLK)
    wait (PREADY);
    PENABLE = 1'b0;
 
    @(posedge PCLK)
    PADDR   = 3'b001;
    PWRITE  = 1'b1;
    PSEL    = 1'b1;
    PENABLE = 1'b0;
    PWDATA  = contr2_data;
 
    @(posedge PCLK)
    PADDR   = 3'b001;
    PWRITE  = 1'b1;
    PSEL    = 1'b1;
    PENABLE = 1'b1;
    PWDATA  = contr2_data;
 
    @(posedge PCLK)
    wait (PREADY);
    PENABLE = 1'b0;
 
    @(posedge PCLK)
    PADDR   = 3'b010;
    PWRITE  = 1'b1;
    PSEL    = 1'b1;
    PENABLE = 1'b0;
    PWDATA  = baud_data;
 
    @(posedge PCLK)
    PADDR   = 3'b010;
    PWRITE  = 1'b1;
    PSEL    = 1'b1;
    PENABLE = 1'b1;
    PWDATA  = baud_data;
 
    @(posedge PCLK)
    wait (PREADY);
    PENABLE = 1'b0;
end
endtask
 
// transmit data register (addr 5)
task write_data_register(input [7:0] write_data);
begin
    @(posedge PCLK)
    PADDR   = 3'b101;
    PWRITE  = 1'b1;
    PSEL    = 1'b1;
    PENABLE = 1'b1;
    PWDATA  = write_data;
 
    @(posedge PCLK)
    PADDR   = 3'b101;
    PWRITE  = 1'b1;
    PSEL    = 1'b1;
    PENABLE = 1'b1;
    PWDATA  = write_data;
 
    @(posedge PCLK)
    wait (PREADY);
    PADDR   = 3'b101;
    PWRITE  = 1'b0;
    PSEL    = 1'b0;
    PENABLE = 1'b0;
    PWDATA  = write_data;
end
endtask
 
// ---------------- MISO drivers ----------------
task write_miso_data_low_lsbfe(input [7:0] miso_data);
begin
    wait (~ss);
    miso = miso_data[0];
    @(negedge sclk);
    for (i = 1; i <= 7; i = i + 1)
    begin
        @(negedge sclk)
        miso = miso_data[i];
    end
end
endtask
 
task write_miso_data_low_msbfe(input [7:0] miso_data);
begin
    wait (~ss);
    for (i = 7; i >= 0; i = i - 1)
    begin
        @(negedge sclk)
        miso = miso_data[i];
    end
end
endtask
 
task write_miso_data_high_lsbfe(input [7:0] miso_data);
begin
    miso = 1'b0;
    wait (~ss);
    for (i = 0; i <= 7; i = i + 1)
    begin
        @(posedge sclk)
        miso = miso_data[i];
    end
end
endtask
 
task write_miso_data_high_msbfe(input [7:0] miso_data);
begin
    wait (~ss);
    miso = miso_data[7];
    for (i = 6; i >= 0; i = i - 1)
    begin
        @(posedge sclk)
        miso = miso_data[i];
    end
end
endtask
 
// APB reads of CR1, CR2, BR, SR, DR (not called from the initial block)
task read_data;
begin
    // CR1
    @(negedge PCLK)
    PADDR = 3'b000; PWRITE = 1'b0; PSEL = 1'b1; PENABLE = 1'b0;
    @(negedge PCLK)
    PADDR = 3'b000; PWRITE = 1'b0; PSEL = 1'b1; PENABLE = 1'b1;
    @(negedge PCLK)
    wait (PREADY);
    PENABLE = 1'b0;
 
    // CR2
    @(negedge PCLK)
    PADDR = 3'b001; PWRITE = 1'b0; PSEL = 1'b1; PENABLE = 1'b0;
    @(negedge PCLK)
    PADDR = 3'b001; PWRITE = 1'b0; PSEL = 1'b1; PENABLE = 1'b1;
    @(negedge PCLK)
    wait (PREADY);
    PENABLE = 1'b0;
 
    // Baud rate register
    @(negedge PCLK)
    PADDR = 3'b010; PWRITE = 1'b0; PSEL = 1'b1; PENABLE = 1'b0;
    @(negedge PCLK)
    PADDR = 3'b010; PWRITE = 1'b0; PSEL = 1'b1; PENABLE = 1'b1;
    @(negedge PCLK)
    wait (PREADY);
    PENABLE = 1'b0;
 
    // Status register
    @(negedge PCLK)
    PADDR = 3'b011; PWRITE = 1'b0; PSEL = 1'b1; PENABLE = 1'b0;
    @(negedge PCLK)
    PADDR = 3'b011; PWRITE = 1'b0; PSEL = 1'b1; PENABLE = 1'b1;
    @(negedge PCLK)
    wait (PREADY);
    PENABLE = 1'b0;
 
    // Data register
    @(negedge PCLK)
    PADDR = 3'b101; PWRITE = 1'b0; PSEL = 1'b1; PENABLE = 1'b0;
    @(negedge PCLK)
    PADDR = 3'b101; PWRITE = 1'b0; PSEL = 1'b1; PENABLE = 1'b1;
    @(negedge PCLK)
    wait (PREADY);
    PADDR = 3'b101; PWRITE = 1'b0; PSEL = 1'b0; PENABLE = 1'b0;
end
endtask
 
initial
begin
    miso = 1'b0;
    reset;
 
    write_registers(8'b1111_0101, 8'b0000_0000, 8'b0000_0001);
    write_data_register(8'b1010_1010);
    write_miso_data_low_lsbfe(8'b0101_0111);
 
    #100;
 
    write_registers(8'b1111_0101, 8'b0000_0000, 8'b0000_0010);
    write_data_register(8'b1010_1010);
    write_miso_data_low_lsbfe(8'b0101_0101);
 
    #200 $finish();
  
end
 
endmodule

