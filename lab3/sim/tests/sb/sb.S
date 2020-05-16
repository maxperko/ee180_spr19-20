###############################################################################
# File         : sb.S
# Project      : EE180 Lab 2: MIPS
#
# Standards/Formatting:
#   MIPS gas, soft tab, 80 column
#
# Description:
#   Test the functionality of the 'sb' instruction.
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
    lui     $t1, 0xde0f
    ori     $t1, $t1, 0xbeef
    lui     $t2, 0xffff
    ori     $t2, $t2, 0xffde
    sb      $t2, 3($t0)         # $t0 = 0xde000000
    ori     $t3, $0, 0x0f
    sb      $t3, 2($t0)         # $t0 = 0xde0f0000
    lui     $t4, 0xffff
    ori     $t4, $t4, 0xffbe
    sb      $t4, 1($t0)         # $t0 = 0xde0fbe00
    lui     $t5, 0xffff
    ori     $t5, $t5, 0xffee
    sb      $t5, 0($t0)         # $t0 = 0xde0fbeee   
    subu    $v0, $t1, $t0
    sw      $v0, 4($s0)         # Set the test result
    sw      $s1, 0($s0)         # Set 'done'

$done:
    j       $done
    nop

    .end boot
