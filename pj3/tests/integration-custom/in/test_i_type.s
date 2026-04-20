# 仅限 I 型指令（无任何内存加载/存储）
# 允许寄存器：ra, sp, t0, t1, t2, s0, s1, a0
# 覆盖：addi slli srli srai slti xori ori andi

# ---------- addi 立即数加法 ----------
addi t0, x0, 35
addi t1, x0, -63
addi t2, x0, 127
addi s0, x0, 0
addi s1, x0, -2048
addi a0, x0, 2047

# ---------- 移位 I型指令 ----------
addi a0, x0, 17
slli t0, a0, 1
srli t1, a0, 2

addi a0, x0, -24
srai t2, a0, 2

# ---------- slti 立即数比较 ----------
addi a0, x0, 42
slti s0, a0, 100
slti s1, a0, 30

# ---------- 位运算 I型：xori ori andi ----------
addi a0, x0, 79
xori t0, a0, 15
ori  t1, a0, 31
andi t2, a0, 8
