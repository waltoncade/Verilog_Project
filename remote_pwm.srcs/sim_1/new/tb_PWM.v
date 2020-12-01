`timescale 1ns / 1ns
module tb_PWM;

parameter resolution = 8;
reg clock, reset;
reg [resolution-1:0] duty_cycle;
wire signal;
wire [resolution-1:0] counter;

PWM #(.res(resolution)) 
GEN (.SCK(clock), .RST(reset),
     .DC(duty_cycle), .signal(signal),
     .COUNT(counter));

always begin                //create repeat clock
   #1 clock <= ~clock;
end

initial begin
    reset <= 1'b1;
    clock <= 1'b0;            //initialize clock
    duty_cycle <= 25;         //set new duty cycle
    @(posedge clock);
    reset <= 1'b0;
    repeat (300) begin       //count 300
        @(posedge clock);
    end
    reset <= 1'b1;
    @(posedge clock);
    reset <= 1'b0;
    repeat (50) begin       //count 50
        @(posedge clock);
    end
    duty_cycle <= 100;       //set new duty cycle
    repeat (300) begin       //count 300
        @(posedge clock);
    end
    $finish;
end
endmodule
