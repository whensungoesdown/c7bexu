`include "../../defines.vh"
`include "../../c7bifu/rtl/dec_defs.v"

module c7bexu (
   input              clk,
   input              resetn,

   input              ext_intr,

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
   input              ifu_exu_lsu_ibar_d,
   input              ifu_exu_lsu_dbar_d,
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

   // div
   input              ifu_exu_div_vld_d,
   input              ifu_exu_div_signed_d,
   input              ifu_exu_div_mod_d,

   // csr
   input              ifu_exu_csr_vld_d,
   input  [13:0]      ifu_exu_csr_raddr_d, // CSR_BIT 14
   input              ifu_exu_csr_xchg_d,
   input              ifu_exu_csr_wen_d,
   input  [13:0]      ifu_exu_csr_waddr_d, // CSR_BIT 14
   input              ifu_exu_csr_rdtimel_d,
   input              ifu_exu_csr_rdtimeh_d,

   // ertn
   input              ifu_exu_ertn_vld_d,

   // tlb
   input              ifu_exu_tlb_vld_d,
   input  [3:0]       ifu_exu_tlb_op_d,

   // exc
   input              ifu_exu_exc_vld_d,
   input  [5:0]       ifu_exu_exc_code_d,
   input  [8:0]       ifu_exu_exc_subcode_d,
   input  [31:0]      ifu_exu_exc_badv_d,

   // memory interface  E M
   output             lsu_biu_rd_req,
   output [31:0]      lsu_biu_rd_addr,

   input              biu_lsu_rd_ack,
   input              biu_lsu_data_vld,
   input  [63:0]      biu_lsu_data,
   input              biu_lsu_fault,
   input  [1:0]       biu_lsu_fault_code,

   output             lsu_biu_wr_req,
   output [31:0]      lsu_biu_wr_addr,
   output [63:0]      lsu_biu_wr_data,
   output [7:0]       lsu_biu_wr_strb,

   input              biu_lsu_wr_ack,
   input              biu_lsu_wr_fin,
   input              biu_lsu_wr_fault,
   input  [1:0]       biu_lsu_wr_fault_code,

   output             csr_ifu_ic_en,
   output             csr_ifu_ic_en_pls,

   output             csr_ifu_crmd_da, 
   output             csr_ifu_crmd_pg,

   output [2:0]       csr_ifu_dmw0_pseg,
   output [2:0]       csr_ifu_dmw0_vseg,
   output [2:0]       csr_ifu_dmw1_pseg,
   output [2:0]       csr_ifu_dmw1_vseg,

   output [18:0]      csr_itlb_tlbehi_vppn,

   output             csr_itlb_tlbidx_ne,
   output [5:0]       csr_itlb_tlbidx_ps,
   output             csr_itlb_tlbidx_i_d,
   output [4:0]       csr_itlb_tlbidx_index,

   output [19:0]      csr_itlb_tlbelo0_ppn,
   output             csr_itlb_tlbelo0_g,
   output [1:0]       csr_itlb_tlbelo0_mat,
   output [1:0]       csr_itlb_tlbelo0_plv,
   output             csr_itlb_tlbelo0_d,
   output             csr_itlb_tlbelo0_v,
   
   output [19:0]      csr_itlb_tlbelo1_ppn,
   output             csr_itlb_tlbelo1_g,
   output [1:0]       csr_itlb_tlbelo1_mat,
   output [1:0]       csr_itlb_tlbelo1_plv,
   output             csr_itlb_tlbelo1_d,
   output             csr_itlb_tlbelo1_v,

   output [9:0]       csr_itlb_asid_asid, 

   output             csr_itlb_tlbrefill_ctx,

   output [1:0]       csr_itlb_crmd_plv,

   output [4:0]       exu_itlb_random_index,

   output             exu_itlb_tlbfill_vld_e,
   output             exu_itlb_tlbwr_vld_e,
   output             exu_itlb_tlbsrch_vld_e,
   output             exu_itlb_invtlb_vld_e,

   output [4:0]       exu_itlb_invtlb_op_e,
   output [9:0]       exu_itlb_invtlb_asid_e,
   output [18:0]      exu_itlb_invtlb_vppn_e,

   // itlb to csr
   input  [4:0]       itlb_csr_tlbidx_index,
   input  [18:0]      itlb_csr_tlbehi_vppn,
   input              itlb_csr_tlbelo_g,
   input  [5:0]       itlb_csr_tlbidx_ps,
   input              itlb_csr_tlbidx_e,
   input              itlb_csr_tlbelo0_v,
   input              itlb_csr_tlbelo0_d,
   input  [1:0]       itlb_csr_tlbelo0_mat,
   input  [1:0]       itlb_csr_tlbelo0_plv,
   input  [19:0]      itlb_csr_tlbelo0_ppn,
   input              itlb_csr_tlbelo1_v,
   input              itlb_csr_tlbelo1_d,
   input  [1:0]       itlb_csr_tlbelo1_mat,
   input  [1:0]       itlb_csr_tlbelo1_plv,
   input  [19:0]      itlb_csr_tlbelo1_ppn,
   input  [9:0]       itlb_csr_asid_asid 
);

