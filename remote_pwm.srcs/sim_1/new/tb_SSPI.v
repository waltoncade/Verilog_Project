`timescale 1ns / 1ns
module tb_SSPI;

parameter frame = 8;
reg clock, select, reset, MOSI;
wire [frame-1:0] data, OUT;
wire [2:0] counter;
wire MISO;

SSPI #(.frame(frame))
SLAVE (.MOSI(MOSI), .SCK(clock), .RST(reset),
       .SSEL(select), .DATA(data), .COUNT(counter), 
       .RETURN(OUT), .MISO(MISO));

always begin                        //Repeat clock
   #10 clock <= ~clock;
end

initial begin
    clock <= 1'b0;
    reset <= 1'b1;
    select <= 1'b0;
    MOSI <= 1'b0;                   //Simulated data coming from master
    @(posedge clock);
    reset <= 1'b0;
    select <= 1'b1;                 //Simulated slave select pin set high from master
    MOSI <= 1'b1;
    repeat (3) @(posedge clock);
    MOSI <= 1'b0;
    repeat (2) @(posedge clock);
    MOSI <= 1'b1;
    repeat (2) @(posedge clock);
    MOSI <= 1'b0;
    repeat (10) @(posedge clock);   //Show one full transmission period
    $finish;
end
endmodule
