`timescale 1ns / 1ps

module wta_inhibit #(
    parameter NUM_NEURONS = 100,
    parameter COUNT_WIDTH = 16
)(
    input  wire                       clk,
    input  wire                       rst,
    input  wire                       image_start,
    input  wire [NUM_NEURONS-1:0]     spikes_in,
    output reg  [NUM_NEURONS-1:0]     inhibit_out,
    output reg  [6:0]                 winner_idx,
    output reg                        winner_valid
);

    integer i;

    reg [COUNT_WIDTH-1:0] spike_count [0:NUM_NEURONS-1];
    reg [COUNT_WIDTH-1:0] best_count;
    reg [COUNT_WIDTH-1:0] next_count;

    reg [6:0] local_winner_idx;
    reg local_spike_seen;

    always @(*) begin
        local_winner_idx = 7'd0;
        local_spike_seen = 1'b0;

        // choose first spiking neuron in THIS timestep only
        for (i = 0; i < NUM_NEURONS; i = i + 1) begin
            if (!local_spike_seen && spikes_in[i]) begin
                local_winner_idx = i[6:0];
                local_spike_seen = 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            winner_idx   <= 7'd0;
            winner_valid <= 1'b0;
            inhibit_out  <= {NUM_NEURONS{1'b0}};
            best_count   <= {COUNT_WIDTH{1'b0}};

            for (i = 0; i < NUM_NEURONS; i = i + 1) begin
                spike_count[i] <= {COUNT_WIDTH{1'b0}};
            end
        end
        else if (image_start) begin
            winner_idx   <= 7'd0;
            winner_valid <= 1'b0;
            inhibit_out  <= {NUM_NEURONS{1'b0}};
            best_count   <= {COUNT_WIDTH{1'b0}};

            for (i = 0; i < NUM_NEURONS; i = i + 1) begin
                spike_count[i] <= {COUNT_WIDTH{1'b0}};
            end
        end
        else begin
            // default: no inhibition
            inhibit_out <= {NUM_NEURONS{1'b0}};

            // instantaneous WTA for THIS timestep only
            if (local_spike_seen) begin
                for (i = 0; i < NUM_NEURONS; i = i + 1) begin
                    if (i == local_winner_idx)
                        inhibit_out[i] <= 1'b0;
                    else
                        inhibit_out[i] <= 1'b1;
                end
            end

            // accumulate spike counts across the image
            for (i = 0; i < NUM_NEURONS; i = i + 1) begin
                if (spikes_in[i]) begin
                    spike_count[i] <= spike_count[i] + 1'b1;
                    next_count = spike_count[i] + 1'b1;

                    if ((winner_valid == 1'b0) || (next_count > best_count)) begin
                        best_count   <= next_count;
                        winner_idx   <= i[6:0];
                        winner_valid <= 1'b1;
                    end
                end
            end
        end
    end

endmodule
