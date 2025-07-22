`timescale 1ns / 1ps

module fixed_posit_m1_tb;

// Inputs
reg sa, sb;                   // (0,1)
reg [5:0] ea, eb;             // (0,63)
reg [1:0] ra, rb;             // (3,0)
reg [22:0] fa, fb;            // (7fffff,0)

// Outputs
wire sc;
wire [5:0] ec;
wire [1:0] rc;
wire [22:0] fc;

// Instantiate the Unit Under Test (UUT)
fixed_posit_m1 uut (
    .sa(sa), .sb(sb),
    .ea(ea), .eb(eb),
    .ra(ra), .rb(rb),
    .fa(fa), .fb(fb),
    .sc(sc), .rc(rc), .ec(ec), .fc(fc)
);

// Initialization
initial begin
    // Test 0: Basic no shift, no fraction
    sa = 1'b0; sb = 1'b0;            // sc = 0 (+ve nums)
    ra = 2'b10; rb = 2'b10;          // ka = 0, kb = 0 => useed^0 = 1
    ea = 6'b000000; eb = 6'b000000;  // ea = eb = 0
    fa = 23'b0; fb = 23'b0;          // fa = fb = 0 , 1+f = 1
    // Expected: v1 = 1, v2 = 1, product = 1

    #20; 
    
    //Test 2: integer multiplication
    sa = 1'b0; sb = 1'b0;            // sc = 0 (+ve nums)
    ra = 2'b10; rb = 2'b10;          // ka = 0, kb = 0 => useed^0 = 1
    ea = 6'b000001; eb = 6'b000100;  // ea = 1 eb = 4
    fa = 23'b0; fb = 23'b0;          // fa = fb = 0 , 1+f = 1
    // Expected: v1 = 2, v2 = 16, product = 32 (0 10 000101 23x0)
    
    #20;
    
    $stop; // stop simulation
end

// Single combined monitor
initial begin
    $monitor("Time=%0t | sa=%b ra=%b ea=%d fa=%h | sb=%b rb=%b eb=%d fb=%h || sc=%b rc=%b ec=%d fc=%h",
        $time, sa, ra, ea, fa, sb, rb, eb, fb, sc, rc, ec, fc);
end

endmodule
