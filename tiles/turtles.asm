draw_sprite_turtle_1:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x1000a400($t0) # draw pixel
	sw $t1, 0x1000b404($t0) # draw pixel
	sw $t1, 0x10008c10($t0) # draw pixel
	sw $t1, 0x1000b038($t0) # draw pixel
	sw $t1, 0x10008838($t0) # draw pixel
	sw $t1, 0x1000800c($t0) # draw pixel
	sw $t1, 0x1000b420($t0) # draw pixel
	sw $t1, 0x10008018($t0) # draw pixel
	sw $t1, 0x1000942c($t0) # draw pixel
	sw $t1, 0x1000b020($t0) # draw pixel
	sw $t1, 0x1000943c($t0) # draw pixel
	sw $t1, 0x10009434($t0) # draw pixel
	sw $t1, 0x10008c30($t0) # draw pixel
	sw $t1, 0x10008020($t0) # draw pixel
	sw $t1, 0x1000b834($t0) # draw pixel
	sw $t1, 0x1000ac3c($t0) # draw pixel
	sw $t1, 0x1000bc24($t0) # draw pixel
	sw $t1, 0x1000b418($t0) # draw pixel
	sw $t1, 0x1000b434($t0) # draw pixel
	sw $t1, 0x10008c28($t0) # draw pixel
	sw $t1, 0x10009834($t0) # draw pixel
	sw $t1, 0x10009400($t0) # draw pixel
	sw $t1, 0x1000a800($t0) # draw pixel
	sw $t1, 0x10008818($t0) # draw pixel
	sw $t1, 0x10008c0c($t0) # draw pixel
	sw $t1, 0x1000bc20($t0) # draw pixel
	sw $t1, 0x1000b838($t0) # draw pixel
	sw $t1, 0x1000bc18($t0) # draw pixel
	sw $t1, 0x10008c1c($t0) # draw pixel
	sw $t1, 0x10009c34($t0) # draw pixel
	sw $t1, 0x1000b008($t0) # draw pixel
	sw $t1, 0x1000b428($t0) # draw pixel
	sw $t1, 0x10008c08($t0) # draw pixel
	sw $t1, 0x10009000($t0) # draw pixel
	sw $t1, 0x1000b80c($t0) # draw pixel
	sw $t1, 0x1000a434($t0) # draw pixel
	sw $t1, 0x1000bc38($t0) # draw pixel
	sw $t1, 0x1000b408($t0) # draw pixel
	sw $t1, 0x10009c30($t0) # draw pixel
	sw $t1, 0x1000982c($t0) # draw pixel
	sw $t1, 0x10009038($t0) # draw pixel
	sw $t1, 0x1000bc00($t0) # draw pixel
	sw $t1, 0x1000903c($t0) # draw pixel
	sw $t1, 0x1000bc0c($t0) # draw pixel
	sw $t1, 0x1000a838($t0) # draw pixel
	sw $t1, 0x1000bc1c($t0) # draw pixel
	sw $t1, 0x1000940c($t0) # draw pixel
	sw $t1, 0x10008010($t0) # draw pixel
	sw $t1, 0x1000ac04($t0) # draw pixel
	sw $t1, 0x10008814($t0) # draw pixel
	sw $t1, 0x1000a83c($t0) # draw pixel
	sw $t1, 0x10008c3c($t0) # draw pixel
	sw $t1, 0x10008404($t0) # draw pixel
	sw $t1, 0x1000801c($t0) # draw pixel
	sw $t1, 0x10008c38($t0) # draw pixel
	sw $t1, 0x1000ac38($t0) # draw pixel
	sw $t1, 0x1000b438($t0) # draw pixel
	sw $t1, 0x10008828($t0) # draw pixel
	sw $t1, 0x1000900c($t0) # draw pixel
	sw $t1, 0x1000a830($t0) # draw pixel
	sw $t1, 0x1000803c($t0) # draw pixel
	sw $t1, 0x10008014($t0) # draw pixel
	sw $t1, 0x10008400($t0) # draw pixel
	sw $t1, 0x1000b808($t0) # draw pixel
	sw $t1, 0x1000901c($t0) # draw pixel
	sw $t1, 0x1000b824($t0) # draw pixel
	sw $t1, 0x1000ac30($t0) # draw pixel
	sw $t1, 0x10009404($t0) # draw pixel
	sw $t1, 0x1000ac00($t0) # draw pixel
	sw $t1, 0x10008800($t0) # draw pixel
	sw $t1, 0x10009c38($t0) # draw pixel
	sw $t1, 0x10008030($t0) # draw pixel
	sw $t1, 0x10008034($t0) # draw pixel
	sw $t1, 0x1000b40c($t0) # draw pixel
	sw $t1, 0x1000b400($t0) # draw pixel
	sw $t1, 0x10009008($t0) # draw pixel
	sw $t1, 0x1000ac08($t0) # draw pixel
	sw $t1, 0x1000ac0c($t0) # draw pixel
	sw $t1, 0x10009024($t0) # draw pixel
	sw $t1, 0x10009034($t0) # draw pixel
	sw $t1, 0x1000b004($t0) # draw pixel
	sw $t1, 0x10009004($t0) # draw pixel
	sw $t1, 0x1000bc28($t0) # draw pixel
	sw $t1, 0x1000b01c($t0) # draw pixel
	sw $t1, 0x10008834($t0) # draw pixel
	sw $t1, 0x10008414($t0) # draw pixel
	sw $t1, 0x1000b000($t0) # draw pixel
	sw $t1, 0x1000843c($t0) # draw pixel
	sw $t1, 0x1000b41c($t0) # draw pixel
	sw $t1, 0x10008038($t0) # draw pixel
	sw $t1, 0x10008424($t0) # draw pixel
	sw $t1, 0x10008810($t0) # draw pixel
	sw $t1, 0x10008824($t0) # draw pixel
	sw $t1, 0x10008428($t0) # draw pixel
	sw $t1, 0x1000b828($t0) # draw pixel
	sw $t1, 0x10008024($t0) # draw pixel
	sw $t1, 0x1000a808($t0) # draw pixel
	sw $t1, 0x1000b804($t0) # draw pixel
	sw $t1, 0x1000b830($t0) # draw pixel
	sw $t1, 0x1000883c($t0) # draw pixel
	sw $t1, 0x10008830($t0) # draw pixel
	sw $t1, 0x10008434($t0) # draw pixel
	sw $t1, 0x1000b430($t0) # draw pixel
	sw $t1, 0x1000842c($t0) # draw pixel
	sw $t1, 0x10009438($t0) # draw pixel
	sw $t1, 0x10008418($t0) # draw pixel
	sw $t1, 0x10009830($t0) # draw pixel
	sw $t1, 0x1000b820($t0) # draw pixel
	sw $t1, 0x1000a82c($t0) # draw pixel
	sw $t1, 0x1000b818($t0) # draw pixel
	sw $t1, 0x10008820($t0) # draw pixel
	sw $t1, 0x1000b00c($t0) # draw pixel
	sw $t1, 0x1000a430($t0) # draw pixel
	sw $t1, 0x1000bc30($t0) # draw pixel
	sw $t1, 0x10008008($t0) # draw pixel
	sw $t1, 0x1000b810($t0) # draw pixel
	sw $t1, 0x1000a834($t0) # draw pixel
	sw $t1, 0x10008c00($t0) # draw pixel
	sw $t1, 0x1000a80c($t0) # draw pixel
	sw $t1, 0x10008438($t0) # draw pixel
	sw $t1, 0x10008408($t0) # draw pixel
	sw $t1, 0x1000880c($t0) # draw pixel
	sw $t1, 0x10009020($t0) # draw pixel
	sw $t1, 0x1000980c($t0) # draw pixel
	sw $t1, 0x10009c3c($t0) # draw pixel
	sw $t1, 0x1000b800($t0) # draw pixel
	sw $t1, 0x1000b03c($t0) # draw pixel
	sw $t1, 0x10008420($t0) # draw pixel
	sw $t1, 0x1000b424($t0) # draw pixel
	sw $t1, 0x10008004($t0) # draw pixel
	sw $t1, 0x10008c34($t0) # draw pixel
	sw $t1, 0x10009408($t0) # draw pixel
	sw $t1, 0x1000840c($t0) # draw pixel
	sw $t1, 0x1000ac2c($t0) # draw pixel
	sw $t1, 0x1000a43c($t0) # draw pixel
	sw $t1, 0x1000b82c($t0) # draw pixel
	sw $t1, 0x1000b814($t0) # draw pixel
	sw $t1, 0x1000b024($t0) # draw pixel
	sw $t1, 0x10009838($t0) # draw pixel
	sw $t1, 0x10009800($t0) # draw pixel
	sw $t1, 0x10008c18($t0) # draw pixel
	sw $t1, 0x1000841c($t0) # draw pixel
	sw $t1, 0x10008808($t0) # draw pixel
	sw $t1, 0x10008000($t0) # draw pixel
	sw $t1, 0x10009430($t0) # draw pixel
	sw $t1, 0x1000b43c($t0) # draw pixel
	sw $t1, 0x10008028($t0) # draw pixel
	sw $t1, 0x10009808($t0) # draw pixel
	sw $t1, 0x1000a03c($t0) # draw pixel
	sw $t1, 0x1000bc34($t0) # draw pixel
	sw $t1, 0x10008c24($t0) # draw pixel
	sw $t1, 0x1000881c($t0) # draw pixel
	sw $t1, 0x1000a038($t0) # draw pixel
	sw $t1, 0x1000983c($t0) # draw pixel
	sw $t1, 0x1000bc3c($t0) # draw pixel
	sw $t1, 0x1000bc10($t0) # draw pixel
	sw $t1, 0x1000bc04($t0) # draw pixel
	sw $t1, 0x10008430($t0) # draw pixel
	sw $t1, 0x10008410($t0) # draw pixel
	sw $t1, 0x1000b410($t0) # draw pixel
	sw $t1, 0x1000b81c($t0) # draw pixel
	sw $t1, 0x1000bc14($t0) # draw pixel
	sw $t1, 0x10008c20($t0) # draw pixel
	sw $t1, 0x1000882c($t0) # draw pixel
	sw $t1, 0x1000bc2c($t0) # draw pixel
	sw $t1, 0x10009c00($t0) # draw pixel
	sw $t1, 0x1000bc08($t0) # draw pixel
	sw $t1, 0x10008c04($t0) # draw pixel
	sw $t1, 0x10009804($t0) # draw pixel
	sw $t1, 0x1000802c($t0) # draw pixel
	sw $t1, 0x10008804($t0) # draw pixel
	sw $t1, 0x1000a804($t0) # draw pixel
	sw $t1, 0x1000b034($t0) # draw pixel
	sw $t1, 0x1000b83c($t0) # draw pixel
	sw $t1, 0x1000ac34($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1000b028($t0) # draw pixel
	sw $t1, 0x1000a008($t0) # draw pixel
	sw $t1, 0x1000ac10($t0) # draw pixel
	sw $t1, 0x1000a004($t0) # draw pixel
	sw $t1, 0x1000b014($t0) # draw pixel
	sw $t1, 0x1000ac28($t0) # draw pixel
	sw $t1, 0x10009428($t0) # draw pixel
	sw $t1, 0x10009410($t0) # draw pixel
	sw $t1, 0x1000a000($t0) # draw pixel
	sw $t1, 0x10009c08($t0) # draw pixel
	sw $t1, 0x10009014($t0) # draw pixel
	sw $t1, 0x10009028($t0) # draw pixel
	sw $t1, 0x1000a034($t0) # draw pixel
	sw $t1, 0x10009010($t0) # draw pixel
	sw $t1, 0x1000a438($t0) # draw pixel
	sw $t1, 0x1000b010($t0) # draw pixel
	sw $t1, 0x1000a408($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x1000ac18($t0) # draw pixel
	sw $t1, 0x1000a814($t0) # draw pixel
	sw $t1, 0x1000b414($t0) # draw pixel
	sw $t1, 0x1000a824($t0) # draw pixel
	sw $t1, 0x1000b02c($t0) # draw pixel
	sw $t1, 0x1000b030($t0) # draw pixel
	sw $t1, 0x1000ac1c($t0) # draw pixel
	sw $t1, 0x1000a404($t0) # draw pixel
	sw $t1, 0x10009018($t0) # draw pixel
	sw $t1, 0x10008c14($t0) # draw pixel
	sw $t1, 0x10008c2c($t0) # draw pixel
	sw $t1, 0x10009c04($t0) # draw pixel
	sw $t1, 0x1000b018($t0) # draw pixel
	sw $t1, 0x1000a428($t0) # draw pixel
	sw $t1, 0x1000902c($t0) # draw pixel
	sw $t1, 0x1000b42c($t0) # draw pixel
	sw $t1, 0x1000ac20($t0) # draw pixel
	sw $t1, 0x10009030($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x1000981c($t0) # draw pixel
	sw $t1, 0x1000a41c($t0) # draw pixel
	sw $t1, 0x10009c0c($t0) # draw pixel
	sw $t1, 0x1000a81c($t0) # draw pixel
	sw $t1, 0x10009814($t0) # draw pixel
	sw $t1, 0x1000a01c($t0) # draw pixel
	sw $t1, 0x1000ac24($t0) # draw pixel
	sw $t1, 0x1000a410($t0) # draw pixel
	sw $t1, 0x10009c10($t0) # draw pixel
	sw $t1, 0x1000a418($t0) # draw pixel
	sw $t1, 0x10009824($t0) # draw pixel
	sw $t1, 0x1000a820($t0) # draw pixel
	sw $t1, 0x1000a028($t0) # draw pixel
	sw $t1, 0x1000941c($t0) # draw pixel
	sw $t1, 0x1000a030($t0) # draw pixel
	sw $t1, 0x1000a414($t0) # draw pixel
	sw $t1, 0x10009c20($t0) # draw pixel
	sw $t1, 0x10009424($t0) # draw pixel
	sw $t1, 0x1000a42c($t0) # draw pixel
	sw $t1, 0x1000a024($t0) # draw pixel
	sw $t1, 0x1000a018($t0) # draw pixel
	sw $t1, 0x1000a818($t0) # draw pixel
	sw $t1, 0x10009828($t0) # draw pixel
	sw $t1, 0x10009418($t0) # draw pixel
	sw $t1, 0x1000a40c($t0) # draw pixel
	sw $t1, 0x10009c14($t0) # draw pixel
	sw $t1, 0x1000a010($t0) # draw pixel
	sw $t1, 0x1000a424($t0) # draw pixel
	sw $t1, 0x1000a420($t0) # draw pixel
	sw $t1, 0x10009c24($t0) # draw pixel
	sw $t1, 0x10009818($t0) # draw pixel
	sw $t1, 0x1000a014($t0) # draw pixel
	sw $t1, 0x1000a00c($t0) # draw pixel
	sw $t1, 0x1000a828($t0) # draw pixel
	sw $t1, 0x1000a02c($t0) # draw pixel
	sw $t1, 0x10009c18($t0) # draw pixel
	sw $t1, 0x10009820($t0) # draw pixel
	sw $t1, 0x10009c28($t0) # draw pixel
	sw $t1, 0x10009c2c($t0) # draw pixel
	sw $t1, 0x1000a810($t0) # draw pixel
	sw $t1, 0x1000a020($t0) # draw pixel
	sw $t1, 0x1000ac14($t0) # draw pixel
	sw $t1, 0x10009420($t0) # draw pixel
	sw $t1, 0x10009810($t0) # draw pixel
	sw $t1, 0x10009c1c($t0) # draw pixel
	sw $t1, 0x10009414($t0) # draw pixel
	jr $ra

draw_sprite_turtle_2:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x1000a400($t0) # draw pixel
	sw $t1, 0x1000b404($t0) # draw pixel
	sw $t1, 0x10008c10($t0) # draw pixel
	sw $t1, 0x1000b014($t0) # draw pixel
	sw $t1, 0x1000b038($t0) # draw pixel
	sw $t1, 0x10008838($t0) # draw pixel
	sw $t1, 0x1000800c($t0) # draw pixel
	sw $t1, 0x1000b420($t0) # draw pixel
	sw $t1, 0x10008018($t0) # draw pixel
	sw $t1, 0x1000942c($t0) # draw pixel
	sw $t1, 0x1000b020($t0) # draw pixel
	sw $t1, 0x1000943c($t0) # draw pixel
	sw $t1, 0x10009434($t0) # draw pixel
	sw $t1, 0x10008c30($t0) # draw pixel
	sw $t1, 0x10008020($t0) # draw pixel
	sw $t1, 0x1000b834($t0) # draw pixel
	sw $t1, 0x1000ac3c($t0) # draw pixel
	sw $t1, 0x1000bc24($t0) # draw pixel
	sw $t1, 0x1000b418($t0) # draw pixel
	sw $t1, 0x1000b434($t0) # draw pixel
	sw $t1, 0x10008c28($t0) # draw pixel
	sw $t1, 0x10009834($t0) # draw pixel
	sw $t1, 0x10009400($t0) # draw pixel
	sw $t1, 0x1000a800($t0) # draw pixel
	sw $t1, 0x10008818($t0) # draw pixel
	sw $t1, 0x1000bc20($t0) # draw pixel
	sw $t1, 0x1000b018($t0) # draw pixel
	sw $t1, 0x1000bc18($t0) # draw pixel
	sw $t1, 0x1000b838($t0) # draw pixel
	sw $t1, 0x10008c1c($t0) # draw pixel
	sw $t1, 0x10009c34($t0) # draw pixel
	sw $t1, 0x1000b428($t0) # draw pixel
	sw $t1, 0x10008c08($t0) # draw pixel
	sw $t1, 0x10009000($t0) # draw pixel
	sw $t1, 0x1000b80c($t0) # draw pixel
	sw $t1, 0x1000a434($t0) # draw pixel
	sw $t1, 0x1000bc38($t0) # draw pixel
	sw $t1, 0x1000b408($t0) # draw pixel
	sw $t1, 0x10009c30($t0) # draw pixel
	sw $t1, 0x1000982c($t0) # draw pixel
	sw $t1, 0x10009038($t0) # draw pixel
	sw $t1, 0x1000bc00($t0) # draw pixel
	sw $t1, 0x1000903c($t0) # draw pixel
	sw $t1, 0x1000bc0c($t0) # draw pixel
	sw $t1, 0x1000a838($t0) # draw pixel
	sw $t1, 0x1000bc1c($t0) # draw pixel
	sw $t1, 0x1000940c($t0) # draw pixel
	sw $t1, 0x10008010($t0) # draw pixel
	sw $t1, 0x1000ac04($t0) # draw pixel
	sw $t1, 0x10008814($t0) # draw pixel
	sw $t1, 0x1000a83c($t0) # draw pixel
	sw $t1, 0x10008c3c($t0) # draw pixel
	sw $t1, 0x10008404($t0) # draw pixel
	sw $t1, 0x1000801c($t0) # draw pixel
	sw $t1, 0x10008c38($t0) # draw pixel
	sw $t1, 0x1000ac38($t0) # draw pixel
	sw $t1, 0x1000b438($t0) # draw pixel
	sw $t1, 0x10008828($t0) # draw pixel
	sw $t1, 0x1000a830($t0) # draw pixel
	sw $t1, 0x10009018($t0) # draw pixel
	sw $t1, 0x1000803c($t0) # draw pixel
	sw $t1, 0x10008014($t0) # draw pixel
	sw $t1, 0x10008400($t0) # draw pixel
	sw $t1, 0x1000b808($t0) # draw pixel
	sw $t1, 0x1000901c($t0) # draw pixel
	sw $t1, 0x1000b824($t0) # draw pixel
	sw $t1, 0x1000ac30($t0) # draw pixel
	sw $t1, 0x10009404($t0) # draw pixel
	sw $t1, 0x1000ac00($t0) # draw pixel
	sw $t1, 0x10008800($t0) # draw pixel
	sw $t1, 0x10008030($t0) # draw pixel
	sw $t1, 0x10008034($t0) # draw pixel
	sw $t1, 0x1000b400($t0) # draw pixel
	sw $t1, 0x1000ac08($t0) # draw pixel
	sw $t1, 0x1000ac0c($t0) # draw pixel
	sw $t1, 0x10009034($t0) # draw pixel
	sw $t1, 0x10009024($t0) # draw pixel
	sw $t1, 0x1000b004($t0) # draw pixel
	sw $t1, 0x10009004($t0) # draw pixel
	sw $t1, 0x1000bc28($t0) # draw pixel
	sw $t1, 0x1000b01c($t0) # draw pixel
	sw $t1, 0x10008834($t0) # draw pixel
	sw $t1, 0x10008414($t0) # draw pixel
	sw $t1, 0x1000b000($t0) # draw pixel
	sw $t1, 0x1000843c($t0) # draw pixel
	sw $t1, 0x1000b41c($t0) # draw pixel
	sw $t1, 0x10008038($t0) # draw pixel
	sw $t1, 0x10008424($t0) # draw pixel
	sw $t1, 0x10008810($t0) # draw pixel
	sw $t1, 0x10008824($t0) # draw pixel
	sw $t1, 0x10008428($t0) # draw pixel
	sw $t1, 0x1000b828($t0) # draw pixel
	sw $t1, 0x10008024($t0) # draw pixel
	sw $t1, 0x1000a808($t0) # draw pixel
	sw $t1, 0x1000b804($t0) # draw pixel
	sw $t1, 0x1000b830($t0) # draw pixel
	sw $t1, 0x1000883c($t0) # draw pixel
	sw $t1, 0x10008830($t0) # draw pixel
	sw $t1, 0x10008434($t0) # draw pixel
	sw $t1, 0x1000b414($t0) # draw pixel
	sw $t1, 0x1000b430($t0) # draw pixel
	sw $t1, 0x1000842c($t0) # draw pixel
	sw $t1, 0x10009438($t0) # draw pixel
	sw $t1, 0x10008418($t0) # draw pixel
	sw $t1, 0x10009830($t0) # draw pixel
	sw $t1, 0x1000b820($t0) # draw pixel
	sw $t1, 0x1000a82c($t0) # draw pixel
	sw $t1, 0x1000b818($t0) # draw pixel
	sw $t1, 0x10008820($t0) # draw pixel
	sw $t1, 0x1000a430($t0) # draw pixel
	sw $t1, 0x1000bc30($t0) # draw pixel
	sw $t1, 0x10008008($t0) # draw pixel
	sw $t1, 0x1000b810($t0) # draw pixel
	sw $t1, 0x1000a834($t0) # draw pixel
	sw $t1, 0x10008c00($t0) # draw pixel
	sw $t1, 0x1000a80c($t0) # draw pixel
	sw $t1, 0x10008438($t0) # draw pixel
	sw $t1, 0x10008408($t0) # draw pixel
	sw $t1, 0x1000880c($t0) # draw pixel
	sw $t1, 0x10009020($t0) # draw pixel
	sw $t1, 0x1000980c($t0) # draw pixel
	sw $t1, 0x10009c3c($t0) # draw pixel
	sw $t1, 0x1000b800($t0) # draw pixel
	sw $t1, 0x1000b03c($t0) # draw pixel
	sw $t1, 0x10008420($t0) # draw pixel
	sw $t1, 0x1000b424($t0) # draw pixel
	sw $t1, 0x10008004($t0) # draw pixel
	sw $t1, 0x10009014($t0) # draw pixel
	sw $t1, 0x10008c34($t0) # draw pixel
	sw $t1, 0x10009408($t0) # draw pixel
	sw $t1, 0x1000840c($t0) # draw pixel
	sw $t1, 0x1000ac2c($t0) # draw pixel
	sw $t1, 0x1000a43c($t0) # draw pixel
	sw $t1, 0x1000b82c($t0) # draw pixel
	sw $t1, 0x1000b814($t0) # draw pixel
	sw $t1, 0x1000b024($t0) # draw pixel
	sw $t1, 0x10009838($t0) # draw pixel
	sw $t1, 0x10009800($t0) # draw pixel
	sw $t1, 0x10008c18($t0) # draw pixel
	sw $t1, 0x1000841c($t0) # draw pixel
	sw $t1, 0x10008808($t0) # draw pixel
	sw $t1, 0x10008000($t0) # draw pixel
	sw $t1, 0x10009430($t0) # draw pixel
	sw $t1, 0x1000b43c($t0) # draw pixel
	sw $t1, 0x10008028($t0) # draw pixel
	sw $t1, 0x10009808($t0) # draw pixel
	sw $t1, 0x1000a03c($t0) # draw pixel
	sw $t1, 0x1000bc34($t0) # draw pixel
	sw $t1, 0x1000a438($t0) # draw pixel
	sw $t1, 0x10008c24($t0) # draw pixel
	sw $t1, 0x1000881c($t0) # draw pixel
	sw $t1, 0x1000a038($t0) # draw pixel
	sw $t1, 0x1000983c($t0) # draw pixel
	sw $t1, 0x1000bc3c($t0) # draw pixel
	sw $t1, 0x1000bc10($t0) # draw pixel
	sw $t1, 0x1000bc04($t0) # draw pixel
	sw $t1, 0x10008430($t0) # draw pixel
	sw $t1, 0x10008410($t0) # draw pixel
	sw $t1, 0x10008c14($t0) # draw pixel
	sw $t1, 0x1000b410($t0) # draw pixel
	sw $t1, 0x1000b81c($t0) # draw pixel
	sw $t1, 0x1000bc14($t0) # draw pixel
	sw $t1, 0x10008c20($t0) # draw pixel
	sw $t1, 0x1000882c($t0) # draw pixel
	sw $t1, 0x1000bc2c($t0) # draw pixel
	sw $t1, 0x10009c00($t0) # draw pixel
	sw $t1, 0x1000bc08($t0) # draw pixel
	sw $t1, 0x10008c04($t0) # draw pixel
	sw $t1, 0x10009804($t0) # draw pixel
	sw $t1, 0x1000802c($t0) # draw pixel
	sw $t1, 0x10008804($t0) # draw pixel
	sw $t1, 0x1000a804($t0) # draw pixel
	sw $t1, 0x1000b034($t0) # draw pixel
	sw $t1, 0x1000b83c($t0) # draw pixel
	sw $t1, 0x1000ac34($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1000b028($t0) # draw pixel
	sw $t1, 0x1000a008($t0) # draw pixel
	sw $t1, 0x10009010($t0) # draw pixel
	sw $t1, 0x1000b42c($t0) # draw pixel
	sw $t1, 0x1000900c($t0) # draw pixel
	sw $t1, 0x1000a004($t0) # draw pixel
	sw $t1, 0x10009028($t0) # draw pixel
	sw $t1, 0x1000b00c($t0) # draw pixel
	sw $t1, 0x1000b010($t0) # draw pixel
	sw $t1, 0x1000ac28($t0) # draw pixel
	sw $t1, 0x1000a408($t0) # draw pixel
	sw $t1, 0x10009030($t0) # draw pixel
	sw $t1, 0x1000b02c($t0) # draw pixel
	sw $t1, 0x10008c0c($t0) # draw pixel
	sw $t1, 0x10008c2c($t0) # draw pixel
	sw $t1, 0x10009c08($t0) # draw pixel
	sw $t1, 0x10009c38($t0) # draw pixel
	sw $t1, 0x1000902c($t0) # draw pixel
	sw $t1, 0x1000b40c($t0) # draw pixel
	sw $t1, 0x10009008($t0) # draw pixel
	sw $t1, 0x1000a034($t0) # draw pixel
	sw $t1, 0x1000b030($t0) # draw pixel
	sw $t1, 0x1000b008($t0) # draw pixel
	sw $t1, 0x1000ac10($t0) # draw pixel
	sw $t1, 0x10009428($t0) # draw pixel
	sw $t1, 0x10009410($t0) # draw pixel
	sw $t1, 0x1000a000($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x1000ac18($t0) # draw pixel
	sw $t1, 0x1000a814($t0) # draw pixel
	sw $t1, 0x1000a824($t0) # draw pixel
	sw $t1, 0x1000ac1c($t0) # draw pixel
	sw $t1, 0x1000a404($t0) # draw pixel
	sw $t1, 0x10009c04($t0) # draw pixel
	sw $t1, 0x1000a428($t0) # draw pixel
	sw $t1, 0x1000ac20($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x1000981c($t0) # draw pixel
	sw $t1, 0x1000a41c($t0) # draw pixel
	sw $t1, 0x10009c0c($t0) # draw pixel
	sw $t1, 0x1000a81c($t0) # draw pixel
	sw $t1, 0x10009814($t0) # draw pixel
	sw $t1, 0x1000a01c($t0) # draw pixel
	sw $t1, 0x1000ac24($t0) # draw pixel
	sw $t1, 0x1000a410($t0) # draw pixel
	sw $t1, 0x10009c10($t0) # draw pixel
	sw $t1, 0x1000a418($t0) # draw pixel
	sw $t1, 0x10009824($t0) # draw pixel
	sw $t1, 0x1000a820($t0) # draw pixel
	sw $t1, 0x1000a028($t0) # draw pixel
	sw $t1, 0x1000941c($t0) # draw pixel
	sw $t1, 0x1000a030($t0) # draw pixel
	sw $t1, 0x1000a414($t0) # draw pixel
	sw $t1, 0x10009c20($t0) # draw pixel
	sw $t1, 0x10009424($t0) # draw pixel
	sw $t1, 0x1000a42c($t0) # draw pixel
	sw $t1, 0x1000a024($t0) # draw pixel
	sw $t1, 0x1000a018($t0) # draw pixel
	sw $t1, 0x1000a818($t0) # draw pixel
	sw $t1, 0x10009828($t0) # draw pixel
	sw $t1, 0x10009418($t0) # draw pixel
	sw $t1, 0x1000a40c($t0) # draw pixel
	sw $t1, 0x10009c14($t0) # draw pixel
	sw $t1, 0x1000a010($t0) # draw pixel
	sw $t1, 0x1000a424($t0) # draw pixel
	sw $t1, 0x1000a420($t0) # draw pixel
	sw $t1, 0x10009c24($t0) # draw pixel
	sw $t1, 0x10009818($t0) # draw pixel
	sw $t1, 0x1000a014($t0) # draw pixel
	sw $t1, 0x1000a00c($t0) # draw pixel
	sw $t1, 0x1000a828($t0) # draw pixel
	sw $t1, 0x1000a02c($t0) # draw pixel
	sw $t1, 0x10009c18($t0) # draw pixel
	sw $t1, 0x10009820($t0) # draw pixel
	sw $t1, 0x10009c28($t0) # draw pixel
	sw $t1, 0x10009c2c($t0) # draw pixel
	sw $t1, 0x1000a810($t0) # draw pixel
	sw $t1, 0x1000a020($t0) # draw pixel
	sw $t1, 0x1000ac14($t0) # draw pixel
	sw $t1, 0x10009420($t0) # draw pixel
	sw $t1, 0x10009810($t0) # draw pixel
	sw $t1, 0x10009c1c($t0) # draw pixel
	sw $t1, 0x10009414($t0) # draw pixel
	jr $ra

draw_sprite_turtle_3:
	sll $a0, $a0, 2  # multiply $a0 by 4
	sll $a1, $a1, 10 # multiply $a1 by 4 * 256
	add $t0, $a0, $a1
	li $t1, 0x000047 # store colour code for 0x000047
	sw $t1, 0x1000a400($t0) # draw pixel
	sw $t1, 0x1000b404($t0) # draw pixel
	sw $t1, 0x10008c10($t0) # draw pixel
	sw $t1, 0x1000b014($t0) # draw pixel
	sw $t1, 0x1000b038($t0) # draw pixel
	sw $t1, 0x10008838($t0) # draw pixel
	sw $t1, 0x1000800c($t0) # draw pixel
	sw $t1, 0x1000b420($t0) # draw pixel
	sw $t1, 0x10008018($t0) # draw pixel
	sw $t1, 0x1000b42c($t0) # draw pixel
	sw $t1, 0x1000b020($t0) # draw pixel
	sw $t1, 0x1000943c($t0) # draw pixel
	sw $t1, 0x10009434($t0) # draw pixel
	sw $t1, 0x10008c30($t0) # draw pixel
	sw $t1, 0x10008020($t0) # draw pixel
	sw $t1, 0x1000b834($t0) # draw pixel
	sw $t1, 0x1000ac3c($t0) # draw pixel
	sw $t1, 0x1000bc24($t0) # draw pixel
	sw $t1, 0x1000b418($t0) # draw pixel
	sw $t1, 0x1000b434($t0) # draw pixel
	sw $t1, 0x10008c28($t0) # draw pixel
	sw $t1, 0x10009834($t0) # draw pixel
	sw $t1, 0x10009400($t0) # draw pixel
	sw $t1, 0x1000a800($t0) # draw pixel
	sw $t1, 0x10008818($t0) # draw pixel
	sw $t1, 0x1000b02c($t0) # draw pixel
	sw $t1, 0x10008c0c($t0) # draw pixel
	sw $t1, 0x10008c2c($t0) # draw pixel
	sw $t1, 0x1000bc20($t0) # draw pixel
	sw $t1, 0x1000b018($t0) # draw pixel
	sw $t1, 0x1000bc18($t0) # draw pixel
	sw $t1, 0x1000b838($t0) # draw pixel
	sw $t1, 0x10008c1c($t0) # draw pixel
	sw $t1, 0x10009c34($t0) # draw pixel
	sw $t1, 0x1000b030($t0) # draw pixel
	sw $t1, 0x1000b008($t0) # draw pixel
	sw $t1, 0x1000b428($t0) # draw pixel
	sw $t1, 0x10008c08($t0) # draw pixel
	sw $t1, 0x10009000($t0) # draw pixel
	sw $t1, 0x1000a000($t0) # draw pixel
	sw $t1, 0x1000b80c($t0) # draw pixel
	sw $t1, 0x1000a434($t0) # draw pixel
	sw $t1, 0x1000bc38($t0) # draw pixel
	sw $t1, 0x1000b408($t0) # draw pixel
	sw $t1, 0x10009c30($t0) # draw pixel
	sw $t1, 0x1000982c($t0) # draw pixel
	sw $t1, 0x10009038($t0) # draw pixel
	sw $t1, 0x1000bc00($t0) # draw pixel
	sw $t1, 0x1000903c($t0) # draw pixel
	sw $t1, 0x1000bc0c($t0) # draw pixel
	sw $t1, 0x1000a838($t0) # draw pixel
	sw $t1, 0x1000bc1c($t0) # draw pixel
	sw $t1, 0x10008010($t0) # draw pixel
	sw $t1, 0x1000ac04($t0) # draw pixel
	sw $t1, 0x10008814($t0) # draw pixel
	sw $t1, 0x1000a83c($t0) # draw pixel
	sw $t1, 0x10008c3c($t0) # draw pixel
	sw $t1, 0x10008404($t0) # draw pixel
	sw $t1, 0x1000801c($t0) # draw pixel
	sw $t1, 0x10008c38($t0) # draw pixel
	sw $t1, 0x1000ac38($t0) # draw pixel
	sw $t1, 0x1000b438($t0) # draw pixel
	sw $t1, 0x10008828($t0) # draw pixel
	sw $t1, 0x1000900c($t0) # draw pixel
	sw $t1, 0x1000a830($t0) # draw pixel
	sw $t1, 0x10009018($t0) # draw pixel
	sw $t1, 0x1000803c($t0) # draw pixel
	sw $t1, 0x10008014($t0) # draw pixel
	sw $t1, 0x10008400($t0) # draw pixel
	sw $t1, 0x1000b808($t0) # draw pixel
	sw $t1, 0x1000901c($t0) # draw pixel
	sw $t1, 0x1000b824($t0) # draw pixel
	sw $t1, 0x1000ac30($t0) # draw pixel
	sw $t1, 0x10009404($t0) # draw pixel
	sw $t1, 0x1000ac00($t0) # draw pixel
	sw $t1, 0x10008800($t0) # draw pixel
	sw $t1, 0x10009c38($t0) # draw pixel
	sw $t1, 0x10008030($t0) # draw pixel
	sw $t1, 0x10008034($t0) # draw pixel
	sw $t1, 0x1000b40c($t0) # draw pixel
	sw $t1, 0x1000b400($t0) # draw pixel
	sw $t1, 0x10009008($t0) # draw pixel
	sw $t1, 0x1000ac08($t0) # draw pixel
	sw $t1, 0x10009034($t0) # draw pixel
	sw $t1, 0x10009024($t0) # draw pixel
	sw $t1, 0x1000b004($t0) # draw pixel
	sw $t1, 0x10009004($t0) # draw pixel
	sw $t1, 0x10009c04($t0) # draw pixel
	sw $t1, 0x1000b01c($t0) # draw pixel
	sw $t1, 0x1000bc28($t0) # draw pixel
	sw $t1, 0x10008834($t0) # draw pixel
	sw $t1, 0x10008414($t0) # draw pixel
	sw $t1, 0x1000b000($t0) # draw pixel
	sw $t1, 0x1000843c($t0) # draw pixel
	sw $t1, 0x1000b41c($t0) # draw pixel
	sw $t1, 0x10008038($t0) # draw pixel
	sw $t1, 0x10008424($t0) # draw pixel
	sw $t1, 0x10008810($t0) # draw pixel
	sw $t1, 0x10008824($t0) # draw pixel
	sw $t1, 0x10008428($t0) # draw pixel
	sw $t1, 0x1000b828($t0) # draw pixel
	sw $t1, 0x10008024($t0) # draw pixel
	sw $t1, 0x1000a808($t0) # draw pixel
	sw $t1, 0x1000b804($t0) # draw pixel
	sw $t1, 0x1000b830($t0) # draw pixel
	sw $t1, 0x1000883c($t0) # draw pixel
	sw $t1, 0x10008830($t0) # draw pixel
	sw $t1, 0x10008434($t0) # draw pixel
	sw $t1, 0x1000b414($t0) # draw pixel
	sw $t1, 0x1000b430($t0) # draw pixel
	sw $t1, 0x1000842c($t0) # draw pixel
	sw $t1, 0x10009438($t0) # draw pixel
	sw $t1, 0x10008418($t0) # draw pixel
	sw $t1, 0x10009830($t0) # draw pixel
	sw $t1, 0x1000b820($t0) # draw pixel
	sw $t1, 0x1000a82c($t0) # draw pixel
	sw $t1, 0x1000b818($t0) # draw pixel
	sw $t1, 0x10008820($t0) # draw pixel
	sw $t1, 0x1000b00c($t0) # draw pixel
	sw $t1, 0x1000a430($t0) # draw pixel
	sw $t1, 0x1000bc30($t0) # draw pixel
	sw $t1, 0x10009030($t0) # draw pixel
	sw $t1, 0x10008008($t0) # draw pixel
	sw $t1, 0x1000a404($t0) # draw pixel
	sw $t1, 0x1000b810($t0) # draw pixel
	sw $t1, 0x1000a834($t0) # draw pixel
	sw $t1, 0x10008c00($t0) # draw pixel
	sw $t1, 0x1000a80c($t0) # draw pixel
	sw $t1, 0x10008438($t0) # draw pixel
	sw $t1, 0x10008408($t0) # draw pixel
	sw $t1, 0x1000880c($t0) # draw pixel
	sw $t1, 0x10009020($t0) # draw pixel
	sw $t1, 0x1000980c($t0) # draw pixel
	sw $t1, 0x10009c3c($t0) # draw pixel
	sw $t1, 0x1000b800($t0) # draw pixel
	sw $t1, 0x1000b03c($t0) # draw pixel
	sw $t1, 0x10008420($t0) # draw pixel
	sw $t1, 0x1000b424($t0) # draw pixel
	sw $t1, 0x10008004($t0) # draw pixel
	sw $t1, 0x10009014($t0) # draw pixel
	sw $t1, 0x10008c34($t0) # draw pixel
	sw $t1, 0x10009408($t0) # draw pixel
	sw $t1, 0x1000840c($t0) # draw pixel
	sw $t1, 0x1000a43c($t0) # draw pixel
	sw $t1, 0x1000b82c($t0) # draw pixel
	sw $t1, 0x1000b814($t0) # draw pixel
	sw $t1, 0x1000b024($t0) # draw pixel
	sw $t1, 0x10009838($t0) # draw pixel
	sw $t1, 0x10009800($t0) # draw pixel
	sw $t1, 0x10008c18($t0) # draw pixel
	sw $t1, 0x1000841c($t0) # draw pixel
	sw $t1, 0x10008808($t0) # draw pixel
	sw $t1, 0x10008000($t0) # draw pixel
	sw $t1, 0x10009430($t0) # draw pixel
	sw $t1, 0x1000b43c($t0) # draw pixel
	sw $t1, 0x10008028($t0) # draw pixel
	sw $t1, 0x10009808($t0) # draw pixel
	sw $t1, 0x1000a03c($t0) # draw pixel
	sw $t1, 0x1000bc34($t0) # draw pixel
	sw $t1, 0x1000a438($t0) # draw pixel
	sw $t1, 0x10008c24($t0) # draw pixel
	sw $t1, 0x1000881c($t0) # draw pixel
	sw $t1, 0x1000a038($t0) # draw pixel
	sw $t1, 0x1000983c($t0) # draw pixel
	sw $t1, 0x1000bc3c($t0) # draw pixel
	sw $t1, 0x1000bc10($t0) # draw pixel
	sw $t1, 0x1000bc04($t0) # draw pixel
	sw $t1, 0x10008430($t0) # draw pixel
	sw $t1, 0x10008410($t0) # draw pixel
	sw $t1, 0x10008c14($t0) # draw pixel
	sw $t1, 0x1000b410($t0) # draw pixel
	sw $t1, 0x1000b81c($t0) # draw pixel
	sw $t1, 0x1000bc14($t0) # draw pixel
	sw $t1, 0x10008c20($t0) # draw pixel
	sw $t1, 0x1000882c($t0) # draw pixel
	sw $t1, 0x1000902c($t0) # draw pixel
	sw $t1, 0x1000bc2c($t0) # draw pixel
	sw $t1, 0x10009c00($t0) # draw pixel
	sw $t1, 0x1000bc08($t0) # draw pixel
	sw $t1, 0x10008c04($t0) # draw pixel
	sw $t1, 0x10009804($t0) # draw pixel
	sw $t1, 0x1000802c($t0) # draw pixel
	sw $t1, 0x10008804($t0) # draw pixel
	sw $t1, 0x1000a804($t0) # draw pixel
	sw $t1, 0x1000b034($t0) # draw pixel
	sw $t1, 0x1000b83c($t0) # draw pixel
	sw $t1, 0x1000ac34($t0) # draw pixel
	li $t1, 0x21de00 # store colour code for 0x21de00
	sw $t1, 0x1000b028($t0) # draw pixel
	sw $t1, 0x1000a008($t0) # draw pixel
	sw $t1, 0x1000ac10($t0) # draw pixel
	sw $t1, 0x1000a004($t0) # draw pixel
	sw $t1, 0x1000ac2c($t0) # draw pixel
	sw $t1, 0x10009428($t0) # draw pixel
	sw $t1, 0x10009410($t0) # draw pixel
	sw $t1, 0x10009028($t0) # draw pixel
	sw $t1, 0x1000940c($t0) # draw pixel
	sw $t1, 0x1000942c($t0) # draw pixel
	sw $t1, 0x1000a034($t0) # draw pixel
	sw $t1, 0x1000ac0c($t0) # draw pixel
	sw $t1, 0x10009010($t0) # draw pixel
	sw $t1, 0x1000b010($t0) # draw pixel
	sw $t1, 0x1000ac28($t0) # draw pixel
	li $t1, 0xdedef7 # store colour code for 0xdedef7
	sw $t1, 0x1000ac18($t0) # draw pixel
	sw $t1, 0x1000a814($t0) # draw pixel
	sw $t1, 0x1000a824($t0) # draw pixel
	sw $t1, 0x1000ac1c($t0) # draw pixel
	sw $t1, 0x10009c08($t0) # draw pixel
	sw $t1, 0x1000a428($t0) # draw pixel
	sw $t1, 0x1000ac20($t0) # draw pixel
	sw $t1, 0x1000a408($t0) # draw pixel
	li $t1, 0xff0000 # store colour code for 0xff0000
	sw $t1, 0x1000981c($t0) # draw pixel
	sw $t1, 0x1000a41c($t0) # draw pixel
	sw $t1, 0x10009c0c($t0) # draw pixel
	sw $t1, 0x1000a81c($t0) # draw pixel
	sw $t1, 0x10009814($t0) # draw pixel
	sw $t1, 0x1000a01c($t0) # draw pixel
	sw $t1, 0x1000ac24($t0) # draw pixel
	sw $t1, 0x1000a410($t0) # draw pixel
	sw $t1, 0x10009c10($t0) # draw pixel
	sw $t1, 0x1000a418($t0) # draw pixel
	sw $t1, 0x10009824($t0) # draw pixel
	sw $t1, 0x1000a820($t0) # draw pixel
	sw $t1, 0x1000a028($t0) # draw pixel
	sw $t1, 0x1000941c($t0) # draw pixel
	sw $t1, 0x1000a030($t0) # draw pixel
	sw $t1, 0x1000a414($t0) # draw pixel
	sw $t1, 0x10009c20($t0) # draw pixel
	sw $t1, 0x10009424($t0) # draw pixel
	sw $t1, 0x1000a42c($t0) # draw pixel
	sw $t1, 0x1000a024($t0) # draw pixel
	sw $t1, 0x1000a018($t0) # draw pixel
	sw $t1, 0x1000a818($t0) # draw pixel
	sw $t1, 0x10009828($t0) # draw pixel
	sw $t1, 0x10009418($t0) # draw pixel
	sw $t1, 0x1000a40c($t0) # draw pixel
	sw $t1, 0x10009c14($t0) # draw pixel
	sw $t1, 0x1000a010($t0) # draw pixel
	sw $t1, 0x1000a424($t0) # draw pixel
	sw $t1, 0x1000a420($t0) # draw pixel
	sw $t1, 0x10009c24($t0) # draw pixel
	sw $t1, 0x10009818($t0) # draw pixel
	sw $t1, 0x1000a014($t0) # draw pixel
	sw $t1, 0x1000a00c($t0) # draw pixel
	sw $t1, 0x1000a828($t0) # draw pixel
	sw $t1, 0x1000a02c($t0) # draw pixel
	sw $t1, 0x10009c18($t0) # draw pixel
	sw $t1, 0x10009820($t0) # draw pixel
	sw $t1, 0x10009c28($t0) # draw pixel
	sw $t1, 0x10009c2c($t0) # draw pixel
	sw $t1, 0x1000a810($t0) # draw pixel
	sw $t1, 0x1000a020($t0) # draw pixel
	sw $t1, 0x1000ac14($t0) # draw pixel
	sw $t1, 0x10009420($t0) # draw pixel
	sw $t1, 0x10009810($t0) # draw pixel
	sw $t1, 0x10009c1c($t0) # draw pixel
	sw $t1, 0x10009414($t0) # draw pixel
	jr $ra
