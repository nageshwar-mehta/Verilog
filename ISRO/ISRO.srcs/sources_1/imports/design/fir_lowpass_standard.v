module fir_lowpass_standard #(
    parameter INPUT_WIDTH = 24,
    parameter OUTPUT_WIDTH = 24,
    parameter COEFF_WIDTH = 16,
    parameter NUM_TAPS = 70,
    parameter DECIMATION = 2
)(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire signed [INPUT_WIDTH-1:0] data_in,
    input  wire                          data_in_valid,
    
    output reg  signed [OUTPUT_WIDTH-1:0] data_out,
    output reg                           data_out_valid
);

    // ========================================
    // COEFFICIENT MEMORY
    // ========================================
    reg signed [COEFF_WIDTH-1:0] coeffs [0:NUM_TAPS-1];
    
   initial begin
    // Q15 Format: Multiply float by 32768 and round
    coeffs[0]  = 16'sd0;      // -1.01856152299957e-05 (rounds to 0)
    coeffs[1]  = -16'sd22;    // -0.000681482399587287
    coeffs[2]  = -16'sd56;    // -0.00169724024859198
    coeffs[3]  = -16'sd44;    // -0.00135313182533946
    coeffs[4]  = 16'sd24;     // 0.000739628340112045
    coeffs[5]  = 16'sd51;     // 0.00155466216490508
    coeffs[6]  = -16'sd25;    // -0.000755292592924844
    coeffs[7]  = -16'sd73;    // -0.00222185257724471
    coeffs[8]  = 16'sd24;     // 0.000725473830998784
    coeffs[9]  = 16'sd104;    // 0.00316342718905174
    coeffs[10] = -16'sd19;    // -0.000566618688569036
    coeffs[11] = -16'sd143;   // -0.00436483473993474
    coeffs[12] = 16'sd8;      // 0.000229972712716431
    coeffs[13] = 16'sd192;    // 0.00584776667188319
    coeffs[14] = 16'sd11;     // 0.000340132163276587
    coeffs[15] = -16'sd251;   // -0.00765049433076375
    coeffs[16] = -16'sd40;    // -0.00121551803743147
    coeffs[17] = 16'sd322;    // 0.00982884711553702
    coeffs[18] = 16'sd82;     // 0.00249235389070427
    coeffs[19] = -16'sd408;   // -0.0124664206066404
    coeffs[20] = -16'sd141;   // -0.00430727999728216
    coeffs[21] = 16'sd514;    // 0.0156984251667923
    coeffs[22] = 16'sd225;    // 0.00686977075853652
    coeffs[23] = -16'sd647;   // -0.0197609209603029
    coeffs[24] = -16'sd345;   // -0.0105337914164905
    coeffs[25] = 16'sd823;    // 0.0251022817662649
    coeffs[26] = 16'sd523;    // 0.0159723976886922
    coeffs[27] = -16'sd1071;  // -0.0326723972418244
    coeffs[28] = -16'sd808;   // -0.0246752979374044
    coeffs[29] = 16'sd1469;   // 0.0448400135469002
    coeffs[30] = 16'sd1336;   // 0.0407754072769057
    coeffs[31] = -16'sd2276;  // -0.0694527557678144
    coeffs[32] = -16'sd2676;  // -0.0816435223595301
    coeffs[33] = 16'sd5124;   // 0.156369385204054
    coeffs[34] = 16'sd14508;  // 0.442752114777915 (CENTER TAP 1)
    coeffs[35] = 16'sd14508;  // 0.442752114777915 (CENTER TAP 2)
    coeffs[36] = 16'sd5124;   // 0.156369385204054
    coeffs[37] = -16'sd2676;  // -0.0816435223595301
    coeffs[38] = -16'sd2276;  // -0.0694527557678144
    coeffs[39] = 16'sd1336;   // 0.0407754072769057
    coeffs[40] = 16'sd1469;   // 0.0448400135469002
    coeffs[41] = -16'sd808;   // -0.0246752979374044
    coeffs[42] = -16'sd1071;  // -0.0326723972418244
    coeffs[43] = 16'sd523;    // 0.0159723976886922
    coeffs[44] = 16'sd823;    // 0.0251022817662649
    coeffs[45] = -16'sd345;   // -0.0105337914164905
    coeffs[46] = -16'sd647;   // -0.0197609209603029
    coeffs[47] = 16'sd225;    // 0.00686977075853652
    coeffs[48] = 16'sd514;    // 0.0156984251667923
    coeffs[49] = -16'sd141;   // -0.00430727999728216
    coeffs[50] = -16'sd408;   // -0.0124664206066404
    coeffs[51] = 16'sd82;     // 0.00249235389070427
    coeffs[52] = 16'sd322;    // 0.00982884711553702
    coeffs[53] = -16'sd40;    // -0.00121551803743147
    coeffs[54] = -16'sd251;   // -0.00765049433076375
    coeffs[55] = 16'sd11;     // 0.000340132163276587
    coeffs[56] = 16'sd192;    // 0.00584776667188319
    coeffs[57] = 16'sd8;      // 0.000229972712716431
    coeffs[58] = -16'sd143;   // -0.00436483473993474
    coeffs[59] = -16'sd19;    // -0.000566618688569036
    coeffs[60] = 16'sd104;    // 0.00316342718905174
    coeffs[61] = 16'sd24;     // 0.000725473830998784
    coeffs[62] = -16'sd73;    // -0.00222185257724471
    coeffs[63] = -16'sd25;    // -0.000755292592924844
    coeffs[64] = 16'sd51;     // 0.00155466216490508
    coeffs[65] = 16'sd24;     // 0.000739628340112045
    coeffs[66] = -16'sd44;    // -0.00135313182533946
    coeffs[67] = -16'sd56;    // -0.00169724024859198
    coeffs[68] = -16'sd22;    // -0.000681482399587287
    coeffs[69] = 16'sd0;      // -1.01856152299957e-05 (rounds to 0)
