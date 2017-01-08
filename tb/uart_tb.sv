module uart_tb;

   logic clk;
   logic reset;
   logic rx;
   logic [7:0] data;
   logic data_ready;

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


task uart_send(logic [7:0] val);
   automatic logic [9:0] word  = {1'b1, val[7:0], 1'b0};
   for (int i = 0; i < 10; i = i + 1) begin
      rx = word[i];
      #645 @(posedge clk);
   end;
endtask

initial begin
   rx       = 1;
   #104 rx  = 0;
   #200 rx  = 1;
   #200 uart_send(8'h41);
end

uart uut(.*);

endmodule