// Debug Code
//   // uty: test
//   // 移位寄存器，用于记录最近4个周期的状态
//   reg [3:0] shift_reg;
//   reg uty_test /*synthesis noprune*/;
//   
//   always @(posedge clk or negedge resetn) begin
//      if (!resetn) begin
//         // 异步复位
//         shift_reg <= 4'b0;
//         uty_test <= 1'b0;
//      end else begin
//              // 将当前周期是否全0的信息移入寄存器
//              shift_reg <= {shift_reg[2:0], (ifu_exu_pc_d[11:0] == 12'b0)};
//   
//              // 检查是否连续4个周期都为0
//              if (shift_reg == 4'b1111) begin
//                 uty_test <= 1'b1;
//              end else begin
//                 uty_test <= 1'b0;
//              end
//      end
//   end
//   //
   
   wire flush;
   wire ertn_vld_e;
   wire ertn_vld_m;
   wire ertn_vld_w;

   // intr
   wire ext_intr_sync;
   wire ext_intr_pulse;
   wire csr_timer_intr;
   wire csr_crmd_ie;

   // tlb
   wire tlb_vld_e;
   wire [3:0] tlb_op_e;
   wire tlbfill_vld_e; 
   wire tlbwr_vld_e; 
   wire tlbrd_vld_e;
   wire tlbsrch_vld_e;
   wire tlbsrch_vld_m;
   wire invtlb_vld_e;

   wire [1:0] csr_crmd_plv;
   wire csr_crmd_da;
   wire csr_crmd_pg;
   wire [2:0] csr_dmw0_pseg;
   wire [2:0] csr_dmw0_vseg;
   wire [2:0] csr_dmw1_pseg;
   wire [2:0] csr_dmw1_vseg;

   wire [18:0] csr_tlbehi_vppn;

   wire        csr_tlbidx_ne;
   wire [5:0]  csr_tlbidx_ps;
   wire        csr_tlbidx_i_d;
   wire [4:0]  csr_tlbidx_index;

   wire [19:0] csr_tlbelo0_ppn;
   wire        csr_tlbelo0_g;
   wire [1:0]  csr_tlbelo0_mat;
   wire [1:0]  csr_tlbelo0_plv;
   wire        csr_tlbelo0_d;
   wire        csr_tlbelo0_v;

   wire [19:0] csr_tlbelo1_ppn;
   wire        csr_tlbelo1_g;
   wire [1:0]  csr_tlbelo1_mat;
   wire [1:0]  csr_tlbelo1_plv;
   wire        csr_tlbelo1_d;
   wire        csr_tlbelo1_v;

   wire [9:0]  csr_asid_asid; 

   wire        csr_tlbrefill_ctx;

   // csr to dtlb, to do
   wire [1:0]  csr_dtlb_crmd_plv;

   wire [4:0]  random_tlb_index;

   // dtlb to csr
   wire [4:0]  dtlb_csr_tlbidx_index;
   wire [18:0] dtlb_csr_tlbehi_vppn;
   wire        dtlb_csr_tlbelo_g;
   wire [5:0]  dtlb_csr_tlbidx_ps;
   wire        dtlb_csr_tlbidx_e;
   wire        dtlb_csr_tlbelo0_v;
   wire        dtlb_csr_tlbelo0_d;
   wire [1:0]  dtlb_csr_tlbelo0_mat;
   wire [1:0]  dtlb_csr_tlbelo0_plv;
   wire [19:0] dtlb_csr_tlbelo0_ppn;
   wire        dtlb_csr_tlbelo1_v;
   wire        dtlb_csr_tlbelo1_d;
   wire [1:0]  dtlb_csr_tlbelo1_mat;
   wire [1:0]  dtlb_csr_tlbelo1_plv;
   wire [19:0] dtlb_csr_tlbelo1_ppn;
   wire [9:0]  dtlb_csr_asid_asid;

   wire        exu_dtlb_invtlb_vld_e;

   wire [4:0]  exu_dtlb_invtlb_op_e;
   wire [9:0]  exu_dtlb_invtlb_asid_e;
   wire [18:0] exu_dtlb_invtlb_vppn_e;



   intr_sync #(
           .SYNC_STAGES(2)
   ) u_ext_intr_sync (
           .clk            (clk),
           .rst_n          (resetn),
           .intr           (ext_intr),
           .intr_sync      (ext_intr_sync),
           .intr_pulse     (ext_intr_pulse)
   );


   wire intr_sync;
   wire intr_pulse;
   wire pic_csr_ext_intr;

   pic u_pic (
      .clk                             (clk),
      .resetn                          (resetn),
      .ext_intr_sync                   (ext_intr_sync & csr_crmd_ie),
      .csr_timer_intr_sync             (csr_timer_intr & csr_crmd_ie),
      .vld_d                           (ifu_exu_vld_d & ~ifu_exu_exc_vld_d & ~flush),
      .ertn_w                          (ertn_vld_w),

      .pic_csr_ext_intr                (pic_csr_ext_intr),
      .intr_sync                       (intr_sync),
      .intr_sync_pulse                 (intr_pulse)
   );

   // exc
   wire exc_vld_e;
   wire exc_vld_m;
   wire exc_vld_w;

   wire [5:0] exc_code_e;
   wire [5:0] exc_code_m;
   wire [5:0] exc_code_w;

   wire [8:0] exc_subcode_e;
   wire [8:0] exc_subcode_m;
   wire [8:0] exc_subcode_w;

   wire [31:0] exc_badv_e;
   wire [31:0] exc_badv_m;
   wire [31:0] exc_badv_w;

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

      .waddr1                          (rd_w),// I, 5
      .raddr0_0                        (ifu_exu_rs1_d),// I, 5
      .raddr0_1                        (ifu_exu_rs2_d),// I, 5
      .wen1                            (wen_w),// I, 1
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
   wire lsu_ibar_e;
   wire lsu_dbar_e;
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
   wire [31:0] lsu_except_ale_badv_ls1;
   wire [31:0] lsu_except_ale_badv_m;
   wire lsu_except_buserr_ls3;
   wire [31:0] lsu_except_buserr_badv_ls3;
   wire lsu_except_ecc_ls3;
   wire lsu_except_tlbr_ls2;   
   wire [31:0] lsu_except_tlbr_badv_ls2;
   wire lsu_except_pil_ls2;
   wire [31:0] lsu_except_pil_badv_ls2;
   wire lsu_except_pis_ls2;
   wire [31:0] lsu_except_pis_badv_ls2;
   wire lsu_except_ppi_ls2;
   wire [31:0] lsu_except_ppi_badv_ls2;
   wire lsu_except_pme_ls2;
   wire [31:0] lsu_except_pme_badv_ls2;

   wire lsu_except_tlb_related_ls2;

   wire lsu_ecl_ibar_fin;
   wire lsu_ecl_dbar_fin;
   wire lsu_ecl_sc_fin_ls1; // equals to _e
   wire lsu_sc_fin_m;

   wire lsu_sc;
   wire lsu_csr_llb_set;
   wire lsu_csr_llb_clr;
   wire csr_lsu_llb;

   assign lsu_base_e = rs1_data_byp_e;
   assign lsu_offset_e = lsu_double_read_e ? rs2_data_byp_e: imm_shifted_e;
   assign lsu_wdata_e = rs2_data_byp_e;

   assign lsu_except_tlb_related_ls2 = lsu_except_tlbr_ls2 | lsu_except_pil_ls2 | lsu_except_pis_ls2 | lsu_except_ppi_ls2 | lsu_except_pme_ls2;

   c7blsu u_lsu(
      .clk                             (clk),
      .resetn                          (resetn),

      .ecl_lsu_valid_e                 (lsu_vld_e),
      .ecl_lsu_ibar_e                  (lsu_ibar_e),
      .ecl_lsu_dbar_e                  (lsu_dbar_e),
      .ecl_lsu_op_e                    (lsu_op_e),
      .ecl_lsu_base_e                  (lsu_base_e),
      .ecl_lsu_offset_e                (lsu_offset_e),
      .ecl_lsu_wdata_e                 (lsu_wdata_e),
      .lsu_ecl_data_valid_ls3          (lsu_data_vld_ls3),
      .lsu_ecl_data_ls3                (lsu_data_ls3),
      .lsu_ecl_wr_fin_ls3              (lsu_wr_fin_ls3),      
      .lsu_ecl_except_ale_ls1          (lsu_except_ale_ls1),
      .lsu_ecl_except_ale_badv_ls1     (lsu_except_ale_badv_ls1),
      .lsu_ecl_except_buserr_ls3       (lsu_except_buserr_ls3),
      .lsu_ecl_except_ecc_ls3          (lsu_except_ecc_ls3),
      .lsu_ecl_except_buserr_badv_ls3  (lsu_except_buserr_badv_ls3),
      .lsu_ecl_except_tlbr_ls2         (lsu_except_tlbr_ls2),
      .lsu_ecl_except_tlbr_badv_ls2    (lsu_except_tlbr_badv_ls2),
      .lsu_except_pil_ls2              (lsu_except_pil_ls2),
      .lsu_except_pil_badv_ls2         (lsu_except_pil_badv_ls2),
      .lsu_except_pis_ls2              (lsu_except_pis_ls2),
      .lsu_except_pis_badv_ls2         (lsu_except_pis_badv_ls2),
      .lsu_except_ppi_ls2              (lsu_except_ppi_ls2),
      .lsu_except_ppi_badv_ls2         (lsu_except_ppi_badv_ls2),
      .lsu_except_pme_ls2              (lsu_except_pme_ls2),
      .lsu_except_pme_badv_ls2         (lsu_except_pme_badv_ls2),

      .lsu_ecl_ibar_fin                (lsu_ecl_ibar_fin),
      .lsu_ecl_dbar_fin                (lsu_ecl_dbar_fin),
      .lsu_ecl_sc_fin_ls1              (lsu_ecl_sc_fin_ls1),

      .lsu_sc                          (lsu_sc),
      .lsu_csr_llb_set                 (lsu_csr_llb_set),
      .lsu_csr_llb_clr                 (lsu_csr_llb_clr),

      .csr_lsu_llb                     (csr_lsu_llb),

      // BIU Interface
      .lsu_biu_rd_req_ls2              (lsu_biu_rd_req),
      .lsu_biu_rd_addr_ls2             (lsu_biu_rd_addr),
      .biu_lsu_rd_ack_ls2              (biu_lsu_rd_ack),
      .biu_lsu_data_valid_ls3          (biu_lsu_data_vld),
      .biu_lsu_data_ls3                (biu_lsu_data),
      .biu_lsu_fault_ls3               (biu_lsu_fault),
      .biu_lsu_fault_code_ls3          (biu_lsu_fault_code),

      .lsu_biu_wr_req_ls2              (lsu_biu_wr_req),
      .lsu_biu_wr_addr_ls2             (lsu_biu_wr_addr),
      .lsu_biu_wr_data_ls2             (lsu_biu_wr_data),
      .lsu_biu_wr_strb_ls2             (lsu_biu_wr_strb),
      .biu_lsu_wr_ack_ls2              (biu_lsu_wr_ack),
      .biu_lsu_wr_fin_ls3              (biu_lsu_wr_fin),
      .biu_lsu_wr_fault_ls3            (biu_lsu_wr_fault),
      .biu_lsu_wr_fault_code_ls3       (biu_lsu_wr_fault_code),

      .csr_lsu_crmd_da                 (csr_crmd_da),
      .csr_lsu_crmd_pg                 (csr_crmd_pg),

      .csr_lsu_dmw0_pseg               (csr_dmw0_pseg),
      .csr_lsu_dmw0_vseg               (csr_dmw0_vseg),
      .csr_lsu_dmw1_pseg               (csr_dmw1_pseg),
      .csr_lsu_dmw1_vseg               (csr_dmw1_vseg),

      .csr_dtlb_tlbehi_vppn            (csr_tlbehi_vppn),

      .csr_dtlb_tlbidx_ne              (csr_tlbidx_ne),
      .csr_dtlb_tlbidx_ps              (csr_tlbidx_ps),
      .csr_dtlb_tlbidx_i_d             (csr_tlbidx_i_d),
      .csr_dtlb_tlbidx_index           (csr_tlbidx_index),

      .csr_dtlb_tlbelo0_ppn            (csr_tlbelo0_ppn),
      .csr_dtlb_tlbelo0_g              (csr_tlbelo0_g),
      .csr_dtlb_tlbelo0_mat            (csr_tlbelo0_mat),
      .csr_dtlb_tlbelo0_plv            (csr_tlbelo0_plv),
      .csr_dtlb_tlbelo0_d              (csr_tlbelo0_d),
      .csr_dtlb_tlbelo0_v              (csr_tlbelo0_v),

      .csr_dtlb_tlbelo1_ppn            (csr_tlbelo1_ppn),
      .csr_dtlb_tlbelo1_g              (csr_tlbelo1_g),
      .csr_dtlb_tlbelo1_mat            (csr_tlbelo1_mat),
      .csr_dtlb_tlbelo1_plv            (csr_tlbelo1_plv),
      .csr_dtlb_tlbelo1_d              (csr_tlbelo1_d),
      .csr_dtlb_tlbelo1_v              (csr_tlbelo1_v),
      .csr_dtlb_asid_asid              (csr_asid_asid),

      .csr_dtlb_tlbrefill_ctx          (csr_tlbrefill_ctx),

      .csr_dtlb_crmd_plv               (csr_dtlb_crmd_plv),

      .exu_dtlb_random_index           (random_tlb_index),

      .csr_dtlb_tlbfill_vld_e          (tlbfill_vld_e),
      .csr_dtlb_tlbwr_vld_e            (tlbwr_vld_e),
      .exu_dtlb_tlbsrch_vld_e          (tlbsrch_vld_e),
      .exu_dtlb_tlbsrch_vld_m          (tlbsrch_vld_m),
      .exu_dtlb_invtlb_vld_e           (exu_dtlb_invtlb_vld_e), 
      .exu_dtlb_invtlb_op_e            (exu_dtlb_invtlb_op_e),
      .exu_dtlb_invtlb_asid_e          (exu_dtlb_invtlb_asid_e),
      .exu_dtlb_invtlb_vppn_e          (exu_dtlb_invtlb_vppn_e),



      .dtlb_csr_tlbidx_index           (dtlb_csr_tlbidx_index),
      .dtlb_csr_tlbehi_vppn            (dtlb_csr_tlbehi_vppn),
      .dtlb_csr_tlbelo_g               (dtlb_csr_tlbelo_g),
      .dtlb_csr_tlbidx_ps              (dtlb_csr_tlbidx_ps),
      .dtlb_csr_tlbidx_e               (dtlb_csr_tlbidx_e),
      .dtlb_csr_tlbelo0_v              (dtlb_csr_tlbelo0_v),
      .dtlb_csr_tlbelo0_d              (dtlb_csr_tlbelo0_d),
      .dtlb_csr_tlbelo0_mat            (dtlb_csr_tlbelo0_mat),
      .dtlb_csr_tlbelo0_plv            (dtlb_csr_tlbelo0_plv),
      .dtlb_csr_tlbelo0_ppn            (dtlb_csr_tlbelo0_ppn),
      .dtlb_csr_tlbelo1_v              (dtlb_csr_tlbelo1_v),
      .dtlb_csr_tlbelo1_d              (dtlb_csr_tlbelo1_d),
      .dtlb_csr_tlbelo1_mat            (dtlb_csr_tlbelo1_mat),
      .dtlb_csr_tlbelo1_plv            (dtlb_csr_tlbelo1_plv),
      .dtlb_csr_tlbelo1_ppn            (dtlb_csr_tlbelo1_ppn),
      .dtlb_csr_asid_asid              (dtlb_csr_asid_asid)
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

   //assign bru_a_e = rs1_data_e;
   //assign bru_b_e = rs2_data_e;
   assign bru_a_e = rs1_data_byp_e;
   assign bru_b_e = rs2_data_byp_e;
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

   assign mul_a_e = rs1_data_byp_e;
   assign mul_b_e = rs2_data_byp_e;
   assign mul_a_64_e = {32'b0, mul_a_e};
   assign mul_b_64_e = {32'b0, mul_b_e};
   assign mul_res_m = mul_res_64_m[31:0];

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


   // div
   wire div_vld_e;
   wire div_vld_m;
   wire [31:0] div_a_e;
   wire [31:0] div_b_e;
   wire div_signed_e;
   wire div_mod_e;
   wire div_mod_m;
   wire [31:0] div_s_m;
   wire [31:0] div_r_m;
   wire div_complete_m;

   assign div_a_e = rs1_data_byp_e;
   assign div_b_e = rs2_data_byp_e;

   div u_div (
      .div_clk                         (clk),
      .reset                           (~resetn),

      .div                             (div_vld_e),
      .div_signed                      (div_signed_e),
      .x                               (div_a_e),
      .y                               (div_b_e),
      .s                               (div_s_m),
      .r                               (div_r_m),
      .complete                        (div_complete_m)
   );


   // csr
   wire csr_vld_e;
   wire csr_vld_m;
   wire [13:0] csr_raddr_d;
   wire csr_rdtimel_d;
   wire csr_rdtimeh_d;
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
   wire [31:0] csr_tlbr_addr;

   //wire [31:0] csr_badv;

   assign csr_raddr_d = ifu_exu_csr_raddr_d;
   assign csr_rdtimel_d = ifu_exu_csr_rdtimel_d;
   assign csr_rdtimeh_d = ifu_exu_csr_rdtimeh_d;
   assign csr_wdata_e = rs2_data_byp_e;
   assign csr_mask_e = csr_xchg_e ? rs1_data_byp_e : 32'hFFFFFFFF;


   c7bcsr u_csr(
      .clk                             (clk),
      .resetn                          (resetn),
      .csr_rdata                       (csr_rdata_d),
      .csr_raddr                       (csr_raddr_d),
      .csr_waddr                       (csr_waddr_m),
      .csr_wdata                       (csr_wdata_m),
      .csr_mask                        (csr_mask_m),
      .csr_wen                         (csr_wen_m),
      .csr_rdtimel                     (csr_rdtimel_d),
      .csr_rdtimeh                     (csr_rdtimeh_d),

      .csr_eentry                      (csr_isr_addr),
      .csr_era                         (csr_ert_addr),
      .csr_tlbrentry                   (csr_tlbr_addr),

      .ecl_csr_badv_w                  (exc_badv_w), 
      .exu_csr_except_w                (exc_vld_w),
      .ecl_csr_exccode_w               (exc_code_w),
      .ecl_csr_excsubcode_w            (exc_subcode_w),
      .ifu_exu_pc_w                    (pc_w),
      .ecl_csr_ertn_w                  (ertn_vld_w),
      .lsu_csr_llb_set                 (lsu_csr_llb_set),
      .lsu_csr_llb_clr                 (lsu_csr_llb_clr),

      .csr_lsu_llb                     (csr_lsu_llb),
      .csr_ecl_crmd_ie                 (csr_crmd_ie),
      .csr_crmd_plv                    (csr_crmd_plv),
      .csr_crmd_da                     (csr_crmd_da),
      .csr_crmd_pg                     (csr_crmd_pg),
      .csr_dmw0_pseg                   (csr_dmw0_pseg), 
      .csr_dmw0_vseg                   (csr_dmw0_vseg), 
      .csr_dmw1_pseg                   (csr_dmw1_pseg), 
      .csr_dmw1_vseg                   (csr_dmw1_vseg), 
      .csr_ifu_ic_en                   (csr_ifu_ic_en), 
      .csr_ifu_ic_en_pls               (csr_ifu_ic_en_pls), 
      .csr_ecl_timer_intr              (csr_timer_intr),

      .ext_intr_sync                   (ext_intr_sync),
      //.ext_intr_sync                   (pic_csr_ext_intr)
      
      .csr_tlbehi_vppn                 (csr_tlbehi_vppn),

      .csr_tlbidx_ne                   (csr_tlbidx_ne),
      .csr_tlbidx_ps                   (csr_tlbidx_ps),
      .csr_tlbidx_i_d                  (csr_tlbidx_i_d),
      .csr_tlbidx_index                (csr_tlbidx_index),

      .csr_tlbelo0_ppn                 (csr_tlbelo0_ppn),
      .csr_tlbelo0_g                   (csr_tlbelo0_g),
      .csr_tlbelo0_mat                 (csr_tlbelo0_mat),
      .csr_tlbelo0_plv                 (csr_tlbelo0_plv),
      .csr_tlbelo0_d                   (csr_tlbelo0_d),
      .csr_tlbelo0_v                   (csr_tlbelo0_v),

      .csr_tlbelo1_ppn                 (csr_tlbelo1_ppn),
      .csr_tlbelo1_g                   (csr_tlbelo1_g),
      .csr_tlbelo1_mat                 (csr_tlbelo1_mat),
      .csr_tlbelo1_plv                 (csr_tlbelo1_plv),
      .csr_tlbelo1_d                   (csr_tlbelo1_d),
      .csr_tlbelo1_v                   (csr_tlbelo1_v),
      .csr_asid_asid                   (csr_asid_asid),

      .csr_tlbrefill_ctx               (csr_tlbrefill_ctx),

      .tlbrd_vld_e                     (tlbrd_vld_e),
      .tlbsrch_vld_m                   (tlbsrch_vld_m),

      // itlb to csr
      .itlb_csr_tlbidx_index           (itlb_csr_tlbidx_index),
      .itlb_csr_tlbehi_vppn            (itlb_csr_tlbehi_vppn),
      .itlb_csr_tlbelo_g               (itlb_csr_tlbelo_g),
      .itlb_csr_tlbidx_ps              (itlb_csr_tlbidx_ps),
      .itlb_csr_tlbidx_e               (itlb_csr_tlbidx_e),
      .itlb_csr_tlbelo0_v              (itlb_csr_tlbelo0_v),
      .itlb_csr_tlbelo0_d              (itlb_csr_tlbelo0_d),
      .itlb_csr_tlbelo0_mat            (itlb_csr_tlbelo0_mat),
      .itlb_csr_tlbelo0_plv            (itlb_csr_tlbelo0_plv),
      .itlb_csr_tlbelo0_ppn            (itlb_csr_tlbelo0_ppn),
      .itlb_csr_tlbelo1_v              (itlb_csr_tlbelo1_v),
      .itlb_csr_tlbelo1_d              (itlb_csr_tlbelo1_d),
      .itlb_csr_tlbelo1_mat            (itlb_csr_tlbelo1_mat),
      .itlb_csr_tlbelo1_plv            (itlb_csr_tlbelo1_plv),
      .itlb_csr_tlbelo1_ppn            (itlb_csr_tlbelo1_ppn),
      .itlb_csr_asid_asid              (itlb_csr_asid_asid),

      // dtlb to csr
      .dtlb_csr_tlbidx_index           (dtlb_csr_tlbidx_index),
      .dtlb_csr_tlbehi_vppn            (dtlb_csr_tlbehi_vppn),
      .dtlb_csr_tlbelo_g               (dtlb_csr_tlbelo_g),
      .dtlb_csr_tlbidx_ps              (dtlb_csr_tlbidx_ps),
      .dtlb_csr_tlbidx_e               (dtlb_csr_tlbidx_e),
      .dtlb_csr_tlbelo0_v              (dtlb_csr_tlbelo0_v),
      .dtlb_csr_tlbelo0_d              (dtlb_csr_tlbelo0_d),
      .dtlb_csr_tlbelo0_mat            (dtlb_csr_tlbelo0_mat),
      .dtlb_csr_tlbelo0_plv            (dtlb_csr_tlbelo0_plv),
      .dtlb_csr_tlbelo0_ppn            (dtlb_csr_tlbelo0_ppn),
      .dtlb_csr_tlbelo1_v              (dtlb_csr_tlbelo1_v),
      .dtlb_csr_tlbelo1_d              (dtlb_csr_tlbelo1_d),
      .dtlb_csr_tlbelo1_mat            (dtlb_csr_tlbelo1_mat),
      .dtlb_csr_tlbelo1_plv            (dtlb_csr_tlbelo1_plv),
      .dtlb_csr_tlbelo1_ppn            (dtlb_csr_tlbelo1_ppn),
      .dtlb_csr_asid_asid              (dtlb_csr_asid_asid)
   );

   assign csr_ifu_crmd_da = csr_crmd_da;
   assign csr_ifu_crmd_pg = csr_crmd_pg;

   assign csr_ifu_dmw0_pseg = csr_dmw0_pseg;
   assign csr_ifu_dmw0_vseg = csr_dmw0_vseg;
   assign csr_ifu_dmw1_pseg = csr_dmw1_pseg;
   assign csr_ifu_dmw1_vseg = csr_dmw1_vseg;

   assign csr_itlb_tlbehi_vppn  = csr_tlbehi_vppn;

   assign csr_itlb_tlbidx_ne    = csr_tlbidx_ne;
   assign csr_itlb_tlbidx_ps    = csr_tlbidx_ps;
   assign csr_itlb_tlbidx_i_d   = csr_tlbidx_i_d;
   assign csr_itlb_tlbidx_index = csr_tlbidx_index;

   assign csr_itlb_tlbelo0_ppn = csr_tlbelo0_ppn;
   assign csr_itlb_tlbelo0_g   = csr_tlbelo0_g;
   assign csr_itlb_tlbelo0_mat = csr_tlbelo0_mat;
   assign csr_itlb_tlbelo0_plv = csr_tlbelo0_plv;
   assign csr_itlb_tlbelo0_d   = csr_tlbelo0_d;
   assign csr_itlb_tlbelo0_v   = csr_tlbelo0_v;

   assign csr_itlb_tlbelo1_ppn = csr_tlbelo1_ppn;
   assign csr_itlb_tlbelo1_g   = csr_tlbelo1_g;
   assign csr_itlb_tlbelo1_mat = csr_tlbelo1_mat;
   assign csr_itlb_tlbelo1_plv = csr_tlbelo1_plv;
   assign csr_itlb_tlbelo1_d   = csr_tlbelo1_d;
   assign csr_itlb_tlbelo1_v   = csr_tlbelo1_v;
   assign csr_itlb_asid_asid   = csr_asid_asid;

   assign csr_itlb_tlbrefill_ctx = csr_tlbrefill_ctx;

   assign csr_itlb_crmd_plv = csr_crmd_plv;

   assign csr_dtlb_crmd_plv = csr_crmd_plv;

   // tlbfill
   assign tlbfill_vld_e = tlb_vld_e & (tlb_op_e == `LTLB_TLBWR);
   assign exu_itlb_tlbfill_vld_e = tlbfill_vld_e;
   // tlbwr
   assign tlbwr_vld_e = tlb_vld_e & (tlb_op_e == `LTLB_TLBWI);
   assign exu_itlb_tlbwr_vld_e = tlbwr_vld_e;
   // tlbrd
   assign tlbrd_vld_e = tlb_vld_e & (tlb_op_e == `LTLB_TLBR);
   // tlbsrch
   assign tlbsrch_vld_e = tlb_vld_e & (tlb_op_e == `LTLB_TLBP);
   assign exu_itlb_tlbsrch_vld_e = tlbsrch_vld_e;

   // TLB search takes 1 cycle
   dffrl_ns #(1) tlbsrch_vld_m_reg (
      .din   (tlbsrch_vld_e),
      .rst_l (resetn),
      .clk   (clk),
      .q     (tlbsrch_vld_m));

   assign invtlb_vld_e = tlb_vld_e & (tlb_op_e == `LTLB_INVTLB);

   assign exu_itlb_invtlb_vld_e = invtlb_vld_e;
   assign exu_itlb_invtlb_op_e = rd_e;
   assign exu_itlb_invtlb_asid_e = rs1_data_byp_e[9:0];
   assign exu_itlb_invtlb_vppn_e = rs2_data_byp_e[31:13];

   assign exu_dtlb_invtlb_vld_e = invtlb_vld_e;
   assign exu_dtlb_invtlb_op_e = rd_e;
   assign exu_dtlb_invtlb_asid_e = rs1_data_byp_e[9:0];
   assign exu_dtlb_invtlb_vppn_e = rs2_data_byp_e[31:13];


   random u_random(
      .clk                              (clk),
      .resetn                           (resetn),
      .count                            (random_tlb_index)
   );

   assign exu_itlb_random_index = random_tlb_index;



   assign rd_data_m = ({32{alu_vld_m}}               & alu_res_m) |
                      ({32{lsu_data_vld_ls3}}        & lsu_data_ls3) |
                      ({32{bru_vld_m}}               & bru_link_pc_m) |
                      ({32{mul_vld_m}}               & mul_res_m) |
                      ({32{csr_vld_m}}               & csr_rdata_m) |
                      ({32{div_vld_m &  div_mod_m}}  & div_r_m) |
                      ({32{div_vld_m & ~div_mod_m}}  & div_s_m) |
		      ({32{lsu_sc_fin_m}}            & 32'b0) |   // {31'b0, csr_lsu_llb}
		      ({32{lsu_wr_fin_ls3 & lsu_sc}} & 32'b1);

   // This circuit implementation is prioritized.
   //assign rd_data_m = alu_vld_m                     ? alu_res_m :
   //                  (lsu_vld_m & lsu_data_vld_ls3) ? lsu_rdata_m :
   //                   bru_vld_m                     ? bru_link_pc_m :
   //                   mul_vld_m                     ? mul_res_m :
   //                   csr_vld_m                     ? csr_rdata_m :
   //                                                 '0;

   assign exu_ifu_branch = bru_branch_w;
   assign exu_ifu_brn_addr = bru_brn_addr_w;

   assign exu_ifu_except = exc_vld_w;
   //assign exu_ifu_isr_addr = csr_isr_addr;
   //                                       `EXC_TLBR
   assign exu_ifu_isr_addr = (exc_code_w == 6'h3f) ? csr_tlbr_addr : csr_isr_addr;

   assign exu_ifu_ertn = ertn_vld_w;
   assign exu_ifu_ert_addr = csr_ert_addr;



   wire stall_ifu;
   wire stall_reg_mw;
   
   // Because lsu_except_ale_ls1 merge into exc_vld_m at _m, therefore, ale
   // exception at _e also need to flush
   //assign flush = lsu_except_ale_ls1 | lsu_except_tlbr_ls2 | exc_vld_e | exc_vld_m | exc_vld_w | ertn_vld_e | ertn_vld_m | ertn_vld_w | bru_branch_e | bru_branch_m | bru_branch_w;
   assign flush = lsu_except_ale_ls1 | lsu_except_tlb_related_ls2 | exc_vld_e | exc_vld_m | exc_vld_w | ertn_vld_e | ertn_vld_m | ertn_vld_w | bru_branch_e | bru_branch_m | bru_branch_w;

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
      //.lsu_except_tlbr_ls2             (lsu_except_tlbr_ls2),
      .lsu_except_tlb_related_ls2      (lsu_except_tlb_related_ls2),
      .lsu_data_valid_ls3              (lsu_data_vld_ls3),
      .lsu_wr_fin_ls3                  (lsu_wr_fin_ls3),

      .lsu_ecl_ibar_fin                (lsu_ecl_ibar_fin),
      .lsu_ecl_dbar_fin                (lsu_ecl_dbar_fin),
      .lsu_ecl_sc_fin                  (lsu_ecl_sc_fin_ls1),

      .csr_vld_e                       (csr_vld_e),  // stall two cycles will be engough

      .div_vld_e                       (div_vld_e),
      .div_complete_m                  (div_complete_m),

      .tlb_vld_e                       (tlb_vld_e) // stall one cycle, to let tlbsrch take tlb's search port
   );


   wire vld_e = exc_vld_e | alu_vld_e | lsu_vld_e | bru_vld_e | mul_vld_e | div_vld_e | csr_vld_e | ertn_vld_e | tlb_vld_e;

   // a valid instrution, with no exception so far, not flushed by previous
   // instructions, and no interruption
   wire good_to_issue = (ifu_exu_vld_d & ~ifu_exu_exc_vld_d) & ~flush & ~intr_pulse;


   //// exc
   //reg intr_pending;
   //wire intr_insert_condition = ifu_exu_vld_d & ~ifu_exu_exc_vld_d & ~flush;
   //wire intr_to_insert = intr_pending | intr_pulse;   // pulse or pending

   //always @(posedge clk or negedge resetn) begin
   //   if (!resetn) begin
   //      intr_pending <= 1'b0;
   //   end else begin
   //      if (intr_pulse) begin
   //         // new interrupt arrives: if currently insertable then insert immediately (no pending), else pend
   //         if (intr_insert_condition)
   //            intr_pending <= 1'b0;   // consumed immediately, no pending
   //         else
   //            intr_pending <= 1'b1;   // pend and wait
   //      end else if (intr_pending && intr_insert_condition) begin
   //         // pending interrupt inserted when condition satisfied, clear pending
   //         intr_pending <= 1'b0;
   //      end
   //   end
   //end
   // exc_vld_e_reg.din now uses intr_to_insert condition, but ensure it's inserted only once
   // Note: when intr_pending and intr_insert_condition are both active, insertion signal should be generated and pending cleared.


   //
   // Registers
   //

   // Only LSU operations and common pipeline registers (pc, wen, rd, etc.)
   // are affected by stalls. Other units continue execution normally.
   wire reg_en_m = ~stall_reg_mw;
   wire reg_en_e = ~stall_reg_mw;

   // exc
   dff_ns #(1) exc_vld_e_reg (
      // origitnal exception ready to issue | a valid non-exception instrution
      //                                      inserted with the interruption
      .din ((ifu_exu_exc_vld_d & ifu_exu_vld_d & ~flush) | (ifu_exu_vld_d & ~ifu_exu_exc_vld_d & ~flush & intr_pulse)),
      //.din ((ifu_exu_exc_vld_d & ifu_exu_vld_d & ~flush) | (ifu_exu_vld_d & ~ifu_exu_exc_vld_d & ~flush & intr_to_insert)),
      .clk (clk),
      .q   (exc_vld_e));

   dff_ns #(6) exc_code_e_reg (
      .din (intr_pulse ? 6'h00 : ifu_exu_exc_code_d), // EXC_INT 6'h00
      .clk (clk),
      .q   (exc_code_e));

   dff_ns #(9) exc_subcode_e_reg (
      .din (ifu_exu_exc_subcode_d),
      .clk (clk),
      .q   (exc_subcode_e));

   dff_ns #(32) exc_badv_e_reg (
      .din (ifu_exu_exc_badv_d),
      .clk (clk),
      .q   (exc_badv_e));
   
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

   dff_ns #(9) exc_subcode_m_reg (
      .din (exc_subcode_e), 
      .clk (clk),
      .q   (exc_subcode_m));

   dff_ns #(32) exc_badv_m_reg (
      .din (exc_badv_e),
      .clk (clk),
      .q   (exc_badv_m));


   //
   // Exception valid, code, and BADV merging
   //
   // Note: The registers exc_vld_w, exc_code_w, and exc_badv_w are not
   //       required to hold their values across multiple cycles, because:
   //       Any exception that occurs before lsu_except_buserr_ls3 will
   //       either block the LSU request or terminate the LSU process 
   //       immediately (e.g., ALE exception).
   //
   //wire exc_vld_merge_m = exc_vld_m | lsu_except_ale_m | lsu_except_buserr_ls3;
   //wire exc_vld_merge_m = exc_vld_m | lsu_except_ale_m | lsu_except_buserr_ls3 | lsu_except_tlbr_ls2;
   wire exc_vld_merge_m = exc_vld_m | lsu_except_ale_m | lsu_except_buserr_ls3 | lsu_except_tlb_related_ls2;

   dff_ns #(1) exc_vld_w_reg (
      .din (exc_vld_merge_m),
      .clk (clk),
      .q   (exc_vld_w));


