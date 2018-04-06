.data
Array:	.space 40
Space:	.asciiz ", "
Period:	.asciiz ". "
Prompt: .asciiz "Please enter 10 numbers: \n"
Prompt2:.asciiz "Enter any number: "


.text
.globl main



main:
		la		$s0, Array # $s0 points to the first value of Array.
		la     $s5, Array
		jal		ReadNums # jump and link ReadNums;

		la  $t0, Array
		add $t0, $t0, 40
	outterLoop:
		add $t1, $0, $0
		la  $s0, Array
	innerLoop:
		lw  $t2, 0($s0)
		lw  $t3, 4($s0)
		slt $t5, $t2, $t3
		beq $t5, $0, continue
		add $t1, $0, 1
		sw  $t2, 4($s0)
		sw  $t3, 0($s0)
	continue:
		addi $s0, $s0, 4
		bne  $s0, $t0, innerLoop
		bne  $t1, $0, outterLoop

		addi $s5, 4
		move 		$s0, $s5
		li		$s2, 0
		jal		PrintNums # jump and link PrintNums

		j		exit # jump to exit.


ReadNums:
		la		$a0, Prompt # gets the amount of numbers we want saved into s1.
		li		$v0, 4
		syscall
		li		$s1, 10
		li		$s2, 0 # amount of numbers we've added so far.
		move	$s3, $ra
		jal		GetNums
		move	$ra, $s3
		jr		$ra


GetNums:
		la		$a0, Prompt2 # gets a number in $v0.
		li		$v0, 4
		syscall
		li		$v0, 5
		syscall
		sw		$v0, 0($s0) # saves $v0 at wherever $s0 points.
		addi	$s0, $s0, 4 # move $s0 forward.
		addi	$s2, $s2, 1
		addi	$s6, $s6, 4
		beq		$s1, $s2, Break
		j GetNums

Break: #
		jr		$ra



PrintNums:
move $s3, $ra
jal	PrintLoop # jump to PrintLoop;
move $ra, $s3
jr $ra

PrintLoop:
lw $a0, ($s0) # load value into $a0.
li $v0, 1
syscall
addi $s0, $s0, 4
addi $s2, $s2, 1
beq $s2, 10, EndPrint # if we have printed 10 numbers, then we have done
la $a0, Space # load Comma into $a0
li $v0, 4 # load 4 into $v0 to print a string
syscall
j	PrintLoop # loop back up.

EndPrint:
	la $a0, Period # load Period into $a0.
	li $v0, 4 # load 4 into $v0 to print a string.
	syscall # prints a period and a space.
	j	Break # return to line 121.

	exit:	li		$v0, 10 # load 10 into $v0
			syscall # close program.
