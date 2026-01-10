`timescale 1ns / 1ps

module median_Di #(
    parameter WIDTH = 16
)(
    input  wire               clk,
    input  wire               rstn,
    input  wire               in_valid,
    input  wire               in_last,        // asserted after 32nd Di
    input  wire signed [WIDTH-1:0] Di_re,
    input  wire signed [WIDTH-1:0] Di_im,

    output reg  [WIDTH:0]     med_di,         // median(|Di|)
    output reg                out_valid,
    output reg                busy
);

    localparam COLLECT   = 2'd0,
               S_SORT   = 2'd1,
               S_MEDOUT = 2'd2;

    reg [1:0] state;

    reg [WIDTH:0] D_rom [0:31];// |Re|+|Im| fits in WIDTH + 1 bits, divide by 2 will make it equal to WIDTH
    reg [5:0] idx;
    
    wire [WIDTH-1:0] abs_re = Di_re[WIDTH-1] ? (~Di_re + 1'b1) : Di_re;
    wire [WIDTH-1:0] abs_im = Di_im[WIDTH-1] ? (~Di_im + 1'b1) : Di_im;
    wire [WIDTH:0] D_mod = abs_re + abs_im;

    reg [5:0] i, j;
    reg [WIDTH:0] temp;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            idx <= 0;
            state <= COLLECT;
            busy <= 0;
            out_valid <= 0;
            med_di    <= 0;
            i <= 0;
            j <= 0;
        end
        else begin
            out_valid <= 0;    
            case(state)
            COLLECT: begin
                busy <= 0;
                if(in_valid) begin
                    D_rom[idx] <= D_mod;
                    idx <= idx + 1;

                    if(in_last) begin
                        // 32 samples collected
                        idx <= 0;
                        i   <= 0;
                        j   <= 0;
                        state <= S_SORT;
                    end
                end
            end

            S_SORT: begin
                // one compare-swap per clock
                busy <= 1;
                if(i < 31) begin
                    if(j < 31 - i) begin
                        if(D_rom[j] > D_rom[j+1]) begin
                            temp      = D_rom[j];
                            D_rom[j]   = D_rom[j+1];
                            D_rom[j+1] = temp;
                        end
                        j <= j + 1;
                    end
                    else begin
                        j <= 0;
                        i <= i + 1;
                    end
                end
                else begin
                    // sorting finished
                    state <= S_MEDOUT;
                end
            end

            S_MEDOUT: begin       
                med_di    <= (D_rom[15] + D_rom[16]) >> 2;
                out_valid <= 1;
                busy      <= 0;
                // Prepare for next frame
                idx   <= 0;
                i     <= 0;
                j     <= 0;
                state <= COLLECT;
            end

            endcase
        end
    end

endmodule
