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
	c_white: .word 0xffffff		# colour code for white
	c_light_grey: .word 0xc0c0c0	# colour code for light grey
	c_dark_grey: .word 0x808080 	# colour code for dark grey
.text
game_loop:
	jal draw
	jal wait_frame
	j game_loop
draw:
init_draw_start_area_loop:
	# Draws the start area
	li $t8, 0
	addi $s0, $ra, 0
draw_start_area_loop:
	bge $t8, 8, draw_start_area_loop_done
	
	addi $a0, $t8, 0
	li $a1, 7
	jal draw_empty_tile
	
	addi $t8, $t8, 1
	j draw_start_area_loop
draw_start_area_loop_done:
	j init_draw_safe_area_loop
	
init_draw_safe_area_loop:
	# Draws the start area
	li $t8, 0
	addi $s0, $ra, 0
draw_safe_area_loop:
	bge $t8, 8, draw_safe_area_loop_done
	
	addi $a0, $t8, 0
	li $a1, 4
	jal draw_empty_tile
	
	addi $t8, $t8, 1
	j draw_safe_area_loop
draw_safe_area_loop_done:
	addi $ra, $s0, 0
	jr $ra
	

draw_empty_tile:
	# Draws an 8x8 empty tile 
	# Arguments:
	#  - $a0 stores the TOP LEFT X coordinate (0 <= X < 8)
	#  - $a1 stores the TOP LEFT Y coordinate (0 <= Y < 8)
	#
	addi $s1, $ra, 0	# save the return address of the caller
	jal pixel_coords_to_memory_addr
	addi $ra, $s1, 0	# restore the return address of the caller
	
	# Load colour values
	lw $t5, c_white
	lw $t6, c_light_grey
	lw $t7, c_dark_grey

	li $t0, 0
draw_empty_tile_outer_loop:		
	bge $t0, 8, draw_empty_tile_outer_loop_done
	add $t2, $t0, 0		# copy $t0 into $t2
	sll $t2, $t2, 8 	# multiply by 256 (64 * 4)
	add $t1, $v0, $t2
	
	addi $t2, $t1, 32
draw_empty_tile_inner_loop:
	bge $t1, $t2, draw_empty_tile_inner_loop_done

	beq $t0, 0, draw_empty_tile_if_row_0
	beq $t0, 7, draw_empty_tile_if_row_7
	# otherwise, 1 <= row <= 6
	sw $t6, 0($t1)
	j draw_empty_tile_inner_loop_end
draw_empty_tile_if_row_0:
	sw $t5, 0($t1)
	j draw_empty_tile_inner_loop_end
draw_empty_tile_if_row_7:
	sw $t7, 0($t1)
	j draw_empty_tile_inner_loop_end
draw_empty_tile_inner_loop_end:
	add $t1, $t1, 4
	j draw_empty_tile_inner_loop
draw_empty_tile_inner_loop_done:
	add $t0, $t0, 1
	j draw_empty_tile_outer_loop
draw_empty_tile_outer_loop_done:
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
	# $v0 will store the top left coordinate of the tile in address space
	addi $v0, $a1, 0
	sll $v0, $v0, 6		# mutliply by 512 / 8 = 6 (shift by 6 = log2(64) positions)
	add $v0, $v0, $a0	# add horizontal offset of $a0
	sll $v0, $v0, 2		# multiply by 4 to get memory address of top left coordinate
	
	lw $t0, base_display_addr
	add $v0, $v0, $t0	# offset by base_display_addr
	
	jr $ra
wait_frame:
	li $v0, 32	# load 32 into $v0 to specify that we want the sleep syscall
	li $a0, 17	# load 17 millisconds as argument to sleep function (into $a0)
	syscall
	jr $ra		
exit:
	li $v0, 10 # terminate the program gracefully
	syscall
