`timescale 1ns / 1ns
module tb_SSPI;

parameter frame = 8;
reg clock, select, reset, MOSI; //MOSI should be wire in main module, same with select
wire [frame-1:0] data, OUT;
wire [2:0] counter;
wire MISO, edger;

SSPI #(.frame(frame))
TSM (.MOSI(MOSI), .SCK(clock), .RST(reset),
     .SSEL(select), .DATA(data), .COUNT(counter), 
     .RETURN(OUT), .MISO(MISO));

always begin
   #10 clock <= ~clock;
end

initial begin
    clock <= 1'b0;
    reset <= 1'b1;
    select <= 1'b0;
    MOSI <= 0'b1;           //need to figure out way to keep MOSI or MISO to 0 when not being used
    @(posedge clock);
    reset <= 1'b0;
    select <= 1'b1;
    @(posedge clock);
    repeat (8) begin
        @(posedge clock);
    end
    reset <= 1'b1;
    @(posedge clock);
    reset <= 1'b0;
    repeat (4) begin
        @(posedge clock);
    end
    reset <= 1'b1;
    @(posedge clock);
    @(posedge clock);
    $display ("4'b0001 | 4'b0000 = %b", (4'b0001 | 4'b0000));
    $display ("4'b0001 << 1 = %b", (4'b0001 << 1));
    $finish;
end
endmodule