end

    
    // ========================================
    // SYMMETRIC FIR (70 taps → 35 multipliers)
    // ========================================
    localparam HALF_TAPS = NUM_TAPS / 2;  // 35
    
    reg signed [INPUT_WIDTH-1:0] delay_line [0:NUM_TAPS-1];
    reg signed [INPUT_WIDTH:0] pre_add [0:HALF_TAPS-1];
    reg signed [INPUT_WIDTH+COEFF_WIDTH:0] products [0:HALF_TAPS-1];
    reg signed [INPUT_WIDTH+COEFF_WIDTH+6:0] mac_result;
    
    integer i;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < NUM_TAPS; i = i + 1) begin
                delay_line[i] <= 0;
            end
        end else if (data_in_valid) begin
            delay_line[0] <= data_in;
            for (i = 1; i < NUM_TAPS; i = i + 1) begin
                delay_line[i] <= delay_line[i-1];
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mac_result <= 0;
        end else if (data_in_valid) begin
            // Symmetric pairs
            for (i = 0; i < HALF_TAPS; i = i + 1) begin
                pre_add[i] = delay_line[i] + delay_line[NUM_TAPS-1-i];
            end
            
            // Multiply
            for (i = 0; i < HALF_TAPS; i = i + 1) begin
                products[i] = pre_add[i] * coeffs[i];
            end
            
            // Accumulate
            mac_result = 0;
            for (i = 0; i < HALF_TAPS; i = i + 1) begin
                mac_result = mac_result + products[i];
            end
        end
    end
    
    reg dec_toggle;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dec_toggle <= 0;
            data_out <= 0;
            data_out_valid <= 0;
        end else if (data_in_valid) begin
            dec_toggle <= ~dec_toggle;
            if (dec_toggle) begin
                data_out <= mac_result[INPUT_WIDTH+COEFF_WIDTH+6 -: OUTPUT_WIDTH];
                data_out_valid <= 1;
            end else begin
                data_out_valid <= 0;
            end
        end else begin
            data_out_valid <= 0;
        end
    end

endmodule
