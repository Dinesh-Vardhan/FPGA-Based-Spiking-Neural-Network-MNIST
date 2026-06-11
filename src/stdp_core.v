`timescale 1ns / 1ps

module stdp_core #(
    parameter WEIGHT_WIDTH = 8,
    parameter TRACE_WIDTH  = 8,
    parameter MAX_WEIGHT   = 8'd255,
    parameter MIN_WEIGHT   = 8'd1,
    parameter MU_PRE       = 8'd1,   // very small depression
    parameter MU_POST      = 8'd1,   // very small potentiation
    parameter TRACE_MAX    = 8'd255,
    parameter DECAY_SHIFT  = 4       // slower decay
)(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     image_start,
    input  wire                     train_mode,
    input  wire                     pre_spike,
    input  wire                     post_spike,
    input  wire [WEIGHT_WIDTH-1:0]  weight_in,
    output reg  [WEIGHT_WIDTH-1:0]  weight_out,

    output reg  [TRACE_WIDTH-1:0]   x_pre,
    output reg  [TRACE_WIDTH-1:0]   y1_post,
    output reg  [TRACE_WIDTH-1:0]   y2_post
);

    reg [TRACE_WIDTH-1:0] x_pre_next;
    reg [TRACE_WIDTH-1:0] y1_post_next;
    reg [TRACE_WIDTH-1:0] y2_post_next;

    reg [15:0] ltp_term;
    reg [15:0] ltd_term;
    reg [15:0] new_weight_calc;

    always @(*) begin
        x_pre_next   = x_pre   - (x_pre   >> DECAY_SHIFT);
        y1_post_next = y1_post - (y1_post >> DECAY_SHIFT);
        y2_post_next = y2_post - (y2_post >> DECAY_SHIFT);

        if (x_pre <= (x_pre >> DECAY_SHIFT))     x_pre_next = 0;
        if (y1_post <= (y1_post >> DECAY_SHIFT)) y1_post_next = 0;
        if (y2_post <= (y2_post >> DECAY_SHIFT)) y2_post_next = 0;

        if (pre_spike)
            x_pre_next = TRACE_MAX;

        if (post_spike) begin
            y1_post_next = TRACE_MAX;
            y2_post_next = TRACE_MAX;
        end
    end

    always @(*) begin
        ltp_term = 0;
        ltd_term = 0;
        new_weight_calc = weight_in;

        if (train_mode) begin
            // very small LTD
            if (pre_spike) begin
                ltd_term = (MU_PRE * y1_post) >> 7;
                if (weight_in > (MIN_WEIGHT + ltd_term))
                    new_weight_calc = weight_in - ltd_term;
                else
                    new_weight_calc = MIN_WEIGHT;
            end

            // very small triplet-style LTP
            if (post_spike) begin
                ltp_term = (MU_POST * x_pre * y2_post) >> 15;
                if ((new_weight_calc + ltp_term) < MAX_WEIGHT)
                    new_weight_calc = new_weight_calc + ltp_term;
                else
                    new_weight_calc = MAX_WEIGHT;
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            x_pre      <= 0;
            y1_post    <= 0;
            y2_post    <= 0;
            weight_out <= MIN_WEIGHT;
        end
        else if (image_start) begin
            x_pre      <= 0;
            y1_post    <= 0;
            y2_post    <= 0;
            weight_out <= weight_in;
        end
        else begin
            x_pre      <= x_pre_next;
            y1_post    <= y1_post_next;
            y2_post    <= y2_post_next;
            weight_out <= new_weight_calc[WEIGHT_WIDTH-1:0];
        end
    end

endmodule
