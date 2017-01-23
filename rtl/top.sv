module top
  (
   rx,
   ws2812_out
   );

   parameter int     nled  = 72;
   localparam int    nbyte  = nled*3;
   localparam int    addr_size = $clog2(nbyte);

   input logic rx;
   output logic ws2812_out;

   logic        clk;
   logic        reset;

   logic [7:0]  uart_data, receive_data, ws2812_data;
   logic [addr_size-1:0] receive_addr, send_addr;

   logic                 uart_data_ready;
   logic                 receive_write_strobe;
   logic                 receive_ready;

   logic                 ws2812_next, ws2812_latch;


platform
  platform(.clk(clk),
           .rst(reset));

uart #(.divider(12))
uart(.data(uart_data),
     .data_ready(uart_data_ready),
     .*);

receive #(.addr_size(addr_size))
receive(.data(uart_data),
        .data_ready(uart_data_ready),
        .data_out(receive_data),
        .addr(receive_addr),
        .write_strobe(receive_write_strobe),
        .length(),
        .ready(receive_ready),
        .*);

send #(.addr_size(addr_size))
send(.length(addr_size'(nbyte-1)),
     .trigger(receive_ready),
     .next(ws2812_next),
     .addr(send_addr),
     .done(ws2812_latch),
     .*);

ram
  ram(.WrAddress(receive_addr),
      .RdAddress(send_addr),
      .Data(receive_data),
      .WE(receive_write_strobe),
      .RdClock(clk),
      .RdClockEn(1'b1),
      .Reset(reset),
      .WrClock(clk),
      .WrClockEn(1'b1),
      .Q(ws2812_data));

ws2812 #(.divider(8))
ws2812(.data(ws2812_data),
       .latch(ws2812_latch),
       .next(ws2812_next),
       .bit_dout(ws2812_out),
       .*);

endmodule
