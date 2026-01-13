`timescale 1ns/1ps

module top_tb;
    // Inputs
    reg [4:0] rs1_e;
    reg [4:0] rs2_e;
    reg [4:0] rd_m;
    reg [4:0] rd_w;
    reg wen_m;
    reg wen_w;
    reg [31:0] rs1_data_e;
    reg [31:0] rs2_data_e;
    reg [31:0] rd_data_m;
    reg [31:0] rd_data_w;

    // Outputs
    wire [31:0] rs1_data_byp_e;
    wire [31:0] rs2_data_byp_e;

    // Test control
    integer test_count;
    integer pass_count;
    integer fail_count;

    // Instantiate the Unit Under Test (UUT)
    c7bexu_byp uut (
        .rs1_e(rs1_e),
        .rs2_e(rs2_e),
        .rd_m(rd_m),
        .rd_w(rd_w),
        .wen_m(wen_m),
        .wen_w(wen_w),
        .rs1_data_e(rs1_data_e),
        .rs2_data_e(rs2_data_e),
        .rd_data_m(rd_data_m),
        .rd_data_w(rd_data_w),
        .rs1_data_byp_e(rs1_data_byp_e),
        .rs2_data_byp_e(rs2_data_byp_e)
    );

    // Test control signals (simulate ecl_byp signals)
    reg ecl_byp_rs1_mux_sel_rf;
    reg ecl_byp_rs1_mux_sel_m;
    reg ecl_byp_rs1_mux_sel_w;
    reg ecl_byp_rs2_mux_sel_rf;
    reg ecl_byp_rs2_mux_sel_m;
    reg ecl_byp_rs2_mux_sel_w;

    // Initialize signals
    initial begin
        // Global test counters
        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        // Initialize all inputs
        rs1_e = 0;
        rs2_e = 0;
        rd_m = 0;
        rd_w = 0;
        wen_m = 0;
        wen_w = 0;
        rs1_data_e = 0;
        rs2_data_e = 0;
        rd_data_m = 0;
        rd_data_w = 0;

        // Run test cases
        test_case_1(); // No bypass
        test_case_2(); // Bypass from MEM stage
        test_case_3(); // Bypass from WB stage
        test_case_4(); // Bypass both rs1 and rs2 from MEM
        test_case_5(); // Write enable flags off

        // Print summary
        $display("===========================================");
        $display("TEST SUMMARY:");
        $display("Total tests  : %0d", test_count);
        $display("Passed tests : %0d", pass_count);
        $display("Failed tests : %0d", fail_count);
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
        $finish;
    end

    // Helper task to check results
    task check_result;
        input [31:0] expected_rs1;
        input [31:0] expected_rs2;
        input [512:0] test_name;
        begin
            test_count = test_count + 1;
            if (rs1_data_byp_e === expected_rs1 && rs2_data_byp_e === expected_rs2) begin
                $display("PASS: %s", test_name);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %s", test_name);
                $display("  Expected: rs1=0x%8h, rs2=0x%8h", expected_rs1, expected_rs2);
                $display("  Got     : rs1=0x%8h, rs2=0x%8h", rs1_data_byp_e, rs2_data_byp_e);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Test Case 1: No bypass (RF data selected)
    task test_case_1;
        reg [512:0] test_name;
        begin
            test_name = "No bypass (RF selected)";
            $display("\n--- Test Case 1: No Bypass ---");
            // Setup
            rs1_e = 5'h01;
            rs2_e = 5'h02;
            rd_m = 5'h03; // different from rs1 and rs2
            rd_w = 5'h04;
            wen_m = 1;
            wen_w = 1;
            rs1_data_e = 32'hAAAA_AAAA;
            rs2_data_e = 32'hBBBB_BBBB;
            rd_data_m = 32'hCCCC_CCCC;
            rd_data_w = 32'hDDDD_DDDD;

            // Simulate bypass logic (assume RF selected)
            ecl_byp_rs1_mux_sel_rf = 1;
            ecl_byp_rs1_mux_sel_m = 0;
            ecl_byp_rs1_mux_sel_w = 0;
            ecl_byp_rs2_mux_sel_rf = 1;
            ecl_byp_rs2_mux_sel_m = 0;
            ecl_byp_rs2_mux_sel_w = 0;

            #10;
            check_result(32'hAAAA_AAAA, 32'hBBBB_BBBB, test_name);
        end
    endtask

    // Test Case 2: Bypass from MEM stage for rs1
    task test_case_2;
        reg [512:0] test_name;
        begin
            test_name = "Bypass MEM -> rs1";
            $display("\n--- Test Case 2: Bypass from MEM (rs1) ---");
            // Setup: rs1 matches rd_m, MEM write enabled
            rs1_e = 5'h05;
            rs2_e = 5'h06;
            rd_m = 5'h05; // same as rs1
            rd_w = 5'h07;
            wen_m = 1;
            wen_w = 1;
            rs1_data_e = 32'h1111_1111;
            rs2_data_e = 32'h2222_2222;
            rd_data_m = 32'h3333_3333;
            rd_data_w = 32'h4444_4444;

            // Simulate bypass logic (MEM selected for rs1)
            ecl_byp_rs1_mux_sel_rf = 0;
            ecl_byp_rs1_mux_sel_m = 1;
            ecl_byp_rs1_mux_sel_w = 0;
            ecl_byp_rs2_mux_sel_rf = 1;
            ecl_byp_rs2_mux_sel_m = 0;
            ecl_byp_rs2_mux_sel_w = 0;

            #10;
            check_result(32'h3333_3333, 32'h2222_2222, test_name);
        end
    endtask

    // Test Case 3: Bypass from WB stage for rs2
    task test_case_3;
        reg [512:0] test_name;
        begin
            test_name = "Bypass WB -> rs2";
            $display("\n--- Test Case 3: Bypass from WB (rs2) ---");
            // Setup: rs2 matches rd_w, WB write enabled
            rs1_e = 5'h08;
            rs2_e = 5'h09;
            rd_m = 5'h0A;
            rd_w = 5'h09; // same as rs2
            wen_m = 1;
            wen_w = 1;
            rs1_data_e = 32'h5555_5555;
            rs2_data_e = 32'h6666_6666;
            rd_data_m = 32'h7777_7777;
            rd_data_w = 32'h8888_8888;

            // Simulate bypass logic (WB selected for rs2)
            ecl_byp_rs1_mux_sel_rf = 1;
            ecl_byp_rs1_mux_sel_m = 0;
            ecl_byp_rs1_mux_sel_w = 0;
            ecl_byp_rs2_mux_sel_rf = 0;
            ecl_byp_rs2_mux_sel_m = 0;
            ecl_byp_rs2_mux_sel_w = 1;

            #10;
            check_result(32'h5555_5555, 32'h8888_8888, test_name);
        end
    endtask

    // Test Case 4: Bypass both rs1 and rs2 from MEM
    task test_case_4;
        reg [512:0] test_name;
        begin
            test_name = "Bypass MEM -> rs1 & rs2";
            $display("\n--- Test Case 4: Bypass both from MEM ---");
            // Setup: both rs1 and rs2 match rd_m
            rs1_e = 5'h0B;
            rs2_e = 5'h0B; // same as rs1
            rd_m = 5'h0B;  // same as both
            rd_w = 5'h0C;
            wen_m = 1;
            wen_w = 1;
            rs1_data_e = 32'h9999_9999;
            rs2_data_e = 32'hAAAA_AAAA;
            rd_data_m = 32'hBBBB_BBBB;
            rd_data_w = 32'hCCCC_CCCC;

            // Simulate bypass logic (MEM selected for both)
            ecl_byp_rs1_mux_sel_rf = 0;
            ecl_byp_rs1_mux_sel_m = 1;
            ecl_byp_rs1_mux_sel_w = 0;
            ecl_byp_rs2_mux_sel_rf = 0;
            ecl_byp_rs2_mux_sel_m = 1;
            ecl_byp_rs2_mux_sel_w = 0;

            #10;
            check_result(32'hBBBB_BBBB, 32'hBBBB_BBBB, test_name);
        end
    endtask

    // Test Case 5: Write enable flags off (should still use RF)
    task test_case_5;
        reg [512:0] test_name;
        begin
            test_name = "Write enable off (RF selected)";
            $display("\n--- Test Case 5: Write Enables Off ---");
            // Setup: rs1 matches rd_m and rd_w, but wen_m=wen_w=0
            rs1_e = 5'h0D;
            rs2_e = 5'h0E;
            rd_m = 5'h0D; // same as rs1
            rd_w = 5'h0D; // same as rs1
            wen_m = 0;    // not writing
            wen_w = 0;    // not writing
            rs1_data_e = 32'hDDDD_DDDD;
            rs2_data_e = 32'hEEEE_EEEE;
            rd_data_m = 32'hFFFF_FFFF;
            rd_data_w = 32'h0000_0000;

            // Simulate bypass logic (should still select RF)
            ecl_byp_rs1_mux_sel_rf = 1;
            ecl_byp_rs1_mux_sel_m = 0;
            ecl_byp_rs1_mux_sel_w = 0;
            ecl_byp_rs2_mux_sel_rf = 1;
            ecl_byp_rs2_mux_sel_m = 0;
            ecl_byp_rs2_mux_sel_w = 0;

            #10;
            check_result(32'hDDDD_DDDD, 32'hEEEE_EEEE, test_name);
        end
    endtask

endmodule
