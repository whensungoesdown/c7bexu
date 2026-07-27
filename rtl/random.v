// 0-31 counter
module random (
    input        clk,
    input        resetn,
    output [4:0] count   // Counter value (0 to 31)
);

    // Next state: count + 1 (wraps from 31 to 0 automatically due to 5-bit width)
    wire [4:0] count_next = count + 1'b1;

    dffrl_ns #(5) count_reg (
        .din    (count_next),
        .rst_l  (resetn),
        .clk    (clk),
        .q      (count)
    );

endmodule
