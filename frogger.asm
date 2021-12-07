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
	#write_buffer: .space 262144
	# Frog position, in pixels
	frog_x: .word 128
	frog_y: .word 224
	frog_width: .word 16
	################
	# OBJECTS
	################
	# Turtles
	n_turtle_rows: .word 2
	turtle_x_positions: .word 0, 0
	turtle_y_positions: .word 64, 112
	turtle_speeds: .word -5, -15
	# Logs
	n_log_rows: .word 3
	log_x_positions: .word 128, 6, 0
	log_y_positions: .word 48, 80, 96
	log_speeds: .word 7, 10, 3
	# Cars
	n_car_rows: .word 5
	car_x_positions: .word 0, 64, 128, 128, 0
	car_y_positions: .word 144, 160, 176, 192, 208
	car_speeds: .word -8, 4, -5, 6, 3
	
	# starting x positions of the cars
	car_rows_starting_x: .word 
		0, 128,        # Row 1
		0,             # Row 2
		56, 120, 184,  # Row 3
		0, 64, 128,    # Row 4
		32, 104, 176,  # Row 5
	# number of cars in each row
	car_row_sizes: 2, 1, 3, 3, 3
		
	# width of cars in each row
	car_widths: .word 32, 16, 16, 16, 16
.text
init:
	# Reset screen on first frame
	li $a0, 0
	li $a1, 65792
	li $a2, 0x00000
	jal fill_between
main:
	# Draw water region
	#li $a0, 0
	#li $a1, 33024
	#li $a2, 0x000042
	#jal draw_rect
	# Draw road region
	#li $a0, 36864
	#li $a1, 57600
	#li $a2, 0x000000
	#jal draw_rect
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
	la $t8, turtle_x_positions
	la $t9, turtle_y_positions
	# draw second row of turtles (bottom-most)
	lw $s0, 4($t8)
	lw $s1, 4($t9)
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

	# draw first row of turtles (top-most)
	lw $s0, 0($t8)
	lw $s1, 0($t9)
	# turtles 1
	addi $a0, $s0, 0
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 16
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	# turtles 2
	addi $a0, $s0, 64
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 80
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	# turtles 3
	addi $a0, $s0, 128
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 144
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	# turtles 4
	addi $a0, $s0, 192
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
	addi $a0, $s0, 208
	addi $a1, $s1, 0
	jal draw_sprite_turtle_1
_draw_logs:
	la $t8, log_x_positions
	la $t9, log_y_positions
	# draw first row of logs (top-most)
	lw $s0, 0($t8)
	lw $s1, 0($t9)
	# log 1
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
	# log 1
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
	# log 1
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
	li $a3, 0xff0000 # colour
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
	li $a3, 0xff0000 # colour
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
	li $a3, 0xff0000 # colour
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
	li $a3, 0xff0000 # colour
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
	li $a3, 0xff0000 # colour
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
	li $a3, 0xff0000 # colour
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
	li $a3, 0xff0000 # colour
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
	li $a3, 0xff0000 # colour
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
	li $a3, 0xff0000 # colour
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
	li $a3, 0xff0000 # colour
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
	li $a3, 0xff0000 # colour
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
	li $a3, 0xff0000 # colour
	jal draw_rect
	addi $a0, $s0, 176
	addi $a1, $s1, 0
	jal draw_sprite_car1
_draw_player:
	# draw player
	lw $a0, frog_x
	addi $a0, $a0, -8
	lw $a1, frog_y
	jal draw_sprite_frog
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
	rem $t9, $t9, 255
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
	rem $t9, $t9, 255
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
	rem $t9, $t9, 255
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
	jal check_collisions_car
_flip_buffers:
	# Copy data from write_buffer to $gp

wait:	
	# repeat
	j main
	
move_up:
	lw $t9, frog_y
	addi $t9, $t9, -16
	bge $t9, 24, _move_up_return
	li $t9, 24
_move_up_return:
	sw $t9, frog_y
	jr $ra	

move_down:
	lw $t9, frog_y
	addi $t9, $t9, 16
	ble $t9, 224, _move_down_return
	li $t9, 224
_move_down_return:
	sw $t9, frog_y
	jr $ra
	
move_left:
	lw $t9, frog_x
	addi $t9, $t9, -16
	bge $t9, 0, _move_left_return
	li $t9, 0
