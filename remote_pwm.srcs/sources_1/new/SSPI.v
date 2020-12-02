module SSPI #(parameter frame = 8)
            (input MOSI, SCK, RST, SSEL, 
             output reg [frame-1:0] DATA,
             output reg [3:0] COUNT,
             output reg [frame-1:0] RETURN,
             output MISO);
             
    assign MISO = RETURN & 1'b1;
    reg [2:0] SSELr;
    always @(posedge SCK) SSELr <= {SSELr[1:0], SSEL};
    wire SSEL_risingedge = (SSELr[2:0] == 2'b01);
    
    always @(posedge SCK) begin           //COUNTING PROCESS
        if(RST || ~SSEL || COUNT == 4'b1000) 
            COUNT <= 4'b0000;
        else if(SSEL) COUNT <= COUNT + 1;
     end
    
    always @(posedge SCK) begin           //SENDING PROCESS
        if(RST) begin
            RETURN <= 8'b00000000;
        end
        if(COUNT == 4'b0000) begin
            RETURN <= DATA;
        end
        else if(SSEL && ~RST) begin
           RETURN <= RETURN >> 1;
        end
     end
     
    always @(posedge SCK) begin           //RECEIVING PROCESS
        if(RST) begin
            DATA <= 8'b00000000;
        end
        else if(SSEL) begin
            DATA <= {MOSI, DATA[7:1]};
        end
     end         
        
endmodule