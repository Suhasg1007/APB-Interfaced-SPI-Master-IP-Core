# APB Interfaced SPI Master IP Core RTL Design

## Project Overview

This project presents the RTL design of an APB-interfaced SPI Master IP Core using Verilog HDL. The design integrates an APB slave interface, SPI control and status registers, a programmable baud rate generator, a shifter block, and slave-select control logic.

The project focuses on register read/write operations, SPI data transmission and reception, programmable clock generation, and RTL verification.

## Objectives

- Design an APB slave interface for register read and write operations.
- Implement Control, Status, and Data Registers.
- Generate a programmable SPI baud rate using the system clock.
- Implement a shifter block for serial data transmission and reception.
- Generate SPI clock timing according to CPOL and CPHA settings.
- Verify the design using a Verilog testbench and simulation waveforms.
- Perform RTL linting and analyze the lint report.

## Design Architecture

The SPI Core consists of the following major blocks:

- **APB Interface:** Handles APB transactions and register access.
- **Baud Rate Generator:** Generates programmable SPI clock timing.
- **Shifter:** Supports SPI data transmission and reception.
- **Slave Select Control:** Manages SPI slave selection and transfer timing.

## Tools Used

- Verilog HDL
- ModelSim – RTL simulation and waveform analysis
- Synopsys VC SpyGlass – RTL linting
- Synopsys Design Compiler / Design Vision – Synthesis flow and design visualization

## Project Files

| File | Description |
|---|---|
| `spi_core.v` | Top-level SPI core |
| `spi_apb_interface.v` | APB slave interface and register logic |
| `spi_baud_generator.v` | Programmable SPI baud rate generator |
| `spi_shifter.v` | SPI data transmission and reception |
| `spi_slave_select.v` | Slave select control |
| `spi_core_tb.v` | Verilog testbench |

## Simulation and Verification

The design was verified using a Verilog testbench in ModelSim. Simulation waveforms were analyzed to observe APB transactions and SPI-related signal behavior.

## RTL Linting

RTL linting was performed using Synopsys VC SpyGlass.

The lint report summary includes:
- Fatal issues: 0
- Errors: 0
- Warnings: 1
- Informational messages: 11

The warning and informational messages were reviewed as part of the lint analysis.

## Design Visualization

The design hierarchy and schematic were explored using Synopsys Design Vision.

## Learning Outcomes

This project provided practical experience in RTL design, APB protocol interfacing, SPI communication, simulation-based verification, RTL linting, and design visualization.

