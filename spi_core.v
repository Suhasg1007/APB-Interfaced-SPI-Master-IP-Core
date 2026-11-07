`timescale 1ps/1ps
`define SPI_APB_DATA_WIDTH 8
`define SPI_REG_WIDTH 8
`define SPI_APB_ADDR_WIDTH 3

module spi_core (
    input                              PCLK,
    input                              PRESET_n,
    input  [`SPI_APB_ADDR_WIDTH-1:0]   PADDR_i,
    input                              PWRITE_i,
    input                              PSEL_i,
    input                              PENABLE_i,
    input  [`SPI_APB_DATA_WIDTH-1:0]   PWDATA_i,
    output [`SPI_APB_DATA_WIDTH-1:0]   PRDATA_o,
    output                             PREADY_o,
    output                             PSLVERR_o,
    input                              miso_i,
    output                             ss_o,
    output                             sclk_o,
    output                             spi_interrupt_request_o,
    output                             mosi_o
);
 
wire [`SPI_APB_DATA_WIDTH-1:0] data_miso_s;
wire [`SPI_APB_DATA_WIDTH-1:0] data_mosi_s;
 
wire        send_data_s;
wire        receive_data_s;
wire        tip_s;
wire [1:0]  spi_mode_s;
wire        mstr_s;
wire        cpol_s;
wire        cpha_s;
wire        lsbfe_s;
wire        spiswai_s;
wire [2:0]  sppr_s;
wire [2:0]  spr_s;
wire [11:0] BaudRateDivisor_s;
 
wire miso_receive_sclk_s;
wire miso_receive_sclk0_s;
wire mosi_send_sclk0_s;
wire mosi_send_sclk_s;
 
// ---------------- SPI serial clock generator ----------------
spi_serial_clock_gen spi_bg (
    .PCLK                 (PCLK),
    .PRESET_n             (PRESET_n),
    .spi_mode_i           (spi_mode_s),
    .spiswai_i            (spiswai_s),
    .sppr_i               (sppr_s),
    .spr_i                (spr_s),
    .cpol_i               (cpol_s),
    .cpha_i               (cpha_s),
    .ss_i                 (ss_o),
    .sclk_o               (sclk_o),
    .miso_receive_sclk_o  (miso_receive_sclk_s),
    .miso_receive_sclk0_o (miso_receive_sclk0_s),
    .mosi_send_sclk0_o    (mosi_send_sclk0_s),
    .mosi_send_sclk_o     (mosi_send_sclk_s),     // not in your notes, see section 1
    .BaudRateDivisor_o    (BaudRateDivisor_s)
);
 
// ---------------- SPI APB interface ----------------
spi_apb_interface spi_apb_interface (
    .PCLK                    (PCLK),
    .PRESET_n                (PRESET_n),
    .PADDR_i                 (PADDR_i),
    .PWRITE_i                (PWRITE_i),
    .PSEL_i                  (PSEL_i),
    .PENABLE_i               (PENABLE_i),
    .PWDATA_i                (PWDATA_i),
    .PRDATA_o                (PRDATA_o),
    .PREADY_o                (PREADY_o),             // missing in your notes
    .PSLVERR_o               (PSLVERR_o),
    .ss_i                    (ss_o),
    .data_miso_i             (data_miso_s),
    .send_data_o             (send_data_s),
    .receive_data_i          (receive_data_s),       // notes had ';' here
    .tip_i                   (tip_s),
    .data_mosi_o             (data_mosi_s),
    .spi_mode_o              (spi_mode_s),
    .mstr_o                  (mstr_s),
    .cpol_o                  (cpol_s),
    .cpha_o                  (cpha_s),
    .lsbfe_o                 (lsbfe_s),
    .spiswai_o               (spiswai_s),
    .sppr_o                  (sppr_s),
    .spr_o                   (spr_s),
    .spi_interrupt_request_o (spi_interrupt_request_o)
);
 
// ---------------- SPI shifter ----------------
spi_shifter spi_shifter (
    .PCLK                  (PCLK),
    .PRESET_n              (PRESET_n),
    .ss_i                  (ss_o),
    .send_data_i           (send_data_s),
    .lsbfe_i               (lsbfe_s),
    .cpha_i                (cpha_s),
    .cpol_i                (cpol_s),
    .miso_receive_sclk_i   (miso_receive_sclk_s),
    .miso_receive_sclk0_i  (miso_receive_sclk0_s),
    .mosi_send_sclk0_i     (mosi_send_sclk0_s),
    .mosi_send_sclk_i      (mosi_send_sclk_s),
    .data_mosi_i           (data_mosi_s),
    .miso_i                (miso_i),
    .receive_data_i        (receive_data_s),
    .data_miso_o           (data_miso_s),
    .mosi_o                (mosi_o)
);
 
// ---------------- SPI slave select ----------------
spi_slave_select spi_ss (
    .PRESETn           (PRESET_n),
    .spi_mode_i         (spi_mode_s),
    .mstr_i             (mstr_s),
    .spiswai_i          (spiswai_s),
    .PCLK               (PCLK),
    .send_data_i        (send_data_s),
    .BaudRateDivisor_i  (BaudRateDivisor_s),
    .ss_o               (ss_o),
    .receive_data_o     (receive_data_s),
    .tip_o              (tip_s)
);
 
endmodule

 

 
