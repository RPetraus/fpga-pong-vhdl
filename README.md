# FPGA Pong in VHDL

Two-player Pong game implemented in **VHDL** for the **DE10-Lite** FPGA development board (Intel **MAX 10** device family), with **VGA video output**, **collision detection**, **scorekeeping**, and **seven-segment display logic**.

## Overview

This project was built as part of **ECE 318** as a three-person team project. The design implements a playable two-player Pong game entirely in VHDL and uses a modular architecture for video timing, game logic, and display output. The accompanying report describes a 640 × 480 @ 60 Hz VGA synchronization pipeline, parameter-driven paddle controllers, a ball engine with collision handling, a scoring unit with win-state behavior, and BCD-to-seven-segment display decoding. Functional verification was performed in ModelSim, and the final design was demonstrated on hardware through Quartus Prime on a MAX 10 target. fileciteturn15file0 fileciteturn15file7

## Features

- Two-player Pong gameplay on an external VGA display
- Modular VHDL architecture
- Paddle control using on-board switches
- Ball motion and paddle collision detection
- Scorekeeping with win-state logic
- Seven-segment score display output
- Reset behavior for game restart

The report notes that the finished system successfully detected paddle hits and scoring events, stopped the game when a player reached 11 points, and supported score and ball reset behavior from a button input. fileciteturn15file2

## Hardware and Tools

- **Board:** Terasic DE10-Lite
- **FPGA family:** Intel MAX 10 (`10M50DAF484C7G` target in the Quartus project)
- **Language:** VHDL
- **Toolchain:** Quartus Prime 20.1, ModelSim
- **Display:** VGA

The project report’s design environment section identifies the target device as an Intel MAX 10 mounted on the Terasic DE10-Lite board, while the checked-in Quartus project file targets the MAX 10 family and device `10M50DAF484C7G`. fileciteturn15file5 fileciteturn13file0

## Repository Contents

### Core source files
- `ball.vhd`
- `paddle.vhd`
- `lines.vhd`
- `char_decoder.vhd`
- `Scoring.vhd`
- `VGA_SYNC.vhd`
- `output_files/collision.vhd`
- `output_files/sevenseg.vhd`

### Quartus project and schematic files
- `PongFinalProj.qpf`
- `PongFinalProj.qsf`
- `PongFinalProj_assignment_defaults.qdf`
- `BouncingBall.bdf`

### Symbol files
- `ball.bsf`
- `char_decoder.bsf`
- `collision.bsf`
- `lines.bsf`
- `paddle.bsf`
- `scoring.bsf`
- `Sevenseg.bsf`

### Documentation
- `docs/README.md`
- `docs/Final_Proj_Report.pdf`

## Notes

- The Quartus project currently references `output_files/collision.vhd` and `output_files/sevenseg.vhd` directly in `PongFinalProj.qsf`. That works, but a later cleanup could move those files to the repository root or a dedicated source folder and then update the Quartus file paths accordingly. fileciteturn13file0
- Generated build folders such as `db/` and `incremental_db/`, along with backup and workspace files, are intentionally excluded from version control through `.gitignore`. fileciteturn11file0 fileciteturn15file12
- The demo video is not stored in this repository to keep the repo lightweight; the project is documented here through the source files and technical report.

## Documentation

Additional project documentation is available in the [`docs`](docs) folder, including the technical report.
