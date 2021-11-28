draw_sprite_safe_top2:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	li $t1, 0x9400f7 # store colour code for 0x9400f7
	sw $t1, 0x10009000($t0) # draw pixel
	sw $t1, 0x10009408($t0) # draw pixel
	sw $t1, 0x10008408($t0) # draw pixel
	sw $t1, 0x10009410($t0) # draw pixel
	sw $t1, 0x10008808($t0) # draw pixel
	sw $t1, 0x10009404($t0) # draw pixel
	sw $t1, 0x10009c10($t0) # draw pixel
	sw $t1, 0x10009418($t0) # draw pixel
	sw $t1, 0x10009808($t0) # draw pixel
	sw $t1, 0x10009c08($t0) # draw pixel
	sw $t1, 0x10008410($t0) # draw pixel
	sw $t1, 0x1000841c($t0) # draw pixel
	sw $t1, 0x1000980c($t0) # draw pixel
	sw $t1, 0x10008800($t0) # draw pixel
	sw $t1, 0x1000881c($t0) # draw pixel
	sw $t1, 0x10009c14($t0) # draw pixel
	sw $t1, 0x1000940c($t0) # draw pixel
	sw $t1, 0x10009804($t0) # draw pixel
	sw $t1, 0x10009400($t0) # draw pixel
	sw $t1, 0x10009008($t0) # draw pixel
	sw $t1, 0x1000900c($t0) # draw pixel
	sw $t1, 0x10009800($t0) # draw pixel
	sw $t1, 0x10009c0c($t0) # draw pixel
	sw $t1, 0x10008414($t0) # draw pixel
	sw $t1, 0x10009810($t0) # draw pixel
	sw $t1, 0x10009414($t0) # draw pixel
	sw $t1, 0x10008400($t0) # draw pixel
	sw $t1, 0x10009010($t0) # draw pixel
	sw $t1, 0x10009818($t0) # draw pixel
	sw $t1, 0x10008c0c($t0) # draw pixel
	sw $t1, 0x10009c00($t0) # draw pixel
	sw $t1, 0x1000941c($t0) # draw pixel
	sw $t1, 0x10009014($t0) # draw pixel
	sw $t1, 0x10008418($t0) # draw pixel
	sw $t1, 0x1000880c($t0) # draw pixel
	sw $t1, 0x10009c04($t0) # draw pixel
	sw $t1, 0x10008c10($t0) # draw pixel
	sw $t1, 0x10009814($t0) # draw pixel
	sw $t1, 0x10008404($t0) # draw pixel
	sw $t1, 0x1000840c($t0) # draw pixel
	sw $t1, 0x10008810($t0) # draw pixel
	sw $t1, 0x10008014($t0) # draw pixel
	sw $t1, 0x10008814($t0) # draw pixel
	sw $t1, 0x10008000($t0) # draw pixel
	sw $t1, 0x1000901c($t0) # draw pixel
	li $t1, 0x0000f7 # store colour code for 0x0000f7
	sw $t1, 0x10008c14($t0) # draw pixel
	sw $t1, 0x10008818($t0) # draw pixel
	sw $t1, 0x10008c08($t0) # draw pixel
	sw $t1, 0x10008804($t0) # draw pixel
	sw $t1, 0x10009018($t0) # draw pixel
	sw $t1, 0x1000981c($t0) # draw pixel
	sw $t1, 0x10009004($t0) # draw pixel
	sw $t1, 0x10009c18($t0) # draw pixel
	sw $t1, 0x10008c00($t0) # draw pixel
	sw $t1, 0x10008c1c($t0) # draw pixel
	li $t1, 0x000000 # store colour code for 0x000000
	sw $t1, 0x10008018($t0) # draw pixel
	sw $t1, 0x1000800c($t0) # draw pixel
	sw $t1, 0x1000801c($t0) # draw pixel
	sw $t1, 0x10008010($t0) # draw pixel
	sw $t1, 0x10008008($t0) # draw pixel
	sw $t1, 0x10008004($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x10009c1c($t0) # draw pixel
	sw $t1, 0x10008c04($t0) # draw pixel
	sw $t1, 0x10008c18($t0) # draw pixel
	jr $ra