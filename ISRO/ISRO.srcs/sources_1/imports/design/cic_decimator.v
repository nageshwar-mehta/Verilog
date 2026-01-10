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