`timescale 1ns / 1ps


module Four_deep_FIFO_tb;

//output ports
wire fifo_empty,fifo_full;
wire [3:0] data_out;

//input ports
reg [3:0]data_in;
reg push,pop,clk;

//DUT
Four_deep_FIFO uut(
    .data_in(data_in),
    .push(push),
    .pop(pop),
    .clk(clk),
    .fifo_empty(fifo_empty),
    .fifo_full(fifo_full),
    .data_out(data_out)
);


//clk initialization
initial begin
    clk = 0;
    forever #5 clk=~clk;//time period = 10s
end


//Tests
initial begin 

    //out settling
    repeat(6) begin
        #10 data_in = 0;
        #10 push = 1;
//        push = 0;
    end
//=================PUSH==================//
    //test 1
    #10;
    data_in = 3;
    push = 1;
    #10 push = 0;  
    //test 2
    #10;
    data_in = 9;
    push = 1;
    #10 push = 0;  
    //test 3;
    #10;
    data_in = 8;
    push = 1;
    #10 push = 0;  
    //test 4;
    #10;
    data_in = 6;
    push = 1;
    #10 push = 0;  
    //test 5;
    #10;
    data_in = 1;
    push = 1;
    #10 push = 0;  
    
//===============POP==================//
    //test 1
    #10;
    pop = 1;
    #10 pop = 0;
    //test 2
    #10;
    pop = 1;
    #10 pop = 0;
    
//==============POP & PUSH============//
    //test 1
    #10;        
    data_in = 6;
    push = 1;
    #10 push = 0;   
    //test 2  
    #10;        
    data_in = 1;
    push = 1; 
    #10 push = 0;  
    //test 3 
    #10;    
    pop = 1;   
    #10 pop = 0;
    //test 4;   
    #10;        
    data_in = 8;
    push = 1;
    #10 push = 0;     
    //test 3 
    #10;     
    pop = 1; 
    #10 pop = 0;
    //test 3 
    #10;     
    pop = 1; 
    #10 pop = 0;
    //test 3 
    #10;     
    pop = 1; 
    #10 pop = 0;
    
    $finish;
end

initial begin
$monitor("time: %0t, data_in: %d, push: %b, pop: %b, data_out: %d, fifo_empty: %b, fifo_full: %b",$time,data_in,push,pop,data_out,fifo_empty,fifo_full);
end
endmodule
