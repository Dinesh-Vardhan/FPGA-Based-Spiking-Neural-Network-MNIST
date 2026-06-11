`timescale 1ns / 1ps

module weight_rom #(
    parameter NUM_NEURONS  = 100,
    parameter PIXEL_COUNT  = 784,
    parameter WEIGHT_WIDTH = 8
)(
    input  wire [6:0] neuron_id,     // 0 to 99
    input  wire [9:0] pixel_idx,     // 0 to 783
    output reg  [WEIGHT_WIDTH-1:0] weight_out
);

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

    reg [3:0] digit_group;
    reg [7:0] base_weight;

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
    end

    always @(*) begin
        digit_group = neuron_id / 10;
        base_weight = 8'd0;

        case (digit_group)
            4'd0: base_weight = digit0_mem[pixel_idx];
            4'd1: base_weight = digit1_mem[pixel_idx];
            4'd2: base_weight = digit2_mem[pixel_idx];
            4'd3: base_weight = digit3_mem[pixel_idx];
            4'd4: base_weight = digit4_mem[pixel_idx];
            4'd5: base_weight = digit5_mem[pixel_idx];
            4'd6: base_weight = digit6_mem[pixel_idx];
            4'd7: base_weight = digit7_mem[pixel_idx];
            4'd8: base_weight = digit8_mem[pixel_idx];
            4'd9: base_weight = digit9_mem[pixel_idx];
            default: base_weight = 8'd0;
        endcase

        // small within-group diversity
        weight_out = base_weight + (neuron_id % 10);
    end

endmodule
