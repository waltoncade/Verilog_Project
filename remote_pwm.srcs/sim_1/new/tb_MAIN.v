`timescale 1ns / 1ns
module tb_MAIN;

//wires going between modules
reg clock, reset;
wire MOSI, MISO, SLAVE1, SLAVE2;

//observation and control variables
parameter frame = 8;
reg [1:0] select;
reg [frame-1:0] data;
wire [3:0] s1counter, s2counter, mcounter;
wire [frame-1:0] s1return, s2return, mreturn, shift,
                 p1return, p2return, s1data, s2data,
                 p1counter, p2counter;
wire verified, pwm1, pwm2;

//Master SPI Module
MSPI #(.frame(frame))
Master (.MOSI(MOSI), .SCK(clock), .RST(reset), 
        .DATA(data), .SSEL(select), .COUNT(mcounter),
        .VTRANS(verified),
        .RETURN(mreturn), .DATA_SHIFT(shift),
        .MISO(MISO), .SLAVE1(SLAVE1), .SLAVE2(SLAVE2));

//Slave #1 SPI Module
SSPI #(.frame(frame))
S1 (.MOSI(MOSI), .SCK(clock), .RST(reset),
    .SSEL(SLAVE1), .DATA(s1data), .COUNT(s1counter), 
    .RETURN(s1return), .MISO(MISO));

//PWM #1 Module connected to Slave #1
PWM #(.res(frame)) 
GEN1 (.SCK(clock), .RST(reset), .VER(verified),
     .DATA(s1data), .signal(pwm1),
     .COUNT(p1counter), .DC(p1return));

//Slave #2 SPI Module
SSPI #(.frame(frame))
S2 (.MOSI(MOSI), .SCK(clock), .RST(reset),
    .SSEL(SLAVE2), .DATA(s2data), .COUNT(s2counter), 
    .RETURN(s2return), .MISO(MISO));
    
//PWM #2 Module connected to Slave #2
PWM #(.res(frame)) 
GEN2 (.SCK(clock), .RST(reset), .VER(verified),
     .DATA(s2data), .signal(pwm2),
     .COUNT(p2counter), .DC(p2return));

always begin                        //Repeat clock
   #10 clock <= ~clock;
end

initial begin
    clock <= 1'b0;
    reset <= 1'b1;
    select <= 2'b00;
    @(posedge clock);
    data <= 56;                     //PWM Data to be sent to Slave
    reset <= 1'b0;
    select <= 2'b01;                //Communicating with slave #1
    repeat (24) @(posedge clock);   //Need at least two full data frames, 18 clock cycles, to propogate from master to slave and back
    data <= 30;                     //PWM Data to be sent to Slave
    select <= 2'b10;                //Communicating with slave #2
    repeat (50) @(posedge clock);
    $finish;
end

endmodule
