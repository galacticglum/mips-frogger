draw_sprite_frog:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	li $t1, 0x59e640 # store colour code for 0x59e640
	sw $t1, 0x1000a418($t0) # draw pixel
	sw $t1, 0x10008c44($t0) # draw pixel
	sw $t1, 0x10009c3c($t0) # draw pixel
	sw $t1, 0x10008818($t0) # draw pixel
	sw $t1, 0x1000a430($t0) # draw pixel
	sw $t1, 0x10008c14($t0) # draw pixel
	sw $t1, 0x10009c38($t0) # draw pixel
	sw $t1, 0x10008c40($t0) # draw pixel
	sw $t1, 0x1000a818($t0) # draw pixel
	sw $t1, 0x1000a414($t0) # draw pixel
	sw $t1, 0x1000a424($t0) # draw pixel
	sw $t1, 0x10009020($t0) # draw pixel
	sw $t1, 0x1000a018($t0) # draw pixel
	sw $t1, 0x10009018($t0) # draw pixel
	sw $t1, 0x1000941c($t0) # draw pixel
	sw $t1, 0x10009438($t0) # draw pixel
	sw $t1, 0x10009418($t0) # draw pixel
	sw $t1, 0x1000a034($t0) # draw pixel
	sw $t1, 0x10008c18($t0) # draw pixel
	sw $t1, 0x10008c3c($t0) # draw pixel
	sw $t1, 0x1000a440($t0) # draw pixel
	sw $t1, 0x1000a444($t0) # draw pixel
	sw $t1, 0x1000903c($t0) # draw pixel
	sw $t1, 0x10009c18($t0) # draw pixel
	sw $t1, 0x1000a83c($t0) # draw pixel
	sw $t1, 0x1000a020($t0) # draw pixel
	sw $t1, 0x1000a43c($t0) # draw pixel
	sw $t1, 0x1000943c($t0) # draw pixel
	sw $t1, 0x1000883c($t0) # draw pixel
	sw $t1, 0x10009c1c($t0) # draw pixel
	sw $t1, 0x1000a03c($t0) # draw pixel
	li $t1, 0xff20f8 # store colour code for 0xff20f8
	sw $t1, 0x10008c20($t0) # draw pixel
	li $t1, 0xffff20 # store colour code for 0xffff20
	sw $t1, 0x1000a42c($t0) # draw pixel
	sw $t1, 0x10009820($t0) # draw pixel
	sw $t1, 0x1000a024($t0) # draw pixel
	sw $t1, 0x10009420($t0) # draw pixel
	sw $t1, 0x10009c20($t0) # draw pixel
	sw $t1, 0x10008824($t0) # draw pixel
	sw $t1, 0x1000a428($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x10008c30($t0) # draw pixel
	sw $t1, 0x10009030($t0) # draw pixel
	sw $t1, 0x10008c24($t0) # draw pixel
	sw $t1, 0x10009034($t0) # draw pixel
	sw $t1, 0x10009024($t0) # draw pixel
	sw $t1, 0x1000a028($t0) # draw pixel
	sw $t1, 0x10009c24($t0) # draw pixel
	sw $t1, 0x10008828($t0) # draw pixel
	sw $t1, 0x10009824($t0) # draw pixel
	li $t1, 0xffff00 # store colour code for 0xffff00
	sw $t1, 0x10009430($t0) # draw pixel
	sw $t1, 0x1000902c($t0) # draw pixel
	sw $t1, 0x10009424($t0) # draw pixel
	sw $t1, 0x10008c28($t0) # draw pixel
	sw $t1, 0x10009828($t0) # draw pixel
	sw $t1, 0x10009c34($t0) # draw pixel
	sw $t1, 0x10009028($t0) # draw pixel
	sw $t1, 0x1000a030($t0) # draw pixel
	sw $t1, 0x10008c2c($t0) # draw pixel
	sw $t1, 0x10009434($t0) # draw pixel
	sw $t1, 0x10008830($t0) # draw pixel
	sw $t1, 0x1000882c($t0) # draw pixel
	sw $t1, 0x10009830($t0) # draw pixel
	sw $t1, 0x1000a02c($t0) # draw pixel
	sw $t1, 0x10009c30($t0) # draw pixel
	sw $t1, 0x10009428($t0) # draw pixel
	sw $t1, 0x10009c28($t0) # draw pixel
	sw $t1, 0x1000942c($t0) # draw pixel
	sw $t1, 0x10009834($t0) # draw pixel
	sw $t1, 0x1000982c($t0) # draw pixel
	sw $t1, 0x10009c2c($t0) # draw pixel
	li $t1, 0xff00f7 # store colour code for 0xff00f7
	sw $t1, 0x10008c34($t0) # draw pixel
	jr $ra