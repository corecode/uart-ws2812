module send
  (
   clk,
   reset,
   length,
   trigger,
   next,
   addr,
   done
   );

   parameter int addr_size = 8;

   input logic   clk;
   input logic   reset;
   input logic [addr_size-1:0] length;
   input logic                 trigger;
   input logic                 next;
   output logic [addr_size-1:0] addr;
   output logic                 done;

   enum {IDLE, SENDING} state;

assign done = state == IDLE;

always_ff @(posedge clk)
  if (reset) begin
     addr <= 0;
     state <= IDLE;
  end
  else begin
     case (state)
       IDLE:
         if (trigger) begin
            state <= SENDING;
            addr  <= 0;
         end
       SENDING:
         if (next) begin
            if (addr == length)
              state <= IDLE;
            else
              addr <= addr + 1;
         end
     endcase
  end

endmodule
