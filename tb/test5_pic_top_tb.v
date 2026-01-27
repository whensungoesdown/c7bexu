`timescale 1ns/1ns

module top_tb;
    reg clk;
    reg resetn;
    reg ext_intr_sync;
    reg csr_timer_intr_sync;
    reg vld_d;
    reg ertn_w;
    
    wire pic_csr_ext_intr;
    wire intr_sync;
    wire intr_sync_pulse;
    
    integer test_count;
    integer pass_count;
    integer current_test_passed;
    
    // Instantiate the DUT
    pic dut (
        .clk(clk),
        .resetn(resetn),
        .ext_intr_sync(ext_intr_sync),
        .csr_timer_intr_sync(csr_timer_intr_sync),
        .vld_d(vld_d),
        .ertn_w(ertn_w),
        .pic_csr_ext_intr(pic_csr_ext_intr),
        .intr_sync(intr_sync),
        .intr_sync_pulse(intr_sync_pulse)
    );
    
    // Clock generation
    always begin
        #5 clk = ~clk;
    end
    
    // Test reporting function
    task report_test;
        input [80*8:1] test_name;
        begin
            test_count = test_count + 1;
            if (current_test_passed) begin
                pass_count = pass_count + 1;
                $display("[%0t] TEST: %s - PASS", $time, test_name);
            end else begin
                $display("[%0t] TEST: %s - FAIL", $time, test_name);
            end
        end
    endtask
    
    // Test 1: Reset functionality
    task test_reset;
        begin
            $display("\n--- Starting Test: Reset Functionality ---");
            resetn = 0;
            ext_intr_sync = 0;
            csr_timer_intr_sync = 0;
            vld_d = 0;
            ertn_w = 0;
            //@(negedge clk);
            @(posedge clk);
            
            // Check if outputs are as expected after reset
            current_test_passed = (intr_sync === 1'b0) && 
                                 (intr_sync_pulse === 1'b0) && 
                                 (pic_csr_ext_intr === 1'b0);



            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);

            report_test("Reset");
        end
    endtask
    
    // Test 2: External interrupt normal
    task test_ext_intr_normal;
        begin
            // reset
            resetn = 0;
            repeat(10) @(posedge clk);

            $display("\n--- Starting Test: External Interrupt Normal Case---");
            resetn = 1;
            ext_intr_sync = 1;
            csr_timer_intr_sync = 0;
            vld_d = 0;
            ertn_w = 0;
            //@(negedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            
            vld_d = 1;      // last 3 cycles
            @(posedge clk);
            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b1) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: vld_d=1 same cycle");
            @(posedge clk);

            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: intr_sync_pulse only asserted 1 cycle!");

            @(posedge clk);
            vld_d = 0;
            @(posedge clk);

            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: intr_sync_pulse only asserted 1 cycle!");

            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            ertn_w = 1;
            @(posedge clk);
            ertn_w = 0;
            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: ertn_w asserted");
            @(posedge clk);
            current_test_passed = (intr_sync === 1'b0) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b0);
            report_test("Ext Intr: ertn_w clears intr_sync and pic_csr_ext_intr");
            @(posedge clk);
        end
    endtask

    task test_ext_intr_vld_same_cycle;
        begin
            // reset
            resetn = 0;
            repeat(10) @(posedge clk);

            $display("\n--- Starting Test: External Interrupt Normal Case---");
            resetn = 1;
            ext_intr_sync = 1;
            csr_timer_intr_sync = 0;
            vld_d = 0;
            ertn_w = 0;
            vld_d = 1;      // ext_intr_sync vld_d asserted at the same cycle
            @(posedge clk);
            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b1) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: vld_d=1 same cycle");
            @(posedge clk);

            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: intr_sync_pulse only asserted 1 cycle!");

            @(posedge clk);
            vld_d = 0;
            @(posedge clk);

            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: intr_sync_pulse only asserted 1 cycle!");

            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            ertn_w = 1;
            @(posedge clk);
            ertn_w = 0;
            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: ertn_w asserted");
            @(posedge clk);
            current_test_passed = (intr_sync === 1'b0) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b0);
            report_test("Ext Intr: ertn_w clears intr_sync and pic_csr_ext_intr");
            @(posedge clk);
        end
    endtask

    task test_ext_intr_vld_multiple;
        begin
            // reset
            resetn = 0;
            repeat(10) @(posedge clk);

            $display("\n--- Starting Test: External Interrupt Normal Case---");
            resetn = 1;
            ext_intr_sync = 1;
            csr_timer_intr_sync = 0;
            vld_d = 0;
            ertn_w = 0;
            vld_d = 1;      // ext_intr_sync vld_d asserted at the same cycle
            @(posedge clk);
            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b1) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: vld_d=1 same cycle");

            vld_d = 0;
            @(posedge clk);

            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: intr_sync_pulse only asserted 1 cycle!");

            vld_d = 1;

            @(posedge clk);
            vld_d = 0;
            @(posedge clk);

            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: intr_sync_pulse only asserted 1 cycle!");

            vld_d = 1;

            @(posedge clk);
            vld_d = 0;
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            ertn_w = 1;
            @(posedge clk);
            ertn_w = 0;
            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: ertn_w asserted");
            @(posedge clk);
            current_test_passed = (intr_sync === 1'b0) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b0);
            report_test("Ext Intr: ertn_w clears intr_sync and pic_csr_ext_intr");
            @(posedge clk);
        end
    endtask

    task test_ext_intr_vld_again;
        begin
            // reset
            resetn = 0;
            repeat(10) @(posedge clk);

            $display("\n--- Starting Test: External Interrupt, ext_intr remains asserted, vld_d comes again---");
            resetn = 1;
            ext_intr_sync = 1;
            csr_timer_intr_sync = 0;
            vld_d = 0;
            ertn_w = 0;
            vld_d = 1;      // ext_intr_sync vld_d asserted at the same cycle
            @(posedge clk);
            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b1) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: vld_d=1 same cycle");
            @(posedge clk);

            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: intr_sync_pulse only asserted 1 cycle!");

            @(posedge clk);
            vld_d = 0;
            @(posedge clk);

            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: intr_sync_pulse only asserted 1 cycle!");

            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            ertn_w = 1;
            @(posedge clk);
            ertn_w = 0;
            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: ertn_w asserted");
            @(posedge clk);
            current_test_passed = (intr_sync === 1'b0) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b0);
            report_test("Ext Intr: ertn_w clears intr_sync and pic_csr_ext_intr");
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            vld_d = 1;      // vld_d comes again
            @(posedge clk);
            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b1) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: vld_d=1 same cycle");
            @(posedge clk);

            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: intr_sync_pulse only asserted 1 cycle!");

            @(posedge clk);
            vld_d = 0;
            @(posedge clk);

            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: intr_sync_pulse only asserted 1 cycle!");

            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            ertn_w = 1;
            @(posedge clk);
            ertn_w = 0;
            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: ertn_w asserted");
            @(posedge clk);
            current_test_passed = (intr_sync === 1'b0) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b0);
            report_test("Ext Intr: ertn_w clears intr_sync and pic_csr_ext_intr");
            @(posedge clk);
        end
    endtask

    // Test 4: External interrupt normal
    task test_ext_intr_twice;
        begin
            // reset
            resetn = 0;
            repeat(10) @(posedge clk);

            $display("\n--- Starting Test: External Interrupt Twice ---");
            resetn = 1;
            ext_intr_sync = 1;
            csr_timer_intr_sync = 0;
            vld_d = 0;
            ertn_w = 0;
            //@(negedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
            
            vld_d = 1;      // last 3 cycles
            @(posedge clk);
            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b1) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: vld_d=1 same cycle");
            @(posedge clk);

            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: intr_sync_pulse only asserted 1 cycle!");

            @(posedge clk);
            vld_d = 0;
            @(posedge clk);

            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: intr_sync_pulse only asserted 1 cycle!");

            @(posedge clk);
            @(posedge clk);
            ext_intr_sync = 0;
            @(posedge clk);
            @(posedge clk);
            ext_intr_sync = 1;
            @(posedge clk);
            @(posedge clk);
            ertn_w = 1;
            @(posedge clk);
            ertn_w = 0;
            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b1);
            report_test("Ext Intr: ertn_w asserted");
            @(posedge clk);
            current_test_passed = (intr_sync === 1'b0) && 
                                 (intr_sync_pulse === 1'b0) &&
                                 (pic_csr_ext_intr === 1'b0);
            report_test("Ext Intr: ertn_w clears intr_sync and pic_csr_ext_intr");
            @(posedge clk);
        end
    endtask
    
    // Test 3: Timer interrupt start
    task test_timer_intr_start;
        begin
            $display("\n--- Starting Test: Timer Interrupt Start ---");
            resetn = 1;
            ext_intr_sync = 0;
            csr_timer_intr_sync = 1;
            vld_d = 1;
            ertn_w = 0;
            @(negedge clk);
            
            // Check if timer interrupt starts
            current_test_passed = (intr_sync === 1'b1) && 
                                 (intr_sync_pulse === 1'b1) && 
                                 (pic_csr_ext_intr === 1'b0);
            report_test("Timer Intr Start");
        end
    endtask
    
    // Test 4: Interrupt end with ertn_w
    task test_intr_end;
        begin
            $display("\n--- Starting Test: Interrupt End ---");
            resetn = 1;
            ext_intr_sync = 1;
            csr_timer_intr_sync = 0;
            vld_d = 1;
            ertn_w = 0;
            @(negedge clk); // Start interrupt
            
            // End interrupt
            ext_intr_sync = 0;
            vld_d = 0;
            ertn_w = 1;
            @(negedge clk);
            
            // Check if interrupt ends
            current_test_passed = (intr_sync === 1'b0);
            report_test("Interrupt End");
        end
    endtask
    
    // Test 5: pic_csr_ext_intr output
    task test_pic_csr_ext_intr;
        begin
            $display("\n--- Starting Test: pic_csr_ext_intr Output ---");
            resetn = 1;
            ext_intr_sync = 1;
            csr_timer_intr_sync = 0;
            vld_d = 1;
            ertn_w = 0;
            @(negedge clk); // Start interrupt
            
            // Check pic_csr_ext_intr during external interrupt
            if (pic_csr_ext_intr === 1'b1) begin
                // Switch to timer interrupt
                ext_intr_sync = 0;
                csr_timer_intr_sync = 1;
                @(negedge clk);
                
                if (pic_csr_ext_intr === 1'b0) begin
                    current_test_passed = 1;
                end else begin
                    current_test_passed = 0;
                end
            end else begin
                current_test_passed = 0;
            end
            report_test("pic_csr_ext_intr Test");
        end
    endtask
    
    // Test 6: No interrupt without vld_d
    task test_no_vld_no_intr;
        begin
            $display("\n--- Starting Test: No Interrupt Without vld_d ---");
            resetn = 1;
            ext_intr_sync = 1;
            csr_timer_intr_sync = 1;
            vld_d = 0; // No valid signal
            ertn_w = 0;
            @(negedge clk);
            
            // Should not start interrupt
            current_test_passed = (intr_sync === 1'b0) && 
                                 (intr_sync_pulse === 1'b0);
            report_test("No Intr Without vld_d");
        end
    endtask
    
    // Main test sequence
    initial begin
        // Initialize
        clk = 0;
        test_count = 0;
        pass_count = 0;
        current_test_passed = 0;
        
        // Apply reset
        resetn = 0;
        ext_intr_sync = 0;
        csr_timer_intr_sync = 0;
        vld_d = 0;
        ertn_w = 0;
        
        // Wait a few cycles
        #20;
        
//        // Run all tests
//        test_reset();
//        #10;
//        
        
        test_ext_intr_normal();

        test_ext_intr_vld_same_cycle();

        test_ext_intr_vld_multiple();

        test_ext_intr_vld_again();

        test_ext_intr_twice();
        
        
        // Final report
        $display("\n========================================");
        $display("TEST SUMMARY:");
        $display("Total Tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", test_count - pass_count);
        $display("========================================\n");
        
        if (pass_count == test_count) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("SOME TESTS FAILED!");
        end
        
        $finish;
    end
    
    // Monitor for debugging
    initial begin
        $monitor("[%0t] resetn=%b, ext_intr=%b, timer_intr=%b, vld_d=%b, ertn_w=%b, intr_sync=%b, intr_pulse=%b, pic_csr_ext=%b",
                 $time, resetn, ext_intr_sync, csr_timer_intr_sync, vld_d, ertn_w, 
                 intr_sync, intr_sync_pulse, pic_csr_ext_intr);
    end
    
endmodule
