`timescale 1ns / 1ns
module tb_MSPI;

parameter frame = 8;
reg clock, reset, MISO;
reg [1:0] select;
reg [frame-1:0] data;
wire [2:0] counter;
wire [frame-1:0] feedback, shift;
wire verified, MOSI, SLAVE1, SLAVE2, fault;

//Master SPI Module
MSPI #(.frame(frame))
Master (.MOSI(MOSI), .SCK(clock), .RST(reset), 
        .DATA(data), .SSEL(select), .COUNT(counter),
        .VTRANS(verified),
        .RETURN(feedback), .DATA_SHIFT(shift),
        .MISO(MISO), .SLAVE1(SLAVE1), .SLAVE2(SLAVE2));

always begin                        //Repeat clock
   #10 clock <= ~clock;
end

initial begin
    clock <= 1'b0;
    select <= 2'b00;
    data <= 131;                    //PWM Data to be sent to Slave
    reset <= 1'b1;
    MISO <= 1'b1;                   //MISO = Simulated data coming back from slave
    @(posedge clock);
    select <= 2'b01;                //Talk to simulated slave #1
    reset <= 1'b0;
    MISO <= 1'b1;
    repeat (2) @(posedge clock);
    MISO <= 1'b0;
    repeat (5) @(posedge clock);
    MISO <= 1'b1;
    repeat (3) @(posedge clock);
    MISO <= 1'b0;
    data <= 127;                    //New PWM Data to be sent to slave
    MISO <= 1'b0;
    repeat (2) @(posedge clock);
    MISO <= 1'b1;
    repeat (5) @(posedge clock);
    MISO <= 1'b1;
    repeat (3) @(posedge clock);
    MISO <= 1'b0;
    repeat (3) @(posedge clock);
    $finish;
end
endmodule
