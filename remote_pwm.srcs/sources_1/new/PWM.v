module PWM #(parameter res = 8)
            (input SCK, RST,
             input [res-1:0] DC,
             output signal,
             output reg [res-1:0] COUNT);       
    reg [res-1:0] DC_Flag;
    assign signal = (COUNT < DC);
    always @(posedge SCK) begin
        if (RST) begin
            COUNT <= 0;
            DC_Flag <= DC;
        end
        else if (COUNT == 8'b11111111) begin
            COUNT <= 0;
        end
        else begin
            COUNT <= COUNT + 1'b1;
        end
        if (DC != DC_Flag) begin
            COUNT <= 0;
            DC_Flag <= DC;
        end     
    end
endmodule
