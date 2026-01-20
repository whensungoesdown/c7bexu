// ============================================================================
// Testbench for Verification
// ============================================================================
module top_tb;

// Parameters
localparam CLK_PERIOD = 10;      // 100 MHz
localparam SYNC_STAGES = 2;

// Test Signals
reg         clk;
reg         rst_n;
reg         intr;
wire        intr_sync;
wire        intr_pulse;

// Instantiate DUT
intr_sync #(
    .SYNC_STAGES(SYNC_STAGES)
) u_dut (
    .clk            (clk),
    .rst_n          (rst_n),
    .intr       (intr),
    .intr_sync  (intr_sync),
    .intr_pulse (intr_pulse)
);

// Clock Generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Test Stimulus
initial begin
    // Initialize
    rst_n = 0;
    intr = 0;
    
    // Apply reset
    #(CLK_PERIOD*2);
    rst_n = 1;
    #(CLK_PERIOD);
    
    $display("=== Test 1: Single interrupt pulse ===");
    intr = 1;
    #(CLK_PERIOD*3);
    intr = 0;
    #(CLK_PERIOD*5);
    
    $display("=== Test 2: Long duration interrupt ===");
    intr = 1;
    #(CLK_PERIOD*10);
    intr = 0;
    #(CLK_PERIOD*5);
    
    $display("=== Test 3: Rapid interrupts ===");
    repeat (3) begin
        intr = 1;
        #(CLK_PERIOD);
        intr = 0;
        #(CLK_PERIOD);
    end
    
    $display("=== Test 4: Interrupt during reset ===");
    rst_n = 0;
    intr = 1;
    #(CLK_PERIOD*2);
    rst_n = 1;
    #(CLK_PERIOD*3);
    intr = 0;
    
    #(CLK_PERIOD*10) $display("=== Simulation Complete ===");
    $finish;
end

// Monitor
initial begin
    $monitor("Time=%0t: rst_n=%b, intr=%b, sync=%b, pulse=%b",
             $time, rst_n, intr, intr_sync, intr_pulse);
end

// Waveform dump (for debugging)
initial begin
    $dumpfile("intr_sync.vcd");
    $dumpvars(0, top_tb);
end

endmodule
