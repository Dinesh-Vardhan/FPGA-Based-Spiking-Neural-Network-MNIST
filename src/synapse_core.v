`timescale 1ns / 1ps

module synapse_core #(
    parameter WEIGHT_WIDTH = 8,
    parameter STATE_WIDTH  = 16,
    parameter DECAY_VALUE  = 1
)(
    input  wire                         clk,
    input  wire                         rst,
    input  wire                         image_start,
    input  wire                         pre_spike,
    input  wire [WEIGHT_WIDTH-1:0]      weight_in,
    output reg  [STATE_WIDTH-1:0]       syn_current
);

    reg [STATE_WIDTH-1:0] next_syn;

    always @(*) begin
        if (syn_current > DECAY_VALUE)
            next_syn = syn_current - DECAY_VALUE;
        else
            next_syn = 0;

        if (pre_spike)
            next_syn = next_syn + weight_in;
    end

    always @(posedge clk) begin
        if (rst)
            syn_current <= 0;
        else if (image_start)
            syn_current <= 0;
        else
            syn_current <= next_syn;
    end

endmodule
