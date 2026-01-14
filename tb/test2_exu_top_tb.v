`timescale 1ns/1ps

module top_tb;
    // Clock and reset signals
    reg clk;
    reg resetn;
    
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
    wire             lsu_vld_m;
    wire [31:0]      alu_res_m;
    wire [31:0]      lsu_data_ls3;
    wire             lsu_data_vld_ls3;
    wire             lsu_except_ale_ls1;
    wire             lsu_except_buserr_ls3;
    wire             lsu_except_ecc_ls3;
    wire             lsu_ecl_wr_fin_ls3;
    
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
    assign lsu_vld_m = u_dut.lsu_vld_m;
    assign alu_res_m = u_dut.alu_res_m;
    assign lsu_data_ls3 = u_dut.lsu_data_ls3;
    assign lsu_data_vld_ls3 = u_dut.lsu_data_vld_ls3;
    assign lsu_except_ale_ls1 = u_dut.lsu_except_ale_ls1;
    assign lsu_except_buserr_ls3 = u_dut.lsu_except_buserr_ls3;
    assign lsu_except_ecc_ls3 = u_dut.lsu_except_ecc_ls3;
    assign lsu_ecl_wr_fin_ls3 = u_dut.lsu_ecl_wr_fin_ls3;
    
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
        ifu_exu_pc_d = 32'h8000_0000;
        ifu_exu_rs1_d = 6;     // $r6
        ifu_exu_rs2_d = 0;
        ifu_exu_rd_d = 5;      // $r5
        ifu_exu_wen_d = 1;     // Writeback needed
        ifu_exu_imm_shifted_d = 0;  // Offset 0
        
        // LSU valid
        ifu_exu_lsu_vld_d = 1;
        ifu_exu_lsu_op_d = 7'b0000011;  // LD opcode (assumed)
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
        
        // Record stall status
        if (exu_ifu_stall) begin
            stall_start_time = $time;
            $display("Stall detected at time %0t", $time);
        end
        
        // Simulate BIU response
        // Assume data returns at cycle 3
        repeat(2) @(posedge clk);
        
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
        wait_cycles(5);
        
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
        if (pc_w !== 32'h8000_0000) begin
            $display("ERROR: pc_w is 0x%h, expected 0x8000_0000", pc_w);
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
        ifu_exu_pc_d = 32'h8000_2000;
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
        wait_cycles(5);
        
        // Check results
        passed = 1;
        
        // Check branch signal
        if (exu_ifu_branch !== 1) begin
            $display("ERROR: Branch signal not asserted");
            passed = 0;
        end
        
        // Check branch address
        if (exu_ifu_brn_addr !== 32'h8000_2100) begin  // PC + offset
            $display("ERROR: Branch address 0x%h, expected 0x8000_2100",
                     exu_ifu_brn_addr);
            passed = 0;
        end
        
        // Restore inputs
        init_inputs();
        
        // Print test result
        print_test_result(passed);
    end
    endtask
    
    // Main test flow
    initial begin
        // Initialize
        clk = 0;
        init_inputs();
        
        // Wait for some time
        //#10;
        
        // Reset system
        reset_system();
        
        $display("\n========================================");
        $display("Starting c7bexu Testbench");
        $display("========================================\n");
        
        // Run test cases
        //test_ld_instruction();
        test_alu_add_instruction();
        //test_bru_branch_instruction();
        
        // Add more test cases here...
        
        // Print test statistics
        $display("\n========================================");
        $display("Test Summary:");
        $display("Total Tests:  %0d", test_count);
        $display("Passed:       %0d", pass_count);
        $display("Failed:       %0d", fail_count);
        $display("========================================\n");
        
        // End simulation
        #100;
        $finish;
    end
    
    // Monitor key signal changes
    initial begin
        $monitor("Time %0t: clk=%b, resetn=%b, stall=%b, pc_w=0x%h, rd_w=%0d, rd_data_w=0x%h",
                 $time, clk, resetn, exu_ifu_stall, pc_w, rd_w, rd_data_w);
    end
    
    // Waveform file generation
    initial begin
        $dumpfile("c7bexu.vcd");
        //$dumpvars(0, tb_c7bexu);
    end
    
endmodule
