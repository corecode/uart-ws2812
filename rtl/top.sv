module top
  (
   rx,
   leds,
   sample
   );

   input logic rx;
   output logic [7:0] leds;

   logic [7:0]     data;
   logic           data_ready;
   logic           clk;
   logic           reset;

platform platform(.clk(clk), .rst(reset));

uart #(.divider(12)) uart(.*);

assign leds = ~data;

   output logic    sample  = uart.sample;

endmodule
