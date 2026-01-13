module c7bexu_byplog (
   input  [4:0]       rs_e,
   input  [4:0]       rd_m,
   input  [4:0]       rd_w,
   input              wen_m,
   input              wen_w,

   output             rs_mux_sel_rf,
   output             rs_mux_sel_m,
   output             rs_mux_sel_w
   );

   wire match_m;
   wire match_w;
   wire rs_is_nonzero;
   wire bypass_m;
   wire bypass_w;
   wire use_m;
   wire use_w;
   wire use_rf;
   
   assign match_m = (rs_e[4:0] == rd_m[4:0]);
   assign match_w = (rs_e[4:0] == rd_w[4:0]);

   assign rs_is_nonzero = rs_e[0]|rs_e[1]|rs_e[2]|rs_e[3]|rs_e[4];

   assign bypass_m = wen_m;
   assign bypass_w = wen_w;

   assign use_m = match_m & bypass_m & rs_is_nonzero;
   assign use_w = match_w & bypass_w & rs_is_nonzero & ~use_m;

   assign use_rf = ~use_w & ~use_m;

   assign rs_mux_sel_m = use_m;
   assign rs_mux_sel_w = use_w;
   assign rs_mux_sel_rf = use_rf;
   
endmodule // c7bexu_byplog
