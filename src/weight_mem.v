`timescale 1ns / 1ps

module weight_mem #(
    parameter NEURON_ID     = 0,
    parameter PIXEL_COUNT   = 784,
    parameter WEIGHT_WIDTH  = 8
)(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     image_start,
    input  wire                     train_mode,
    input  wire                     pre_spike,
    input  wire                     post_spike,
    input  wire [9:0]               pixel_idx,
    output wire [WEIGHT_WIDTH-1:0]  current_weight
);

    integer k;
    localparam [3:0] DIGIT_GROUP = NEURON_ID / 10;

    reg [7:0] mem [0:PIXEL_COUNT-1];

    reg [7:0] digit0_mem [0:783];
    reg [7:0] digit1_mem [0:783];
    reg [7:0] digit2_mem [0:783];
    reg [7:0] digit3_mem [0:783];
    reg [7:0] digit4_mem [0:783];
    reg [7:0] digit5_mem [0:783];
    reg [7:0] digit6_mem [0:783];
    reg [7:0] digit7_mem [0:783];
    reg [7:0] digit8_mem [0:783];
    reg [7:0] digit9_mem [0:783];

    wire [WEIGHT_WIDTH-1:0] stdp_weight_out;
    wire [7:0] x_pre, y1_post, y2_post;

    assign current_weight = mem[pixel_idx];

    initial begin
        $readmemh("D:/GPT SNN PAPER/snn/templates/digit_0.mem", digit0_mem);
        $readmemh("D:/GPT SNN PAPER/snn/templates/digit_1.mem", digit1_mem);
        $readmemh("D:/GPT SNN PAPER/snn/templates/digit_2.mem", digit2_mem);
        $readmemh("D:/GPT SNN PAPER/snn/templates/digit_3.mem", digit3_mem);
        $readmemh("D:/GPT SNN PAPER/snn/templates/digit_4.mem", digit4_mem);
        $readmemh("D:/GPT SNN PAPER/snn/templates/digit_5.mem", digit5_mem);
        $readmemh("D:/GPT SNN PAPER/snn/templates/digit_6.mem", digit6_mem);
        $readmemh("D:/GPT SNN PAPER/snn/templates/digit_7.mem", digit7_mem);
        $readmemh("D:/GPT SNN PAPER/snn/templates/digit_8.mem", digit8_mem);
        $readmemh("D:/GPT SNN PAPER/snn/templates/digit_9.mem", digit9_mem);

        for (k = 0; k < PIXEL_COUNT; k = k + 1) begin
            case (DIGIT_GROUP)
                4'd0: mem[k] = digit0_mem[k] + (NEURON_ID % 10);
                4'd1: mem[k] = digit1_mem[k] + (NEURON_ID % 10);
                4'd2: mem[k] = digit2_mem[k] + (NEURON_ID % 10);
                4'd3: mem[k] = digit3_mem[k] + (NEURON_ID % 10);
                4'd4: mem[k] = digit4_mem[k] + (NEURON_ID % 10);
                4'd5: mem[k] = digit5_mem[k] + (NEURON_ID % 10);
                4'd6: mem[k] = digit6_mem[k] + (NEURON_ID % 10);
                4'd7: mem[k] = digit7_mem[k] + (NEURON_ID % 10);
                4'd8: mem[k] = digit8_mem[k] + (NEURON_ID % 10);
                4'd9: mem[k] = digit9_mem[k] + (NEURON_ID % 10);
                default: mem[k] = 8'd1;
            endcase
        end
    end

    stdp_core #(
        .WEIGHT_WIDTH(WEIGHT_WIDTH),
        .TRACE_WIDTH(8),
        .MAX_WEIGHT(8'd255),
        .MIN_WEIGHT(8'd1),
        .MU_PRE(8'd1),
        .MU_POST(8'd1),
        .TRACE_MAX(8'd255),
        .DECAY_SHIFT(4)
    ) stdp_inst (
        .clk(clk),
        .rst(rst),
        .image_start(image_start),
        .train_mode(train_mode),
        .pre_spike(pre_spike),
        .post_spike(post_spike),
        .weight_in(mem[pixel_idx]),
        .weight_out(stdp_weight_out),
        .x_pre(x_pre),
        .y1_post(y1_post),
        .y2_post(y2_post)
    );

    always @(posedge clk) begin
        if (!rst && train_mode && post_spike) begin
            mem[pixel_idx] <= stdp_weight_out;
        end
    end

endmodule
