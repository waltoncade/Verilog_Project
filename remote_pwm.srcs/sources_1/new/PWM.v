module PWM #(parameter res = 8)
            (input SCK, RST, VER,
             input [res-1:0] DATA,
             output signal,
             output reg [res-1:0] COUNT, DC);       
             
    assign signal = (COUNT < DC);               //If the current count (up to 255) is less than the set duty cycle, the signal value is low
    
    always @(posedge SCK) begin
        if (RST) begin                          //Reset duty cycle and count registers to 0
            COUNT <= 0;
            DC <= 0;
        end
        else if (COUNT == 8'b11111111) begin    //If count = 255 (maximum value), restart counter to allow for repetative duty cycle modulation
            COUNT <= 0;
        end
        else begin
            COUNT <= COUNT + 1'b1;              //Count incrementer
        end
        if (VER && (DC != DATA)) begin          //Only populate data coming from SPI Slave into Duty Cycle register if verified and the current duty cycle is not already what is being sent
            COUNT <= 0;
            DC <= DATA;
        end     
    end

endmodule
