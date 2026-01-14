// register file for MIPS 32

module c7bexu_rf(
	input clk,
	input rst,

	input 	[ 4:0] 			waddr1,
	input 	[ 4:0] 			raddr0_0,
	input 	[ 4:0] 			raddr0_1,
	input 					wen1,
	input 	[31:0] 	wdata1,
	output 	[31:0] 	rdata0_0,
	output 	[31:0] 	rdata0_1,

	input 	[ 4:0] 			waddr2,
	input 	[ 4:0] 			raddr1_0,
	input 	[ 4:0] 			raddr1_1,
	input 					wen2,
	input 	[31:0] 	wdata2,
	output 	[31:0] 	rdata1_0,
	output 	[31:0] 	rdata1_1,

	input 	[ 4:0] 			raddr2_0,
	input 	[ 4:0] 			raddr2_1,
	output 	[31:0] 	rdata2_0,
	output 	[31:0] 	rdata2_1
);

  // registers (r0 excluded)
	reg [31:0] regs [31:0];

  // read after write (RAW)
  	wire r1_1_w1_raw =	wen1 && (raddr0_0 == waddr1);	
	wire r1_2_w1_raw =  wen1 && (raddr0_1 == waddr1);
  	wire r1_1_w2_raw =	wen2 && (raddr0_0 == waddr2);
	wire r1_2_w2_raw =  wen2 && (raddr0_1 == waddr2);

	wire r2_1_w1_raw =	wen1 && (raddr1_0 == waddr1);
	wire r2_2_w1_raw =  wen1 && (raddr1_1 == waddr1);
  	wire r2_1_w2_raw =	wen2 && (raddr1_0 == waddr2);
	wire r2_2_w2_raw =  wen2 && (raddr1_1 == waddr2);

	wire r3_1_w1_raw =	wen1 && (raddr2_0 == waddr1);	
	wire r3_2_w1_raw =  wen1 && (raddr2_1 == waddr1);
  	wire r3_1_w2_raw =	wen2 && (raddr2_0 == waddr2);
	wire r3_2_w2_raw =  wen2 && (raddr2_1 == waddr2);

	wire r1_1_raw = r1_1_w1_raw || r1_1_w2_raw;	// read port need forwarding
	wire r1_2_raw = r1_2_w1_raw || r1_2_w2_raw;
	wire r2_1_raw = r2_1_w1_raw || r2_1_w2_raw;
	wire r2_2_raw = r2_2_w1_raw || r2_2_w2_raw;
	wire r3_1_raw = r3_1_w1_raw || r3_1_w2_raw;
	wire r3_2_raw = r3_2_w1_raw || r3_2_w2_raw;

	wire [31:0]	r1_1_raw_data = r1_1_w2_raw ? wdata2 : wdata1;	// forwarding data
	wire [31:0]	r1_2_raw_data = r1_2_w2_raw ? wdata2 : wdata1;
	wire [31:0]	r2_1_raw_data = r2_1_w2_raw ? wdata2 : wdata1;
	wire [31:0]	r2_2_raw_data = r2_2_w2_raw ? wdata2 : wdata1;
	wire [31:0]	r3_1_raw_data = r3_1_w2_raw ? wdata2 : wdata1;
	wire [31:0]	r3_2_raw_data = r3_2_w2_raw ? wdata2 : wdata1;

  // write crash
	wire write_crash = (waddr1 == waddr2);
	wire wen1_input = (!write_crash || !wen2) && wen1;
	wire wen2_input	= wen2;

  // process read (r0 wired to 0)

	assign rdata0_0 = raddr0_0 == 0 ? 0 : r1_1_raw ? r1_1_raw_data : regs[raddr0_0];
	assign rdata0_1 = raddr0_1 == 0 ? 0 : r1_2_raw ? r1_2_raw_data : regs[raddr0_1];

	assign rdata1_0 = raddr1_0 == 0 ? 0 : r2_1_raw ? r2_1_raw_data : regs[raddr1_0];
	assign rdata1_1 = raddr1_1 == 0 ? 0 : r2_2_raw ? r2_2_raw_data : regs[raddr1_1];

	assign rdata2_0 = raddr2_0 == 0 ? 0 : r3_1_raw ? r3_1_raw_data : regs[raddr2_0];
	assign rdata2_1 = raddr2_1 == 0 ? 0 : r3_2_raw ? r3_2_raw_data : regs[raddr2_1];

  // process write
	always @(posedge clk) begin
		 if(rst) begin
		 	regs[31] <= 32'd0;
		 	regs[30] <= 32'd0;
		 	regs[29] <= 32'd0;
		 	regs[28] <= 32'd0;
		 	regs[27] <= 32'd0;
		 	regs[26] <= 32'd0;
		 	regs[25] <= 32'd0;
		 	regs[24] <= 32'd0;
		 	regs[23] <= 32'd0;
		 	regs[22] <= 32'd0;
		 	regs[21] <= 32'd0;
		 	regs[20] <= 32'd0;
		 	regs[19] <= 32'd0;
		 	regs[18] <= 32'd0;
		 	regs[17] <= 32'd0;
		 	regs[16] <= 32'd0;
		 	regs[15] <= 32'd0;
		 	regs[14] <= 32'd0;
		 	regs[13] <= 32'd0;
		 	regs[12] <= 32'd0;
		 	regs[11] <= 32'd0;
		 	regs[10] <= 32'd0;
		 	regs[9] <= 32'd0;
		 	regs[8] <= 32'd0;
		 	regs[7] <= 32'd0;
		 	regs[6] <= 32'd0;
		 	regs[5] <= 32'd0;
		 	regs[4] <= 32'd0;
		 	regs[3] <= 32'd0;
		 	regs[2] <= 32'd0;
		 	regs[1] <= 32'd0;
		 	regs[0] <= 32'd0;

		 end
		 else begin
			case({wen1_input,wen2_input}) 
					2'b11:begin   
					   regs[waddr1] <= wdata1; 
					   regs[waddr2] <= wdata2; 
					   end
				  	2'b10:regs[waddr1] <= wdata1;
					2'b01:regs[waddr2] <= wdata2;
					default:	;
			endcase
		 end
	end
	
endmodule
