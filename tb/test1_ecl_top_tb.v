`timescale 1ns/1ps

module top_tb();

// ===========================================
// Clock and Reset Generation
// ===========================================
reg clk;
reg resetn;

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    resetn = 0;
    #17 resetn = 1;
end

// ===========================================
// Test Variables and Coverage
// ===========================================
integer test_count = 0;
integer pass_count = 0;
integer fail_count = 0;

// ===========================================
// DUT Interface
// ===========================================
wire stall;

reg lsu_vld_e;
reg lsu_except_ale_ls1;
reg lsu_except_buserr_ls3;
reg lsu_except_ecc_ls3;
reg lsu_data_valid_ls3;
reg lsu_wr_fin_ls3;
reg csr_vld_e;

c7bexu_ecl dut (
    .clk(clk),
    .resetn(resetn),
    .stall(stall),
    .lsu_vld_e(lsu_vld_e),
    .lsu_except_ale_ls1(lsu_except_ale_ls1),
    .lsu_except_buserr_ls3(lsu_except_buserr_ls3),
    .lsu_except_ecc_ls3(lsu_except_ecc_ls3),
    .lsu_data_valid_ls3(lsu_data_valid_ls3),
    .lsu_wr_fin_ls3(lsu_wr_fin_ls3),
    .csr_vld_e(csr_vld_e)
);

// ===========================================
// Initialization Task
// ===========================================
task init_signals;
begin
    lsu_vld_e = 0;
    lsu_except_ale_ls1 = 0;
    lsu_except_buserr_ls3 = 0;
    lsu_except_ecc_ls3 = 0;
    lsu_data_valid_ls3 = 0;
    lsu_wr_fin_ls3 = 0;
    csr_vld_e = 0;
end
endtask

// ===========================================
// Test Case 1: No Operation
// ===========================================
task test_no_operation;
begin
    $display("[%0t] Test 1: No operation", $time);
    test_count = test_count + 1;
    init_signals;
    #20;
    if (stall === 1'b0) begin
        $display("Test 1: No operation  -> PASS");
        pass_count = pass_count + 1;
    end else begin
        $display("Test 1: No operation  -> FAIL: stall should be 0");
        fail_count = fail_count + 1;
    end
end
endtask

// ===========================================
// Test Case 2: CSR Operation Triggers Stall
// ===========================================
task test_csr_stall;
begin
    $display("[%0t] Test 2: CSR stall", $time);
    test_count = test_count + 1;
    init_signals;
    @(posedge clk);
    csr_vld_e = 1;
    @(posedge clk);
    csr_vld_e = 0;
    #10;
    // Stall should be asserted for 2 cycles after csr_vld_e
    if (stall === 1'b1) begin
        $display("Test 2: CSR stall  -> PASS");
        pass_count = pass_count + 1;
    end else begin
        $display("Test 2: CSR stall  -> FAIL: stall should be 1 for two cycles");
        fail_count = fail_count + 1;
    end
end
endtask

// ===========================================
// Test Case 3: LSU Start Triggers Stall
// ===========================================
task test_lsu_start_stall;
begin
    $display("[%0t] Test 3: LSU start stall", $time);
    test_count = test_count + 1;
    init_signals;
    @(posedge clk);
    lsu_vld_e = 1;
    @(posedge clk);
    lsu_vld_e = 0;
    #10;
    // Stall should be asserted after LSU start
    if (stall === 1'b1) begin
        $display("Test 3: LSU start stall  -> PASS");
        pass_count = pass_count + 1;
    end else begin
        $display("Test 3: LSU start stall  -> FAIL: stall should be 1 after LSU start");
        fail_count = fail_count + 1;
    end
end
endtask

// ===========================================
// Test Case 4: LSU Exception Ends Stall
// ===========================================
task test_lsu_except_ale;
begin
    $display("[%0t] Test 4: LSU exception end stall", $time);
    test_count = test_count + 1;
    init_signals;
    @(posedge clk);
    lsu_vld_e = 1;
    @(posedge clk);
    lsu_vld_e = 0;
    lsu_except_ale_ls1 = 1;
    @(posedge clk);
    lsu_except_ale_ls1 = 0;
    #10;
    // Stall should be de-asserted after LSU exception
    if (stall === 1'b0) begin
        $display("Test 4: LSU exception end stall  -> PASS");
        pass_count = pass_count + 1;
    end else begin
        $display("Test 4: LSU exception end stall  -> FAIL: stall should be 0 after LSU exception");
        fail_count = fail_count + 1;
    end
end
endtask

// ===========================================
// Test Case 5: LSU Normal Completion Ends Stall
// ===========================================
task test_lsu_normal_end;
begin
    $display("[%0t] Test 5: LSU normal end stall", $time);
    test_count = test_count + 1;
    init_signals;
    @(posedge clk);
    lsu_vld_e = 1;
    @(posedge clk);
    lsu_vld_e = 0;
    lsu_data_valid_ls3 = 1;
    @(posedge clk);
    lsu_data_valid_ls3 = 0;
    #10;
    // Stall should be de-asserted after LSU normal completion
    if (stall === 1'b0) begin
        $display("Test 5: LSU normal end stall  -> PASS");
        pass_count = pass_count + 1;
    end else begin
        $display("Test 5: LSU normal end stall  -> FAIL: stall should be 0 after LSU normal end");
        fail_count = fail_count + 1;
    end
end
endtask

// ===========================================
// Main Test Sequence
// ===========================================
initial begin
    // Wait for reset to complete
    #20;
    $display("===========================================");
    $display("Starting Testbench for c7bexu_ecl");
    $display("===========================================");

    // Execute test cases
    test_no_operation;
    test_csr_stall;
    test_lsu_start_stall;
    test_lsu_except_ale;
    test_lsu_normal_end;

    // Display test summary
    #10;
    $display("===========================================");
    $display("Test Summary");
    $display("  Total Tests : %0d", test_count);
    $display("  PASS        : %0d", pass_count);
    $display("  FAIL        : %0d", fail_count);
    $display("===========================================");

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
    $finish;
end

endmodule
