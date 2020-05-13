###############################################################################
# File         : xori.S
# Project      : EE180 Lab 2: MIPS
#
# Standards/Formatting:
#   MIPS gas, soft tab, 80 column
#
# Description:
#   Test the functionality of the 'xori' instruction.
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
    ori     $t0, $0, 0xe7c8     # A = 0xe7c8
    nop
    nop
    nop
    nop
    xori    $t2, $t0, 0xe7c9    # C = xor(A,0xe7c9) = 0x1
    nop
    nop
    nop
    nop
    sw      $t2, 4($s0)         # Set the test result
    sw      $s1, 0($s0)         # Set 'done'

$done:
    j       $done
    nop

    .end boot
