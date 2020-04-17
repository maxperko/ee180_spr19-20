#==============================================================================
# File:         mergesort.s (PA 1)
#
# Description:  Skeleton for assembly mergesort routine. 
#
#       To complete this assignment, add the following functionality:
#
#       1. Call mergesort. (See mergesort.c)
#          Pass 3 arguments:
#
#          ARG 1: Pointer to the first element of the array
#          (referred to as "nums" in the C code)
#
#          ARG 2: Number of elements in the array
#
#          ARG 3: Temporary array storage
#                 
#          Remember to use the correct CALLING CONVENTIONS !!!
#          Pass all arguments in the conventional way!
#
#       2. Mergesort routine.
#          The routine is recursive by definition, so mergesort MUST 
#          call itself. There are also two helper functions to implement:
#          merge, and arrcpy.
#          Again, make sure that you use the correct calling conventions!
#
#==============================================================================

.data
HOW_MANY:   .asciiz "How many elements to be sorted? "
ENTER_ELEM: .asciiz "Enter next element: "
ANS:        .asciiz "The sorted list is:\n"
SPACE:      .asciiz " "
EOL:        .asciiz "\n"

.text
.globl main

#==========================================================================
main:
#==========================================================================

    #----------------------------------------------------------
    # Register Definitions
    #----------------------------------------------------------
    # $s0 - pointer to the first element of the array
    # $s1 - number of elements in the array
    # $s2 - number of bytes in the array
    #----------------------------------------------------------
    
    #---- Store the old values into stack ---------------------
    addiu   $sp, $sp, -32
    sw      $ra, 28($sp)

    #---- Prompt user for array size --------------------------
    li      $v0, 4              # print_string
    la      $a0, HOW_MANY       # "How many elements to be sorted? "
    syscall         
    li      $v0, 5              # read_int
    syscall 
    move    $s1, $v0            # save number of elements

    #---- Create dynamic array --------------------------------
    li      $v0, 9              # sbrk
    sll     $s2, $s1, 2         # number of bytes needed
    move    $a0, $s2            # set up the argument for sbrk
    syscall
    move    $s0, $v0            # the addr of allocated memory


    #---- Prompt user for array elements ----------------------
    addu    $t1, $s0, $s2       # address of end of the array
    move    $t0, $s0            # address of the current element
    j       read_loop_cond

read_loop:
    li      $v0, 4              # print_string
    la      $a0, ENTER_ELEM     # text to be displayed
    syscall
    li      $v0, 5              # read_int
    syscall
    sw      $v0, 0($t0)     
    addiu   $t0, $t0, 4

read_loop_cond:
    bne     $t0, $t1, read_loop

    #---- Call Mergesort ---------------------------------------
    # ADD YOUR CODE HERE! 
	
	li		$v0, 9				# sbrk
	move	$a0, $s2			# set up the argument for sbrk, number of bytes needed
	syscall
	move    $a2, $v0            # the addr of allocated memory for temp_array
	move	$a1, $s2			# move array_size into a1
	jal		mergesort

    # You must use a syscall to allocate
    # temporary storage (temp_array in the C implementation)
    # then pass the three arguments in $a0, $a1, and $a2 before
    # calling mergesort

    #---- Print sorted array -----------------------------------
    li      $v0, 4              # print_string
    la      $a0, ANS            # "The sorted list is:\n"
    syscall

    #---- For loop to print array elements ----------------------
    
    #---- Iniliazing variables ----------------------------------
    move    $t0, $s0            # address of start of the array
    addu    $t1, $s0, $s2       # address of end of the array
    j       print_loop_cond

print_loop:
    li      $v0, 1              # print_integer
    lw      $a0, 0($t0)         # array[i]
    syscall
    li      $v0, 4              # print_string
    la      $a0, SPACE          # print a space
    syscall            
    addiu   $t0, $t0, 4         # increment array pointer

print_loop_cond:
    bne     $t0, $t1, print_loop

    li      $v0, 4              # print_string
    la      $a0, EOL            # "\n"
    syscall          

    #---- Exit -------------------------------------------------
    lw      $ra, 28($sp)
    addiu   $sp, $sp, 32
    jr      $ra


# ADD YOUR CODE HERE! 

mergesort:
	slti	$t0, $a1, 2			# check n < 2
	beq		$t0, $zero, mergesort_skip 
	jr		$ra

mergesort_skip:
	addiu   $sp, $sp, -32		# start callee setup
    sw      $ra, 28($sp)
	sw		$fp, 24($sp)
	addiu	$fp, $sp, 28
	sw		$s0, 20($sp)		# end callee setup
	sw		$a0, 16($sp)		# start recursive caller setup
	sw		$a1, 12$sp)
	sw		$a2, 8($sp)
	sw 		$a3, 4($sp)			# end recursive caller setup
	
	move	$s0, $a1			# $s0 = n
	srl		$a1, $a1, 1			# mid = n/2
	jal		mergesort			# a0 = array, a1 = mid, a2 = temp_array
	
	addu	$a0, $a0, $a1		# array + mid
	move	$a3, $a1			# $a3 = mid
	sub		$a1, $s0, $a1		# $a1 = n - mid
	jal		mergesort			# a0 = array + mid, a1 = n - mid, a2 = temp_array
	
	sub		$a0, $a0, $a3		# a0 = array + mid - mid
	move	$a1, $s0			# a1 = n
	jal		merge
	
	lw		$a0, 16($sp)		# start recursive caller teardown
	lw		$a1, 12($sp)
	lw		$a2, 8($sp)
	lw		$a3, 4($sp)			# end recursive caller teardown
	lw		$s0, 20($20)		# start callee teardown
	lw		$fp, 24($sp)
	lw      $ra, 28($sp)		# end callee teardown
    addiu   $sp, $sp, 32
    jr      $ra

