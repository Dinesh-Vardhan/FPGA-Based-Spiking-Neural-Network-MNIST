`timescale 1ns / 1ps

module threshold_adapt #(
    parameter THRESH_WIDTH   = 16,
    parameter BASE_THRESHOLD = 16'd3000,
    parameter THRESH_STEP    = 16'd200,
    parameter DECAY_VALUE    = 16'd1
)(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     image_start,
    input  wire                     spike_in,
    output reg  [THRESH_WIDTH-1:0]  threshold_out
);

    always @(posedge clk) begin
        if (rst) begin
            threshold_out <= BASE_THRESHOLD;
        end
        else if (image_start) begin
            // keep threshold state across images but let it relax
            if (threshold_out > BASE_THRESHOLD + DECAY_VALUE)
                threshold_out <= threshold_out - DECAY_VALUE;
            else
                threshold_out <= BASE_THRESHOLD;
        end
        else begin
            // threshold rises on spike
            if (spike_in) begin
                threshold_out <= threshold_out + THRESH_STEP;
            end
            // otherwise slowly decays back toward base
            else if (threshold_out > BASE_THRESHOLD + DECAY_VALUE) begin
                threshold_out <= threshold_out - DECAY_VALUE;
            end
            else begin
                threshold_out <= BASE_THRESHOLD;
            end
        end
    end

endmodule
