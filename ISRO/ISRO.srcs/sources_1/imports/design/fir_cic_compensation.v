module fir_cic_compensation #(
    parameter INPUT_WIDTH = 23,
    parameter OUTPUT_WIDTH = 24,
    parameter COEFF_WIDTH = 16,
    parameter NUM_TAPS = 61,
    parameter DECIMATION = 2
)(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire signed [INPUT_WIDTH-1:0] data_in,
    input  wire                          data_in_valid,
    
    output reg  signed [OUTPUT_WIDTH-1:0] data_out,
    output reg                           data_out_valid
);
//    integer i;
    // ========================================
    // COEFFICIENT MEMORY
    // ========================================
    // Load coefficients from MATLAB: coeffs_stage2
    // Use: $readmemh("coeffs_stage2.hex", coeffs);
    
    reg signed [COEFF_WIDTH-1:0] coeffs [0:NUM_TAPS-1];
    
    initial begin
    // Q15 Format: Multiply float by 32768 and round
    coeffs[0]  = 16'sd51;     // 0.00156723775664112
    coeffs[1]  = 16'sd45;     // 0.00136428986646208
    coeffs[2]  = -16'sd50;    // -0.00152764980819799
    coeffs[3]  = -16'sd86;    // -0.00263740383666607
    coeffs[4]  = 16'sd37;     // 0.00113806022025491
    coeffs[5]  = 16'sd100;    // 0.00303924682768571
    coeffs[6]  = -16'sd72;    // -0.00221080070607124
    coeffs[7]  = -16'sd169;   // -0.00517318364076861
    coeffs[8]  = 16'sd70;     // 0.00214050560635953
    coeffs[9]  = 16'sd221;    // 0.00675927851387369
    coeffs[10] = -16'sd98;    // -0.00298743336227466
    coeffs[11] = -16'sd319;   // -0.00973212796231664
    coeffs[12] = 16'sd102;    // 0.00310317029536911
    coeffs[13] = 16'sd419;    // 0.0127854284053769
    coeffs[14] = -16'sd123;   // -0.00374757071196368
    coeffs[15] = -16'sd566;   // -0.0172698613539563
    coeffs[16] = 16'sd127;    // 0.00386239227730237
    coeffs[17] = 16'sd741;    // 0.0226031344847863
    coeffs[18] = -16'sd137;   // -0.00419217071005935
    coeffs[19] = -16'sd985;   // -0.0300565671645954
    coeffs[20] = 16'sd130;    // 0.00398017329729429
    coeffs[21] = 16'sd1314;   // 0.040085519326656
    coeffs[22] = -16'sd115;   // -0.003498725746689
    coeffs[23] = -16'sd1814;  // -0.055346649389258
    coeffs[24] = 16'sd54;     // 0.00165939306952306
    coeffs[25] = 16'sd2655;   // 0.0810004838043251
    coeffs[26] = 16'sd121;    // 0.00367968966030899
    coeffs[27] = -16'sd4464;  // -0.136213192625595
    coeffs[28] = -16'sd955;   // -0.029151717063288
    coeffs[29] = 16'sd11056;  // 0.337369247390436
    coeffs[30] = 16'sd18036;  // 0.550368257264989 (CENTER TAP)
    coeffs[31] = 16'sd11056;  // 0.337369247390436
    coeffs[32] = -16'sd955;   // -0.029151717063288
    coeffs[33] = -16'sd4464;  // -0.136213192625595
    coeffs[34] = 16'sd121;    // 0.00367968966030899
    coeffs[35] = 16'sd2655;   // 0.0810004838043251
    coeffs[36] = 16'sd54;     // 0.00165939306952306
    coeffs[37] = -16'sd1814;  // -0.055346649389258
    coeffs[38] = -16'sd115;   // -0.003498725746689
    coeffs[39] = 16'sd1314;   // 0.040085519326656
    coeffs[40] = 16'sd130;    // 0.00398017329729429
    coeffs[41] = -16'sd985;   // -0.0300565671645954
    coeffs[42] = -16'sd137;   // -0.00419217071005935
    coeffs[43] = 16'sd741;    // 0.0226031344847863
    coeffs[44] = 16'sd127;    // 0.00386239227730237
    coeffs[45] = -16'sd566;   // -0.0172698613539563
    coeffs[46] = -16'sd123;   // -0.00374757071196368
    coeffs[47] = 16'sd419;    // 0.0127854284053769
    coeffs[48] = 16'sd102;    // 0.00310317029536911
    coeffs[49] = -16'sd319;   // -0.00973212796231664
    coeffs[50] = -16'sd98;    // -0.00298743336227466
    coeffs[51] = 16'sd221;    // 0.00675927851387369
    coeffs[52] = 16'sd70;     // 0.00214050560635953
    coeffs[53] = -16'sd169;   // -0.00517318364076861
    coeffs[54] = -16'sd72;    // -0.00221080070607124
    coeffs[55] = 16'sd100;    // 0.00303924682768571
    coeffs[56] = 16'sd37;     // 0.00113806022025491
    coeffs[57] = -16'sd86;    // -0.00263740383666607
    coeffs[58] = -16'sd50;    // -0.00152764980819799
    coeffs[59] = 16'sd45;     // 0.00136428986646208
    coeffs[60] = 16'sd51;     // 0.00156723775664112
end
    
    // ========================================
    // SYMMETRIC FIR OPTIMIZATION
    // ========================================
    // Exploit coefficient symmetry: h[k] = h[N-1-k]
    // This reduces multipliers from 61 to 31!
    
    localparam HALF_TAPS = (NUM_TAPS + 1) / 2;  // 31
    
    // Delay line
    reg signed [INPUT_WIDTH-1:0] delay_line [0:NUM_TAPS-1];
    
    // Pre-adders for symmetric pairs
    reg signed [INPUT_WIDTH:0] pre_add [0:HALF_TAPS-1];
    
    // Products
    reg signed [INPUT_WIDTH+COEFF_WIDTH:0] products [0:HALF_TAPS-1];
    
    // MAC accumulator
    reg signed [INPUT_WIDTH+COEFF_WIDTH+6:0] mac_result;
    
    integer i;
    
    // Shift register
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
    
    // Symmetric MAC
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mac_result <= 0;
        end else if (data_in_valid) begin
            // Add symmetric pairs first
            for (i = 0; i < HALF_TAPS-1; i = i + 1) begin
                pre_add[i] = delay_line[i] + delay_line[NUM_TAPS-1-i];
            end
            // Center tap (no pair)
            pre_add[HALF_TAPS-1] = delay_line[HALF_TAPS-1];
            
            // Multiply by coefficients
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
    
    // Decimation by 2
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