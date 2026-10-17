# Audio and Digital Signal Processing DSP:: 
A modular,  Signal Processing (DSP) and Audio Library written entirely in native PureBasic. 
This project implements a full suite of studio-grade audio effects, real-time visualizers, 
and signal processors running on an autonomous virtual hardware stream.



## Core Features
*   Autonomous Audio Engine: Simulates a real-time hardware callback stream using a dedicated high-priority background thread with zero external DLL dependencies.
*   Advanced Windowing Engine: Supports 12 parametric and classic window functions (Hann, Hamming, Blackman-Harris, Kaiser, Welch, Tukey, etc.).
*   Fourier Transformations: Ultra-fast Radix-2 In-Place FFT/IFFT (Cooley-Tukey architecture optimized via compiler-native swaps) & STFT capability.
*   IIR Biquad Filters: Real-time, structurally cached Low-Pass, High-Pass, Band-Pass, Notch, Low-Shelf, High-Shelf, and Parametric Peaking EQs.
*   Dynamics Processors: High-speed multi-mode Compressor/Expander, a true Look-Ahead Brickwall Limiter, and a fast-tracking Noise Gate with Hold timers.
*   Time & Modulation: Continuous fractional sub-sample Delay loops, LFO-driven Chorus/Flanger, and a Time-Domain Pitch Shifter.
*   Convolution & Reverb: High-speed Time-Domain FIR Convolution and Fast Frequency-Domain Convolution Reverb (Overlap-Add method).
*   Signal Correction & Utilities: Windowed Sinc Interpolated Resampler, 1-pole DC-Offset Removal, Phase Inversion, Peak/RMS Level Metering (dBFS), and Triangular (TPDF) Dithering to 16-Bit.
*   Signal Generation: Phase-locked Wave Oscillators (Sine, Triangle, Saw, PWM Square) & Voss-McCartney Pink/White Noise Generators.

## Performance Optimizations
The library has been engineered from the ground up for critical real-time execution bounds:
*   Loop Unswitching: Conditional branches (`Select/Case` blocks) are checked exactly once per block execution, completely bypassing them inside innermost loops to eliminate CPU branch mispredictions.
*   In-Register Local Caching: Array structures and pointer metrics are fetched into local registers (`Protected` variables) inside loops to eliminate structural pointer overhead and memory bus latency.
*   Zero Variable Divisions: Normalization values and fractions are pre-calculated as inverse constants outside the loops, substituting slow divisions with high-speed CPU multiplications.
*   Thread-Safe Encapsulation: Built following a strict modular architecture. The application state is owned exclusively by the central coordinator (`Main::`), while critical rendering domains are synchronized using mutual exclusions (`Mutex`).

## Architecture & Requirements
The Library is embeded in the PureBasicFrameWork
*   Language version: PureBasic 6.00+
*   Floating Point Precision: Double (.d)
*   Operating System: Cross-platform (Windows, macOS, Linux)
*   Compiler Requirement: **Thread-Safe** option must be enabled in the Compiler Options!

## Project File Layout
*   `DSP_main.pb`: Main application GUI orchestrator, thread coordinator, and event loop.
*   `PbFw_Module_DSP.pb`: Core mathematical DSP algorithm library containing filters, transformations, and dynamics.
*   `DSP_AudioIO.pb`: Virtual background hardware stream and audio thread simulator.
*   `Dsp_Draw.pb`: Hardware-accelerated VectorDrawing engine rendering the live Oscilloscope and Logarithmic Frequenz-Analyzer spectrum.

---
Co-authored with support from Google Gemini. Licensed under the MIT License.
