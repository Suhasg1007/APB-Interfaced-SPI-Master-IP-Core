// SPI shifter block (RTL)
`define SPI_APB_DATA_WIDTH 8

module spi_shifter (
    input                              PCLK,
    input                              PRESET_n,
    input                              ss_i,
    input                              send_data_i,
    input                              lsbfe_i,
    input                              cpha_i,
    input                              cpol_i,
    input                              miso_receive_sclk_i,
    input                              miso_receive_sclk0_i,
    input                              mosi_send_sclk0_i,
    input                              mosi_send_sclk_i,
    input  [`SPI_APB_DATA_WIDTH-1:0]   data_mosi_i,
    input                              miso_i,
    input                              receive_data_i,
    output [`SPI_APB_DATA_WIDTH-1:0]   data_miso_o,
    output reg                         mosi_o
);

    reg [`SPI_APB_DATA_WIDTH-1:0] shift_register_s;
    reg [`SPI_APB_DATA_WIDTH-1:0] temp_reg_s;
    reg [2:0] count_s;    // LSB-first bit index (0..7, wraps)
    reg [2:0] count1_s;   // MSB-first bit index (7..0, wraps)

    // cpha != cpol : drive on rising edge (sclk0 pulses), sample on falling
    // cpha == cpol : drive on falling edge (sclk  pulses), sample on rising
    wire mode_diff   = cpha_i ^ cpol_i;
    wire mosi_pulse  = mode_diff ? mosi_send_sclk0_i    : mosi_send_sclk_i;
    wire miso_pulse  = mode_diff ? miso_receive_sclk0_i : miso_receive_sclk_i;

    // load shift register
    always @(posedge PCLK or negedge PRESET_n) begin
        if (!PRESET_n)
            shift_register_s <= {`SPI_APB_DATA_WIDTH{1'b0}};
        else if (send_data_i)
            shift_register_s <= data_mosi_i;
    end

    // MOSI transmit
    always @(posedge PCLK or negedge PRESET_n) begin
        if (!PRESET_n) begin
            mosi_o   <= 1'b0;
            count_s  <= 3'd0;
            count1_s <= 3'd7;
        end
        else if (ss_i) begin                  // not selected: restart
            count_s  <= 3'd0;
            count1_s <= 3'd7;
        end
        else if (mosi_pulse) begin
            if (lsbfe_i) begin                // LSB first
                mosi_o  <= shift_register_s[count_s];
                count_s <= count_s + 1'b1;
            end
            else begin                        // MSB first
                mosi_o   <= shift_register_s[count1_s];
                count1_s <= count1_s - 1'b1;
            end
        end
    end

    // MISO receive
    always @(posedge PCLK or negedge PRESET_n) begin
        if (!PRESET_n)
            temp_reg_s <= {`SPI_APB_DATA_WIDTH{1'b0}};
        else if (!ss_i && miso_pulse) begin
            if (lsbfe_i) temp_reg_s <= {miso_i, temp_reg_s[`SPI_APB_DATA_WIDTH-1:1]};
            else         temp_reg_s <= {temp_reg_s[`SPI_APB_DATA_WIDTH-2:0], miso_i};
        end
    end

    assign data_miso_o = receive_data_i ? temp_reg_s : {`SPI_APB_DATA_WIDTH{1'b0}};

endmodule
