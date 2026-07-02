# Morse Code Translator & Audio Synthesizer

An interactive 16-bit x86 Assembly application built for the DOS environment using **MASM (Microsoft Macro Assembler)**. This project implements a fully bidirectional Morse Code translator that handles alpha-numeric conversions, features a multi-entry translation history stack, uses a dynamic speaker beep synthesis engine, and provides adjustable transmission speed controls.

---

## 🛠️ Features Breakdown

### 1. Bidirectional Translation
* **Text to Morse Code:** Translates English sentences and numbers `0-9` into standard Morse symbols (dots `.` and dashes `-`). Automatically normalizes lowercase text to uppercase.
* **Morse Code to Text:** Decodes Morse code sequences back into characters. Uses a standardized space delimiter (` `) between individual letters and forward slashes (`/`) to process word breaks.

### 2. Audio Beep Synthesis Engine
* Generates synchronized audible audio tones directly through BIOS interrupts (`INT 21H, DL=07H`).
* Distinctly separates short audio signals for dots and extended loop chains to generate long dashes.

### 3. Adjustable Morse Transmission Speed
* Modulates the `INT 15H, AH=86H` system delay loops dynamically across three pre-calibrated configurations:
  * **Slow:** Generates longer beeps and deep-silence spacing intervals.
  * **Medium:** Standardized timing sequence.
  * **Fast:** Aggressive, low-latency microsecond audio pulses for high-speed transmission simulation.

### 4. Dynamic Rolling History Buffer
* Implements a 250-byte rolling cache that retains the **last 5 processed strings**.
* Utilizes string manipulation primitives (`REP MOVSB` and `LODSB`/`STOSB`) to shift memory frames backward when the allocation index reaches capacity, discarding the oldest record.

---

## 🏗️ Technical Architecture & Memory Layout

* **Memory Model:** `.MODEL SMALL` (allocates single data segment and single code segment to minimize cache footprint).
* **Stack:** `.STACK 100H` (256-byte stack space for preserving register frames during deep subprocedure execution).
* **Data Structures:** * Linear Look-Up Vector Tables (`ALPHABET_TABLE` and `NUMBER_TABLE`) containing near-pointers (`DW`) pointing to terminal string arrays (`$`).
  * Index tracking using raw hex manipulation to map character offsets directly to memory structures:
    $$\text{Target Offset} = (\text{ASCII Code} - \text{Base Offset}) \times 2$$

---

## 🕹️ User Controls & Interface Guide

Upon loading the application, you will see a stylized DOS terminal menu window:

```text
--- MORSE CODE TRANSLATOR ---
1. Text to Morse Code
2. Morse Code to Text
3. History Buffer
4. Adjustable Morse Speed

Enter your choice:
