`timescale 1ns / 1ps

module lif_neuron_euler #(
    parameter CURRENT_WIDTH   = 16,
    parameter MEM_WIDTH       = 16,
    parameter THRESH_WIDTH    = 16,
    parameter V_REST          = 16'd0,
    parameter V_RESET         = 16'd0,
    parameter LEAK_SHIFT      = 4   // leak strength ~ 1/16
)(
    input  wire                         clk,
    input  wire                         rst,
    input  wire                         image_start,
    input  wire                         inhibit,
    input  wire [CURRENT_WIDTH-1:0]     syn_current,
    input  wire [THRESH_WIDTH-1:0]      threshold_in,
    output reg                          spike,
    output reg  [MEM_WIDTH-1:0]         v_mem
);

    reg [MEM_WIDTH-1:0] leak_term;
    reg [MEM_WIDTH-1:0] v_next;

    always @(*) begin
        // simple leak toward rest
        if (v_mem > V_REST)
            leak_term = (v_mem - V_REST) >> LEAK_SHIFT;
        else
            leak_term = 0;

        // Euler update
        if (v_mem > leak_term)
            v_next = v_mem - leak_term + syn_current;
        else
            v_next = syn_current;
    end

    always @(posedge clk) begin
        if (rst) begin
            v_mem <= V_REST;
            spike <= 1'b0;
        end
        else if (image_start) begin
            v_mem <= V_REST;
            spike <= 1'b0;
        end
        else if (inhibit) begin
            // inhibit suppresses firing and softly resets
            v_mem <= V_RESET;
            spike <= 1'b0;
        end
        else begin
            if (v_next >= threshold_in) begin
                v_mem <= V_RESET;
                spike <= 1'b1;
            end
            else begin
                v_mem <= v_next;
                spike <= 1'b0;
            end
        end
    end

endmodule
