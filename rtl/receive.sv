module receive
  (
   clk,
   reset,
   data,
   data_ready,
   data_out,
   addr,
   write_strobe,
   length,
   ready
   );

   parameter int addr_size = 8;

   input logic   clk;
   input logic   reset;
   input logic [7:0] data;
   input logic       data_ready;
   output logic [7:0] data_out;
   output logic [addr_size-1:0] addr, length;
   output logic                 write_strobe, ready;

   enum {NORMAL, ESCAPE} state;

   const logic [7:0]            SLIP_ESC  = 8'hdb,
                                SLIP_END  = 8'hc0,
                                ESC_ESC   = 8'hdd,
                                ESC_END   = 8'hdc;

always_ff @(posedge clk)
  if (reset) begin
     state        <= NORMAL;
     write_strobe <= 0;
     ready        <= 0;
     addr         <= '{default: '1};
  end else begin
     write_strobe <= 0;
     ready        <= 0;
     if (data_ready) begin
        if (data == SLIP_ESC)
          state <= ESCAPE;
        else if (data == SLIP_END) begin
           ready <= 1;
           length <= addr;
           addr         <= '{default: '1};
        end else begin
           state        <= NORMAL;
           write_strobe <= 1;
           addr <= addr + 1;
           if (state == ESCAPE && data == ESC_ESC)
             data_out <= SLIP_ESC;
           else if (state == ESCAPE && data == ESC_END)
             data_out <= SLIP_END;
           else
             data_out <= data;
        end
     end
  end

endmodule