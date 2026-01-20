// ============================================================================
// External Interrupt Synchronizer Module
// Synchronizes asynchronous external interrupt signal to current clock domain
// Uses dffrl_ns (D flip-flop with active-low reset) for all storage elements
// Provides both synchronized level signal and synchronized pulse signal
// ============================================================================

module intr_sync #(
    parameter SYNC_STAGES = 2  // Number of synchronization stages (typically 2 or 3)
) (
    // Clock and Reset
    input   wire        clk,           // System clock
    input   wire        rst_n,         // Asynchronous active-low reset
    
    // Interrupt Interface
    input   wire        intr,      // Asynchronous external interrupt input
    output  wire        intr_sync, // Synchronized interrupt level signal
    output  wire        intr_pulse // Synchronized interrupt pulse (one clock cycle)
);

// ============================================================================
// Internal Signals Declaration
// ============================================================================

// Synchronization chain outputs
wire [SYNC_STAGES-1:0]  sync_out;      // Outputs from each synchronization stage
wire                    sync_delayed;  // Delayed version for edge detection

// ============================================================================
// Synchronization Chain Implementation
// ============================================================================

// First synchronization stage - captures asynchronous input
dffrl_ns #(
    .SIZE(1)
) sync_stage_0 (
    .din    (intr),      // Direct connection to external interrupt
    .clk    (clk),           // System clock
    .rst_l  (rst_n),         // Active-low reset
    .q      (sync_out[0])    // First synchronized output
);

// Generate additional synchronization stages if needed
genvar i;
generate
    if (SYNC_STAGES > 1) begin : sync_chain_gen
        for (i = 1; i < SYNC_STAGES; i = i + 1) begin : sync_stage
            dffrl_ns #(
                .SIZE(1)
            ) sync_ff (
                .din    (sync_out[i-1]),  // Input from previous stage
                .clk    (clk),            // System clock
                .rst_l  (rst_n),          // Active-low reset
                .q      (sync_out[i])     // Current stage output
            );
        end
    end
endgenerate

// ============================================================================
// Edge Detection Logic
// ============================================================================

// Delay flip-flop for rising edge detection
dffrl_ns #(
    .SIZE(1)
) delay_ff (
    .din    (sync_out[SYNC_STAGES-1]),  // Last stage of synchronization chain
    .clk    (clk),                      // System clock
    .rst_l  (rst_n),                    // Active-low reset
    .q      (sync_delayed)              // Delayed by one clock cycle
);

// ============================================================================
// Output Generation
// ============================================================================

// Synchronized level output - stable and aligned to clock domain
assign intr_sync = sync_out[SYNC_STAGES-1];

// Rising edge detection: produces one clock cycle pulse
// Pulse occurs when current value is 1 and previous value was 0
assign intr_pulse = sync_out[SYNC_STAGES-1] & ~sync_delayed;

endmodule
