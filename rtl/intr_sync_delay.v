module intr_sync_delay #(
    parameter SYNC_STAGES = 2  // Number of synchronization stages (typically 2 or 3)
) (
    // Clock and Reset
    input   wire        clk,           // System clock
    input   wire        rst_n,         // Asynchronous active-low reset

    // Interrupt Interface
    input   wire        intr,          // Asynchronous external interrupt input
    input   wire        ifu_exu_vld_d,
    output  wire        intr_sync,     // Synchronized interrupt level signal
    output  wire        intr_pulse     // Synchronized interrupt pulse (one clock cycle)
);

    // ==============================
    // 1. Synchronization Chain
    // ==============================
    reg [SYNC_STAGES-1:0] sync_ff;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_ff <= {SYNC_STAGES{1'b0}};
        end else begin
            sync_ff <= {sync_ff[SYNC_STAGES-2:0], intr};
        end
    end

    assign intr_sync = sync_ff[SYNC_STAGES-1];

    // ==============================
    // 2. Edge Detection
    // ==============================
    reg intr_sync_prev;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            intr_sync_prev <= 1'b0;
        end else begin
            intr_sync_prev <= intr_sync;
        end
    end

    // Rising edge detection
    wire intr_rising_edge = intr_sync & ~intr_sync_prev;

    // ==============================
    // 3. Pulse Generation with Delay
    // ==============================
    reg pending_pulse;     // Pending interrupt pulse
    reg delayed_pulse;     // Delayed pulse output

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pending_pulse <= 1'b0;
            delayed_pulse <= 1'b0;
        end else begin
            // Capture rising edge as pending pulse
            if (intr_rising_edge) begin
                pending_pulse <= 1'b1;
            end
            // When ifu_exu_vld_d is valid and we have pending pulse
            else if (ifu_exu_vld_d & pending_pulse) begin
                pending_pulse <= 1'b0;
                delayed_pulse <= 1'b1;
            end else begin
                delayed_pulse <= 1'b0;
            end
        end
    end

    assign intr_pulse = delayed_pulse;

    // ==============================
    // 4. Alternative Implementation with FSM
    // ==============================
    /*
    // Optional FSM-based implementation for better clarity
    localparam IDLE   = 2'b00;
    localparam PENDING = 2'b01;
    localparam SEND   = 2'b10;
    
    reg [1:0] state, next_state;
    
    // State transition
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // Next state logic
    always @(*) begin
        case (state)
            IDLE: begin
                if (intr_rising_edge)
                    next_state = PENDING;
                else
                    next_state = IDLE;
            end
            PENDING: begin
                if (ifu_exu_vld_d)
                    next_state = SEND;
                else
                    next_state = PENDING;
            end
            SEND: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end
    
    // Output logic
    assign intr_pulse = (state == SEND);
    */

endmodule
