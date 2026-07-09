.text
global 0 ag_wAGU

    lhu     x4, 6(x0)
    lhu     x3, 8(x0)

    mul     x4, x4, x10

    lui     x10, 1024
    add     x11, x4, x11

    // ------------------------------------------------------------
    // Hot path: M == 8
    // M==8이면 branch not taken으로 바로 wagu_m8_fast 실행.
    // M!=8이면 wagu_not_m8로 분기.
    // ------------------------------------------------------------
    addi    x7, x3, -8
    bnez    x7, wagu_not_m8


wagu_m8_fast:
    slli    x11, x11, 3
    sh2add  x11, x11, x10
    lui     x10, 1312

    lw      x5, 0(x10)
    lw      x6, 4(x10)
    lw      x7, 8(x10)
    lw      x8, 12(x10)
    lw      x9, 16(x10)
    lw      x12, 20(x10)
    lw      x13, 24(x10)
    lw      x14, 28(x10)

    sw      x5, 0(x11)
    sw      x6, 4(x11)
    sw      x7, 8(x11)
    sw      x8, 12(x11)
    sw      x9, 16(x11)
    sw      x12, 20(x11)
    sw      x13, 24(x11)
    sw      x14, 28(x11)

    ret


wagu_not_m8:
    addi    x7, x3, -4
    beqz    x7, wagu_m4_fast

    addi    x7, x3, -16
    beqz    x7, wagu_m16_fast

    addi    x7, x3, -32
    beqz    x7, wagu_m32_fast

    j       wagu_m64_fast


wagu_m4_fast:
    slli    x11, x11, 2
    sh2add  x11, x11, x10
    lui     x10, 1312

    lw      x5, 0(x10)
    lw      x6, 4(x10)
    lw      x7, 8(x10)
    lw      x8, 12(x10)

    sw      x5, 0(x11)
    sw      x6, 4(x11)
    sw      x7, 8(x11)
    sw      x8, 12(x11)

    ret


wagu_m16_fast:
    slli    x11, x11, 4
    sh2add  x11, x11, x10
    lui     x10, 1312

    lw      x5, 0(x10)
    lw      x6, 4(x10)
    lw      x7, 8(x10)
    lw      x8, 12(x10)
    lw      x9, 16(x10)
    lw      x12, 20(x10)
    lw      x13, 24(x10)
    lw      x14, 28(x10)
    lw      x15, 32(x10)
    lw      x16, 36(x10)
    lw      x17, 40(x10)
    lw      x18, 44(x10)
    lw      x19, 48(x10)
    lw      x20, 52(x10)
    lw      x21, 56(x10)
    lw      x22, 60(x10)

    sw      x5, 0(x11)
    sw      x6, 4(x11)
    sw      x7, 8(x11)
    sw      x8, 12(x11)
    sw      x9, 16(x11)
    sw      x12, 20(x11)
    sw      x13, 24(x11)
    sw      x14, 28(x11)
    sw      x15, 32(x11)
    sw      x16, 36(x11)
    sw      x17, 40(x11)
    sw      x18, 44(x11)
    sw      x19, 48(x11)
    sw      x20, 52(x11)
    sw      x21, 56(x11)
    sw      x22, 60(x11)

    ret


wagu_m32_fast:
    slli    x11, x11, 5
    sh2add  x11, x11, x10
    lui     x10, 1312

    lw      x5, 0(x10)
    lw      x6, 4(x10)
    lw      x7, 8(x10)
    lw      x8, 12(x10)
    lw      x9, 16(x10)
    lw      x12, 20(x10)
    lw      x13, 24(x10)
    lw      x14, 28(x10)
    lw      x15, 32(x10)
    lw      x16, 36(x10)
    lw      x17, 40(x10)
    lw      x18, 44(x10)
    lw      x19, 48(x10)
    lw      x20, 52(x10)
    lw      x21, 56(x10)
    lw      x22, 60(x10)

    sw      x5, 0(x11)
    sw      x6, 4(x11)
    sw      x7, 8(x11)
    sw      x8, 12(x11)
    sw      x9, 16(x11)
    sw      x12, 20(x11)
    sw      x13, 24(x11)
    sw      x14, 28(x11)
    sw      x15, 32(x11)
    sw      x16, 36(x11)
    sw      x17, 40(x11)
    sw      x18, 44(x11)
    sw      x19, 48(x11)
    sw      x20, 52(x11)
    sw      x21, 56(x11)
    sw      x22, 60(x11)

    lw      x5, 64(x10)
    lw      x6, 68(x10)
    lw      x7, 72(x10)
    lw      x8, 76(x10)
    lw      x9, 80(x10)
    lw      x12, 84(x10)
    lw      x13, 88(x10)
    lw      x14, 92(x10)
    lw      x15, 96(x10)
    lw      x16, 100(x10)
    lw      x17, 104(x10)
    lw      x18, 108(x10)
    lw      x19, 112(x10)
    lw      x20, 116(x10)
    lw      x21, 120(x10)
    lw      x22, 124(x10)

    sw      x5, 64(x11)
    sw      x6, 68(x11)
    sw      x7, 72(x11)
    sw      x8, 76(x11)
    sw      x9, 80(x11)
    sw      x12, 84(x11)
    sw      x13, 88(x11)
    sw      x14, 92(x11)
    sw      x15, 96(x11)
    sw      x16, 100(x11)
    sw      x17, 104(x11)
    sw      x18, 108(x11)
    sw      x19, 112(x11)
    sw      x20, 116(x11)
    sw      x21, 120(x11)
    sw      x22, 124(x11)

    ret


