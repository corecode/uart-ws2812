module ws2812_tb;

   logic clk;
   logic reset;
   logic [7:0] data;
   logic       latch;
   logic       next;
   logic       bit_dout;

initial
  #10000 $finish;

initial begin
   clk      = 0;
   #30 clk  = 1;
   forever
     #5 clk  = !clk;
end

initial begin
   reset    = 1;
   #50 reset    = 0;
end

task send(logic [7:0] val, logic set_latch);
   data  = val;
   latch = set_latch;
   do begin
      @(posedge clk);
   end while (next == 0);
endtask


initial begin
   latch  = 1;
   #1133;

   for (int i = 0; i < 3; i++) begin
      send(i, 0);
   end
   send(0, 1);
   #50;
   send('h55, 0);
   send(0, 1);
end

ws2812 #(.divider(4)) uut(.*);

endmodule
