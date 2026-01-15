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
   //input              bru_branch_e,
   //input              exc_vld_e,
   //input              ertn_vld_e
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


//   wire bru_stall;
//   wire bru_stall_in = bru_branch_e;
//   wire bru_stall_q;
//
//   dffrl_ns #(1) bru_stall_reg (
//      .din   (bru_stall_in),
//      .clk   (clk),
//      .rst_l (resetn),
//      .q     (bru_stall_q));
//
//   assign bru_stall = bru_branch_e | bru_stall_q;
//
//
//   wire exc_stall;
//   wire exc_stall_in = exc_vld_e;
//   wire exc_stall_q;
//
//   dffrl_ns #(1) exc_stall_reg (
//      .din   (exc_stall_in),
//      .clk   (clk),
//      .rst_l (resetn),
//      .q     (exc_stall_q));
//
//   assign exc_stall = exc_vld_e | exc_stall_q;
//
//
//   wire ertn_stall;
//   wire ertn_stall_in = ertn_vld_e;
//   wire ertn_stall_q;
//
//   dffrl_ns #(1) ertn_stall_reg (
//      .din   (ertn_stall_in),
//      .clk   (clk),
//      .rst_l (resetn),
//      .q     (ertn_stall_q));
//
//   assign ertn_stall = ertn_vld_e | ertn_stall_q;

   //assign stall = lsu_stall | csr_stall | bru_stall | exc_stall | ertn_stall;

   assign stall_ifu = lsu_stall_ifu | csr_stall_ifu;
   assign stall_reg_mw = lsu_stall_reg_mw | csr_stall_reg_mw;

endmodule
