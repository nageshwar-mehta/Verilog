module Complex_conjugate(
    input [31:0] real_in,//real part  eg : 2
    input [31:0] imag_in,//img part   eg : 3
    output [63:0] out_imag_real
    );
    //input = 2+3i;
    wire [31:0] new_imag;
    assign new_imag = {~imag_in[31],imag_in[30:0]}; // img = -img
    assign out_imag_real  = {new_imag[31:0],real_in[31:0]}; //output = -img + real
    //output =  2-3i
//    first 32 bits are img and last 32 bits are real part
    
endmodule 