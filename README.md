# PureBasicFrameWork (PbFw)

A highly optimized, modular, and cross-platform development framework for PureBasic 6.00+.

Designed for industrial-grade applications, real-time automation tools, and high-performance engineering engines, PbFw provides a clean, fully decoupled architectural pattern that encapsulates complex low-level operations into independent, thread-safe service modules.

## 🏛️ Repository & Folder Structure

The PureBasicFrameWork is systematically organized into distinct top-level directories to separate core logic from industrial implementations and UI applications:

*   `/Modules` : The structural heart of the framework. Houses all standalone, decoupled, and highly optimized service modules (`PbFw_Module_...`).
*   `/Demo`    : Ready-to-run application templates, benchmark scripts, and complete workspaces (including the new real-time interactive DSP Studio) to demonstrate cross-module integration.
*   `/OOP`     : Advanced Object-Oriented Programming abstractions and modular class/interface design patterns implemented inside PureBasic's procedural layout.
*   `/PLC`     : Programmable Logic Controller communication backends, industrial network layers, and factory automation protocols (e.g., Siemens S7 communication trees).

---

## ⚡ Technical Highlights

The framework stands out by injecting native, high-performance features rarely found inside procedural dialects. Here are the core technological pillars:

### ⚡ PX Core Extensions & Pointer-Optimized Performance
The foundation layer injecting optimized macro patterns and pointer-operations into the PB workspace:
*   **Universal Pointers (`pAny` / `pChar`):** C-like memory matrices providing raw, non-converting concurrent datatype mapping on memory boundaries.
*   **Inline Logic Branches:** High-speed logical macro selectors (`IIFn`, `IIFs`, `IIFsf`) that completely remove standard `If/Else` evaluation penalties inside speed-critical loops.

### 🎵 Real-Time Audio & Digital Signal Processing (NEW!)
Turn PureBasic into a powerful real-time audio workstation running on a high-priority background execution thread (`DSP_AudioIO`):
*   **Studio-Grade DSP Chains:** In-place block processing for 12 window functions, full parametric IIR filters, and professional dynamics processors (Compressor, Expander, Look-Ahead Brickwall Limiter, and Noise Gate with Hold timers).
*   **Modulation & Time Domains:** Continuous fractional sub-sample delay paths, LFO-driven Chorus/Flanger modulators, and low-latency Time-Domain Pitch Shifting.
*   **Acoustic Convolution Reverb:** Fast frequency-domain convolution using an optimized Overlap-Add FFT method to process massive room impulse response structures effortlessly.
*   **Signal Analysis & Metering:** Microsecond-accurate Peak & RMS level calculators (dBFS), Crest Factor evaluation (dynamic density tracking), real-time monophonic Pitch Detection (Autocorrelation), and TPDF Dithering for 16-Bit exports.

### 🎨 Modern Visualizations & Drawing Engines
Hardware-accelerated, studio-quality graphical interfaces utilizing modern graphic layers:
*   **Echtzeit-Scopes:** Smooth, hardware-accelerated `VectorDrawing` panels providing sub-pixel anti-aliased live Oscilloscopes and professional Logarithmic Frequency Analyzers (20 Hz to 20 kHz).
*   **High-Fidelity Rendering:** Low-level acceleration frameworks for rendering complex vector curves, multi-matrix color alignments, and raw SVG vectors directly onto native UI nodes.

### 🗣️ Phonetics & Linguistic Text Analysis
Advanced sound-matching, fuzzy text querying, and human-friendly sequence ordering:
*   **Phonetic Encoders:** Full native string-pointer execution of phonetic encodings including **Soundex (EN/DE variants)** and **Cologne Phonetics** (*Kölner Phonetik*) to compare and identify similar-sounding words or names regardless of spelling.
*   **Fuzzy Search Mechanics:** Integrated algorithmic text distance calculators (Levenshtein, Jaro-Winkler) to detect keyboard typos and drive responsive search autofills.
*   **Natural Sorting:** Human-friendly sorting routines (`NaturalSort`) that intelligently arrange mixed alphanumeric files (e.g., sorting "File 2" before "File 10").

### 🎛️ Low-Level Bit, Byte & SPS/PLC Manipulation
Industrial bitwise utilities optimized via multi-backend compiler targets (Classic, ASM32, ASM64, and C-Backend Builtins):
*   **Industrial Converters:** Fast, standalone encoders and decoders for **Gray Code** (position sensors) and **Binary Coded Decimals** (`INTtoBCD`/`BCDtoINT`) backed by strict 16-digit verification filters.
*   **Hardware Bit-Shuffling:** Vector-masked bit-packing routines (`BitShuffle8`/`BitShuffle16`) utilizing specialized CPU machine instructions (`PSHUFB`, `PEXT`, `PDEP`) to manipulate boolean buffers instantly.
*   **Endianness Swap Pipelines:** Zero-overhead network byte swapping (`BSWAP16`, `BSWAP32`, `BSWAP64`) mapped directly to hardware intrinsics (`!bswap`, `__builtin_bswap`) for instantaneous data-interchange processing.

### 💻 Hardware Architecture & CPU Diagnostics
Processor state monitoring and architecture verification:
*   **Feature-Flag Auditing:** Dynamic validation of over 90 CPU instruction flag extensions (SSE4.2, AVX2, AES-NI, BMI2, AVX-512) via automated lookup registers.
*   **Silicon Profiling:** Readouts for stepping IDs, core topology maps (`GetActiveCoreNo`), hypervisor layers (VMware, VirtualBox, Hyper-V detection), and hardware execution time-stamp counters (`ReadTimeStampCounter`).

---

## 🚀 Requirements & Getting Started

*   **Compiler Prerequisite:** Every application utilizing this framework **MUST** have the **"Create thread-safe executable"** flag enabled in the PureBasic IDE Compiler Options!
*   **Precision Standard:** Mathematical and signal processing chains are universally designed in Double (.d) precision.
*   **Platform Scope:** Cross-platform natively (Windows, macOS, Linux).

To initialize the module map inside your workspace, simply pull the main include file:

```purebasic
; Pull the central backbone include
XIncludeFile "Modules/PbFw_Main_Inculde.pbi"

; The framework services are now fully initialized and accessible!
Main::InitializeApplication()
```

## 🤝 Contributing
Contributions are highly welcome! Whether you want to add industrial PLC protocols, expand the class templates inside the OOP layer, optimize string streams with custom assembly, or build audio blocks inside the real-time DSP Studio, feel free to open a Pull Request.

---
Maintained by Maagic7 and co-authored with support from Google Gemini. Licensed under the MIT License.