_move_left_return:
	sw $t9, frog_x
	jr $ra
	
move_right:
	lw $t9, frog_x
	addi $t9, $t9, 16
	ble $t9, 240, _move_right_return
	li $t9, 240
_move_right_return:
	sw $t9, frog_x
	jr $ra
	
check_collisions_car:
	lw $t2, frog_y
	la $s2, car_x_positions
	la $s3, car_y_positions
	la $s4, car_widths
	
	lw $t0, frog_x # left x coordinate of frog (frog_x1)
	lw $t1, frog_x
	lw $s7, frog_width
	add $t1, $t0, $s5 # right x coordinate of frog (frog_x2)
	
	###################################################################################
	# VARIABLE MAP:
	# frog_x1: 		$t0		(left x-coordinate of frog)
	# frog_x2: 		$t1		(right x-coordinate of frog)
	# frog_y:  		$t2
	# 
	# car_x1:  		$t3		(left x-coordinate of current car)
	# car_x2:  		$t4		(right x-coordinate of current car)
	# car_y:   		$t5
	
	# car_x_positions: 	$s2
	# car_y_positions: 	$s3
	# car_widths: 		$s4
	###################################################################################
        
	# row 1
	lw $t5, 16($s3) # car y
	beq $t2, $t5, _check_cars_row_1  # frog_y == car_y
	j _check_collisions_car_done
_check_cars_row_1:
_car_1_5:
	# car 1,5
	lw $t3, 16($s2) # left x coordinate of car (car_x1)
	add $t3, $t3, 32  # car 1,5 starts at x=32
	rem $t3, $t3, 255
	lw $s7, 16($s4) # car width
	add $t4, $t3, $s7 # right x coordinate of car (car_x2)
	rem $t4, $t4, 255
_car_1_1_left:
	# check left
	bgt $t3, $t0, _car_1_1_right # car_x1 > frog_x1
	bgt $t0, $t4, _car_1_1_right # frog_x1 > car_x2
	# car_x1 <= frog_x1 <= car_x2
	j _has_collision_with_car
_car_1_1_right:
	# check right
	bgt $t3, $t1, _check_collisions_car_done # car_x1 > frog_x2
	bgt $t1, $t4, _check_collisions_car_done # frog_x2 > car_x2
	# car_x1 <= frog_x2 <= car_x2
	j _has_collision_with_car
_has_collision_with_car:
	li $a0, 888 #integer to be printed
	li $v0, 1 #system call code 1: print_int
	syscall
	addi $a0, $0, 0xa #ascii code for LF, if you have any trouble try 0xD for CR.
        addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        syscall
        
	j _check_collisions_car_done
_check_collisions_car_done:
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
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0x9700f7 # store colour code for 0x9700f7
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	li $t1, 0xffff00 # store colour code for 0xffff00
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	jr $ra

draw_sprite_car2:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	jr $ra

