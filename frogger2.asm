# Bitmap Display Configuration:
# - Unit width in pixels: 1
# - Unit height in pixels: 1
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data
	# Reserve the next 262144 bytes (e.g. 256 * 256 = 65536) for the bitmap data.
	# This makes sure that other static data doesn't overwrite the bitmap display.
	screen_buffer: .space 262144
	# A temporary buffer used for drawing to the screen.
	# At the end of the frame, this buffer is copied to the screen_buffer for display
	write_buffer: .space 262144
	# Frog position, in pixels
	frog_x: .word 128
	frog_y: .word 224
	# Object positions
	turtle_row_1_position: .word 0
	turtle_row_2_position: .word 0
	log_row_1_position: .word 128
	log_row_2_position: .word 16
	log_row_3_position: .word 0
.text
main:
	# Draw water region
	li $a0, 0
	li $a1, 33024
	li $a2, 0x000042
	jal draw_rect
	# Draw road region
	li $a0, 36864
	li $a1, 56700
	li $a2, 0x000000
	jal draw_rect
draw_safe_area_loop_init:
	li $s0, 0
draw_safe_area_loop_body:
	bge $s0, 32, draw_safe_area_loop_end # branch if $s0 >= 32, in which cases we have drawn all the tiles!
	sll $s1, $s0, 3 # multiply $s0 by 8 and store it in $s1
	
	# compute bitwise AND of $s0 and 1 ($s2 stores 0 iff $s0 is even, and 1 otherwise)
	andi $s2, $s0, 1
	beq $s2, 0, draw_safe_area_loop_body_even # branch if $s2 is even, in which case draw a different tile for the top and bottom
draw_safe_area_loop_body_odd:
	# draw middle safe area
	addi $a0, $s1, 0
	li $a1, 128
	jal draw_sprite_safe_top2
	
	addi $a0, $s1, 0
	li $a1, 136
	jal draw_sprite_safe_bottom2
	# draw starting safe area
	addi $a0, $s1, 0
	li $a1, 224
	jal draw_sprite_safe_top2
	
	addi $a0, $s1, 0
	li $a1, 232
	jal draw_sprite_safe_bottom2
	
	j draw_safe_area_loop_body_common
draw_safe_area_loop_body_even:
	# draw middle safe area
	addi $a0, $s1, 0
	li $a1, 128
	jal draw_sprite_safe_top1
	
	addi $a0, $s1, 0
	li $a1, 136
	jal draw_sprite_safe_bottom1
	# draw starting safe area
	addi $a0, $s1, 0
	li $a1, 224
	jal draw_sprite_safe_top1
	
	addi $a0, $s1, 0
	li $a1, 232
	jal draw_sprite_safe_bottom1
	
	j draw_safe_area_loop_body_common
draw_safe_area_loop_body_common:
	add $s0, $s0, 1 # increment tile x
	j draw_safe_area_loop_body # jump to the start of the loop
draw_safe_area_loop_end:
	# draw goal region
	li $s0, 0
_draw_goal_region_loop_1:
	bgt $s0, 224, _draw_goal_region_loop_2_init
	
	# draw right-connecting tile
	addi $a0, $s0, 0
	li $a1, 24
	jal draw_sprite_goal_tile_cR
	addi $a0, $s0, 0
	li $a1, 32
	jal draw_sprite_goal_tile_NSW
	addi $a0, $s0, 0
	li $a1, 40
	jal draw_sprite_goal_tile_NW
	
	# draw left-connecting tile
	addi $a0, $s0, 24
	li $a1, 24
	jal draw_sprite_goal_tile_cL
	addi $a0, $s0, 24
	li $a1, 32
	jal draw_sprite_goal_tile_NES
	addi $a0, $s0, 24
	li $a1, 40
	jal draw_sprite_goal_tile_NE
	
	# draw middle-connecting tiles
	addi $a0, $s0, 8
	li $a1, 24
	jal draw_sprite_goal_tile_c
	addi $a0, $s0, 16
	li $a1, 24
	jal draw_sprite_goal_tile_c
	
	addi $s0, $s0, 56
	j _draw_goal_region_loop_1
_draw_goal_region_loop_2_init:
	li $s0, 32
