# SPI-to-I2C-FIFO-Converter
# 🔄 Efficient Data Buffering and Flow Control Using FIFO in SPI to I2C Protocol Conversion

This project implements a **Verilog-based protocol converter** between **SPI** (Serial Peripheral Interface) and **I2C** (Inter-Integrated Circuit) using a **FIFO buffer**. The design ensures smooth and efficient data flow across two different communication protocols, handling clock domain mismatches and burst data transfers.

---

## 🚀 Project Overview

- **Objective**: To create a robust hardware solution for converting data from SPI input to I2C output with reliable buffering.
- **Design Components**:
  - SPI to I2C Protocol Conversion
  - FIFO-Based Data Buffer
  - State Machine Controller
- **Language**: Verilog HDL
- **Verification**: Testbench with ModelSim/GTKWave output

---

## 📁 File Structure

```bash
SPI-to-I2C-FIFO-Converter/
│
├── fifo.v                 # FIFO module for data buffering
├── spi_to_i2c_fifo.v     # Main protocol converter module
├── tb_spi_to_i2c_fifo.v  # Testbench to simulate the design
├── dump.vcd              # Generated waveform file (if using GTKWave)
├── waveform.png          # Screenshot of waveform (optional)
└── README.md             # Project documentation
