//altera message_off 10036

// Warning (10036): Verilog HDL or VHDL warning at c7bexu_rf.v(32): object "r0" assigned a value but never read
// Warning (10036): Verilog HDL or VHDL warning at c7bexu_rf.v(32): object "r1" assigned a value but never read
// Warning (10036): Verilog HDL or VHDL warning at c7bexu_rf.v(32): object "r2" assigned a value but never read

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

    wire [31:0] r0, r1, r2, r3, r4, r5, r6, r7;
    wire [31:0] r8, r9, r10, r11, r12, r13, r14, r15;
    wire [31:0] r16, r17, r18, r19, r20, r21, r22, r23;
    wire [31:0] r24, r25, r26, r27, r28, r29, r30, r31;

    // for debug purposes
    assign r0 = regs[0];
    assign r1 = regs[1];
    assign r2 = regs[2];
    assign r3 = regs[3];
    assign r4 = regs[4];
    assign r5 = regs[5];
    assign r6 = regs[6];
    assign r7 = regs[7];
    assign r8 = regs[8];
    assign r9 = regs[9];
    assign r10 = regs[10];
    assign r11 = regs[11];
    assign r12 = regs[12];
    assign r13 = regs[13];
    assign r14 = regs[14];
    assign r15 = regs[15];
    assign r16 = regs[16];
    assign r17 = regs[17];
    assign r18 = regs[18];
    assign r19 = regs[19];
    assign r20 = regs[20];
    assign r21 = regs[21];
    assign r22 = regs[22];
    assign r23 = regs[23];
    assign r24 = regs[24];
    assign r25 = regs[25];
    assign r26 = regs[26];
    assign r27 = regs[27];
    assign r28 = regs[28];
    assign r29 = regs[29];
    assign r30 = regs[30];
    assign r31 = regs[31];

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
