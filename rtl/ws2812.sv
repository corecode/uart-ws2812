module ws2812
  (
   clk,
   reset,
   data,
   latch,
   next,
   bit_dout
   );

   parameter int divider = 3;

   input logic   clk;
   input logic   reset;
   input logic [7:0] data;
   input logic       latch;
   output logic      next;
   output logic      bit_dout;

   logic [7:0]       shiftreg;
   logic             next_bit;
   logic [2:0]       bitpos;
   logic [$clog2(divider)-1:0] clk_div, clk_div_n;
   logic                       clk_en;

   logic [4:0]                 bitcycle;
   logic                       next_byte_strobe;
   logic                       next_bit_strobe;
   logic                       signaled_latch;

   enum { IDLE, LOADING, TRANSMITTING, LATCHING } state;

assign clk_en = clk_div == 0;

always_comb begin
   clk_div_n    = clk_div + 1;
   if (clk_div == divider)
     clk_div_n  = 0;
end

always_ff @(posedge clk)
  if (reset)
    clk_div <= 0;
  else
    clk_div <= clk_div_n;


always_ff @(posedge clk) begin
   if (state == TRANSMITTING) begin
      if (bitcycle == 1 || bitcycle == 0)
        bit_dout <= 1;
      else
        bit_dout <= 0;
   end
   if (state == LATCHING)
     bit_dout <= 0;
end

assign next_bit = shiftreg[7];

always_ff @(posedge clk)
  if (reset)
    bitcycle <= 0;
  else
    if (clk_en) begin
       if (state == TRANSMITTING || state == LOADING) begin
          if (bitcycle == 3 || state == LOADING) begin
             if (next_bit)
               bitcycle <= 0;
             else
               bitcycle <= 1;
          end else
            bitcycle <= bitcycle + 1;
       end
       else if (state == LATCHING)
         bitcycle <= bitcycle + 1;
    end


assign next_bit_strobe = bitcycle == 2;
assign next_byte_strobe = next_bit_strobe && bitpos == 0;

always_ff @(posedge clk)
  if (reset) begin
     state        <= IDLE;
     signaled_latch <= 1;
     bitpos       <= 7;
     signaled_latch <= 0;
	 next <= 0;
  end
  else begin
     next <= 0;
     if (clk_en) begin
        if (state == IDLE || state == TRANSMITTING && next_byte_strobe) begin
           shiftreg <= data;
           bitpos   <= 7;

           if (latch) begin
              if (!signaled_latch) begin
                 state <= LATCHING;
                 next <= 1;
              end
           end else begin
              signaled_latch <= 0;
              if (state == IDLE)
                state <= LOADING;
              next    <= 1;
           end
        end
        else if (state == TRANSMITTING) begin
           if (next_bit_strobe) begin
              bitpos   <= bitpos - 1;
              shiftreg <= {shiftreg[6:0], 1'b0};
           end
        end
        else if (state == LATCHING && bitcycle == 22) begin
           state          <= IDLE;
           signaled_latch <= 1;
        end
        else if (state == LOADING)
          state <= TRANSMITTING;
     end
  end


endmodule
