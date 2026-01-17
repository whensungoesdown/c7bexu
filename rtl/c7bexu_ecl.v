module c7bexu_ecl (
   input              clk,
   input              resetn,

   output             stall_ifu,
   output             stall_reg_mw,

   input              lsu_vld_e,
   input              lsu_except_ale_ls1,
   input              lsu_except_buserr_ls3, // NOT IMPLEMENTED
   input              lsu_except_ecc_ls3, // NOT IMPLEMENTED
   input              lsu_data_valid_ls3,
   input              lsu_wr_fin_ls3,

   input              csr_vld_e
);

   wire lsu_stall_ifu;
   wire lsu_stall_reg_mw;
   wire lsu_stall_in;
   wire lsu_stall_q;

   wire lsu_bgn = lsu_vld_e;
   wire lsu_end = lsu_except_ale_ls1 | lsu_data_valid_ls3 | lsu_wr_fin_ls3;

   // lsu_bgn        : _-______
   // lsu_end        : ______-_
   //
   // lsu_stall_in   : _-----__
   // lsu_stall_q    : __-----_
   // lsu_stall_ifu  : _------_
   // lsu_stall_reg_mw   : __-----_

   //assign lsu_stall_in = (lsu_stall_q & ~lsu_end) | lsu_bgn;
   
   assign lsu_stall_in = (~lsu_end) & (lsu_bgn | lsu_stall_q);

   dffrl_ns #(1) lsu_stall_reg (
      .din   (lsu_stall_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (lsu_stall_q));

   //assign lsu_stall_ifu = lsu_bgn | lsu_stall_q; 
   assign lsu_stall_ifu = lsu_stall_in; 
   //assign lsu_stall = lsu_stall_in; 
   assign lsu_stall_reg_mw = lsu_stall_q & ~lsu_end; 


   // Enforced Two-Cycle Stall

   // This logic enforces a mandatory two-cycle pipeline stall. The stall is
   // not required by the CSR operations themselves but is a workaround for
   // the current lack of CSR register bypass logic. Since CSR instructions
   // are infrequent, this fixed stall penalty is acceptable.
   wire csr_stall_ifu;
   wire csr_stall_reg_mw;
   wire csr_stall_in = csr_vld_e;
   wire csr_stall_q;

   dffrl_ns #(1) csr_stall_reg (
      .din   (csr_stall_in),
      .clk   (clk),
      .rst_l (resetn),
      .q     (csr_stall_q));

   assign csr_stall_ifu = csr_vld_e | csr_stall_q;
   assign csr_stall_reg_mw = csr_stall_q;


   // CSR instructions stall IFU for 2 cycles only,
   // but complete execution within the main pipeline.
   assign stall_ifu = lsu_stall_ifu | csr_stall_ifu;
   //assign stall_reg_mw = lsu_stall_reg_mw | csr_stall_reg_mw;
   assign stall_reg_mw = lsu_stall_reg_mw;

endmodule
