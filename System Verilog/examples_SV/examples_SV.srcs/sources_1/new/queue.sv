`timescale 1ns / 1ps

module queue;
    int q1[$],q2[$];
    initial begin
        q1 = '{1,2,3,4,5};
        $display("q1 : %p", q1); //q1 : '{1, 2, 3, 4, 5}
        
        //FIFO 
        q1.push_front(0);
        $display("q1 : %p", q1);//'{0, 1, 2, 3, 4, 5}
        q1.pop_back();
        $display("q1 : %p", q1);//'{0, 1, 2, 3, 4}
        
        //LIFO
        q1.push_back(10);
        $display("q1 : %p", q1);//q1 : '{0, 1, 2, 3, 4, 10}
        q1.pop_front();
        $display("q1 : %p", q1);//q1 : '{1, 2, 3, 4, 10}
        
        //Insert at any index 
        q1.insert(1,11);
        $display("q1[1] : %0d", q1[1]);//q1[1] : 11
        
        //size of queue
        $display("size of q1 : %0d", q1.size()); //size of q1 : 6
        
        //delete
        q1.delete(1);
        $display("q1 (after deleting by index value) : %p", q1); //q1 (after deleting by index value) : '{1, 2, 3, 4, 10}
        q1.delete();
        $display("q1 (complete deletion) : %p", q1);//q1 (complete deletion) : '{}
        
        
        
        
    end        
    
endmodule
