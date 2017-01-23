module platform(clk, rst);
   output logic clk;
   output logic rst;

initial begin
   clk      = 0;
   #30 clk  = 1;
   forever
     #5 clk  = !clk;
end

initial begin
   rst    = 1;
   #50 rst    = 0;
end
endmodule

module ram (WrAddress, RdAddress, Data, WE, RdClock, RdClockEn, Reset,
            WrClock, WrClockEn, Q)/* synthesis NGD_DRC_MASK=1 */;
   input wire [7:0] WrAddress;
   input wire [7:0] RdAddress;
   input wire [7:0] Data;
   input wire       WE;
   input wire       RdClock;
   input wire       RdClockEn;
   input wire       Reset;
   input wire       WrClock;
   input wire       WrClockEn;
   output wire [7:0] Q;

   bit [7:0]         ram [0:255] = '{default: 8'h00};

always_ff @(posedge WrClock)
  if (WrClockEn && WE)
    ram[WrAddress]  = Data;

assign Q = ram[RdAddress];

endmodule

module top_tb;

   logic rx;
   logic ws2812_out;

initial
  #100000 $finish;

task uart_send(logic [7:0] val);
   automatic logic [9:0] word  = {1'b1, val[7:0], 1'b0};
   for (int i = 0; i < 10; i = i + 1) begin
      rx = word[i];
      #(16*13*10);
   end;
endtask

initial begin
   rx       = 1;
   #1040 rx  = 0;
   #500 rx  = 1;
   #2000 uart_send(8'h41);
   uart_send(8'h20);
   uart_send(8'hc0);
end

top uut(.*);
defparam uut.nled = 1;

endmodule