_draw_goal_region_loop_2:
	bge $s0, 224, _draw_goal_region_loop_end
	
	addi $a0, $s0, 0
	li $a1, 24
	jal draw_sprite_goal_tile_NESW
	addi $a0, $s0, 8
	li $a1, 24
	jal draw_sprite_goal_tile_NESW
	addi $a0, $s0, 16
	li $a1, 24
	jal draw_sprite_goal_tile_NESW
	
	addi $a0, $s0, 0
	li $a1, 32
	jal draw_sprite_goal_tile_NESW
	addi $a0, $s0, 8
	li $a1, 32
	jal draw_sprite_goal_tile_NESW
	addi $a0, $s0, 16
	li $a1, 32
	jal draw_sprite_goal_tile_NESW
	
	addi $a0, $s0, 0
	li $a1, 40
	jal draw_sprite_goal_tile_c
	addi $a0, $s0, 8
	li $a1, 40
	jal draw_sprite_goal_tile_c
	addi $a0, $s0, 16
	li $a1, 40
	jal draw_sprite_goal_tile_c
	
	addi $s0, $s0, 56
	j _draw_goal_region_loop_2
_draw_goal_region_loop_end:
_draw_turtles:
	# draw second row of turtles (bottom-most)
	lw $s0, turtle_row_2_position
	# turtles 1
	addi $a0, $s0, 0
	li $a1, 112
	jal draw_sprite_turtle_1
	addi $a0, $s0, 16
	li $a1, 112
	jal draw_sprite_turtle_1
	addi $a0, $s0, 32
	li $a1, 112
	jal draw_sprite_turtle_1
	# turtles 2
	addi $a0, $s0, 64
	li $a1, 112
	jal draw_sprite_turtle_1
	addi $a0, $s0, 80
	li $a1, 112
	jal draw_sprite_turtle_1
	addi $a0, $s0, 96
	li $a1, 112
	jal draw_sprite_turtle_1
	# turtles 3
	addi $a0, $s0, 128
	li $a1, 112
	jal draw_sprite_turtle_1
	addi $a0, $s0, 144
	li $a1, 112
	jal draw_sprite_turtle_1
	addi $a0, $s0, 160
	li $a1, 112
	jal draw_sprite_turtle_1
	# turtles 4
	addi $a0, $s0, 192
	li $a1, 112
	jal draw_sprite_turtle_1
	addi $a0, $s0, 208
	li $a1, 112
	jal draw_sprite_turtle_1
	addi $a0, $s0, 224
	li $a1, 112
	jal draw_sprite_turtle_1

	# draw first row of turtles (top-most)
	lw $s0, turtle_row_1_position
	# turtles 1
	addi $a0, $s0, 0
	li $a1, 64
	jal draw_sprite_turtle_1
	addi $a0, $s0, 16
	li $a1, 64
	jal draw_sprite_turtle_1
	# turtles 2
	addi $a0, $s0, 64
	li $a1, 64
	jal draw_sprite_turtle_1
	addi $a0, $s0, 80
	li $a1, 64
	jal draw_sprite_turtle_1
	# turtles 3
	addi $a0, $s0, 128
	li $a1, 64
	jal draw_sprite_turtle_1
	addi $a0, $s0, 144
	li $a1, 64
	jal draw_sprite_turtle_1
	# turtles 4
	addi $a0, $s0, 192
	li $a1, 64
	jal draw_sprite_turtle_1
	addi $a0, $s0, 208
	li $a1, 64
	jal draw_sprite_turtle_1
