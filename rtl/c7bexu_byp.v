module c7bexu_byp (
   input  [4:0]       rs1_e,
   input  [4:0]       rs2_e,
   input  [4:0]       rd_m,
   input  [4:0]       rd_w,
   input              wen_m,
   input              wen_w,
   input  [31:0]      rs1_data_e,
   input  [31:0]      rs2_data_e,
   input  [31:0]      rd_data_m,
   input  [31:0]      rd_data_w,
   output [31:0]      rs1_data_byp_e,
   output [31:0]      rs2_data_byp_e
);

   wire rs1_mux_sel_rf;
   wire rs1_mux_sel_m;
   wire rs1_mux_sel_w;

   wire rs2_mux_sel_rf;
   wire rs2_mux_sel_m;
   wire rs2_mux_sel_w;

   c7bexu_byplog u_byplog_rs1(
      .rs_e                            (rs1_e[4:0]),
      .rd_m                            (rd_m[4:0]),
      .rd_w                            (rd_w[4:0]),
      .wen_m                           (wen_m),
      .wen_w                           (wen_w),

      .rs_mux_sel_rf                   (rs1_mux_sel_rf),
      .rs_mux_sel_m                    (rs1_mux_sel_m),
      .rs_mux_sel_w                    (rs1_mux_sel_w)
      );

   c7bexu_byplog u_byplog_rs2(
      .rs_e                            (rs2_e[4:0]),
      .rd_m                            (rd_m[4:0]),
      .rd_w                            (rd_w[4:0]),
      .wen_m                           (wen_m),
      .wen_w                           (wen_w),

      .rs_mux_sel_rf                   (rs2_mux_sel_rf),
      .rs_mux_sel_m                    (rs2_mux_sel_m),
      .rs_mux_sel_w                    (rs2_mux_sel_w)
      );

   mux3ds #(32) mux_rs1_data (
      .dout(rs1_data_byp_e),
      .in0(rs1_data_e),
      .in1(rd_data_m),
      .in2(rd_data_w),
      .sel0(rs1_mux_sel_rf),
      .sel1(rs1_mux_sel_m),
      .sel2(rs1_mux_sel_w)
      );

   mux3ds #(32) mux_rs2_data (
      .dout(rs2_data_byp_e),
      .in0(rs2_data_e),
      .in1(rd_data_m),
      .in2(rd_data_w),
      .sel0(rs2_mux_sel_rf),
      .sel1(rs2_mux_sel_m),
      .sel2(rs2_mux_sel_w)
      );

endmodule
