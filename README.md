# iCE40 Power Testing

This section covers various experiments with low power on the iCE40.

# Setup
The setup is the ICE40 breakout board from Lattice. This board was chosen as it breaks out all power rails of the FPGA. I used the PCF file from the UPduino as its identical. THe icestorm toolchain was used as its very fast and scriptable. The FPGA boots from CRAM not flash unless otherwise mentioned.

# Results
| Description | V_PLL (1.219V) | V_IO 0 (3.283V) | V_IO 1 (3.283V) | V_IO 2 (3.283V)| CORE (1.219V)|
| ---         | ---   | ---    | ---    | ---    | ---  |
| Unconfigured | 4.4 | 1.29   | 1552 | 1.5 | 381.6 |
| Reset        | 4.4 | 1.29 | 82.9 | 1.5 | 188.3|
| Blank design | 4.1 | 1.3  | 3.4  | 1.5 | 85.6 |
| External 12MHz + 28 bit counter (32LC's) | 4.1 | 1.3  | 3.4  | 1.5 | 613.5 |
| External 12MHz + 28*2 bit counter (60LC's) | 4.1 | 1.3  | 3.4  | 1.5 | 6136.65 |
| External 12MHz + 28*4 bit counter (116LC's) | 4.1 | 1.3  | 3.4  | 1.5 | 624.2 |
| External 12MHz + 28*8 bit counter (228LC's) | 4.1 | 1.3  | 3.4  | 1.5 | 641.3 |
| HFOSC (48MHz) | 4.1 | 3.76 | 3.4 | 1.5 | 2178 |
| HFOSC+RGB (48MHz clock) | 4.4 | 321.9 | 3.4 | 1.5 | 2195 |
| PLL (12MHz in, 48MHz output) | 138.6 | 1.29 | 3.42 | 1.4 | 1435 |

# Observations
- DONE signal take 150uA! Disconnect this for lowest power.
- The RGB driver takes ~280uA, setting the CURREN or the RGBLEDEN to zero drops this current entirely.
