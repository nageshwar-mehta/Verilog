`timescale 1ns/1ps

module decimation_filter_top (
    input  wire        clk,              // System clock (e.g., 1.024 MHz or higher)
    input  wire        rst_n,            // Active-low reset
    
    // Input from Delta-Sigma Modulator
    input  wire signed [3:0] modulator_in,
    input  wire        modulator_valid,
    
    // Final output
    output wire signed [23:0] audio_out,
    output wire        audio_valid
 
);

    // Internal signals
    wire signed [22:0] cic_data;
    wire cic_data_valid;
    
    wire signed [23:0] fir1_data;
    wire fir1_data_valid;
    
    // ========================================
    // STAGE 1: CIC DECIMATOR
    // ========================================
    cic_decimator #(
        .INPUT_WIDTH(4),
        .DECIMATION_RATIO(64),
        .NUM_STAGES(3),
        .DIFF_DELAY(1)
    ) u_cic (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(modulator_in),
        .data_in_valid(modulator_valid),
        .data_out(cic_data),
        .data_out_valid(cic_data_valid)
    );
    
    // ========================================
    // STAGE 2: CIC COMPENSATION FIR (61 TAPS)
    // ========================================
    fir_cic_compensation #(
        .INPUT_WIDTH(23),
        .OUTPUT_WIDTH(24),
        .COEFF_WIDTH(16),
        .NUM_TAPS(61),
        .DECIMATION(2)
    ) u_fir_comp (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(cic_data),
        .data_in_valid(cic_data_valid),
        .data_out(fir1_data),
        .data_out_valid(fir1_data_valid)
    );
    
    // ========================================
    // STAGE 3: STANDARD LOWPASS FIR (70 TAPS)
    // ========================================
    fir_lowpass_standard #(
        .INPUT_WIDTH(24),
        .OUTPUT_WIDTH(24),
        .COEFF_WIDTH(16),
        .NUM_TAPS(70),
        .DECIMATION(2)
    ) u_fir_lpf (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(fir1_data),
        .data_in_valid(fir1_data_valid),
        .data_out(audio_out),
        .data_out_valid(audio_valid)
    );
    
  

endmodule


module cic_decimator #(
    parameter INPUT_WIDTH = 4,
    parameter DECIMATION_RATIO = 64,
    parameter NUM_STAGES = 3,
    parameter DIFF_DELAY = 1,
    
    // Calculated parameters
    parameter OUTPUT_WIDTH = INPUT_WIDTH + $clog2(DECIMATION_RATIO**NUM_STAGES) + 1,
    parameter COUNTER_WIDTH = $clog2(DECIMATION_RATIO)
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire signed [INPUT_WIDTH-1:0] data_in,
    input  wire                         data_in_valid,
    
    output reg  signed [OUTPUT_WIDTH-1:0] data_out,
    output reg                          data_out_valid
);

    // ========================================
    // INTEGRATOR SECTION (High Rate: 1.024 MHz)
    // ========================================
    // Three cascaded integrators
    reg signed [OUTPUT_WIDTH-1:0] integrator1;
    reg signed [OUTPUT_WIDTH-1:0] integrator2;
    reg signed [OUTPUT_WIDTH-1:0] integrator3;
    
    // Sign-extend input to full width
    wire signed [OUTPUT_WIDTH-1:0] data_in_extended;
    assign data_in_extended = {{(OUTPUT_WIDTH-INPUT_WIDTH){data_in[INPUT_WIDTH-1]}}, data_in};
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            integrator1 <= 0;
            integrator2 <= 0;
            integrator3 <= 0;
        end else if (data_in_valid) begin
            // Cascaded integrators: y[n] = y[n-1] + x[n]
            integrator1 <= integrator1 + data_in_extended;
            integrator2 <= integrator2 + integrator1;
            integrator3 <= integrator3 + integrator2;
        end
    end
    
    // ========================================
    // DECIMATION COUNTER
    // ========================================
    reg [COUNTER_WIDTH-1:0] dec_counter;
    reg decimated_valid;
    reg signed [OUTPUT_WIDTH-1:0] decimated_data;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dec_counter <= 0;
            decimated_valid <= 1'b0;
            decimated_data <= 0;
        end else if (data_in_valid) begin
            if (dec_counter == DECIMATION_RATIO - 1) begin
                // Output every 64th sample
                dec_counter <= 0;
                decimated_valid <= 1'b1;
                decimated_data <= integrator3;
            end else begin
                dec_counter <= dec_counter + 1;
                decimated_valid <= 1'b0;
            end
        end else begin
            decimated_valid <= 1'b0;
        end
    end
    
    // ========================================
    // COMB SECTION (Low Rate: 16 kHz)
    // ========================================
    // Three cascaded differentiators (combs)
    // For M=1: y[n] = x[n] - x[n-1]
    
    reg signed [OUTPUT_WIDTH-1:0] comb1_delay;
    reg signed [OUTPUT_WIDTH-1:0] comb2_delay;
    reg signed [OUTPUT_WIDTH-1:0] comb3_delay;
    
    reg signed [OUTPUT_WIDTH-1:0] comb1_out;
    reg signed [OUTPUT_WIDTH-1:0] comb2_out;
    reg signed [OUTPUT_WIDTH-1:0] comb3_out;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            comb1_delay <= 0;
            comb2_delay <= 0;
            comb3_delay <= 0;
            comb1_out <= 0;
            comb2_out <= 0;
            comb3_out <= 0;
            data_out <= 0;
            data_out_valid <= 1'b0;
        end else if (decimated_valid) begin
            // Comb Stage 1
            comb1_out <= decimated_data - comb1_delay;
            comb1_delay <= decimated_data;
            
            // Comb Stage 2
            comb2_out <= comb1_out - comb2_delay;
            comb2_delay <= comb1_out;
            
            // Comb Stage 3
            comb3_out <= comb2_out - comb3_delay;
            comb3_delay <= comb2_out;
            
            // Final output
            data_out <= comb3_out;
            data_out_valid <= 1'b1;
        end else begin
            data_out_valid <= 1'b0;
        end
    end

endmodule
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

    // ========================================
    // COEFFICIENTS
    // ========================================
    wire signed [COEFF_WIDTH-1:0] coeffs [0:NUM_TAPS-1];

    
    // Q15 Format: Multiply float by 32768 and round
    assign coeffs[0]  = 16'sd51;     // 0.00156723775664112
    assign coeffs[1]  = 16'sd45;     // 0.00136428986646208
    assign coeffs[2]  = -16'sd50;    // -0.00152764980819799
    assign coeffs[3]  = -16'sd86;    // -0.00263740383666607
    assign coeffs[4]  = 16'sd37;     // 0.00113806022025491
    assign coeffs[5]  = 16'sd100;    // 0.00303924682768571
    assign coeffs[6]  = -16'sd72;    // -0.00221080070607124
    assign coeffs[7]  = -16'sd169;   // -0.00517318364076861
    assign coeffs[8]  = 16'sd70;     // 0.00214050560635953
    assign coeffs[9]  = 16'sd221;    // 0.00675927851387369
    assign coeffs[10] = -16'sd98;    // -0.00298743336227466
    assign coeffs[11] = -16'sd319;   // -0.00973212796231664
    assign coeffs[12] = 16'sd102;    // 0.00310317029536911
    assign coeffs[13] = 16'sd419;    // 0.0127854284053769
    assign coeffs[14] = -16'sd123;   // -0.00374757071196368
    assign coeffs[15] = -16'sd566;   // -0.0172698613539563
    assign coeffs[16] = 16'sd127;    // 0.00386239227730237
    assign coeffs[17] = 16'sd741;    // 0.0226031344847863
    assign coeffs[18] = -16'sd137;   // -0.00419217071005935
    assign coeffs[19] = -16'sd985;   // -0.0300565671645954
    assign coeffs[20] = 16'sd130;    // 0.00398017329729429
    assign coeffs[21] = 16'sd1314;   // 0.040085519326656
    assign coeffs[22] = -16'sd115;   // -0.003498725746689
    assign coeffs[23] = -16'sd1814;  // -0.055346649389258
    assign coeffs[24] = 16'sd54;     // 0.00165939306952306
    assign coeffs[25] = 16'sd2655;   // 0.0810004838043251
    assign coeffs[26] = 16'sd121;    // 0.00367968966030899
    assign coeffs[27] = -16'sd4464;  // -0.136213192625595
    assign coeffs[28] = -16'sd955;   // -0.029151717063288
    assign coeffs[29] = 16'sd11056;  // 0.337369247390436
    assign coeffs[30] = 16'sd18036;  // 0.550368257264989 (CENTER TAP)
    assign coeffs[31] = 16'sd11056;  // 0.337369247390436
    assign coeffs[32] = -16'sd955;   // -0.029151717063288
    assign coeffs[33] = -16'sd4464;  // -0.136213192625595
    assign coeffs[34] = 16'sd121;    // 0.00367968966030899
    assign coeffs[35] = 16'sd2655;   // 0.0810004838043251
    assign coeffs[36] = 16'sd54;     // 0.00165939306952306
    assign coeffs[37] = -16'sd1814;  // -0.055346649389258
    assign coeffs[38] = -16'sd115;   // -0.003498725746689
    assign coeffs[39] = 16'sd1314;   // 0.040085519326656
    assign coeffs[40] = 16'sd130;    // 0.00398017329729429
    assign coeffs[41] = -16'sd985;   // -0.0300565671645954
    assign coeffs[42] = -16'sd137;   // -0.00419217071005935
    assign coeffs[43] = 16'sd741;    // 0.0226031344847863
    assign coeffs[44] = 16'sd127;    // 0.00386239227730237
    assign coeffs[45] = -16'sd566;   // -0.0172698613539563
    assign coeffs[46] = -16'sd123;   // -0.00374757071196368
    assign coeffs[47] = 16'sd419;    // 0.0127854284053769
    assign coeffs[48] = 16'sd102;    // 0.00310317029536911
    assign coeffs[49] = -16'sd319;   // -0.00973212796231664
    assign coeffs[50] = -16'sd98;    // -0.00298743336227466
    assign coeffs[51] = 16'sd221;    // 0.00675927851387369
    assign coeffs[52] = 16'sd70;     // 0.00214050560635953
    assign coeffs[53] = -16'sd169;   // -0.00517318364076861
    assign coeffs[54] = -16'sd72;    // -0.00221080070607124
    assign coeffs[55] = 16'sd100;    // 0.00303924682768571
    assign coeffs[56] = 16'sd37;     // 0.00113806022025491
    assign coeffs[57] = -16'sd86;    // -0.00263740383666607
    assign coeffs[58] = -16'sd50;    // -0.00152764980819799
    assign coeffs[59] = 16'sd45;     // 0.00136428986646208
    assign coeffs[60] = 16'sd51;     // 0.00156723775664112

    // ========================================
    // PIPELINE ARCHITECTURE
    // ========================================
    localparam HALF_TAPS = (NUM_TAPS + 1) / 2;  // 31
    localparam NUM_PARTIAL = (HALF_TAPS + 3) / 4;  // 8
    
    // Delay line
    reg signed [INPUT_WIDTH-1:0] delay_line [0:NUM_TAPS-1];
    
    // Pipeline Stage 1: Pre-adders
    reg signed [INPUT_WIDTH:0] pre_add [0:HALF_TAPS-1];
    reg stage1_valid;
    
    // Pipeline Stage 2: Multipliers
    reg signed [INPUT_WIDTH+COEFF_WIDTH:0] products [0:HALF_TAPS-1];
    reg stage2_valid;
    
    // Pipeline Stage 3: Partial sums
    reg signed [INPUT_WIDTH+COEFF_WIDTH+3:0] partial_sums [0:NUM_PARTIAL-1];
    reg stage3_valid;
    
    // Pipeline Stage 4: Final sum
    reg signed [INPUT_WIDTH+COEFF_WIDTH+6:0] final_sum;
    reg stage4_valid;
    
    // Temporary combinational variables (these can be blocking)
    reg signed [INPUT_WIDTH+COEFF_WIDTH+3:0] temp_partial;
    reg signed [INPUT_WIDTH+COEFF_WIDTH+6:0] temp_final;
    
    integer i, j;
    
   
    // ========================================
    // STAGE 1: DELAY LINE + PRE-ADDERS
    // ========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage1_valid <= 1'b0;
            for (i = 0; i < NUM_TAPS; i = i + 1) begin
                delay_line[i] <= {INPUT_WIDTH{1'b0}};
            end
            for (i = 0; i < HALF_TAPS; i = i + 1) begin
                pre_add[i] <= {(INPUT_WIDTH+1){1'b0}};
            end
        end else begin
            stage1_valid <= data_in_valid;
            
            if (data_in_valid) begin
                delay_line[0] <= data_in;
                for (i = 1; i < NUM_TAPS; i = i + 1) begin
                    delay_line[i] <= delay_line[i-1];
                end
                
                for (i = 0; i < HALF_TAPS-1; i = i + 1) begin
                    pre_add[i] <= delay_line[i] + delay_line[NUM_TAPS-1-i];
                end
                pre_add[HALF_TAPS-1] <= delay_line[HALF_TAPS-1];
            end
        end
    end
    
    // ========================================
    // STAGE 2: MULTIPLIERS
    // ========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage2_valid <= 1'b0;
            for (i = 0; i < HALF_TAPS; i = i + 1) begin
                products[i] <= {(INPUT_WIDTH+COEFF_WIDTH+1){1'b0}};
            end
        end else begin
            stage2_valid <= stage1_valid;
            
            if (stage1_valid) begin
                for (i = 0; i < HALF_TAPS; i = i + 1) begin
                    products[i] <= pre_add[i] * coeffs[i];
                end
            end
        end
    end
    
    // ========================================
    // STAGE 3: PARTIAL SUMS (4-way tree)
    // FIXED: Proper blocking/non-blocking usage
    // ========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage3_valid <= 1'b0;
            for (i = 0; i < NUM_PARTIAL; i = i + 1) begin
                partial_sums[i] <= {(INPUT_WIDTH+COEFF_WIDTH+4){1'b0}};
            end
        end else begin
            stage3_valid <= stage2_valid;
            
            if (stage2_valid) begin
                for (i = 0; i < NUM_PARTIAL; i = i + 1) begin
                    // Use blocking for temporary calculation
                    temp_partial = {(INPUT_WIDTH+COEFF_WIDTH+4){1'b0}};
                    
                    for (j = 0; j < 4; j = j + 1) begin
                        if ((i*4 + j) < HALF_TAPS) begin
                            temp_partial = temp_partial + products[i*4 + j];
                        end
                    end
                    
                    // Non-blocking assignment to register
                    partial_sums[i] <= temp_partial;
                end
            end
        end
    end
    
    // ========================================
    // STAGE 4: FINAL SUM
    // FIXED: Proper blocking/non-blocking usage
    // ========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage4_valid <= 1'b0;
            final_sum <= {(INPUT_WIDTH+COEFF_WIDTH+7){1'b0}};
        end else begin
            stage4_valid <= stage3_valid;
            
            if (stage3_valid) begin
                // Use blocking for temporary calculation
                temp_final = {(INPUT_WIDTH+COEFF_WIDTH+7){1'b0}};
                
                for (i = 0; i < NUM_PARTIAL; i = i + 1) begin
                    temp_final = temp_final + partial_sums[i];
                end
                
                // Non-blocking assignment to register
                final_sum <= temp_final;
            end
        end
    end
    
    // ========================================
    // DECIMATION BY 2
    // ========================================
    reg dec_toggle;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dec_toggle <= 1'b0;
            data_out <= {OUTPUT_WIDTH{1'b0}};
            data_out_valid <= 1'b0;
        end else begin
            if (stage4_valid) begin
                dec_toggle <= ~dec_toggle;
                
                if (dec_toggle) begin
                    data_out <= final_sum[INPUT_WIDTH+COEFF_WIDTH+6 -: OUTPUT_WIDTH];
                    data_out_valid <= 1'b1;
                end else begin
                    data_out_valid <= 1'b0;
                end
            end else begin
                data_out_valid <= 1'b0;
            end
        end
    end


endmodule

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
    // COEFFICIENTS
    // ========================================
    wire signed [COEFF_WIDTH-1:0] coeffs [0:NUM_TAPS-1];
    
 
    // Q15 Format: Multiply float by 32768 and round
    assign coeffs[0]  = 16'sd0;      // -1.01856152299957e-05 (rounds to 0)
    assign coeffs[1]  = -16'sd22;    // -0.000681482399587287
    assign coeffs[2]  = -16'sd56;    // -0.00169724024859198
    assign coeffs[3]  = -16'sd44;    // -0.00135313182533946
    assign coeffs[4]  = 16'sd24;     // 0.000739628340112045
    assign coeffs[5]  = 16'sd51;     // 0.00155466216490508
    assign coeffs[6]  = -16'sd25;    // -0.000755292592924844
    assign coeffs[7]  = -16'sd73;    // -0.00222185257724471
    assign coeffs[8]  = 16'sd24;     // 0.000725473830998784
    assign coeffs[9]  = 16'sd104;    // 0.00316342718905174
    assign coeffs[10] = -16'sd19;    // -0.000566618688569036
    assign coeffs[11] = -16'sd143;   // -0.00436483473993474
    assign coeffs[12] = 16'sd8;      // 0.000229972712716431
    assign coeffs[13] = 16'sd192;    // 0.00584776667188319
    assign coeffs[14] = 16'sd11;     // 0.000340132163276587
    assign coeffs[15] = -16'sd251;   // -0.00765049433076375
    assign coeffs[16] = -16'sd40;    // -0.00121551803743147
    assign coeffs[17] = 16'sd322;    // 0.00982884711553702
    assign coeffs[18] = 16'sd82;     // 0.00249235389070427
    assign coeffs[19] = -16'sd408;   // -0.0124664206066404
    assign coeffs[20] = -16'sd141;   // -0.00430727999728216
    assign coeffs[21] = 16'sd514;    // 0.0156984251667923
    assign coeffs[22] = 16'sd225;    // 0.00686977075853652
    assign coeffs[23] = -16'sd647;   // -0.0197609209603029
    assign coeffs[24] = -16'sd345;   // -0.0105337914164905
    assign coeffs[25] = 16'sd823;    // 0.0251022817662649
    assign coeffs[26] = 16'sd523;    // 0.0159723976886922
    assign coeffs[27] = -16'sd1071;  // -0.0326723972418244
    assign coeffs[28] = -16'sd808;   // -0.0246752979374044
    assign coeffs[29] = 16'sd1469;   // 0.0448400135469002
    assign coeffs[30] = 16'sd1336;   // 0.0407754072769057
    assign coeffs[31] = -16'sd2276;  // -0.0694527557678144
    assign coeffs[32] = -16'sd2676;  // -0.0816435223595301
    assign coeffs[33] = 16'sd5124;   // 0.156369385204054
    assign coeffs[34] = 16'sd14508;  // 0.442752114777915 (CENTER TAP 1)
    assign coeffs[35] = 16'sd14508;  // 0.442752114777915 (CENTER TAP 2)
    assign coeffs[36] = 16'sd5124;   // 0.156369385204054
    assign coeffs[37] = -16'sd2676;  // -0.0816435223595301
    assign coeffs[38] = -16'sd2276;  // -0.0694527557678144
    assign coeffs[39] = 16'sd1336;   // 0.0407754072769057
    assign coeffs[40] = 16'sd1469;   // 0.0448400135469002
    assign coeffs[41] = -16'sd808;   // -0.0246752979374044
    assign coeffs[42] = -16'sd1071;  // -0.0326723972418244
    assign coeffs[43] = 16'sd523;    // 0.0159723976886922
    assign coeffs[44] = 16'sd823;    // 0.0251022817662649
    assign coeffs[45] = -16'sd345;   // -0.0105337914164905
    assign coeffs[46] = -16'sd647;   // -0.0197609209603029
    assign coeffs[47] = 16'sd225;    // 0.00686977075853652
    assign coeffs[48] = 16'sd514;    // 0.0156984251667923
    assign coeffs[49] = -16'sd141;   // -0.00430727999728216
    assign coeffs[50] = -16'sd408;   // -0.0124664206066404
    assign coeffs[51] = 16'sd82;     // 0.00249235389070427
    assign coeffs[52] = 16'sd322;    // 0.00982884711553702
    assign coeffs[53] = -16'sd40;    // -0.00121551803743147
    assign coeffs[54] = -16'sd251;   // -0.00765049433076375
    assign coeffs[55] = 16'sd11;     // 0.000340132163276587
    assign coeffs[56] = 16'sd192;    // 0.00584776667188319
    assign coeffs[57] = 16'sd8;      // 0.000229972712716431
    assign coeffs[58] = -16'sd143;   // -0.00436483473993474
    assign coeffs[59] = -16'sd19;    // -0.000566618688569036
    assign coeffs[60] = 16'sd104;    // 0.00316342718905174
    assign coeffs[61] = 16'sd24;     // 0.000725473830998784
    assign coeffs[62] = -16'sd73;    // -0.00222185257724471
    assign coeffs[63] = -16'sd25;    // -0.000755292592924844
    assign coeffs[64] = 16'sd51;     // 0.00155466216490508
    assign coeffs[65] = 16'sd24;     // 0.000739628340112045
    assign coeffs[66] = -16'sd44;    // -0.00135313182533946
    assign coeffs[67] = -16'sd56;    // -0.00169724024859198
    assign coeffs[68] = -16'sd22;    // -0.000681482399587287
    assign coeffs[69] = 16'sd0;      // -1.01856152299957e-05 (rounds to 0)


    
    // ========================================
    // PIPELINED SYMMETRIC FIR
    // ========================================
    localparam HALF_TAPS = NUM_TAPS / 2;  // 35
       reg signed [INPUT_WIDTH+COEFF_WIDTH+3:0] temp_partial;
    reg signed [INPUT_WIDTH+COEFF_WIDTH+6:0] temp_final;
    
    // Delay line
    reg signed [INPUT_WIDTH-1:0] delay_line [0:NUM_TAPS-1];
    
    // Pipeline stages (same structure as FIR1)
    reg signed [INPUT_WIDTH:0] pre_add [0:HALF_TAPS-1];
    reg signed [INPUT_WIDTH+COEFF_WIDTH:0] products [0:HALF_TAPS-1];
    
    localparam NUM_PARTIAL = (HALF_TAPS + 3) / 4;
    reg signed [INPUT_WIDTH+COEFF_WIDTH+3:0] partial_sums [0:NUM_PARTIAL-1];
    reg signed [INPUT_WIDTH+COEFF_WIDTH+6:0] final_sum;
    
    reg stage1_valid, stage2_valid, stage3_valid, stage4_valid;
    
    integer i, j;
    
    // ========================================
    // STAGE 1: PRE-ADDERS
    // ========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < NUM_TAPS; i = i + 1)
                delay_line[i] <= 0;
            for (i = 0; i < HALF_TAPS; i = i + 1)
                pre_add[i] <= 0;
            stage1_valid <= 0;
        end else begin
            stage1_valid <= data_in_valid;
            if (data_in_valid) begin
                delay_line[0] <= data_in;
                for (i = 1; i < NUM_TAPS; i = i + 1)
                    delay_line[i] <= delay_line[i-1];
                
                for (i = 0; i < HALF_TAPS; i = i + 1)
                    pre_add[i] <= delay_line[i] + delay_line[NUM_TAPS-1-i];
            end
        end
    end
    
    // ========================================
    // STAGE 2: MULTIPLIERS
    // ========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < HALF_TAPS; i = i + 1)
                products[i] <= 0;
            stage2_valid <= 0;
        end else begin
            stage2_valid <= stage1_valid;
            if (stage1_valid) begin
                for (i = 0; i < HALF_TAPS; i = i + 1)
                    products[i] <= pre_add[i] * coeffs[i];
            end
        end
    end
    
    // ========================================
    // STAGE 3: PARTIAL SUMS
    // FIXED: Proper blocking/non-blocking usage
    // ========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < NUM_PARTIAL; i = i + 1)
                partial_sums[i] <= 0;
            stage3_valid <= 0;
        end else begin
            stage3_valid <= stage2_valid;
            if (stage2_valid) begin
                for (i = 0; i < NUM_PARTIAL; i = i + 1) begin
                    // Use blocking for temporary calculation
                    temp_partial = 0;
                    for (j = 0; j < 4; j = j + 1) begin
                        if ((i*4 + j) < HALF_TAPS)
                            temp_partial = temp_partial + products[i*4 + j];
                    end
                    // Non-blocking assignment to register
                    partial_sums[i] <= temp_partial;
                end
            end
        end
    end
    
    // ========================================
    // STAGE 4: FINAL SUM
    // FIXED: Proper blocking/non-blocking usage
    // ========================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            final_sum <= 0;
            stage4_valid <= 0;
        end else begin
            stage4_valid <= stage3_valid;
            if (stage3_valid) begin
                // Use blocking for temporary calculation
                temp_final = 0;
                for (i = 0; i < NUM_PARTIAL; i = i + 1)
                    temp_final = temp_final + partial_sums[i];
                // Non-blocking assignment to register
                final_sum <= temp_final;
            end
        end
    end
    
    // ========================================
    // DECIMATION BY 2
    // ========================================
    reg dec_toggle;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dec_toggle <= 0;
            data_out <= 0;
            data_out_valid <= 0;
        end else begin
            if (stage4_valid) begin
                dec_toggle <= ~dec_toggle;
                if (dec_toggle) begin
                    data_out <= final_sum[INPUT_WIDTH+COEFF_WIDTH+6 -: OUTPUT_WIDTH];
                    data_out_valid <= 1;
                end else begin
                    data_out_valid <= 0;
                end
            end else begin
                data_out_valid <= 0;
            end
        end
    end


endmodule