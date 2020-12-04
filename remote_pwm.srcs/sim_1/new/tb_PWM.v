`timescale 1ns / 1ns
module tb_PWM;

parameter resolution = 8;
reg clock, reset, verify;
reg [resolution-1:0] data;
wire signal;
wire [resolution-1:0] counter, dc;

PWM #(.res(resolution)) 
GEN (.SCK(clock), .RST(reset), .VER(verify),
     .DATA(data), .signal(signal),
     .COUNT(counter), .DC(dc));

always begin                        //Repeat clock
   #1 clock <= ~clock;
end

initial begin
    reset <= 1'b1;
    verify <= 1'b0;
    clock <= 1'b0;
    data <= 25;                     //Simulated PWM modulation signal coming from slave module
    @(posedge clock);
    reset <= 1'b0;
    repeat (50) @(posedge clock);
    verify <= 1'b1;                 //Simulated verify line to validate input from master
    repeat (270) @(posedge clock);  //Display one full Duty Cycle period
    reset <= 1'b1;
    @(posedge clock);
    reset <= 1'b0;
    repeat (50) @(posedge clock);
    data <= 100;                    //Modulate signal to show runtime modulation capability
    verify <= 1'b1;
    repeat (300) @(posedge clock);
    $finish;
end
endmodule
