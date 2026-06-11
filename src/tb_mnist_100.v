`timescale 1ns / 1ps

module tb_mnist_100;

    parameter NUM_IMAGES       = 100;
    parameter PIXELS_PER_IMAGE = 784;
    parameter TOTAL_PIXELS     = NUM_IMAGES * PIXELS_PER_IMAGE;
    parameter NUM_NEURONS      = 100;
    parameter CYCLES_PER_PIXEL = 2;
    parameter TRAIN_EPOCHS     = 1;

    reg clk;
    reg rst;
    reg image_start;
    reg pixel_valid;
    reg image_done;
    reg train_mode;
    reg [7:0] pixel_in;
    reg [9:0] pixel_idx;

    wire [NUM_NEURONS-1:0] neuron_spikes;
    wire [NUM_NEURONS-1:0] inhibit_bus;
    wire [6:0] winner_idx;
    wire winner_valid;
    wire [3:0] predicted_digit;

    reg [7:0] image_mem [0:TOTAL_PIXELS-1];

    integer epoch;
    integer img_idx;
    integer i;
    integer c;
    integer expected_digit;
    integer correct_count_train;
    integer correct_count_test;

    snn_core_100 #(
        .NUM_NEURONS(NUM_NEURONS),
        .PIXEL_WIDTH(8),
        .WEIGHT_WIDTH(8),
        .SYN_WIDTH(16),
        .MEM_WIDTH(16),
        .THRESH_WIDTH(16)
    ) uut (
        .clk(clk),
        .rst(rst),
        .image_start(image_start),
        .pixel_valid(pixel_valid),
        .image_done(image_done),
        .train_mode(train_mode),
        .pixel_in(pixel_in),
        .pixel_idx(pixel_idx),
        .neuron_spikes(neuron_spikes),
        .inhibit_bus(inhibit_bus),
        .winner_idx(winner_idx),
        .winner_valid(winner_valid),
        .predicted_digit(predicted_digit)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        image_start = 0;
        pixel_valid = 0;
        image_done = 0;
        train_mode = 0;
        pixel_in = 0;
        pixel_idx = 0;
        correct_count_train = 0;
        correct_count_test  = 0;

        $readmemh("D:\\GPT SNN PAPER\\snn\\data\\mnist_batch_100.txt", image_mem);

        #50;
        rst = 0;
        #20;

        // =========================
        // PHASE 1: TRAINING EPOCHS
        // =========================
        train_mode = 1'b1;
        $display("==========================================");
        $display("STARTING TRAINING PHASE (STDP ENABLED)");
        $display("TRAIN EPOCHS = %0d", TRAIN_EPOCHS);
        $display("==========================================");

        for (epoch = 0; epoch < TRAIN_EPOCHS; epoch = epoch + 1) begin
            correct_count_train = 0;
            $display("------------------------------------------");
            $display("TRAINING EPOCH %0d", epoch + 1);
            $display("------------------------------------------");

            for (img_idx = 0; img_idx < NUM_IMAGES; img_idx = img_idx + 1) begin
                expected_digit = img_idx / 10;

                image_start = 1;
                #10;
                image_start = 0;

                for (i = 0; i < PIXELS_PER_IMAGE; i = i + 1) begin
                    pixel_idx = i[9:0];
                    pixel_in  = image_mem[img_idx * PIXELS_PER_IMAGE + i];

                    for (c = 0; c < CYCLES_PER_PIXEL; c = c + 1) begin
                        pixel_valid = 1;
                        #10;
                    end
                end

                pixel_valid = 0;
                pixel_in    = 0;
                pixel_idx   = 0;

                image_done = 1;
                #10;
                image_done = 0;

                #20;

                if (predicted_digit == expected_digit)
                    correct_count_train = correct_count_train + 1;

                $display("[TRAIN E%0d] Image %0d | Expected = %0d | Predicted = %0d | Winner = %0d | Valid = %0d | Correct so far = %0d",
                         epoch + 1, img_idx, expected_digit, predicted_digit, winner_idx, winner_valid, correct_count_train);

                #20;
            end

            $display("EPOCH %0d TRAIN ACCURACY = %0d / %0d", epoch + 1, correct_count_train, NUM_IMAGES);
        end

        $display("==========================================");
        $display("TRAINING COMPLETE");
        $display("==========================================");

        // IMPORTANT: no reset here, keep learned weights
        #100;

        // =========================
        // PHASE 2: FINAL INFERENCE
        // =========================
        train_mode = 1'b0;
        correct_count_test = 0;

        $display("==========================================");
        $display("STARTING INFERENCE PHASE (STDP DISABLED)");
        $display("==========================================");

        for (img_idx = 0; img_idx < NUM_IMAGES; img_idx = img_idx + 1) begin
            expected_digit = img_idx / 10;

            image_start = 1;
            #10;
            image_start = 0;

            for (i = 0; i < PIXELS_PER_IMAGE; i = i + 1) begin
                pixel_idx = i[9:0];
                pixel_in  = image_mem[img_idx * PIXELS_PER_IMAGE + i];

                for (c = 0; c < CYCLES_PER_PIXEL; c = c + 1) begin
                    pixel_valid = 1;
                    #10;
                end
            end

            pixel_valid = 0;
            pixel_in    = 0;
            pixel_idx   = 0;

            image_done = 1;
            #10;
            image_done = 0;

            #20;

            if (predicted_digit == expected_digit)
                correct_count_test = correct_count_test + 1;

            $display("[TEST] Image %0d | Expected = %0d | Predicted = %0d | Winner = %0d | Valid = %0d | Correct so far = %0d",
                     img_idx, expected_digit, predicted_digit, winner_idx, winner_valid, correct_count_test);

            #20;
        end

        $display("==========================================");
        $display("FINAL TEST ACCURACY = %0d / %0d", correct_count_test, NUM_IMAGES);
        $display("==========================================");

        $finish;
    end

endmodule
