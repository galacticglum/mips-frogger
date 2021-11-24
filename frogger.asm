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
	li $t2, 0xffffff			# $t2 stores the colour code for white
game_loop:
	jal clear_screen
	jal draw
	jal wait_frame
	j game_loop
draw:
	li $a0, 1
	li $a1, 1
	jal draw_empty_tile
	
	li $a0, 2
	li $a1, 2
	jal draw_empty_tile
	
	jr $ra
draw_empty_tile:
	# Draws an 8x8 empty tile 
	# Arguments:
	#  - $a0 stores the TOP LEFT X coordinate
	#  - $a1 stores the TOP LEFT Y coordinate
	#
	addi $t7, $ra, 0	# save the return address of the caller
	jal pixel_coords_to_memory_addr
	addi $ra, $t7, 0	# restore the return address of the caller
	# draw the tile
	sw $t2, 0($v0)
	jr $ra
pixel_coords_to_memory_addr:
	# Get the memory address corresponding to the given pixel coordinates.
	# Arguments:
	#  - $a0 stores the X coordinate
	#  - $a1 stores the Y coordinate
	# Returns: the memory address stored in $v0
	#
	# translate tile coordinates into pixel coordinates
	sll $a0, $a0, 3	# multiply $a0 by 8 (tile width)
	sll $a1, $a1, 3	# multiply $a1 by 8 (tile height)

	# translate pixel coordinates to address space
	# $t8 stores the top left coordinate of the tile in address space
	addi $v0, $a1, 0
	sll $v0, $v0, 6		# mutliply $t8 by 512 / 8 = 64 (shift by 6 = log2(64) positions)
	add $v0, $v0, $a0	# add horizontal offset $a0 to $t8
	sll $v0, $v0, 2		# multiply $t8 by 4 to get memory address of top left coordinate
	add $v0, $v0, $t0	# offset $t8 by base_display_addr
	
	jr $ra
wait_frame:
	li $v0, 32				# load 32 into $v0 to specify that we want the sleep syscall
	li $a0, 17				# load 17 millisconds as argument to sleep function (into $a0)
	syscall					# Execute sleep function call
	jr $ra		
clear_screen:
	lw $t8, base_display_addr		# $t8 stores current_display_addr
	li $t9, 0x000000			# $t9 stores the black colour code
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