draw_sprite_car3:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x3c4c($t0) # draw pixel
	sw $t1, 0x45c($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x868($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0x3448($t0) # draw pixel
	sw $t1, 0x46c($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x3c6c($t0) # draw pixel
	sw $t1, 0x3440($t0) # draw pixel
	sw $t1, 0xc78($t0) # draw pixel
	sw $t1, 0x3854($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x4c($t0) # draw pixel
	sw $t1, 0x3450($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x3c50($t0) # draw pixel
	sw $t1, 0x47c($t0) # draw pixel
	sw $t1, 0x3c7c($t0) # draw pixel
	sw $t1, 0x878($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x844($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x3848($t0) # draw pixel
	sw $t1, 0x3840($t0) # draw pixel
	sw $t1, 0x1878($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x70($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0x460($t0) # draw pixel
	sw $t1, 0x3868($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0xc48($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x3844($t0) # draw pixel
	sw $t1, 0x3468($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x870($t0) # draw pixel
	sw $t1, 0x458($t0) # draw pixel
	sw $t1, 0x3c40($t0) # draw pixel
	sw $t1, 0x247c($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x3864($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x3c58($t0) # draw pixel
	sw $t1, 0x2478($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x385c($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0x58($t0) # draw pixel
	sw $t1, 0x2c7c($t0) # draw pixel
	sw $t1, 0xc54($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x3458($t0) # draw pixel
	sw $t1, 0x1078($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x444($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x448($t0) # draw pixel
	sw $t1, 0x344c($t0) # draw pixel
	sw $t1, 0x345c($t0) # draw pixel
	sw $t1, 0x464($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x44c($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x305c($t0) # draw pixel
	sw $t1, 0x307c($t0) # draw pixel
	sw $t1, 0x44($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x60($t0) # draw pixel
	sw $t1, 0x187c($t0) # draw pixel
	sw $t1, 0x3064($t0) # draw pixel
	sw $t1, 0x3860($t0) # draw pixel
	sw $t1, 0x848($t0) # draw pixel
	sw $t1, 0x854($t0) # draw pixel
	sw $t1, 0x470($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x440($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x3040($t0) # draw pixel
	sw $t1, 0x304c($t0) # draw pixel
	sw $t1, 0x3060($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x3c64($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x3464($t0) # draw pixel
	sw $t1, 0xc60($t0) # draw pixel
	sw $t1, 0xc44($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0xc58($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x287c($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x468($t0) # draw pixel
	sw $t1, 0x384c($t0) # draw pixel
	sw $t1, 0x107c($t0) # draw pixel
	sw $t1, 0x3c68($t0) # draw pixel
	sw $t1, 0x78($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0xc4c($t0) # draw pixel
	sw $t1, 0x3850($t0) # draw pixel
	sw $t1, 0x347c($t0) # draw pixel
	sw $t1, 0x3044($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0x3478($t0) # draw pixel
	sw $t1, 0x3474($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x68($t0) # draw pixel
	sw $t1, 0x85c($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x3c44($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x3078($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x858($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x50($t0) # draw pixel
	sw $t1, 0x3454($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x3470($t0) # draw pixel
	sw $t1, 0x147c($t0) # draw pixel
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x386c($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x3460($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0xc5c($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3050($t0) # draw pixel
	sw $t1, 0x454($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0xc74($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x48($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0xc40($t0) # draw pixel
	sw $t1, 0x3048($t0) # draw pixel
	sw $t1, 0x3878($t0) # draw pixel
	sw $t1, 0x346c($t0) # draw pixel
	sw $t1, 0x860($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x64($t0) # draw pixel
	sw $t1, 0x40($t0) # draw pixel
	sw $t1, 0x864($t0) # draw pixel
	sw $t1, 0x450($t0) # draw pixel
	sw $t1, 0xc7c($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x3c5c($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x850($t0) # draw pixel
	sw $t1, 0x478($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0x840($t0) # draw pixel
	sw $t1, 0x3c54($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0x3c60($t0) # draw pixel
	sw $t1, 0x74($t0) # draw pixel
	sw $t1, 0x3874($t0) # draw pixel
	sw $t1, 0x3074($t0) # draw pixel
	sw $t1, 0x7c($t0) # draw pixel
	sw $t1, 0x3054($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x387c($t0) # draw pixel
	sw $t1, 0x3c48($t0) # draw pixel
	sw $t1, 0x3058($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0x86c($t0) # draw pixel
	sw $t1, 0x874($t0) # draw pixel
	sw $t1, 0x3858($t0) # draw pixel
	sw $t1, 0x2878($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0x2078($t0) # draw pixel
	sw $t1, 0x3c74($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x3444($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x3870($t0) # draw pixel
	sw $t1, 0x54($t0) # draw pixel
	sw $t1, 0x474($t0) # draw pixel
	sw $t1, 0x87c($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0xc64($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x2c78($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0xc50($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x84c($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x1c78($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x1c7c($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x5c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x6c($t0) # draw pixel
	sw $t1, 0x3c78($t0) # draw pixel
	sw $t1, 0x207c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x1478($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x3c70($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x2874($t0) # draw pixel
	sw $t1, 0x1050($t0) # draw pixel
	sw $t1, 0x1c70($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	sw $t1, 0x2858($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x2058($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x2458($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1060($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x1444($t0) # draw pixel
	sw $t1, 0x1040($t0) # draw pixel
	sw $t1, 0x2074($t0) # draw pixel
	sw $t1, 0x1068($t0) # draw pixel
	sw $t1, 0x1468($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x1454($t0) # draw pixel
	sw $t1, 0x2464($t0) # draw pixel
	sw $t1, 0x2c44($t0) # draw pixel
	sw $t1, 0x2050($t0) # draw pixel
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x1c60($t0) # draw pixel
	sw $t1, 0x1064($t0) # draw pixel
	sw $t1, 0x1044($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x2854($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x2868($t0) # draw pixel
	sw $t1, 0x1c48($t0) # draw pixel
	sw $t1, 0x1058($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x2c64($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x2468($t0) # draw pixel
	sw $t1, 0x1858($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1c64($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x2450($t0) # draw pixel
	sw $t1, 0x2c40($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x2848($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x2840($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0x2c48($t0) # draw pixel
	sw $t1, 0x145c($t0) # draw pixel
	sw $t1, 0x2850($t0) # draw pixel
	sw $t1, 0x2860($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x1848($t0) # draw pixel
	sw $t1, 0x144c($t0) # draw pixel
	sw $t1, 0x205c($t0) # draw pixel
	sw $t1, 0x1864($t0) # draw pixel
	sw $t1, 0x1440($t0) # draw pixel
	sw $t1, 0x1c54($t0) # draw pixel
	sw $t1, 0x2060($t0) # draw pixel
	sw $t1, 0x2044($t0) # draw pixel
	sw $t1, 0x2460($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x2470($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x1460($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x2c74($t0) # draw pixel
	sw $t1, 0x1450($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x2c5c($t0) # draw pixel
	sw $t1, 0x2448($t0) # draw pixel
	sw $t1, 0x1854($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x2444($t0) # draw pixel
	sw $t1, 0x106c($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x1c40($t0) # draw pixel
	sw $t1, 0x2c4c($t0) # draw pixel
	sw $t1, 0x2c58($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x1868($t0) # draw pixel
	sw $t1, 0x246c($t0) # draw pixel
	sw $t1, 0x105c($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x2c6c($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x1074($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x186c($t0) # draw pixel
	sw $t1, 0x1850($t0) # draw pixel
	sw $t1, 0x1c5c($t0) # draw pixel
	sw $t1, 0x2454($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x1470($t0) # draw pixel
	sw $t1, 0x1c4c($t0) # draw pixel
	sw $t1, 0x185c($t0) # draw pixel
	sw $t1, 0x2c60($t0) # draw pixel
	sw $t1, 0x1048($t0) # draw pixel
	sw $t1, 0x2864($t0) # draw pixel
	sw $t1, 0x2040($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x2070($t0) # draw pixel
	sw $t1, 0x2048($t0) # draw pixel
	sw $t1, 0x2c70($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x1874($t0) # draw pixel
	sw $t1, 0x1054($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x2c54($t0) # draw pixel
	sw $t1, 0x1840($t0) # draw pixel
	sw $t1, 0x2474($t0) # draw pixel
	sw $t1, 0x184c($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x1458($t0) # draw pixel
	sw $t1, 0x1c6c($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x286c($t0) # draw pixel
	sw $t1, 0x2c68($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x2440($t0) # draw pixel
	sw $t1, 0x1474($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x285c($t0) # draw pixel
	sw $t1, 0x146c($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2c50($t0) # draw pixel
	sw $t1, 0x245c($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1c50($t0) # draw pixel
	sw $t1, 0x104c($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x2064($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x1070($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x1448($t0) # draw pixel
	sw $t1, 0x244c($t0) # draw pixel
	sw $t1, 0x1c44($t0) # draw pixel
	sw $t1, 0x2870($t0) # draw pixel
	sw $t1, 0x2054($t0) # draw pixel
	sw $t1, 0x1c58($t0) # draw pixel
	sw $t1, 0x1c68($t0) # draw pixel
	sw $t1, 0x1844($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x2068($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1860($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x206c($t0) # draw pixel
	sw $t1, 0x284c($t0) # draw pixel
	sw $t1, 0x1870($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x1c74($t0) # draw pixel
	sw $t1, 0x1464($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x204c($t0) # draw pixel
	sw $t1, 0x2844($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x306c($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0xc68($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc70($t0) # draw pixel
	sw $t1, 0x3070($t0) # draw pixel
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0x3068($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0xc6c($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	jr $ra

draw_sprite_car4:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0x00def7 # store colour code for 0x00def7
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	li $t1, 0xff47f7 # store colour code for 0xff47f7
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	li $t1, 0x97ff00 # store colour code for 0x97ff00
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	jr $ra

draw_sprite_car5:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	jr $ra

draw_sprite_frog:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x59e640 # store colour code for 0x59e640
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0xc40($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x2444($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0xc44($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x2440($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	li $t1, 0xff20f8 # store colour code for 0xff20f8
	sw $t1, 0xc20($t0) # draw pixel
	li $t1, 0xffff20 # store colour code for 0xffff20
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	li $t1, 0xffff00 # store colour code for 0xffff00
	sw $t1, 0x102c($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	li $t1, 0xff00f7 # store colour code for 0xff00f7
	sw $t1, 0xc34($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_c:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_cL:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_cR:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_NE:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_NES:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_NESW:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_NSW:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	jr $ra

draw_sprite_goal_tile_NW:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0xff4700 # store colour code for 0xff4700
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	jr $ra

draw_sprite_log_left:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0xde684f # store colour code for 0xde684f
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	li $t1, 0x97684f # store colour code for 0x97684f
	sw $t1, 0x2c18($t0) # draw pixel
	jr $ra

draw_sprite_log_mid1:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0xde684f # store colour code for 0xde684f
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	li $t1, 0x97684f # store colour code for 0x97684f
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	jr $ra

draw_sprite_log_mid2:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0xde684f # store colour code for 0xde684f
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	li $t1, 0x97684f # store colour code for 0x97684f
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	jr $ra

draw_sprite_log_mid3:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0xde684f # store colour code for 0xde684f
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	li $t1, 0x97684f # store colour code for 0x97684f
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	jr $ra

draw_sprite_log_right:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0xde684f # store colour code for 0xde684f
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	li $t1, 0x97684f # store colour code for 0x97684f
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x102c($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	jr $ra

draw_sprite_safe_bottom1:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x9400f7 # store colour code for 0x9400f7
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	li $t1, 0x0000f7 # store colour code for 0x0000f7
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	jr $ra

draw_sprite_safe_bottom2:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x9400f7 # store colour code for 0x9400f7
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0x0000f7 # store colour code for 0x0000f7
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	jr $ra

draw_sprite_safe_top1:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x9400f7 # store colour code for 0x9400f7
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0x0000f7 # store colour code for 0x0000f7
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	jr $ra

draw_sprite_safe_top2:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x9400f7 # store colour code for 0x9400f7
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0x0000f7 # store colour code for 0x0000f7
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	jr $ra

draw_sprite_turtle_1:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	add $t0, $t0, 0x10008000
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x800($t0) # draw pixel
	sw $t1, 0x3c1c($t0) # draw pixel
	sw $t1, 0x428($t0) # draw pixel
	sw $t1, 0x1838($t0) # draw pixel
	sw $t1, 0x808($t0) # draw pixel
	sw $t1, 0x34($t0) # draw pixel
	sw $t1, 0xc18($t0) # draw pixel
	sw $t1, 0x420($t0) # draw pixel
	sw $t1, 0x1c30($t0) # draw pixel
	sw $t1, 0x283c($t0) # draw pixel
	sw $t1, 0x410($t0) # draw pixel
	sw $t1, 0x3438($t0) # draw pixel
	sw $t1, 0x10($t0) # draw pixel
	sw $t1, 0x2c30($t0) # draw pixel
	sw $t1, 0x1400($t0) # draw pixel
	sw $t1, 0x2c34($t0) # draw pixel
	sw $t1, 0x3404($t0) # draw pixel
	sw $t1, 0xc10($t0) # draw pixel
	sw $t1, 0x414($t0) # draw pixel
	sw $t1, 0x424($t0) # draw pixel
	sw $t1, 0x3c18($t0) # draw pixel
	sw $t1, 0x42c($t0) # draw pixel
	sw $t1, 0x1800($t0) # draw pixel
	sw $t1, 0x2800($t0) # draw pixel
	sw $t1, 0x3c24($t0) # draw pixel
	sw $t1, 0x300c($t0) # draw pixel
	sw $t1, 0x3830($t0) # draw pixel
	sw $t1, 0x2808($t0) # draw pixel
	sw $t1, 0xc3c($t0) # draw pixel
	sw $t1, 0x2c3c($t0) # draw pixel
	sw $t1, 0x341c($t0) # draw pixel
	sw $t1, 0x404($t0) # draw pixel
	sw $t1, 0x400($t0) # draw pixel
	sw $t1, 0x2400($t0) # draw pixel
	sw $t1, 0x2434($t0) # draw pixel
	sw $t1, 0x303c($t0) # draw pixel
	sw $t1, 0x2834($t0) # draw pixel
	sw $t1, 0x1c3c($t0) # draw pixel
	sw $t1, 0x101c($t0) # draw pixel
	sw $t1, 0x83c($t0) # draw pixel
	sw $t1, 0x2c00($t0) # draw pixel
	sw $t1, 0x824($t0) # draw pixel
	sw $t1, 0x280c($t0) # draw pixel
	sw $t1, 0x382c($t0) # draw pixel
	sw $t1, 0x3434($t0) # draw pixel
	sw $t1, 0x3810($t0) # draw pixel
	sw $t1, 0x2c38($t0) # draw pixel
	sw $t1, 0x3000($t0) # draw pixel
	sw $t1, 0x0($t0) # draw pixel
	sw $t1, 0x203c($t0) # draw pixel
	sw $t1, 0x343c($t0) # draw pixel
	sw $t1, 0x3c3c($t0) # draw pixel
	sw $t1, 0x418($t0) # draw pixel
	sw $t1, 0x1004($t0) # draw pixel
	sw $t1, 0x3800($t0) # draw pixel
	sw $t1, 0x30($t0) # draw pixel
	sw $t1, 0x4($t0) # draw pixel
	sw $t1, 0xc34($t0) # draw pixel
	sw $t1, 0xc00($t0) # draw pixel
	sw $t1, 0x80c($t0) # draw pixel
	sw $t1, 0x830($t0) # draw pixel
	sw $t1, 0x1008($t0) # draw pixel
	sw $t1, 0x3c2c($t0) # draw pixel
	sw $t1, 0x2c08($t0) # draw pixel
	sw $t1, 0x243c($t0) # draw pixel
	sw $t1, 0x103c($t0) # draw pixel
	sw $t1, 0x3824($t0) # draw pixel
	sw $t1, 0x41c($t0) # draw pixel
	sw $t1, 0xc28($t0) # draw pixel
	sw $t1, 0x3814($t0) # draw pixel
	sw $t1, 0x818($t0) # draw pixel
	sw $t1, 0x43c($t0) # draw pixel
	sw $t1, 0x380c($t0) # draw pixel
	sw $t1, 0x3408($t0) # draw pixel
	sw $t1, 0x340c($t0) # draw pixel
	sw $t1, 0x1020($t0) # draw pixel
	sw $t1, 0x3818($t0) # draw pixel
	sw $t1, 0x2430($t0) # draw pixel
	sw $t1, 0x408($t0) # draw pixel
	sw $t1, 0x1c38($t0) # draw pixel
	sw $t1, 0x1034($t0) # draw pixel
	sw $t1, 0xc20($t0) # draw pixel
	sw $t1, 0x3428($t0) # draw pixel
	sw $t1, 0x28($t0) # draw pixel
	sw $t1, 0x1438($t0) # draw pixel
	sw $t1, 0x142c($t0) # draw pixel
	sw $t1, 0x3008($t0) # draw pixel
	sw $t1, 0x301c($t0) # draw pixel
	sw $t1, 0x2038($t0) # draw pixel
	sw $t1, 0x40c($t0) # draw pixel
	sw $t1, 0x180c($t0) # draw pixel
	sw $t1, 0x1024($t0) # draw pixel
	sw $t1, 0x1830($t0) # draw pixel
	sw $t1, 0xc($t0) # draw pixel
	sw $t1, 0x3c0c($t0) # draw pixel
	sw $t1, 0x3c30($t0) # draw pixel
	sw $t1, 0x3c14($t0) # draw pixel
	sw $t1, 0x381c($t0) # draw pixel
	sw $t1, 0x430($t0) # draw pixel
	sw $t1, 0x1804($t0) # draw pixel
	sw $t1, 0xc24($t0) # draw pixel
	sw $t1, 0x3024($t0) # draw pixel
	sw $t1, 0x1c($t0) # draw pixel
	sw $t1, 0x1038($t0) # draw pixel
	sw $t1, 0x3430($t0) # draw pixel
	sw $t1, 0x438($t0) # draw pixel
	sw $t1, 0x3c08($t0) # draw pixel
	sw $t1, 0x3420($t0) # draw pixel
	sw $t1, 0x82c($t0) # draw pixel
	sw $t1, 0x8($t0) # draw pixel
	sw $t1, 0x18($t0) # draw pixel
	sw $t1, 0x1c34($t0) # draw pixel
	sw $t1, 0x100c($t0) # draw pixel
	sw $t1, 0x3c04($t0) # draw pixel
	sw $t1, 0x3828($t0) # draw pixel
	sw $t1, 0x3834($t0) # draw pixel
	sw $t1, 0x1000($t0) # draw pixel
	sw $t1, 0x3038($t0) # draw pixel
	sw $t1, 0x182c($t0) # draw pixel
	sw $t1, 0x2c2c($t0) # draw pixel
	sw $t1, 0x3034($t0) # draw pixel
	sw $t1, 0x20($t0) # draw pixel
	sw $t1, 0x1808($t0) # draw pixel
	sw $t1, 0x3c34($t0) # draw pixel
	sw $t1, 0x828($t0) # draw pixel
	sw $t1, 0x3004($t0) # draw pixel
	sw $t1, 0x2c04($t0) # draw pixel
	sw $t1, 0x814($t0) # draw pixel
	sw $t1, 0x3424($t0) # draw pixel
	sw $t1, 0x2838($t0) # draw pixel
	sw $t1, 0x3c20($t0) # draw pixel
	sw $t1, 0x1434($t0) # draw pixel
	sw $t1, 0x1834($t0) # draw pixel
	sw $t1, 0x3400($t0) # draw pixel
	sw $t1, 0x2830($t0) # draw pixel
	sw $t1, 0x183c($t0) # draw pixel
	sw $t1, 0xc08($t0) # draw pixel
	sw $t1, 0x810($t0) # draw pixel
	sw $t1, 0x2804($t0) # draw pixel
	sw $t1, 0x38($t0) # draw pixel
	sw $t1, 0x143c($t0) # draw pixel
	sw $t1, 0x3418($t0) # draw pixel
	sw $t1, 0x24($t0) # draw pixel
	sw $t1, 0xc30($t0) # draw pixel
	sw $t1, 0xc04($t0) # draw pixel
	sw $t1, 0x3410($t0) # draw pixel
	sw $t1, 0x140c($t0) # draw pixel
	sw $t1, 0xc38($t0) # draw pixel
	sw $t1, 0x3808($t0) # draw pixel
	sw $t1, 0xc0c($t0) # draw pixel
	sw $t1, 0x834($t0) # draw pixel
	sw $t1, 0x820($t0) # draw pixel
	sw $t1, 0x3c38($t0) # draw pixel
	sw $t1, 0x3c10($t0) # draw pixel
	sw $t1, 0x3820($t0) # draw pixel
	sw $t1, 0x3c00($t0) # draw pixel
	sw $t1, 0x282c($t0) # draw pixel
	sw $t1, 0x14($t0) # draw pixel
	sw $t1, 0x2c($t0) # draw pixel
	sw $t1, 0x3804($t0) # draw pixel
	sw $t1, 0xc1c($t0) # draw pixel
	sw $t1, 0x1c00($t0) # draw pixel
	sw $t1, 0x383c($t0) # draw pixel
	sw $t1, 0x3c28($t0) # draw pixel
	sw $t1, 0x3c($t0) # draw pixel
	sw $t1, 0x804($t0) # draw pixel
	sw $t1, 0x838($t0) # draw pixel
	sw $t1, 0x2c0c($t0) # draw pixel
	sw $t1, 0x1408($t0) # draw pixel
	sw $t1, 0x434($t0) # draw pixel
	sw $t1, 0x3838($t0) # draw pixel
	sw $t1, 0x1430($t0) # draw pixel
	sw $t1, 0x1404($t0) # draw pixel
	sw $t1, 0x3020($t0) # draw pixel
	sw $t1, 0x81c($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x2438($t0) # draw pixel
	sw $t1, 0x1c08($t0) # draw pixel
	sw $t1, 0x2004($t0) # draw pixel
	sw $t1, 0x2000($t0) # draw pixel
	sw $t1, 0x1014($t0) # draw pixel
	sw $t1, 0x2408($t0) # draw pixel
	sw $t1, 0x3028($t0) # draw pixel
	sw $t1, 0x1410($t0) # draw pixel
	sw $t1, 0x2034($t0) # draw pixel
	sw $t1, 0x2c10($t0) # draw pixel
	sw $t1, 0x3014($t0) # draw pixel
	sw $t1, 0x1028($t0) # draw pixel
	sw $t1, 0x1010($t0) # draw pixel
	sw $t1, 0x1428($t0) # draw pixel
	sw $t1, 0x2c28($t0) # draw pixel
	sw $t1, 0x2008($t0) # draw pixel
	sw $t1, 0x3010($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x1030($t0) # draw pixel
	sw $t1, 0x2814($t0) # draw pixel
	sw $t1, 0x2404($t0) # draw pixel
	sw $t1, 0x3030($t0) # draw pixel
	sw $t1, 0xc2c($t0) # draw pixel
	sw $t1, 0x102c($t0) # draw pixel
	sw $t1, 0x342c($t0) # draw pixel
	sw $t1, 0x2824($t0) # draw pixel
	sw $t1, 0x1c04($t0) # draw pixel
	sw $t1, 0x2c1c($t0) # draw pixel
	sw $t1, 0x1018($t0) # draw pixel
	sw $t1, 0x2c20($t0) # draw pixel
	sw $t1, 0x2c18($t0) # draw pixel
	sw $t1, 0x2428($t0) # draw pixel
	sw $t1, 0x3018($t0) # draw pixel
	sw $t1, 0xc14($t0) # draw pixel
	sw $t1, 0x3414($t0) # draw pixel
	sw $t1, 0x302c($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x1c24($t0) # draw pixel
	sw $t1, 0x1c10($t0) # draw pixel
	sw $t1, 0x2014($t0) # draw pixel
	sw $t1, 0x2820($t0) # draw pixel
	sw $t1, 0x1810($t0) # draw pixel
	sw $t1, 0x2020($t0) # draw pixel
	sw $t1, 0x2028($t0) # draw pixel
	sw $t1, 0x2410($t0) # draw pixel
	sw $t1, 0x1814($t0) # draw pixel
	sw $t1, 0x1818($t0) # draw pixel
	sw $t1, 0x1414($t0) # draw pixel
	sw $t1, 0x141c($t0) # draw pixel
	sw $t1, 0x2418($t0) # draw pixel
	sw $t1, 0x1c28($t0) # draw pixel
	sw $t1, 0x200c($t0) # draw pixel
	sw $t1, 0x240c($t0) # draw pixel
	sw $t1, 0x2818($t0) # draw pixel
	sw $t1, 0x201c($t0) # draw pixel
	sw $t1, 0x1820($t0) # draw pixel
	sw $t1, 0x1824($t0) # draw pixel
	sw $t1, 0x2c24($t0) # draw pixel
	sw $t1, 0x1c2c($t0) # draw pixel
	sw $t1, 0x2420($t0) # draw pixel
	sw $t1, 0x1420($t0) # draw pixel
	sw $t1, 0x1c18($t0) # draw pixel
	sw $t1, 0x2018($t0) # draw pixel
	sw $t1, 0x1c0c($t0) # draw pixel
	sw $t1, 0x2010($t0) # draw pixel
	sw $t1, 0x2024($t0) # draw pixel
	sw $t1, 0x2828($t0) # draw pixel
	sw $t1, 0x242c($t0) # draw pixel
	sw $t1, 0x1418($t0) # draw pixel
	sw $t1, 0x202c($t0) # draw pixel
	sw $t1, 0x2424($t0) # draw pixel
	sw $t1, 0x1424($t0) # draw pixel
	sw $t1, 0x2414($t0) # draw pixel
	sw $t1, 0x1c14($t0) # draw pixel
	sw $t1, 0x281c($t0) # draw pixel
	sw $t1, 0x2c14($t0) # draw pixel
	sw $t1, 0x241c($t0) # draw pixel
	sw $t1, 0x181c($t0) # draw pixel
	sw $t1, 0x2030($t0) # draw pixel
	sw $t1, 0x1828($t0) # draw pixel
	sw $t1, 0x1c20($t0) # draw pixel
	sw $t1, 0x1c1c($t0) # draw pixel
	sw $t1, 0x2810($t0) # draw pixel
	jr $ra

