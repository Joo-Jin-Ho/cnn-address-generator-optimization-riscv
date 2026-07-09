# CNN Address Generator Optimization with RISC-V
Address generation optimization for CNN acceleration on a RISC-V based architecture

구체적인 과정과 시간 단축에 사용한 기법는 report.pdf로 첨부하였습니다.

CNN 연산을 효율적으로 수행하기 위한 RISC-V 기반 하드웨어 가속기를 구현하는 프로젝트입니다. CNN Accelerator의 메모리 구조와 데이터 이동 과정을 이해하고, 프로세서와 PE 간의 데이터 전송을 담당하는 Address Generation 기능을 구현하여 CNN 연산이 효율적으로 수행될 수 있는 구조를 설계하는 것을 목표로 합니다.

# 🚀 프로젝트 개요
구현된 CNN Accelerator는 RISC-V 기반 시스템에서 CNN 연산을 수행하기 위한 하드웨어 가속기의 Address Generator을 설계하는 프로젝트입니다. CNN 연산 과정에서 입력 데이터와 가중치가 DRAM → SRAM → PE로 전달되고, 연산 결과가 다시 SRAM → DRAM으로 저장되는 전체 데이터 흐름을 제어합니다. 각 메모리 계층 간의 데이터 이동은 Memory-Mapped I/O 방식으로 이루어지며, 모든 데이터 전송은 Address Generation 모듈을 통해 수행됩니다.

메인 프로그램은 Loop Tiling 구조를 기반으로 출력 Feature Map을 Tile 단위로 분할하여 처리합니다. 각 Tile마다 ag_rDMA가 DRAM에서 SRAM으로 데이터를 로드하고, ag_rAGU가 SRAM의 데이터를 PE 입력으로 전달합니다. PE에서 CNN 연산이 완료되면 ag_wAGU가 연산 결과를 SRAM으로 저장하고, 마지막으로 ag_wDMA가 SRAM의 결과를 DRAM으로 저장하여 하나의 Tile 연산을 완료합니다.

본 프로젝트에서는 ag_rDMA, ag_rAGU, ag_wAGU, ag_wDMA의 네 가지 Address Generation 모듈을 구현하였으며, CNN Layer와 Tile 크기에 따라 올바른 메모리 주소를 생성하여 데이터가 정확한 위치로 이동하도록 설계하였습니다. 또한 다양한 CNN 구조에서 동일한 Address Generation 로직이 동작할 수 있도록 구현하여 CNN Accelerator의 효율적인 데이터 전송 구조를 구성하였습니다.

<img width="1009" height="593" alt="image" src="https://github.com/user-attachments/assets/1b056d1a-5c1d-4698-8f70-a948df0ca031" />

# Main idea
<img width="500" height="300" alt="image" src="https://github.com/user-attachments/assets/1f3ed7f5-1d4a-43ed-982a-eb747b6f3952" />

8가지의 layer에 대해 데이터를 Tile 단위로 분할하여 처리할 것입니다. 이때 Tile의 크기는 P,Q의 약수의 크기로 한정하고 Tile의 크기는 1로도 두지않습니다. 그렇게되면 총 168가지 경우에 대해서 데이터를 처리하게 되고, 실행시간은 layer마다 최대한 비중을 비슷하게 하여 계산하며 report에서는 T라고 표현하였습니다. 처음에는 C코드로 먼저 코드를 작성하고 이 코드를 Assembly로 변형한 후 이 Assembly를 최적화시키는 방향으로 T값을 줄여나갔습니다.

가장 중점적으로 한 idea는 branch를 줄여나가는 방법입니다. Risc-V에서의 Branch가 많은 코드는 분기 때문에 파이프라인이 자주 영향을 받고, 예측 실패 혹은 분기 지연으로 인해 추가 cycle이 발생할 수 있습니다. 그러므로 Branch 코드를 unroll하는 방식으로 파이프라인이 끊기지 않고 잘 흘러가도록 하였고, CPI가 1에 가까워지도록 구성하였습니다. 자주 사용하는 Tile의 크기에 대해서는 따로 그 경우에 대해 데이터를 처리하는 코드를 추가하였고, 이 방법을 통해서도 T값을 줄일 수 있었습니다.
