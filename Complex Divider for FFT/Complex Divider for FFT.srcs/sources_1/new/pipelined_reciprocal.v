//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// pipelined_reciprocal.v
//// Fully-synthesizable pipelined reciprocal using binary long division
//// Computes recip_out = floor( 2^OUT_FRAC / denom_in )
//// Throughput: 1 denom / clock, Latency: OUT_FRAC cycles
////////////////////////////////////////////////////////////////////////////////////

//module pipelined_reciprocal #(
//    parameter integer IN_W     = 34,
//    parameter integer OUT_W    = 32,
//    parameter integer OUT_FRAC = 32
//)(
//    input  wire                 clk,
//    input  wire                 rstn,
//    input  wire [IN_W-1:0]      denom_in,
//    input  wire                 denom_valid,
//    output wire [OUT_W-1:0]     recip_out,
//    output wire                 recip_valid
//);

//    localparam integer REM_W = IN_W + OUT_FRAC + 1;
//    integer i;

//    reg [REM_W-1:0] rem_pipe [0:OUT_FRAC-1];
//    reg [OUT_FRAC-1:0] q_pipe [0:OUT_FRAC-1];
//    reg [IN_W-1:0] denom_pipe [0:OUT_FRAC-1];
//    reg valid_pipe [0:OUT_FRAC-1];

//    always @(posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            for (i=0;i<OUT_FRAC;i=i+1) begin
//                rem_pipe[i]   <= 0;
//                q_pipe[i]     <= 0;
//                denom_pipe[i] <= 0;
//                valid_pipe[i] <= 0;
//            end
//        end else begin
//            if (denom_valid) begin
//                rem_pipe[0]   <= {{(REM_W-1){1'b0}}, 1'b1};
//                q_pipe[0]     <= 0;
//                denom_pipe[0] <= denom_in;
//                valid_pipe[0] <= 1'b1;
//            end else begin
//                valid_pipe[0] <= 1'b0;
//                rem_pipe[0]   <= 0;
//                q_pipe[0]     <= 0;
//                denom_pipe[0] <= 0;
//            end

//            for (i=1;i<OUT_FRAC;i=i+1) begin
//                if (valid_pipe[i-1]) begin
//                    if ( (rem_pipe[i-1] << 1) >= { {(REM_W - IN_W){1'b0}}, denom_pipe[i-1] } ) begin
//                        rem_pipe[i] <= (rem_pipe[i-1] << 1) - { {(REM_W - IN_W){1'b0}}, denom_pipe[i-1] };
//                        q_pipe[i]   <= (q_pipe[i-1] << 1) | 1'b1;
//                    end else begin
//                        rem_pipe[i] <= (rem_pipe[i-1] << 1);
//                        q_pipe[i]   <= (q_pipe[i-1] << 1);
//                    end
//                    denom_pipe[i] <= denom_pipe[i-1];
//                    valid_pipe[i] <= 1'b1;
//                end else begin
//                    rem_pipe[i]   <= 0;
//                    q_pipe[i]     <= 0;
//                    denom_pipe[i] <= 0;
//                    valid_pipe[i] <= 0;
//                end
//            end
//        end
//    end

//    reg [OUT_W-1:0] recip_reg;
//    reg recip_valid_reg;

//    always @(posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            recip_reg <= 0;
//            recip_valid_reg <= 0;
//        end else begin
//            if (valid_pipe[OUT_FRAC-1]) begin
//                if (denom_pipe[OUT_FRAC-1] == 0)
//                    recip_reg <= {OUT_W{1'b1}};
//                else if (OUT_W <= OUT_FRAC)
//                    recip_reg <= q_pipe[OUT_FRAC-1][OUT_FRAC-1 -: OUT_W];
//                else
//                    recip_reg <= { {(OUT_W-OUT_FRAC){1'b0}}, q_pipe[OUT_FRAC-1] };
//                recip_valid_reg <= 1'b1;
//            end else
//                recip_valid_reg <= 1'b0;
//        end
//    end

