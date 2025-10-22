// cordic_pipeline.v
// Pipelined (unfolded) CORDIC processor (circular) supporting rotation/vectoring modes.
// Mode: 0 = rotation (sigma = sign(z)), 1 = vectoring (sigma = -sign(y))
// Signed fixed-point Q format: WL total bits, FL fractional bits
`timescale 1ns/1ps
module cordic_pipeline #(
    parameter integer WL   = 32,
    parameter integer FL   = 16,
    parameter integer ITERS= 31  // number of micro-rotations/stages
)(
    input  wire                 clk,
    input  wire                 rstn,
    input  wire                 validIn,
    input  wire signed [WL-1:0] x_in,
    input  wire signed [WL-1:0] y_in,
    input  wire signed [WL-1:0] z_in,      // angle (for rotation) or 0 (for vectoring)
    input  wire                 mode,      // 0 = rotation, 1 = vectoring
    output wire signed [WL-1:0] x_out,
    output wire signed [WL-1:0] y_out,
    output wire signed [WL-1:0] z_out,
    output wire                 validOut
);

    // Internal pipeline registers arrays
    // stage 0 stores inputs; stage i stores results after micro-rotation i-1
    reg signed [WL-1:0] xreg [0:ITERS];
    reg signed [WL-1:0] yreg [0:ITERS];
    reg signed [WL-1:0] zreg [0:ITERS];
    reg                vreg [0:ITERS];

    integer i;
    // Precomputed atan table in Q format (WL, FL)
    // We compute atan(2^-i) scaled by 2^FL and store as signed constants.
    // For simplicity we compute approximate constants offline and put them here.
    // Below generation uses real calc - synthesizers ignore real constants in regs but we set them in initial.
    reg signed [WL-1:0] atan_table [0:ITERS-1];

    // initialize angle table (fixed-point) at elaboration
    real aval;
    initial begin
        for (i=0;i<ITERS;i=i+1) begin
            aval = $atan(2.0**(-i)); // radians
            // scale by 2^FL
            atan_table[i] = $rtoi(aval * (2.0**FL));
        end
    end

    // Pipeline registers reset
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (i=0;i<=ITERS;i=i+1) begin
                xreg[i] <= 0;
                yreg[i] <= 0;
                zreg[i] <= 0;
                vreg[i] <= 1'b0;
            end
        end else begin
            // stage 0 captures inputs
            xreg[0] <= x_in;
            yreg[0] <= y_in;
            zreg[0] <= z_in;
            vreg[0] <= validIn;

            // propagate through stages
            for (i=0;i<ITERS;i=i+1) begin
                // sigma depends on mode
                // rotation mode: sigma = sign(z)
                // vectoring mode: sigma = -sign(y)
                if (mode == 1'b0) begin
                    // rotation
                    if (zreg[i][WL-1] == 1'b0) begin // z >= 0 -> sigma = +1
                        xreg[i+1] <= xreg[i] - ( (yreg[i]) >>> i );
                        yreg[i+1] <= yreg[i] + ( (xreg[i]) >>> i );
                        zreg[i+1] <= zreg[i] - atan_table[i];
                    end else begin // z < 0 -> sigma = -1
                        xreg[i+1] <= xreg[i] + ( (yreg[i]) >>> i );
                        yreg[i+1] <= yreg[i] - ( (xreg[i]) >>> i );
                        zreg[i+1] <= zreg[i] + atan_table[i];
                    end
                end else begin
                    // vectoring mode: sigma = -sign(y)
                    if (yreg[i][WL-1] == 1'b1) begin // y < 0 -> sign(y) = -1 => sigma = -(-1)=+1
                        // sigma = +1
                        xreg[i+1] <= xreg[i] - ( (yreg[i]) >>> i );
                        yreg[i+1] <= yreg[i] + ( (xreg[i]) >>> i );
                        zreg[i+1] <= zreg[i] - atan_table[i];
                    end else begin
                        // sigma = -1
                        xreg[i+1] <= xreg[i] + ( (yreg[i]) >>> i );
                        yreg[i+1] <= yreg[i] - ( (xreg[i]) >>> i );
                        zreg[i+1] <= zreg[i] + atan_table[i];
                    end
                end
                vreg[i+1] <= vreg[i];
            end
        end
    end

    assign x_out = xreg[ITERS];
    assign y_out = yreg[ITERS];
    assign z_out = zreg[ITERS];
    assign validOut = vreg[ITERS];

endmodule
