# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
.data
	base_display_addr: .word 0x10008000	# base address for display ($gp)
	max_display_addr: .word 0x1000C000	# max address for display (offset of 16384 = 4 * (512 / 8)^2 from base_display_addr)
.text
init:
	lw $t0, base_display_addr		# $t0 stores the base address for display
	lw $t1, max_display_addr		# $t1 stores the max address for display
game_loop:
	jal clear_screen
	jal draw
	jal wait_frame
	j game_loop
draw:
	jr $ra
wait_frame:
	li $v0, 32				# load 32 into $v0 to specify that we want the sleep syscall
	li $a0, 17				# load 17 millisconds as argument to sleep function (into $a0)
	syscall					# Execute sleep function call
	jr $ra		
clear_screen:
	lw $t8, base_display_addr		# $t8 stores current_display_addr
	li $t9, 000f0000			# $t9 stores the black colour code
clear_loop:
	bge $t8, $t1, clear_return		# branch (current_display_addr >= max_display_addr)
						# otherwise, current_display_addr < max_display_addr
	sw $t9, 0($t8)
	add $t8, $t8, 4				# increment current_display_addr
	j clear_loop
clear_return:
	jr $ra
exit:
	li $v0, 10 # terminate the program gracefully
	syscall