wagu_m64_fast:
    slli    x11, x11, 6
    sh2add  x11, x11, x10
    lui     x10, 1312

    lw      x5, 0(x10)
    lw      x6, 4(x10)
    lw      x7, 8(x10)
    lw      x8, 12(x10)
    lw      x9, 16(x10)
    lw      x12, 20(x10)
    lw      x13, 24(x10)
    lw      x14, 28(x10)
    lw      x15, 32(x10)
    lw      x16, 36(x10)
    lw      x17, 40(x10)
    lw      x18, 44(x10)
    lw      x19, 48(x10)
    lw      x20, 52(x10)
    lw      x21, 56(x10)
    lw      x22, 60(x10)

    sw      x5, 0(x11)
    sw      x6, 4(x11)
    sw      x7, 8(x11)
    sw      x8, 12(x11)
    sw      x9, 16(x11)
    sw      x12, 20(x11)
    sw      x13, 24(x11)
    sw      x14, 28(x11)
    sw      x15, 32(x11)
    sw      x16, 36(x11)
    sw      x17, 40(x11)
    sw      x18, 44(x11)
    sw      x19, 48(x11)
    sw      x20, 52(x11)
    sw      x21, 56(x11)
    sw      x22, 60(x11)

    lw      x5, 64(x10)
    lw      x6, 68(x10)
    lw      x7, 72(x10)
    lw      x8, 76(x10)
    lw      x9, 80(x10)
    lw      x12, 84(x10)
    lw      x13, 88(x10)
    lw      x14, 92(x10)
    lw      x15, 96(x10)
    lw      x16, 100(x10)
    lw      x17, 104(x10)
    lw      x18, 108(x10)
    lw      x19, 112(x10)
    lw      x20, 116(x10)
    lw      x21, 120(x10)
    lw      x22, 124(x10)

    sw      x5, 64(x11)
    sw      x6, 68(x11)
    sw      x7, 72(x11)
    sw      x8, 76(x11)
    sw      x9, 80(x11)
    sw      x12, 84(x11)
    sw      x13, 88(x11)
    sw      x14, 92(x11)
    sw      x15, 96(x11)
    sw      x16, 100(x11)
    sw      x17, 104(x11)
    sw      x18, 108(x11)
    sw      x19, 112(x11)
    sw      x20, 116(x11)
    sw      x21, 120(x11)
    sw      x22, 124(x11)

    lw      x5, 128(x10)
    lw      x6, 132(x10)
    lw      x7, 136(x10)
    lw      x8, 140(x10)
    lw      x9, 144(x10)
    lw      x12, 148(x10)
    lw      x13, 152(x10)
    lw      x14, 156(x10)
    lw      x15, 160(x10)
    lw      x16, 164(x10)
    lw      x17, 168(x10)
    lw      x18, 172(x10)
    lw      x19, 176(x10)
    lw      x20, 180(x10)
    lw      x21, 184(x10)
    lw      x22, 188(x10)

    sw      x5, 128(x11)
    sw      x6, 132(x11)
    sw      x7, 136(x11)
    sw      x8, 140(x11)
    sw      x9, 144(x11)
    sw      x12, 148(x11)
    sw      x13, 152(x11)
    sw      x14, 156(x11)
    sw      x15, 160(x11)
    sw      x16, 164(x11)
    sw      x17, 168(x11)
    sw      x18, 172(x11)
    sw      x19, 176(x11)
    sw      x20, 180(x11)
    sw      x21, 184(x11)
    sw      x22, 188(x11)

    lw      x5, 192(x10)
    lw      x6, 196(x10)
    lw      x7, 200(x10)
    lw      x8, 204(x10)
    lw      x9, 208(x10)
    lw      x12, 212(x10)
    lw      x13, 216(x10)
    lw      x14, 220(x10)
    lw      x15, 224(x10)
    lw      x16, 228(x10)
    lw      x17, 232(x10)
    lw      x18, 236(x10)
    lw      x19, 240(x10)
    lw      x20, 244(x10)
    lw      x21, 248(x10)
    lw      x22, 252(x10)

    sw      x5, 192(x11)
    sw      x6, 196(x11)
    sw      x7, 200(x11)
    sw      x8, 204(x11)
    sw      x9, 208(x11)
    sw      x12, 212(x11)
    sw      x13, 216(x11)
    sw      x14, 220(x11)
    sw      x15, 224(x11)
    sw      x16, 228(x11)
    sw      x17, 232(x11)
    sw      x18, 236(x11)
    sw      x19, 240(x11)
    sw      x20, 244(x11)
    sw      x21, 248(x11)
    sw      x22, 252(x11)

    ret