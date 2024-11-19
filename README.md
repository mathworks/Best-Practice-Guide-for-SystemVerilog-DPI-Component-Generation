# Best Practice Guide for SystemVerilog DPI Component Generation 

HDL Verifier&trade; facilitates the generation of SystemVerilog DPI and Universal Verification Methodology (UVM) testbench components directly from MATLAB&reg; or Simulink&reg;, bridging the gap between algorithm development and design verification. This guide is tailored to enhance your MATLAB workflow by providing recommended practices for preparing MATLAB designs for SystemVerilog DPI component generation.

In this guide, you will find comprehensive coverage of topics essential for evaluating MATLAB code compatibility with code generation, including:

- Getting started with code generation
- Converting scripts to functions
- Frame/stream modeling
- Working with vectors and matrices, including variable-sized vectors and matrices
- Using floating- and fixed-point data types
- Considerations for constrained randomization
- Generating UVM components

## Setup

In MATLAB release R2023a and earlier, the DPI-C generation feature was installed with HDL Verifier. Beginning with release R2023b, this feature is available through the [ASIC Testbench for HDL Verifier](https://www.mathworks.com/products/asic-testbench.html) add-on. HDL Verifier users can download and install the ASIC Testbench add-on via the [MATLAB Add-Ons](https://www.mathworks.com/help/matlab/matlab_env/get-add-ons.html) menu or [File Exchange](https://www.mathworks.com/matlabcentral/fileexchange/128964-asic-testbench-for-hdl-verifier).

### MathWorks Products (https://www.mathworks.com)

HDL Verifier introduced support for DPI generation in R2014b. However, this guide is based on R2024a. To perform the examples in this guide, the following MathWorks products are required:

- [MATLAB](https://www.mathworks.com/products/matlab.html)
- [Fixed-Point Designer&trade;](https://www.mathworks.com/products/fixed-point-designer.html)
- [HDL Verifier](https://www.mathworks.com/products/hdl-verifier.html)
- [MATLAB Coder&trade;](https://www.mathworks.com/products/matlab-coder.html)

### 3rd Party Products:

Many commercial HDL simulators support the SystemVerilog DPI interface. However, MathWorks verifies that the generated DPI components are compatible with the following commercial HDL simulators:

- [AMD Vivado&trade; Simulator](https://docs.amd.com/r/en-US/ug937-vivado-design-suite-simulation-tutorial/Vivado-Simulator-Overview)
- [Cadence&reg; Xcelium&trade; Logic Simulator](https://www.cadence.com/en_US/home/tools/system-design-and-verification/simulation-and-testbench-verification/xcelium-simulator.html)
- [Siemens&reg; Questa&trade; Advanced Simulator](https://eda.sw.siemens.com/en-US/ic/questa/simulation/advanced-simulator/)
- [Synopsys&reg; VCS&reg; Functional Simulation](https://www.synopsys.com/verification/simulation/vcs.html)

For more information on supported HDL simulator versions and configurations, please refer to [Supported EDA Tools and Hardware – HDL Verifier](https://www.mathworks.com/help/hdlverifier/gs/supported-eda-tools.html).

## Examples

The guide includes numerous examples to illustrate key concepts. Use the MATLAB script `runme.mlx` within each example folder to get started.

## License

The license is available in the License.txt file in this GitHub repository.

## Community Support

[MATLAB Central](https://www.mathworks.com/matlabcentral/)

Copyright 2024 The MathWorks, Inc.