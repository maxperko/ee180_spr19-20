###############################################################################
# File         : sc.S
# Project      : EE180 Lab 2: MIPS
#
# Standards/Formatting:
#   MIPS gas, soft tab, 80 column
#
# Description:
#   Test the functionality of the 'sc' instruction.
#
###############################################################################


    .section .boot, "x"
    .balign 4
    .set    noreorder
    .global boot
    .ent    boot
boot:
    lui     $s0, 0x8002         # Load the base address of the status/test registers
    ori     $s1, $0, 1          # Prepare the 'done' status
    lui     $t0, 0              # Load some valid address 0x00003210 to register $t0
    ori     $t0, $t0, 0x3210
    sw      $0, 0($t0)
    ori     $t1, $0, 1
    ll      $t2, 0($t0)         # load 0 in $t2
    sc      $t1, 0($t0)         # attempt store 1 in addr in $t0
    lw      $t3, 0($t0)         # load value at addre in $t0
    and     $v0, $t1, $t3       # compare value to result of sc
    sw      $v0, 4($s0)         # Set the test result
    sw      $s1, 0($s0)         # Set 'done'

$done:
    j       $done
    nop

    .end boot
