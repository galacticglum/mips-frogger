#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Shon Verch, 1006758796
#
# Bitmap Display Configuration:
# - Unit width in pixels: 2
# - Unit height in pixels: 2
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# - Milestone 5
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. [EASY] - Display the number of lives remaining 
# 2. [EASY] - After final player death, display game over/retry screen. Restart the game if "retry" option is chosen.
# 3. [EASY] - Make objects (frogs, logs, turtles, vehicles, etc.) look more like the arcade version.
# 4. [EASY] - Have objects in different rows move at different speed.
# 5. [EASY] - Add a third row in each of the water and road sections.
# 6. [HARD] - Add sound effects for movement, collisions, game end, and reaching the goal area.
#
.data
	# Reserve the next 262144 bytes (e.g. 256 * 256 = 65536) for the bitmap data.
	# This makes sure that other static data doesn't overwrite the bitmap display.
	screen_buffer: .space 262144
	# A temporary buffer used for drawing to the screen.
	# At the end of the frame, this buffer is copied to the screen_buffer for display
	#write_buffer: .space 262144
	# Frog position, in pixels
	starting_frog_x: .word 120
	starting_frog_y: .word 224
	frog_x: .word 0
	frog_y: .word 0
	frog_width: .word 16
	################
	# OBJECTS
	################
	# Turtles
	n_turtle_rows: .word 2
	turtle_x_positions: .word 0, 0
	turtle_y_positions: .word 64, 112
	turtle_speeds: .word -1, -2
	# Logs
	n_log_rows: .word 3
	log_x_positions: .word 128, 6, 0
	log_y_positions: .word 48, 80, 96
	log_speeds: .word 2, 2, 1
	# Cars
	n_car_rows: .word 5
	car_x_positions: .word 0, 64, 128, 128, 0
	car_y_positions: .word 144, 160, 176, 192, 208
	car_speeds: .word -2, 1, -1, 2, 1
	# width of cars in each row
	car_widths: .word 32, 16, 16, 16, 16
	################
	# STATE
	################
	moved_this_frame: .word 0
	max_num_lives: .word 5
	num_lives: .word 0
	
	has_drawn_game_over: .word 0
.text
init:
	lw $v0, starting_frog_x
	lw $v1, starting_frog_y
	sw $v0, frog_x
	sw $v1, frog_y
	
	li $v0, 0
	sw $v0, has_drawn_game_over
	
	lw $v0, max_num_lives
	sw $v0, num_lives
	
	# Reset screen on first frame
	li $a0, 0
	li $a1, 65792
	li $a2, 0x00000
	jal fill_between
	
	# Draw water region
	li $a0, 0
	li $a1, 256
	li $a2, 128
	li $a3, 0x000042
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
	bge $s0, 224, main
	
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
main:
	lw $s1, num_lives
	blt $s1, 0, game_over
draw_lives:
	li $s0, 0
	lw $s2, max_num_lives
	# clear ui region
	li $a0, 61440
	move $a1, $s2
	sll $a1, $a1, 3
	li $a2, 8
	li $a3, 0x000000
	jal draw_rect
draw_lives_loop:
	bge $s0, $s1, check_for_keypress
	move $a0, $s0
	sll $a0, $a0, 3
	li $a1, 240
	jal draw_sprite_heart

	# increment
	addi $s0, $s0, 1
	j draw_lives_loop
check_for_keypress:
	# Poll for keypress event
	lw $t8, 0xffff0000
	beq $t8, 1, on_keyboard_input
	j after_check_for_keypress
on_keyboard_input:
	lw $t0, 0xffff0004
	beq $t0, 0x77, respond_to_up_key
	beq $t0, 0x73, respond_to_down_key
	beq $t0, 0x61, respond_to_left_key
	beq $t0, 0x64, respond_to_right_key
	j after_check_for_keypress
respond_to_up_key:
	jal move_up
	j after_check_for_keypress
respond_to_down_key:
	jal move_down
	j after_check_for_keypress
respond_to_left_key:
	jal move_left
	j after_check_for_keypress
respond_to_right_key:
	jal move_right
	j after_check_for_keypress
after_check_for_keypress:
_draw_turtles:
	la $t8, turtle_x_positions
	la $t9, turtle_y_positions
	la $t7, turtle_speeds
	# draw second row of turtles (bottom-most)
	lw $s0, 4($t8)
	lw $s1, 4($t9)
	lw $s2, 4($t7)
	abs $s2, $s2
	# turtles 1
	addi $a0, $s0, 0
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 16
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 32
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	# clear old region (turtles 2,1)
	addi $t0, $s0, 48 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	move $a1, $s2 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	jal draw_rect
	
	# turtles 2
	addi $a0, $s0, 64
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 80
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 96
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	# clear old region (turtles 2,2)
	addi $t0, $s0, 112 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	move $a1, $s2 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	jal draw_rect
	
	# turtles 3
	addi $a0, $s0, 128
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 144
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 160
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	# clear old region (turtles 2,3)
	addi $t0, $s0, 176 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	move $a1, $s2 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	jal draw_rect
	
	# turtles 4
	addi $a0, $s0, 192
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 208
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 224
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	# clear old region (turtles 2,4)
	addi $t0, $s0, 240 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	move $a1, $s2 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	jal draw_rect

	# draw first row of turtles (top-most)
	lw $s0, 0($t8)
	lw $s1, 0($t9)
	lw $s2, 0($t7)
	abs $s2, $s2
	# turtles 1
	addi $a0, $s0, 0
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 16
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	# clear old region (turtles 1,1)
	addi $t0, $s0, 32 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	move $a1, $s2 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	jal draw_rect
	
	# turtles 2
	addi $a0, $s0, 64
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 80
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	# clear old region (turtles 1,2)
	addi $t0, $s0, 96 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	move $a1, $s2 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	jal draw_rect
	
	# turtles 3	
	addi $a0, $s0, 128
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 144
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	# clear old region (turtles 1,3)
	addi $t0, $s0, 160 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	move $a1, $s2 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	jal draw_rect
	
	# turtles 4
	addi $a0, $s0, 192
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 208
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	# clear old region (turtles 1,4)
	addi $t0, $s0, 224 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	move $a1, $s2 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	jal draw_rect
_draw_logs:
	la $t8, log_x_positions
	la $t9, log_y_positions
	la $t7, log_speeds
	# draw first row of logs (top-most)
	lw $s0, 0($t8)
	lw $s1, 0($t9)
	lw $s2, 0($t7)
	# log 1
	# clear old region (log 1,1)
	addi $t0, $s0, 0 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	move $a1, $s2 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	jal draw_rect
	
	addi $a0, $s0, 0
	addi $a1, $s1, 0
	jal draw_sprite_log_left
	addi $a0, $s0, 8
	addi $a1, $s1, 0
	jal draw_sprite_log_mid1
	addi $a0, $s0, 16
	addi $a1, $s1, 0
	jal draw_sprite_log_mid2
	addi $a0, $s0, 24
	addi $a1, $s1, 0
	jal draw_sprite_log_mid3
	addi $a0, $s0, 32
	addi $a1, $s1, 0
	jal draw_sprite_log_right
	# log 2
	# clear old region (log 1,2)
	addi $t0, $s0, 64 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	move $a1, $s2 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	jal draw_rect
	addi $a0, $s0, 64
	addi $a1, $s1, 0
	jal draw_sprite_log_left
	addi $a0, $s0, 72
	addi $a1, $s1, 0
	jal draw_sprite_log_mid1
	addi $a0, $s0, 80
	addi $a1, $s1, 0
	jal draw_sprite_log_mid2
	addi $a0, $s0, 88
	addi $a1, $s1, 0
	jal draw_sprite_log_mid3
	addi $a0, $s0, 96
	addi $a1, $s1, 0
	jal draw_sprite_log_mid2
	addi $a0, $s0, 104
	addi $a1, $s1, 0
	jal draw_sprite_log_mid3
	addi $a0, $s0, 112
	addi $a1, $s1, 0
	jal draw_sprite_log_right
	# log 3
	# clear old region (log 1,3)
	addi $t0, $s0, 144 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	move $a1, $s2 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	jal draw_rect
	addi $a0, $s0, 144
	addi $a1, $s1, 0
	jal draw_sprite_log_left
	addi $a0, $s0, 152
	addi $a1, $s1, 0
	jal draw_sprite_log_mid1
	addi $a0, $s0, 160
	addi $a1, $s1, 0
	jal draw_sprite_log_mid2
	addi $a0, $s0, 168
	addi $a1, $s1, 0
	jal draw_sprite_log_mid3
	addi $a0, $s0, 176
	addi $a1, $s1, 0
	jal draw_sprite_log_right
	
	# draw second row of logs
	lw $s0, 4($t8)
	lw $s1, 4($t9)	
	lw $s2, 4($t7)
	# log 1
	# clear old region (log 2,1)
	addi $t0, $s0, 0 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	move $a1, $s2 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	jal draw_rect
	
	addi $a0, $s0, 0
	addi $a1, $s1, 0
	jal draw_sprite_log_left
	addi $a0, $s0, 8
	addi $a1, $s1, 0
	jal draw_sprite_log_mid1
	addi $a0, $s0, 16
	addi $a1, $s1, 0
	jal draw_sprite_log_mid2
	addi $a0, $s0, 24
	addi $a1, $s1, 0
	jal draw_sprite_log_mid3
	addi $a0, $s0, 32
	addi $a1, $s1, 0
	jal draw_sprite_log_mid2
	addi $a0, $s0, 40
	addi $a1, $s1, 0
	jal draw_sprite_log_mid3
	addi $a0, $s0, 48
	addi $a1, $s1, 0
	jal draw_sprite_log_mid2
	addi $a0, $s0, 56
	addi $a1, $s1, 0
	jal draw_sprite_log_mid3
	addi $a0, $s0, 64
	addi $a1, $s1, 0
	jal draw_sprite_log_right
	# log 2
	# clear old region (log 2,2)
	addi $t0, $s0, 128 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	move $a1, $s2 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	jal draw_rect
	
	addi $a0, $s0, 128
	addi $a1, $s1, 0
	jal draw_sprite_log_left
	addi $a0, $s0, 136
	addi $a1, $s1, 0
	jal draw_sprite_log_mid1
	addi $a0, $s0, 144
	addi $a1, $s1, 0
	jal draw_sprite_log_mid2
	addi $a0, $s0, 152
	addi $a1, $s1, 0
	jal draw_sprite_log_mid3
	addi $a0, $s0, 160
	addi $a1, $s1, 0
	jal draw_sprite_log_mid2
	addi $a0, $s0, 168
	addi $a1, $s1, 0
	jal draw_sprite_log_mid3
	addi $a0, $s0, 176
	addi $a1, $s1, 0
	jal draw_sprite_log_mid2
	addi $a0, $s0, 182
	addi $a1, $s1, 0
	jal draw_sprite_log_mid3
	addi $a0, $s0, 190
	addi $a1, $s1, 0
	jal draw_sprite_log_right
	
	# draw third row of logs
	lw $s0, 8($t8)
	lw $s1, 8($t9)
	lw $s2, 8($t7)
	# log 1
	# clear old region (log 3,1)
	addi $t0, $s0, 0 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	move $a1, $s2 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	jal draw_rect
	
	addi $a0, $s0, 0
	addi $a1, $s1, 0
	jal draw_sprite_log_left
	addi $a0, $s0, 8
	addi $a1, $s1, 0
	jal draw_sprite_log_mid1
	addi $a0, $s0, 16
	addi $a1, $s1, 0
	jal draw_sprite_log_right
	# log 2
	# clear old region (log 3,2)
	addi $t0, $s0, 104 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	move $a1, $s2 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	jal draw_rect
	
	addi $a0, $s0, 104
	addi $a1, $s1, 0
	jal draw_sprite_log_left
	addi $a0, $s0, 112
	addi $a1, $s1, 0
	jal draw_sprite_log_mid1
	addi $a0, $s0, 120
	addi $a1, $s1, 0
	jal draw_sprite_log_right
_draw_cars:
	la $t8, car_x_positions
	la $t9, car_y_positions
	la $t7, car_speeds
	# draw first row of cars (top most)
	lw $s0, 0($t8)
	lw $s1, 0($t9)
	lw $s2, 0($t7)
	
	# clear old region (car 1,1)
	addi $t0, $s0, 0 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	li $a1, 32 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	jal draw_rect
	addi $a0, $s0, 0
	addi $a1, $s1, 0
	jal draw_sprite_car3
	
	# clear old region (car 1,2)
	addi $t0, $s0, 128 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	li $a1, 32 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	jal draw_rect
	addi $a0, $s0, 128
	addi $a1, $s1, 0
	jal draw_sprite_car3
	
	# draw second row of cars
	lw $s0, 4($t8)
	lw $s1, 4($t9)
	lw $s2, 4($t7)
	
	# clear old region (car 2,1)
	addi $t0, $s0, 0 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	jal draw_rect
	addi $a0, $s0, 0
	addi $a1, $s1, 0
	jal draw_sprite_car5
	
	# draw third row of cars
	lw $s0, 8($t8)
	lw $s1, 8($t9)
	lw $s2, 8($t7)
	
	# clear old region (car 3,1)
	addi $t0, $s0, 56 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	jal draw_rect
	addi $a0, $s0, 56
	addi $a1, $s1, 0
	jal draw_sprite_car4
	
	# clear old region (car 3,2)
	addi $t0, $s0, 120 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	jal draw_rect
	addi $a0, $s0, 120
	addi $a1, $s1, 0
	jal draw_sprite_car4
	
	# clear old region (car 3,3)
	addi $t0, $s0, 184 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	jal draw_rect
	addi $a0, $s0, 184
	addi $a1, $s1, 0
	jal draw_sprite_car4
	
	# draw fourth row of cars 
	lw $s0, 12($t8)
	lw $s1, 12($t9)
	lw $s2, 12($t7) # car_speed
	
	# clear old region (car 4,1)
	addi $t0, $s0, 0 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	jal draw_rect
	addi $a0, $s0, 0
	addi $a1, $s1, 0
	jal draw_sprite_car2
	
	# clear old region (car 4,2)
	addi $t0, $s0, 64 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	jal draw_rect
	addi $a0, $s0, 64
	addi $a1, $s1, 0
	jal draw_sprite_car2
	
	# clear old region (car 4,3)
	addi $t0, $s0, 128 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	jal draw_rect
	addi $a0, $s0, 128
	addi $a1, $s1, 0
	jal draw_sprite_car2
	
	# draw fifth row of cars (bottom most)
	lw $s0, 16($t8)
	lw $s1, 16($t9)
	lw $s2, 16($t7) # car_speed
	
	# clear old region (car 5,1)
	addi $t0, $s0, 32 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	jal draw_rect
	addi $a0, $s0, 32
	addi $a1, $s1, 0
	jal draw_sprite_car1
	
	# clear old region (car 5,2)
	addi $t0, $s0, 104 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	jal draw_rect
	addi $a0, $s0, 104
	addi $a1, $s1, 0
	jal draw_sprite_car1
	
	# clear old region (car 5,3)
	addi $t0, $s0, 176 # offset x1
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $t0 # add x1
	sub $a0, $a0, $s2 # subtract speed
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	jal draw_rect
	addi $a0, $s0, 176
	addi $a1, $s1, 0
	jal draw_sprite_car1
_update:
_update_turtle_positions:
	# Update turtle positions
	li $t7, 0
	la $s0, turtle_x_positions
	la $s1, turtle_speeds
	lw $s2, n_turtle_rows
_update_turtle_positions_loop:
	bge $t7, $s2, _update_log_positions
	
	sll $t5, $t7, 2 # Multiply $t7 by 4
	add $t6, $t5, $s1 # Add $s1 to $t5 and store it in $t6
	add $t5, $t5, $s0 # Add $s0 to $t5 and store it in $t5
	
	lw $t9, 0($t5)
	lw $t8, 0($t6)
	add $t9, $t9, $t8
	# Wrap around screen width
	rem $t9, $t9, 256
	sw $t9, 0($t5)
	# increment
	addi $t7, $t7, 1
	j _update_turtle_positions_loop
_update_log_positions:
	# Update log positions
	li $t7, 0
	la $s0, log_x_positions
	la $s1, log_speeds
	lw $s2, n_log_rows
_update_log_positions_loop:
	bge $t7, $s2, _update_car_positions
	
	sll $t5, $t7, 2 # Multiply $t7 by 4
	add $t6, $t5, $s1 # Add $s1 to $t5 and store it in $t6
	add $t5, $t5, $s0 # Add $s0 to $t5 and store it in $t5
	
	lw $t9, 0($t5)
	lw $t8, 0($t6)
	add $t9, $t9, $t8
	# Wrap around screen width
	rem $t9, $t9, 256
	sw $t9, 0($t5)
	# increment
	addi $t7, $t7, 1
	j _update_log_positions_loop
_update_car_positions:
	# Update car positions
	li $t7, 0
	la $s0, car_x_positions
	la $s1, car_speeds
	lw $s2, n_car_rows
_update_car_positions_loop:
	bge $t7, $s2, _update_frog_position
	
	sll $t5, $t7, 2 # Multiply $t7 by 4
	add $t6, $t5, $s1 # Add $s1 to $t5 and store it in $t6
	add $t5, $t5, $s0 # Add $s0 to $t5 and store it in $t5
	
	lw $t9, 0($t5)
	lw $t8, 0($t6)
	add $t9, $t9, $t8
	# Wrap around screen width
	rem $t9, $t9, 256
	sw $t9, 0($t5)
	# increment
	addi $t7, $t7, 1
	j _update_car_positions_loop
_update_frog_position:
	lw $t8, frog_x
	lw $t9, frog_y
_start_update_frog_position_turtle:
	li $t7, 0
	la $s0, turtle_y_positions
	la $s1, turtle_speeds
	lw $s2, n_turtle_rows
_update_frog_position_turtle_loop:
	bge $t7, $s2, _start_update_frog_position_log
	
	sll $t5, $t7, 2 # Multiply $t7 by 4
	add $t6, $t5, $s1 # Add $s1 to $t5 and store it in $t6
	add $t5, $t5, $s0 # Add $s0 to $t5 and store it in $t5
	
	lw $t4, 0($t5)
	bne $t9, $t4, _update_frog_position_turtle_loop_end

	lw $t3, 0($t6)
	add $t8, $t8, $t3
_update_frog_position_turtle_loop_end:
	# increment
	addi $t7, $t7, 1
	j _update_frog_position_turtle_loop
_start_update_frog_position_log:
	li $t7, 0
	la $s0, log_y_positions
	la $s1, log_speeds
	lw $s2, n_log_rows
_update_frog_position_log_loop:
	bge $t7, $s2, _done_update_frog_position
	
	sll $t5, $t7, 2 # Multiply $t7 by 4
	add $t6, $t5, $s1 # Add $s1 to $t5 and store it in $t6
	add $t5, $t5, $s0 # Add $s0 to $t5 and store it in $t5
	
	lw $t4, 0($t5)
	bne $t9, $t4, _update_frog_position_log_loop_end

	lw $t3, 0($t6)
	add $t8, $t8, $t3
_update_frog_position_log_loop_end:
	# increment
	addi $t7, $t7, 1
	j _update_frog_position_log_loop
_done_update_frog_position:	
	sw $t8, frog_x
	sw $t9, frog_y
	jal check_collisions
_draw_player:
	# draw player
	lw $a0, frog_x
	lw $a1, frog_y
	jal draw_sprite_frog
wait:	
	li $v0, 32				# load 32 into $v0 to specify that we want the sleep syscall
	li $a0, 16				# load 17 millisconds as argument to sleep function (into $a0)
	syscall					# Execute sleep function call
	# repeat
	lw $v0, moved_this_frame
	beq $v0, 1, redraw_all
	j main
redraw_all:
	li $v0, 0
	sw $v0, moved_this_frame
	j draw_safe_area_loop_init
game_over:
	li $a0, 0
	li $a1, 256
	li $a2, 256
	li $a3, 0x000000
	jal draw_rect
	li $a0, 0
	li $a1, 0
	jal draw_sprite_game_over_screen
	li $v0, 1
	sw $v0, has_drawn_game_over
	jal play_midi_alfonsos_disappointment
_done_draw_game_over:
	lw $t0, 0xffff0004
	beq $t0, 0x72, respond_to_r_key
	beq $t0, 0x71, respond_to_q_key
	j _done_draw_game_over
respond_to_r_key:
	j init
respond_to_q_key:
	li $v0, 10 # terminate the program gracefully
	syscall
	
move_up:
	lw $t8, frog_x
	lw $t9, frog_y
	# clear region at current position
	sll $a0, $t9, 8 # multiply by 256
	add $a0, $a0, $t8 # add frog_x
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	move $s0, $ra
	jal draw_rect
	move $ra, $s0
	
	# play sound
	li $v0, 31  
	li $a0, 67
	li $a1, 100
	li $a2, 1
	li $a3, 50
	syscall 
	
	addi $t9, $t9, -16
	bge $t9, 24, _move_up_return
	li $t9, 24
_move_up_return:
	li $v0, 1
	sw $v0, moved_this_frame
	
	sw $t9, frog_y
	jr $ra	

