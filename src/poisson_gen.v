`timescale 1ns / 1ps

module poisson_gen #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst,
    input  wire [WIDTH-1:0] pixel_intensity,
    input  wire             enable,
    output reg              spike_out
);

    reg [15:0] lfsr;

    always @(posedge clk) begin
        if (rst) begin
            lfsr <= 16'hACE1;
            spike_out <= 1'b0;
        end
        else if (enable) begin
            // 16-bit LFSR update
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};

            // Compare lower 8 random bits against pixel intensity
            if (lfsr[7:0] < pixel_intensity)
                spike_out <= 1'b1;
            else
                spike_out <= 1'b0;
        end
        else begin
            spike_out <= 1'b0;
        end
    end

endmodule
