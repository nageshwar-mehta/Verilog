`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.11.2025 19:07:23
// Design Name: 
// Module Name: detail_coffn
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//   Di[0] = h[0]
//   Di[k] = h[2k] - h[2k-1]  for k = 1-31  (last: D31 = h[62] - h[61])
//  input samples arrive sequentially from IFFT block with in_valid asserted for each sample.
// Stops producing Di after D31.
//////////////////////////////////////////////////////////////////////////////////

module detail_coffn #(
    parameter WIDTH = 16
)(
    input                      clk,
    input                      rstn,       
    input signed [WIDTH-1:0]   h_re,
    input signed [WIDTH-1:0]   h_im,
    input                      in_last,    
    input                      in_valid,   
    output reg signed [WIDTH-1:0] Di_re,
    output reg signed [WIDTH-1:0] Di_im,
    output reg                 out_last, 
    output reg                 out_valid    
);

    reg [5:0] count;                // 0 - 63
    reg signed [WIDTH-1:0] prev_re;      // stores h[2k-1]
    reg signed [WIDTH-1:0] prev_im;


    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            count   <= 6'd0;
            prev_re <= {WIDTH{1'b0}};
            prev_im <= {WIDTH{1'b0}};
            Di_re   <= {WIDTH{1'b0}};
            Di_im   <= {WIDTH{1'b0}};
            out_last<= 1'b0;
            out_valid<= 1'b0;
        end else begin
            out_last <= 1'b0; // default low
            out_valid <= 1'b0;                        
            if (in_valid && count <= 6'd62) begin                
                if (count == 6'd0) begin
                    // First sample: D0 = h0
                    Di_re <= h_re;
                    Di_im <= h_im;
                    count <= count + 6'd1;
                    out_valid <= 1'b1;
                    
                end
                else if (count[0] == 1'b1) begin
                    // odd index: store as previous (h[2k-1])
                    prev_re <= h_re;
                    prev_im <= h_im;
                    count <= count + 6'd1;
                    out_valid <= 1'b0;
                end
                else begin
                    // even index : compute Di = h[2k] - h[2k-1]
                    Di_re <= h_re - prev_re;
                    Di_im <= h_im - prev_im; 
                    out_valid <= 1'b1;                   
                    if (count == 6'd62) begin
                        out_last <= 1'b1;
                    end

                    count <= count + 6'd1;
                end
            end            
        end
    end

endmodule

