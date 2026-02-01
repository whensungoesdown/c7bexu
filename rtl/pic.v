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

   // ext intr
   //wire ext_intr_inprog_in;
   wire ext_intr_inprog_q;

   //wire ext_intr_inprog_bgn = (ext_intr_sync & vld_d) & ~ext_intr_inprog_q;
   wire ext_intr_inprog_end = ertn_w;

   // ext_intr_inprog_bgn   : _-______
   // ext_intr_inprog_end   : ______-_
   // ext_intr_inprog_in    : _-----__
   // ext_intr_inprog_q     : __-----_
   //


   //assign ext_intr_inprog_in = (~ext_intr_inprog_end) & (ext_intr_inprog_bgn | ext_intr_inprog_q);

   wire ext_intr_active = ext_intr_sync & vld_d;
   wire ext_intr_not_busy = ~ext_intr_inprog_q;
   
   assign ext_intr_inprog_bgn = ext_intr_active & ext_intr_not_busy;
   assign ext_intr_inprog_in = ~ext_intr_inprog_end &
                               (ext_intr_active & ext_intr_not_busy | ext_intr_inprog_q);

   dffrl_ns #(1) ext_intr_inprog_reg (
      .din (ext_intr_inprog_in),
      .clk (clk),
      .rst_l (resetn),
      .q   (ext_intr_inprog_q));

   wire pic_ext_intr_sync = ext_intr_inprog_bgn | ext_intr_inprog_q;
   wire pic_ext_intr_sync_pulse = ext_intr_inprog_in & ~ext_intr_inprog_q;


   // csr timer intr
   wire timer_intr_inprog_in;
   wire timer_intr_inprog_q;

   wire timer_intr_inprog_bgn = (csr_timer_intr_sync & vld_d) & ~timer_intr_inprog_q;
   wire timer_intr_inprog_end = ertn_w;

   // timer_intr_inprog_bgn   : _-______
   // timer_intr_inprog_end   : ______-_
   // timer_intr_inprog_in    : _-----__
   // timer_intr_inprog_q     : __-----_
   //


   assign timer_intr_inprog_in = (~timer_intr_inprog_end) & (timer_intr_inprog_bgn | timer_intr_inprog_q);

   dffrl_ns #(1) timer_intr_inprog_reg (
      .din (timer_intr_inprog_in),
      .clk (clk),
      .rst_l (resetn),
      .q   (timer_intr_inprog_q));

   wire pic_timer_intr_sync = timer_intr_inprog_bgn | timer_intr_inprog_q;
   wire pic_timer_intr_sync_pulse = timer_intr_inprog_in & ~timer_intr_inprog_q;


   assign intr_sync = pic_ext_intr_sync | pic_timer_intr_sync;
   assign intr_sync_pulse = pic_ext_intr_sync_pulse | pic_timer_intr_sync_pulse;

   //assign pic_csr_ext_intr = pic_ext_intr_sync;
   assign pic_csr_ext_intr = ext_intr_sync;

endmodule
