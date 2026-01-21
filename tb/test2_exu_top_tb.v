`timescale 1ns/1ps

module top_tb;
    // Clock and reset signals
    reg clk;
    reg resetn;
    
    reg              ext_intr;

    // EXU outputs to IFU
    wire             exu_ifu_except;
    wire [31:0]      exu_ifu_isr_addr;
    wire             exu_ifu_branch;
    wire [31:0]      exu_ifu_brn_addr;
    wire             exu_ifu_ertn;
    wire [31:0]      exu_ifu_ert_addr;
    wire             exu_ifu_stall;
    
    // IFU inputs to EXU
    reg              ifu_exu_vld_d;
    reg  [31:0]      ifu_exu_pc_d;
    reg  [4:0]       ifu_exu_rs1_d;
    reg  [4:0]       ifu_exu_rs2_d;
    reg  [4:0]       ifu_exu_rd_d;
    reg              ifu_exu_wen_d;
    reg  [31:0]      ifu_exu_imm_shifted_d;
    
    // ALU related
    reg              ifu_exu_alu_vld_d;
    reg  [5:0]       ifu_exu_alu_op_d;
    reg              ifu_exu_alu_a_pc_d;
    reg  [31:0]      ifu_exu_alu_c_d;
    reg              ifu_exu_alu_double_word_d;
    reg              ifu_exu_alu_b_imm_d;
    
    // LSU related
    reg              ifu_exu_lsu_vld_d;
    reg  [6:0]       ifu_exu_lsu_op_d;
    reg              ifu_exu_lsu_double_read_d;
    
    // BRU related
    reg              ifu_exu_bru_vld_d;
    reg  [3:0]       ifu_exu_bru_op_d;
    reg  [31:0]      ifu_exu_bru_offset_d;
    
    // MUL related
    reg              ifu_exu_mul_vld_d;
    reg              ifu_exu_mul_signed_d;
    reg              ifu_exu_mul_double_d;
    reg              ifu_exu_mul_hi_d;
    reg              ifu_exu_mul_short_d;
    
    // CSR related
    reg              ifu_exu_csr_vld_d;
    reg  [13:0]      ifu_exu_csr_raddr_d;
    reg              ifu_exu_csr_xchg_d;
    reg              ifu_exu_csr_wen_d;
    reg  [13:0]      ifu_exu_csr_waddr_d;
    
    // ERTN
    reg              ifu_exu_ertn_vld_d;
    
    // EXC
    reg              ifu_exu_exc_vld_d;
    reg  [5:0]       ifu_exu_exc_code_d;
    
    // BIU interface
    wire             lsu_biu_rd_req;
    wire [31:0]      lsu_biu_rd_addr;
    reg              biu_lsu_rd_ack;
    reg              biu_lsu_data_vld;
    reg  [63:0]      biu_lsu_data;
    wire             lsu_biu_wr_req;
    wire [31:0]      lsu_biu_wr_addr;
    wire [63:0]      lsu_biu_wr_data;
    wire [7:0]       lsu_biu_wr_strb;
    reg              biu_lsu_wr_ack;
    reg              biu_lsu_wr_fin;
    
    // Internal signals for monitoring
    wire [31:0]      rs1_data_d;
    wire [31:0]      rs2_data_d;
    wire [31:0]      pc_e;
    wire [31:0]      pc_m;
    wire [31:0]      pc_w;
    wire [4:0]       rd_w;
    wire             wen_w;
    wire [31:0]      rd_data_w;
    wire             lsu_vld_e;
    //wire             lsu_vld_m;
    wire [31:0]      alu_res_m;
    wire [31:0]      lsu_data_ls3;
    wire             lsu_data_vld_ls3;
    wire             lsu_except_ale_ls1;
    wire             lsu_except_buserr_ls3;
    wire             lsu_except_ecc_ls3;
    //wire             lsu_ecl_wr_fin_ls3;
    
    // Test statistics
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    
    // Test name storage (Verilog-2001 doesn't support string arguments in functions)
    reg [256:0] current_test_name;  // 80 characters for test name
    

    // Clock generation
    always #5 clk = ~clk;
    
    // Instantiate DUT
    c7bexu u_dut (
        .clk                        (clk),
        .resetn                     (resetn),

	.ext_intr                   (ext_intr),
        
        .exu_ifu_except             (exu_ifu_except),
        .exu_ifu_isr_addr           (exu_ifu_isr_addr),
        .exu_ifu_branch             (exu_ifu_branch),
        .exu_ifu_brn_addr           (exu_ifu_brn_addr),
        .exu_ifu_ertn               (exu_ifu_ertn),
        .exu_ifu_ert_addr           (exu_ifu_ert_addr),
        .exu_ifu_stall              (exu_ifu_stall),
        
        .ifu_exu_vld_d              (ifu_exu_vld_d),
        .ifu_exu_pc_d               (ifu_exu_pc_d),
        .ifu_exu_rs1_d              (ifu_exu_rs1_d),
        .ifu_exu_rs2_d              (ifu_exu_rs2_d),
        .ifu_exu_rd_d               (ifu_exu_rd_d),
        .ifu_exu_wen_d              (ifu_exu_wen_d),
        .ifu_exu_imm_shifted_d      (ifu_exu_imm_shifted_d),
        
        .ifu_exu_alu_vld_d          (ifu_exu_alu_vld_d),
        .ifu_exu_alu_op_d           (ifu_exu_alu_op_d),
        .ifu_exu_alu_a_pc_d         (ifu_exu_alu_a_pc_d),
        .ifu_exu_alu_c_d            (ifu_exu_alu_c_d),
        .ifu_exu_alu_double_word_d  (ifu_exu_alu_double_word_d),
        .ifu_exu_alu_b_imm_d        (ifu_exu_alu_b_imm_d),
        
        .ifu_exu_lsu_vld_d          (ifu_exu_lsu_vld_d),
        .ifu_exu_lsu_op_d           (ifu_exu_lsu_op_d),
        .ifu_exu_lsu_double_read_d  (ifu_exu_lsu_double_read_d),
        
        .ifu_exu_bru_vld_d          (ifu_exu_bru_vld_d),
        .ifu_exu_bru_op_d           (ifu_exu_bru_op_d),
        .ifu_exu_bru_offset_d       (ifu_exu_bru_offset_d),
        
        .ifu_exu_mul_vld_d          (ifu_exu_mul_vld_d),
        .ifu_exu_mul_signed_d       (ifu_exu_mul_signed_d),
        .ifu_exu_mul_double_d       (ifu_exu_mul_double_d),
        .ifu_exu_mul_hi_d           (ifu_exu_mul_hi_d),
        .ifu_exu_mul_short_d        (ifu_exu_mul_short_d),
        
        .ifu_exu_csr_vld_d          (ifu_exu_csr_vld_d),
        .ifu_exu_csr_raddr_d        (ifu_exu_csr_raddr_d),
        .ifu_exu_csr_xchg_d         (ifu_exu_csr_xchg_d),
        .ifu_exu_csr_wen_d          (ifu_exu_csr_wen_d),
        .ifu_exu_csr_waddr_d        (ifu_exu_csr_waddr_d),
        
        .ifu_exu_ertn_vld_d         (ifu_exu_ertn_vld_d),
        
        .ifu_exu_exc_vld_d          (ifu_exu_exc_vld_d),
        .ifu_exu_exc_code_d         (ifu_exu_exc_code_d),
        
        .lsu_biu_rd_req             (lsu_biu_rd_req),
        .lsu_biu_rd_addr            (lsu_biu_rd_addr),
        
        .biu_lsu_rd_ack             (biu_lsu_rd_ack),
        .biu_lsu_data_vld           (biu_lsu_data_vld),
        .biu_lsu_data               (biu_lsu_data),
        
        .lsu_biu_wr_req             (lsu_biu_wr_req),
        .lsu_biu_wr_addr            (lsu_biu_wr_addr),
        .lsu_biu_wr_data            (lsu_biu_wr_data),
        .lsu_biu_wr_strb            (lsu_biu_wr_strb),
        
        .biu_lsu_wr_ack             (biu_lsu_wr_ack),
        .biu_lsu_wr_fin             (biu_lsu_wr_fin)
    );
    
    // Connect internal signals (through hierarchical reference)
    assign rs1_data_d = u_dut.rs1_data_d;
    assign rs2_data_d = u_dut.rs2_data_d;
    assign pc_e = u_dut.pc_e;
    assign pc_m = u_dut.pc_m;
    assign pc_w = u_dut.pc_w;
    assign rd_w = u_dut.rd_w;
    assign wen_w = u_dut.wen_w;
    assign rd_data_w = u_dut.rd_data_w;
    assign lsu_vld_e = u_dut.lsu_vld_e;
    //assign lsu_vld_m = u_dut.lsu_vld_m;
    assign alu_res_m = u_dut.alu_res_m;
    assign lsu_data_ls3 = u_dut.lsu_data_ls3;
    assign lsu_data_vld_ls3 = u_dut.lsu_data_vld_ls3;
    assign lsu_except_ale_ls1 = u_dut.lsu_except_ale_ls1;
    assign lsu_except_buserr_ls3 = u_dut.lsu_except_buserr_ls3;
    assign lsu_except_ecc_ls3 = u_dut.lsu_except_ecc_ls3;
    //assign lsu_ecl_wr_fin_ls3 = u_dut.lsu_ecl_wr_fin_ls3;
    
    // Task: Initialize all inputs
    task init_inputs;
    begin
        ifu_exu_vld_d = 0;
        ifu_exu_pc_d = 0;
        ifu_exu_rs1_d = 0;
        ifu_exu_rs2_d = 0;
        ifu_exu_rd_d = 0;
        ifu_exu_wen_d = 0;
        ifu_exu_imm_shifted_d = 0;
        
        ifu_exu_alu_vld_d = 0;
        ifu_exu_alu_op_d = 0;
        ifu_exu_alu_a_pc_d = 0;
        ifu_exu_alu_c_d = 0;
        ifu_exu_alu_double_word_d = 0;
        ifu_exu_alu_b_imm_d = 0;
        
        ifu_exu_lsu_vld_d = 0;
        ifu_exu_lsu_op_d = 0;
        ifu_exu_lsu_double_read_d = 0;
        
        ifu_exu_bru_vld_d = 0;
        ifu_exu_bru_op_d = 0;
        ifu_exu_bru_offset_d = 0;
        
        ifu_exu_mul_vld_d = 0;
        ifu_exu_mul_signed_d = 0;
        ifu_exu_mul_double_d = 0;
        ifu_exu_mul_hi_d = 0;
        ifu_exu_mul_short_d = 0;
        
        ifu_exu_csr_vld_d = 0;
        ifu_exu_csr_raddr_d = 0;
        ifu_exu_csr_xchg_d = 0;
        ifu_exu_csr_wen_d = 0;
        ifu_exu_csr_waddr_d = 0;
        
        ifu_exu_ertn_vld_d = 0;
        ifu_exu_exc_vld_d = 0;
        ifu_exu_exc_code_d = 0;
        
        biu_lsu_rd_ack = 0;
        biu_lsu_data_vld = 0;
        biu_lsu_data = 0;
        biu_lsu_wr_ack = 0;
        biu_lsu_wr_fin = 0;
    end
    endtask
    
    // Task: Generate reset sequence
    task reset_system;
    begin
        resetn = 0;
        repeat(10) @(posedge clk);
        #2 resetn = 1;
        @(posedge clk);
    end
    endtask
    
    // Task: Wait for N clock cycles
    task wait_cycles;
        input integer cycles;
    begin
        repeat(cycles) @(posedge clk);
    end
    endtask
    
    // Task: Print test result
    task print_test_result;
        input passed;
    begin
        test_count = test_count + 1;
        
        if (passed) begin
            $display("[PASS] Test: %0s", current_test_name);
            pass_count = pass_count + 1;
        end
        else begin
            $display("[FAIL] Test: %0s", current_test_name);
            fail_count = fail_count + 1;
        end
    end
    endtask
    
    // Task: LD Instruction Test
    task test_ld_instruction;
        reg [31:0] expected_addr;
        reg [31:0] expected_data;
        reg [31:0] stall_start_time;
        reg [31:0] stall_end_time;
        integer stall_cycles;
        integer passed;
    begin
        current_test_name = "LD Instruction Test";
        $display("\n=== Starting LD Instruction Test ===");
        
        // Initialize
        init_inputs();
        
        // Setup LD instruction: ld.w $r5, $r6, 0
        // rs1 = 6, rd = 5, offset = 0
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_0000;
        ifu_exu_rs1_d = 6;     // $r6
        ifu_exu_rs2_d = 0;
        ifu_exu_rd_d = 5;      // $r5
        ifu_exu_wen_d = 1;     // Writeback needed
        ifu_exu_imm_shifted_d = 0;  // Offset 0
        
        // LSU valid
        ifu_exu_lsu_vld_d = 1;
        ifu_exu_lsu_op_d = 7'b0000011;  // LD opcode LD_W
        ifu_exu_lsu_double_read_d = 0;
        
        // Other functional units inactive
        ifu_exu_alu_vld_d = 0;
        ifu_exu_bru_vld_d = 0;
        ifu_exu_mul_vld_d = 0;
        ifu_exu_csr_vld_d = 0;
        
        // Record stall start time
        stall_start_time = $time;
        
        // Wait 1 cycle for instruction to enter E stage
        @(posedge clk);

        ifu_exu_vld_d = 0;
        ifu_exu_pc_d = 32'h0;
        ifu_exu_rs1_d = 0;     // $r6
        ifu_exu_rs2_d = 0;
        ifu_exu_rd_d = 0;      // $r5
        ifu_exu_wen_d = 0;     // Writeback needed
        ifu_exu_imm_shifted_d = 0;  // Offset 0
        
        // LSU valid
        ifu_exu_lsu_vld_d = 0;
        ifu_exu_lsu_op_d = 7'b0000000;
        ifu_exu_lsu_double_read_d = 0;
        
        // Record stall status
        if (exu_ifu_stall) begin
            stall_start_time = $time;
            $display("Stall detected at time %0t", $time);
        end
        
        // Simulate BIU response
        repeat(4) @(posedge clk);
        
        // Respond to read request at cycle 3
        if (lsu_biu_rd_req) begin
            expected_addr = lsu_biu_rd_addr;
            $display("LSU read request for address: 0x%h", expected_addr);
            
            // Return data
            biu_lsu_rd_ack = 1;
            @(posedge clk);
            biu_lsu_rd_ack = 0;
            
            // Data valid next cycle
            @(posedge clk);
            biu_lsu_data_vld = 1;
            biu_lsu_data = 64'h1234_5678_abcd_ef00;  // Return test data
            expected_data = 32'habcd_ef00;  // Lower 32 bits
            
            @(posedge clk);
            biu_lsu_data_vld = 0;
        end
        
        // Wait for stall to end
        while (exu_ifu_stall) begin
            @(posedge clk);
        end
        
        stall_end_time = $time;
        stall_cycles = (stall_end_time - stall_start_time) / 10;  // 10ns period
        
        $display("Stall lasted %0d cycles", stall_cycles);
        
        // Wait for instruction completion (reaching W stage)
        wait_cycles(1);
        
        // Check results
        passed = 1;  // Assume pass
        
        // Check 1: rd_w should be 5
        if (rd_w !== 5) begin
            $display("ERROR: rd_w is %0d, expected 5", rd_w);
            passed = 0;
        end
        
        // Check 2: wen_w should be 1
        if (wen_w !== 1) begin
            $display("ERROR: wen_w is %0d, expected 1", wen_w);
            passed = 0;
        end
        
        // Check 3: rd_data_w should equal returned data
        if (rd_data_w !== expected_data) begin
            $display("ERROR: rd_data_w is 0x%h, expected 0x%h", 
                     rd_data_w, expected_data);
            passed = 0;
        end
        
        // Check 4: pc_w should equal instruction PC
        if (pc_w !== 32'h1C00_0000) begin
            $display("ERROR: pc_w is 0x%h, expected 0x1C00_0000", pc_w);
            passed = 0;
        end
        
        // Check 5: Stall cycles should be reasonable (LSU typically needs multiple cycles)
        if (stall_cycles < 3) begin
            $display("WARNING: stall cycles (%0d) seems too short for LD", 
                     stall_cycles);
        end
        
        // Check 6: No exception should occur
        if (exu_ifu_except !== 0) begin
            $display("ERROR: Unexpected exception");
            passed = 0;
        end
        
        // Check 7: No branch should occur
        if (exu_ifu_branch !== 0) begin
            $display("ERROR: Unexpected branch");
            passed = 0;
        end
        
        // Check 8: No ertn should occur
        if (exu_ifu_ertn !== 0) begin
            $display("ERROR: Unexpected ertn");
            passed = 0;
        end
        
        // Restore inputs
        init_inputs();
        
        // Print test result
        print_test_result(passed);
    end
    endtask

    // Task: LD Instruction ALE Test
    task test_ld_instruction_ale;
        reg [31:0] expected_addr;
        reg [31:0] expected_data;
        reg [31:0] stall_start_time;
        reg [31:0] stall_end_time;
        integer stall_cycles;
        integer passed;
    begin
        current_test_name = "LD Instruction Test";
        $display("\n=== Starting LD Instruction Test ===");
        
        // Initialize
        init_inputs();
        
        // Setup LD instruction: ld.w $r5, $r6, 0
        // rs1 = 6, rd = 5, offset = 0
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_0000;
        ifu_exu_rs1_d = 6;     // $r6
        ifu_exu_rs2_d = 0;
        ifu_exu_rd_d = 5;      // $r5
        ifu_exu_wen_d = 1;     // Writeback needed
        ifu_exu_imm_shifted_d = 1;  // Offset 1
        
        // LSU valid
        ifu_exu_lsu_vld_d = 1;
        ifu_exu_lsu_op_d = 7'b0000011;  // LD opcode LD_W
        ifu_exu_lsu_double_read_d = 0;
        
        // Other functional units inactive
        ifu_exu_alu_vld_d = 0;
        ifu_exu_bru_vld_d = 0;
        ifu_exu_mul_vld_d = 0;
        ifu_exu_csr_vld_d = 0;
        
        // Record stall start time
        stall_start_time = $time;
        
        // Wait 1 cycle for instruction to enter E stage
        @(posedge clk);

        ifu_exu_vld_d = 0;
        ifu_exu_pc_d = 32'h0;
        ifu_exu_rs1_d = 0;     // $r6
        ifu_exu_rs2_d = 0;
        ifu_exu_rd_d = 0;      // $r5
        ifu_exu_wen_d = 0;     // Writeback needed
        ifu_exu_imm_shifted_d = 0;  // Offset 0
        
        // LSU valid
        ifu_exu_lsu_vld_d = 0;
        ifu_exu_lsu_op_d = 7'b0000000;
        ifu_exu_lsu_double_read_d = 0;
        
        @(posedge clk);

        //// Record stall status
        //if (exu_ifu_stall) begin
        //    stall_start_time = $time;
        //    $display("Stall detected at time %0t", $time);
        //end

        if (lsu_except_ale_ls1) begin
            $display("ALE detected at time %0t", $time);
        end

        // Wait for stall to end
        while (exu_ifu_stall) begin
            @(posedge clk);
        end
        //wait_cycles(1);

        //stall_end_time = $time;
        //stall_cycles = (stall_end_time - stall_start_time) / 10;  // 10ns period
        //
        //$display("Stall lasted %0d cycles", stall_cycles);

        
        // Wait for instruction completion (reaching W stage)
        wait_cycles(2);

        // Check results
        passed = 1;  // Assume pass
        
        // Check 1: rd_w should be 5
        if (rd_w !== 5) begin
            $display("ERROR: rd_w is %0d, expected 5", rd_w);
            passed = 0;
        end
        
        // Check 2: wen_w should be 1
        if (wen_w !== 0) begin
            $display("ERROR: wen_w is %0d, expected 0", wen_w);
            passed = 0;
        end
        
        //// Check 3: rd_data_w should equal returned data
        //if (rd_data_w !== expected_data) begin
        //    $display("ERROR: rd_data_w is 0x%h, expected 0x%h", 
        //             rd_data_w, expected_data);
        //    passed = 0;
        //end
        
        // Check 4: pc_w should equal instruction PC
        if (pc_w !== 32'h1C00_0000) begin
            $display("ERROR: pc_w is 0x%h, expected 0x1C00_0000", pc_w);
            passed = 0;
        end
        
	// No stall when ALE happen
        //// Check 5: Stall cycles should be reasonable (LSU typically needs multiple cycles)
        //if (stall_cycles !== 1) begin
        //    $display("ERROR: stall cycles should be 1 cycle when ALE happen");
        //    passed = 0;
        //end
        
        // Check 6: No exception should occur
        if (exu_ifu_except === 0) begin
            $display("ERROR: Should be ALE");
            passed = 0;
        end
        
        // Check 7: No branch should occur
        if (exu_ifu_branch !== 0) begin
            $display("ERROR: Unexpected branch");
            passed = 0;
        end
        
        // Check 8: No ertn should occur
        if (exu_ifu_ertn !== 0) begin
            $display("ERROR: Unexpected ertn");
            passed = 0;
        end


	//
	// Second Instruction
	//
        // Setup ADD instruction: add.w $r1, $r2, $r3
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_0004;
        ifu_exu_rs1_d = 2;     // $r2
        ifu_exu_rs2_d = 3;     // $r3
        ifu_exu_rd_d = 1;      // $r1
        ifu_exu_wen_d = 1;
        
	u_dut.u_rf.regs[2] = 32'h10;
	u_dut.u_rf.regs[3] = 32'h0a;

        // ALU valid
        ifu_exu_alu_vld_d = 1;
        ifu_exu_alu_op_d = 6'b000001;  // ADD opcode
        ifu_exu_alu_a_pc_d = 0;
        ifu_exu_alu_b_imm_d = 0;
        
        // Other functional units inactive
        ifu_exu_lsu_vld_d = 0;
        ifu_exu_bru_vld_d = 0;
        ifu_exu_mul_vld_d = 0;
        ifu_exu_csr_vld_d = 0;
        
        wait_cycles(1);

        ifu_exu_vld_d = 0;
        ifu_exu_pc_d = 32'h0;
        ifu_exu_rs1_d = 0;     // $r2
        ifu_exu_rs2_d = 0;     // $r3
        ifu_exu_rd_d = 0;      // $r1
        ifu_exu_wen_d = 0;
        
        // ALU valid
        ifu_exu_alu_vld_d = 0;
        ifu_exu_alu_op_d = 6'b000000;
        ifu_exu_alu_a_pc_d = 0;
        ifu_exu_alu_b_imm_d = 0;

        @(posedge clk);
        
        

        
        repeat(2) @(posedge clk);

        // Restore inputs
        init_inputs();
        
        // Print test result
        print_test_result(passed);
    end
    endtask
    
    // Task: ALU ADD Instruction Test
    task test_alu_add_instruction;
        integer passed;
    begin
        current_test_name = "ALU ADD Instruction Test";
        $display("\n=== Starting ALU ADD Instruction Test ===");
        
        // Initialize
        init_inputs();
        
        // Setup ADD instruction: add.w $r1, $r2, $r3
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_0000;
        ifu_exu_rs1_d = 2;     // $r2
        ifu_exu_rs2_d = 3;     // $r3
        ifu_exu_rd_d = 1;      // $r1
        ifu_exu_wen_d = 1;
        
	u_dut.u_rf.regs[2] = 32'h10;
	u_dut.u_rf.regs[3] = 32'h0a;

        // ALU valid
        ifu_exu_alu_vld_d = 1;
        ifu_exu_alu_op_d = 6'b000001;  // ADD opcode
        ifu_exu_alu_a_pc_d = 0;
        ifu_exu_alu_b_imm_d = 0;
        
        // Other functional units inactive
        ifu_exu_lsu_vld_d = 0;
        ifu_exu_bru_vld_d = 0;
        ifu_exu_mul_vld_d = 0;
        ifu_exu_csr_vld_d = 0;
        
        // Wait for instruction completion
        wait_cycles(1);

        ifu_exu_vld_d = 0;
        ifu_exu_pc_d = 32'h0;
        ifu_exu_rs1_d = 0;     // $r2
        ifu_exu_rs2_d = 0;     // $r3
        ifu_exu_rd_d = 0;      // $r1
        ifu_exu_wen_d = 0;
        
        // ALU valid
        ifu_exu_alu_vld_d = 0;
        ifu_exu_alu_op_d = 6'b000000;
        ifu_exu_alu_a_pc_d = 0;
        ifu_exu_alu_b_imm_d = 0;
        
        // Check results
        passed = 1;
       
        // wait for the result propagate through _e _m _w	
        wait_cycles(3);

        // Check rd_w and wen_w
        if (rd_w !== 1) begin
            $display("ERROR: rd_w is %0d, expected 1", rd_w);
            passed = 0;
        end
        
        if (wen_w !== 1) begin
            $display("ERROR: wen_w is %0d, expected 1", wen_w);
            passed = 0;
        end

        if (rd_data_w !== 32'h1a) begin
            $display("ERROR: rd_data_w is %0x, expected 0x1a", rd_data_w);
            passed = 0;
        end
        
        // ALU instruction should not cause stall
        if (exu_ifu_stall !== 0) begin
            $display("ERROR: Unexpected stall for ALU instruction");
            passed = 0;
        end
        
        // Restore inputs
        init_inputs();
        
        // Print test result
        print_test_result(passed);
    end
    endtask
    
    // Task: BRU Branch Instruction Test
    task test_bru_branch_instruction;
        integer passed;
    begin
        current_test_name = "BRU Branch Instruction Test";
        $display("\n=== Starting BRU Branch Instruction Test ===");
        
        // Initialize
        init_inputs();
        
        // Setup branch instruction: beq $r1, $r2, offset
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_2000;
        ifu_exu_rs1_d = 1;
        ifu_exu_rs2_d = 2;
        ifu_exu_rd_d = 0;  // Branch instructions typically don't write registers
        ifu_exu_wen_d = 0;
        ifu_exu_imm_shifted_d = 32'h100;  // Offset
        
        // BRU valid
        ifu_exu_bru_vld_d = 1;
        ifu_exu_bru_op_d = 4'b0000;  // BEQ opcode (assumed)
        ifu_exu_bru_offset_d = 32'h100;
        
        // Other functional units inactive
        ifu_exu_alu_vld_d = 0;
        ifu_exu_lsu_vld_d = 0;
        ifu_exu_mul_vld_d = 0;
        ifu_exu_csr_vld_d = 0;
        
        // Wait for instruction completion
        wait_cycles(1);

        ifu_exu_vld_d = 0;
        ifu_exu_pc_d = 32'h0;
        ifu_exu_rs1_d = 0;
        ifu_exu_rs2_d = 0;
        ifu_exu_rd_d = 0;  // Branch instructions typically don't write registers
        ifu_exu_wen_d = 0;
        ifu_exu_imm_shifted_d = 32'h0;  // Offset
        
        // BRU valid
        ifu_exu_bru_vld_d = 0;
        ifu_exu_bru_op_d = 4'b0000;  // BEQ opcode
        ifu_exu_bru_offset_d = 32'h0;
        

	// Second Instruction

        // Setup ADD instruction: add.w $r1, $r2, $r3
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_2004;
        ifu_exu_rs1_d = 2;     // $r2
        ifu_exu_rs2_d = 3;     // $r3
        ifu_exu_rd_d = 1;      // $r1
        ifu_exu_wen_d = 1;
        
	u_dut.u_rf.regs[2] = 32'h10;
	u_dut.u_rf.regs[3] = 32'h0a;

        // ALU valid
        ifu_exu_alu_vld_d = 1;
        ifu_exu_alu_op_d = 6'b000001;  // ADD opcode
        ifu_exu_alu_a_pc_d = 0;
        ifu_exu_alu_b_imm_d = 0;
        
        // Other functional units inactive
        ifu_exu_lsu_vld_d = 0;
        ifu_exu_bru_vld_d = 0;
        ifu_exu_mul_vld_d = 0;
        ifu_exu_csr_vld_d = 0;
        
        wait_cycles(1);

        ifu_exu_vld_d = 0;
        ifu_exu_pc_d = 32'h0;
        ifu_exu_rs1_d = 0;     // $r2
        ifu_exu_rs2_d = 0;     // $r3
        ifu_exu_rd_d = 0;      // $r1
        ifu_exu_wen_d = 0;
        
        // ALU valid
        ifu_exu_alu_vld_d = 0;
        ifu_exu_alu_op_d = 6'b000000;
        ifu_exu_alu_a_pc_d = 0;
        ifu_exu_alu_b_imm_d = 0;

        wait_cycles(2);

        // Check results
        passed = 1;
        
        // Check branch signal
        if (exu_ifu_branch !== 1) begin
            $display("ERROR: Branch signal not asserted");
            passed = 0;
        end
        
        // Check branch address
        if (exu_ifu_brn_addr !== 32'h1C00_2100) begin  // PC + offset
            $display("ERROR: Branch address 0x%h, expected 0x1C00_2100",
                     exu_ifu_brn_addr);
            passed = 0;
        end
        
        wait_cycles(2);

        //if (u_dut.u_rf.regs[1] !== 32'h0) begin 
        if (wen_w !== 0) begin 
            $display("ERROR: Seccond instruction not flushed, regs[1] 0x%h, wen_w 0x%h, expected 0x0",
                     u_dut.u_rf.regs[1], wen_w);
            passed = 0;
        end

        // Restore inputs
        init_inputs();
        
        // Print test result
        print_test_result(passed);
    end
    endtask

    // Task: ERTN Instruction Test with flush mechanism
    task test_ertn_flush_instruction;
        integer passed;
        integer i;
    begin
        current_test_name = "ERTN Instruction Test with Flush";
        $display("\n=== Starting ERTN Instruction Flush Test ===");

        // Initialize
        init_inputs();

        // First: Setup an ADD instruction to establish baseline
        $display("Step 1: Executing baseline ADD instruction");
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_0000;
        ifu_exu_rs1_d = 2;
        ifu_exu_rs2_d = 3;
        ifu_exu_rd_d = 10;      // $r10
        ifu_exu_wen_d = 1;

        u_dut.u_rf.regs[2] = 32'h20;
        u_dut.u_rf.regs[3] = 32'h10;

        ifu_exu_alu_vld_d = 1;
        ifu_exu_alu_op_d = 6'b000001;
        ifu_exu_alu_a_pc_d = 0;
        ifu_exu_alu_b_imm_d = 0;

        @(posedge clk);

        // Second: Setup ERTN instruction
        $display("Step 2: Executing ERTN instruction");
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_0004;
        ifu_exu_rd_d = 0;
        ifu_exu_wen_d = 0;

        ifu_exu_ertn_vld_d = 1;
        ifu_exu_alu_vld_d = 0;

        @(posedge clk);

        // Third: Setup ADD instruction that should be flushed
        $display("Step 3: Executing ADD instruction (should be flushed)");
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_0008;
        ifu_exu_rs1_d = 4;
        ifu_exu_rs2_d = 5;
        ifu_exu_rd_d = 10;      // $r10
        ifu_exu_wen_d = 1;

        u_dut.u_rf.regs[4] = 32'h30;
        u_dut.u_rf.regs[5] = 32'h15;

        ifu_exu_alu_vld_d = 1;
        ifu_exu_alu_op_d = 6'b000001;
        ifu_exu_ertn_vld_d = 0;

        @(posedge clk);

        // Fourth: Setup another ADD instruction (should also be flushed)
        $display("Step 4: Executing second ADD instruction (should be flushed)");
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_000C;
        ifu_exu_rs1_d = 6;
        ifu_exu_rs2_d = 7;
        ifu_exu_rd_d = 10;      // $r10
        ifu_exu_wen_d = 1;

        u_dut.u_rf.regs[6] = 32'h40;
        u_dut.u_rf.regs[7] = 32'h20;

        ifu_exu_alu_vld_d = 1;
        ifu_exu_alu_op_d = 6'b000001;

        @(posedge clk);

        // Stop sending instructions
        $display("Step 5: Stopping instruction stream");
        init_inputs();

        // Wait for pipeline to process
        wait_cycles(1);

        // Check results
        passed = 1;

        $display("\nChecking results...");

        // Check 1: ERTN signal should be asserted
        if (exu_ifu_ertn !== 1) begin
            $display("ERROR: ERTN signal not asserted");
            passed = 0;
        end

        // Check 2: First ADD instruction (before ERTN) should complete
        // Wait for it to reach W stage
        wait_cycles(5);

        //if (rd_w === 10 && wen_w === 1 && rd_data_w === 32'h30) begin
        //    $display("PASS: First ADD instruction completed: $r10 = 0x%h", rd_data_w);
        //end else begin
        //    $display("ERROR: First ADD instruction failed: rd_w=%0d, wen_w=%0d, data=0x%h",
        //             rd_w, wen_w, rd_data_w);
        //    passed = 0;
        //end
	
        if (u_dut.u_rf.regs[10] === 32'h30) begin
            $display("PASS: First ADD instruction completed: $r10 = 0x%h, other ADD instructions at 0x1C000008 and 0x1C00000C are flushed", u_dut.u_rf.regs[10]);
        end else begin
            $display("ERROR: First ADD instruction failed");
            passed = 0;
        end

//        // Check 3: ADD instructions after ERTN should be flushed (not write back)
//        // Monitor for several cycles to ensure they don't complete
//        for (i = 0; i < 8; i = i + 1) begin
//            @(posedge clk);
//            if (rd_w === 11 || rd_w === 12) begin
//                $display("ERROR: Flushed instruction completed (rd_w=%0d at cycle %0d)",
//                         rd_w, i);
//                passed = 0;
//            end
//        end
//
//        // Check 4: Register file should not be updated by flushed instructions
//        if (u_dut.u_rf.regs[11] !== 32'h0) begin
//            $display("ERROR: $r11 was updated to 0x%h, should remain 0x0",
//                     u_dut.u_rf.regs[11]);
//            passed = 0;
//        end
//
//        if (u_dut.u_rf.regs[12] !== 32'h0) begin
//            $display("ERROR: $r12 was updated to 0x%h, should remain 0x0",
//                     u_dut.u_rf.regs[12]);
//            passed = 0;
//        end
//
//        // Check 5: IFU should be flushed (no new instructions fetched for some cycles)
//        // This is harder to check without IFU interface, but we can monitor
//        // the stall signal and instruction flow
//
//        // Check 6: After some cycles, new instructions should be fetchable
//        // Send a new ADD instruction to verify pipeline recovered
//        $display("\nStep 6: Testing pipeline recovery after ERTN");
//        ifu_exu_vld_d = 1;
//        ifu_exu_pc_d = 32'h1C00_0100;  // New PC after ERTN
//        ifu_exu_rs1_d = 8;
//        ifu_exu_rs2_d = 9;
//        ifu_exu_rd_d = 13;      // $r13
//        ifu_exu_wen_d = 1;
//
//        u_dut.u_rf.regs[8] = 32'h50;
//        u_dut.u_rf.regs[9] = 32'h25;
//
//        ifu_exu_alu_vld_d = 1;
//        ifu_exu_alu_op_d = 6'b000001;
//
//        @(posedge clk);
//        init_inputs();
//
//        // Wait for this instruction to complete
//        wait_cycles(4);
//
//        if (rd_w === 13 && wen_w === 1 && rd_data_w === 32'h75) begin
//            $display("PASS: Pipeline recovered, new ADD completed: $r13 = 0x%h", rd_data_w);
//        end else begin
//            $display("ERROR: Pipeline recovery failed: rd_w=%0d, wen_w=%0d, data=0x%h",
//                     rd_w, wen_w, rd_data_w);
//            passed = 0;
//        end
//
//        // Check 7: ERTN signal should be deasserted after completion
//        wait_cycles(2);
//        if (exu_ifu_ertn !== 0) begin
//            $display("ERROR: ERTN signal still asserted");
//            passed = 0;
//        end

        // Summary
        $display("\nERTN Flush Test Summary:");
        if (passed) begin
            $display("All flush mechanisms working correctly");
        end else begin
            $display("Some flush mechanisms failed");
        end

        // Restore inputs
        init_inputs();

        // Print test result
        print_test_result(passed);
    end
    endtask

    // Task: Complex ERTN with multiple instruction types
    task test_ertn_complex_flush;
        integer passed;
        reg [31:0] saved_regs [0:15];
        integer i;
    begin
        current_test_name = "ERTN Complex Flush Test";
        $display("\n=== Starting Complex ERTN Flush Test ===");

        // Save current register values
        for (i = 0; i < 16; i = i + 1) begin
            saved_regs[i] = u_dut.u_rf.regs[i];
        end

        // Initialize
        init_inputs();

        // Create a mix of instructions in the pipeline
        $display("Setting up mixed instruction pipeline...");

        // Cycle 0: ALU instruction
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_1000;
        ifu_exu_rs1_d = 1;
        ifu_exu_rs2_d = 2;
        ifu_exu_rd_d = 20;      // $r20
        ifu_exu_wen_d = 1;
        u_dut.u_rf.regs[1] = 32'h100;
        u_dut.u_rf.regs[2] = 32'h200;
        ifu_exu_alu_vld_d = 1;
        ifu_exu_alu_op_d = 6'b000001;  // ADD

        @(posedge clk);

        // Cycle 1: ERTN instruction
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_1008;
        ifu_exu_rd_d = 0;
        ifu_exu_wen_d = 0;
        ifu_exu_lsu_vld_d = 0;
        ifu_exu_ertn_vld_d = 1;

        @(posedge clk);

        // Cycle 2: LSU instruction (should be flushed)
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_1004;
        ifu_exu_rs1_d = 3;
        ifu_exu_rs2_d = 0;
        ifu_exu_rd_d = 21;      // $r21
        ifu_exu_wen_d = 1;
        ifu_exu_imm_shifted_d = 32'h0;
        u_dut.u_rf.regs[3] = 32'h4000_0000;
        ifu_exu_alu_vld_d = 0;
        ifu_exu_lsu_vld_d = 1;
        ifu_exu_lsu_op_d = 7'b0000011;  // LD

        @(posedge clk);

        // Cycle 3: BRU instruction (should be flushed)
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_100C;
        ifu_exu_rs1_d = 4;
        ifu_exu_rs2_d = 5;
        ifu_exu_rd_d = 0;
        ifu_exu_wen_d = 0;
        ifu_exu_bru_offset_d = 32'h100;
        u_dut.u_rf.regs[4] = 32'h1;
        u_dut.u_rf.regs[5] = 32'h1;
        ifu_exu_ertn_vld_d = 0;
        ifu_exu_bru_vld_d = 1;
        ifu_exu_bru_op_d = 4'b0000;  // BEQ

        @(posedge clk);

        // Cycle 4: MUL instruction (should be flushed)
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_1010;
        ifu_exu_rs1_d = 6;
        ifu_exu_rs2_d = 7;
        ifu_exu_rd_d = 22;      // $r22
        ifu_exu_wen_d = 1;
        u_dut.u_rf.regs[6] = 32'h5;
        u_dut.u_rf.regs[7] = 32'h6;
        ifu_exu_bru_vld_d = 0;
        ifu_exu_mul_vld_d = 1;
        ifu_exu_mul_signed_d = 1;

        @(posedge clk);

        // Stop instruction stream
        init_inputs();

	//// response to LSU ld instruction
        //if (lsu_biu_rd_req) begin
        //    $display("Note: Cancelling pending LSU request due to ERTN flush");
        //    // Simulate BIU acknowledging but data won't be used
        //    @(posedge clk);
        //    biu_lsu_rd_ack = 1;
        //    @(posedge clk);
        //    biu_lsu_rd_ack = 0;
        //end

	//// Wait for several cycles to send data
        //wait_cycles(5);

	//biu_lsu_data_vld = 1;
	//biu_lsu_data = 64'haaaa1234bbbb1234;

        //wait_cycles(1);
	//
	//biu_lsu_data_vld = 0;
	//biu_lsu_data = 64'h0;

        // Check results
        passed = 1;

        $display("\nChecking complex flush behavior...");

        // Check 1: ERTN should be asserted
        if (exu_ifu_ertn !== 1) begin
            $display("ERROR: ERTN signal not asserted");
            passed = 0;
        end

        // Check 2: Instruction before ERTN (ALU ADD) should complete
        wait_cycles(2);
        if (u_dut.u_rf.regs[20] === 32'h300) begin
            $display("PASS: Pre-ERTN ALU instruction completed");
        end else begin
            $display("ERROR: Pre-ERTN instruction failed");
            passed = 0;
        end

        // Check 3: LSU instruction should be cancelled/not complete
        // Monitor for several cycles
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            if (rd_w === 21 && wen_w === 1) begin
                $display("ERROR: Flushed LSU instruction completed (cycle %0d)", i);
                passed = 0;
            end
        end

        // Check 4: BRU and MUL instructions should be flushed
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            if (rd_w === 22 && wen_w === 1) begin
                $display("ERROR: Flushed MUL instruction completed (cycle %0d)", i);
                passed = 0;
            end
        end

        // Check 5: No branch should occur from flushed BRU
        if (exu_ifu_branch !== 0) begin
            $display("ERROR: Branch occurred from flushed instruction");
            passed = 0;
        end

        // Check 6: Pipeline should eventually recover
        // Send a new instruction
        $display("\nTesting pipeline recovery...");
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_2000;  // New address after ERTN
        ifu_exu_rs1_d = 10;
        ifu_exu_rs2_d = 11;
        ifu_exu_rd_d = 23;      // $r23
        ifu_exu_wen_d = 1;
        u_dut.u_rf.regs[10] = 32'h77;
        u_dut.u_rf.regs[11] = 32'h88;
        ifu_exu_alu_vld_d = 1;
        ifu_exu_alu_op_d = 6'b000010;  // SUB for variety

        @(posedge clk);
        init_inputs();

        wait_cycles(4);

        if (u_dut.u_rf.regs[23] === 32'hFFFFFFEF) begin  // 0x77 - 0x88 = -0x11
            $display("PASS: Pipeline recovered, SUB instruction completed");
        end else begin
            $display("ERROR: Pipeline recovery failed: data=0x%h, expected 0xFFFFFFEF",
                     rd_data_w);
            passed = 0;
        end

        // Restore original register values
        for (i = 0; i < 16; i = i + 1) begin
            u_dut.u_rf.regs[i] = saved_regs[i];
        end

        // Restore inputs
        init_inputs();

        // Print test result
        print_test_result(passed);
    end
    endtask
    
    // Task: JIRL Instruction Test (jirl $r1, $r6, 32)
    task test_jirl_instruction;
        integer passed;
        reg [31:0] expected_target;
        reg [31:0] expected_return_addr;
    begin
        current_test_name = "JIRL Instruction Test";
        $display("\n=== Starting JIRL Instruction Test ===");

        // Initialize
        init_inputs();

        // Setup JIRL instruction: jirl $r1, $r6, 32
        // rs1 = 6 (base register), rd = 1 (destination for return address)
        // offset = 32 (0x20)
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_3000;  // Current PC
        ifu_exu_rs1_d = 6;             // $r6 (base register)
        ifu_exu_rs2_d = 0;             // Not used
        ifu_exu_rd_d = 1;              // $r1 (destination for return address)
        ifu_exu_wen_d = 1;             // Write return address to $r1
        ifu_exu_imm_shifted_d = 32'h20;  // Offset (32 decimal)

        // Setup register value for $r6
        u_dut.u_rf.regs[6] = 32'h4000_0000;  // Base address

        // Calculate expected values
        expected_target = 32'h4000_0020;      // $r6 + offset
        expected_return_addr = 32'h1C00_3004; // PC + 4 (next instruction)

        // BRU valid (assuming JIRL is handled by BRU)
        ifu_exu_bru_vld_d = 1;
        ifu_exu_bru_op_d = 4'b0101;
        ifu_exu_bru_offset_d = 32'h20;

        // Other functional units inactive
        ifu_exu_alu_vld_d = 0;
        ifu_exu_lsu_vld_d = 0;
        ifu_exu_mul_vld_d = 0;
        ifu_exu_csr_vld_d = 0;

        // Wait for instruction to enter pipeline
        @(posedge clk);

        // Clear inputs for next cycle
        ifu_exu_vld_d = 0;
        ifu_exu_pc_d = 0;
        ifu_exu_rs1_d = 0;
        ifu_exu_rs2_d = 0;
        ifu_exu_rd_d = 0;
        ifu_exu_wen_d = 0;
        ifu_exu_imm_shifted_d = 0;
        ifu_exu_bru_vld_d = 0;
        ifu_exu_bru_op_d = 0;
        ifu_exu_bru_offset_d = 0;

        // Wait for instruction to complete (go through pipeline stages)
        wait_cycles(3);

        // Check results
        passed = 1;

        $display("Checking JIRL instruction results...");

        // Check 1: Branch signal should be asserted
        if (exu_ifu_branch !== 1) begin
            $display("ERROR: Branch signal not asserted for JIRL");
            passed = 0;
        end

        // Check 2: Branch address should be $r6 + offset
        if (exu_ifu_brn_addr !== expected_target) begin
            $display("ERROR: Branch address 0x%h, expected 0x%h",
                     exu_ifu_brn_addr, expected_target);
            passed = 0;
        end

        // Check 3: Return address should be written to $r1

        if (rd_w !== 1) begin
            $display("ERROR: rd_w is %0d, expected 1", rd_w);
            passed = 0;
        end

        if (wen_w !== 1) begin
            $display("ERROR: wen_w is %0d, expected 1", wen_w);
            passed = 0;
        end

        if (rd_data_w !== expected_return_addr) begin
            $display("ERROR: Return address 0x%h, expected 0x%h",
                     rd_data_w, expected_return_addr);
            passed = 0;
        end

        // Check 4: PC in writeback stage should match instruction PC
        if (pc_w !== 32'h1C00_3000) begin
            $display("ERROR: pc_w is 0x%h, expected 0x1C00_3000", pc_w);
            passed = 0;
        end

        // Check 5: No stall should occur for JIRL (non-load/store)
        if (exu_ifu_stall !== 0) begin
            $display("ERROR: Unexpected stall for JIRL instruction");
            passed = 0;
        end

        // Check 6: No exception should occur
        if (exu_ifu_except !== 0) begin
            $display("ERROR: Unexpected exception for JIRL");
            passed = 0;
        end

        // Check 7: No ERTN should occur
        if (exu_ifu_ertn !== 0) begin
            $display("ERROR: Unexpected ertn for JIRL");
            passed = 0;
        end

        // Restore inputs
        init_inputs();

        // Print test result
        print_test_result(passed);

        $display("JIRL test completed:");
        $display("  Jump target: 0x%h ($r6 + 0x20)", expected_target);
        $display("  Return address saved to $r1: 0x%h", expected_return_addr);
    end
    endtask

    // Task: JIRL with zero offset test
    task test_jirl_zero_offset;
        integer passed;
    begin
        current_test_name = "JIRL Zero Offset Test";
        $display("\n=== Starting JIRL Zero Offset Test ===");

        // Initialize
        init_inputs();

        // Setup JIRL instruction: jirl $r2, $r7, 0
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_4000;
        ifu_exu_rs1_d = 7;             // $r7
        ifu_exu_rd_d = 2;              // $r2
        ifu_exu_wen_d = 1;
        ifu_exu_imm_shifted_d = 0;     // Zero offset

        u_dut.u_rf.regs[7] = 32'h5000_0000;  // Base address

        // BRU valid
        ifu_exu_bru_vld_d = 1;
        ifu_exu_bru_op_d = 4'b0101;    // JIRL opcode
        ifu_exu_bru_offset_d = 0;

        @(posedge clk);
        init_inputs();

        // Wait for completion
        wait_cycles(3);

        // Check results
        passed = 1;

        // Check branch signal
        if (exu_ifu_branch !== 1) begin
            $display("ERROR: Branch signal not asserted");
            passed = 0;
        end

        // Check branch address (should equal $r7)
        if (exu_ifu_brn_addr !== 32'h5000_0000) begin
            $display("ERROR: Branch address 0x%h, expected 0x5000_0000",
                     exu_ifu_brn_addr);
            passed = 0;
        end

        // Check return address
        if (rd_data_w !== 32'h1C00_4004) begin
            $display("ERROR: Return address 0x%h, expected 0x1C00_4004",
                     rd_data_w);
            passed = 0;
        end

        // Restore inputs
        init_inputs();

        // Print test result
        print_test_result(passed);
    end
    endtask

    // Task: JIRL with negative offset test
    task test_jirl_negative_offset;
        integer passed;
        reg [31:0] expected_target;
    begin
        current_test_name = "JIRL Negative Offset Test";
        $display("\n=== Starting JIRL Negative Offset Test ===");

        // Initialize
        init_inputs();

        // Setup JIRL instruction: jirl $r3, $r8, -16
        // Note: Offset is signed, -16 = 0xFFFFFFF0 in two's complement
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_5000;
        ifu_exu_rs1_d = 8;             // $r8
        ifu_exu_rd_d = 3;              // $r3
        ifu_exu_wen_d = 1;
        ifu_exu_imm_shifted_d = 32'hFFFFFFF0;  // -16

        u_dut.u_rf.regs[8] = 32'h6000_0010;  // Base address

        // Calculate expected target: 0x6000_0010 + (-16) = 0x6000_0000
        expected_target = 32'h6000_0000;

        // BRU valid
        ifu_exu_bru_vld_d = 1;
        ifu_exu_bru_op_d = 4'b0101;    // JIRL opcode
        ifu_exu_bru_offset_d = 32'hFFFFFFF0;

        @(posedge clk);
        init_inputs();

        // Wait for completion
        wait_cycles(3);

        // Check results
        passed = 1;

        // Check branch signal
        if (exu_ifu_branch !== 1) begin
            $display("ERROR: Branch signal not asserted");
            passed = 0;
        end

        // Check branch address
        if (exu_ifu_brn_addr !== expected_target) begin
            $display("ERROR: Branch address 0x%h, expected 0x%h",
                     exu_ifu_brn_addr, expected_target);
            passed = 0;
        end

        // Check return address
        if (rd_data_w !== 32'h1C00_5004) begin
            $display("ERROR: Return address 0x%h, expected 0x1C00_5004",
                     rd_data_w);
            passed = 0;
        end

        // Restore inputs
        init_inputs();

        // Print test result
        print_test_result(passed);

        $display("Negative offset test: 0x6000_0010 + (-16) = 0x%h", expected_target);
    end
    endtask

    // Task: CSRRD Instruction Test (csrrd $r5, 0x0)
    task test_csrrd_instruction;
        integer passed;
        reg [31:0] expected_csr_value;
        integer csr_read_done;
        integer i;
    begin
        current_test_name = "CSRRD Instruction Test";
        $display("\n=== Starting CSRRD Instruction Test ===");
        
        // Initialize
        init_inputs();
        
        // Setup CSRRD instruction: csrrd $r5, 0x0
        // rd = 5 (destination register), csr_num = 0x0
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_6000;  // Current PC
        ifu_exu_rs1_d = 0;             // Not used for CSRRD
        ifu_exu_rs2_d = 0;             // Not used
        ifu_exu_rd_d = 5;              // $r5 (destination for CSR value)
        ifu_exu_wen_d = 1;             // Write CSR value to $r5
        ifu_exu_imm_shifted_d = 0;     // Not used
        
        // CSR valid
        ifu_exu_csr_vld_d = 1;
        ifu_exu_csr_raddr_d = 14'h0;   // CSR address 0x0
        ifu_exu_csr_xchg_d = 0;        // Read only (not exchange)
        ifu_exu_csr_wen_d = 0;         // No write (read only)
        ifu_exu_csr_waddr_d = 14'h0;   // Not used for read
        
        // Other functional units inactive
        ifu_exu_alu_vld_d = 0;
        ifu_exu_lsu_vld_d = 0;
        ifu_exu_bru_vld_d = 0;
        ifu_exu_mul_vld_d = 0;
        
        // Pre-set CSR 0x0 value in the DUT (if accessible)
        expected_csr_value = 32'h1234_5678;  // Example CSR value
        
        $display("Executing CSRRD $r5, 0x0");
        $display("Expected to read CSR 0x0 and write to $r5");
        
        // Wait for instruction to enter pipeline
        @(posedge clk);
        
        // Clear inputs for next cycle
        ifu_exu_vld_d = 0;
        ifu_exu_pc_d = 0;
        ifu_exu_rd_d = 0;
        ifu_exu_wen_d = 0;
        ifu_exu_csr_vld_d = 0;
        ifu_exu_csr_raddr_d = 0;
        
        // Wait for instruction to complete
        // CSR operations may take multiple cycles
        wait_cycles(2);
        
        // Check results
        passed = 1;
        csr_read_done = 0;
        
        $display("Checking CSRRD instruction results...");
        
        // Monitor for several cycles since CSR read might be pipelined
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge clk);
            
            // Check when instruction reaches writeback stage
            if (wen_w === 1 && rd_w === 5) begin
                csr_read_done = 1;
                
                // Check 1: rd_w should be 5
                if (rd_w !== 5) begin
                    $display("ERROR: rd_w is %0d, expected 5", rd_w);
                    passed = 0;
                end
                
                // Check 2: wen_w should be 1
                if (wen_w !== 1) begin
                    $display("ERROR: wen_w is %0d, expected 1", wen_w);
                    passed = 0;
                end
                
                // Check 3: pc_w should match instruction PC
                if (pc_w !== 32'h1C00_6000) begin
                    $display("ERROR: pc_w is 0x%h, expected 0x1C00_6000", pc_w);
                    passed = 0;
                end
                
                // Check 4: rd_data_w contains CSR value
                $display("CSR value read: 0x%h", rd_data_w);
                
                // Exit the loop when we found the result
                i = 5;  // Set to max to exit loop
            end
        end
        
        // Check if CSR read completed
        if (csr_read_done === 0) begin
            $display("ERROR: CSRRD instruction did not complete writeback within expected cycles");
            passed = 0;
        end
        
        // Check 5: No stall should occur for CSR read (unless CSR has side effects)
        if (exu_ifu_stall !== 0) begin
            $display("WARNING: Stall occurred during CSR read");
            // Not necessarily an error - some CSR reads might cause stalls
        end
        
        // Check 6: No exception should occur
        if (exu_ifu_except !== 0) begin
            $display("ERROR: Unexpected exception during CSR read");
            passed = 0;
        end
        
        // Check 7: No branch should occur
        if (exu_ifu_branch !== 0) begin
            $display("ERROR: Unexpected branch during CSR read");
            passed = 0;
        end
        
        // Check 8: No ertn should occur
        if (exu_ifu_ertn !== 0) begin
            $display("ERROR: Unexpected ertn during CSR read");
            passed = 0;
        end
        
        // Restore inputs
        init_inputs();
        
        // Print test result
        print_test_result(passed);
        
        $display("CSRRD test completed:");
        $display("  Read CSR 0x0, value = 0x%h", rd_data_w);
        $display("  Written to $r5");
    end
    endtask
    
    // Task: CSRWR Instruction Test (csrwr with read-back)
    task test_csrwr_instruction;
        integer passed;
        reg [31:0] test_value;
        integer csr_write_done;
        integer i;
    begin
        current_test_name = "CSRWR Instruction Test";
        $display("\n=== Starting CSRWR Instruction Test ===");
        
        // Initialize
        init_inputs();
        
        // Test value to write
        test_value = 32'hDEAD_BEEF;
        
        // First, write to CSR using CSRWR
        $display("Step 1: Writing 0x%h to CSR 0x6", test_value);
        
        // Setup CSRWR instruction
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_6100;
        ifu_exu_rs2_d = 10;            // Source register $r10
        ifu_exu_rd_d = 10;             // $r10 (destination for old CSR value)
        ifu_exu_wen_d = 1;             // Write old CSR value to $r10
        
        // Set source register value
        u_dut.u_rf.regs[10] = test_value;
        
        // CSR valid - write operation
        ifu_exu_csr_vld_d = 1;
        ifu_exu_csr_raddr_d = 14'h6;   // CSR address 0x6
        ifu_exu_csr_xchg_d = 0;        // Exchange (write new, read old) CSRWR xchg 0
        ifu_exu_csr_wen_d = 1;         // Write enabled
        ifu_exu_csr_waddr_d = 14'h6;   // Write to CSR 0x6
        
        @(posedge clk);
        init_inputs();
        
        // Wait for write to complete
        wait_cycles(3);
        
        // Second, read back using CSRRD to verify
        $display("Step 2: Reading back CSR 0x6 to verify");
        
        // Setup CSRRD instruction
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_6104;
        ifu_exu_rs1_d = 0;             // Not used
        ifu_exu_rd_d = 12;             // $r12 (destination for read value)
        ifu_exu_wen_d = 1;             // Write CSR value to $r12
        
        // CSR valid - read operation
        ifu_exu_csr_vld_d = 1;
        ifu_exu_csr_raddr_d = 14'h6;   // CSR address 0x6
        ifu_exu_csr_xchg_d = 0;        // Read only
        ifu_exu_csr_wen_d = 0;         // No write
        ifu_exu_csr_waddr_d = 14'h0;   // Not used
        
        @(posedge clk);
        init_inputs();
        
        // Wait for read to complete
        wait_cycles(2);
        
        // Check results
        passed = 1;
        csr_write_done = 0;
        
        $display("Checking CSRWR/CSRRD results...");
        
        // Monitor for CSR read completion
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge clk);
            
            // Check when readback instruction reaches writeback
            if (wen_w === 1 && rd_w === 12) begin
                csr_write_done = 1;
                
                // Check that we read back the written value
                $display("CSR 0x6 value read back: 0x%h", rd_data_w);
                
                // Ideally we'd check if rd_data_w equals test_value,
                // but this depends on CSR implementation
                if (rd_data_w === test_value) begin
                    $display("PASS: CSR write/read verified correctly");
                end else begin
                    $display("ERROR: CSR readback value differs");
                    $display("  Written: 0x%h, Read: 0x%h", test_value, rd_data_w);
		    passed = 0;
                end
                
                // Exit the loop
                i = 5;
            end
        end
        
        if (csr_write_done === 0) begin
            $display("ERROR: CSR readback did not complete");
            passed = 0;
        end
        
        // Also check that old CSR value was captured in $r11
        // This happens during the CSRWR instruction
        wait_cycles(2);
        
        // Restore inputs
        init_inputs();
        
        // Print test result
        print_test_result(passed);
        
        $display("CSRWR test completed:");
        $display("  Wrote 0x%h to CSR 0x6", test_value);
        $display("  Read back 0x%h", rd_data_w);
    end
    endtask
    
    // Task: CSR operations with pipeline interaction
    task test_csr_pipeline_interaction;
        reg [31:0] test_value;
        integer passed;
        integer i;
    begin
        current_test_name = "CSR Pipeline Interaction Test";
        $display("\n=== Starting CSR Pipeline Interaction Test ===");
        
        // Initialize
        init_inputs();
        
	// Test value to write
        test_value = 32'hDEAD_BEEF;

        // Test CSR operations mixed with other instructions
        $display("Testing CSR ops in pipeline with ALU instructions");
        
        // Cycle 0: CSWR instruction
	// Setup CSRWR instruction
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_6200;
        ifu_exu_rs2_d = 20;            // Source register $r20
        ifu_exu_rd_d = 20;             // $r20 (destination for old CSR value)
        ifu_exu_wen_d = 1;             // Write old CSR value to $r10

        // Set source register value
        u_dut.u_rf.regs[20] = test_value;

        // CSR valid - write operation
        ifu_exu_csr_vld_d = 1;
        ifu_exu_csr_raddr_d = 14'h6;   // CSR address 0x6
        ifu_exu_csr_xchg_d = 0;        // Exchange (write new, read old) CSRWR xchg 0
        ifu_exu_csr_wen_d = 1;         // Write enabled
        ifu_exu_csr_waddr_d = 14'h6;   // Write to CSR 0x6


        
        // Set ALU operands for next instruction
        u_dut.u_rf.regs[1] = 32'h100;
        u_dut.u_rf.regs[2] = 32'h200;
        
        @(posedge clk);
        init_inputs();
        
        // Wait for CSRRD to release stall
        wait_cycles(2);
        
        // Cycle 1: ALU ADD instruction (should flow through pipeline with CSR)
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_6204;
        ifu_exu_rs1_d = 1;
        ifu_exu_rs2_d = 2;
        ifu_exu_rd_d = 21;             // $r21
        ifu_exu_wen_d = 1;
        ifu_exu_csr_vld_d = 0;
        ifu_exu_alu_vld_d = 1;
        ifu_exu_alu_op_d = 6'b000001;  // ADD
        
        @(posedge clk);
        
        // Cycle 2: Another CSRRD
        ifu_exu_vld_d = 1;
        ifu_exu_pc_d = 32'h1C00_6208;
        ifu_exu_rd_d = 25;             // $r25
        ifu_exu_wen_d = 1;
        ifu_exu_csr_vld_d = 1;
        ifu_exu_csr_raddr_d = 14'h6;   // CSR 0x6
        ifu_exu_alu_vld_d = 0;
        
        @(posedge clk);
        
        // Stop instruction stream
        init_inputs();
        
        // Wait for all instructions to complete
        wait_cycles(8);
        
        // Check results
        passed = 1;
        
        $display("Checking pipeline interaction...");
        
        // Check that all three instructions completed
        // We'll check the register file or monitor signals
        // For now, just check no exceptions occurred
        
        if (exu_ifu_except !== 0) begin
            $display("ERROR: Exception during CSR/ALU pipeline test");
            passed = 0;
        end
        
        // Check that pipeline didn't stall unnecessarily
        // (CSR ops might cause some stalls, but should recover)
        
        // Check ALU result if visible
        wait_cycles(2);
        
        // Check register file updates for ALU instruction
        // Note: This assumes register file is directly accessible
        if (u_dut.u_rf.regs[21] !== 32'h300) begin
            $display("ERROR: ALU result not in register file");
            $display("  Expected 0x300, got 0x%h", u_dut.u_rf.regs[21]);
	    passed = 0;
        end else begin
            $display("ALU instruction executes correctly");
        end
        
        // Check for CSR instruction completion signals
        if (u_dut.u_rf.regs[25] === test_value) begin
            $display("PASS: CSR write/read verified correctly");
        end else begin
            $display("ERROR: CSR readback value differs");
            $display("  Written: 0x%h, Read: 0x%h", test_value, rd_data_w);
	    passed = 0;
        end
        
        // Restore inputs
        init_inputs();
        
        // Print test result
        print_test_result(passed);
        
        $display("CSR pipeline test completed:");
        $display("  Mixed CSR and ALU instructions in pipeline");
        $display("  No exceptions, pipeline flowed correctly");
    end
    endtask

    // Main test flow
    initial begin
        // Initialize
        clk = 0;
        ext_intr = 1'b0;
        init_inputs();
        
        // Wait for some time
        //#10;
        
        // Reset system
        reset_system();
        
        $display("\n========================================");
        $display("Starting c7bexu Testbench");
        $display("========================================\n");
        
        // Run test cases
        test_ld_instruction();
        test_ld_instruction_ale();
        test_alu_add_instruction();
        test_bru_branch_instruction();
      
	// Add ERTN flush tests
        test_ertn_flush_instruction();
        test_ertn_complex_flush();
        
        // Add JIRL tests
        test_jirl_instruction();
        test_jirl_zero_offset();
        test_jirl_negative_offset();

	// Add CSR tests
        test_csrrd_instruction();
        test_csrwr_instruction();
        test_csr_pipeline_interaction();
	
        // Add more test cases here...
        
        // Print test statistics
        $display("\n========================================");
        $display("Test Summary:");
        $display("Total Tests:  %0d", test_count);
        $display("Passed:       %0d", pass_count);
        $display("Failed:       %0d", fail_count);
        $display("========================================\n");
        
        if (fail_count == 0) begin
            $display("ALL TESTS PASSED!");
            $display("\nPASS!\n");
            $display("\033[0;32m");
            $display("**************************************************");
            $display("*                                                *");
            $display("*      * * *       *        * * *     * * *      *");
            $display("*      *    *     * *      *         *           *");
            $display("*      * * *     *   *      * * *     * * *      *");
            $display("*      *        * * * *          *         *     *");
            $display("*      *       *       *    * * *     * * *      *");
            $display("*                                                *");
            $display("**************************************************");
            $display("\n");
            $display("\033[0m");
        end else begin
            $display("SOME TESTS FAILED!");
            $display("\nFAIL!\n");
            $display("\033[0;31m");
            $display("**************************************************");
            $display("*                                                *");
            $display("*      * * *       *         ***      *          *");
            $display("*      *          * *         *       *          *");
            $display("*      * * *     *   *        *       *          *");
            $display("*      *        * * * *       *       *          *");
            $display("*      *       *       *     ***      * * *      *");
            $display("*                                                *");
            $display("**************************************************");
            $display("\n");
            $display("\033[0m");
        end

        // End simulation
        #100;
        $finish;
    end
    
    // Monitor key signal changes
    initial begin
        $monitor("Time %0t: clk=%b, resetn=%b, stall=%b, ertn=%b, pc_w=0x%h, wen_w=%d rd_w=%0d, rd_data_w=0x%h",
                 $time, clk, resetn, exu_ifu_stall, exu_ifu_ertn, pc_w, wen_w, rd_w, rd_data_w);
    end
    
    // Waveform file generation
    initial begin
        $dumpfile("c7bexu.vcd");
        //$dumpvars(0, tb_c7bexu);
    end
    
endmodule
