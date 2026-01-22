`timescale 1ns/1ps

module top_tb();

    // Parameters
    parameter SYNC_STAGES = 2;
    
    // Clock and Reset
    reg clk;
    reg rst_n;
    
    // DUT Inputs
    reg intr;
    reg ifu_exu_vld_d;
    
    // DUT Outputs
    wire intr_sync;
    wire intr_pulse;
    
    // Test Control
    integer test_num;
    integer pass_count;
    integer fail_count;
    reg test_result;
    
    // Instantiate DUT
    intr_sync_delay #(
        .SYNC_STAGES(SYNC_STAGES)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .intr(intr),
        .ifu_exu_vld_d(ifu_exu_vld_d),
        .intr_sync(intr_sync),
        .intr_pulse(intr_pulse)
    );
    
    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end
    
    // Test Harness
    initial begin
        // Initialize
        test_num = 0;
        pass_count = 0;
        fail_count = 0;
        rst_n = 0;
        intr = 0;
        ifu_exu_vld_d = 0;
        
        // Reset sequence
        #20;
        rst_n = 1;
        #10;
        
        // Run individual test cases
        test_reset_functionality();
        test_basic_synchronization();
        test_pulse_delay_without_valid();
        test_pulse_delay_with_valid();
        test_multiple_interrupts();
        
        // Print summary
        print_test_summary();
        
        // End simulation
        #100;
        $finish;
    end
    
    // -------------------------------------------------------------
    // Test Case 1: Reset Functionality
    // -------------------------------------------------------------
    task test_reset_functionality;
    begin
        test_num = test_num + 1;
        $display("[Test %0d] Reset Functionality Test", test_num);
        
        // Assert reset
        rst_n = 0;
        intr = 1;
        ifu_exu_vld_d = 1;
	@(posedge clk);
        ifu_exu_vld_d = 0;
        #80;
        
        // Check outputs should be 0 during reset
        if (intr_sync === 1'b0 && intr_pulse === 1'b0) begin
            test_result = 1;
            pass_count = pass_count + 1;
            $display("  -> PASS: All outputs are 0 during reset");
        end else begin
            test_result = 0;
            fail_count = fail_count + 1;
            $display("  -> FAIL: intr_sync=%b, intr_pulse=%b (expected 0,0)", 
                     intr_sync, intr_pulse);
        end
        
        // Release reset
        rst_n = 1;
        #10;
    end
    endtask
    
    // -------------------------------------------------------------
    // Test Case 2: Basic Synchronization
    // -------------------------------------------------------------
    task test_basic_synchronization;
    begin
        test_num = test_num + 1;
        $display("[Test %0d] Basic Synchronization Test", test_num);
        
        // Initialize
        intr = 0;
        ifu_exu_vld_d = 0;
        #10;
        
        // Generate interrupt
        intr = 1;
        #40; // Wait for synchronization through 2 flops (2 clock cycles)
        
        // Check synchronized signal
        if (intr_sync === 1'b1) begin
            test_result = 1;
            pass_count = pass_count + 1;
            $display("  -> PASS: intr_sync=1 after synchronization delay");
        end else begin
            test_result = 0;
            fail_count = fail_count + 1;
            $display("  -> FAIL: intr_sync=%b (expected 1)", intr_sync);
        end
        
        // Deassert interrupt
        intr = 0;
        #40;
    end
    endtask
    
    // -------------------------------------------------------------
    // Test Case 3: Pulse Delay without Valid Signal
    // -------------------------------------------------------------
    task test_pulse_delay_without_valid;
    begin
        test_num = test_num + 1;
        $display("[Test %0d] Pulse Delay without Valid Signal", test_num);
        
        // Initialize
        intr = 0;
        ifu_exu_vld_d = 0;
        #20;
        
        // Generate interrupt (rising edge)
        intr = 1;
        #30;
        intr = 0;
        #30;
        
        // Check that pulse is NOT generated without valid signal
        if (intr_pulse === 1'b0) begin
            test_result = 1;
            pass_count = pass_count + 1;
            $display("  -> PASS: No pulse generated without ifu_exu_vld_d");
        end else begin
            test_result = 0;
            fail_count = fail_count + 1;
            $display("  -> FAIL: intr_pulse=%b (expected 0)", intr_pulse);
        end
        
        #20;
    end
    endtask
    
    // -------------------------------------------------------------
    // Test Case 4: Pulse Delay with Valid Signal
    // -------------------------------------------------------------
    task test_pulse_delay_with_valid;
    begin
        test_num = test_num + 1;
        $display("[Test %0d] Pulse Delay with Valid Signal", test_num);
        
        // Initialize
        intr = 0;
        ifu_exu_vld_d = 0;
        #20;
        
        // Generate interrupt
        intr = 1;
        #30;
        //intr = 0;
        
        // Wait for synchronization, then assert valid
        #20;
        ifu_exu_vld_d = 1;
        //#10;
	@(posedge clk);
        
        // Check pulse is generated
        if (intr_pulse === 1'b1) begin
            test_result = 1;
            pass_count = pass_count + 1;
            $display("  -> PASS: Pulse generated when ifu_exu_vld_d=1");
        end else begin
            test_result = 0;
            fail_count = fail_count + 1;
            $display("  -> FAIL: intr_pulse=%b (expected 1)", intr_pulse);
        end
        
        // Deassert valid
        ifu_exu_vld_d = 0;
        #30;
    end
    endtask
    
    // -------------------------------------------------------------
    // Test Case 5: Multiple Interrupts
    // -------------------------------------------------------------
    task test_multiple_interrupts;
    begin
        test_num = test_num + 1;
        $display("[Test %0d] Multiple Interrupts Test", test_num);
        
        // Initialize
        intr = 0;
        ifu_exu_vld_d = 0;
        #20;
        
        // First interrupt
        intr = 1;
        #30;
        
	@(posedge clk);
        // First valid - should generate pulse
        ifu_exu_vld_d = 1;
        //#10;
	@(posedge clk);
        
        if (intr_pulse === 1'b1) begin
            $display("  -> First pulse generated OK");
        end else begin
            $display("  -> ERROR: First pulse not generated");
        end

        ifu_exu_vld_d = 0;
	@(posedge clk);

        #50;
        intr = 0;
        
        #50;
        
        // Second interrupt while first is still pending? (simulate missed scenario)
        intr = 1;
        #30;
        
	@(posedge clk);
        // Second valid
        ifu_exu_vld_d = 1;
        //#10;
	@(posedge clk);
        
        // Check second pulse
        if (intr_pulse === 1'b1) begin
            test_result = 1;
            pass_count = pass_count + 1;
            $display("  -> PASS: Second pulse generated correctly");
        end else begin
            test_result = 0;
            fail_count = fail_count + 1;
            $display("  -> FAIL: Second pulse not generated");
        end
        
        ifu_exu_vld_d = 0;
	@(posedge clk);

        #80;
        intr = 0;
    end
    endtask
    
    // -------------------------------------------------------------
    // Print Test Summary
    // -------------------------------------------------------------
    task print_test_summary;
    begin
        $display("\n========================================");
        $display(" TEST SUMMARY");
        $display("========================================");
        $display(" Total Tests: %0d", test_num);
        $display(" Passed:      %0d", pass_count);
        $display(" Failed:      %0d", fail_count);
        
        if (fail_count == 0) begin
            $display(" RESULT: ALL TESTS PASSED");
        end else begin
            $display(" RESULT: %0d TEST(S) FAILED", fail_count);
        end
        $display("========================================\n");
    end
    endtask
    
    // -------------------------------------------------------------
    // Monitoring
    // -------------------------------------------------------------
    initial begin
        $display("\n========================================");
        $display(" Starting Simulation");
        $display("========================================\n");
        
        $monitor("Time=%0t: rst_n=%b, intr=%b, valid=%b, sync=%b, pulse=%b",
                 $time, rst_n, intr, ifu_exu_vld_d, intr_sync, intr_pulse);
    end
    
endmodule
