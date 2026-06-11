`timescale 1ns / 1ps

module snn_core_100 #(
    parameter NUM_NEURONS    = 100,
    parameter PIXEL_WIDTH    = 8,
    parameter WEIGHT_WIDTH   = 8,
    parameter SYN_WIDTH      = 16,
    parameter MEM_WIDTH      = 16,
    parameter THRESH_WIDTH   = 16
)(
    input  wire                         clk,
    input  wire                         rst,
    input  wire                         image_start,
    input  wire                         pixel_valid,
    input  wire                         image_done,
    input  wire                         train_mode,
    input  wire [PIXEL_WIDTH-1:0]       pixel_in,
    input  wire [9:0]                   pixel_idx,

    output wire [NUM_NEURONS-1:0]       neuron_spikes,
    output wire [NUM_NEURONS-1:0]       inhibit_bus,
    output wire [6:0]                   winner_idx,
    output wire                         winner_valid,
    output wire [3:0]                   predicted_digit
);

    wire input_spike;

    poisson_gen #(
        .WIDTH(PIXEL_WIDTH)
    ) poisson_inst (
        .clk(clk),
        .rst(rst),
        .pixel_intensity(pixel_in),
        .enable(pixel_valid),
        .spike_out(input_spike)
    );

    genvar i;

    generate
        for (i = 0; i < NUM_NEURONS; i = i + 1) begin : neuron_array
            wire [WEIGHT_WIDTH-1:0]  weight_i;
            wire [SYN_WIDTH-1:0]     syn_i;
            wire [MEM_WIDTH-1:0]     vmem_i;
            wire [THRESH_WIDTH-1:0]  thresh_i;
            wire                     spike_i;
            wire                     inhibit_i;

            assign inhibit_i = inhibit_bus[i];

            weight_mem #(
                .NEURON_ID(i),
                .PIXEL_COUNT(784),
                .WEIGHT_WIDTH(WEIGHT_WIDTH)
            ) weight_mem_inst (
                .clk(clk),
                .rst(rst),
                .image_start(image_start),
                .train_mode(train_mode),
                .pre_spike(input_spike),
                .post_spike(spike_i),
                .pixel_idx(pixel_idx),
                .current_weight(weight_i)
            );

            synapse_core #(
                .WEIGHT_WIDTH(WEIGHT_WIDTH),
                .STATE_WIDTH(SYN_WIDTH),
                .DECAY_VALUE(1)
            ) synapse_inst (
                .clk(clk),
                .rst(rst),
                .image_start(image_start),
                .pre_spike(input_spike),
                .weight_in(weight_i),
                .syn_current(syn_i)
            );

            threshold_adapt #(
                .THRESH_WIDTH(THRESH_WIDTH),
                .BASE_THRESHOLD(16'd2400),
                .THRESH_STEP(16'd200),
                .DECAY_VALUE(16'd1)
            ) thresh_inst (
                .clk(clk),
                .rst(rst),
                .image_start(image_start),
                .spike_in(spike_i),
                .threshold_out(thresh_i)
            );

            lif_neuron_euler #(
                .CURRENT_WIDTH(SYN_WIDTH),
                .MEM_WIDTH(MEM_WIDTH),
                .THRESH_WIDTH(THRESH_WIDTH),
                .V_REST(16'd0),
                .V_RESET(16'd0),
                .LEAK_SHIFT(4)
            ) neuron_inst (
                .clk(clk),
                .rst(rst),
                .image_start(image_start),
                .inhibit(inhibit_i),
                .syn_current(syn_i),
                .threshold_in(thresh_i),
                .spike(spike_i),
                .v_mem(vmem_i)
            );

            assign neuron_spikes[i] = spike_i;
        end
    endgenerate

    wta_inhibit #(
        .NUM_NEURONS(NUM_NEURONS)
    ) wta_inst (
        .clk(clk),
        .rst(rst),
        .image_start(image_start),
        .spikes_in(neuron_spikes),
        .inhibit_out(inhibit_bus),
        .winner_idx(winner_idx),
        .winner_valid(winner_valid)
    );

    assign predicted_digit = winner_idx / 10;

endmodule
