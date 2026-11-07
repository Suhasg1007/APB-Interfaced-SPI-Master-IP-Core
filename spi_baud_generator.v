module spi_serial_clk_gen (
    input             PCLK,
    input             PRESET_n,
    input      [1:0]  spi_mode_i,
    input             spiswai_i,
    input      [2:0]  sppr_i,
    input      [2:0]  spr_i,
    input             cpol_i,
    input             cpha_i,
    input             ss_i,
    output reg        sclk_o,
    output reg        miso_receive_sclk_o,
    output reg        miso_receive_sclk0_o,
    output reg        mosi_send_sclk0_o,
    output reg        mosi_send_sclk_o,
    output     [11:0] BaudRateDivisor_o
);

    wire        pre_sclk_s;
    reg  [11:0] count_s;
    wire [11:0] BaudRateDivisor;

    // BaudRateDivisor = (SPPR+1) * 2^(SPR+1)
    assign BaudRateDivisor   = (sppr_i + 1) * (2 ** (spr_i + 1));
    assign BaudRateDivisor_o = BaudRateDivisor;

    // idle level of SCLK depends on CPOL
    assign pre_sclk_s = cpol_i ? 1'b1 : 1'b0;

    // Fires on the active edge selected by CPOL/CPHA
    wire edge_sel = (!cpha_i && cpol_i) || (cpha_i && !cpol_i);

    // ---------------- SCLK generation ----------------
    always @(posedge PCLK or negedge PRESET_n) begin
        if (!PRESET_n) begin
            count_s <= 12'b0;
            sclk_o  <= pre_sclk_s;
        end
        else if ((!ss_i) && ((spi_mode_i == 2'b00) || (spi_mode_i == 2'b01))
                         && (!spiswai_i)) begin
            if (count_s == (BaudRateDivisor/2 - 1'b1)) begin
                count_s <= 12'b0;
                sclk_o  <= ~sclk_o;
            end
            else
                count_s <= count_s + 1'b1;
        end
        else begin
            sclk_o  <= pre_sclk_s;
            count_s <= 12'b0;
        end
    end

    // ---------------- MISO receive pulse (sclk0) ----------------
    always @(posedge PCLK or negedge PRESET_n) begin
        if (!PRESET_n) begin
            miso_receive_sclk_o  <= 1'b0;
            miso_receive_sclk0_o <= 1'b0;
        end
        else begin
            if (edge_sel) begin
                if (sclk_o) begin
                    if (count_s == (BaudRateDivisor/2 - 2'b01))
                        miso_receive_sclk0_o <= 1'b1;
                    else
                        miso_receive_sclk0_o <= 1'b0;
                end
                else
                    miso_receive_sclk0_o <= 1'b0;
            end
            else begin
                if (~sclk_o) begin
                    if (count_s == (BaudRateDivisor/2 - 2'b01))
                        miso_receive_sclk0_o <= 1'b1;
                    else
                        miso_receive_sclk0_o <= 1'b0;
                end
                else
                    miso_receive_sclk0_o <= 1'b0;
            end
        end
    end

    // ---------------- MISO receive pulse (sclk) ----------------
    always @(posedge PCLK or negedge PRESET_n) begin
        if (!PRESET_n) begin
            miso_receive_sclk_o <= 1'b0;
        end
        else begin
            if (edge_sel) begin
                if (sclk_o) begin
                    if (count_s == (BaudRateDivisor/2 - 2'b01))
                        miso_receive_sclk_o <= 1'b1;
                    else
                        miso_receive_sclk_o <= 1'b0;
                end
                else
                    miso_receive_sclk_o <= 1'b0;
            end
            else begin
                if (~sclk_o) begin
                    if (count_s == (BaudRateDivisor/2 - 2'b01))
                        miso_receive_sclk_o <= 1'b1;
                    else
                        miso_receive_sclk_o <= 1'b0;
                end
                else
                    miso_receive_sclk_o <= 1'b0;
            end
        end
    end

    // ---------------- MOSI send pulse (sclk0) ----------------
    always @(posedge PCLK or negedge PRESET_n) begin
        if (!PRESET_n) begin
            mosi_send_sclk0_o <= 1'b0;
        end
        else begin
            if (edge_sel) begin
                if (sclk_o) begin
                    if (count_s == (BaudRateDivisor/2 - 2'b10))
                        mosi_send_sclk0_o <= 1'b1;
                    else
                        mosi_send_sclk0_o <= 1'b0;
                end
                else
                    mosi_send_sclk0_o <= 1'b0;
            end
            else begin
                if (~sclk_o) begin
                    if (count_s == (BaudRateDivisor/2 - 2'b10))
                        mosi_send_sclk0_o <= 1'b1;
                    else
                        mosi_send_sclk0_o <= 1'b0;
                end
                else
                    mosi_send_sclk0_o <= 1'b0;
            end
        end
    end

    // ---------------- MOSI send pulse (sclk) ----------------
    always @(posedge PCLK or negedge PRESET_n) begin
        if (!PRESET_n) begin
            mosi_send_sclk_o <= 1'b0;
        end
        else begin
            if (edge_sel) begin
                if (sclk_o) begin
                    if (count_s == (BaudRateDivisor/2 - 2'b10))
                        mosi_send_sclk_o <= 1'b1;
                    else
                        mosi_send_sclk_o <= 1'b0;
                end
                else
                    mosi_send_sclk_o <= 1'b0;
            end
            else begin
                if (~sclk_o) begin
                    if (count_s == (BaudRateDivisor/2 - 2'b10))
                        mosi_send_sclk_o <= 1'b1;
                    else
                        mosi_send_sclk_o <= 1'b0;
                end
                else
                    mosi_send_sclk_o <= 1'b0;
            end
        end
    end

endmodule


