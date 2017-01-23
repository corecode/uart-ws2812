module send_tb;

   logic clk;
   logic reset;
   logic [7:0] addr, length;
   logic       trigger, next, done;

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

initial begin
   length       = 10;
   trigger      = 0;
   #70 trigger  = 1;
   @(posedge clk);
   trigger  = 0;
   do begin
      next = 0;
      repeat (3) @(posedge clk);
      if (!done)
        next  = 1;
      @(posedge clk);
   end while (!done);
end

send uut(.*);

endmodule