//    assign recip_out   = recip_reg;
//    assign recip_valid = recip_valid_reg;

//endmodule


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// pipelined_reciprocal.v
// Fully-synthesizable pipelined reciprocal using binary long division
// Computes recip_out = floor( 2^OUT_FRAC / denom_in )
// Throughput: 1 denom / clock, Latency: OUT_FRAC cycles
//////////////////////////////////////////////////////////////////////////////////

module pipelined_reciprocal #(
    parameter integer IN_W     = 34,
    parameter integer OUT_W    = 32,
    parameter integer OUT_FRAC = 32
)(
    input  wire                 clk,
    input  wire                 rstn,
    input  wire [IN_W-1:0]      denom_in,
    input  wire                 denom_valid,
    output wire [OUT_W-1:0]     recip_out,
    output wire                 recip_valid
);

    localparam integer REM_W = IN_W + OUT_FRAC + 1;
    integer i;

    reg [REM_W-1:0] rem_pipe [0:OUT_FRAC-1];
    reg [OUT_FRAC-1:0] q_pipe [0:OUT_FRAC-1];
    reg [IN_W-1:0] denom_pipe [0:OUT_FRAC-1];
    reg valid_pipe [0:OUT_FRAC-1];

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i=0;i<OUT_FRAC;i=i+1) begin
                rem_pipe[i]   <= 0;
                q_pipe[i]     <= 0;
                denom_pipe[i] <= 0;
                valid_pipe[i] <= 0;
            end
        end else begin
            if (denom_valid) begin
                rem_pipe[0]   <= {{(REM_W-1){1'b0}}, 1'b1};
                q_pipe[0]     <= 0;
                denom_pipe[0] <= denom_in;
                valid_pipe[0] <= 1'b1;
            end else begin
                valid_pipe[0] <= 1'b0;
                rem_pipe[0]   <= 0;
                q_pipe[0]     <= 0;
                denom_pipe[0] <= 0;
            end

            for (i=1;i<OUT_FRAC;i=i+1) begin
                if (valid_pipe[i-1]) begin
                    if ( (rem_pipe[i-1] << 1) >= { {(REM_W - IN_W){1'b0}}, denom_pipe[i-1] } ) begin
                        rem_pipe[i] <= (rem_pipe[i-1] << 1) - { {(REM_W - IN_W){1'b0}}, denom_pipe[i-1] };
                        q_pipe[i]   <= (q_pipe[i-1] << 1) | 1'b1;
                    end else begin
                        rem_pipe[i] <= (rem_pipe[i-1] << 1);
                        q_pipe[i]   <= (q_pipe[i-1] << 1);
                    end
                    denom_pipe[i] <= denom_pipe[i-1];
                    valid_pipe[i] <= 1'b1;
                end else begin
                    rem_pipe[i]   <= 0;
                    q_pipe[i]     <= 0;
                    denom_pipe[i] <= 0;
                    valid_pipe[i] <= 0;
                end
            end
        end
    end

    reg [OUT_W-1:0] recip_reg;
    reg recip_valid_reg;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            recip_reg <= 0;
            recip_valid_reg <= 0;
        end else begin
            if (valid_pipe[OUT_FRAC-1]) begin
                if (denom_pipe[OUT_FRAC-1] == 0)
                    recip_reg <= {OUT_W{1'b1}};
                else if (OUT_W <= OUT_FRAC)
                    recip_reg <= q_pipe[OUT_FRAC-1][OUT_FRAC-1 -: OUT_W];
                else
                    recip_reg <= { {(OUT_W-OUT_FRAC){1'b0}}, q_pipe[OUT_FRAC-1] };
                recip_valid_reg <= 1'b1;
            end else
                recip_valid_reg <= 1'b0;
        end
    end

    assign recip_out   = recip_reg;
    assign recip_valid = recip_valid_reg;

endmodule