move_down:
	lw $t8, frog_x
	lw $t9, frog_y
	# clear region at current position
	sll $a0, $t9, 8 # multiply by 256
	add $a0, $a0, $t8 # add frog_x
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	move $s0, $ra
	jal draw_rect
	move $ra, $s0
	
	
	# play sound
	li $v0, 31  
	li $a0, 67
	li $a1, 100
	li $a2, 1
	li $a3, 50
	syscall 
	
	addi $t9, $t9, 16
	ble $t9, 224, _move_down_return
	li $t9, 224
_move_down_return:
	li $v0, 1
	sw $v0, moved_this_frame
	
	sw $t9, frog_y
	jr $ra
	
move_left:
	lw $t8, frog_x
	lw $t9, frog_y
	# clear region at current position
	sll $a0, $t9, 8 # multiply by 256
	add $a0, $a0, $t8 # add frog_x
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	move $s0, $ra
	jal draw_rect
	move $ra, $s0
	
	
	
	# play sound
	li $v0, 31  
	li $a0, 67
	li $a1, 100
	li $a2, 1
	li $a3, 50
	syscall 
	
	addi $t8, $t8, -16
	bge $t8, 0, _move_left_return
	li $t8, 0
_move_left_return:
	li $v0, 1
	sw $v0, moved_this_frame
	
	sw $t8, frog_x
	jr $ra
	
move_right:
	lw $t8, frog_x
	lw $t9, frog_y
	# clear region at current position
	sll $a0, $t9, 8 # multiply by 256
	add $a0, $a0, $t8 # add frog_x
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	move $s0, $ra
	jal draw_rect
	move $ra, $s0
	
	
	# play sound
	li $v0, 31  
	li $a0, 67
	li $a1, 100
	li $a2, 1
	li $a3, 50
	syscall 
	
	addi $t8, $t8, 16
	ble $t8, 240, _move_right_return
	li $t8, 240
_move_right_return:
	li $v0, 1
	sw $v0, moved_this_frame
	
	sw $t8, frog_x
	jr $ra
	
check_collisions:
	#           frog_y <  48 player is colliding with goal selection iff there exists a pixel that is BLUE
	# if 48  <= frog_y <= 112: player is colliding with water iff every pixel under the player is BLUE
	# if 144 <= frog_y <= 208: player is colliding with car iff there exists a pixel under the player that is NOT black
	lw $s0, frog_x
	lw $s1, frog_y
	lw $s2, frog_width
_check_collisions_with_car_section:
	blt $s1, 144, _check_collisions_with_water_section # frog_y < 144
	bgt $s1, 208, _check_collisions_return # frog_y > 208
	# check if every pixel under the player is BLUE
	# args: start_idx ($a0), width ($a1), height ($a2)
	move $t2, $s1
	sll $t2, $t2, 8 # multiply by 256
	add $t2, $t2, $s0
	sll $t2, $t2, 2 # multiply by 4
	add $t2, $t2, $gp
	li $t0, 0 # y value
_ccwc_outer_loop:
	bge $t0, 16, _ccwc_outer_loop_done
	li $t1, 0 # x value
	move $t3, $t2
_ccwc_inner_loop:
	bge $t1, $s2, _ccwc_inner_loop_done
	lw $t5, 0($t3)
	beq $t5, 0x000000, _increment_ccwc
	beq $t5, 0x21de00, _increment_ccwc
	beq $t5, 0xffff00, _increment_ccwc
	beq $t5, 0xff00f7, _increment_ccwc
	j _has_collision_car
_increment_ccwc:
	# increment
	addi $t1, $t1, 1
	addi $t3, $t3, 4
	j _ccwc_inner_loop
_ccwc_inner_loop_done:
	# increment
	addi $t0, $t0, 1
	addi $t2, $t2, 1024
	j _ccwc_outer_loop
_ccwc_outer_loop_done:
	j _check_collisions_return
_check_collisions_with_water_section:
	lw $s0, frog_x
	addi $s0, $s0, 4
	lw $s1, frog_y
	lw $s2, frog_width
	subi $s2, $s2, 4
        
	blt $s1, 48, _check_collisions_with_goal_section # frog_y < 48
	bgt $s1, 112, _check_collisions_return # frog_y > 112
	# check if there exists a pixel under the player that is NOT black
	# args: start_idx ($a0), width ($a1), height ($a2)
	move $t2, $s1
	sll $t2, $t2, 8 # multiply by 256
	add $t2, $t2, $s0
	sll $t2, $t2, 2 # multiply by 4
	add $t2, $t2, $gp
	li $t0, 0 # y value
_ccww_outer_loop:
	bge $t0, 16, _ccww_outer_loop_done
	li $t1, 0 # x value
	move $t3, $t2
_ccww_inner_loop:
	bge $t1, $s2, _ccww_inner_loop_done
	lw $t5, 0($t3)
	beq $t5, 0x21de00, _increment_ccww
	beq $t5, 0xffff00, _increment_ccww
	beq $t5, 0xff00f7, _increment_ccww

	beq $t5, 0x000000, _increment_ccww
	beq $t5, 0x000042, _increment_ccww # water colour 1
	beq $t5, 0x000047, _increment_ccww # water colour 2
	j _check_collisions_with_goal_section
_increment_ccww:
	# increment
	addi $t1, $t1, 1
	addi $t3, $t3, 4
	j _ccww_inner_loop
_ccww_inner_loop_done:
	# increment
	addi $t0, $t0, 1
	addi $t2, $t2, 1024
	j _ccww_outer_loop
_ccww_outer_loop_done:
	j _has_collision_water
_check_collisions_with_goal_section:
	lw $s0, frog_x
	addi $s0, $s0, 4
	lw $s1, frog_y
	lw $s2, frog_width
	subi $s2, $s2, 4
	
	bge $s1, 48, _check_collisions_return # frog_y >= 48
	# check if every pixel under the player is BLUE
	# args: start_idx ($a0), width ($a1), height ($a2)
	move $t2, $s1
	sll $t2, $t2, 8 # multiply by 256
	add $t2, $t2, $s0
	sll $t2, $t2, 2 # multiply by 4
	add $t2, $t2, $gp
	li $t0, 0 # y value
_ccwg_outer_loop:
	bge $t0, 16, _ccwg_outer_loop_done
	li $t1, 0 # x value
	move $t3, $t2
_ccwg_inner_loop:
	bge $t1, $s2, _ccwg_inner_loop_done
	lw $t5, 0($t3)
	beq $t5, 0x21de00, _increment_ccwg
	beq $t5, 0xffff00, _increment_ccwg
	beq $t5, 0xff00f7, _increment_ccwg

	beq $t5, 0x000000, _increment_ccwg
	beq $t5, 0x000042, _increment_ccwg # water colour 1
	beq $t5, 0x000047, _increment_ccwg # water colour 2
	j _has_collision_water
_increment_ccwg:
	# increment
	addi $t1, $t1, 1
	addi $t3, $t3, 4
	j _ccwg_inner_loop
_ccwg_inner_loop_done:
	# increment
	addi $t0, $t0, 1
	addi $t2, $t2, 1024
	j _ccwg_outer_loop
_ccwg_outer_loop_done:
	j _has_collision_goal
_has_collision_car:
	lw $v0, starting_frog_x
	lw $v1, starting_frog_y
	sw $v0, frog_x
	sw $v1, frog_y
	# clear region at current position
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $s0 # add frog_x
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000000 # colour
	move $s0, $ra
	jal draw_rect
	move $ra, $s0
	# decrease nummber of lives
	lw $v0, num_lives
	addi $v0, $v0, -1
	sw $v0, num_lives
	j _has_collision_common
_has_collision_water:
	lw $v0, starting_frog_x
	lw $v1, starting_frog_y
	sw $v0, frog_x
	sw $v1, frog_y
	# clear region at current position
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $s0 # add frog_x
	li $a1, 16 # width
	li $a2, 16 # height
	li $a3, 0x000042 # colour
	move $s0, $ra
	jal draw_rect
	move $ra, $s0
	# decrease nummber of lives
	lw $v0, num_lives
	addi $v0, $v0, -1
	sw $v0, num_lives
	j _has_collision_common
_has_collision_goal:
	lw $t8, frog_x
	lw $t9, frog_y
	
	lw $v0, starting_frog_x
	lw $v1, starting_frog_y
	sw $v0, frog_x
	sw $v1, frog_y
	# clear region at current position
	sll $a0, $s1, 8 # multiply by 256
	add $a0, $a0, $s0 # add frog_x
	li $a1, 16 # width
	li $a2, 16 # height
	#li $a3, 0x000042 # colour
	li $a3, 0x000042
	move $s0, $ra
	#jal draw_rect
	move $ra, $s0
	# draw goal region	
	move $a0, $t8
	move $a1, $t9
	move $s0, $ra
	jal draw_sprite_goal_region
	move $ra, $s0
	# play sound
	li $v0, 31  
	li $a0, 70
	li $a1, 100
	li $a2, 99
	li $a3, 50
	syscall 
	j _check_collisions_return
_has_collision_common:
	# play sound
	li $v0, 31  
	li $a0, 50
	li $a1, 100
	li $a2, 81
	li $a3, 50
	syscall 
	j _check_collisions_return
_check_collisions_return:
	jr $ra

fill_between:
	# args: start_idx, end_idx, colour
	sll $t0, $a0, 2 # multiply by 4
	sll $t1, $a1, 2 # multiply by 4
	addi $t2, $gp, 0
	add $t0, $t0, $t2
	add $t1, $t1, $t2
fill_between_loop_body:
	bgt $t0, $t1, fill_between_loop_end
	sw $a2, 0($t0)
	addi $t0, $t0, 4
	j fill_between_loop_body
fill_between_loop_end:
	jr $ra

draw_rect:
	# args: start_idx, width, height, colour
	sll $t2, $a0, 2 # multiply by 4
	add $t2, $t2, $gp

	li $t0, 0 # y value
_draw_rect_outer_loop:
	bge $t0, $a2, _draw_rect_outer_loop_done
	li $t1, 0 # x value
	move $t3, $t2
_draw_rect_inner_loop:
	bge $t1, $a1, _draw_rect_inner_loop_done
	sw $a3, 0($t3)
	# increment
	addi $t1, $t1, 1
	addi $t3, $t3, 4
	j _draw_rect_inner_loop
_draw_rect_inner_loop_done:
	# increment
	addi $t0, $t0, 1
	addi $t2, $t2, 1024
	j _draw_rect_outer_loop
_draw_rect_outer_loop_done:
	jr $ra
	
draw_sprite_car1:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	li $t1, 0x9700f7 # store colour code for 0x9700f7
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	li $t1, 0xffff00 # store colour code for 0xffff00
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	jr $ra

draw_sprite_car2:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	jr $ra

