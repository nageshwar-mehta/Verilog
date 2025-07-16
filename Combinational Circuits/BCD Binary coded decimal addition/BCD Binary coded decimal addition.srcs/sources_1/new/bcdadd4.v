module top_module ( 
    input [15:0] a, b,
    input cin,
    output cout,
    output [15:0] sum );
    wire c1,c2,c3;
    wire[3:0] s1,s2,s3,s4;
    bcd_fadd block1(a[3:0],b[3:0],cin,c1,s1);
    bcd_fadd block2(a[7:4],b[7:4],c1,c2,s2);
    bcd_fadd block3(a[11:8],b[11:8],c2,c3,s3);
    bcd_fadd block4(a[15:12],b[15:12],c3,cout,s4);
    assign sum = {s4,s3,s2,s1};

endmodule
module bcd_fadd(input[3:0]a,input[3:0]b,input cin,output cout,output[3:0] sum);
    wire [4:0] raw_sum ;
    reg [4:0] corrected_sum;
   
    assign raw_sum = a+b+cin;
    always@(*)begin
        if (raw_sum>5'd9) begin
           corrected_sum = raw_sum+5'd6;
        end
        else corrected_sum = raw_sum;
    end
    assign cout = corrected_sum[4];
    assign sum = corrected_sum[3:0];
    
endmodule
