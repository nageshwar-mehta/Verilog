`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Nageshwar Kumar (IIT Jammu)
// Module : Fixed_Point_DividerR1
// Type   : Iterative Restoring Divider (Fixed-point, Signed)
module Fixed_Point_DividerR1 #(
    parameter integer Q = 9,       // fractional bits
    parameter integer N = 16       // total bits (including sign)
)(  input clk, rstn,
    input [N-1:0] divisor, divident,
    output reg [N-1:0] quotient,
    output reg overflow, out_valid);
//    reg [N-1:0]temp_quotient;
//    reg [N-1:0]temp_divident;
//    integer i;
    wire [N-1:0]pos_divisor = ~divisor+1;
    wire [N-1:0]pos_divident = ~divident+1;
    reg [N-1:0]temp_output;
    
    function automatic [N-1:0] divide_unsigned;
        input [N-1:0] divident;
        input [N-1:0] divisor;
        integer i;
        reg [N-1:0] temp_divident;
        reg [N-1:0] temp_quotient;
    begin
        temp_divident = 0;
        temp_quotient = 0;
        for (i = N-1; i >= 0; i = i - 1) begin
            temp_divident = temp_divident << 1;
            temp_divident[0] = divident[i];
            if (temp_divident < divisor) begin
                temp_quotient = (temp_quotient << 1);
            end else begin
                temp_quotient = (temp_quotient << 1) | 1'b1;
                temp_divident = temp_divident - divisor;
            end
        end
        divide_unsigned = (temp_quotient << Q);
    end
    endfunction

    
    always @ (posedge clk or negedge rstn) begin 
//-------------------------------------//
        if(!rstn) begin 
            quotient <= 0;
            overflow <= 0;
            out_valid <= 0;
        end
//-------------------------------------//        
        else begin
            //-------------------------------------//
            //===Divide by zero====//
            if (divisor == 0) begin
                out_valid<=1;
                quotient<=0;
                overflow<=1;
            end
            //-------------------------------------//
            //===Divide by One====//
            //-------------------------------------//
            else if((divisor>>>Q)==1||(divisor>>>Q)==-1) begin
                out_valid<=1;
                quotient<=divident*(divisor>>>Q);
                overflow<=0;
            end
            //-------------------------------------//
            //====Same sign=======//
            //-------------------------------------//
            else if(divisor[N-1]^divident[N-1]==0)begin
                //-------------------------------------//
                //========Both +ve========//
//                if(divisor[N-1]==0)begin
//                    for(i=N-1;i>=0;i=i-1)begin
//                        temp_divident = temp_divident<<1;
//                        temp_divident[0] = divident[i];
//                        if(temp_divident<divisor)begin
//                            temp_quotient = temp_quotient<<1;
//                            temp_quotient[0] = 0; 
//                        end
//                        else begin
//                            temp_quotient = temp_quotient<<1;
//                            temp_quotient[0] = 1; 
//                            temp_divident = temp_divident - divisor; 
//                        end
//                    end
//                end
                if(divisor[N-1]==0)begin
                    out_valid=0;
                    quotient <= divide_unsigned(divident, divisor);
                    if(quotient[N-1]==1)begin
                        overflow<= 1;
                    end
                    else begin
                        overflow<= 0;
                    end
                    out_valid <=1;
                    
                end
                //-------------------------------------//
                //=======Both negetive=======//
                //-------------------------------------//
                else begin
                    out_valid=0;
                    quotient <= divide_unsigned(pos_divident, pos_divisor);
                    if(quotient[N-1]==1)begin
                        overflow<= 1;
                    end
                    else begin
                        overflow<= 0;
                    end
                    out_valid <=1;
                end
                //-------------------------------------//
            end
            //-------------------------------------//
            //=======Different Sign================//
            else if(divisor[N-1]^divident[N-1]==1)begin
                //-------------------------------------//
                //=======Negetive Divisor=======//
                //-------------------------------------//
                if(divisor[N-1]==1)begin
                    out_valid=0;
                    temp_output = divide_unsigned(divident, pos_divisor);
                    quotient <= ~temp_output +1;
                    if(quotient[N-1]==0)begin
                        overflow<= 1;
                    end
                    else begin
                        overflow<= 0;
                    end
                    out_valid <=1;
                    
                end
                //-------------------------------------//
                //=======Negetive Divident=======//
                //-------------------------------------//
                else begin
                    out_valid=0;
                    temp_output = divide_unsigned(pos_divident, divisor);
                    quotient <= ~temp_output + 1;
                    if(quotient[N-1]==0)begin
                        overflow<= 1;
                    end
                    else begin
                        overflow<= 0;
                    end
                    out_valid <=0;
                end
                //-------------------------------------//
                
            end
            else begin
                overflow<=1;
                out_valid<=0;
                quotient<=0;
            end
        end
    end

endmodule
