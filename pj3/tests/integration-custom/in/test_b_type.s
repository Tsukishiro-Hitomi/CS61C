# 6 条 B 型指令 完整测试
# beq, bne, blt, bge, bltu, bgeu

# 初始化数据
addi t0, x0, 5
addi t1, x0, 5
addi t2, x0, 10
addi s0, x0, -1
addi s1, x0, 0

# 1. beq 相等跳转
beq t0, t1, beq_pass
addi s1, x0, 1
beq_pass:

# 2. bne 不相等跳转
bne t0, t2, bne_pass
addi s1, x0, 2
bne_pass:

# 3. blt 有符号小于跳转
blt s0, t0, blt_pass
addi s1, x0, 3
blt_pass:

# 4. bge 有符号大于等于跳转
bge t0, s0, bge_pass
addi s1, x0, 4
bge_pass:

# 5. bltu 无符号小于跳转
bltu t0, t2, bltu_pass
addi s1, x0, 5
bltu_pass:

# 6. bgeu 无符号大于等于跳转
bgeu t2, t0, bgeu_pass
addi s1, x0, 6
bgeu_pass:

# 正确结束
addi a0, x0, 1
