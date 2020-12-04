module MSPI #(parameter frame = 8)
            (input MISO, SCK, RST,
             input [frame-1:0] DATA,
             input [1:0] SSEL,
             output reg [3:0] COUNT,
             output reg [frame-1:0] RETURN, DATA_SHIFT,
             output MOSI, SLAVE1, SLAVE2, VTRANS);

    assign MOSI = DATA_SHIFT & 1'b1;                    //Assigns MOSI line to the LSB of the Data_Shift Register
    assign SLAVE1 = ((SSEL >> 0) & 1'b1) && !VTRANS;    //Assigns first SSEL line (Slave1) to the LSB of the select vector
    assign SLAVE2 = ((SSEL >> 1) & 1'b1) && !VTRANS;    //Assigns second SSEL line (Slave2) to the Second bit of the select vector
    assign VTRANS = (DATA == RETURN) ? 1'b1 : 1'b0;     //VTRANS validates a good return from slave module only when DATA sent == data RETURN
    
    always @(posedge SCK) begin           //COUNTING PROCESS
        if(RST || VTRANS || COUNT == 4'b1000)           //Resets count back to 0 to create a counting loop
            COUNT <= 4'b0000;
        else if(SLAVE1 || SLAVE2) begin                 //Only when one of the slaves are selected does the counter increment
            COUNT <= COUNT + 1;
        end
     end
    
    always @(posedge SCK) begin           //SENDING PROCESS
        if(RST) begin                                   //Resets the shift register to 0 if reset is high
            DATA_SHIFT <= 8'b00000000;
        end
        if(COUNT == 4'b0000) begin                      //When Count = 0, populate new data into the shift register from the user
            DATA_SHIFT <= DATA;
        end
        else if((SLAVE1 || SLAVE2) && ~RST && !VTRANS) begin
           DATA_SHIFT <= DATA_SHIFT >> 1;               //Shifting register. Allows the module to iteratively set the MOSI line to the LSB serially
        end
     end
     
    always @(posedge SCK) begin           //RECEIVING PROCESS
        if(RST) begin                                   //Resets the return register to 0 if reset is high
            RETURN <= 8'b00000000;
        end
        else if((SLAVE1 || SLAVE2) && !VTRANS) begin    //Populates return from SPI slave (MISO) into an LSB shift register serially
            RETURN <= {MISO, RETURN[7:1]};
        end
     end

endmodule