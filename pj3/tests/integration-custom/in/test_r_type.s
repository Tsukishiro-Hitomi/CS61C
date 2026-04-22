# R-Type 指令测试（无报错版）
# 仅用寄存器：ra, sp, t0, t1, t2, s0, s1, a0
# 覆盖：add, sub, sll, mul, mulh, mulhu, slt, xor, srl, sra, or, and
# 所有立即数 -2048~2047，无非法指令

# 初始化小数值（全部合法）
addi  t0, x0, 15       # t0 = 15
addi  t1, x0, 3        # t1 = 3
addi  a0, x0, -15      # a0 = -15
addi  s0, x0, 200      # s0 = 200
addi  s1, x0, 2        # s1 = 2

# 1. 算术
add   t2, t0, t1       # t2 = 15+3=18
sub   s0, s0, t1       # s0 = 200-3=197

# 2. 移位
sll   t2, t0, t1       # t2 = 15<<3=120
srl   t2, t2, t1       # t2 = 120>>3=15
sra   a0, a0, s1       # a0 = -15>>2=-4

# 3. 乘法
mul   t0, t0, t1       # t0 = 15*3=45
mulh  t1, t0, t1       # 有符号乘法高32位
mulhu t2, t0, t1       # 无符号乘法高32位

# 4. 比较
addi  t0, x0, 10
addi  t1, x0, 20
slt   s0, t0, t1       # s0 = 1 (10<20)
slt   s1, t1, t0       # s1 = 0 (20<10不成立)

# 5. 位运算
addi  t0, x0, 15
addi  t1, x0, 3
xor   t2, t0, t1       # 15^3=12
or    s0, t0, t1       # 15|3=15
and   s1, t0, t1       # 15&3=3

