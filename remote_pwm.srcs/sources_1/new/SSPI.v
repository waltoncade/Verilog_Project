module SSPI #(parameter frame = 8)
            (input MOSI, SCK, RST, SSEL, 
             output reg [frame-1:0] DATA,
             output reg [2:0] COUNT,
             output reg [frame-1:0] RETURN,
             output MISO);
             
    assign MISO = RETURN & 1'b1;
    reg [2:0] SSELr;
    always @(posedge SCK) SSELr <= {SSELr[1:0], SSEL};
    wire SSEL_risingedge = (SSELr[2:1] == 2'b01);
    
    always @(posedge SCK) begin           //COUNTING PROCESS
        if(COUNT == 3'b111) COUNT <= 3'b000;
        if(RST) COUNT <= 3'b000;
        else if(SSEL) COUNT <= COUNT + 1;
     end
    
    always @(negedge SCK) begin           //SENDING PROCESS
        if(RST || (COUNT == 3'b000)) begin
            RETURN <= DATA;
        end
        else if(SSEL) begin
           RETURN <= RETURN >> 1;
        end
     end
     
    always @(negedge SCK) begin           //RECEIVING PROCESS
        if(RST || SSEL_risingedge) begin
            DATA <= (8'b00000000 | MOSI);
        end
        else if(SSEL && MOSI) begin
            DATA <= DATA | (1'b1 << COUNT);
        end
     end         
        
endmodule