_draw_logs:
	# draw first row of logs (top-most)
	lw $s0, log_row_1_position
	# log 1
	addi $a0, $s0, 0
	li $a1, 48
	jal draw_sprite_log_left
	addi $a0, $s0, 8
	li $a1, 48
	jal draw_sprite_log_mid1
	addi $a0, $s0, 16
	li $a1, 48
	jal draw_sprite_log_mid2
	addi $a0, $s0, 24
	li $a1, 48
	jal draw_sprite_log_mid3
	addi $a0, $s0, 32
	li $a1, 48
	jal draw_sprite_log_right
	# log 2
	addi $a0, $s0, 64
	li $a1, 48
	jal draw_sprite_log_left
	addi $a0, $s0, 72
	li $a1, 48
	jal draw_sprite_log_mid1
	addi $a0, $s0, 80
	li $a1, 48
	jal draw_sprite_log_mid2
	addi $a0, $s0, 88
	li $a1, 48
	jal draw_sprite_log_mid3
	addi $a0, $s0, 96
	li $a1, 48
	jal draw_sprite_log_mid2
	addi $a0, $s0, 104
	li $a1, 48
	jal draw_sprite_log_mid3
	addi $a0, $s0, 112
	li $a1, 48
	jal draw_sprite_log_right
	# log 3
	addi $a0, $s0, 144
	li $a1, 48
	jal draw_sprite_log_left
	addi $a0, $s0, 152
	li $a1, 48
	jal draw_sprite_log_mid1
	addi $a0, $s0, 160
	li $a1, 48
	jal draw_sprite_log_mid2
	addi $a0, $s0, 168
	li $a1, 48
	jal draw_sprite_log_mid3
	addi $a0, $s0, 176
	li $a1, 48
	jal draw_sprite_log_right
	
	# draw second row of logs
	lw $s0, log_row_2_position
	# log 1
	addi $a0, $s0, 0
	li $a1, 80
	jal draw_sprite_log_left
	addi $a0, $s0, 8
	li $a1, 80
	jal draw_sprite_log_mid1
	addi $a0, $s0, 16
	li $a1, 80
	jal draw_sprite_log_mid2
	addi $a0, $s0, 24
	li $a1, 80
	jal draw_sprite_log_mid3
	addi $a0, $s0, 32
	li $a1, 80
	jal draw_sprite_log_mid2
	addi $a0, $s0, 40
	li $a1, 80
	jal draw_sprite_log_mid3
	addi $a0, $s0, 48
	li $a1, 80
	jal draw_sprite_log_mid2
	addi $a0, $s0, 56
	li $a1, 80
	jal draw_sprite_log_mid3
	addi $a0, $s0, 64
	li $a1, 80
	jal draw_sprite_log_right
	# log 2
	addi $a0, $s0, 128
	li $a1, 80
	jal draw_sprite_log_left
	addi $a0, $s0, 136
	li $a1, 80
	jal draw_sprite_log_mid1
	addi $a0, $s0, 144
	li $a1, 80
	jal draw_sprite_log_mid2
	addi $a0, $s0, 152
	li $a1, 80
	jal draw_sprite_log_mid3
	addi $a0, $s0, 160
	li $a1, 80
	jal draw_sprite_log_mid2
	addi $a0, $s0, 168
	li $a1, 80
	jal draw_sprite_log_mid3
	addi $a0, $s0, 176
	li $a1, 80
	jal draw_sprite_log_mid2
	addi $a0, $s0, 182
	li $a1, 80
	jal draw_sprite_log_mid3
	addi $a0, $s0, 190
	li $a1, 80
	jal draw_sprite_log_right
	
	# draw third row of logs
	lw $s0, log_row_3_position
	# log 1
	addi $a0, $s0, 0
	li $a1, 96
	jal draw_sprite_log_left
	addi $a0, $s0, 8
	li $a1, 96
	jal draw_sprite_log_mid1
	addi $a0, $s0, 16
	li $a1, 96
	jal draw_sprite_log_right
	# log 2
	addi $a0, $s0, 104
	li $a1, 96
	jal draw_sprite_log_left
	addi $a0, $s0, 112
	li $a1, 96
	jal draw_sprite_log_mid1
	addi $a0, $s0, 120
	li $a1, 96
	jal draw_sprite_log_right
_draw_player:
	# draw player
	lw $a0, frog_x
	addi $a0, $a0, -8
	lw $a1, frog_y
	jal draw_sprite_frog
_update:
	# Update turtle positions
	lw $t9, turtle_row_1_position
	addi $t9, $t9, -5
	rem $t9, $t9, 255
	sw $t9, turtle_row_1_position
	
	lw $t9, turtle_row_2_position
	addi $t9, $t9, -15
	rem $t9, $t9, 255
	sw $t9, turtle_row_2_position
	
	# Update log positions
	lw $t9, log_row_1_position
	addi $t9, $t9, 7
	rem $t9, $t9, 255
	sw $t9, log_row_1_position
	
	lw $t9, log_row_2_position
	addi $t9, $t9, 10
	rem $t9, $t9, 255
	sw $t9, log_row_2_position
	
	lw $t9, log_row_3_position
	addi $t9, $t9, 3
	rem $t9, $t9, 255
	sw $t9, log_row_3_position
