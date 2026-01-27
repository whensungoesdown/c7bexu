module pic (
   input              clk,
   input              resetn,
   
   input              ext_intr_sync,
   input              csr_timer_intr_sync,
   input              vld_d,
   input              ertn_w,

   output             pic_csr_ext_intr,
   output             intr_sync,
   output             intr_sync_pulse
);

   wire all_intr_sync = ext_intr_sync | csr_timer_intr_sync;

   wire intr_inprog_in;
   wire intr_inprog_q;

   wire intr_inprog_bgn = (all_intr_sync & vld_d) & ~intr_inprog_q;
   wire intr_inprog_end = ertn_w;

   // intr_inprog_bgn   : _-______
   // intr_inprog_end   : ______-_
   // intr_inprog_in    : _-----__
   // intr_inprog_q     : __-----_
   //


   assign intr_inprog_in = (~intr_inprog_end) & (intr_inprog_bgn | intr_inprog_q);

   dffrl_ns #(1) exc_vld_e_reg (
      .din (intr_inprog_in),
      .clk (clk),
      .rst_l (resetn),
      .q   (intr_inprog_q));

  assign intr_sync = intr_inprog_bgn | intr_inprog_q;
  assign intr_sync_pulse = intr_inprog_in & ~intr_inprog_q;
  assign pic_csr_ext_intr = ext_intr_sync & intr_sync;

endmodule
