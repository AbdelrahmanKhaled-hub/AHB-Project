AHB-Lite SoC System

Overview

This project implements a complete AMBA AHB-Lite SoC system in Verilog, designed for simulation and functional verification.
The system contains:

A Master Testbench that acts as the AHB-Lite bus master.

A Generic Slave Interface for consistent communication with all slave modules.

Three custom slave modules:

GPIO – General Purpose Input/Output interface.

Timer – Simple timer peripheral for counting operations.

Register File – Configurable register storage for data read/write.

Combinational logic components for generating control signals, including:

Address Decoder – Selects the active slave based on the address.

Multiplexer – Routes read data from the active slave to the master.

AHB-Project/
├── rtl/                  # RTL source code
│   ├── master/           # Master interface
│   ├── slaves/           # Slave implementations
│   ├── decoder.v         # Address decoder
│   └── mux.v            # Control signal multiplexor
├── tb/                   # Testbench
│   └── master_tb.v       # Master testbench
├── docs/                 # Documentation
│   ├── spec/             # Protocol specifications
│   └── timing/           # Timing diagrams
└── scripts/             # Simulation/validation scripts