//   wire [5:0] exc_code_merge_m = lsu_except_buserr_ls3 ? 6'h08 :  // EXC_ADEF/EXC_ADEM
//                                 lsu_except_ale_m      ? 6'h09 :  // EXC_ALE
//	                                                 exc_code_m;
   wire [5:0] exc_code_merge_m = lsu_except_buserr_ls3 ? 6'h08 :    // EXC_ADEM
                                  lsu_except_ale_m      ? 6'h09 :   // EXC_ALE
                                  lsu_except_tlbr_ls2   ? 6'h3f :   // EXC_TLBR
                                  lsu_except_pil_ls2    ? 6'h01 :   // EXC_PIL
                                  lsu_except_pis_ls2    ? 6'h02 :   // EXC_PIS
                                  lsu_except_ppi_ls2    ? 6'h07 :   // EXC_PPI
                                  lsu_except_pme_ls2    ? 6'h04 :   // EXC_PME
                                  exc_code_m;						 
                       
   dff_ns #(6) exc_code_w_reg (
      .din (exc_code_merge_m),
      .clk (clk),
      .q   (exc_code_w));


   //wire [8:0] exc_subcode_merge_m = lsu_except_tlbr_ls2 | lsu_except_pil_ls2 | lsu_except_pis_ls2 | lsu_except_pme_ls2 ? 1'b1 : exc_subcode_m;
   wire [8:0] exc_subcode_merge_m = (lsu_except_tlb_related_ls2 | lsu_except_buserr_ls3) ? 1'b1 : exc_subcode_m;  // ADEM subcode 0x1

   dff_ns #(9) exc_subcode_w_reg (
      .din (exc_subcode_merge_m),
      .clk (clk),
      .q   (exc_subcode_w));

