`timescale 1ns / 1ns
module tb_MAIN;

//wires going between modules
reg clock, reset;
wire MOSI, MISO, SLAVE1, SLAVE2;

//observation and control parameters
parameter frame = 8;
reg [1:0] select;
reg [frame-1:0] data;
wire [3:0] scounter, mcounter;
wire [frame-1:0] sreturn, mreturn, shift, sdata;
wire verified, fault;

MSPI #(.frame(frame))
Master (.MOSI(MOSI), .SCK(clock), .RST(reset), 
        .DATA(data), .SSEL(select), .COUNT(mcounter),
        .FAULT(fault), .VTRANS(verified),
        .RETURN(mreturn), .DATA_SHIFT(shift),
        .MISO(MISO), .SLAVE1(SLAVE1), .SLAVE2(SLAVE2));

SSPI #(.frame(frame))
S1 (.MOSI(MOSI), .SCK(clock), .RST(reset),
    .SSEL(SLAVE1), .DATA(sdata), .COUNT(scounter), 
    .RETURN(sreturn), .MISO(MISO));

always begin
   #10 clock <= ~clock;
end

initial begin
    clock <= 1'b0;
    reset <= 1'b1;
    select <= 2'b00;
    data <= 136;
    @(posedge clock);
    reset <= 1'b0;
    @(posedge clock);
    select <= 2'b01;
    repeat (20) @(posedge clock);
    $finish;
end

endmodule