draw_sprite_car3:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x3460($t0) # draw pixel
	sw $t1, 0x70($t0) # draw pixel
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x247c($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x44c($t0) # draw pixel
	sw $t1, 0x854($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0x450($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x384c($t0) # draw pixel
	sw $t1, 0x347c($t0) # draw pixel
	sw $t1, 0xc44($t0) # draw pixel
	sw $t1, 0x458($t0) # draw pixel
	sw $t1, 0x3c68($t0) # draw pixel
	sw $t1, 0x346c($t0) # draw pixel
	sw $t1, 0x68($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0xc54($t0) # draw pixel
	sw $t1, 0x478($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x3048($t0) # draw pixel
	sw $t1, 0x870($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x3860($t0) # draw pixel
	sw $t1, 0x868($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x3870($t0) # draw pixel
	sw $t1, 0x3474($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x305c($t0) # draw pixel
	sw $t1, 0x107c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x84c($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x850($t0) # draw pixel
	sw $t1, 0x3074($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0xc48($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x3c44($t0) # draw pixel
	sw $t1, 0x470($t0) # draw pixel
	sw $t1, 0x64($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x864($t0) # draw pixel
	sw $t1, 0x3044($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x3058($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x3848($t0) # draw pixel
	sw $t1, 0x3064($t0) # draw pixel
	sw $t1, 0x3464($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x3878($t0) # draw pixel
	sw $t1, 0x3458($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x2c7c($t0) # draw pixel
	sw $t1, 0x44($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3c60($t0) # draw pixel
	sw $t1, 0x3840($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x3450($t0) # draw pixel
	sw $t1, 0x3850($t0) # draw pixel
	sw $t1, 0x3c58($t0) # draw pixel
	sw $t1, 0x6c($t0) # draw pixel
	sw $t1, 0x187c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0xc78($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x85c($t0) # draw pixel
	sw $t1, 0x385c($t0) # draw pixel
	sw $t1, 0x874($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x448($t0) # draw pixel
	sw $t1, 0x1478($t0) # draw pixel
	sw $t1, 0x2478($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0xc4c($t0) # draw pixel
	sw $t1, 0x54($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0xc60($t0) # draw pixel
	sw $t1, 0x307c($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x3468($t0) # draw pixel
	sw $t1, 0x444($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x3448($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x48($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x858($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0xc64($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0x1c78($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x3440($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0x468($t0) # draw pixel
	sw $t1, 0x2878($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x58($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x3c40($t0) # draw pixel
	sw $t1, 0x2078($t0) # draw pixel
	sw $t1, 0xc74($t0) # draw pixel
	sw $t1, 0x1c7c($t0) # draw pixel
	sw $t1, 0x1878($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3c64($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x474($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x50($t0) # draw pixel
	sw $t1, 0x60($t0) # draw pixel
	sw $t1, 0x3864($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x3854($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x45c($t0) # draw pixel
	sw $t1, 0x345c($t0) # draw pixel
	sw $t1, 0x46c($t0) # draw pixel
	sw $t1, 0x3874($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x5c($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x3470($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0xc50($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0x386c($t0) # draw pixel
	sw $t1, 0x207c($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x440($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x304c($t0) # draw pixel
	sw $t1, 0x3454($t0) # draw pixel
	sw $t1, 0xc58($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0xc7c($t0) # draw pixel
	sw $t1, 0x3060($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x3858($t0) # draw pixel
	sw $t1, 0x4c($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x147c($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x3078($t0) # draw pixel
	sw $t1, 0x3478($t0) # draw pixel
	sw $t1, 0x3c7c($t0) # draw pixel
	sw $t1, 0x3050($t0) # draw pixel
	sw $t1, 0x3c5c($t0) # draw pixel
	sw $t1, 0x344c($t0) # draw pixel
	sw $t1, 0x78($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x3c54($t0) # draw pixel
	sw $t1, 0x40($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0x454($t0) # draw pixel
	sw $t1, 0x3c4c($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x2c78($t0) # draw pixel
	sw $t1, 0x3c70($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x3054($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x3c48($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x3844($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x1078($t0) # draw pixel
	sw $t1, 0xc40($t0) # draw pixel
	sw $t1, 0x87c($t0) # draw pixel
	sw $t1, 0x860($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x848($t0) # draw pixel
	sw $t1, 0x464($t0) # draw pixel
	sw $t1, 0x3c78($t0) # draw pixel
	sw $t1, 0x460($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x878($t0) # draw pixel
	sw $t1, 0x7c($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x47c($t0) # draw pixel
	sw $t1, 0x3868($t0) # draw pixel
	sw $t1, 0x3c50($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x3040($t0) # draw pixel
	sw $t1, 0x74($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x86c($t0) # draw pixel
	sw $t1, 0x387c($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x287c($t0) # draw pixel
	sw $t1, 0x3444($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x840($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0xc5c($t0) # draw pixel
	sw $t1, 0x3c6c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x3c74($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x844($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x2868($t0) # draw pixel
	sw $t1, 0x1450($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x2044($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x105c($t0) # draw pixel
	sw $t1, 0x2470($t0) # draw pixel
	sw $t1, 0x1050($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1c48($t0) # draw pixel
	sw $t1, 0x144c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x1444($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x1448($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1460($t0) # draw pixel
	sw $t1, 0x1870($t0) # draw pixel
	sw $t1, 0x1454($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x1048($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0x1c54($t0) # draw pixel
	sw $t1, 0x2460($t0) # draw pixel
	sw $t1, 0x146c($t0) # draw pixel
	sw $t1, 0x1840($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x2c44($t0) # draw pixel
	sw $t1, 0x204c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x1060($t0) # draw pixel
	sw $t1, 0x2860($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1458($t0) # draw pixel
	sw $t1, 0x2464($t0) # draw pixel
	sw $t1, 0x1868($t0) # draw pixel
	sw $t1, 0x2874($t0) # draw pixel
	sw $t1, 0x1854($t0) # draw pixel
	sw $t1, 0x2064($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x1c58($t0) # draw pixel
	sw $t1, 0x245c($t0) # draw pixel
	sw $t1, 0x2070($t0) # draw pixel
	sw $t1, 0x244c($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x1c6c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x186c($t0) # draw pixel
	sw $t1, 0x246c($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x2054($t0) # draw pixel
	sw $t1, 0x1074($t0) # draw pixel
	sw $t1, 0x2050($t0) # draw pixel
	sw $t1, 0x1474($t0) # draw pixel
	sw $t1, 0x1c70($t0) # draw pixel
	sw $t1, 0x2444($t0) # draw pixel
	sw $t1, 0x2c48($t0) # draw pixel
	sw $t1, 0x285c($t0) # draw pixel
	sw $t1, 0x2450($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x205c($t0) # draw pixel
	sw $t1, 0x2468($t0) # draw pixel
	sw $t1, 0x1058($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x184c($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x145c($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x1c4c($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x1440($t0) # draw pixel
	sw $t1, 0x1c50($t0) # draw pixel
	sw $t1, 0x2040($t0) # draw pixel
	sw $t1, 0x2c60($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x2864($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1844($t0) # draw pixel
	sw $t1, 0x2068($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x2c5c($t0) # draw pixel
	sw $t1, 0x1070($t0) # draw pixel
	sw $t1, 0x286c($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x2c58($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x2448($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1c40($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x1874($t0) # draw pixel
	sw $t1, 0x2c50($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1850($t0) # draw pixel
	sw $t1, 0x2c64($t0) # draw pixel
	sw $t1, 0x1040($t0) # draw pixel
	sw $t1, 0x284c($t0) # draw pixel
	sw $t1, 0x2c40($t0) # draw pixel
	sw $t1, 0x2870($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x1c74($t0) # draw pixel
	sw $t1, 0x2074($t0) # draw pixel
	sw $t1, 0x1c68($t0) # draw pixel
	sw $t1, 0x2858($t0) # draw pixel
	sw $t1, 0x2454($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x1064($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x2840($t0) # draw pixel
	sw $t1, 0x106c($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0x1848($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x2c68($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1864($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x1068($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x2060($t0) # draw pixel
	sw $t1, 0x2854($t0) # draw pixel
	sw $t1, 0x2c4c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x2c70($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x2850($t0) # draw pixel
	sw $t1, 0x2048($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0x2c54($t0) # draw pixel
	sw $t1, 0x1464($t0) # draw pixel
	sw $t1, 0x185c($t0) # draw pixel
	sw $t1, 0x2058($t0) # draw pixel
	sw $t1, 0x2c74($t0) # draw pixel
	sw $t1, 0x2458($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0x1858($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x2844($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0x1044($t0) # draw pixel
	sw $t1, 0x2c6c($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x104c($t0) # draw pixel
	sw $t1, 0x1c5c($t0) # draw pixel
	sw $t1, 0x206c($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x1c64($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x1860($t0) # draw pixel
	sw $t1, 0x2440($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x2848($t0) # draw pixel
	sw $t1, 0x1c60($t0) # draw pixel
	sw $t1, 0x1468($t0) # draw pixel
	sw $t1, 0x2474($t0) # draw pixel
	sw $t1, 0x1470($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x1054($t0) # draw pixel
	sw $t1, 0x1c44($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0xc68($t0) # draw pixel
	sw $t1, 0x3068($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x3070($t0) # draw pixel
	sw $t1, 0xc70($t0) # draw pixel
	sw $t1, 0xc6c($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x306c($t0) # draw pixel
	jr $ra

draw_sprite_car4:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	li $t1, 0x00def7 # store colour code for 0x00def7
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	li $t1, 0xff47f7 # store colour code for 0xff47f7
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	li $t1, 0x97ff00 # store colour code for 0x97ff00
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	jr $ra

draw_sprite_car5:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	jr $ra

draw_sprite_frog:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0xff00f7 # store colour code for 0xff00f7
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	li $t1, 0xffff00 # store colour code for 0xffff00
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	jr $ra

draw_sprite_game_over_screen:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0xffff00 # store colour code for 0xffff00
	sw $t1, 0xc540($t0) # draw pixel
	sw $t1, 0x1d67c($t0) # draw pixel
	sw $t1, 0x1d250($t0) # draw pixel
	sw $t1, 0x1dae4($t0) # draw pixel
	sw $t1, 0xceac($t0) # draw pixel
	sw $t1, 0x1dadc($t0) # draw pixel
	sw $t1, 0x9d98($t0) # draw pixel
	sw $t1, 0x1d904($t0) # draw pixel
	sw $t1, 0x1cf08($t0) # draw pixel
	sw $t1, 0x1c918($t0) # draw pixel
	sw $t1, 0x1d4d8($t0) # draw pixel
	sw $t1, 0x1c17c($t0) # draw pixel
	sw $t1, 0x1cde8($t0) # draw pixel
	sw $t1, 0x1d27c($t0) # draw pixel
	sw $t1, 0x1c170($t0) # draw pixel
	sw $t1, 0x1c628($t0) # draw pixel
	sw $t1, 0x1c328($t0) # draw pixel
	sw $t1, 0xce5c($t0) # draw pixel
	sw $t1, 0x1d2c0($t0) # draw pixel
	sw $t1, 0x1d2f8($t0) # draw pixel
	sw $t1, 0x9d44($t0) # draw pixel
	sw $t1, 0x1c610($t0) # draw pixel
	sw $t1, 0xceb4($t0) # draw pixel
	sw $t1, 0x1c570($t0) # draw pixel
	sw $t1, 0x1cd88($t0) # draw pixel
	sw $t1, 0x1db20($t0) # draw pixel
	sw $t1, 0x1c108($t0) # draw pixel
	sw $t1, 0xc53c($t0) # draw pixel
	sw $t1, 0x1d528($t0) # draw pixel
	sw $t1, 0x9f24($t0) # draw pixel
	sw $t1, 0x9e14($t0) # draw pixel
	sw $t1, 0xceb0($t0) # draw pixel
	sw $t1, 0x9ce8($t0) # draw pixel
	sw $t1, 0x1c5e4($t0) # draw pixel
	sw $t1, 0x1da7c($t0) # draw pixel
	sw $t1, 0x1d9dc($t0) # draw pixel
	sw $t1, 0x1cb30($t0) # draw pixel
	sw $t1, 0xb4d8($t0) # draw pixel
	sw $t1, 0xb554($t0) # draw pixel
	sw $t1, 0x1c2f8($t0) # draw pixel
	sw $t1, 0x9f1c($t0) # draw pixel
	sw $t1, 0x1c8b8($t0) # draw pixel
	sw $t1, 0x1d25c($t0) # draw pixel
	sw $t1, 0x9ecc($t0) # draw pixel
	sw $t1, 0x1d300($t0) # draw pixel
	sw $t1, 0x1d570($t0) # draw pixel
	sw $t1, 0x1c8c8($t0) # draw pixel
	sw $t1, 0x1d71c($t0) # draw pixel
	sw $t1, 0x1d6b0($t0) # draw pixel
	sw $t1, 0xb4e0($t0) # draw pixel
	sw $t1, 0x1d708($t0) # draw pixel
	sw $t1, 0x1ce54($t0) # draw pixel
	sw $t1, 0x1dae0($t0) # draw pixel
	sw $t1, 0x1c184($t0) # draw pixel
	sw $t1, 0x1d614($t0) # draw pixel
	sw $t1, 0x1c524($t0) # draw pixel
	sw $t1, 0x1ca68($t0) # draw pixel
	sw $t1, 0x1d6e8($t0) # draw pixel
	sw $t1, 0x1c0c4($t0) # draw pixel
	sw $t1, 0x1cb04($t0) # draw pixel
	sw $t1, 0x1c9d0($t0) # draw pixel
	sw $t1, 0x1d0b8($t0) # draw pixel
	sw $t1, 0x1cb44($t0) # draw pixel
	sw $t1, 0x1c984($t0) # draw pixel
	sw $t1, 0x1ce24($t0) # draw pixel
	sw $t1, 0x1c6f4($t0) # draw pixel
	sw $t1, 0x1d548($t0) # draw pixel
	sw $t1, 0xb4e4($t0) # draw pixel
	sw $t1, 0x1da80($t0) # draw pixel
	sw $t1, 0x1d264($t0) # draw pixel
	sw $t1, 0x1c13c($t0) # draw pixel
	sw $t1, 0x1d6d4($t0) # draw pixel
	sw $t1, 0x1c5bc($t0) # draw pixel
	sw $t1, 0x1d610($t0) # draw pixel
	sw $t1, 0x1d6f4($t0) # draw pixel
	sw $t1, 0x1dab4($t0) # draw pixel
	sw $t1, 0xc5f0($t0) # draw pixel
	sw $t1, 0x1dae8($t0) # draw pixel
	sw $t1, 0x1d33c($t0) # draw pixel
	sw $t1, 0x1d93c($t0) # draw pixel
	sw $t1, 0x1d2c4($t0) # draw pixel
	sw $t1, 0x1d574($t0) # draw pixel
	sw $t1, 0x1c2c0($t0) # draw pixel
	sw $t1, 0x9d48($t0) # draw pixel
	sw $t1, 0x1c1b8($t0) # draw pixel
	sw $t1, 0x1d280($t0) # draw pixel
	sw $t1, 0x1cd08($t0) # draw pixel
	sw $t1, 0x1d534($t0) # draw pixel
	sw $t1, 0x9f28($t0) # draw pixel
	sw $t1, 0x9ec8($t0) # draw pixel
	sw $t1, 0x1c614($t0) # draw pixel
	sw $t1, 0x1c344($t0) # draw pixel
	sw $t1, 0x1ca64($t0) # draw pixel
	sw $t1, 0x1cef4($t0) # draw pixel
	sw $t1, 0x1c574($t0) # draw pixel
	sw $t1, 0x1c120($t0) # draw pixel
	sw $t1, 0x1c584($t0) # draw pixel
	sw $t1, 0xb608($t0) # draw pixel
	sw $t1, 0x9e00($t0) # draw pixel
	sw $t1, 0x1cb3c($t0) # draw pixel
	sw $t1, 0x1c4c8($t0) # draw pixel
	sw $t1, 0x1c8f8($t0) # draw pixel
	sw $t1, 0x1c588($t0) # draw pixel
	sw $t1, 0x1d234($t0) # draw pixel
	sw $t1, 0xce54($t0) # draw pixel
	sw $t1, 0x1ca10($t0) # draw pixel
	sw $t1, 0x1d8b8($t0) # draw pixel
	sw $t1, 0x1d4e8($t0) # draw pixel
	sw $t1, 0x1da64($t0) # draw pixel
	sw $t1, 0x1c0c8($t0) # draw pixel
	sw $t1, 0xbe48($t0) # draw pixel
	sw $t1, 0x1da48($t0) # draw pixel
	sw $t1, 0x9cec($t0) # draw pixel
	sw $t1, 0xce04($t0) # draw pixel
	sw $t1, 0x1d580($t0) # draw pixel
	sw $t1, 0xb664($t0) # draw pixel
	sw $t1, 0xb6c4($t0) # draw pixel
	sw $t1, 0x1c4d8($t0) # draw pixel
	sw $t1, 0x1c4f8($t0) # draw pixel
	sw $t1, 0x1c2d8($t0) # draw pixel
	sw $t1, 0x1d9e0($t0) # draw pixel
	sw $t1, 0x1d668($t0) # draw pixel
	sw $t1, 0x1c678($t0) # draw pixel
	sw $t1, 0x1d5d4($t0) # draw pixel
	sw $t1, 0xce60($t0) # draw pixel
	sw $t1, 0xcdf4($t0) # draw pixel
	sw $t1, 0xb4e8($t0) # draw pixel
	sw $t1, 0x9d40($t0) # draw pixel
	sw $t1, 0x1d6e4($t0) # draw pixel
	sw $t1, 0x1c4cc($t0) # draw pixel
	sw $t1, 0x1d0dc($t0) # draw pixel
	sw $t1, 0x1c658($t0) # draw pixel
	sw $t1, 0x1cd28($t0) # draw pixel
	sw $t1, 0x1d9d4($t0) # draw pixel
	sw $t1, 0xcd48($t0) # draw pixel
	sw $t1, 0x1cb38($t0) # draw pixel
	sw $t1, 0x1ce34($t0) # draw pixel
	sw $t1, 0x9e6c($t0) # draw pixel
	sw $t1, 0xcd8c($t0) # draw pixel
	sw $t1, 0x1c178($t0) # draw pixel
	sw $t1, 0x1dad8($t0) # draw pixel
	sw $t1, 0x1c6b8($t0) # draw pixel
	sw $t1, 0x1c8cc($t0) # draw pixel
	sw $t1, 0x1d2d4($t0) # draw pixel
	sw $t1, 0xc720($t0) # draw pixel
	sw $t1, 0x1ce14($t0) # draw pixel
	sw $t1, 0x1cdd0($t0) # draw pixel
	sw $t1, 0x1c0dc($t0) # draw pixel
	sw $t1, 0x1d344($t0) # draw pixel
	sw $t1, 0x1ce38($t0) # draw pixel
	sw $t1, 0x1cb20($t0) # draw pixel
	sw $t1, 0x1cf40($t0) # draw pixel
	sw $t1, 0xcda0($t0) # draw pixel
	sw $t1, 0x1c704($t0) # draw pixel
	sw $t1, 0x1c260($t0) # draw pixel
	sw $t1, 0xccc4($t0) # draw pixel
	sw $t1, 0xce78($t0) # draw pixel
	sw $t1, 0xcf34($t0) # draw pixel
	sw $t1, 0x1c6c0($t0) # draw pixel
	sw $t1, 0x1d9bc($t0) # draw pixel
	sw $t1, 0x1d8fc($t0) # draw pixel
	sw $t1, 0x1d0fc($t0) # draw pixel
	sw $t1, 0x1d680($t0) # draw pixel
	sw $t1, 0x9ec0($t0) # draw pixel
	sw $t1, 0x1d970($t0) # draw pixel
	sw $t1, 0x1da44($t0) # draw pixel
	sw $t1, 0xce64($t0) # draw pixel
	sw $t1, 0x1c0e8($t0) # draw pixel
	sw $t1, 0x1dac4($t0) # draw pixel
	sw $t1, 0x1cd34($t0) # draw pixel
	sw $t1, 0x1d334($t0) # draw pixel
	sw $t1, 0x1c4ec($t0) # draw pixel
	sw $t1, 0x1c8ec($t0) # draw pixel
	sw $t1, 0xc5b8($t0) # draw pixel
	sw $t1, 0x1da14($t0) # draw pixel
	sw $t1, 0x1c71c($t0) # draw pixel
	sw $t1, 0x1c334($t0) # draw pixel
	sw $t1, 0x9d3c($t0) # draw pixel
	sw $t1, 0x1d8d8($t0) # draw pixel
	sw $t1, 0x1cb08($t0) # draw pixel
	sw $t1, 0xcd30($t0) # draw pixel
	sw $t1, 0xc584($t0) # draw pixel
	sw $t1, 0x1c2fc($t0) # draw pixel
	sw $t1, 0x9f20($t0) # draw pixel
	sw $t1, 0x1d924($t0) # draw pixel
	sw $t1, 0x1c31c($t0) # draw pixel
	sw $t1, 0xbe44($t0) # draw pixel
	sw $t1, 0x1cf1c($t0) # draw pixel
	sw $t1, 0x1cb1c($t0) # draw pixel
	sw $t1, 0x9e08($t0) # draw pixel
	sw $t1, 0x1d128($t0) # draw pixel
	sw $t1, 0x1c9d4($t0) # draw pixel
	sw $t1, 0x1ced4($t0) # draw pixel
	sw $t1, 0x1d920($t0) # draw pixel
	sw $t1, 0x1d908($t0) # draw pixel
	sw $t1, 0x1c1d4($t0) # draw pixel
	sw $t1, 0x1c10c($t0) # draw pixel
	sw $t1, 0xcecc($t0) # draw pixel
	sw $t1, 0x1caf0($t0) # draw pixel
	sw $t1, 0x9e18($t0) # draw pixel
	sw $t1, 0x1c0fc($t0) # draw pixel
	sw $t1, 0x1c9e8($t0) # draw pixel
	sw $t1, 0x1d734($t0) # draw pixel
	sw $t1, 0x1c180($t0) # draw pixel
	sw $t1, 0x1d530($t0) # draw pixel
	sw $t1, 0xced0($t0) # draw pixel
	sw $t1, 0x1c0b8($t0) # draw pixel
	sw $t1, 0xce18($t0) # draw pixel
	sw $t1, 0x1cd3c($t0) # draw pixel
	sw $t1, 0x1da38($t0) # draw pixel
	sw $t1, 0xb4dc($t0) # draw pixel
	sw $t1, 0x9f18($t0) # draw pixel
	sw $t1, 0x1cd40($t0) # draw pixel
	sw $t1, 0xce68($t0) # draw pixel
	sw $t1, 0x1c974($t0) # draw pixel
	sw $t1, 0xce08($t0) # draw pixel
	sw $t1, 0x1d21c($t0) # draw pixel
	sw $t1, 0x1c1bc($t0) # draw pixel
	sw $t1, 0xb6cc($t0) # draw pixel
	sw $t1, 0x1c684($t0) # draw pixel
	sw $t1, 0x1d704($t0) # draw pixel
	sw $t1, 0xcd90($t0) # draw pixel
	sw $t1, 0x1cf44($t0) # draw pixel
	sw $t1, 0x1d0bc($t0) # draw pixel
	sw $t1, 0x1cf38($t0) # draw pixel
	sw $t1, 0x1cb34($t0) # draw pixel
	sw $t1, 0xb6c8($t0) # draw pixel
	sw $t1, 0x1c2b8($t0) # draw pixel
	sw $t1, 0x1c730($t0) # draw pixel
	sw $t1, 0x1d17c($t0) # draw pixel
	sw $t1, 0x1cd44($t0) # draw pixel
	sw $t1, 0x1c6c4($t0) # draw pixel
	sw $t1, 0xc5ec($t0) # draw pixel
	sw $t1, 0x1cee4($t0) # draw pixel
	sw $t1, 0x1ccec($t0) # draw pixel
	sw $t1, 0x1ccd4($t0) # draw pixel
	sw $t1, 0x1caf4($t0) # draw pixel
	sw $t1, 0xcd50($t0) # draw pixel
	sw $t1, 0x1da68($t0) # draw pixel
	sw $t1, 0x1d8e4($t0) # draw pixel
	sw $t1, 0x1cd24($t0) # draw pixel
	sw $t1, 0xce74($t0) # draw pixel
	sw $t1, 0x1c0d8($t0) # draw pixel
	sw $t1, 0x1d984($t0) # draw pixel
	sw $t1, 0x1c638($t0) # draw pixel
	sw $t1, 0x1d1bc($t0) # draw pixel
	sw $t1, 0xcf2c($t0) # draw pixel
	sw $t1, 0x1d720($t0) # draw pixel
	sw $t1, 0x1d928($t0) # draw pixel
	sw $t1, 0x1c1b4($t0) # draw pixel
	sw $t1, 0x1d9c0($t0) # draw pixel
	sw $t1, 0xcf30($t0) # draw pixel
	sw $t1, 0xa658($t0) # draw pixel
	sw $t1, 0x1cd74($t0) # draw pixel
	sw $t1, 0xcdb0($t0) # draw pixel
	sw $t1, 0x1c674($t0) # draw pixel
	sw $t1, 0x1ccb8($t0) # draw pixel
	sw $t1, 0x9e0c($t0) # draw pixel
	sw $t1, 0xcf04($t0) # draw pixel
	sw $t1, 0x1c214($t0) # draw pixel
	sw $t1, 0x9e04($t0) # draw pixel
	sw $t1, 0x1d1d4($t0) # draw pixel
	sw $t1, 0x1c514($t0) # draw pixel
	sw $t1, 0x1c4b8($t0) # draw pixel
	sw $t1, 0xcd28($t0) # draw pixel
	sw $t1, 0xcec4($t0) # draw pixel
	sw $t1, 0x1c224($t0) # draw pixel
	sw $t1, 0x1c1dc($t0) # draw pixel
	sw $t1, 0xbde4($t0) # draw pixel
	sw $t1, 0x1d254($t0) # draw pixel
	sw $t1, 0x1cee8($t0) # draw pixel
	sw $t1, 0x1db04($t0) # draw pixel
	sw $t1, 0x1d180($t0) # draw pixel
	sw $t1, 0x1d584($t0) # draw pixel
	sw $t1, 0x1cdc0($t0) # draw pixel
	sw $t1, 0x1db24($t0) # draw pixel
	sw $t1, 0xbde8($t0) # draw pixel
	sw $t1, 0x1d91c($t0) # draw pixel
	sw $t1, 0x1cdd4($t0) # draw pixel
	sw $t1, 0x9e10($t0) # draw pixel
	sw $t1, 0x1c654($t0) # draw pixel
	sw $t1, 0x1cf20($t0) # draw pixel
	sw $t1, 0x1c8fc($t0) # draw pixel
	sw $t1, 0x1db30($t0) # draw pixel
	sw $t1, 0x1c9e4($t0) # draw pixel
	sw $t1, 0x1c140($t0) # draw pixel
	sw $t1, 0xcdf8($t0) # draw pixel
	sw $t1, 0x1c9bc($t0) # draw pixel
	sw $t1, 0x9e74($t0) # draw pixel
	sw $t1, 0x1c300($t0) # draw pixel
	sw $t1, 0x1c8d8($t0) # draw pixel
	sw $t1, 0x1d4d4($t0) # draw pixel
	sw $t1, 0x9da8($t0) # draw pixel
	sw $t1, 0x1db48($t0) # draw pixel
	sw $t1, 0x1c6b4($t0) # draw pixel
	sw $t1, 0x1c970($t0) # draw pixel
	sw $t1, 0xccc8($t0) # draw pixel
	sw $t1, 0x9e64($t0) # draw pixel
	sw $t1, 0x1d5c0($t0) # draw pixel
	sw $t1, 0x1db44($t0) # draw pixel
	sw $t1, 0x1c124($t0) # draw pixel
	sw $t1, 0x1da34($t0) # draw pixel
	sw $t1, 0xce00($t0) # draw pixel
	sw $t1, 0x1c6d4($t0) # draw pixel
	sw $t1, 0xcd24($t0) # draw pixel
	sw $t1, 0x1d2d0($t0) # draw pixel
	sw $t1, 0x1d5bc($t0) # draw pixel
	sw $t1, 0x1db08($t0) # draw pixel
	sw $t1, 0x1d5d0($t0) # draw pixel
	sw $t1, 0xc588($t0) # draw pixel
	sw $t1, 0x9d9c($t0) # draw pixel
	sw $t1, 0x1d4b8($t0) # draw pixel
	sw $t1, 0x1d748($t0) # draw pixel
	sw $t1, 0x1c634($t0) # draw pixel
	sw $t1, 0xcd98($t0) # draw pixel
	sw $t1, 0x9ed0($t0) # draw pixel
	sw $t1, 0x1d4e4($t0) # draw pixel
	sw $t1, 0x1d988($t0) # draw pixel
	sw $t1, 0x1c1e0($t0) # draw pixel
	sw $t1, 0x1c5d4($t0) # draw pixel
	sw $t1, 0x1c118($t0) # draw pixel
	sw $t1, 0x1d268($t0) # draw pixel
	sw $t1, 0xb550($t0) # draw pixel
	sw $t1, 0x1c1c4($t0) # draw pixel
	sw $t1, 0x1d0f8($t0) # draw pixel
	sw $t1, 0x1d4b4($t0) # draw pixel
	sw $t1, 0x1c220($t0) # draw pixel
	sw $t1, 0x1da40($t0) # draw pixel
	sw $t1, 0x1c218($t0) # draw pixel
	sw $t1, 0x1c5e8($t0) # draw pixel
	sw $t1, 0x1c734($t0) # draw pixel
	sw $t1, 0xb734($t0) # draw pixel
	sw $t1, 0xcd2c($t0) # draw pixel
	sw $t1, 0x1d304($t0) # draw pixel
	sw $t1, 0xce14($t0) # draw pixel
	sw $t1, 0x1d2b0($t0) # draw pixel
	sw $t1, 0x1c25c($t0) # draw pixel
	sw $t1, 0x1d31c($t0) # draw pixel
	sw $t1, 0x1c104($t0) # draw pixel
	sw $t1, 0xcd58($t0) # draw pixel
	sw $t1, 0x1cd70($t0) # draw pixel
	sw $t1, 0x1d330($t0) # draw pixel
	sw $t1, 0x1c8d4($t0) # draw pixel
	sw $t1, 0x1c348($t0) # draw pixel
	sw $t1, 0x9d38($t0) # draw pixel
	sw $t1, 0xccd0($t0) # draw pixel
	sw $t1, 0x1c934($t0) # draw pixel
	sw $t1, 0x9cd8($t0) # draw pixel
	sw $t1, 0x9cf4($t0) # draw pixel
	sw $t1, 0x1cce4($t0) # draw pixel
	sw $t1, 0x1cce8($t0) # draw pixel
	sw $t1, 0x1cf48($t0) # draw pixel
	sw $t1, 0x1c314($t0) # draw pixel
	sw $t1, 0xcec0($t0) # draw pixel
	sw $t1, 0x1ca14($t0) # draw pixel
	sw $t1, 0xc538($t0) # draw pixel
	sw $t1, 0xc71c($t0) # draw pixel
	sw $t1, 0x1ce50($t0) # draw pixel
	sw $t1, 0x1c1c0($t0) # draw pixel
	sw $t1, 0xcf38($t0) # draw pixel
	sw $t1, 0x1c0e4($t0) # draw pixel
	sw $t1, 0x1c6d8($t0) # draw pixel
	sw $t1, 0x1d9e4($t0) # draw pixel
	sw $t1, 0x1db18($t0) # draw pixel
	sw $t1, 0x1d4e0($t0) # draw pixel
	sw $t1, 0x1c318($t0) # draw pixel
	sw $t1, 0x1c988($t0) # draw pixel
	sw $t1, 0x1c720($t0) # draw pixel
	sw $t1, 0xceb8($t0) # draw pixel
	sw $t1, 0x1d4fc($t0) # draw pixel
	sw $t1, 0x1cd80($t0) # draw pixel
	sw $t1, 0x1d2c8($t0) # draw pixel
	sw $t1, 0x1c238($t0) # draw pixel
	sw $t1, 0x1d0d8($t0) # draw pixel
	sw $t1, 0x1d1d0($t0) # draw pixel
	sw $t1, 0x1da54($t0) # draw pixel
	sw $t1, 0xcec8($t0) # draw pixel
	sw $t1, 0x1d0c0($t0) # draw pixel
	sw $t1, 0x1d340($t0) # draw pixel
	sw $t1, 0x1c100($t0) # draw pixel
	sw $t1, 0x1c5c0($t0) # draw pixel
	sw $t1, 0x1db14($t0) # draw pixel
	sw $t1, 0x1c21c($t0) # draw pixel
	sw $t1, 0xc650($t0) # draw pixel
	sw $t1, 0x1d6c4($t0) # draw pixel
	sw $t1, 0x9ce4($t0) # draw pixel
	sw $t1, 0x1c0e0($t0) # draw pixel
	sw $t1, 0xce70($t0) # draw pixel
	sw $t1, 0x1c700($t0) # draw pixel
	sw $t1, 0x1d650($t0) # draw pixel
	sw $t1, 0x1c930($t0) # draw pixel
	sw $t1, 0x1c744($t0) # draw pixel
	sw $t1, 0x1dac8($t0) # draw pixel
	sw $t1, 0x1d2e8($t0) # draw pixel
	sw $t1, 0x1d148($t0) # draw pixel
	sw $t1, 0x1ca38($t0) # draw pixel
	sw $t1, 0x1cac4($t0) # draw pixel
	sw $t1, 0x9da0($t0) # draw pixel
	sw $t1, 0x1ca54($t0) # draw pixel
	sw $t1, 0x1d6d8($t0) # draw pixel
	sw $t1, 0x1c11c($t0) # draw pixel
	sw $t1, 0x1c0bc($t0) # draw pixel
	sw $t1, 0x1cd20($t0) # draw pixel
	sw $t1, 0x1c664($t0) # draw pixel
	sw $t1, 0x1c324($t0) # draw pixel
	sw $t1, 0x1ce80($t0) # draw pixel
	sw $t1, 0x1ce84($t0) # draw pixel
	sw $t1, 0x1d174($t0) # draw pixel
	sw $t1, 0x9cdc($t0) # draw pixel
	sw $t1, 0x1ce68($t0) # draw pixel
	sw $t1, 0x1c2e0($t0) # draw pixel
	sw $t1, 0xcd44($t0) # draw pixel
	sw $t1, 0x1c174($t0) # draw pixel
	sw $t1, 0x1d170($t0) # draw pixel
	sw $t1, 0x1cb48($t0) # draw pixel
	sw $t1, 0x1d5e8($t0) # draw pixel
	sw $t1, 0x1ce7c($t0) # draw pixel
	sw $t1, 0x1ced0($t0) # draw pixel
	sw $t1, 0x1c8b4($t0) # draw pixel
	sw $t1, 0x1c234($t0) # draw pixel
	sw $t1, 0x9ec4($t0) # draw pixel
	sw $t1, 0x1cccc($t0) # draw pixel
	sw $t1, 0xcda8($t0) # draw pixel
	sw $t1, 0xcf10($t0) # draw pixel
	sw $t1, 0x1c2dc($t0) # draw pixel
	sw $t1, 0x1d1c0($t0) # draw pixel
	sw $t1, 0x1c2e8($t0) # draw pixel
	sw $t1, 0x1cf30($t0) # draw pixel
	sw $t1, 0x1ca84($t0) # draw pixel
	sw $t1, 0x1cd00($t0) # draw pixel
	sw $t1, 0x1c8e8($t0) # draw pixel
	sw $t1, 0xcebc($t0) # draw pixel
	sw $t1, 0x1d638($t0) # draw pixel
	sw $t1, 0x1d57c($t0) # draw pixel
	sw $t1, 0x1d0e4($t0) # draw pixel
	sw $t1, 0xcd9c($t0) # draw pixel
	sw $t1, 0x1c138($t0) # draw pixel
	sw $t1, 0x1c210($t0) # draw pixel
	sw $t1, 0x1d90c($t0) # draw pixel
	sw $t1, 0x1c530($t0) # draw pixel
	sw $t1, 0xcd4c($t0) # draw pixel
	sw $t1, 0x1c4d4($t0) # draw pixel
	sw $t1, 0xced4($t0) # draw pixel
	sw $t1, 0x1d210($t0) # draw pixel
	sw $t1, 0x1ca34($t0) # draw pixel
	sw $t1, 0xce58($t0) # draw pixel
	sw $t1, 0x1c518($t0) # draw pixel
	sw $t1, 0x1d1e8($t0) # draw pixel
	sw $t1, 0x1c288($t0) # draw pixel
	sw $t1, 0x1da10($t0) # draw pixel
	sw $t1, 0x1c2bc($t0) # draw pixel
	sw $t1, 0x1c1c8($t0) # draw pixel
	sw $t1, 0x1ce78($t0) # draw pixel
	sw $t1, 0x1d2b8($t0) # draw pixel
	sw $t1, 0x9e70($t0) # draw pixel
	sw $t1, 0x1d320($t0) # draw pixel
	sw $t1, 0x1c4e8($t0) # draw pixel
	sw $t1, 0xb730($t0) # draw pixel
	sw $t1, 0x1d6b4($t0) # draw pixel
	sw $t1, 0x1d9d8($t0) # draw pixel
	sw $t1, 0x1d2e4($t0) # draw pixel
	sw $t1, 0x1cde4($t0) # draw pixel
	sw $t1, 0x1d654($t0) # draw pixel
	sw $t1, 0x1ccfc($t0) # draw pixel
	sw $t1, 0x1c2e4($t0) # draw pixel
	sw $t1, 0x1d664($t0) # draw pixel
	sw $t1, 0x1c0f8($t0) # draw pixel
	sw $t1, 0x1daf0($t0) # draw pixel
	sw $t1, 0xcd94($t0) # draw pixel
	sw $t1, 0x1d224($t0) # draw pixel
	sw $t1, 0x1d934($t0) # draw pixel
	sw $t1, 0x1daf4($t0) # draw pixel
	sw $t1, 0xcf28($t0) # draw pixel
	sw $t1, 0x1c540($t0) # draw pixel
	sw $t1, 0x1c660($t0) # draw pixel
	sw $t1, 0xce0c($t0) # draw pixel
	sw $t1, 0x1ce28($t0) # draw pixel
	sw $t1, 0x1d900($t0) # draw pixel
	sw $t1, 0x9e68($t0) # draw pixel
	sw $t1, 0x1d308($t0) # draw pixel
	sw $t1, 0x1c6f8($t0) # draw pixel
	sw $t1, 0x1c0d4($t0) # draw pixel
	sw $t1, 0x1dab0($t0) # draw pixel
	sw $t1, 0xcccc($t0) # draw pixel
	sw $t1, 0x1c5d0($t0) # draw pixel
	sw $t1, 0x1ccd8($t0) # draw pixel
	sw $t1, 0x1c330($t0) # draw pixel
	sw $t1, 0x1cad0($t0) # draw pixel
	sw $t1, 0x1d0d4($t0) # draw pixel
	sw $t1, 0x1d238($t0) # draw pixel
	sw $t1, 0x1ccb4($t0) # draw pixel
	sw $t1, 0xcd54($t0) # draw pixel
	sw $t1, 0x1d740($t0) # draw pixel
	sw $t1, 0x1d1e4($t0) # draw pixel
	sw $t1, 0x1cd1c($t0) # draw pixel
	sw $t1, 0x1c528($t0) # draw pixel
	sw $t1, 0x1d348($t0) # draw pixel
	sw $t1, 0xcda4($t0) # draw pixel
	sw $t1, 0x1cd38($t0) # draw pixel
	sw $t1, 0x1c278($t0) # draw pixel
	sw $t1, 0xced8($t0) # draw pixel
	sw $t1, 0xb6c0($t0) # draw pixel
	sw $t1, 0x1d8e8($t0) # draw pixel
	sw $t1, 0x9ed4($t0) # draw pixel
	sw $t1, 0xb4ec($t0) # draw pixel
	sw $t1, 0x1ce64($t0) # draw pixel
	sw $t1, 0x1c4b4($t0) # draw pixel
	sw $t1, 0x1cac8($t0) # draw pixel
	sw $t1, 0x1d2fc($t0) # draw pixel
	sw $t1, 0x1d0b4($t0) # draw pixel
	sw $t1, 0x1c9c0($t0) # draw pixel
	sw $t1, 0x1c624($t0) # draw pixel
	sw $t1, 0x1cab4($t0) # draw pixel
	sw $t1, 0x1d2bc($t0) # draw pixel
	sw $t1, 0x1c134($t0) # draw pixel
	sw $t1, 0x1ccc8($t0) # draw pixel
	sw $t1, 0x1ce10($t0) # draw pixel
	sw $t1, 0x1ca50($t0) # draw pixel
	sw $t1, 0x1c258($t0) # draw pixel
	sw $t1, 0x1d220($t0) # draw pixel
	sw $t1, 0xce6c($t0) # draw pixel
	sw $t1, 0x1d2b4($t0) # draw pixel
	sw $t1, 0x1d4f8($t0) # draw pixel
	sw $t1, 0x1d938($t0) # draw pixel
	sw $t1, 0x1d544($t0) # draw pixel
	sw $t1, 0x1d940($t0) # draw pixel
	sw $t1, 0x1c0c0($t0) # draw pixel
	sw $t1, 0x1c274($t0) # draw pixel
	sw $t1, 0x1c688($t0) # draw pixel
	sw $t1, 0xce10($t0) # draw pixel
	sw $t1, 0x1cad4($t0) # draw pixel
	sw $t1, 0x1cdbc($t0) # draw pixel
	sw $t1, 0xcdfc($t0) # draw pixel
	sw $t1, 0x9e60($t0) # draw pixel
	sw $t1, 0x1d518($t0) # draw pixel
	sw $t1, 0x1d944($t0) # draw pixel
	sw $t1, 0xb6d0($t0) # draw pixel
	sw $t1, 0x1c284($t0) # draw pixel
	sw $t1, 0x1d6f0($t0) # draw pixel
	sw $t1, 0x9cf0($t0) # draw pixel
	sw $t1, 0xc64c($t0) # draw pixel
	sw $t1, 0x1d0e0($t0) # draw pixel
	sw $t1, 0x1da3c($t0) # draw pixel
	sw $t1, 0x1cab0($t0) # draw pixel
	sw $t1, 0x1d8d4($t0) # draw pixel
	sw $t1, 0x1d918($t0) # draw pixel
	sw $t1, 0x1c4fc($t0) # draw pixel
	sw $t1, 0xb668($t0) # draw pixel
	sw $t1, 0x1cd84($t0) # draw pixel
	sw $t1, 0xa5f8($t0) # draw pixel
	sw $t1, 0x1ceb4($t0) # draw pixel
	sw $t1, 0x1cef0($t0) # draw pixel
	sw $t1, 0x1d2f4($t0) # draw pixel
	sw $t1, 0x1c914($t0) # draw pixel
	sw $t1, 0x9e78($t0) # draw pixel
	sw $t1, 0xb604($t0) # draw pixel
	sw $t1, 0x1d5e4($t0) # draw pixel
	sw $t1, 0x1d218($t0) # draw pixel
	sw $t1, 0xcf08($t0) # draw pixel
	sw $t1, 0x1cec8($t0) # draw pixel
	sw $t1, 0x1c544($t0) # draw pixel
	sw $t1, 0x1ca24($t0) # draw pixel
	sw $t1, 0xcf24($t0) # draw pixel
	sw $t1, 0x1ca28($t0) # draw pixel
	sw $t1, 0x1d258($t0) # draw pixel
	sw $t1, 0x1db34($t0) # draw pixel
	sw $t1, 0x1c738($t0) # draw pixel
	sw $t1, 0x9cf8($t0) # draw pixel
	sw $t1, 0x1d214($t0) # draw pixel
	sw $t1, 0x1d6c8($t0) # draw pixel
	sw $t1, 0x1c748($t0) # draw pixel
	sw $t1, 0x1d730($t0) # draw pixel
	sw $t1, 0x9ce0($t0) # draw pixel
	sw $t1, 0x1d8b4($t0) # draw pixel
	sw $t1, 0x1d8ec($t0) # draw pixel
	sw $t1, 0x1d974($t0) # draw pixel
	sw $t1, 0x1c534($t0) # draw pixel
	sw $t1, 0x1ceb0($t0) # draw pixel
	sw $t1, 0x1d2f0($t0) # draw pixel
	sw $t1, 0x1cec4($t0) # draw pixel
	sw $t1, 0x1cf04($t0) # draw pixel
	sw $t1, 0x1db1c($t0) # draw pixel
	sw $t1, 0xb738($t0) # draw pixel
	sw $t1, 0x1c1d8($t0) # draw pixel
	sw $t1, 0x1d980($t0) # draw pixel
	sw $t1, 0x1d0c8($t0) # draw pixel
	sw $t1, 0x1d8f8($t0) # draw pixel
	sw $t1, 0x1ca78($t0) # draw pixel
	sw $t1, 0x1d260($t0) # draw pixel
	sw $t1, 0x1db28($t0) # draw pixel
	sw $t1, 0x1d178($t0) # draw pixel
	sw $t1, 0x1c0b4($t0) # draw pixel
	sw $t1, 0xc718($t0) # draw pixel
	sw $t1, 0xcdac($t0) # draw pixel
	sw $t1, 0x1d0c4($t0) # draw pixel
	sw $t1, 0x1cf34($t0) # draw pixel
	sw $t1, 0x1d744($t0) # draw pixel
	sw $t1, 0x1d634($t0) # draw pixel
	sw $t1, 0x1da50($t0) # draw pixel
	sw $t1, 0xcf0c($t0) # draw pixel
	sw $t1, 0x1cf3c($t0) # draw pixel
	sw $t1, 0xb558($t0) # draw pixel
	sw $t1, 0x1c1e4($t0) # draw pixel
	sw $t1, 0x1cee0($t0) # draw pixel
	sw $t1, 0x1c320($t0) # draw pixel
	sw $t1, 0x9ed8($t0) # draw pixel
	sw $t1, 0x1cd04($t0) # draw pixel
	sw $t1, 0x1d144($t0) # draw pixel
	sw $t1, 0x9da4($t0) # draw pixel
	sw $t1, 0x1ccf8($t0) # draw pixel
	sw $t1, 0x1d514($t0) # draw pixel
	sw $t1, 0x1cd18($t0) # draw pixel
	li $t1, 0xff00f7 # store colour code for 0xff00f7
	sw $t1, 0xc6ac($t0) # draw pixel
	sw $t1, 0xa72c($t0) # draw pixel
	sw $t1, 0x98c4($t0) # draw pixel
	sw $t1, 0xc4c4($t0) # draw pixel
	sw $t1, 0xc0c4($t0) # draw pixel
	sw $t1, 0xc2ac($t0) # draw pixel
	sw $t1, 0xa1ec($t0) # draw pixel
	sw $t1, 0xa2ac($t0) # draw pixel
	sw $t1, 0x9aac($t0) # draw pixel
	sw $t1, 0x9cc4($t0) # draw pixel
	sw $t1, 0xa184($t0) # draw pixel
	sw $t1, 0xa524($t0) # draw pixel
	sw $t1, 0xc944($t0) # draw pixel
	sw $t1, 0xb264($t0) # draw pixel
	sw $t1, 0x9dac($t0) # draw pixel
	sw $t1, 0xb244($t0) # draw pixel
	sw $t1, 0xb704($t0) # draw pixel
	sw $t1, 0xc98c($t0) # draw pixel
	sw $t1, 0xbdec($t0) # draw pixel
	sw $t1, 0xba0c($t0) # draw pixel
	sw $t1, 0xa32c($t0) # draw pixel
	sw $t1, 0xb184($t0) # draw pixel
	sw $t1, 0xb60c($t0) # draw pixel
	sw $t1, 0xb324($t0) # draw pixel
	sw $t1, 0xc8c4($t0) # draw pixel
	sw $t1, 0xb5ac($t0) # draw pixel
	sw $t1, 0xc58c($t0) # draw pixel
	sw $t1, 0xaeac($t0) # draw pixel
	sw $t1, 0xa924($t0) # draw pixel
	sw $t1, 0xacc4($t0) # draw pixel
	sw $t1, 0xa984($t0) # draw pixel
	sw $t1, 0xa5ac($t0) # draw pixel
	sw $t1, 0xaa44($t0) # draw pixel
	sw $t1, 0x998c($t0) # draw pixel
	sw $t1, 0xa94c($t0) # draw pixel
	sw $t1, 0xc704($t0) # draw pixel
	sw $t1, 0xab04($t0) # draw pixel
	sw $t1, 0xae44($t0) # draw pixel
	sw $t1, 0xb584($t0) # draw pixel
	sw $t1, 0xb5e4($t0) # draw pixel
	sw $t1, 0x9b04($t0) # draw pixel
	sw $t1, 0xc184($t0) # draw pixel
	sw $t1, 0xc1ec($t0) # draw pixel
	sw $t1, 0xa9ac($t0) # draw pixel
	sw $t1, 0xaaac($t0) # draw pixel
	sw $t1, 0xbb04($t0) # draw pixel
	sw $t1, 0xb124($t0) # draw pixel
	sw $t1, 0xad24($t0) # draw pixel
	sw $t1, 0xbe0c($t0) # draw pixel
	sw $t1, 0xa584($t0) # draw pixel
	sw $t1, 0xa24c($t0) # draw pixel
	sw $t1, 0xab2c($t0) # draw pixel
	sw $t1, 0xc20c($t0) # draw pixel
	sw $t1, 0xb204($t0) # draw pixel
	sw $t1, 0xcaac($t0) # draw pixel
	sw $t1, 0xb2ac($t0) # draw pixel
	sw $t1, 0xb66c($t0) # draw pixel
	sw $t1, 0xc654($t0) # draw pixel
	sw $t1, 0xb6ac($t0) # draw pixel
	sw $t1, 0xadac($t0) # draw pixel
	sw $t1, 0xbf04($t0) # draw pixel
	sw $t1, 0xad84($t0) # draw pixel
	sw $t1, 0xb4c4($t0) # draw pixel
	sw $t1, 0xb304($t0) # draw pixel
	sw $t1, 0xba6c($t0) # draw pixel
	sw $t1, 0xbdac($t0) # draw pixel
	sw $t1, 0x9a54($t0) # draw pixel
	sw $t1, 0xa8c4($t0) # draw pixel
	sw $t1, 0xbd24($t0) # draw pixel
	sw $t1, 0x9924($t0) # draw pixel
	sw $t1, 0xc24c($t0) # draw pixel
	sw $t1, 0xa14c($t0) # draw pixel
	sw $t1, 0xa704($t0) # draw pixel
	sw $t1, 0xcb04($t0) # draw pixel
	sw $t1, 0xb984($t0) # draw pixel
	sw $t1, 0xbcc4($t0) # draw pixel
	sw $t1, 0xbd84($t0) # draw pixel
	sw $t1, 0xc724($t0) # draw pixel
	sw $t1, 0xb924($t0) # draw pixel
	sw $t1, 0x9f04($t0) # draw pixel
	sw $t1, 0xa4c4($t0) # draw pixel
	sw $t1, 0xc1ac($t0) # draw pixel
	sw $t1, 0xb524($t0) # draw pixel
	sw $t1, 0xc524($t0) # draw pixel
	sw $t1, 0xade4($t0) # draw pixel
	sw $t1, 0x99f4($t0) # draw pixel
	sw $t1, 0xb0c4($t0) # draw pixel
	sw $t1, 0xcb24($t0) # draw pixel
	sw $t1, 0xc304($t0) # draw pixel
	sw $t1, 0xa304($t0) # draw pixel
	sw $t1, 0xa54c($t0) # draw pixel
	sw $t1, 0xa6ac($t0) # draw pixel
	sw $t1, 0xa124($t0) # draw pixel
	sw $t1, 0xca54($t0) # draw pixel
	sw $t1, 0xb8c4($t0) # draw pixel
	sw $t1, 0xbe4c($t0) # draw pixel
	sw $t1, 0xbe6c($t0) # draw pixel
	sw $t1, 0xc5f4($t0) # draw pixel
	sw $t1, 0xaf04($t0) # draw pixel
	sw $t1, 0xbaac($t0) # draw pixel
	sw $t1, 0x9eac($t0) # draw pixel
	sw $t1, 0xc9f4($t0) # draw pixel
	sw $t1, 0xb1ac($t0) # draw pixel
	sw $t1, 0xb144($t0) # draw pixel
	sw $t1, 0x9f2c($t0) # draw pixel
	sw $t1, 0xc124($t0) # draw pixel
	sw $t1, 0x9d24($t0) # draw pixel
	sw $t1, 0xc26c($t0) # draw pixel
	sw $t1, 0xb9ac($t0) # draw pixel
	sw $t1, 0xb1e4($t0) # draw pixel
	sw $t1, 0xa9e4($t0) # draw pixel
	sw $t1, 0xc924($t0) # draw pixel
	sw $t1, 0xa0c4($t0) # draw pixel
	sw $t1, 0xb9e4($t0) # draw pixel
	sw $t1, 0xb644($t0) # draw pixel
	sw $t1, 0xba44($t0) # draw pixel
	sw $t1, 0xa1ac($t0) # draw pixel
	sw $t1, 0xc544($t0) # draw pixel
	sw $t1, 0xbeac($t0) # draw pixel
	sw $t1, 0x9d4c($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0xae10($t0) # draw pixel
	sw $t1, 0xaf10($t0) # draw pixel
	sw $t1, 0xacd0($t0) # draw pixel
	sw $t1, 0xa930($t0) # draw pixel
	sw $t1, 0xc5ac($t0) # draw pixel
	sw $t1, 0xc214($t0) # draw pixel
	sw $t1, 0xc70c($t0) # draw pixel
	sw $t1, 0xa0c8($t0) # draw pixel
	sw $t1, 0xb534($t0) # draw pixel
	sw $t1, 0x9f30($t0) # draw pixel
	sw $t1, 0xad34($t0) # draw pixel
	sw $t1, 0xb2c8($t0) # draw pixel
	sw $t1, 0xc2bc($t0) # draw pixel
	sw $t1, 0xa958($t0) # draw pixel
	sw $t1, 0xca18($t0) # draw pixel
	sw $t1, 0xb0e0($t0) # draw pixel
	sw $t1, 0x9548($t0) # draw pixel
	sw $t1, 0xaeb4($t0) # draw pixel
	sw $t1, 0x9cd4($t0) # draw pixel
	sw $t1, 0xc9a8($t0) # draw pixel
	sw $t1, 0xa738($t0) # draw pixel
	sw $t1, 0xb2d4($t0) # draw pixel
	sw $t1, 0xc320($t0) # draw pixel
	sw $t1, 0xb15c($t0) # draw pixel
	sw $t1, 0xc728($t0) # draw pixel
	sw $t1, 0x9534($t0) # draw pixel
	sw $t1, 0xb940($t0) # draw pixel
	sw $t1, 0xbd94($t0) # draw pixel
	sw $t1, 0xcb10($t0) # draw pixel
	sw $t1, 0x9eb0($t0) # draw pixel
	sw $t1, 0xb548($t0) # draw pixel
	sw $t1, 0xb61c($t0) # draw pixel
	sw $t1, 0xbf14($t0) # draw pixel
	sw $t1, 0xc950($t0) # draw pixel
	sw $t1, 0xb2d0($t0) # draw pixel
	sw $t1, 0xc270($t0) # draw pixel
	sw $t1, 0x96cc($t0) # draw pixel
	sw $t1, 0xb714($t0) # draw pixel
	sw $t1, 0x9a08($t0) # draw pixel
	sw $t1, 0xb210($t0) # draw pixel
	sw $t1, 0xb5b0($t0) # draw pixel
	sw $t1, 0xcac8($t0) # draw pixel
	sw $t1, 0xb338($t0) # draw pixel
	sw $t1, 0xbf24($t0) # draw pixel
	sw $t1, 0xb590($t0) # draw pixel
	sw $t1, 0xb990($t0) # draw pixel
	sw $t1, 0xca0c($t0) # draw pixel
	sw $t1, 0xc2b0($t0) # draw pixel
	sw $t1, 0xaab4($t0) # draw pixel
	sw $t1, 0xab34($t0) # draw pixel
	sw $t1, 0xb718($t0) # draw pixel
	sw $t1, 0xbe50($t0) # draw pixel
	sw $t1, 0x9ebc($t0) # draw pixel
	sw $t1, 0xb208($t0) # draw pixel
	sw $t1, 0x94d4($t0) # draw pixel
	sw $t1, 0xc134($t0) # draw pixel
	sw $t1, 0x95b4($t0) # draw pixel
	sw $t1, 0x98e4($t0) # draw pixel
	sw $t1, 0xb1f0($t0) # draw pixel
	sw $t1, 0xb30c($t0) # draw pixel
	sw $t1, 0xc8cc($t0) # draw pixel
	sw $t1, 0xa194($t0) # draw pixel
	sw $t1, 0xb2b0($t0) # draw pixel
	sw $t1, 0xcb3c($t0) # draw pixel
	sw $t1, 0xb9b0($t0) # draw pixel
	sw $t1, 0xa8d0($t0) # draw pixel
	sw $t1, 0xab30($t0) # draw pixel
	sw $t1, 0xc274($t0) # draw pixel
	sw $t1, 0xa708($t0) # draw pixel
	sw $t1, 0xca04($t0) # draw pixel
	sw $t1, 0xab14($t0) # draw pixel
	sw $t1, 0xc2b4($t0) # draw pixel
	sw $t1, 0xb4d0($t0) # draw pixel
	sw $t1, 0xaf38($t0) # draw pixel
	sw $t1, 0x96bc($t0) # draw pixel
	sw $t1, 0x9b14($t0) # draw pixel
	sw $t1, 0xb614($t0) # draw pixel
	sw $t1, 0x9a78($t0) # draw pixel
	sw $t1, 0xb5e8($t0) # draw pixel
	sw $t1, 0xca1c($t0) # draw pixel
	sw $t1, 0xcad4($t0) # draw pixel
	sw $t1, 0x9530($t0) # draw pixel
	sw $t1, 0xbe1c($t0) # draw pixel
	sw $t1, 0xae4c($t0) # draw pixel
	sw $t1, 0xbd88($t0) # draw pixel
	sw $t1, 0xb938($t0) # draw pixel
	sw $t1, 0xb4cc($t0) # draw pixel
	sw $t1, 0x9a18($t0) # draw pixel
	sw $t1, 0xba7c($t0) # draw pixel
	sw $t1, 0x98d4($t0) # draw pixel
	sw $t1, 0x94d8($t0) # draw pixel
	sw $t1, 0xbd34($t0) # draw pixel
	sw $t1, 0x9b2c($t0) # draw pixel
	sw $t1, 0xc92c($t0) # draw pixel
	sw $t1, 0xca68($t0) # draw pixel
	sw $t1, 0xaeb8($t0) # draw pixel
	sw $t1, 0xb728($t0) # draw pixel
	sw $t1, 0xca14($t0) # draw pixel
	sw $t1, 0x94dc($t0) # draw pixel
	sw $t1, 0xc934($t0) # draw pixel
	sw $t1, 0xc678($t0) # draw pixel
	sw $t1, 0xb2c0($t0) # draw pixel
	sw $t1, 0xbd28($t0) # draw pixel
	sw $t1, 0xae74($t0) # draw pixel
	sw $t1, 0x96d8($t0) # draw pixel
	sw $t1, 0x95a0($t0) # draw pixel
	sw $t1, 0xa928($t0) # draw pixel
	sw $t1, 0xc138($t0) # draw pixel
	sw $t1, 0xb2cc($t0) # draw pixel
	sw $t1, 0xc930($t0) # draw pixel
	sw $t1, 0x98f4($t0) # draw pixel
	sw $t1, 0xaed0($t0) # draw pixel
	sw $t1, 0xa70c($t0) # draw pixel
	sw $t1, 0xc130($t0) # draw pixel
	sw $t1, 0x9724($t0) # draw pixel
	sw $t1, 0xb8cc($t0) # draw pixel
	sw $t1, 0xb934($t0) # draw pixel
	sw $t1, 0xbb08($t0) # draw pixel
	sw $t1, 0x953c($t0) # draw pixel
	sw $t1, 0x9f08($t0) # draw pixel
	sw $t1, 0x967c($t0) # draw pixel
	sw $t1, 0xc738($t0) # draw pixel
	sw $t1, 0xa1f0($t0) # draw pixel
	sw $t1, 0x9a1c($t0) # draw pixel
	sw $t1, 0xc6cc($t0) # draw pixel
	sw $t1, 0xb9f4($t0) # draw pixel
	sw $t1, 0xab38($t0) # draw pixel
	sw $t1, 0xae6c($t0) # draw pixel
	sw $t1, 0xacf4($t0) # draw pixel
	sw $t1, 0x9f3c($t0) # draw pixel
	sw $t1, 0xadf4($t0) # draw pixel
	sw $t1, 0x9614($t0) # draw pixel
	sw $t1, 0xc27c($t0) # draw pixel
	sw $t1, 0xb948($t0) # draw pixel
	sw $t1, 0xad54($t0) # draw pixel
	sw $t1, 0x9a14($t0) # draw pixel
	sw $t1, 0xbd2c($t0) # draw pixel
	sw $t1, 0x94e4($t0) # draw pixel
	sw $t1, 0xae7c($t0) # draw pixel
	sw $t1, 0xc9a0($t0) # draw pixel
	sw $t1, 0xbf2c($t0) # draw pixel
	sw $t1, 0xcb38($t0) # draw pixel
	sw $t1, 0xade8($t0) # draw pixel
	sw $t1, 0xb2b4($t0) # draw pixel
	sw $t1, 0xc328($t0) # draw pixel
	sw $t1, 0xa710($t0) # draw pixel
	sw $t1, 0x99a8($t0) # draw pixel
	sw $t1, 0x9df0($t0) # draw pixel
	sw $t1, 0xa594($t0) # draw pixel
	sw $t1, 0xa9b0($t0) # draw pixel
	sw $t1, 0xa190($t0) # draw pixel
	sw $t1, 0x9940($t0) # draw pixel
	sw $t1, 0x9db0($t0) # draw pixel
	sw $t1, 0xb528($t0) # draw pixel
	sw $t1, 0xb270($t0) # draw pixel
	sw $t1, 0xc730($t0) # draw pixel
	sw $t1, 0xa4cc($t0) # draw pixel
	sw $t1, 0x9ac8($t0) # draw pixel
	sw $t1, 0xc550($t0) # draw pixel
	sw $t1, 0x9608($t0) # draw pixel
	sw $t1, 0xba18($t0) # draw pixel
	sw $t1, 0xc218($t0) # draw pixel
	sw $t1, 0xadec($t0) # draw pixel
	sw $t1, 0xad88($t0) # draw pixel
	sw $t1, 0xad5c($t0) # draw pixel
	sw $t1, 0xbdbc($t0) # draw pixel
	sw $t1, 0xbf18($t0) # draw pixel
	sw $t1, 0xa158($t0) # draw pixel
	sw $t1, 0x9e54($t0) # draw pixel
	sw $t1, 0x9b34($t0) # draw pixel
	sw $t1, 0xae70($t0) # draw pixel
	sw $t1, 0xbb10($t0) # draw pixel
	sw $t1, 0x95b0($t0) # draw pixel
	sw $t1, 0xb930($t0) # draw pixel
	sw $t1, 0xc59c($t0) # draw pixel
	sw $t1, 0x961c($t0) # draw pixel
	sw $t1, 0xa250($t0) # draw pixel
	sw $t1, 0xb20c($t0) # draw pixel
	sw $t1, 0xb1f4($t0) # draw pixel
	sw $t1, 0xc9fc($t0) # draw pixel
	sw $t1, 0xc65c($t0) # draw pixel
	sw $t1, 0x99a0($t0) # draw pixel
	sw $t1, 0xc6c0($t0) # draw pixel
	sw $t1, 0xc1f8($t0) # draw pixel
	sw $t1, 0xae0c($t0) # draw pixel
	sw $t1, 0xa308($t0) # draw pixel
	sw $t1, 0xaf0c($t0) # draw pixel
	sw $t1, 0xb2c4($t0) # draw pixel
	sw $t1, 0xad94($t0) # draw pixel
	sw $t1, 0xcadc($t0) # draw pixel
	sw $t1, 0x9678($t0) # draw pixel
	sw $t1, 0xbf1c($t0) # draw pixel
	sw $t1, 0xba54($t0) # draw pixel
	sw $t1, 0x9b18($t0) # draw pixel
	sw $t1, 0x9ad0($t0) # draw pixel
	sw $t1, 0x995c($t0) # draw pixel
	sw $t1, 0xb8d4($t0) # draw pixel
	sw $t1, 0x9a04($t0) # draw pixel
	sw $t1, 0xa18c($t0) # draw pixel
	sw $t1, 0xbe18($t0) # draw pixel
	sw $t1, 0xacec($t0) # draw pixel
	sw $t1, 0xca78($t0) # draw pixel
	sw $t1, 0x966c($t0) # draw pixel
	sw $t1, 0xaf08($t0) # draw pixel
	sw $t1, 0x9658($t0) # draw pixel
	sw $t1, 0xa5bc($t0) # draw pixel
	sw $t1, 0xb6b4($t0) # draw pixel
	sw $t1, 0xc194($t0) # draw pixel
	sw $t1, 0x9b10($t0) # draw pixel
	sw $t1, 0x94c8($t0) # draw pixel
	sw $t1, 0xc1b4($t0) # draw pixel
	sw $t1, 0x9b3c($t0) # draw pixel
	sw $t1, 0xb71c($t0) # draw pixel
	sw $t1, 0xbdf8($t0) # draw pixel
	sw $t1, 0xc610($t0) # draw pixel
	sw $t1, 0xab0c($t0) # draw pixel
	sw $t1, 0xa534($t0) # draw pixel
	sw $t1, 0xb254($t0) # draw pixel
	sw $t1, 0x9a60($t0) # draw pixel
	sw $t1, 0xc6d4($t0) # draw pixel
	sw $t1, 0xbf0c($t0) # draw pixel
	sw $t1, 0xcad8($t0) # draw pixel
	sw $t1, 0xc594($t0) # draw pixel
	sw $t1, 0xa0d4($t0) # draw pixel
	sw $t1, 0xb14c($t0) # draw pixel
	sw $t1, 0xc8c8($t0) # draw pixel
	sw $t1, 0xb58c($t0) # draw pixel
	sw $t1, 0xca7c($t0) # draw pixel
	sw $t1, 0xaed4($t0) # draw pixel
	sw $t1, 0xb0f0($t0) # draw pixel
	sw $t1, 0xc558($t0) # draw pixel
	sw $t1, 0xbcd4($t0) # draw pixel
	sw $t1, 0x9f14($t0) # draw pixel
	sw $t1, 0x994c($t0) # draw pixel
	sw $t1, 0xb21c($t0) # draw pixel
	sw $t1, 0xb26c($t0) # draw pixel
	sw $t1, 0xa1f8($t0) # draw pixel
	sw $t1, 0xc154($t0) # draw pixel
	sw $t1, 0xa8c8($t0) # draw pixel
	sw $t1, 0xb4d4($t0) # draw pixel
	sw $t1, 0x9538($t0) # draw pixel
	sw $t1, 0x9590($t0) # draw pixel
	sw $t1, 0xbf10($t0) # draw pixel
	sw $t1, 0xa9f0($t0) # draw pixel
	sw $t1, 0xa6b4($t0) # draw pixel
	sw $t1, 0xa714($t0) # draw pixel
	sw $t1, 0xc958($t0) # draw pixel
	sw $t1, 0xc54c($t0) # draw pixel
	sw $t1, 0xcad0($t0) # draw pixel
	sw $t1, 0xc258($t0) # draw pixel
	sw $t1, 0xc6bc($t0) # draw pixel
	sw $t1, 0xa5b4($t0) # draw pixel
	sw $t1, 0xbcc8($t0) # draw pixel
	sw $t1, 0xc128($t0) # draw pixel
	sw $t1, 0xc668($t0) # draw pixel
	sw $t1, 0xa64c($t0) # draw pixel
	sw $t1, 0xa2bc($t0) # draw pixel
	sw $t1, 0xbab0($t0) # draw pixel
	sw $t1, 0xa5f4($t0) # draw pixel
	sw $t1, 0xb52c($t0) # draw pixel
	sw $t1, 0xc5b4($t0) # draw pixel
	sw $t1, 0xa134($t0) # draw pixel
	sw $t1, 0xc72c($t0) # draw pixel
	sw $t1, 0xbe78($t0) # draw pixel
	sw $t1, 0xc5fc($t0) # draw pixel
	sw $t1, 0xcb30($t0) # draw pixel
	sw $t1, 0xbe10($t0) # draw pixel
	sw $t1, 0xc6d8($t0) # draw pixel
	sw $t1, 0x9acc($t0) # draw pixel
	sw $t1, 0xa30c($t0) # draw pixel
	sw $t1, 0x98f0($t0) # draw pixel
	sw $t1, 0x94f4($t0) # draw pixel
	sw $t1, 0xc660($t0) # draw pixel
	sw $t1, 0xb594($t0) # draw pixel
	sw $t1, 0x99f8($t0) # draw pixel
	sw $t1, 0xa1f4($t0) # draw pixel
	sw $t1, 0xad90($t0) # draw pixel
	sw $t1, 0xbd48($t0) # draw pixel
	sw $t1, 0xa950($t0) # draw pixel
	sw $t1, 0x9abc($t0) # draw pixel
	sw $t1, 0xcb34($t0) # draw pixel
	sw $t1, 0xb9f0($t0) # draw pixel
	sw $t1, 0xa4c8($t0) # draw pixel
	sw $t1, 0xb18c($t0) # draw pixel
	sw $t1, 0xc318($t0) # draw pixel
	sw $t1, 0xa648($t0) # draw pixel
	sw $t1, 0xa4d0($t0) # draw pixel
	sw $t1, 0xb278($t0) # draw pixel
	sw $t1, 0xc2b8($t0) # draw pixel
	sw $t1, 0x9f38($t0) # draw pixel
	sw $t1, 0xba50($t0) # draw pixel
	sw $t1, 0xb214($t0) # draw pixel
	sw $t1, 0xacd4($t0) # draw pixel
	sw $t1, 0xaf2c($t0) # draw pixel
	sw $t1, 0xb32c($t0) # draw pixel
	sw $t1, 0xb64c($t0) # draw pixel
	sw $t1, 0x9928($t0) # draw pixel
	sw $t1, 0x96b0($t0) # draw pixel
	sw $t1, 0xb98c($t0) # draw pixel
	sw $t1, 0xa9b8($t0) # draw pixel
	sw $t1, 0xa58c($t0) # draw pixel
	sw $t1, 0xad50($t0) # draw pixel
	sw $t1, 0xc210($t0) # draw pixel
	sw $t1, 0xca6c($t0) # draw pixel
	sw $t1, 0xab10($t0) # draw pixel
	sw $t1, 0xc5a8($t0) # draw pixel
	sw $t1, 0xc534($t0) # draw pixel
	sw $t1, 0xa1fc($t0) # draw pixel
	sw $t1, 0xc600($t0) # draw pixel
	sw $t1, 0xaec0($t0) # draw pixel
	sw $t1, 0xbdb4($t0) # draw pixel
	sw $t1, 0x98fc($t0) # draw pixel
	sw $t1, 0xb2b8($t0) # draw pixel
	sw $t1, 0xa334($t0) # draw pixel
	sw $t1, 0x9d88($t0) # draw pixel
	sw $t1, 0x9720($t0) # draw pixel
	sw $t1, 0xa730($t0) # draw pixel
	sw $t1, 0xbdb8($t0) # draw pixel
	sw $t1, 0xad8c($t0) # draw pixel
	sw $t1, 0xb150($t0) # draw pixel
	sw $t1, 0x9d8c($t0) # draw pixel
	sw $t1, 0xadb4($t0) # draw pixel
	sw $t1, 0xb674($t0) # draw pixel
	sw $t1, 0x9718($t0) # draw pixel
	sw $t1, 0x9a00($t0) # draw pixel
	sw $t1, 0xc308($t0) # draw pixel
	sw $t1, 0xb2bc($t0) # draw pixel
	sw $t1, 0xb334($t0) # draw pixel
	sw $t1, 0xb0cc($t0) # draw pixel
	sw $t1, 0x9dfc($t0) # draw pixel
	sw $t1, 0xae08($t0) # draw pixel
	sw $t1, 0xc55c($t0) # draw pixel
	sw $t1, 0x9e50($t0) # draw pixel
	sw $t1, 0x9ad8($t0) # draw pixel
	sw $t1, 0xb268($t0) # draw pixel
	sw $t1, 0x98e8($t0) # draw pixel
	sw $t1, 0x96b8($t0) # draw pixel
	sw $t1, 0x9550($t0) # draw pixel
	sw $t1, 0xb650($t0) # draw pixel
	sw $t1, 0xc61c($t0) # draw pixel
	sw $t1, 0xa1b0($t0) # draw pixel
	sw $t1, 0xc664($t0) # draw pixel
	sw $t1, 0xbeb4($t0) # draw pixel
	sw $t1, 0x9930($t0) # draw pixel
	sw $t1, 0x9d58($t0) # draw pixel
	sw $t1, 0xc94c($t0) # draw pixel
	sw $t1, 0xc9ac($t0) # draw pixel
	sw $t1, 0xaab0($t0) # draw pixel
	sw $t1, 0xb54c($t0) # draw pixel
	sw $t1, 0x94e0($t0) # draw pixel
	sw $t1, 0xb540($t0) # draw pixel
	sw $t1, 0xb1b0($t0) # draw pixel
	sw $t1, 0x9708($t0) # draw pixel
	sw $t1, 0xb5f4($t0) # draw pixel
	sw $t1, 0xc948($t0) # draw pixel
	sw $t1, 0x9d50($t0) # draw pixel
	sw $t1, 0xbb18($t0) # draw pixel
	sw $t1, 0x9a5c($t0) # draw pixel
	sw $t1, 0x9db4($t0) # draw pixel
	sw $t1, 0xb12c($t0) # draw pixel
	sw $t1, 0xb53c($t0) # draw pixel
	sw $t1, 0xb6b8($t0) # draw pixel
	sw $t1, 0xa188($t0) # draw pixel
	sw $t1, 0x9d34($t0) # draw pixel
	sw $t1, 0x9df8($t0) # draw pixel
	sw $t1, 0x9a7c($t0) # draw pixel
	sw $t1, 0xb218($t0) # draw pixel
	sw $t1, 0xa258($t0) # draw pixel
	sw $t1, 0xb92c($t0) # draw pixel
	sw $t1, 0xa5b8($t0) # draw pixel
	sw $t1, 0x9d30($t0) # draw pixel
	sw $t1, 0xc614($t0) # draw pixel
	sw $t1, 0xb0c8($t0) # draw pixel
	sw $t1, 0xaa54($t0) # draw pixel
	sw $t1, 0xc1f4($t0) # draw pixel
	sw $t1, 0xba14($t0) # draw pixel
	sw $t1, 0xc73c($t0) # draw pixel
	sw $t1, 0xcb2c($t0) # draw pixel
	sw $t1, 0xc66c($t0) # draw pixel
	sw $t1, 0xc994($t0) # draw pixel
	sw $t1, 0xc32c($t0) # draw pixel
	sw $t1, 0xc150($t0) # draw pixel
	sw $t1, 0xc1b0($t0) # draw pixel
	sw $t1, 0xc4d4($t0) # draw pixel
	sw $t1, 0xa550($t0) # draw pixel
	sw $t1, 0xc188($t0) # draw pixel
	sw $t1, 0xca58($t0) # draw pixel
	sw $t1, 0xadf0($t0) # draw pixel
	sw $t1, 0xb1b8($t0) # draw pixel
	sw $t1, 0xb0d4($t0) # draw pixel
	sw $t1, 0xa530($t0) # draw pixel
	sw $t1, 0x9660($t0) # draw pixel
	sw $t1, 0xa73c($t0) # draw pixel
	sw $t1, 0x9f10($t0) # draw pixel
	sw $t1, 0xaf28($t0) # draw pixel
	sw $t1, 0x9dbc($t0) # draw pixel
	sw $t1, 0x9f34($t0) # draw pixel
	sw $t1, 0xb9b4($t0) # draw pixel
	sw $t1, 0xb648($t0) # draw pixel
	sw $t1, 0xa988($t0) # draw pixel
	sw $t1, 0x95ac($t0) # draw pixel
	sw $t1, 0x9ac4($t0) # draw pixel
	sw $t1, 0xb710($t0) # draw pixel
	sw $t1, 0xa0cc($t0) # draw pixel
	sw $t1, 0xb588($t0) # draw pixel
	sw $t1, 0xbebc($t0) # draw pixel
	sw $t1, 0xcb14($t0) # draw pixel
	sw $t1, 0x9d2c($t0) # draw pixel
	sw $t1, 0x9a68($t0) # draw pixel
	sw $t1, 0x9ab0($t0) # draw pixel
	sw $t1, 0x9544($t0) # draw pixel
	sw $t1, 0x9db8($t0) # draw pixel
	sw $t1, 0x9710($t0) # draw pixel
	sw $t1, 0xbf08($t0) # draw pixel
	sw $t1, 0xaa48($t0) # draw pixel
	sw $t1, 0xbeb8($t0) # draw pixel
	sw $t1, 0xa25c($t0) # draw pixel
	sw $t1, 0x9ac0($t0) # draw pixel
	sw $t1, 0xc658($t0) # draw pixel
	sw $t1, 0xc334($t0) # draw pixel
	sw $t1, 0xc8d4($t0) # draw pixel
	sw $t1, 0xb994($t0) # draw pixel
	sw $t1, 0x9b1c($t0) # draw pixel
	sw $t1, 0xa654($t0) # draw pixel
	sw $t1, 0xace4($t0) # draw pixel
	sw $t1, 0x9b08($t0) # draw pixel
	sw $t1, 0xb0d8($t0) # draw pixel
	sw $t1, 0xc6c4($t0) # draw pixel
	sw $t1, 0x9674($t0) # draw pixel
	sw $t1, 0xc6b0($t0) # draw pixel
	sw $t1, 0x98d0($t0) # draw pixel
	sw $t1, 0xb134($t0) # draw pixel
	sw $t1, 0xa92c($t0) # draw pixel
	sw $t1, 0xae50($t0) # draw pixel
	sw $t1, 0xbb24($t0) # draw pixel
	sw $t1, 0xbe5c($t0) # draw pixel
	sw $t1, 0x9adc($t0) # draw pixel
	sw $t1, 0x971c($t0) # draw pixel
	sw $t1, 0xc604($t0) # draw pixel
	sw $t1, 0x9cd0($t0) # draw pixel
	sw $t1, 0x99a4($t0) # draw pixel
	sw $t1, 0x960c($t0) # draw pixel
	sw $t1, 0x9954($t0) # draw pixel
	sw $t1, 0xc250($t0) # draw pixel
	sw $t1, 0xbb2c($t0) # draw pixel
	sw $t1, 0x9e5c($t0) # draw pixel
	sw $t1, 0xbd3c($t0) # draw pixel
	sw $t1, 0xc954($t0) # draw pixel
	sw $t1, 0xb9ec($t0) # draw pixel
	sw $t1, 0x972c($t0) # draw pixel
	sw $t1, 0xc734($t0) # draw pixel
	sw $t1, 0x9958($t0) # draw pixel
	sw $t1, 0xb188($t0) # draw pixel
	sw $t1, 0xcb28($t0) # draw pixel
	sw $t1, 0xc710($t0) # draw pixel
	sw $t1, 0xa330($t0) # draw pixel
	sw $t1, 0x9668($t0) # draw pixel
	sw $t1, 0xba4c($t0) # draw pixel
	sw $t1, 0xa6bc($t0) # draw pixel
	sw $t1, 0x98ec($t0) # draw pixel
	sw $t1, 0xbf34($t0) # draw pixel
	sw $t1, 0xc9a4($t0) # draw pixel
	sw $t1, 0xbabc($t0) # draw pixel
	sw $t1, 0xca5c($t0) # draw pixel
	sw $t1, 0x9554($t0) # draw pixel
	sw $t1, 0xca74($t0) # draw pixel
	sw $t1, 0xc1bc($t0) # draw pixel
	sw $t1, 0xae78($t0) # draw pixel
	sw $t1, 0x94e8($t0) # draw pixel
	sw $t1, 0xc330($t0) # draw pixel
	sw $t1, 0xc8d0($t0) # draw pixel
	sw $t1, 0xc554($t0) # draw pixel
	sw $t1, 0xc6b4($t0) # draw pixel
	sw $t1, 0x98dc($t0) # draw pixel
	sw $t1, 0xb248($t0) # draw pixel
	sw $t1, 0xc1fc($t0) # draw pixel
	sw $t1, 0xbccc($t0) # draw pixel
	sw $t1, 0x9604($t0) # draw pixel
	sw $t1, 0xbe70($t0) # draw pixel
	sw $t1, 0xa0d0($t0) # draw pixel
	sw $t1, 0xc30c($t0) # draw pixel
	sw $t1, 0xad48($t0) # draw pixel
	sw $t1, 0x96c4($t0) # draw pixel
	sw $t1, 0x965c($t0) # draw pixel
	sw $t1, 0xb720($t0) # draw pixel
	sw $t1, 0xa130($t0) # draw pixel
	sw $t1, 0xb308($t0) # draw pixel
	sw $t1, 0x9670($t0) # draw pixel
	sw $t1, 0xbb14($t0) # draw pixel
	sw $t1, 0x9a6c($t0) # draw pixel
	sw $t1, 0x9cc8($t0) # draw pixel
	sw $t1, 0xc12c($t0) # draw pixel
	sw $t1, 0xbab8($t0) # draw pixel
	sw $t1, 0xb1b4($t0) # draw pixel
	sw $t1, 0xc144($t0) # draw pixel
	sw $t1, 0xa588($t0) # draw pixel
	sw $t1, 0xaab8($t0) # draw pixel
	sw $t1, 0xaa4c($t0) # draw pixel
	sw $t1, 0xaec8($t0) # draw pixel
	sw $t1, 0x98cc($t0) # draw pixel
	sw $t1, 0xc598($t0) # draw pixel
	sw $t1, 0xc4c8($t0) # draw pixel
	sw $t1, 0x9d90($t0) # draw pixel
	sw $t1, 0x95a8($t0) # draw pixel
	sw $t1, 0xb328($t0) # draw pixel
	sw $t1, 0xc608($t0) # draw pixel
	sw $t1, 0x9ccc($t0) # draw pixel
	sw $t1, 0x9b20($t0) # draw pixel
	sw $t1, 0xb0e4($t0) # draw pixel
	sw $t1, 0xcb0c($t0) # draw pixel
	sw $t1, 0xb5b4($t0) # draw pixel
	sw $t1, 0xa55c($t0) # draw pixel
	sw $t1, 0x9594($t0) # draw pixel
	sw $t1, 0xae48($t0) # draw pixel
	sw $t1, 0x9938($t0) # draw pixel
	sw $t1, 0xa9b4($t0) # draw pixel
	sw $t1, 0x96b4($t0) # draw pixel
	sw $t1, 0xa558($t0) # draw pixel
	sw $t1, 0xc674($t0) # draw pixel
	sw $t1, 0x98e0($t0) # draw pixel
	sw $t1, 0xbdf4($t0) # draw pixel
	sw $t1, 0x9e58($t0) # draw pixel
	sw $t1, 0xbd30($t0) # draw pixel
	sw $t1, 0xc25c($t0) # draw pixel
	sw $t1, 0xa528($t0) # draw pixel
	sw $t1, 0x9b28($t0) # draw pixel
	sw $t1, 0xae18($t0) # draw pixel
	sw $t1, 0xcacc($t0) # draw pixel
	sw $t1, 0x96c8($t0) # draw pixel
	sw $t1, 0xacdc($t0) # draw pixel
	sw $t1, 0xa990($t0) # draw pixel
	sw $t1, 0xad2c($t0) # draw pixel
	sw $t1, 0xc0d0($t0) # draw pixel
	sw $t1, 0x9618($t0) # draw pixel
	sw $t1, 0xcab0($t0) # draw pixel
	sw $t1, 0xbd38($t0) # draw pixel
	sw $t1, 0xba48($t0) # draw pixel
	sw $t1, 0x94fc($t0) # draw pixel
	sw $t1, 0xb67c($t0) # draw pixel
	sw $t1, 0xb610($t0) # draw pixel
	sw $t1, 0xaf14($t0) # draw pixel
	sw $t1, 0x992c($t0) # draw pixel
	sw $t1, 0xbe58($t0) # draw pixel
	sw $t1, 0xc5f8($t0) # draw pixel
	sw $t1, 0x99b4($t0) # draw pixel
	sw $t1, 0x9528($t0) # draw pixel
	sw $t1, 0xad28($t0) # draw pixel
	sw $t1, 0xc18c($t0) # draw pixel
	sw $t1, 0xb724($t0) # draw pixel
	sw $t1, 0xb5bc($t0) # draw pixel
	sw $t1, 0xbd4c($t0) # draw pixel
	sw $t1, 0xa5e8($t0) # draw pixel
	sw $t1, 0xc140($t0) # draw pixel
	sw $t1, 0xbe54($t0) # draw pixel
	sw $t1, 0xc60c($t0) # draw pixel
	sw $t1, 0xb678($t0) # draw pixel
	sw $t1, 0xa12c($t0) # draw pixel
	sw $t1, 0xa2b8($t0) # draw pixel
	sw $t1, 0xc9b4($t0) # draw pixel
	sw $t1, 0xa650($t0) # draw pixel
	sw $t1, 0xb93c($t0) # draw pixel
	sw $t1, 0xc14c($t0) # draw pixel
	sw $t1, 0xbb20($t0) # draw pixel
	sw $t1, 0xa9e8($t0) # draw pixel
	sw $t1, 0xc0cc($t0) # draw pixel
	sw $t1, 0x9998($t0) # draw pixel
	sw $t1, 0x954c($t0) # draw pixel
	sw $t1, 0xc590($t0) # draw pixel
	sw $t1, 0xb654($t0) # draw pixel
	sw $t1, 0xb1e8($t0) # draw pixel
	sw $t1, 0xca60($t0) # draw pixel
	sw $t1, 0xb9e8($t0) # draw pixel
	sw $t1, 0xc0c8($t0) # draw pixel
	sw $t1, 0xaccc($t0) # draw pixel
	sw $t1, 0xa98c($t0) # draw pixel
	sw $t1, 0x9664($t0) # draw pixel
	sw $t1, 0xaeb0($t0) # draw pixel
	sw $t1, 0xbe14($t0) # draw pixel
	sw $t1, 0xb1ec($t0) # draw pixel
	sw $t1, 0xb0d0($t0) # draw pixel
	sw $t1, 0xbab4($t0) # draw pixel
	sw $t1, 0xb158($t0) # draw pixel
	sw $t1, 0xa6b8($t0) # draw pixel
	sw $t1, 0x993c($t0) # draw pixel
	sw $t1, 0xa5f0($t0) # draw pixel
	sw $t1, 0xa994($t0) # draw pixel
	sw $t1, 0x9950($t0) # draw pixel
	sw $t1, 0xbf30($t0) # draw pixel
	sw $t1, 0x99fc($t0) # draw pixel
	sw $t1, 0x94f0($t0) # draw pixel
	sw $t1, 0x9d94($t0) # draw pixel
	sw $t1, 0xca10($t0) # draw pixel
	sw $t1, 0xaf34($t0) # draw pixel
	sw $t1, 0xb4f0($t0) # draw pixel
	sw $t1, 0x9a58($t0) # draw pixel
	sw $t1, 0xc670($t0) # draw pixel
	sw $t1, 0xc278($t0) # draw pixel
	sw $t1, 0xc99c($t0) # draw pixel
	sw $t1, 0x9b30($t0) # draw pixel
	sw $t1, 0xa5ec($t0) # draw pixel
	sw $t1, 0xc548($t0) # draw pixel
	sw $t1, 0xace0($t0) # draw pixel
	sw $t1, 0xacc8($t0) # draw pixel
	sw $t1, 0xb190($t0) # draw pixel
	sw $t1, 0xa128($t0) # draw pixel
	sw $t1, 0xb708($t0) # draw pixel
	sw $t1, 0xcb08($t0) # draw pixel
	sw $t1, 0xa310($t0) # draw pixel
	sw $t1, 0xc714($t0) # draw pixel
	sw $t1, 0x98f8($t0) # draw pixel
	sw $t1, 0xc31c($t0) # draw pixel
	sw $t1, 0xa590($t0) # draw pixel
	sw $t1, 0xa154($t0) # draw pixel
	sw $t1, 0xb538($t0) # draw pixel
	sw $t1, 0xb154($t0) # draw pixel
	sw $t1, 0xb24c($t0) # draw pixel
	sw $t1, 0xa95c($t0) # draw pixel
	sw $t1, 0xaa50($t0) # draw pixel
	sw $t1, 0x9a10($t0) # draw pixel
	sw $t1, 0x970c($t0) # draw pixel
	sw $t1, 0xb314($t0) # draw pixel
	sw $t1, 0xc6b8($t0) # draw pixel
	sw $t1, 0xba70($t0) # draw pixel
	sw $t1, 0xb274($t0) # draw pixel
	sw $t1, 0xba10($t0) # draw pixel
	sw $t1, 0x9b0c($t0) # draw pixel
	sw $t1, 0xc6d0($t0) # draw pixel
	sw $t1, 0x95f8($t0) # draw pixel
	sw $t1, 0xbdb0($t0) # draw pixel
	sw $t1, 0xcabc($t0) # draw pixel
	sw $t1, 0xc314($t0) # draw pixel
	sw $t1, 0xa150($t0) # draw pixel
	sw $t1, 0x94f8($t0) # draw pixel
	sw $t1, 0xc4cc($t0) # draw pixel
	sw $t1, 0xc528($t0) # draw pixel
	sw $t1, 0xad30($t0) # draw pixel
	sw $t1, 0xbdf0($t0) # draw pixel
	sw $t1, 0xab3c($t0) # draw pixel
	sw $t1, 0x9730($t0) # draw pixel
	sw $t1, 0x952c($t0) # draw pixel
	sw $t1, 0xb8c8($t0) # draw pixel
	sw $t1, 0xad4c($t0) # draw pixel
	sw $t1, 0x999c($t0) # draw pixel
	sw $t1, 0x9a70($t0) # draw pixel
	sw $t1, 0xa8d4($t0) # draw pixel
	sw $t1, 0xa33c($t0) # draw pixel
	sw $t1, 0xaf3c($t0) # draw pixel
	sw $t1, 0xb1bc($t0) # draw pixel
	sw $t1, 0x94cc($t0) # draw pixel
	sw $t1, 0x96dc($t0) # draw pixel
	sw $t1, 0xcac0($t0) # draw pixel
	sw $t1, 0xb4c8($t0) # draw pixel
	sw $t1, 0xbe74($t0) # draw pixel
	sw $t1, 0xc67c($t0) # draw pixel
	sw $t1, 0xb72c($t0) # draw pixel
	sw $t1, 0xbcd0($t0) # draw pixel
	sw $t1, 0x9b38($t0) # draw pixel
	sw $t1, 0xa954($t0) # draw pixel
	sw $t1, 0xa2b0($t0) # draw pixel
	sw $t1, 0x9540($t0) # draw pixel
	sw $t1, 0xc708($t0) # draw pixel
	sw $t1, 0xb0ec($t0) # draw pixel
	sw $t1, 0x96d4($t0) # draw pixel
	sw $t1, 0xa254($t0) # draw pixel
	sw $t1, 0xae68($t0) # draw pixel
	sw $t1, 0xc0d4($t0) # draw pixel
	sw $t1, 0xc254($t0) # draw pixel
	sw $t1, 0xaf30($t0) # draw pixel
	sw $t1, 0xca64($t0) # draw pixel
	sw $t1, 0xa6b0($t0) # draw pixel
	sw $t1, 0xc9f8($t0) # draw pixel
	sw $t1, 0xa934($t0) # draw pixel
	sw $t1, 0xb194($t0) # draw pixel
	sw $t1, 0xc618($t0) # draw pixel
	sw $t1, 0x9d28($t0) # draw pixel
	sw $t1, 0xc148($t0) # draw pixel
	sw $t1, 0xb250($t0) # draw pixel
	sw $t1, 0x9f0c($t0) # draw pixel
	sw $t1, 0xace8($t0) # draw pixel
	sw $t1, 0xc190($t0) # draw pixel
	sw $t1, 0xb5ec($t0) # draw pixel
	sw $t1, 0xb618($t0) # draw pixel
	sw $t1, 0x95a4($t0) # draw pixel
	sw $t1, 0x9728($t0) # draw pixel
	sw $t1, 0xb5b8($t0) # draw pixel
	sw $t1, 0x9598($t0) # draw pixel
	sw $t1, 0xb670($t0) # draw pixel
	sw $t1, 0xbd44($t0) # draw pixel
	sw $t1, 0xa9ec($t0) # draw pixel
	sw $t1, 0x9eb4($t0) # draw pixel
	sw $t1, 0xbb28($t0) # draw pixel
	sw $t1, 0xb5f0($t0) # draw pixel
	sw $t1, 0x9df4($t0) # draw pixel
	sw $t1, 0xcac4($t0) # draw pixel
	sw $t1, 0xab08($t0) # draw pixel
	sw $t1, 0xbdfc($t0) # draw pixel
	sw $t1, 0xca08($t0) # draw pixel
	sw $t1, 0xb988($t0) # draw pixel
	sw $t1, 0xb130($t0) # draw pixel
	sw $t1, 0xb9bc($t0) # draw pixel
	sw $t1, 0xba78($t0) # draw pixel
	sw $t1, 0xc13c($t0) # draw pixel
	sw $t1, 0xb9b8($t0) # draw pixel
	sw $t1, 0xb0dc($t0) # draw pixel
	sw $t1, 0xca00($t0) # draw pixel
	sw $t1, 0xc990($t0) # draw pixel
	sw $t1, 0xc5a0($t0) # draw pixel
	sw $t1, 0xc95c($t0) # draw pixel
	sw $t1, 0xb94c($t0) # draw pixel
	sw $t1, 0x9a0c($t0) # draw pixel
	sw $t1, 0xc21c($t0) # draw pixel
	sw $t1, 0x9ab8($t0) # draw pixel
	sw $t1, 0x959c($t0) # draw pixel
	sw $t1, 0xa554($t0) # draw pixel
	sw $t1, 0x9ab4($t0) # draw pixel
	sw $t1, 0xacf0($t0) # draw pixel
	sw $t1, 0xae14($t0) # draw pixel
	sw $t1, 0x99ac($t0) # draw pixel
	sw $t1, 0xb70c($t0) # draw pixel
	sw $t1, 0xb310($t0) # draw pixel
	sw $t1, 0xae1c($t0) # draw pixel
	sw $t1, 0xae54($t0) # draw pixel
	sw $t1, 0xc324($t0) # draw pixel
	sw $t1, 0xa734($t0) # draw pixel
	sw $t1, 0x9734($t0) # draw pixel
	sw $t1, 0xc998($t0) # draw pixel
	sw $t1, 0xa4d4($t0) # draw pixel
	sw $t1, 0xbd54($t0) # draw pixel
	sw $t1, 0x96c0($t0) # draw pixel
	sw $t1, 0xa338($t0) # draw pixel
	sw $t1, 0xcab4($t0) # draw pixel
	sw $t1, 0xc310($t0) # draw pixel
	sw $t1, 0xcab8($t0) # draw pixel
	sw $t1, 0xc9b0($t0) # draw pixel
	sw $t1, 0xadb8($t0) # draw pixel
	sw $t1, 0xb128($t0) # draw pixel
	sw $t1, 0x9934($t0) # draw pixel
	sw $t1, 0xa5b0($t0) # draw pixel
	sw $t1, 0xca70($t0) # draw pixel
	sw $t1, 0x9948($t0) # draw pixel
	sw $t1, 0xbd40($t0) # draw pixel
	sw $t1, 0xc4d0($t0) # draw pixel
	sw $t1, 0x98d8($t0) # draw pixel
	sw $t1, 0xadb0($t0) # draw pixel
	sw $t1, 0xc1f0($t0) # draw pixel
	sw $t1, 0xaecc($t0) # draw pixel
	sw $t1, 0xb0e8($t0) # draw pixel
	sw $t1, 0x9600($t0) # draw pixel
	sw $t1, 0xb27c($t0) # draw pixel
	sw $t1, 0xb6b0($t0) # draw pixel
	sw $t1, 0xb530($t0) # draw pixel
	sw $t1, 0xc928($t0) # draw pixel
	sw $t1, 0xb0f4($t0) # draw pixel
	sw $t1, 0x99b0($t0) # draw pixel
	sw $t1, 0x96d0($t0) # draw pixel
	sw $t1, 0x9d54($t0) # draw pixel
	sw $t1, 0x94d0($t0) # draw pixel
	sw $t1, 0xc5b0($t0) # draw pixel
	sw $t1, 0xbf20($t0) # draw pixel
	sw $t1, 0xa1b4($t0) # draw pixel
	sw $t1, 0xbb1c($t0) # draw pixel
	sw $t1, 0xb544($t0) # draw pixel
	sw $t1, 0xc6dc($t0) # draw pixel
	sw $t1, 0xa52c($t0) # draw pixel
	sw $t1, 0xbd50($t0) # draw pixel
	sw $t1, 0xb928($t0) # draw pixel
	sw $t1, 0xa15c($t0) # draw pixel
	sw $t1, 0xacd8($t0) # draw pixel
	sw $t1, 0x9944($t0) # draw pixel
	sw $t1, 0xbeb0($t0) # draw pixel
	sw $t1, 0xc5a4($t0) # draw pixel
	sw $t1, 0xaec4($t0) # draw pixel
	sw $t1, 0xbd8c($t0) # draw pixel
	sw $t1, 0xc6c8($t0) # draw pixel
	sw $t1, 0xa314($t0) # draw pixel
	sw $t1, 0xb944($t0) # draw pixel
	sw $t1, 0xbd90($t0) # draw pixel
	sw $t1, 0xa2b4($t0) # draw pixel
	sw $t1, 0x9610($t0) # draw pixel
	sw $t1, 0xb6bc($t0) # draw pixel
	sw $t1, 0xbb0c($t0) # draw pixel
	sw $t1, 0x9990($t0) # draw pixel
	sw $t1, 0xaebc($t0) # draw pixel
	sw $t1, 0xa1bc($t0) # draw pixel
	sw $t1, 0xad58($t0) # draw pixel
	sw $t1, 0xba74($t0) # draw pixel
	sw $t1, 0xc530($t0) # draw pixel
	sw $t1, 0xb148($t0) # draw pixel
	sw $t1, 0xba1c($t0) # draw pixel
	sw $t1, 0x94ec($t0) # draw pixel
	sw $t1, 0xb33c($t0) # draw pixel
	sw $t1, 0x9714($t0) # draw pixel
	sw $t1, 0xc1b8($t0) # draw pixel
	sw $t1, 0xaabc($t0) # draw pixel
	sw $t1, 0xbe7c($t0) # draw pixel
	sw $t1, 0xbf28($t0) # draw pixel
	sw $t1, 0xc52c($t0) # draw pixel
	sw $t1, 0x9994($t0) # draw pixel
	sw $t1, 0x9b24($t0) # draw pixel
	sw $t1, 0x9ad4($t0) # draw pixel
	sw $t1, 0xa1b8($t0) # draw pixel
	sw $t1, 0x9eb8($t0) # draw pixel
	sw $t1, 0x9a64($t0) # draw pixel
	sw $t1, 0xb8d0($t0) # draw pixel
	sw $t1, 0x98c8($t0) # draw pixel
	sw $t1, 0x95fc($t0) # draw pixel
	sw $t1, 0xa8cc($t0) # draw pixel
	sw $t1, 0x9a74($t0) # draw pixel
	sw $t1, 0xa9bc($t0) # draw pixel
	sw $t1, 0xb330($t0) # draw pixel
	sw $t1, 0xa9f4($t0) # draw pixel
	sw $t1, 0xadbc($t0) # draw pixel
	sw $t1, 0x9d5c($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x232e4($t0) # draw pixel
	sw $t1, 0x22648($t0) # draw pixel
	sw $t1, 0x23ae0($t0) # draw pixel
	sw $t1, 0x22e30($t0) # draw pixel
	sw $t1, 0x22e20($t0) # draw pixel
	sw $t1, 0x22e70($t0) # draw pixel
	sw $t1, 0x231e4($t0) # draw pixel
	sw $t1, 0x23938($t0) # draw pixel
	sw $t1, 0x23698($t0) # draw pixel
	sw $t1, 0x226e0($t0) # draw pixel
	sw $t1, 0x225e4($t0) # draw pixel
	sw $t1, 0x23ac0($t0) # draw pixel
	sw $t1, 0x22ec4($t0) # draw pixel
	sw $t1, 0x22918($t0) # draw pixel
	sw $t1, 0x232a8($t0) # draw pixel
	sw $t1, 0x23a38($t0) # draw pixel
	sw $t1, 0x23694($t0) # draw pixel
	sw $t1, 0x22644($t0) # draw pixel
	sw $t1, 0x2311c($t0) # draw pixel
	sw $t1, 0x22934($t0) # draw pixel
	sw $t1, 0x22a94($t0) # draw pixel
	sw $t1, 0x22ae4($t0) # draw pixel
	sw $t1, 0x235d4($t0) # draw pixel
	sw $t1, 0x23594($t0) # draw pixel
	sw $t1, 0x22a48($t0) # draw pixel
	sw $t1, 0x22634($t0) # draw pixel
	sw $t1, 0x23a7c($t0) # draw pixel
	sw $t1, 0x22a98($t0) # draw pixel
	sw $t1, 0x2292c($t0) # draw pixel
	sw $t1, 0x239a4($t0) # draw pixel
	sw $t1, 0x23288($t0) # draw pixel
	sw $t1, 0x22a34($t0) # draw pixel
	sw $t1, 0x22168($t0) # draw pixel
	sw $t1, 0x2313c($t0) # draw pixel
	sw $t1, 0x23294($t0) # draw pixel
	sw $t1, 0x23158($t0) # draw pixel
	sw $t1, 0x23620($t0) # draw pixel
	sw $t1, 0x226ac($t0) # draw pixel
	sw $t1, 0x22124($t0) # draw pixel
	sw $t1, 0x2223c($t0) # draw pixel
	sw $t1, 0x236e0($t0) # draw pixel
	sw $t1, 0x23948($t0) # draw pixel
	sw $t1, 0x22670($t0) # draw pixel
	sw $t1, 0x2211c($t0) # draw pixel
	sw $t1, 0x23674($t0) # draw pixel
	sw $t1, 0x23230($t0) # draw pixel
	sw $t1, 0x22d2c($t0) # draw pixel
	sw $t1, 0x2252c($t0) # draw pixel
	sw $t1, 0x23960($t0) # draw pixel
	sw $t1, 0x231d4($t0) # draw pixel
	sw $t1, 0x2294c($t0) # draw pixel
	sw $t1, 0x22d94($t0) # draw pixel
	sw $t1, 0x22e1c($t0) # draw pixel
	sw $t1, 0x225d4($t0) # draw pixel
	sw $t1, 0x2254c($t0) # draw pixel
	sw $t1, 0x23aa4($t0) # draw pixel
	sw $t1, 0x22518($t0) # draw pixel
	sw $t1, 0x22280($t0) # draw pixel
	sw $t1, 0x22e48($t0) # draw pixel
	sw $t1, 0x22548($t0) # draw pixel
	sw $t1, 0x2227c($t0) # draw pixel
	sw $t1, 0x23134($t0) # draw pixel
	sw $t1, 0x23aa0($t0) # draw pixel
	sw $t1, 0x23980($t0) # draw pixel
	sw $t1, 0x236c0($t0) # draw pixel
	sw $t1, 0x231dc($t0) # draw pixel
	sw $t1, 0x23680($t0) # draw pixel
	sw $t1, 0x239e0($t0) # draw pixel
	sw $t1, 0x231a8($t0) # draw pixel
	sw $t1, 0x23538($t0) # draw pixel
	sw $t1, 0x22a20($t0) # draw pixel
	sw $t1, 0x22a44($t0) # draw pixel
	sw $t1, 0x22284($t0) # draw pixel
	sw $t1, 0x239dc($t0) # draw pixel
	sw $t1, 0x22138($t0) # draw pixel
	sw $t1, 0x23544($t0) # draw pixel
	sw $t1, 0x22974($t0) # draw pixel
	sw $t1, 0x23648($t0) # draw pixel
	sw $t1, 0x222d8($t0) # draw pixel
	sw $t1, 0x22dd4($t0) # draw pixel
	sw $t1, 0x22d58($t0) # draw pixel
	sw $t1, 0x22514($t0) # draw pixel
	sw $t1, 0x23944($t0) # draw pixel
	sw $t1, 0x22630($t0) # draw pixel
	sw $t1, 0x22d28($t0) # draw pixel
	sw $t1, 0x23994($t0) # draw pixel
	sw $t1, 0x222cc($t0) # draw pixel
	sw $t1, 0x221a0($t0) # draw pixel
	sw $t1, 0x23978($t0) # draw pixel
	sw $t1, 0x23acc($t0) # draw pixel
	sw $t1, 0x22994($t0) # draw pixel
	sw $t1, 0x229d0($t0) # draw pixel
	sw $t1, 0x22178($t0) # draw pixel
	sw $t1, 0x236c4($t0) # draw pixel
	sw $t1, 0x22224($t0) # draw pixel
	sw $t1, 0x22ec0($t0) # draw pixel
	sw $t1, 0x23958($t0) # draw pixel
	sw $t1, 0x22978($t0) # draw pixel
	sw $t1, 0x22914($t0) # draw pixel
	sw $t1, 0x22a70($t0) # draw pixel
	sw $t1, 0x236ac($t0) # draw pixel
	sw $t1, 0x222a8($t0) # draw pixel
	sw $t1, 0x23988($t0) # draw pixel
	sw $t1, 0x222c8($t0) # draw pixel
	sw $t1, 0x23270($t0) # draw pixel
	sw $t1, 0x23918($t0) # draw pixel
	sw $t1, 0x22274($t0) # draw pixel
	sw $t1, 0x222c4($t0) # draw pixel
	sw $t1, 0x23a88($t0) # draw pixel
	sw $t1, 0x222e8($t0) # draw pixel
	sw $t1, 0x23a9c($t0) # draw pixel
	sw $t1, 0x22684($t0) # draw pixel
	sw $t1, 0x22e44($t0) # draw pixel
	sw $t1, 0x23558($t0) # draw pixel
	sw $t1, 0x231d0($t0) # draw pixel
	sw $t1, 0x2261c($t0) # draw pixel
	sw $t1, 0x22d88($t0) # draw pixel
	sw $t1, 0x2213c($t0) # draw pixel
	sw $t1, 0x22674($t0) # draw pixel
	sw $t1, 0x22114($t0) # draw pixel
	sw $t1, 0x22e84($t0) # draw pixel
	sw $t1, 0x236e4($t0) # draw pixel
	sw $t1, 0x232c4($t0) # draw pixel
	sw $t1, 0x22e74($t0) # draw pixel
	sw $t1, 0x221d4($t0) # draw pixel
	sw $t1, 0x221e0($t0) # draw pixel
	sw $t1, 0x23968($t0) # draw pixel
	sw $t1, 0x22e88($t0) # draw pixel
	sw $t1, 0x226a8($t0) # draw pixel
	sw $t1, 0x22de4($t0) # draw pixel
	sw $t1, 0x22d34($t0) # draw pixel
	sw $t1, 0x22160($t0) # draw pixel
	sw $t1, 0x23a74($t0) # draw pixel
	sw $t1, 0x22ee4($t0) # draw pixel
	sw $t1, 0x23144($t0) # draw pixel
	sw $t1, 0x22d60($t0) # draw pixel
	sw $t1, 0x23634($t0) # draw pixel
	sw $t1, 0x22d80($t0) # draw pixel
	sw $t1, 0x23a34($t0) # draw pixel
	sw $t1, 0x229e8($t0) # draw pixel
	sw $t1, 0x22d18($t0) # draw pixel
	sw $t1, 0x23914($t0) # draw pixel
	sw $t1, 0x23114($t0) # draw pixel
	sw $t1, 0x22120($t0) # draw pixel
	sw $t1, 0x23140($t0) # draw pixel
	sw $t1, 0x22948($t0) # draw pixel
	sw $t1, 0x23a80($t0) # draw pixel
	sw $t1, 0x23138($t0) # draw pixel
	sw $t1, 0x2355c($t0) # draw pixel
	sw $t1, 0x229e4($t0) # draw pixel
	sw $t1, 0x239a0($t0) # draw pixel
	sw $t1, 0x222ac($t0) # draw pixel
	sw $t1, 0x23574($t0) # draw pixel
	sw $t1, 0x23514($t0) # draw pixel
	sw $t1, 0x22218($t0) # draw pixel
	sw $t1, 0x222e0($t0) # draw pixel
	sw $t1, 0x22d5c($t0) # draw pixel
	sw $t1, 0x23588($t0) # draw pixel
	sw $t1, 0x235a4($t0) # draw pixel
	sw $t1, 0x2217c($t0) # draw pixel
	sw $t1, 0x22278($t0) # draw pixel
	sw $t1, 0x22d84($t0) # draw pixel
	sw $t1, 0x23118($t0) # draw pixel
	sw $t1, 0x2295c($t0) # draw pixel
	sw $t1, 0x22e94($t0) # draw pixel
	sw $t1, 0x2216c($t0) # draw pixel
	sw $t1, 0x23a1c($t0) # draw pixel
	sw $t1, 0x231e0($t0) # draw pixel
	sw $t1, 0x22a1c($t0) # draw pixel
	sw $t1, 0x22ee0($t0) # draw pixel
	sw $t1, 0x22584($t0) # draw pixel
	sw $t1, 0x22184($t0) # draw pixel
	sw $t1, 0x236a8($t0) # draw pixel
	sw $t1, 0x23a44($t0) # draw pixel
	sw $t1, 0x232e0($t0) # draw pixel
	sw $t1, 0x23670($t0) # draw pixel
	sw $t1, 0x22198($t0) # draw pixel
	sw $t1, 0x22d14($t0) # draw pixel
	sw $t1, 0x22164($t0) # draw pixel
	sw $t1, 0x22a88($t0) # draw pixel
	sw $t1, 0x22240($t0) # draw pixel
	sw $t1, 0x22228($t0) # draw pixel
	sw $t1, 0x22528($t0) # draw pixel
	sw $t1, 0x22aa8($t0) # draw pixel
	sw $t1, 0x22aac($t0) # draw pixel
	sw $t1, 0x22a84($t0) # draw pixel
	sw $t1, 0x22140($t0) # draw pixel
	sw $t1, 0x22128($t0) # draw pixel
	sw $t1, 0x22d38($t0) # draw pixel
	sw $t1, 0x239e8($t0) # draw pixel
	sw $t1, 0x22698($t0) # draw pixel
	sw $t1, 0x23ae4($t0) # draw pixel
	sw $t1, 0x23934($t0) # draw pixel
	sw $t1, 0x22118($t0) # draw pixel
	sw $t1, 0x22144($t0) # draw pixel
	sw $t1, 0x22220($t0) # draw pixel
	sw $t1, 0x23a98($t0) # draw pixel
	sw $t1, 0x232ac($t0) # draw pixel
	sw $t1, 0x23578($t0) # draw pixel
	sw $t1, 0x23a78($t0) # draw pixel
	sw $t1, 0x222b8($t0) # draw pixel
	sw $t1, 0x2397c($t0) # draw pixel
	sw $t1, 0x225a4($t0) # draw pixel
	sw $t1, 0x222c0($t0) # draw pixel
	sw $t1, 0x22da0($t0) # draw pixel
	sw $t1, 0x22694($t0) # draw pixel
	sw $t1, 0x225d0($t0) # draw pixel
	sw $t1, 0x22244($t0) # draw pixel
	sw $t1, 0x23998($t0) # draw pixel
	sw $t1, 0x235e0($t0) # draw pixel
	sw $t1, 0x23aa8($t0) # draw pixel
	sw $t1, 0x23644($t0) # draw pixel
	sw $t1, 0x23964($t0) # draw pixel
	sw $t1, 0x221dc($t0) # draw pixel
	sw $t1, 0x23984($t0) # draw pixel
	sw $t1, 0x22590($t0) # draw pixel
	sw $t1, 0x2394c($t0) # draw pixel
	sw $t1, 0x22194($t0) # draw pixel
	sw $t1, 0x22538($t0) # draw pixel
	sw $t1, 0x23220($t0) # draw pixel
	sw $t1, 0x22ea8($t0) # draw pixel
	sw $t1, 0x23248($t0) # draw pixel
	sw $t1, 0x226e4($t0) # draw pixel
	sw $t1, 0x22a30($t0) # draw pixel
	sw $t1, 0x22d48($t0) # draw pixel
	sw $t1, 0x229d4($t0) # draw pixel
	sw $t1, 0x22214($t0) # draw pixel
	sw $t1, 0x22e98($t0) # draw pixel
	sw $t1, 0x22558($t0) # draw pixel
	sw $t1, 0x2219c($t0) # draw pixel
	sw $t1, 0x2215c($t0) # draw pixel
	sw $t1, 0x23128($t0) # draw pixel
	sw $t1, 0x23590($t0) # draw pixel
	sw $t1, 0x2395c($t0) # draw pixel
	sw $t1, 0x23120($t0) # draw pixel
	sw $t1, 0x22ac0($t0) # draw pixel
	sw $t1, 0x2221c($t0) # draw pixel
	sw $t1, 0x22180($t0) # draw pixel
	sw $t1, 0x23284($t0) # draw pixel
	sw $t1, 0x22958($t0) # draw pixel
	sw $t1, 0x2399c($t0) # draw pixel
	sw $t1, 0x22de8($t0) # draw pixel
	sw $t1, 0x222bc($t0) # draw pixel
	sw $t1, 0x2321c($t0) # draw pixel
	sw $t1, 0x22a74($t0) # draw pixel
	sw $t1, 0x226c0($t0) # draw pixel
	sw $t1, 0x22620($t0) # draw pixel
	sw $t1, 0x22578($t0) # draw pixel
	sw $t1, 0x22dd0($t0) # draw pixel
	sw $t1, 0x22da4($t0) # draw pixel
	sw $t1, 0x23ac4($t0) # draw pixel
	sw $t1, 0x23188($t0) # draw pixel
	sw $t1, 0x23a40($t0) # draw pixel
	sw $t1, 0x22990($t0) # draw pixel
	sw $t1, 0x23518($t0) # draw pixel
	sw $t1, 0x23548($t0) # draw pixel
	sw $t1, 0x225a0($t0) # draw pixel
	sw $t1, 0x226c4($t0) # draw pixel
	sw $t1, 0x23280($t0) # draw pixel
	sw $t1, 0x22238($t0) # draw pixel
	sw $t1, 0x23274($t0) # draw pixel
	sw $t1, 0x22234($t0) # draw pixel
	sw $t1, 0x23298($t0) # draw pixel
	sw $t1, 0x235e4($t0) # draw pixel
	sw $t1, 0x222ec($t0) # draw pixel
	sw $t1, 0x222e4($t0) # draw pixel
	sw $t1, 0x22534($t0) # draw pixel
	sw $t1, 0x22298($t0) # draw pixel
	sw $t1, 0x23a20($t0) # draw pixel
	sw $t1, 0x221d8($t0) # draw pixel
	sw $t1, 0x23ab8($t0) # draw pixel
	sw $t1, 0x2327c($t0) # draw pixel
	sw $t1, 0x22d68($t0) # draw pixel
	sw $t1, 0x22d44($t0) # draw pixel
	sw $t1, 0x22688($t0) # draw pixel
	sw $t1, 0x23124($t0) # draw pixel
	sw $t1, 0x22ae0($t0) # draw pixel
	sw $t1, 0x23234($t0) # draw pixel
	sw $t1, 0x231e8($t0) # draw pixel
	sw $t1, 0x23244($t0) # draw pixel
	sw $t1, 0x22158($t0) # draw pixel
	sw $t1, 0x235a8($t0) # draw pixel
	sw $t1, 0x235d0($t0) # draw pixel
	sw $t1, 0x239d8($t0) # draw pixel
	sw $t1, 0x2315c($t0) # draw pixel
	sw $t1, 0x23540($t0) # draw pixel
	sw $t1, 0x222dc($t0) # draw pixel
	sw $t1, 0x22d78($t0) # draw pixel
	sw $t1, 0x22d7c($t0) # draw pixel
	sw $t1, 0x22134($t0) # draw pixel
	sw $t1, 0x22e34($t0) # draw pixel
	sw $t1, 0x22928($t0) # draw pixel
	sw $t1, 0x23684($t0) # draw pixel
	sw $t1, 0x2361c($t0) # draw pixel
	sw $t1, 0x22938($t0) # draw pixel
	sw $t1, 0x22d64($t0) # draw pixel
	sw $t1, 0x23ac8($t0) # draw pixel
	sw $t1, 0x232c0($t0) # draw pixel
	sw $t1, 0x22588($t0) # draw pixel
	sw $t1, 0x23534($t0) # draw pixel
	sw $t1, 0x22ac4($t0) # draw pixel
	sw $t1, 0x22148($t0) # draw pixel
	sw $t1, 0x22574($t0) # draw pixel
	sw $t1, 0x22294($t0) # draw pixel
	sw $t1, 0x23abc($t0) # draw pixel
	sw $t1, 0x22d4c($t0) # draw pixel
	sw $t1, 0x22eac($t0) # draw pixel
	sw $t1, 0x231a4($t0) # draw pixel
	sw $t1, 0x22d9c($t0) # draw pixel
	sw $t1, 0x221e4($t0) # draw pixel
	sw $t1, 0x22594($t0) # draw pixel
	sw $t1, 0x225e8($t0) # draw pixel
	sw $t1, 0x2396c($t0) # draw pixel
	sw $t1, 0x22d98($t0) # draw pixel
	sw $t1, 0x23a3c($t0) # draw pixel
	sw $t1, 0x2255c($t0) # draw pixel
	sw $t1, 0x23630($t0) # draw pixel
	sw $t1, 0x239d4($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x15198($t0) # draw pixel
	sw $t1, 0x14dcc($t0) # draw pixel
	sw $t1, 0x15284($t0) # draw pixel
	sw $t1, 0x14614($t0) # draw pixel
	sw $t1, 0x13a24($t0) # draw pixel
	sw $t1, 0x13e2c($t0) # draw pixel
	sw $t1, 0x14668($t0) # draw pixel
	sw $t1, 0x141c4($t0) # draw pixel
	sw $t1, 0x151cc($t0) # draw pixel
	sw $t1, 0x13a7c($t0) # draw pixel
	sw $t1, 0x13e18($t0) # draw pixel
	sw $t1, 0x139dc($t0) # draw pixel
	sw $t1, 0x15228($t0) # draw pixel
	sw $t1, 0x13a1c($t0) # draw pixel
	sw $t1, 0x1521c($t0) # draw pixel
	sw $t1, 0x14e74($t0) # draw pixel
	sw $t1, 0x145e8($t0) # draw pixel
	sw $t1, 0x14db8($t0) # draw pixel
	sw $t1, 0x139e8($t0) # draw pixel
	sw $t1, 0x14d7c($t0) # draw pixel
	sw $t1, 0x151dc($t0) # draw pixel
	sw $t1, 0x14574($t0) # draw pixel
	sw $t1, 0x149a8($t0) # draw pixel
	sw $t1, 0x14674($t0) # draw pixel
	sw $t1, 0x14234($t0) # draw pixel
	sw $t1, 0x145ac($t0) # draw pixel
	sw $t1, 0x145b4($t0) # draw pixel
	sw $t1, 0x13e34($t0) # draw pixel
	sw $t1, 0x14a14($t0) # draw pixel
	sw $t1, 0x14998($t0) # draw pixel
	sw $t1, 0x13e58($t0) # draw pixel
	sw $t1, 0x14228($t0) # draw pixel
	sw $t1, 0x14a78($t0) # draw pixel
	sw $t1, 0x15288($t0) # draw pixel
	sw $t1, 0x141bc($t0) # draw pixel
	sw $t1, 0x14e14($t0) # draw pixel
	sw $t1, 0x14978($t0) # draw pixel
	sw $t1, 0x15264($t0) # draw pixel
	sw $t1, 0x1517c($t0) # draw pixel
	sw $t1, 0x1468c($t0) # draw pixel
	sw $t1, 0x14a40($t0) # draw pixel
	sw $t1, 0x141dc($t0) # draw pixel
	sw $t1, 0x13a60($t0) # draw pixel
	sw $t1, 0x151ec($t0) # draw pixel
	sw $t1, 0x14628($t0) # draw pixel
	sw $t1, 0x14a7c($t0) # draw pixel
	sw $t1, 0x14a80($t0) # draw pixel
	sw $t1, 0x151a8($t0) # draw pixel
	sw $t1, 0x14578($t0) # draw pixel
	sw $t1, 0x14e44($t0) # draw pixel
	sw $t1, 0x141cc($t0) # draw pixel
	sw $t1, 0x13a6c($t0) # draw pixel
	sw $t1, 0x13d98($t0) # draw pixel
	sw $t1, 0x14198($t0) # draw pixel
	sw $t1, 0x14d98($t0) # draw pixel
	sw $t1, 0x14638($t0) # draw pixel
	sw $t1, 0x13a64($t0) # draw pixel
	sw $t1, 0x13980($t0) # draw pixel
	sw $t1, 0x13984($t0) # draw pixel
	sw $t1, 0x141b4($t0) # draw pixel
	sw $t1, 0x1398c($t0) # draw pixel
	sw $t1, 0x14174($t0) # draw pixel
	sw $t1, 0x14a84($t0) # draw pixel
	sw $t1, 0x14a74($t0) # draw pixel
	sw $t1, 0x1463c($t0) # draw pixel
	sw $t1, 0x13db8($t0) # draw pixel
	sw $t1, 0x13a78($t0) # draw pixel
	sw $t1, 0x13dd8($t0) # draw pixel
	sw $t1, 0x1399c($t0) # draw pixel
	sw $t1, 0x14684($t0) # draw pixel
	sw $t1, 0x13d78($t0) # draw pixel
	sw $t1, 0x13dc4($t0) # draw pixel
	sw $t1, 0x14e5c($t0) # draw pixel
	sw $t1, 0x149d8($t0) # draw pixel
	sw $t1, 0x14a5c($t0) # draw pixel
	sw $t1, 0x14278($t0) # draw pixel
	sw $t1, 0x151b4($t0) # draw pixel
	sw $t1, 0x14a18($t0) # draw pixel
	sw $t1, 0x14a28($t0) # draw pixel
	sw $t1, 0x1428c($t0) # draw pixel
	sw $t1, 0x14e84($t0) # draw pixel
	sw $t1, 0x14e58($t0) # draw pixel
	sw $t1, 0x141b8($t0) # draw pixel
	sw $t1, 0x139c8($t0) # draw pixel
	sw $t1, 0x1528c($t0) # draw pixel
	sw $t1, 0x1526c($t0) # draw pixel
	sw $t1, 0x14218($t0) # draw pixel
	sw $t1, 0x14e2c($t0) # draw pixel
	sw $t1, 0x13a88($t0) # draw pixel
	sw $t1, 0x145bc($t0) # draw pixel
	sw $t1, 0x14194($t0) # draw pixel
	sw $t1, 0x15260($t0) # draw pixel
	sw $t1, 0x1422c($t0) # draw pixel
	sw $t1, 0x13a80($t0) # draw pixel
	sw $t1, 0x149c0($t0) # draw pixel
	sw $t1, 0x1465c($t0) # draw pixel
	sw $t1, 0x13a20($t0) # draw pixel
	sw $t1, 0x139a0($t0) # draw pixel
	sw $t1, 0x14e80($t0) # draw pixel
	sw $t1, 0x145b8($t0) # draw pixel
	sw $t1, 0x14e3c($t0) # draw pixel
	sw $t1, 0x14214($t0) # draw pixel
	sw $t1, 0x14d8c($t0) # draw pixel
	sw $t1, 0x15188($t0) # draw pixel
	sw $t1, 0x151e4($t0) # draw pixel
	sw $t1, 0x139e0($t0) # draw pixel
	sw $t1, 0x13e48($t0) # draw pixel
	sw $t1, 0x14988($t0) # draw pixel
	sw $t1, 0x145cc($t0) # draw pixel
	sw $t1, 0x14dac($t0) # draw pixel
	sw $t1, 0x13e38($t0) # draw pixel
	sw $t1, 0x13d9c($t0) # draw pixel
	sw $t1, 0x14da8($t0) # draw pixel
	sw $t1, 0x13da4($t0) # draw pixel
	sw $t1, 0x139cc($t0) # draw pixel
	sw $t1, 0x14a58($t0) # draw pixel
	sw $t1, 0x13a4c($t0) # draw pixel
	sw $t1, 0x15274($t0) # draw pixel
	sw $t1, 0x13a38($t0) # draw pixel
	sw $t1, 0x13a48($t0) # draw pixel
	sw $t1, 0x13a84($t0) # draw pixel
	sw $t1, 0x14db4($t0) # draw pixel
	sw $t1, 0x13a5c($t0) # draw pixel
	sw $t1, 0x14598($t0) # draw pixel
	sw $t1, 0x151b8($t0) # draw pixel
	sw $t1, 0x149c8($t0) # draw pixel
	sw $t1, 0x13a74($t0) # draw pixel
	sw $t1, 0x14dc8($t0) # draw pixel
	sw $t1, 0x145c4($t0) # draw pixel
	sw $t1, 0x13dcc($t0) # draw pixel
	sw $t1, 0x14e18($t0) # draw pixel
	sw $t1, 0x1518c($t0) # draw pixel
	sw $t1, 0x141c0($t0) # draw pixel
	sw $t1, 0x13e14($t0) # draw pixel
	sw $t1, 0x14660($t0) # draw pixel
	sw $t1, 0x1458c($t0) # draw pixel
	sw $t1, 0x13db4($t0) # draw pixel
	sw $t1, 0x1462c($t0) # draw pixel
	sw $t1, 0x14a3c($t0) # draw pixel
	sw $t1, 0x14dd8($t0) # draw pixel
	sw $t1, 0x15224($t0) # draw pixel
	sw $t1, 0x139b4($t0) # draw pixel
	sw $t1, 0x149ac($t0) # draw pixel
	sw $t1, 0x1424c($t0) # draw pixel
	sw $t1, 0x13a58($t0) # draw pixel
	sw $t1, 0x151d8($t0) # draw pixel
	sw $t1, 0x13988($t0) # draw pixel
	sw $t1, 0x13a18($t0) # draw pixel
	sw $t1, 0x145e4($t0) # draw pixel
	sw $t1, 0x14258($t0) # draw pixel
	sw $t1, 0x13a68($t0) # draw pixel
	sw $t1, 0x13e8c($t0) # draw pixel
	sw $t1, 0x15180($t0) # draw pixel
	sw $t1, 0x14e88($t0) # draw pixel
	sw $t1, 0x14974($t0) # draw pixel
	sw $t1, 0x13ddc($t0) # draw pixel
	sw $t1, 0x149cc($t0) # draw pixel
	sw $t1, 0x141a8($t0) # draw pixel
	sw $t1, 0x15268($t0) # draw pixel
	sw $t1, 0x14238($t0) # draw pixel
	sw $t1, 0x14a38($t0) # draw pixel
	sw $t1, 0x15240($t0) # draw pixel
	sw $t1, 0x145a8($t0) # draw pixel
	sw $t1, 0x1425c($t0) # draw pixel
	sw $t1, 0x13e5c($t0) # draw pixel
	sw $t1, 0x139a4($t0) # draw pixel
	sw $t1, 0x14584($t0) # draw pixel
	sw $t1, 0x15194($t0) # draw pixel
	sw $t1, 0x14e28($t0) # draw pixel
	sw $t1, 0x13e4c($t0) # draw pixel
	sw $t1, 0x15184($t0) # draw pixel
	sw $t1, 0x14994($t0) # draw pixel
	sw $t1, 0x149a4($t0) # draw pixel
	sw $t1, 0x149b4($t0) # draw pixel
	sw $t1, 0x139ec($t0) # draw pixel
	sw $t1, 0x14a48($t0) # draw pixel
	sw $t1, 0x15258($t0) # draw pixel
	sw $t1, 0x151e0($t0) # draw pixel
	sw $t1, 0x14678($t0) # draw pixel
	sw $t1, 0x145c0($t0) # draw pixel
	sw $t1, 0x145e0($t0) # draw pixel
	sw $t1, 0x14d88($t0) # draw pixel
	sw $t1, 0x151e8($t0) # draw pixel
	sw $t1, 0x141d8($t0) # draw pixel
	sw $t1, 0x14a44($t0) # draw pixel
	sw $t1, 0x139e4($t0) # draw pixel
	sw $t1, 0x13a28($t0) # draw pixel
	sw $t1, 0x14688($t0) # draw pixel
	sw $t1, 0x149b8($t0) # draw pixel
	sw $t1, 0x14618($t0) # draw pixel
	sw $t1, 0x14274($t0) # draw pixel
	sw $t1, 0x151c8($t0) # draw pixel
	sw $t1, 0x151ac($t0) # draw pixel
	sw $t1, 0x1464c($t0) # draw pixel
	sw $t1, 0x13dbc($t0) # draw pixel
	sw $t1, 0x15218($t0) # draw pixel
	sw $t1, 0x139d8($t0) # draw pixel
	sw $t1, 0x1397c($t0) # draw pixel
	sw $t1, 0x13d7c($t0) # draw pixel
	sw $t1, 0x14648($t0) # draw pixel
	sw $t1, 0x15220($t0) # draw pixel
	sw $t1, 0x14a2c($t0) # draw pixel
	sw $t1, 0x14e78($t0) # draw pixel
	sw $t1, 0x1525c($t0) # draw pixel
	sw $t1, 0x13dc8($t0) # draw pixel
	sw $t1, 0x15278($t0) # draw pixel
	sw $t1, 0x149dc($t0) # draw pixel
	sw $t1, 0x14664($t0) # draw pixel
	sw $t1, 0x14e40($t0) # draw pixel
	sw $t1, 0x14178($t0) # draw pixel
	sw $t1, 0x14ddc($t0) # draw pixel
	sw $t1, 0x13a34($t0) # draw pixel
	sw $t1, 0x14634($t0) # draw pixel
	sw $t1, 0x13e88($t0) # draw pixel
	sw $t1, 0x13e78($t0) # draw pixel
	sw $t1, 0x13da8($t0) # draw pixel
	sw $t1, 0x14288($t0) # draw pixel
	sw $t1, 0x14588($t0) # draw pixel
	sw $t1, 0x149a0($t0) # draw pixel
	sw $t1, 0x141ac($t0) # draw pixel
	sw $t1, 0x14248($t0) # draw pixel
	sw $t1, 0x13e28($t0) # draw pixel
	sw $t1, 0x13e74($t0) # draw pixel
	sw $t1, 0x14d78($t0) # draw pixel
	sw $t1, 0x14594($t0) # draw pixel
	sw $t1, 0x145c8($t0) # draw pixel
	sw $t1, 0x145dc($t0) # draw pixel
	sw $t1, 0x14658($t0) # draw pixel
	sw $t1, 0x1498c($t0) # draw pixel
	sw $t1, 0x14d94($t0) # draw pixel
	sw $t1, 0x1499c($t0) # draw pixel
	sw $t1, 0x145d8($t0) # draw pixel
	sw $t1, 0x14644($t0) # draw pixel
	sw $t1, 0x139b8($t0) # draw pixel
	sw $t1, 0x141c8($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_c:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_cL:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_cR:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_NE:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_NES:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_NESW:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_NSW:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_NW:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	jr $ra

draw_sprite_heart:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	li $t1, 0xffff00 # store colour code for 0xffff00
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0xff00f7 # store colour code for 0xff00f7
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	jr $ra

draw_sprite_log_left:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	li $t1, 0xde684f # store colour code for 0xde684f
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	li $t1, 0x97684f # store colour code for 0x97684f
	sw $t1, 0x2c18($t0) # draw pixel
	jr $ra

draw_sprite_log_mid1:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	li $t1, 0xde684f # store colour code for 0xde684f
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0x97684f # store colour code for 0x97684f
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	jr $ra

draw_sprite_log_mid2:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	li $t1, 0xde684f # store colour code for 0xde684f
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	li $t1, 0x97684f # store colour code for 0x97684f
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	jr $ra

draw_sprite_log_mid3:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	li $t1, 0xde684f # store colour code for 0xde684f
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0x97684f # store colour code for 0x97684f
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	jr $ra

draw_sprite_log_right:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	li $t1, 0xde684f # store colour code for 0xde684f
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0x97684f # store colour code for 0x97684f
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	jr $ra

draw_sprite_safe_bottom1:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x9400f7 # store colour code for 0x9400f7
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0x0000f7 # store colour code for 0x0000f7
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	jr $ra

draw_sprite_safe_bottom2:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x9400f7 # store colour code for 0x9400f7
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0x0000f7 # store colour code for 0x0000f7
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	jr $ra

draw_sprite_safe_top1:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x9400f7 # store colour code for 0x9400f7
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0x0000f7 # store colour code for 0x0000f7
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	jr $ra

draw_sprite_safe_top2:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x9400f7 # store colour code for 0x9400f7
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	li $t1, 0x0000f7 # store colour code for 0x0000f7
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	jr $ra

draw_sprite_turtle_1:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	jr $ra
	
draw_sprite_goal_region:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	li $t1, 0x00def7 # store colour code for 0x00def7
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	jr $ra
	
play_midi_alfonsos_disappointment:
	li $v0, 31
	li $a0, 60
	li $a1, 667
	li $a2, 0
	li $a3, 40
	syscall
	li $v0, 31
	li $a0, 63
	li $a1, 667
	li $a2, 0
	li $a3, 40
	syscall
	li $v0, 31
	li $a0, 67
	li $a1, 667
	li $a2, 0
	li $a3, 40
	syscall
	li $v0, 33
	li $a0, 36
	li $a1, 667
	li $a2, 0
	li $a3, 40
	syscall
	li $v0, 33
	li $a0, 68
	li $a1, 664
	li $a2, 0
	li $a3, 70
	syscall
	li $v0, 31
	li $a0, 60
	li $a1, 667
	li $a2, 0
	li $a3, 90
	syscall
	li $v0, 31
	li $a0, 63
	li $a1, 667
	li $a2, 0
	li $a3, 90
	syscall
	li $v0, 33
	li $a0, 72
	li $a1, 667
	li $a2, 0
	li $a3, 90
	syscall
	li $v0, 33
	li $a0, 67
	li $a1, 671
	li $a2, 0
	li $a3, 82
	syscall
	li $v0, 31
	li $a0, 62
	li $a1, 664
	li $a2, 0
	li $a3, 70
	syscall
	li $v0, 31
	li $a0, 65
	li $a1, 664
	li $a2, 0
	li $a3, 70
	syscall
	li $v0, 33
	li $a0, 36
	li $a1, 664
	li $a2, 0
	li $a3, 70
	syscall
	li $v0, 33
	li $a0, 67
	li $a1, 667
	li $a2, 0
	li $a3, 55
	syscall
	li $v0, 33
	li $a0, 62
	li $a1, 671
	li $a2, 0
	li $a3, 40
	syscall
	li $v0, 33
	li $a0, 67
	li $a1, 223
	li $a2, 0
	li $a3, 80
	syscall
	li $v0, 33
	li $a0, 68
	li $a1, 219
	li $a2, 0
	li $a3, 80
	syscall
	li $v0, 33
	li $a0, 67
	li $a1, 226
	li $a2, 0
	li $a3, 80
	syscall
	li $v0, 31
	li $a0, 36
	li $a1, 82650
	li $a2, 0
	li $a3, 80
	syscall
	li $v0, 31
	li $a0, 60
	li $a1, 82650
	li $a2, 0
	li $a3, 80
	syscall
	jr $ra


