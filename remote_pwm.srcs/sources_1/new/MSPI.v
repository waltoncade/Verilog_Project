module MSPI #(parameter frame = 8)
            (input MISO, SCK, RST,
             input [frame-1:0] DATA,
             input [1:0] SSEL,
             output reg FAULT,
             output reg [2:0] COUNT,
             output reg [frame-1:0] RETURN, DATA_SHIFT,
             output MOSI, SLAVE1, SLAVE2, VTRANS);

    assign MOSI = DATA_SHIFT & 1'b1;
    assign SLAVE1 = ((SSEL >> 0) & 1'b1) && !VTRANS;
    assign SLAVE2 = ((SSEL >> 1) & 1'b1) && !VTRANS;
    assign VTRANS = (DATA == RETURN) ? 1'b1 : 1'b0;
    
    always @(posedge SCK) begin           //COUNTING PROCESS
        if(COUNT == 3'b111) COUNT <= 3'b000;
        if(RST) COUNT <= 3'b000;
        if((SLAVE1 || SLAVE2) && ~RST && !VTRANS) begin
            COUNT <= COUNT + 1;
        end
     end
    
    always @(negedge SCK) begin           //SENDING PROCESS
        if(RST) begin
            FAULT <= 1'b0;
            DATA_SHIFT <= DATA;
        end
        if(COUNT == 3'b000) begin
            DATA_SHIFT <= DATA;
        end
        else if((SLAVE1 || SLAVE2) && ~RST && !VTRANS) begin
           DATA_SHIFT <= DATA_SHIFT >> 1;
        end
     end
     
    always @(negedge SCK) begin           //RECEIVING PROCESS
        if(RST) begin
            RETURN <= (8'b00000000 | MISO);
        end
        else if((SLAVE1 || SLAVE2) && ~RST && !VTRANS) begin
            if(MISO)
                RETURN <= RETURN | (1'b1 << COUNT);
        end
     end

endmodule