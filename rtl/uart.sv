module uart
(
 clk,
 reset,
 rx,
 data,
 data_ready
 );

   parameter int divider  = 3;
   parameter int oversample = 15;

   input logic clk;
   input logic reset;
   input logic rx;
   output logic data_ready;
   output logic [7:0] data;

   logic [7:0]        shiftreg;
   logic [4:0]        bitcount;

   logic [$clog2(divider)-1:0] clk_div;
   logic                       clk_en;
   logic [$clog2(oversample)-1:0] sample_div, sample_div_n;
   logic                        sample;

   enum { IDLE, ACTIVE } state, state_n;


always_ff @(posedge clk)
  if (reset) begin
     clk_div <= 0;
     clk_en <= 0;
  end else begin
     if (clk_div == divider) begin
        clk_div <= 0;
        clk_en  <= 1;
     end else begin
        clk_div <= clk_div + 1;
        clk_en  <= 0;
     end
  end

always_comb
  if (state == IDLE)
    sample_div_n = 0;
  else if (sample_div == oversample)
    sample_div_n  = 0;
  else
    sample_div_n  = sample_div + 1;

assign sample = clk_en && (sample_div == (oversample + 1) / 2 - 1);

always_ff @(posedge clk)
  if (reset)
     sample_div <= 0;
  else if (clk_en)
    sample_div <= sample_div_n;

always_ff @(posedge clk)
  if (reset) begin
     data_ready <= 0;
     data       <= 0;
     state      <= IDLE;
  end else
    case (state)
      IDLE: begin
         data_ready <= 0;
         if (clk_en && rx == 0) begin
            state    <= ACTIVE;
            bitcount <= 0;
         end
      end
      ACTIVE:
        if (sample) begin
           if (bitcount == 0 && rx != 0)
             state <= IDLE;
           if (bitcount != 9)
             bitcount  <= bitcount + 1;
           else begin
              state      <= IDLE;
              if (rx) begin
                 data       <= shiftreg[7:0];
                 data_ready <= 1;
              end
           end
        end
     endcase

always_ff @(posedge clk)
  if (sample)
    shiftreg     <= {rx, shiftreg[7:1]};

endmodule
