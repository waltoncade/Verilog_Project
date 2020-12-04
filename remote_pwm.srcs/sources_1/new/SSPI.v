module SSPI #(parameter frame = 8)
            (input MOSI, SCK, RST, SSEL, 
             output reg [frame-1:0] DATA,
             output reg [3:0] COUNT,
             output reg [frame-1:0] RETURN,
             output MISO);
    
    assign MISO = (SSEL) ? (RETURN & 1'b1) : 1'bz;  //tri-state buffer, prevents multiple slave modules from communicating on MISO at the same time
    
    always @(posedge SCK) begin           //COUNTING PROCESS
        if(RST || ~SSEL || COUNT == 4'b1000)        //Resets count back to 0 to create a counting loop
            COUNT <= 4'b0000;
        else if(SSEL) COUNT <= COUNT + 1;           //Only when the slave select pin is high does the counter increment
     end
    
    always @(posedge SCK) begin           //SENDING PROCESS
        if(RST) begin                               //Resets the shift register to 0 if reset is high
            RETURN <= 8'b00000000;
        end
        if(COUNT == 4'b0000 && SSEL) begin          //When Count = 0, populate new data into the return register from the MOSI serial data
            RETURN <= DATA;
        end
        else if(~RST && SSEL) begin
           RETURN <= RETURN >> 1;                   //Shifting register. Allows the slave module to iteratively set the MISO line to the LSB serially
        end
     end
     
    always @(posedge SCK) begin           //RECEIVING PROCESS
        if(RST) begin                               //Resets the data register to 0 if reset is high, this allows fresh data to be intialized
            DATA <= 8'b00000000;
        end
        else if(SSEL) begin                         //Populates data from SPI master (MOSI) into an LSB shift register serially
            DATA <= {MOSI, DATA[7:1]};
        end
     end         
        
endmodule