//   wire [31:0] exc_badv_merge_m = lsu_except_buserr_ls3 ? lsu_except_buserr_badv_ls3 :
//                                  lsu_except_ale_m      ? lsu_except_ale_badv_m :
//	                                                  exc_badv_m;
   wire [31:0] exc_badv_merge_m = lsu_except_buserr_ls3 ? lsu_except_buserr_badv_ls3 :
                                  lsu_except_ale_m      ? lsu_except_ale_badv_m :
                                  lsu_except_tlbr_ls2   ? lsu_except_tlbr_badv_ls2 :   // should optimize,
                                  lsu_except_pil_ls2    ? lsu_except_pil_badv_ls2 :    // tlb related badv are all lsu_addr_ls2
                                  lsu_except_pis_ls2    ? lsu_except_pis_badv_ls2 :
                                  lsu_except_ppi_ls2    ? lsu_except_ppi_badv_ls2 :
                                  lsu_except_pme_ls2    ? lsu_except_pme_badv_ls2 :
                                  exc_badv_m;

   dff_ns #(32) exc_badv_w_reg (
      .din (exc_badv_merge_m),
      .clk (clk),
      .q   (exc_badv_w));

   //
   dff_ns #(32) pc_e_reg (
      .din (ifu_exu_pc_d),
      .clk (clk),
      .q   (pc_e));

   // pc_m must be valid because pc_w is written to CSR.era at write-back
   // stage
   dffe_ns #(32) pc_m_reg (
      .din (pc_e),
      .clk (clk),
      .en  (reg_en_e & vld_e),
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
      .din (rd_e & {5{~exc_vld_e}}),
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
      .din (ifu_exu_wen_d & good_to_issue),
      .clk (clk),
      .rst_l (resetn),
      .q   (wen_e));

   dffrle_ns #(1) wen_m_reg (
      .din (wen_e & ~exc_vld_e),
      .clk (clk),
      .en  (reg_en_e),
      .rst_l (resetn),
      .q   (wen_m));

   dffrle_ns #(1) wen_w_reg (
      .din (wen_m & ~exc_vld_merge_m), // only when no exception
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
      .din (ifu_exu_alu_vld_d & good_to_issue),
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
      .din (ifu_exu_lsu_vld_d & good_to_issue),
      .clk (clk),
      .rst_l (resetn),
      .q   (lsu_vld_e));

   dff_ns #(1) lsu_ibar_e_reg (
      .din (ifu_exu_lsu_ibar_d),
      .clk (clk),
      .q   (lsu_ibar_e));

   dff_ns #(1) lsu_idbar_e_reg (
      .din (ifu_exu_lsu_dbar_d),
      .clk (clk),
      .q   (lsu_dbar_e));

   dff_ns #(7) lsu_op_e_reg (
      .din (ifu_exu_lsu_op_d),
      .clk (clk),
      .q   (lsu_op_e));

   dff_ns #(1) lsu_double_read_e_reg (
      .din (ifu_exu_lsu_double_read_d),
      .clk (clk),
      .q   (lsu_double_read_e));

   // e equvalent to ls1, for lsu instructions that raise ale, lsu will not stall 
   dff_ns #(1) lsu_except_ale_m_reg (
      .din (lsu_except_ale_ls1),
      .clk (clk),
      //.en  (reg_en_m), // ale should not affected by alu stall itself 
      .q   (lsu_except_ale_m));

   dff_ns #(32) lsu_except_badv_m_reg (
      .din (lsu_except_ale_badv_ls1),
      .clk (clk),
      .q   (lsu_except_ale_badv_m));

   // _ls1 = _e 
   dff_ns #(1) lsu_sc_fin_m_reg (
      .din (lsu_ecl_sc_fin_ls1),
      .clk (clk),
      .q   (lsu_sc_fin_m));

   // bru
   dff_ns #(1) bru_vld_e_reg (
      .din (ifu_exu_bru_vld_d & good_to_issue),
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
      .din (ifu_exu_mul_vld_d & good_to_issue),
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

   // div
   dff_ns #(1) div_vld_e_reg (
      .din (ifu_exu_div_vld_d & good_to_issue),
      .clk (clk),
      .q   (div_vld_e));

   dffe_ns #(1) div_vld_m_reg (
      .din (div_vld_e),
      .clk (clk),
      .en  (reg_en_e),
      .q   (div_vld_m));

   dff_ns #(1) div_signed_e_reg (
      .din (ifu_exu_div_signed_d),
      .clk (clk),
      .q   (div_signed_e));

   dff_ns #(1) div_mod_e_reg (
      .din (ifu_exu_div_mod_d),
      .clk (clk),
      .q   (div_mod_e));

   dffe_ns #(1) div_mod_m_reg (
      .din (div_mod_e),
      .clk (clk),
      .en  (reg_en_e),
      .q   (div_mod_m));

   // csr
   //
   // CSR register updates are not affected by CSR stalls.
   // CSR stalls only block IFU for 2 cycles to prevent instruction fetch.
   dffrl_ns #(1) csr_vld_e_reg (
      .din (ifu_exu_csr_vld_d & good_to_issue),
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
      .din (ifu_exu_csr_wen_d & good_to_issue),
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
      .din (ifu_exu_ertn_vld_d & good_to_issue),
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

   // tlb
   dffrl_ns #(1) tlb_vld_e_reg (
      .din (ifu_exu_tlb_vld_d & good_to_issue),
      .clk (clk),
      .rst_l (resetn),
      .q   (tlb_vld_e));

   dff_ns #(4) tlb_op_e_reg (
      .din (ifu_exu_tlb_op_d),
      .clk (clk),
      .q   (tlb_op_e));

endmodule