merge:
    addiu   $sp, $sp, -32		# start callee setup
    sw      $ra, 28($sp)
	sw		$fp, 24($sp)
	addiu	$fp, $sp, 28
	sw		$s0, 20($sp)		# end callee setup
	sw		$a0, 16($sp)		# start recursive caller setup
	sw		$a1, 12$sp)
	sw		$a2, 8($sp)
	sw 		$a3, 4($sp)			# end recursive caller setup

    add     $t0, $zero, $zero   # tpos = $t0 = 0
    add     $t1, $zero, $zero   # lpos = $t1 = 0
    add     $t2, $zero, $zero   # rpos = $t2 = 0
    sub     $t3, $a1, $a3       # rn = $t3 = n - mid
    add     $t4, $a0, $a3       # *rarr = $t4 = array + mid
    j		merge_while_cond	# jump to merge_while_cond
merge_while_loop:
    sll     $t8, $t1, 2             # $t8 = lpos * 4
    sll     $t9, $t2, 2             # $t9 = rpos * 4
    add     $t8, $a0, $t8           # &(array[lpos])
    add     $t9, $t4, $t9           # &(rarr[rpos])
    lw      $t8, 0($t8)             # array[lpos] = $a0[$t1]
    lw      $t9, 0($t9)             # rarr[rpos] = $t4[$t2]
    slt     $s7, $t8, $t9           # $s7 = ($t8 < $t9) = (array[lpos] < rarr[rpos])
    beq     $s7, $zero, merge_else  # if ($t8 < $t9), go to merge_else
    sll     $s7, $t0, 2             # $s7 = tpos * 4
    add     $s7, $a2, $s7           # &(temp_array[tpos]) = &($a2[$t0])
    sw      $t8, 0($s7)             # temp_array[tpos] = array[lpos], $a2[$t0] = $a0[$t1]
    addi    $t0, $t0, 1             # tpos++
    addi    $t1, $t1, 1             # lpos++
    j		merge_while_cond		# jump to merge_while_cond
merge else:
    sll     $s7, $t0, 2             # $s7 = tpos * 4
    add     $s7, $a2, $s7           # &(temp_array[tpos]) = &($a2[$t0])
    sw      $t9, 0($s7)             # temp_array[tpos] = rarr[rpos], $a2[$t0] = $t4[$t2]
    addi    $t0, $t0, 1             # tpos++
    addi    $t2, $t2, 1             # rpos++
merge_while_cond:
    slt     $t5, $t1, $a3                   # $t5 = (lpos < mid)
    slt     $t6, $t2, $t3                   # $t6 = (rpos < n-mid)
    and     $t7, $t5, $t6                   # $t7 = (lpos < mid) && (rpos < n-mid)
    bne     $t7, $zero, merge_while_loop    # if $t7 = 1 != 0 goto while loop
merge_if_lpos:
    bne     $t5, $zero, merge_end_cond       # goto merge_if_rpos if (lpos < mid)
    sll     $s6, $t0, 2                     # $s6 = tpos * 4
    sll     $s7, $t1, 2                     # $s7 = lpos * 4
    add     $s3, $a2, $s6                   # $s3 = $a2 + $s6 = temp_array + tpos
    add     $s4, $a0, $s7                   # $s4 = $a0 + $s7 = array + lpos
    sub     $s5, $a3, $t1                   # $s5 = $a3 - $t1 = mid - lpos
    move    $a0, $s3
    move    $a1, $s4
    move    $a2, $s5
    jal     arrcpy                          # call arrcpy
merge_if_rpos:
    bne     $t6, $zero, merge_end           # goto merge_if_rpos if (rpos < rn)
    sll     $s6, $t0, 2                     # $s6 = tpos * 4
    sll     $s7, $t2, 2                     # $s7 = rpos * 4
    add     $s3, $a2, $s6                   # $s3 = $a2 + $s6 = temp_array + tpos
    add     $s4, $t4, $s7                   # $s4 = $t4 + $s7 = rarr + rpos
    sub     $s5, $t3, $t2                   # $s5 = $t3 - $t2 = rn - rpos
    move    $a0, $s3
    move    $a1, $s4
    move    $a2, $s5
    jal     arrcpy                          # call arrcpy
merge_end:
    move    $t0, $a1
    move    $a1, $a2
    move    $a2, $t0
    jal     arrcpy              # call arrcpy
    lw		$a0, 16($sp)		# start recursive caller teardown
	lw		$a1, 12($sp)
	lw		$a2, 8($sp)
	lw		$a3, 4($sp)			# end recursive caller teardown
	lw		$s0, 20($20)		# start callee teardown
	lw		$fp, 24($sp)
	lw      $ra, 28($sp)		# end callee teardown
    addiu   $sp, $sp, 32
    jr      $ra

arrcpy:
    add     $t0, $zero, $zero   # init i = 0
    j		arrcpy_test				# jump to test
arrcpy_loop:    
    sll     $t1, $t0, 2         # $t1 = i*4
    add     $t1, $a1, $t1       # &(src[i])
    lw      $t1, 0($t1)         # src[i]
    sll     $t2, $t0, 2         # $t2 = i*4
    add     $t2, $a0, $t2       # &(dst[i])
    sw      $t1, 0($t2)         # dst[i] = src[i]
    addi    $t0, $t0, 1         # i++
arrcpy_test:
    slt     $t1, $t0, $a2       # $t1 = (i<n)
    bne     $t1, $zero, arrcpy_loop    # if i<n, go to loop
    jr      $ra