_flip_buffers:
	# Copy data from write_buffer to $gp
	la $t0, write_buffer
	li $t1, 0
copy_write_buffer_loop:
	bge $t1, 262144, wait

	add $t2, $t1, $t0 # Offset $t1 by $t0 and store it in $t2
	lw $t3, 0($t2) # Load data at $t2 into $t3
	add $t4, $t1, $gp # Offset $t1 by $gp and store it in $t4
	sw $t3, 0($t4)
	
	add $t1, $t1, 4
	j copy_write_buffer_loop
wait:
	# wait 16 milliseconds after every frame
	#li $v0, 32 # load 32 into $v0 to specify that we want the sleep syscall
	#li $a0, 16 # load 16 millisconds as argument to sleep function (into $a0)
	#syscall
	
	# repeat
	j main
	
draw_rect:
	# args: start_idx, end_idx, colour
	sll $t0, $a0, 2 # multiply by 4
	sll $t1, $a1, 2 # multiply by 4
	la $t2, write_buffer
	add $t0, $t0, $t2
	add $t1, $t1, $t2
draw_rect_loop_body:
	bgt $t0, $t1, draw_rect_loop_end
	sw $a2, 0($t0)
	addi $t0, $t0, 4
	j draw_rect_loop_body
draw_rect_loop_end:
	jr $ra

draw_sprite_frog:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x59e640 # store colour code for 0x59e640
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x2440($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0xc40($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x2444($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0xc44($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	li $t1, 0xff20f8 # store colour code for 0xff20f8
	sw $t1, 0xc20($t0) # draw pixel
	li $t1, 0xffff20 # store colour code for 0xffff20
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	li $t1, 0xffff00 # store colour code for 0xffff00
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	li $t1, 0xff00f7 # store colour code for 0xff00f7
	sw $t1, 0xc34($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_c:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_cL:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_cR:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_NE:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_NES:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_NESW:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_NSW:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_NW:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	jr $ra

draw_sprite_log_left:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	li $t1, 0xde684f # store colour code for 0xde684f
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	li $t1, 0x97684f # store colour code for 0x97684f
	sw $t1, 0x2c18($t0) # draw pixel
	jr $ra

draw_sprite_log_mid1:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	li $t1, 0xde684f # store colour code for 0xde684f
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	li $t1, 0x97684f # store colour code for 0x97684f
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	jr $ra

draw_sprite_log_mid2:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	li $t1, 0xde684f # store colour code for 0xde684f
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	li $t1, 0x97684f # store colour code for 0x97684f
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	jr $ra

draw_sprite_log_mid3:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	li $t1, 0xde684f # store colour code for 0xde684f
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	li $t1, 0x97684f # store colour code for 0x97684f
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	jr $ra

draw_sprite_log_right:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	li $t1, 0xde684f # store colour code for 0xde684f
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	li $t1, 0x97684f # store colour code for 0x97684f
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	jr $ra

draw_sprite_safe_bottom1:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x9400f7 # store colour code for 0x9400f7
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	li $t1, 0x0000f7 # store colour code for 0x0000f7
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	jr $ra

draw_sprite_safe_bottom2:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x9400f7 # store colour code for 0x9400f7
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	li $t1, 0x0000f7 # store colour code for 0x0000f7
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	jr $ra

draw_sprite_safe_top1:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x9400f7 # store colour code for 0x9400f7
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	li $t1, 0x0000f7 # store colour code for 0x0000f7
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	jr $ra

draw_sprite_safe_top2:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x9400f7 # store colour code for 0x9400f7
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	li $t1, 0x0000f7 # store colour code for 0x0000f7
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	jr $ra

draw_sprite_turtle_1:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	la $t0, write_buffer
	add $t0, $t0, $a0
	add $t0, $t0, $a1
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	jr $ra
	