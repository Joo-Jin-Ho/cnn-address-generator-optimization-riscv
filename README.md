# CNN Address Generator Optimization with RISC-V
Address generation optimization for CNN acceleration on a RISC-V based architecture

구체적인 과정과 시간 단축에 사용한 기법는 report.pdf로 첨부하였습니다.

CNN 연산을 효율적으로 수행하기 위한 RISC-V 기반 하드웨어 가속기를 구현하는 프로젝트입니다. CNN Accelerator의 메모리 구조와 데이터 이동 과정을 이해하고, 프로세서와 PE 간의 데이터 전송을 담당하는 Address Generation 기능을 구현하여 CNN 연산이 효율적으로 수행될 수 있는 구조를 설계하는 것을 목표로 합니다.

# 🚀 프로젝트 개요
구현된 CNN Accelerator는 RISC-V 기반 시스템에서 CNN 연산을 수행하기 위한 하드웨어 가속기의 Address Generator을 설계하는 프로젝트입니다. CNN 연산 과정에서 입력 데이터와 가중치가 DRAM → SRAM → PE로 전달되고, 연산 결과가 다시 SRAM → DRAM으로 저장되는 전체 데이터 흐름을 제어합니다. 각 메모리 계층 간의 데이터 이동은 Memory-Mapped I/O 방식으로 이루어지며, 모든 데이터 전송은 Address Generation 모듈을 통해 수행됩니다.

메인 프로그램은 Loop Tiling 구조를 기반으로 출력 Feature Map을 Tile 단위로 분할하여 처리합니다. 각 Tile마다 ag_rDMA가 DRAM에서 SRAM으로 데이터를 로드하고, ag_rAGU가 SRAM의 데이터를 PE 입력으로 전달합니다. PE에서 CNN 연산이 완료되면 ag_wAGU가 연산 결과를 SRAM으로 저장하고, 마지막으로 ag_wDMA가 SRAM의 결과를 DRAM으로 저장하여 하나의 Tile 연산을 완료합니다.

본 프로젝트에서는 ag_rDMA, ag_rAGU, ag_wAGU, ag_wDMA의 네 가지 Address Generation 모듈을 구현하였으며, CNN Layer와 Tile 크기에 따라 올바른 메모리 주소를 생성하여 데이터가 정확한 위치로 이동하도록 설계하였습니다. 또한 다양한 CNN 구조에서 동일한 Address Generation 로직이 동작할 수 있도록 구현하여 CNN Accelerator의 효율적인 데이터 전송 구조를 구성하였습니다.

<img width="1009" height="593" alt="image" src="https://github.com/user-attachments/assets/1b056d1a-5c1d-4698-8f70-a948df0ca031" />
