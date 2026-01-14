add wave -position end  result:/top_tb/clk
add wave -position end  result:/top_tb/resetn

add wave -divider
add wave -position end  result:/top_tb/ifu_exu_pc_d
add wave -position end  result:/top_tb/ifu_exu_rd_d
add wave -position end  result:/top_tb/ifu_exu_rs1_d
add wave -position end  result:/top_tb/ifu_exu_rs2_d
add wave -position end  result:/top_tb/ifu_exu_vld_d
add wave -position end  result:/top_tb/ifu_exu_wen_d
add wave -divider
add wave -position end  result:/top_tb/ifu_exu_lsu_double_read_d
add wave -position end  result:/top_tb/ifu_exu_lsu_op_d
add wave -position end  result:/top_tb/ifu_exu_lsu_vld_d
add wave -divider
add wave -position end  result:/top_tb/u_dut/flush
add wave -position end  result:/top_tb/u_dut/exu_ifu_branch
add wave -position end  result:/top_tb/u_dut/exu_ifu_ertn
add wave -position end  result:/top_tb/u_dut/exu_ifu_stall
add wave -position end  result:/top_tb/u_dut/exu_ifu_except
add wave -position end  result:/top_tb/u_dut/stall
add wave -position end  result:/top_tb/u_dut/u_ecl/csr_stall
add wave -position end  result:/top_tb/u_dut/u_ecl/lsu_stall
add wave -position end  result:/top_tb/u_dut/u_ecl/lsu_stall_in
add wave -position end  result:/top_tb/u_dut/u_ecl/lsu_stall_q
add wave -position end  result:/top_tb/u_dut/u_ecl/lsu_bgn
add wave -position end  result:/top_tb/u_dut/u_ecl/lsu_end
add wave -position end  result:/top_tb/u_dut/u_ecl/lsu_except_ale_ls1
add wave -position end  result:/top_tb/u_dut/u_ecl/lsu_except_buserr_ls3
add wave -position end  result:/top_tb/u_dut/u_ecl/lsu_except_ecc_ls3
add wave -position end  result:/top_tb/u_dut/u_ecl/lsu_data_valid_ls3
add wave -position end  result:/top_tb/u_dut/u_ecl/lsu_wr_fin_ls3
add wave -divider
add wave -position end  result:/top_tb/u_dut/exc_code_comb_w
add wave -position end  result:/top_tb/u_dut/exc_code_e
add wave -position end  result:/top_tb/u_dut/exc_code_m
add wave -position end  result:/top_tb/u_dut/exc_code_w
add wave -position end  result:/top_tb/u_dut/exc_vld_comb_w
add wave -position end  result:/top_tb/u_dut/exc_vld_e
add wave -position end  result:/top_tb/u_dut/exc_vld_m
add wave -position end  result:/top_tb/u_dut/exc_vld_w
add wave -divider
add wave -position end  result:/top_tb/u_dut/lsu_base_e
add wave -position end  result:/top_tb/u_dut/lsu_biu_rd_addr
add wave -position end  result:/top_tb/u_dut/lsu_biu_rd_req
add wave -position end  result:/top_tb/u_dut/lsu_biu_wr_addr
add wave -position end  result:/top_tb/u_dut/lsu_biu_wr_data
add wave -position end  result:/top_tb/u_dut/lsu_biu_wr_req
add wave -position end  result:/top_tb/u_dut/lsu_biu_wr_strb
add wave -position end  result:/top_tb/u_dut/lsu_data_ls3
add wave -position end  result:/top_tb/u_dut/lsu_data_vld_ls3
add wave -position end  result:/top_tb/u_dut/lsu_double_read_e
add wave -position end  result:/top_tb/u_dut/lsu_except_ale_ls1
add wave -position end  result:/top_tb/u_dut/lsu_except_ale_w
add wave -position end  result:/top_tb/u_dut/lsu_except_badv_ls1
add wave -position end  result:/top_tb/u_dut/lsu_except_badv_w
add wave -position end  result:/top_tb/u_dut/lsu_except_buserr_ls3
add wave -position end  result:/top_tb/u_dut/lsu_except_ecc_ls3
add wave -position end  result:/top_tb/u_dut/lsu_offset_e
add wave -position end  result:/top_tb/u_dut/lsu_op_e
add wave -position end  result:/top_tb/u_dut/lsu_vld_e
add wave -position end  result:/top_tb/u_dut/lsu_wdata_e
add wave -position end  result:/top_tb/u_dut/lsu_wr_fin_ls3
add wave -divider
add wave -position end  result:/top_tb/u_dut/bru_branch_e
add wave -position end  result:/top_tb/u_dut/bru_branch_m
add wave -position end  result:/top_tb/u_dut/bru_branch_w
add wave -divider
add wave -position end  result:/top_tb/u_dut/reg_en_d
add wave -position end  result:/top_tb/u_dut/reg_en_m
add wave -divider
add wave -position end  result:/top_tb/u_dut/alu_a_e
add wave -position end  result:/top_tb/u_dut/alu_a_pc_e
add wave -position end  result:/top_tb/u_dut/alu_b_e
add wave -position end  result:/top_tb/u_dut/alu_b_imm_e
add wave -position end  result:/top_tb/u_dut/alu_c_e
add wave -position end  result:/top_tb/u_dut/alu_double_word_e
add wave -position end  result:/top_tb/u_dut/alu_op_e
add wave -position end  result:/top_tb/u_dut/alu_res_e
add wave -position end  result:/top_tb/u_dut/alu_res_m
add wave -position end  result:/top_tb/u_dut/alu_vld_e
add wave -position end  result:/top_tb/u_dut/alu_vld_m
add wave -divider
add wave -position end  result:/top_tb/pc_e
add wave -position end  result:/top_tb/pc_m
add wave -position end  result:/top_tb/pc_w
add wave -position end  result:/top_tb/u_dut/rs1_data_byp_e
add wave -position end  result:/top_tb/u_dut/rs2_data_byp_e
add wave -divider
add wave -position end  result:/top_tb/u_dut/wen_e
add wave -position end  result:/top_tb/u_dut/wen_m
add wave -position end  result:/top_tb/u_dut/wen_w
add wave -position end  result:/top_tb/u_dut/rd_e
add wave -position end  result:/top_tb/u_dut/rd_m
add wave -position end  result:/top_tb/u_dut/rd_w
add wave -position end  result:/top_tb/u_dut/reg_en_m
add wave -divider
add wave -position end  result:/top_tb/u_dut/lsu_biu_rd_addr
add wave -position end  result:/top_tb/u_dut/lsu_biu_rd_req
add wave -position end  result:/top_tb/u_dut/biu_lsu_data
add wave -position end  result:/top_tb/u_dut/biu_lsu_data_vld
add wave -position end  result:/top_tb/u_dut/biu_lsu_rd_ack
add wave -divider
add wave -position end  result:/top_tb/u_dut/rd_data_m
add wave -position end  result:/top_tb/u_dut/rd_data_w
add wave -divider
add wave -position end  result:/top_tb/u_dut/u_bru/bru_taken
add wave -position end  result:/top_tb/u_dut/u_bru/bru_target
add wave -position end  result:/top_tb/u_dut/exu_ifu_branch
add wave -position end  result:/top_tb/u_dut/exu_ifu_brn_addr
add wave -position end  result:/top_tb/u_dut/exu_ifu_ert_addr
add wave -position end  result:/top_tb/u_dut/exu_ifu_ertn
add wave -position end  result:/top_tb/u_dut/exu_ifu_except
add wave -position end  result:/top_tb/u_dut/exu_ifu_isr_addr
add wave -divider
