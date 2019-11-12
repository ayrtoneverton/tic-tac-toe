.data
map: .word 0
red: .asciiz "\nRed Winner!\n"
blue: .asciiz "\nBlue Winner!\n"
none: .asciiz "\nNo one won!\n"

.text   

# Constants
li $t1, 0xFFFFFF # Initial white color, if $t1 == 0xFF0000 then Player Red else Player Blue

# Bitmap columns
li $t5, 29 # Max
li $t2, 1 # Count X
barY1:
	li $t3, 0 # Count Y
	mulu $t4, $t2, 20 # Increment Memory
	barY2:
		addu $t4, $t4, 128 # Jump line
		sw $t1, map($t4)
		addu $t3, $t3, 1
		bne $t3, $t5, barY2 # End column
	addu $t2, $t2, 1
	bne $t2, 6, barY1

# Bitmap rows
li $t2, 1 # Count X
barX1:
	li $t3, 0 # Count Y
	mulu $t4, $t2, 5
	mulu $t4, $t4, 128 # Increment Memory
	barX2:
		addu $t4, $t4, 4
		sw $t1, map($t4)
		addu $t3, $t3, 1
		bne $t3, $t5, barX2 # End line
	addu $t2, $t2, 1
	bne $t2, 6, barX1

li $t9, 0 # Count runs
# Game loop
run:
	li $v0, 5 # Load number X
	syscall
	move $t2, $v0 # X
	li $v0, 5 # Load number Y
	syscall
	move $t3, $v0 # Y

	# Calculate address ($t4)
	mulu $t4, $t2, 20
	addu $t4, $t4, 132
	mulu $t5, $t3, 640
	addu $t4, $t4, $t5

	beq $t1, 0xFF0000, elseColor
		li $t1, 0xFF0000 # Red
		j fillingColor
	elseColor:
		li $t1, 0x0000FF # Blue

	fillingColor:
	li $t7, 0
	fillingColor1:
		mulu $t6, $t7, 128
		addu $t6, $t6, $t4
		addu $t5, $t6, 16
		fillingColor2:
			sw $t1, map($t6)
			addu $t6, $t6, 4
			bne $t6, $t5, fillingColor2
		addu $t7, $t7, 1
		bne $t7, 4, fillingColor1

# Check winner =========================================================================

	# 0 < X
	slt $t5, $zero, $t2
	beqz $t5, checkWinner2
	add $t6, $t4, -12 # left
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner2
	add $t6, $t4, 24 # right
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner2
	j selectPlayer # winner

	checkWinner2:
	# 0 < Y
	slt $t5, $zero, $t3
	beqz $t5, checkWinner3
	add $t6, $t4, -384 # up
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner3
	add $t6, $t4, 768 # down
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner3
	j selectPlayer # winner

	checkWinner3:
	# 0 < Y - 1
	add $t5, $t3, -1
	slt $t5, $zero, $t5
	beqz $t5, checkWinner4
	add $t6, $t4, -384 # up
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner4
	add $t6, $t4, -1024 # up up
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner4
	j selectPlayer # winner

	checkWinner4:
	add $t6, $t4, 768 # down
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner5
	add $t6, $t4, 1408 # down down
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner5
	j selectPlayer # winner

	checkWinner5:
	# 0 < X - 1
	add $t5, $t2, -1
	slt $t5, $zero, $t5
	beqz $t5, checkWinner6
	add $t6, $t4, -12 # left
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner6
	add $t6, $t4, -36 # left left
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner6
	j selectPlayer # winner

	checkWinner6:
	add $t6, $t4, 24 # right
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner7
	add $t6, $t4, 44 # right right
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner7
	j selectPlayer # winner

	checkWinner7:
	# 0 < X  and 0 < Y
	slt $t5, $zero, $t2
	beqz $t5, checkWinner8
	slt $t5, $zero, $t3
	beqz $t5, checkWinner8
	add $t6, $t4, -396 # up left
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner8
	add $t6, $t4, 792 # down right
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner8
	j selectPlayer # winner

	checkWinner8:
	# 0 < X  and 0 < Y
	slt $t5, $zero, $t2
	beqz $t5, checkWinner9
	slt $t5, $zero, $t3
	beqz $t5, checkWinner9
	add $t6, $t4, -360 # up right
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner9
	add $t6, $t4, 756 # down left
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner9
	j selectPlayer # winner

	checkWinner9:
	# 0 < X - 1
	add $t5, $t2, -1
	slt $t5, $zero, $t5
	beqz $t5, checkWinner10
	add $t6, $t4, 756 # down left
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner10
	add $t6, $t4, 1372 # down left down left
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner10
	j selectPlayer # winner

	checkWinner10:
	# 0 < Y - 1
	add $t5, $t3, -1
	slt $t5, $zero, $t5
	beqz $t5, checkWinner11
	add $t6, $t4, -360 # up right
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner11
	add $t6, $t4, -980 # up right up right
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner11
	j selectPlayer # winner

	checkWinner11:
	add $t6, $t4, 792 # down right
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner12
	add $t6, $t4, 1452 # down right down right
	lw $t6, map($t6)
	bne $t6, $t1, checkWinner12
	j selectPlayer # winner

	checkWinner12:
	# 0 < X - 1 and 0 < Y - 1
	add $t5, $t2, -1
	slt $t5, $zero, $t5
	beqz $t5, endRun
	add $t5, $t3, -1
	slt $t5, $zero, $t5
	beqz $t5, endRun
	add $t6, $t4, -396 # up left
	lw $t6, map($t6)
	bne $t6, $t1, endRun
	add $t6, $t4, -1060 # up left up left
	lw $t6, map($t6)
	bne $t6, $t1, endRun
	j selectPlayer # winner

# End check winner =====================================================================

	endRun:
	addu $t9, $t9, 1
	bne $t9, 36, run
	li $t1, 0

# Select player
selectPlayer:
bne $t1, 0xFF0000, elseIfPlayer
	la $a0, red
	j printWinner
elseIfPlayer:
	bne $t1, 0x0000FF, elsePlayer
	la $a0, blue
	j printWinner
elsePlayer:
	la $a0, none

# Print player
printWinner:
li $v0, 4
syscall
