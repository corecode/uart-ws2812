module receive_tb;

   logic clk;
   logic reset;
   logic [7:0] data, data_out;
   logic       data_ready;
   logic [7:0] addr, length;
   logic       ready, write_strobe;

initial
  #1000 $finish;

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

task send(logic [7:0] val);
   data  = val;
   data_ready = 1;
   @(posedge clk);
   data_ready  = 0;
   @(posedge clk);
endtask

initial begin
   send('h55);
   send('hdd);
   send('hdb);
   send('hdd);
   send('hdd);
   send('hc0);
end

receive uut(.*);

endmodule
