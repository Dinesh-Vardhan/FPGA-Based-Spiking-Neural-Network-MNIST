# FPGA-Based Spiking Neural Network (SNN) for MNIST Digit Recognition

## Overview

This project presents a hardware-oriented implementation of a Spiking Neural Network (SNN) accelerator using Verilog HDL for handwritten digit recognition on the MNIST dataset.

The design incorporates biologically inspired neural computation techniques including:

- Leaky Integrate-and-Fire (LIF) neurons
- Spike-Timing-Dependent Plasticity (STDP)
- Poisson Spike Encoding
- Winner-Take-All (WTA) inhibition
- Adaptive Threshold Mechanism

The architecture is designed for FPGA deployment and neuromorphic computing research.

---

## Project Architecture

### Top-Level Architecture

![Top Architecture](architecture/Top-level SNN architecture.png)

### Training and Inference Flow

![Training Flow](architecture/training-and-inference-flow.png)

---

## Design Flow

MNIST Image

↓

Poisson Spike Encoder

↓

Synapse Layer

↓

LIF Neuron Array

↓

Winner-Take-All Competition

↓

Digit Prediction

---

## Major Modules

### Poisson Spike Generator

Converts pixel intensities into spike trains using a pseudo-random LFSR-based encoding mechanism.

### Synapse Core

Models synaptic current accumulation and decay behavior.

### LIF Neuron

Implements membrane potential integration, leakage, threshold detection, and spike generation.

### STDP Learning Engine

Updates synaptic weights based on spike timing relationships between pre- and post-synaptic neurons.

### Adaptive Threshold

Adjusts neuron firing thresholds dynamically to encourage competitive learning.

### Winner-Take-All (WTA)

Selects the dominant firing neuron while suppressing competing neurons.

---

## Technologies Used

- Verilog HDL
- Xilinx Vivado
- FPGA-oriented RTL Design
- Neuromorphic Computing
- Digital VLSI Design

---

## Waveforms

### Neuron Behavior

![Neuron Waveform](waveforms/Vivado waveform for neuron behavior.png
)

### Winner Selection

![WTA Waveform](waveforms/wta_img.png)

---

## Applications

- Neuromorphic Computing
- Edge AI
- Low-Power Machine Learning
- Robotics
- FPGA-Based AI Accelerators
- Brain-Inspired Computing Systems

---

## Key Learnings

- Hardware implementation of Spiking Neural Networks
- RTL design of biologically inspired neural architectures
- STDP-based online learning mechanisms
- Winner-Take-All competition logic
- FPGA-oriented AI accelerator development
- Digital design verification using Vivado

---

## Future Improvements

- FPGA deployment on Xilinx boards
- Larger neuron populations
- Convolutional SNN architectures
- SystemVerilog verification environment
- Hardware performance optimization
