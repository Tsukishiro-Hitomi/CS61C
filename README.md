# CS61C — Great Ideas in Computer Architecture

UC Berkeley CS61C 课程作业实现。**版本：Spring 2026**

## Projects
- `pj1` — Snake 游戏：C 语言指针、动态内存管理与文件读写
- `pj2` CS61Classify — 用 **RISC-V 汇编**实现全连接神经网络分类器：矩阵乘法、点积、ReLU、argmax 与矩阵文件读写
- `pj3` CS61CPU — 用 **Logisim** 搭建 RISC-V CPU：ALU、寄存器堆、立即数生成、分支比较、控制逻辑与非对齐访存
- `pj4` — 卷积计算的性能优化：SIMD、OpenMP 与 MPI 三级并行。实测（见 `pj4/src/result.txt`）：
  - SIMD：4.70× -- 5.04×
  - SIMD + OpenMP：5.52× -- 9.18×

## Labs
`lab00`–`lab07`：C 语言与调试、指针与内存、RISC-V、CALL、逻辑电路与 Logisim 等。
