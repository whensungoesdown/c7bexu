`include "defines.vh"

module c7bexu (
   input              clk,
   input              resetn,

   output             exu_ifu_except,
   output [31:0]      exu_ifu_isr_addr,
   output             exu_ifu_branch,
   output [31:0]      exu_ifu_brn_addr,
   output             exu_ifu_ertn,
   output [31:0]      exu_ifu_ert_addr,
   output             exu_ifu_stall,

   input              ifu_exu_vld_d,
   input  [31:0]      ifu_exu_pc_d,
   input  [4:0]       ifu_exu_rs1_d,
   input  [4:0]       ifu_exu_rs2_d,
   input  [4:0]       ifu_exu_rd_d,
   input              ifu_exu_wen_d,
   input  [31:0]      ifu_exu_imm_shifted_d,

   // alu
   input              ifu_exu_alu_vld_d,
   input  [5:0]       ifu_exu_alu_op_d, // ALU_CODE_BIT 6
   input              ifu_exu_alu_a_pc_d,
   input  [31:0]      ifu_exu_alu_c_d,
   input              ifu_exu_alu_double_word_d,
   input              ifu_exu_alu_b_imm_d,

   // lsu
   input              ifu_exu_lsu_vld_d,
   input  [6:0]       ifu_exu_lsu_op_d, // LSU_CODE_BIT 7
   input              ifu_exu_lsu_double_read_d,

   // bru
   input              ifu_exu_bru_vld_d,
   input  [3:0]       ifu_exu_bru_op_d, // BRU_CODE_BIT 4
   input  [31:0]      ifu_exu_bru_offset_d,

   // mul
   input              ifu_exu_mul_vld_d,
   input              ifu_exu_mul_signed_d,
   input              ifu_exu_mul_double_d,
   input              ifu_exu_mul_hi_d,
   input              ifu_exu_mul_short_d,

   // csr
   input              ifu_exu_csr_vld_d,
   input  [13:0]      ifu_exu_csr_raddr_d, // CSR_BIT 14
   input              ifu_exu_csr_xchg_d,
   input              ifu_exu_csr_wen_d,
   input  [13:0]      ifu_exu_csr_waddr_d, // CSR_BIT 14

   // ertn
   input              ifu_exu_ertn_vld_d,

   // exc
   input              ifu_exu_exc_vld_d,
   input  [5:0]       ifu_exu_exc_code_d,

   // memory interface  E M
   output             lsu_biu_rd_req,
   output [31:0]      lsu_biu_rd_addr,

   input              biu_lsu_rd_ack,
   input              biu_lsu_data_vld,
   input  [63:0]      biu_lsu_data,

   output             lsu_biu_wr_req,
   output [31:0]      lsu_biu_wr_addr,
   output [63:0]      lsu_biu_wr_data,
   output [7:0]       lsu_biu_wr_strb,

   input              biu_lsu_wr_ack,
   input              biu_lsu_wr_fin
);

   // exc
   wire exc_vld_e;
   wire exc_vld_m;
   wire exc_vld_w;
   //wire exc_vld_comb_w;

   wire [5:0] exc_code_e;
   wire [5:0] exc_code_m;
   wire [5:0] exc_code_w;
   //wire [5:0] exc_code_comb_w;


   //
   wire [31:0] dumb_rdata1_0;
   wire [31:0] dumb_rdata1_1;
   wire [31:0] dumb_rdata2_0;
   wire [31:0] dumb_rdata2_1;

   wire [31:0] rs1_data_d;
   wire [31:0] rs2_data_d;

   wire [31:0] pc_e;
   wire [31:0] pc_m;
   wire [31:0] pc_w;
   wire [4:0] rs1_e;
   wire [4:0] rs2_e;
   wire [31:0] rs1_data_e;
   wire [31:0] rs2_data_e;
   wire [4:0] rd_e;
   wire [4:0] rd_m;
   wire [4:0] rd_w;
   wire wen_e;
   wire wen_m;
   wire wen_w;
   wire [31:0] imm_shifted_e;

   wire [31:0] rs1_data_byp_e;
   wire [31:0] rs2_data_byp_e;

   wire [31:0] rd_data_m;
   wire [31:0] rd_data_w;

   c7bexu_rf u_rf (
      .clk                             (clk),
      .rst                             (~resetn),

      //.waddr1                          (ecl_irf_rd_w),// I, 5
      .waddr1                          (rd_w),// I, 5
      .raddr0_0                        (ifu_exu_rs1_d),// I, 5
      .raddr0_1                        (ifu_exu_rs2_d),// I, 5
      //.wen1                            (ecl_irf_wen_w),// I, 1
      .wen1                            (wen_w),// I, 1
      //.wdata1                          (ecl_irf_rd_data_w),// I, 32
      .wdata1                          (rd_data_w),// I, 32
      .rdata0_0                        (rs1_data_d),// O, 32
      .rdata0_1                        (rs2_data_d),// O, 32

      
      .waddr2                          (5'b0),// I, 5
      .raddr1_0                        (5'b0),// I, 32
      .raddr1_1                        (5'b0),// I, 32
      .wen2                            (1'b0),// I, 1
      .wdata2                          (32'b0),// I, 32
      .rdata1_0                        (dumb_rdata1_0),// O, 32
      .rdata1_1                        (dumb_rdata1_1),// O, 32

      .raddr2_0                        (5'b0),// I, 5
      .raddr2_1                        (5'b0),// I, 5
      .rdata2_0                        (dumb_rdata2_0),// O, 32
      .rdata2_1                        (dumb_rdata2_1) // O, 32
      );



   c7bexu_byp u_byp(
      .rs1_e                           (rs1_e),
      .rs2_e                           (rs2_e),
      .rd_m                            (rd_m),
      .rd_w                            (rd_w),
      .wen_m                           (wen_m),
      .wen_w                           (wen_w),
      .rs1_data_e                      (rs1_data_e),
      .rs2_data_e                      (rs2_data_e),
      .rd_data_m                       (rd_data_m),
      .rd_data_w                       (rd_data_w),
      .rs1_data_byp_e                  (rs1_data_byp_e),
      .rs2_data_byp_e                  (rs2_data_byp_e)
   );

   wire        alu_vld_e;
   wire        alu_vld_m;
   wire [31:0] alu_a_e;
   wire [31:0] alu_b_e;
   wire [5:0]  alu_op_e;
   wire        alu_a_pc_e;
   wire [31:0] alu_c_e;
   wire        alu_double_word_e;
   wire        alu_b_imm_e;

   wire [31:0] alu_res_e;
   wire [31:0] alu_res_m;


   assign alu_a_e = alu_a_pc_e ? pc_e : rs1_data_byp_e;
   assign alu_b_e = alu_b_imm_e? imm_shifted_e : rs2_data_byp_e;

   alu u_alu(
      .a                               (alu_a_e),
      .b                               (alu_b_e),
      .double_word                     (alu_double_word_e),
      .alu_op                          (alu_op_e),
      .c                               (alu_c_e),
      .Result                          (alu_res_e)
      );


   // lsu
   wire lsu_vld_e;
   //wire lsu_vld_m;
   wire [6:0] lsu_op_e;
   wire lsu_double_read_e;
   wire [31:0] lsu_base_e;
   wire [31:0] lsu_offset_e;
   wire [31:0] lsu_wdata_e;
   wire lsu_data_vld_ls3;
   wire [31:0] lsu_data_ls3;
   wire lsu_wr_fin_ls3;
   wire lsu_except_ale_ls1;
   wire lsu_except_ale_m;
   wire [31:0] lsu_except_badv_ls1;
   wire [31:0] lsu_except_badv_w;
   wire lsu_except_buserr_ls3;
   wire lsu_except_ecc_ls3;

   assign lsu_base_e = rs1_data_byp_e;
   assign lsu_offset_e = lsu_double_read_e ? rs2_data_byp_e: imm_shifted_e;
   assign lsu_wdata_e = rs2_data_byp_e;


   c7blsu u_lsu(
      .clk                             (clk),
      .resetn                          (resetn),

      .ecl_lsu_valid_e                 (lsu_vld_e),
      .ecl_lsu_op_e                    (lsu_op_e),
      .ecl_lsu_base_e                  (lsu_base_e),
      .ecl_lsu_offset_e                (lsu_offset_e),
      .ecl_lsu_wdata_e                 (lsu_wdata_e),
      .lsu_ecl_data_valid_ls3          (lsu_data_vld_ls3),
      .lsu_ecl_data_ls3                (lsu_data_ls3),
      .lsu_ecl_wr_fin_ls3              (lsu_wr_fin_ls3),      
      .lsu_ecl_except_ale_ls1          (lsu_except_ale_ls1),
      .lsu_ecl_except_badv_ls1         (lsu_except_badv_ls1),
      .lsu_ecl_except_buserr_ls3       (lsu_except_buserr_ls3),
      .lsu_ecl_except_ecc_ls3          (lsu_except_ecc_ls3),

      // BIU Interface
      .lsu_biu_rd_req_ls2              (lsu_biu_rd_req),
      .lsu_biu_rd_addr_ls2             (lsu_biu_rd_addr),
      .biu_lsu_rd_ack_ls2              (biu_lsu_rd_ack),
      .biu_lsu_data_valid_ls3          (biu_lsu_data_vld),
      .biu_lsu_data_ls3                (biu_lsu_data),

      .lsu_biu_wr_req_ls2              (lsu_biu_wr_req),
      .lsu_biu_wr_addr_ls2             (lsu_biu_wr_addr),
      .lsu_biu_wr_data_ls2             (lsu_biu_wr_data),
      .lsu_biu_wr_strb_ls2             (lsu_biu_wr_strb),
      .biu_lsu_wr_ack_ls2              (biu_lsu_wr_ack),
      .biu_lsu_wr_fin_ls3              (biu_lsu_wr_fin)
   );


   // bru
   wire bru_vld_e;
   wire bru_vld_m;
   wire [3:0] bru_op_e; // BRU_CODE_BIT 4
   wire [31:0] bru_offset_e;
   wire [31:0] bru_a_e;
   wire [31:0] bru_b_e;
   wire [31:0] bru_pc_e;
   wire [31:0] bru_brn_addr_e;
   wire [31:0] bru_brn_addr_m;
   wire [31:0] bru_brn_addr_w;
   wire bru_branch_e;
   wire bru_branch_m;
   wire bru_branch_w;
   wire [31:0] bru_link_pc_e;
   wire [31:0] bru_link_pc_m;

   assign bru_a_e = rs1_data_e;
   assign bru_b_e = rs2_data_e;
   assign bru_pc_e = pc_e;

   branch u_bru(
      .branch_valid                    (bru_vld_e),
      .branch_op                       (bru_op_e),
      .branch_a                        (bru_a_e),
      .branch_b                        (bru_b_e),
      .branch_pc                       (bru_pc_e),
      .branch_offset                   (bru_offset_e),

      .bru_target                      (bru_brn_addr_e),
      .bru_taken                       (bru_branch_e),
      .bru_link_pc                     (bru_link_pc_e)
   );


   // mul
   wire mul_vld_e;
   wire mul_vld_m;
   wire [31:0] mul_a_e;
   wire [31:0] mul_b_e;
   wire [31:0] mul_res_m;
   wire [63:0] mul_a_64_e;
   wire [63:0] mul_b_64_e;
   wire [63:0] mul_res_64_m;
   wire mul_signed_e;
   wire mul_double_e;
   wire mul_hi_e;
   wire mul_short_e;

   assign mul_a_e = rs1_data_e;
   assign mul_b_e = rs2_data_e;
   assign mul_a_64_e = {32'b0, mul_a_e};
   assign mul_b_64_e = {32'b0, mul_b_e};
   assign mul_res_m = mul_res_m[31:0];

   mul64x64 u_mul(
      .clk                             (clk),
      .rstn                            (resetn),

      .mul_validin                     (mul_vld_e),
      .ex2_allowin                     (1'b1),
      .mul_validout                    (),
      .ex1_readygo                     (1'b1),
      .ex2_readygo                     (1'b1),

      .opa                             (mul_a_64_e),
      .opb                             (mul_b_64_e),
      .mul_signed                      (mul_signed_e),
      .mul64                           (mul_double_e),
      .mul_hi                          (mul_hi_e),
      .mul_short                       (mul_short_e),

      .mul_res_out                     (mul_res_64_m),
      .mul_ready                       ()
   );

   // csr
   wire csr_vld_e;
   wire csr_vld_m;
   wire [13:0] csr_raddr_d;
   wire csr_xchg_e;
   wire csr_wen_e;
   wire csr_wen_m;
   wire [13:0] csr_waddr_e;
   wire [13:0] csr_waddr_m;
   wire [31:0] csr_rdata_d;
   wire [31:0] csr_rdata_e;
   wire [31:0] csr_rdata_m;
   wire [31:0] csr_wdata_e;
   wire [31:0] csr_wdata_m;
   wire [31:0] csr_mask_e;
   wire [31:0] csr_mask_m;
   wire [31:0] csr_isr_addr;
   wire [31:0] csr_ert_addr;
   wire csr_crmd_ie;
   wire csr_timer_intr;

   assign csr_raddr_d = ifu_exu_csr_raddr_d;
   assign csr_xchg_d = ifu_exu_csr_xchg_d;
   assign csr_waddr_d = ifu_exu_csr_waddr_d;
   assign csr_wdata_e = rs2_data_byp_e;
   assign csr_mask_e = csr_xchg_e ? rs1_data_byp_e : 32'hFFFFFFFF;

   wire ertn_vld_e;
   wire ertn_vld_m;
   wire ertn_vld_w;


   c7bcsr u_csr(
      .clk                             (clk),
      .resetn                          (resetn),
      .csr_rdata                       (csr_rdata_d),
      .csr_raddr                       (csr_raddr_d),
      .csr_waddr                       (csr_waddr_m),
      .csr_wdata                       (csr_wdata_m),
      .csr_mask                        (csr_mask_m),
      .csr_wen                         (csr_wen_m),

      .csr_eentry                      (csr_isr_addr),
      .csr_era                         (csr_ert_addr),

      //.ecl_csr_badv_e                  (lsu_except_badv_w), 
      .ecl_csr_badv_w                  (lsu_except_badv_w), 
      //.exu_ifu_except                  (exc_vld_comb_w),
      .exu_ifu_except                  (exc_vld_w),
      //.ecl_csr_exccode_e               (exc_code_w),
      //.ecl_csr_exccode_w               (exc_code_comb_w),
      .ecl_csr_exccode_w               (exc_code_w),
      //.ifu_Exu_pc_e                    (pc_w),
      .ifu_exu_pc_w                    (pc_w),
      //.ecl_csr_ertn_e                  (ertn_vld_w),
      .ecl_csr_ertn_w                  (ertn_vld_w),

      .csr_ecl_crmd_ie                 (csr_crmd_ie),
      .csr_ecl_timer_intr              (csr_timer_intr),

      .ext_intr                        () // todo
   );


   assign rd_data_m = ({32{alu_vld_m}}        & alu_res_m) |
                      ({32{lsu_data_vld_ls3}} & lsu_data_ls3) |
                      ({32{bru_vld_m}}        & bru_link_pc_m) |
                      ({32{mul_vld_m}}        & mul_res_m) |
                      ({32{csr_vld_m}}        & csr_rdata_m);

   // This circuit implementation is prioritized.
   //assign rd_data_m = alu_vld_m                     ? alu_res_m :
   //                  (lsu_vld_m & lsu_data_vld_ls3) ? lsu_rdata_m :
   //                   bru_vld_m                     ? bru_link_pc_m :
   //                   mul_vld_m                     ? mul_res_m :
   //                   csr_vld_m                     ? csr_rdata_m :
   //                                                 '0;

   assign exu_ifu_branch = bru_branch_w;
   assign exu_ifu_brn_addr = bru_brn_addr_w;

   //assign exu_ifu_except = exc_vld_comb_w;
   assign exu_ifu_except = exc_vld_w;
   assign exu_ifu_isr_addr = csr_isr_addr;

   assign exu_ifu_ertn = ertn_vld_w;
   assign exu_ifu_ert_addr = csr_ert_addr;

//   assign exc_vld_comb_w = exc_vld_w | lsu_except_ale_m;
//   assign exc_code_comb_w = exc_code_w | ({6{lsu_except_ale_m}} & 6'h09); // EXC_ALE 


   wire stall_ifu;
   wire stall_reg_mw;
   //wire flush = exu_ifu_except | exu_ifu_branch | exu_ifu_ertn;
   // should also | exc_vld_e | exc_vld_m to solve illinstr exception?
   // also | ertn_vld_e | ertn_vld_m
   wire flush = exc_vld_e | exc_vld_m | exc_vld_w | ertn_vld_e | ertn_vld_m | ertn_vld_w | bru_branch_e | bru_branch_m | bru_branch_w;
   //wire flush = exu_ifu_except | exu_ifu_ertn | bru_branch_e | bru_branch_m | bru_branch_w;

   assign exu_ifu_stall = stall_ifu;

   c7bexu_ecl u_ecl(
      .clk                             (clk),
      .resetn                          (resetn),

      .stall_ifu                       (stall_ifu),
      .stall_reg_mw                    (stall_reg_mw),

      .lsu_vld_e                       (lsu_vld_e),
      .lsu_except_ale_ls1              (lsu_except_ale_ls1),
      .lsu_except_buserr_ls3           (lsu_except_buserr_ls3),
      .lsu_except_ecc_ls3              (lsu_except_ecc_ls3),
      .lsu_data_valid_ls3              (lsu_data_vld_ls3),
      .lsu_wr_fin_ls3                  (lsu_wr_fin_ls3),

      .csr_vld_e                       (csr_vld_e)  // stall two cycles will be engough
   );


   //
   // Registers
   //

   // Only LSU operations and common pipeline registers (pc, wen, rd, etc.)
   // are affected by stalls. Other units continue execution normally.
   wire reg_en_m = ~stall_reg_mw;
   wire reg_en_e = ~stall_reg_mw;

   // exc
   dff_ns #(1) exc_vld_e_reg (
      .din (ifu_exu_exc_vld_d & ifu_exu_vld_d & ~flush),
      .clk (clk),
      .q   (exc_vld_e));

   dff_ns #(6) exc_code_e_reg (
      .din (ifu_exu_exc_code_d),
      .clk (clk),
      .q   (exc_code_e));
   
   // When an exception occurs, instruction issue to the functional units is
   // halted. The exception code is then propagated down the pipeline and
   // resolved at the write-back (_w) stage following a pipeline drain.
   dff_ns #(1) exc_vld_m_reg (
      .din (exc_vld_e),
      .clk (clk),
      .q   (exc_vld_m));

   dff_ns #(6) exc_code_m_reg (
      .din (exc_code_e),
      .clk (clk),
      .q   (exc_code_m));

   dff_ns #(1) exc_vld_w_reg (
      .din (exc_vld_m | lsu_except_ale_m),
      .clk (clk),
      .q   (exc_vld_w));

   dff_ns #(6) exc_code_w_reg (
      .din (exc_code_m | ({6{lsu_except_ale_m}} & 6'h09) ), // EXC_ALLE
      .clk (clk),
      .q   (exc_code_w));


   //
   dff_ns #(32) pc_e_reg (
      .din (ifu_exu_pc_d),
      .clk (clk),
      .q   (pc_e));

   dffe_ns #(32) pc_m_reg (
      .din (pc_e),
      .clk (clk),
      .en  (reg_en_e),
      .q   (pc_m));

   dffe_ns #(32) pc_w_reg (
      .din (pc_m),
      .clk (clk),
      .en  (reg_en_m),
      .q   (pc_w));

   dff_ns #(5) rs1_e_reg (
      .din (ifu_exu_rs1_d),
      .clk (clk),
      .q   (rs1_e));

   dff_ns #(5) rs2_e_reg (
      .din (ifu_exu_rs2_d),
      .clk (clk),
      .q   (rs2_e));

   dff_ns #(32) rs1_data_e_reg (
      .din (rs1_data_d),
      .clk (clk),
      .q   (rs1_data_e));

   dff_ns #(32) rs2_data_e_reg (
      .din (rs2_data_d),
      .clk (clk),
      .q   (rs2_data_e));

   // no need reset, but looks nice
   dffrl_ns #(5) rd_e_reg (
      .din (ifu_exu_rd_d),
      .clk (clk),
      .rst_l (resetn),
      .q   (rd_e));

   // need reset for c7bexu_byp logic
   dffrle_ns #(5) rd_m_reg (
      .din (rd_e),
      .clk (clk),
      .en  (reg_en_e),
      .rst_l (resetn),
      .q   (rd_m));

   // need reset for c7bexu_byp logic
   dffrle_ns #(5) rd_w_reg (
      .din (rd_m),
      .clk (clk),
      .en  (reg_en_m),
      .rst_l (resetn),
      .q   (rd_w));

   dffrl_ns #(1) wen_e_reg (
      .din (ifu_exu_wen_d & ifu_exu_vld_d & ~flush),
      .clk (clk),
      .rst_l (resetn),
      .q   (wen_e));

   dffrle_ns #(1) wen_m_reg (
      .din (wen_e),
      .clk (clk),
      .en  (reg_en_e),
      .rst_l (resetn),
      .q   (wen_m));

   dffrle_ns #(1) wen_w_reg (
      .din (wen_m & ~exc_vld_m & ~lsu_except_ale_m), // only when no exception
      .clk (clk),
      .en  (reg_en_m),
      .rst_l (resetn),
      .q   (wen_w));

   dff_ns #(32) imm_shifted_e_reg (
      .din (ifu_exu_imm_shifted_d),
      .clk (clk),
      .q   (imm_shifted_e));

   dffe_ns #(32) rd_data_w_reg (
      .din (rd_data_m),
      .clk (clk),
      .en  (reg_en_m),
      .q   (rd_data_w));

   // alu
   dff_ns #(1) alu_vld_e_reg (
      .din (ifu_exu_alu_vld_d & (ifu_exu_vld_d & ~ifu_exu_exc_vld_d) & ~flush),
      .clk (clk),
      .q   (alu_vld_e));

   dff_ns #(1) alu_vld_m_reg (
      .din (alu_vld_e),
      .clk (clk),
      .q   (alu_vld_m));

   dff_ns #(6) alu_op_e_reg (
      .din (ifu_exu_alu_op_d),
      .clk (clk),
      .q   (alu_op_e));

   dff_ns #(1) alu_a_pc_e_reg (
      .din (ifu_exu_alu_a_pc_d),
      .clk (clk),
      .q   (alu_a_pc_e));

   dff_ns #(32) alu_c_e_reg (
      .din (ifu_exu_alu_c_d),
      .clk (clk),
      .q   (alu_c_e));

   dff_ns #(1) alu_double_word_e_reg (
      .din (ifu_exu_alu_double_word_d),
      .clk (clk),
      .q   (alu_double_word_e));

   dff_ns #(1) alu_b_imm_e_reg (
      .din (ifu_exu_alu_b_imm_d),
      .clk (clk),
      .q   (alu_b_imm_e));

   dff_ns #(32) alu_res_m_reg (
      .din (alu_res_e),
      .clk (clk),
      .q   (alu_res_m));


   // lsu
   dffrl_ns #(1) lsu_vld_e_reg (
      .din (ifu_exu_lsu_vld_d & (ifu_exu_vld_d & ~ifu_exu_exc_vld_d) & ~flush),
      .clk (clk),
      .rst_l (resetn),
      .q   (lsu_vld_e));

   dff_ns #(7) lsu_op_e_reg (
      .din (ifu_exu_lsu_op_d),
      .clk (clk),
      .q   (lsu_op_e));

   dff_ns #(1) lsu_double_read_e_reg (
      .din (ifu_exu_lsu_double_read_d),
      .clk (clk),
      .q   (lsu_double_read_e));

   // m equvalent to ls1, for lsu instructions that raise ale, lsu will not stall 
   dff_ns #(1) lsu_except_ale_m_reg (
      .din (lsu_except_ale_ls1),
      .clk (clk),
      //.en  (reg_en_m), // ale should not affected by alu stall itself 
      .q   (lsu_except_ale_m));

   dff_ns #(32) lsu_except_badv_w_reg (
      .din (lsu_except_badv_ls1),
      .clk (clk),
      .q   (lsu_except_badv_w));

   // bru
   dff_ns #(1) bru_vld_e_reg (
      .din (ifu_exu_bru_vld_d & (ifu_exu_vld_d & ~ifu_exu_exc_vld_d) & ~flush),
      .clk (clk),
      .q   (bru_vld_e));

   dff_ns #(1) bru_vld_m_reg (
      .din (bru_vld_e),
      .clk (clk),
      .q   (bru_vld_m));

   dff_ns #(4) bru_op_e_reg (
      .din (ifu_exu_bru_op_d),
      .clk (clk),
      .q   (bru_op_e));

   dff_ns #(32) bru_offset_e_reg (
      .din (ifu_exu_bru_offset_d),
      .clk (clk),
      .q   (bru_offset_e));

   dff_ns #(32) bru_link_pc_m_reg (
      .din (bru_link_pc_e),
      .clk (clk),
      .q   (bru_link_pc_m));

   dff_ns #(1) bru_branch_m_reg (
      .din (bru_branch_e),
      .clk (clk),
      .q   (bru_branch_m));

   dff_ns #(1) bru_branch_w_reg (
      .din (bru_branch_m),
      .clk (clk),
      .q   (bru_branch_w));

   dff_ns #(32) bru_brn_addr_m_reg (
      .din (bru_brn_addr_e),
      .clk (clk),
      .q   (bru_brn_addr_m));

   dff_ns #(32) bru_brn_addr_w_reg (
      .din (bru_brn_addr_m),
      .clk (clk),
      .q   (bru_brn_addr_w));

   // mul
   dff_ns #(1) mul_vld_e_reg (
      .din (ifu_exu_mul_vld_d & (ifu_exu_vld_d & ~ifu_exu_exc_vld_d) & ~flush),
      .clk (clk),
      .q   (mul_vld_e));

   dff_ns #(1) mul_vld_m_reg (
      .din (mul_vld_e),
      .clk (clk),
      .q   (mul_vld_m));

   dff_ns #(1) mul_signed_e_reg (
      .din (ifu_exu_mul_signed_d),
      .clk (clk),
      .q   (mul_signed_e));

   dff_ns #(1) mul_double_e_reg (
      .din (ifu_exu_mul_double_d),
      .clk (clk),
      .q   (mul_double_e));

   dff_ns #(1) mul_hi_e_reg (
      .din (ifu_exu_mul_hi_d),
      .clk (clk),
      .q   (mul_hi_e));

   dff_ns #(1) mul_short_e_reg (
      .din (ifu_exu_mul_short_d),
      .clk (clk),
      .q   (mul_short_e));

   // csr
   //
   // CSR register updates are not affected by CSR stalls.
   // CSR stalls only block IFU for 2 cycles to prevent instruction fetch.
   dffrl_ns #(1) csr_vld_e_reg (
      .din (ifu_exu_csr_vld_d & (ifu_exu_vld_d & ~ifu_exu_exc_vld_d) & ~flush),
      .clk (clk),
      .rst_l (resetn),
      .q   (csr_vld_e));

   dffrl_ns #(1) csr_vld_m_reg (
      .din (csr_vld_e),
      .clk (clk),
      .rst_l (resetn),
      .q   (csr_vld_m));

   dff_ns #(32) csr_rdata_e_reg (
      .din (csr_rdata_d),
      .clk (clk),
      .q   (csr_rdata_e));

   dff_ns #(32) csr_rdata_m_reg (
      .din (csr_rdata_e),
      .clk (clk),
      .q   (csr_rdata_m));

   dff_ns #(1) csr_xchg_e_reg (
      .din (ifu_exu_csr_xchg_d),
      .clk (clk),
      .q   (csr_xchg_e));

   dff_ns #(1) csr_wen_e_reg (
      .din (ifu_exu_csr_wen_d),
      .clk (clk),
      .q   (csr_wen_e));

   dff_ns #(1) csr_wen_m_reg (
      .din (csr_wen_e),
      .clk (clk),
      .q   (csr_wen_m));

   dff_ns #(14) csr_waddr_e_reg (
      .din (ifu_exu_csr_waddr_d),
      .clk (clk),
      .q   (csr_waddr_e));

   dff_ns #(14) csr_waddr_m_reg (
      .din (csr_waddr_e),
      .clk (clk),
      .q   (csr_waddr_m));

   dff_ns #(32) csr_wdata_m_reg (
      .din (csr_wdata_e),
      .clk (clk),
      .q   (csr_wdata_m));

   dff_ns #(32) csr_mask_m_reg (
      .din (csr_mask_e),
      .clk (clk),
      .q   (csr_mask_m));

   // ertn
   dff_ns #(1) ertn_vld_e_reg (
      .din (ifu_exu_ertn_vld_d & (ifu_exu_vld_d & ~ifu_exu_exc_vld_d) & ~flush),
      .clk (clk),
      .q   (ertn_vld_e));

   dff_ns #(1) ertn_vld_m_reg (
      .din (ertn_vld_e),
      .clk (clk),
      .q   (ertn_vld_m));

   dff_ns #(1) ertn_vld_w_reg (
      .din (ertn_vld_m),
      .clk (clk),
      .q   (ertn_vld_w));

endmodule
