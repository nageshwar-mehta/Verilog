module gain_compensator #(
    parameter INPUT_WIDTH = 23,
    parameter OUTPUT_WIDTH = 16,
    parameter CIC_GAIN_LOG2 = 18  // log2(262144) = 18
)(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire signed [INPUT_WIDTH-1:0] data_in,
    input  wire                          data_in_valid,
    
    output reg  signed [OUTPUT_WIDTH-1:0] data_out,
    output reg                           data_out_valid
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 0;
            data_out_valid <= 0;
        end else begin
            data_out_valid <= data_in_valid;
            if (data_in_valid) begin
                // Right shift to divide by CIC gain
                data_out <= data_in >>> CIC_GAIN_LOG2;
            end
        end
    end

endmodule