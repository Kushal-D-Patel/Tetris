#####################################################################
# CSCB58 Summer 2024 Assembly Final Project - UTSC
# Student1: Michael Wang, 1010635083, wangm375, michaelgr.wang@mail.utoronto.ca
# Student2: Kushal Patel, 1009971078, pate2441, kd.patel@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 16
# - Unit height in pixels: 16
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5 (All milestones have been completed)
#
# Which approved features have been implemented?
# (See the assignment handout for the list of features)
# Easy Features:
# 1. 1, 2, 3, 4, 5(from the instructions)
# 2. dropping all blocks above cleared rows
# ... (add more if necessary)
# Hard Features:
# 1. 4 (from the instructions)
# 2. (fill in the feature, if any)
# ... (add more if necessary)
# How to play:
# Use W to rotate the tetromino clockwise, A to move that tetromino left, S to drop the tetromino down by one line, D to move the tetromino to the right, p to pause the game and press p again to unpause, q to quit the game, and r to retry only if you are in the game over screen
# Link to video demonstration for final submission:
# - https://drive.google.com/file/d/1hIOHdXTJ6pTVzygyOLRse1VxzzoF7RKw/view?usp=sharing
#
# Are you OK with us sharing the video with people outside course staff?
# - yes
#
# Any additional information that the TA needs to know:
# - N/A
#
#####################################################################

##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000

.eqv STARTROW 768 	# 6*32*4, start on row 7
.eqv STARTCOL 44 	# 10*4, start on column 12
.eqv ENDROW 3200	# 25*32*4, end on row 26
.eqv ENDCOL 80		# 20*4, end on column 21
.eqv ADDROW 128		# 32*4
.eqv ADDCOL 4		# 1*4
.eqv ADD2ROW 256	# 2*32*4, add a row
.eqv ADD2COL 8		# 2*4, add 2 columns
.eqv ORIGIN  956	# STARTROW + ADDROW + STARTCOL + 5*3
##############################################################################
# Mutable Data
##############################################################################
PLACED_BLOCK_DATA:
	.word 180
##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Tetris game.
main:
    # Initialize the game
        li $v1, 0
        li $s4, 20
    	li $a3, 0		# number of placed blocks
	la $s6, ADDR_DSPL
	lw $s6, 0($s6)
	li $t3, 0x0000ff

	li $t9, STARTROW
	li $t8, STARTCOL
	addi $t8, $t8, -ADDCOL
	li $t7, ENDROW
	addi $t7, $t7, ADDROW	
drawSideWallLeft:
	add $t5, $t9, $t8
	add $t4, $t5, $s6
	sw $t3, 0($t4)
	addi $t9, $t9, ADDROW
	ble $t9, $t7, drawSideWallLeft
	
	li $t9, STARTROW
	li $t8, ENDCOL
	addi $t8, $t8, ADDCOL
drawSideWallRight:
	add $t5, $t9, $t8
	add $t4, $t5, $s6
	sw $t3, 0($t4)
	addi $t9, $t9, ADDROW
	ble $t9, $t7, drawSideWallRight
	
	li $t8, STARTCOL
	li $t9, ENDCOL
drawBottomWall:
	add $t5, $t8, $t7
	add $t4, $t5, $s6
	sw $t3, 0($t4)
	addi $t8, $t8, ADDCOL
	ble $t8, $t9, drawBottomWall
	
SET_DATA:
	la $t9, PLACED_BLOCK_DATA
	addi $t8, $t9, 720
DATA_LOOP:
	bge $t9, $t8, SPAWNLINE
	add $t0, $zero, $zero
	sw $t0, 0($t9)
	addi $t9, $t9, 4
	j DATA_LOOP
	
SPAWNLINE:
	addi $a0, $s6, ORIGIN
	li $a1, 0
	add $a2, $zero, $zero
	jal drawLineBlock
	move $a0, $v0

game_loop:	
	# 1a. Check if key has been pressed
	li $t9,0xffff0000
	lw $t8, 0($t9)
    # 1b. Check which key has been pressed
        addi $v1, $v1, 1
    	beq $t8, 1, KEY_PRESSED
    	bge $v1, $s4, FAST_GRAVITY
    	
KEY_RETURN:
        # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $a1, 0($sp)
	li $v0, 32
	li $a0, 100
	syscall
	lw $a1, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8

    #5. Go back to 1
    j game_loop
    
FAST_GRAVITY:
	li $v1, 0
	ble $s4, 5, S_PRESSED
       addi $s4, $s4, -1
       j S_PRESSED
    
KEY_PRESSED:
	lw $t8, 4($t9)
	beq $t8, 0x77, W_PRESSED
	beq $t8, 0x61, A_PRESSED
	beq $t8, 0x73, S_PRESSED
	beq $t8, 0x64, D_PRESSED
	beq $t8, 0x70, PAUSED
	beq $t8, 0x71, END
	j KEY_RETURN
	
PAUSED:
       la $t0, ADDR_DSPL
       lw $t0, 0($t0)
       li $t1, 0xFFA500
       sw $t1, ($t0)
       sw $t1, 128($t0)
       sw $t1, 256($t0)
       sw $t1, 384($t0)
       sw $t1, 512($t0)
       sw $t1, 640($t0)
       sw $t1, 4($t0)
       sw $t1, 8($t0)
       sw $t1, 12($t0)
       sw $t1, 140($t0)
       sw $t1, 268($t0)
       sw $t1, 264($t0)
       sw $t1, 260($t0)
       sw $t1, 20($t0)
       sw $t1, 148($t0)
       sw $t1, 276($t0)
       sw $t1, 404($t0)
       sw $t1, 532($t0)
       sw $t1, 660($t0)
       sw $t1, 24($t0)
       sw $t1, 28($t0)
       sw $t1, 32($t0)
       sw $t1, 160($t0)
       sw $t1, 288($t0)
       sw $t1, 416($t0)
       sw $t1, 544($t0)
       sw $t1, 672($t0)
       sw $t1, 408($t0)
       sw $t1, 412($t0)
       sw $t1, 40($t0)
       sw $t1, 168($t0)
       sw $t1, 296($t0)
       sw $t1, 424($t0)
       sw $t1, 552($t0)
       sw $t1, 680($t0)
       sw $t1, 684($t0)
       sw $t1, 688($t0)
       sw $t1, 692($t0)
       sw $t1, 564($t0)
       sw $t1, 436($t0)
       sw $t1, 308($t0)
       sw $t1, 180($t0)
       sw $t1, 52($t0)
       sw $t1, 60($t0)
       sw $t1, 64($t0)
       sw $t1, 68($t0)
       sw $t1, 188($t0)
       sw $t1, 316($t0)
       sw $t1, 320($t0)
       sw $t1, 324($t0)
       sw $t1, 452($t0)
       sw $t1, 580($t0)
       sw $t1, 708($t0)
       sw $t1, 704($t0)
       sw $t1, 700($t0)
       sw $t1, 76($t0)
       sw $t1, 80($t0)
       sw $t1, 84($t0)
       sw $t1, 204($t0)
       sw $t1, 332($t0)
       sw $t1, 336($t0)
       sw $t1, 340($t0)
       sw $t1, 460($t0)
       sw $t1, 588($t0)
       sw $t1, 716($t0)
       sw $t1, 720($t0)
       sw $t1, 724($t0)
       sw $t1, 92($t0)
       sw $t1, 96($t0)
       sw $t1, 100($t0)
       sw $t1, 220($t0)
       sw $t1, 348($t0)
       sw $t1, 476($t0)
       sw $t1, 604($t0)
       sw $t1, 732($t0)
       sw $t1, 736($t0)
       sw $t1, 740($t0)
       sw $t1, 612($t0)
       sw $t1, 484($t0)
       sw $t1, 356($t0)
       sw $t1, 228($t0)
       j PAUSE_LOOP
       
PAUSE_LOOP:
      li $t9,0xffff0000
      lw $t8, 0($t9)
      beq $t8, 1, CHECK_PAUSE
      j PAUSE_LOOP
      
CHECK_PAUSE:
     lw $t8, 4($t9)
     beq $t8, 0x70, RESUME
     j PAUSE_LOOP
     
RESUME:
       la $t0, ADDR_DSPL
       lw $t0, 0($t0)
       li $t1, 0x000000
       sw $t1, ($t0)
       sw $t1, 128($t0)
       sw $t1, 256($t0)
       sw $t1, 384($t0)
       sw $t1, 512($t0)
       sw $t1, 640($t0)
       sw $t1, 4($t0)
       sw $t1, 8($t0)
       sw $t1, 12($t0)
       sw $t1, 140($t0)
       sw $t1, 268($t0)
       sw $t1, 264($t0)
       sw $t1, 260($t0)
       sw $t1, 20($t0)
       sw $t1, 148($t0)
       sw $t1, 276($t0)
       sw $t1, 404($t0)
       sw $t1, 532($t0)
       sw $t1, 660($t0)
       sw $t1, 24($t0)
       sw $t1, 28($t0)
       sw $t1, 32($t0)
       sw $t1, 160($t0)
       sw $t1, 288($t0)
       sw $t1, 416($t0)
       sw $t1, 544($t0)
       sw $t1, 672($t0)
       sw $t1, 408($t0)
       sw $t1, 412($t0)
       sw $t1, 40($t0)
       sw $t1, 168($t0)
       sw $t1, 296($t0)
       sw $t1, 424($t0)
       sw $t1, 552($t0)
       sw $t1, 680($t0)
       sw $t1, 684($t0)
       sw $t1, 688($t0)
       sw $t1, 692($t0)
       sw $t1, 564($t0)
       sw $t1, 436($t0)
       sw $t1, 308($t0)
       sw $t1, 180($t0)
       sw $t1, 52($t0)
       sw $t1, 60($t0)
       sw $t1, 64($t0)
       sw $t1, 68($t0)
       sw $t1, 188($t0)
       sw $t1, 316($t0)
       sw $t1, 320($t0)
       sw $t1, 324($t0)
       sw $t1, 452($t0)
       sw $t1, 580($t0)
       sw $t1, 708($t0)
       sw $t1, 704($t0)
       sw $t1, 700($t0)
       sw $t1, 76($t0)
       sw $t1, 80($t0)
       sw $t1, 84($t0)
       sw $t1, 204($t0)
       sw $t1, 332($t0)
       sw $t1, 336($t0)
       sw $t1, 340($t0)
       sw $t1, 460($t0)
       sw $t1, 588($t0)
       sw $t1, 716($t0)
       sw $t1, 720($t0)
       sw $t1, 724($t0)
       sw $t1, 92($t0)
       sw $t1, 96($t0)
       sw $t1, 100($t0)
       sw $t1, 220($t0)
       sw $t1, 348($t0)
       sw $t1, 476($t0)
       sw $t1, 604($t0)
       sw $t1, 732($t0)
       sw $t1, 736($t0)
       sw $t1, 740($t0)
       sw $t1, 612($t0)
       sw $t1, 484($t0)
       sw $t1, 356($t0)
       sw $t1, 228($t0)
       j game_loop
    
W_PRESSED:
        beq $a1, 0, ROTATION_COLLISION_ZERO_CASE_ONE
        beq $a1, 2, ROTATION_COLLISION_TWO_CASE_ONE
        beq $a1, 1, ROTATION_COLLISION_ONE_CASE_ONE
        beq $a1, 3, ROTATION_COLLISION_THREE_CASE_ONE

W_BACK:
        add $s0, $a0, $zero
        add $s1, $a1, $zero
        add $s2, $a2, $zero
        add $s3, $a3, $zero
        li $a0, 72 #pitch
        li $a1, 1000 #1000 ms = 1s
        li $a2, 113 #percussion
        li $a3, 100 #volume = 100
        li $v0, 31
        syscall
        add $a0, $s0, $zero
        add $a1, $s1, $zero
        add $a2, $s2, $zero
        add $a3, $s3, $zero
	li $t7, 3
	li $a2, 1		# Rotation boolean
	beq $a1, $t7, ROT_RESET	# if rotation is 3, go back to 0
	addi $a1, $a1, 1	# increment rotation by 1
	jal drawLineBlock
	move $a0, $v0
	j KEY_RETURN
	
ROT_RESET:			# cycle rotation value back to 0
	add $a1, $zero, $zero
	jal drawLineBlock
	move $a0, $v0
	j KEY_RETURN

ROTATION_COLLISION_ZERO_CASE_ONE:		# Apply offset, check 1 block up
	addi $t7, $a0, ADDCOL
        lw $t8, -ADDROW($t7)
        beq $t8, 0x5c5c5c, ROTATION_COLLISION_ZERO_CASE_TWO
        beq $t8, 0x9e9e9e, ROTATION_COLLISION_ZERO_CASE_TWO
        j ROTATION_COLLISION
        
ROTATION_COLLISION_ZERO_CASE_TWO:		# Check 1 block down
	lw $t8, ADDROW($t7)
        beq $t8, 0x5c5c5c, ROTATION_COLLISION_ZERO_CASE_THREE
        beq $t8, 0x9e9e9e, ROTATION_COLLISION_ZERO_CASE_THREE
        j ROTATION_COLLISION
        
ROTATION_COLLISION_ZERO_CASE_THREE:	# Check 2 blocks down
        lw $t8, ADD2ROW($t7)
        beq $t8, 0x5c5c5c, W_BACK
        beq $t8, 0x9e9e9e, W_BACK
        j ROTATION_COLLISION
        
ROTATION_COLLISION_TWO_CASE_ONE:		# Apply offset, check 2 blocks up
	addi $t7, $a0, -ADDCOL
	lw $t8, -ADD2ROW($t7)
        beq $t8, 0x5c5c5c, ROTATION_COLLISION_TWO_CASE_TWO
        beq $t8, 0x9e9e9e, ROTATION_COLLISION_TWO_CASE_TWO
        j ROTATION_COLLISION
        
ROTATION_COLLISION_TWO_CASE_TWO:
	lw $t8, -ADDROW($t7)
        beq $t8, 0x5c5c5c, ROTATION_COLLISION_TWO_CASE_THREE
        beq $t8, 0x9e9e9e, ROTATION_COLLISION_TWO_CASE_THREE
        j ROTATION_COLLISION
        
ROTATION_COLLISION_TWO_CASE_THREE:
	lw $t8, ADDROW($t7)
        beq $t8, 0x5c5c5c, W_BACK
        beq $t8, 0x9e9e9e, W_BACK
        j ROTATION_COLLISION
        
ROTATION_COLLISION_ONE_CASE_ONE:
	addi $t7, $a0, ADDROW
      lw $t8, -ADD2COL($t7)
      beq $t8, 0x5c5c5c, ROTATION_COLLISION_ONE_CASE_TWO
      beq $t8, 0x9e9e9e, ROTATION_COLLISION_ONE_CASE_TWO
      j ROTATION_COLLISION
      
ROTATION_COLLISION_ONE_CASE_TWO:
      lw $t8, -ADDCOL($t7)
      beq $t8, 0x5c5c5c, ROTATION_COLLISION_ONE_CASE_THREE
      beq $t8, 0x9e9e9e, ROTATION_COLLISION_ONE_CASE_THREE
      j ROTATION_COLLISION
    
ROTATION_COLLISION_ONE_CASE_THREE:
      lw $t8, ADDCOL($t7)
      beq $t8, 0x5c5c5c, W_BACK
      beq $t8, 0x9e9e9e, W_BACK
      j ROTATION_COLLISION
      
ROTATION_COLLISION_THREE_CASE_ONE:
	addi $t7, $a0, -ADDROW
      lw $t8, -ADDCOL($a0)
      beq $t8, 0x5c5c5c, ROTATION_COLLISION_THREE_CASE_TWO
      beq $t8, 0x9e9e9e, ROTATION_COLLISION_THREE_CASE_TWO
      j ROTATION_COLLISION
     
ROTATION_COLLISION_THREE_CASE_TWO:
      lw $t8, ADD2COL($a0)
      beq $t8, 0x5c5c5c, ROTATION_COLLISION_THREE_CASE_THREE
      beq $t8, 0x9e9e9e, ROTATION_COLLISION_THREE_CASE_THREE
      j ROTATION_COLLISION
      
ROTATION_COLLISION_THREE_CASE_THREE:
      lw $t8, ADDCOL($a0)
      beq $t8, 0x5c5c5c, W_BACK
      beq $t8, 0x9e9e9e, W_BACK
      j ROTATION_COLLISION
      
ROTATION_COLLISION:
      j game_loop
       
	
A_PRESSED:
	addi $a0, $a0, -ADDCOL
	beq $a1, 0, LEFT_COLLISION_ZERO
	beq $a1, 2, LEFT_COLLISION_TWO
	beq $a1, 1, LEFT_COLLISION_ONE_CASE_ONE
	beq $a1, 3, LEFT_COLLISION_THREE_CASE_ONE
	
A_BACK:
	add $a2, $zero, $zero
	jal drawLineBlock
	j KEY_RETURN
	
LEFT_COLLISION_TWO:
      lw $t8, -ADD2COL($a0)
      beq $t8, 0x5c5c5c, A_BACK
      beq $t8, 0x9e9e9e, A_BACK
      j LEFT_COLLISION
	
LEFT_COLLISION_ZERO:
      lw $t8, -ADDCOL($a0)
      beq $t8, 0x5c5c5c, A_BACK
      beq $t8, 0x9e9e9e, A_BACK
      j LEFT_COLLISION
      
LEFT_COLLISION_ONE_CASE_ONE:
      lw $t8, -ADDROW($a0)
      beq $t8, 0x5c5c5c, LEFT_COLLISION_ONE_CASE_TWO
      beq $t8, 0x9e9e9e, LEFT_COLLISION_ONE_CASE_TWO
      j LEFT_COLLISION
      
LEFT_COLLISION_ONE_CASE_TWO:
      lw $t8, ($a0)
      beq $t8, 0x5c5c5c, LEFT_COLLISION_ONE_CASE_THREE
      beq $t8, 0x9e9e9e, LEFT_COLLISION_ONE_CASE_THREE
      j LEFT_COLLISION
      
LEFT_COLLISION_ONE_CASE_THREE:
      lw $t8, ADDROW($a0)
      beq $t8, 0x5c5c5c, LEFT_COLLISION_ONE_CASE_FOUR
      beq $t8, 0x9e9e9e, LEFT_COLLISION_ONE_CASE_FOUR
      j LEFT_COLLISION

LEFT_COLLISION_ONE_CASE_FOUR:
      lw $t8, ADD2ROW($a0)
      beq $t8, 0x5c5c5c, A_BACK
      beq $t8, 0x9e9e9e, A_BACK
      j LEFT_COLLISION
      
LEFT_COLLISION_THREE_CASE_ONE:
      lw $t8, -ADD2ROW($a0)
      beq $t8, 0x5c5c5c, LEFT_COLLISION_THREE_CASE_TWO
      beq $t8, 0x9e9e9e, LEFT_COLLISION_THREE_CASE_TWO
      j LEFT_COLLISION
      
LEFT_COLLISION_THREE_CASE_TWO:
      lw $t8, -ADDROW($a0)
      beq $t8, 0x5c5c5c, LEFT_COLLISION_THREE_CASE_THREE
      beq $t8, 0x9e9e9e, LEFT_COLLISION_THREE_CASE_THREE
      j LEFT_COLLISION
      
LEFT_COLLISION_THREE_CASE_THREE:
      lw $t8, ($a0)
      beq $t8, 0x5c5c5c, LEFT_COLLISION_THREE_CASE_FOUR
      beq $t8, 0x9e9e9e, LEFT_COLLISION_THREE_CASE_FOUR
      j LEFT_COLLISION

LEFT_COLLISION_THREE_CASE_FOUR:
      lw $t8, ADDROW($a0)
      beq $t8, 0x5c5c5c, A_BACK
      beq $t8, 0x9e9e9e, A_BACK
      j LEFT_COLLISION
	
LEFT_COLLISION:
       addi $a0, $a0, ADDCOL
       j game_loop
	
S_PRESSED:
        addi $a0, $a0, ADDROW
        beq $a1, 0, DOWN_COLLISION_ZERO_CASE_ONE
        beq $a1, 1, DOWN_COLLISION_ONE
        beq $a1, 2, DOWN_COLLISION_TWO_CASE_ONE
        beq $a1, 3, DOWN_COLLISION_THREE
        
S_BACK:
	add $a2, $zero, $zero
	jal drawLineBlock
	j KEY_RETURN
	
DOWN_COLLISION_ZERO_CASE_ONE:
	lw $t8, -ADDCOL($a0)
        beq $t8, 0x5c5c5c, DOWN_COLLISION_ZERO_CASE_TWO
        beq $t8, 0x9e9e9e, DOWN_COLLISION_ZERO_CASE_TWO
        j DOWN_COLLISION 
        
DOWN_COLLISION_ZERO_CASE_TWO:
	lw $t8, 0($a0)
        beq $t8, 0x5c5c5c, DOWN_COLLISION_ZERO_CASE_THREE
        beq $t8, 0x9e9e9e, DOWN_COLLISION_ZERO_CASE_THREE
        j DOWN_COLLISION 
        
DOWN_COLLISION_ZERO_CASE_THREE:
	lw $t8, ADDCOL($a0)
        beq $t8, 0x5c5c5c, DOWN_COLLISION_ZERO_CASE_FOUR
        beq $t8, 0x9e9e9e, DOWN_COLLISION_ZERO_CASE_FOUR
        j DOWN_COLLISION 
        
DOWN_COLLISION_ZERO_CASE_FOUR:
        lw $t8, ADD2COL($a0)
        beq $t8, 0x5c5c5c, S_BACK
        beq $t8, 0x9e9e9e, S_BACK
        j DOWN_COLLISION 
        
DOWN_COLLISION_TWO_CASE_ONE:
	lw $t8, -ADD2COL($a0)
        beq $t8, 0x5c5c5c, DOWN_COLLISION_TWO_CASE_TWO
        beq $t8, 0x9e9e9e, DOWN_COLLISION_TWO_CASE_TWO
        j DOWN_COLLISION 
        
DOWN_COLLISION_TWO_CASE_TWO:
	lw $t8, -ADDCOL($a0)
        beq $t8, 0x5c5c5c, DOWN_COLLISION_TWO_CASE_THREE
        beq $t8, 0x9e9e9e, DOWN_COLLISION_TWO_CASE_THREE
        j DOWN_COLLISION 
        
DOWN_COLLISION_TWO_CASE_THREE:
	lw $t8, 0($a0)
        beq $t8, 0x5c5c5c, DOWN_COLLISION_TWO_CASE_FOUR
        beq $t8, 0x9e9e9e, DOWN_COLLISION_TWO_CASE_FOUR
        j DOWN_COLLISION 
        
DOWN_COLLISION_TWO_CASE_FOUR:
        lw $t8, ADDCOL($a0)
        beq $t8, 0x5c5c5c, S_BACK
        beq $t8, 0x9e9e9e, S_BACK
        j DOWN_COLLISION 
        
DOWN_COLLISION_ONE:
        lw $t8, ADD2ROW($a0)
        beq $t8, 0x5c5c5c, S_BACK
        beq $t8, 0x9e9e9e, S_BACK
        j DOWN_COLLISION  
        
DOWN_COLLISION_THREE:
        lw $t8, ADDROW($a0)
        beq $t8, 0x5c5c5c, S_BACK
        beq $t8, 0x9e9e9e, S_BACK
        j DOWN_COLLISION 
        
DOWN_COLLISION:
        add $s0, $a0, $zero
        add $s1, $a1, $zero
        add $s2, $a2, $zero
        add $s3, $a3, $zero
        li $a0, 72 #pitch
        li $a1, 1000 #1000 ms = 1s
        li $a2, 127 #brass
        li $a3, 100 #volume = 100
        li $v0, 31
        syscall
        add $a0, $s0, $zero
        add $a1, $s1, $zero
        add $a2, $s2, $zero
        add $a3, $s3, $zero
	addi $a0, $a0, -ADDROW
	addi $a3, $a3, 16	# a3 stores number of placed pixels * 4
	jal LINE_BLOCK_SAVE
	jal CHECK_ROWS
        addi $a0, $s6, ORIGIN
	li $a1, 0
	add $a2, $zero, $zero
CHECK_GAME_OVER:
	lw $t0, -ADDCOL($a0)
	beq $t0, 0xff0000, GAME_OVER
	lw $t0, 0($a0)
	beq $t0, 0xff0000, GAME_OVER
	lw $t0, ADDCOL($a0)
	beq $t0, 0xff0000, GAME_OVER
	lw $t0, ADD2COL($a0)
	beq $t0, 0xff0000, GAME_OVER
	
	jal drawLineBlock
	j game_loop
	
GAME_OVER:
        add $s0, $a0, $zero
        add $s1, $a1, $zero
        add $s2, $a2, $zero
        add $s3, $a3, $zero
        li $a0, 70 #pitch=A#
        li $a1, 1000 #1000 ms = 1s
        li $a2, 33 #bass
        li $a3, 100 #volume = 100
        li $v0, 31
        syscall
        add $a0, $s0, $zero
        add $a1, $s1, $zero
        add $a2, $s2, $zero
        add $a3, $s3, $zero

       	la $t0, ADDR_DSPL
       	lw $t0, 0($t0)
       	li $t1, 0x00ff00
       	
       	#G
       	sw $t1 24($t0)
       	sw $t1 28($t0)
       	sw $t1 32($t0)
       	sw $t1 36($t0)
       	sw $t1 152($t0)
       	sw $t1 280($t0)
       	sw $t1 408($t0)
       	sw $t1 536($t0)
       	sw $t1 664($t0)
       	sw $t1 668($t0)
       	sw $t1 672($t0)
       	sw $t1 676($t0)
       	sw $t1 548($t0)
       	sw $t1 420($t0)
       	sw $t1 416($t0)
       	
       	#A
       	sw $t1 44($t0)
       	sw $t1 48($t0)
       	sw $t1 52($t0)
       	sw $t1 56($t0)
       	sw $t1 172($t0)
       	sw $t1 300($t0)
       	sw $t1 428($t0)
       	sw $t1 556($t0)
       	sw $t1 684($t0)
       	sw $t1 184($t0)
       	sw $t1 312($t0)
       	sw $t1 440($t0)
       	sw $t1 568($t0)
       	sw $t1 696($t0)
       	sw $t1 304($t0)
       	sw $t1 308($t0)
       	
       	#M
       	sw $t1 68($t0)
       	sw $t1 76($t0)
       	sw $t1 192($t0)
       	sw $t1 320($t0)
       	sw $t1 448($t0)
       	sw $t1 576($t0)
       	sw $t1 704($t0)
       	sw $t1 200($t0)
       	sw $t1 328($t0)
       	sw $t1 456($t0)
       	sw $t1 584($t0)
       	sw $t1 712($t0)
       	sw $t1 208($t0)
       	sw $t1 336($t0)
       	sw $t1 464($t0)
       	sw $t1 592($t0)
       	sw $t1 720($t0)
       	
       	#E
       	sw $t1 88($t0)
       	sw $t1 92($t0)
       	sw $t1 96($t0)
       	sw $t1 100($t0)
       	sw $t1 216($t0)
       	sw $t1 344($t0)
       	sw $t1 348($t0)
       	sw $t1 352($t0)
       	sw $t1 356($t0)
       	sw $t1 472($t0)
       	sw $t1 600($t0)
       	sw $t1 728($t0)
       	sw $t1 732($t0)
       	sw $t1 736($t0)
       	sw $t1 740($t0)
       	
       	#O
       	sw $t1 920($t0)
       	sw $t1 924($t0)
       	sw $t1 928($t0)
       	sw $t1 932($t0)
       	sw $t1 1048($t0)
       	sw $t1 1176($t0)
       	sw $t1 1304($t0)
       	sw $t1 1432($t0)
       	sw $t1 1560($t0)
       	sw $t1 1564($t0)
       	sw $t1 1568($t0)
       	sw $t1 1572($t0)
       	sw $t1 1444($t0)
       	sw $t1 1316($t0)
       	sw $t1 1188($t0)
       	sw $t1 1060($t0)
       	
       	#V
       	sw $t1 940($t0)
       	sw $t1 1068($t0)
       	sw $t1 1196($t0)
       	sw $t1 1328($t0)
       	sw $t1 1456($t0)
       	sw $t1 1588($t0)
       	sw $t1 1464($t0)
       	sw $t1 1336($t0)
       	sw $t1 1212($t0)
       	sw $t1 1084($t0)
       	sw $t1 956($t0)
       	
       	#E
       	sw $t1 964($t0)
       	sw $t1 968($t0)
       	sw $t1 972($t0)
       	sw $t1 976($t0)
       	sw $t1 1092($t0)
       	sw $t1 1220($t0)
       	sw $t1 1348($t0)
       	sw $t1 1476($t0)
       	sw $t1 1604($t0)
       	sw $t1 1224($t0)
       	sw $t1 1228($t0)
       	sw $t1 1232($t0)
       	sw $t1 1608($t0)
       	sw $t1 1612($t0)
       	sw $t1 1616($t0)
       	
       	#R
       	sw $t1 984($t0)
       	sw $t1 988($t0)
       	sw $t1 992($t0)
       	sw $t1 996($t0)
       	sw $t1 1112($t0)
       	sw $t1 1240($t0)
       	sw $t1 1368($t0)
       	sw $t1 1496($t0)
       	sw $t1 1624($t0)
       	sw $t1 1128($t0)
       	sw $t1 1252($t0)
       	sw $t1 1248($t0)
       	sw $t1 1244($t0)
       	sw $t1 1376($t0)
       	sw $t1 1508($t0)
       	sw $t1 1640($t0)
       	
       	j GAME_OVER_LOOP
       	
GAME_OVER_LOOP:
      	li $t9,0xffff0000
      	lw $t8, 0($t9)
      	beq $t8, 1, CHECK_RETRY
      	j GAME_OVER_LOOP
      	
CHECK_RETRY:
     	lw $t8, 4($t9)
     	beq $t8, 0x72, RETRY
     	j GAME_OVER_LOOP
     	
RETRY:
	li $t1, 0x000000
	#G
       	sw $t1 24($t0)
       	sw $t1 28($t0)
       	sw $t1 32($t0)
       	sw $t1 36($t0)
       	sw $t1 152($t0)
       	sw $t1 280($t0)
       	sw $t1 408($t0)
       	sw $t1 536($t0)
       	sw $t1 664($t0)
       	sw $t1 668($t0)
       	sw $t1 672($t0)
       	sw $t1 676($t0)
       	sw $t1 548($t0)
       	sw $t1 420($t0)
       	sw $t1 416($t0)
       	
       	#A
       	sw $t1 44($t0)
       	sw $t1 48($t0)
       	sw $t1 52($t0)
       	sw $t1 56($t0)
       	sw $t1 172($t0)
       	sw $t1 300($t0)
       	sw $t1 428($t0)
       	sw $t1 556($t0)
       	sw $t1 684($t0)
       	sw $t1 184($t0)
       	sw $t1 312($t0)
       	sw $t1 440($t0)
       	sw $t1 568($t0)
       	sw $t1 696($t0)
       	sw $t1 304($t0)
       	sw $t1 308($t0)
       	
       	#M
       	sw $t1 68($t0)
       	sw $t1 76($t0)
       	sw $t1 192($t0)
       	sw $t1 320($t0)
       	sw $t1 448($t0)
       	sw $t1 576($t0)
       	sw $t1 704($t0)
       	sw $t1 200($t0)
       	sw $t1 328($t0)
       	sw $t1 456($t0)
       	sw $t1 584($t0)
       	sw $t1 712($t0)
       	sw $t1 208($t0)
       	sw $t1 336($t0)
       	sw $t1 464($t0)
       	sw $t1 592($t0)
       	sw $t1 720($t0)
       	
       	#E
       	sw $t1 88($t0)
       	sw $t1 92($t0)
       	sw $t1 96($t0)
       	sw $t1 100($t0)
       	sw $t1 216($t0)
       	sw $t1 344($t0)
       	sw $t1 348($t0)
       	sw $t1 352($t0)
       	sw $t1 356($t0)
       	sw $t1 472($t0)
       	sw $t1 600($t0)
       	sw $t1 728($t0)
       	sw $t1 732($t0)
       	sw $t1 736($t0)
       	sw $t1 740($t0)
       	
       	#O
       	sw $t1 920($t0)
       	sw $t1 924($t0)
       	sw $t1 928($t0)
       	sw $t1 932($t0)
       	sw $t1 1048($t0)
       	sw $t1 1176($t0)
       	sw $t1 1304($t0)
       	sw $t1 1432($t0)
       	sw $t1 1560($t0)
       	sw $t1 1564($t0)
       	sw $t1 1568($t0)
       	sw $t1 1572($t0)
       	sw $t1 1444($t0)
       	sw $t1 1316($t0)
       	sw $t1 1188($t0)
       	sw $t1 1060($t0)
       	
       	#V
       	sw $t1 940($t0)
       	sw $t1 1068($t0)
       	sw $t1 1196($t0)
       	sw $t1 1328($t0)
       	sw $t1 1456($t0)
       	sw $t1 1588($t0)
       	sw $t1 1464($t0)
       	sw $t1 1336($t0)
       	sw $t1 1212($t0)
       	sw $t1 1084($t0)
       	sw $t1 956($t0)
       	
       	#E
       	sw $t1 964($t0)
       	sw $t1 968($t0)
       	sw $t1 972($t0)
       	sw $t1 976($t0)
       	sw $t1 1092($t0)
       	sw $t1 1220($t0)
       	sw $t1 1348($t0)
       	sw $t1 1476($t0)
       	sw $t1 1604($t0)
       	sw $t1 1224($t0)
       	sw $t1 1228($t0)
       	sw $t1 1232($t0)
       	sw $t1 1608($t0)
       	sw $t1 1612($t0)
       	sw $t1 1616($t0)
       	
       	#R
       	sw $t1 984($t0)
       	sw $t1 988($t0)
       	sw $t1 992($t0)
       	sw $t1 996($t0)
       	sw $t1 1112($t0)
       	sw $t1 1240($t0)
       	sw $t1 1368($t0)
       	sw $t1 1496($t0)
       	sw $t1 1624($t0)
       	sw $t1 1128($t0)
       	sw $t1 1252($t0)
       	sw $t1 1248($t0)
       	sw $t1 1244($t0)
       	sw $t1 1376($t0)
       	sw $t1 1508($t0)
       	sw $t1 1640($t0)
       	j main

CHECK_ROWS:
	li $t0, 0
LOOP_ROWS:
	bge $t0, 18, DONE_CHECK
	li $t1, 0
LOOP_COLS:
	bge $t1, 10, CLEAR_ROW
	mul $t3, $t0, 40	# row incr val
	sll $t4, $t1, 2		# col incr val
	la $t9, PLACED_BLOCK_DATA
	add $t5, $t3, $t4
	add $t6, $t5, $t9
	lw $t8, 0($t6)
	beq $t8, 0, NEXT_ROW
        addi $t1, $t1, 1
        j LOOP_COLS
        
CLEAR_ROW:
	# save all values to stack, as we will be re-looping using same initial values
	li $t1, 0
	move $s5, $t0
	addi $sp, $sp, -44
	sw $t9, 0($sp)
	sw $t8, 4($sp)
	sw $t7, 8($sp)
	sw $t6, 12($sp)
	sw $t5, 16($sp)
	sw $t4, 20($sp)
	sw $t3, 24($sp)
	sw $t2, 28($sp)
	sw $t1, 32($sp)
	sw $t0, 36($sp)
	sw $ra, 40($sp)
	li $a3, 1
LOOP_WHITE_ROW:
	li $t2, 0xffffff
 	bge $t1, 10, WRITE_CLEAR_ROW
 	sll $t4, $t1, 2
 	add $t5, $t3, $t4
 	add $t6, $t5, $t9
 	sw $t2 0($t6)
 	addi $t1, $t1, 1
 	j LOOP_WHITE_ROW

WRITE_CLEAR_ROW:
	li $a3, 1
	jal drawLineBlock
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $a1, 0($sp)
	li $v0, 32
	li $a0, 1000
	syscall
	lw $a1, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	lw $t9, 0($sp)
	lw $t8, 4($sp)
	lw $t7, 8($sp)
	lw $t6, 12($sp)
	lw $t5, 16($sp)
	lw $t4, 20($sp)
	lw $t3, 24($sp)
	lw $t2, 28($sp)
	lw $t1, 32($sp)
	lw $t0, 36($sp)
	lw $ra, 40($sp)
	addi $sp, $sp, 44
LOOP_CLEAR_ROW:
 	bge $t1, 10, GRAVITY_CLEAR_LOOP_ROWS
 	sll $t4, $t1, 2
 	add $t5, $t3, $t4	# t5 = row incr + col incr
 	add $t6, $t5, $t9	# t6 = t5 + start addr
 	sw $zero 0($t6)
 	addi $t1, $t1, 1
 	j LOOP_CLEAR_ROW

GRAVITY_CLEAR_LOOP_ROWS:
	li $a3, 0
	ble $s5, 0, NEXT_ROW
	li $t1, 0
GRAVITY_CLEAR_LOOP_COLS:
	bge $t1, 10, GRAVITY_CLEAR_NEXT_ROW 
	mul $t2, $s5, 40
	add $t2, $t9, $t2
	sll $t4, $t1, 2
	add $t2, $t2, $t4	# t2 = current position
	lw $t7, -40($t2)
	sw $t7, ($t2)
	addi $t1, $t1, 1
	j GRAVITY_CLEAR_LOOP_COLS

GRAVITY_CLEAR_NEXT_ROW:
	addi $s5, $s5, -1
	j GRAVITY_CLEAR_LOOP_ROWS
	
	
NEXT_ROW:
	addi $t0, $t0, 1
	j LOOP_ROWS
	
DONE_GRAVITY:
	
	
DONE_CHECK:
	jr $ra
        
D_PRESSED:
	addi $a0, $a0, ADDCOL
	beq $a1, 0, RIGHT_COLLISION_ZERO
	beq $a1, 2, RIGHT_COLLISION_TWO
	beq $a1, 1, RIGHT_COLLISION_ONE_CASE_ONE
	beq $a1, 3, RIGHT_COLLISION_THREE_CASE_ONE
	
D_BACK:
	add $a2, $zero, $zero
	jal drawLineBlock
	j KEY_RETURN
	
RIGHT_COLLISION_TWO:
      lw $t8, ADDCOL($a0)
      beq $t8, 0x5c5c5c, D_BACK
      beq $t8, 0x9e9e9e, D_BACK
      j RIGHT_COLLISION
	
RIGHT_COLLISION_ZERO:
      lw $t8, ADD2COL($a0)
      beq $t8, 0x5c5c5c, D_BACK
      beq $t8, 0x9e9e9e, D_BACK
      j RIGHT_COLLISION
      
RIGHT_COLLISION_ONE_CASE_ONE:
      lw $t8, -ADDROW($a0)
      beq $t8, 0x5c5c5c, RIGHT_COLLISION_ONE_CASE_TWO
      beq $t8, 0x9e9e9e, RIGHT_COLLISION_ONE_CASE_TWO
      j RIGHT_COLLISION
      
RIGHT_COLLISION_ONE_CASE_TWO:
      lw $t8, ($a0)
      beq $t8, 0x5c5c5c, RIGHT_COLLISION_ONE_CASE_THREE
      beq $t8, 0x9e9e9e, RIGHT_COLLISION_ONE_CASE_THREE
      j RIGHT_COLLISION
      
RIGHT_COLLISION_ONE_CASE_THREE:
      lw $t8, ADDROW($a0)
      beq $t8, 0x5c5c5c, RIGHT_COLLISION_ONE_CASE_FOUR
      beq $t8, 0x9e9e9e, RIGHT_COLLISION_ONE_CASE_FOUR
      j RIGHT_COLLISION

RIGHT_COLLISION_ONE_CASE_FOUR:
      lw $t8, ADD2ROW($a0)
      beq $t8, 0x5c5c5c, D_BACK
      beq $t8, 0x9e9e9e, D_BACK
      j RIGHT_COLLISION
      
RIGHT_COLLISION_THREE_CASE_ONE:
      lw $t8, -ADD2ROW($a0)
      beq $t8, 0x5c5c5c, RIGHT_COLLISION_THREE_CASE_TWO
      beq $t8, 0x9e9e9e, RIGHT_COLLISION_THREE_CASE_TWO
      j RIGHT_COLLISION
      
RIGHT_COLLISION_THREE_CASE_TWO:
      lw $t8, -ADDROW($a0)
      beq $t8, 0x5c5c5c, RIGHT_COLLISION_THREE_CASE_THREE
      beq $t8, 0x9e9e9e, RIGHT_COLLISION_THREE_CASE_THREE
      j RIGHT_COLLISION
      
RIGHT_COLLISION_THREE_CASE_THREE:
      lw $t8, ($a0)
      beq $t8, 0x5c5c5c, RIGHT_COLLISION_THREE_CASE_FOUR
      beq $t8, 0x9e9e9e, RIGHT_COLLISION_THREE_CASE_FOUR
      j RIGHT_COLLISION

RIGHT_COLLISION_THREE_CASE_FOUR:
      lw $t8, ADDROW($a0)
      beq $t8, 0x5c5c5c, D_BACK
      beq $t8, 0x9e9e9e, D_BACK
      j RIGHT_COLLISION
	
RIGHT_COLLISION:
       addi $a0, $a0, -ADDCOL
       j game_loop

END:	
	li $v0, 10
	syscall

# a0: position of centre
# a1: clockwise rotation / 90 degrees
# a2: just rotated
# v0: return new position
# *NOTE: The addition/subtraction to the $t1 value is known as "offset" of rotation from phase n-1 to phase n, since our centre of rotation is asymmetric.
drawLineBlock: 	# Draws the line block, returns position of centre
	move $s7, $ra
	jal drawBoard
	
	la $t9, PLACED_BLOCK_DATA
	addi $t8, $t9, 720
PLACED_BLOCK_LOOP:
	bge $t9, $t8, LINE_BLOCK_NO_FILL
	lw $t0, 0($t9)
	beq $t0, 0, SKIP
	sub $t1, $t8, $t9
	addi $t1, $t1, -4
	li $t2, 40
	div $t1, $t2
	mflo $t3
	mfhi $t4
	li $t5, ADDROW
	move $t6, $s6
	addi $t6, $t6, STARTROW
	addi $t6, $t6, STARTCOL
	sub $t6, $t6, $t4
	addi $t6, $t6, 36	# 10 * 4
	mult $t3, $t5
	mflo $t3
	sub $t6, $t6, $t3
	addi $t6, $t6, 2432	# 19 * 128
	
	sw $t0, 0($t6)
SKIP:
	addi $t9, $t9, 4
	j PLACED_BLOCK_LOOP
	
LINE_BLOCK_NO_FILL:
	beq $a3, 1, LINEDONE
	move $t1, $a0
	li $t3, 0xff0000
	move $t2, $a1
	
	beq $t2, $zero, LINEZERO
	addi $t2, $t2, -1 	# shift one
	beq $t2, $zero, LINEONE
	addi $t2, $t2, -1 	# shift one
	beq $t2, $zero, LINETWO
	
	beq $a2, $zero, NOROTTHREE	# If we didn't rotate, skip the offset
	addi $t1, $t1, -ADDCOL
NOROTTHREE:
	sw $t3, -ADD2ROW($t1)
	sw $t3, -ADDROW($t1)
	sw $t3, 0($t1)
	sw $t3, ADDROW($t1)
	j LINEDONE
	
LINEZERO:
	beq $a2, $zero, NOROTZERO	# If we didn't rotate, skip the offset
	addi $t1, $t1, -ADDROW
NOROTZERO:
	sw $t3, -ADDCOL($t1)
	sw $t3, 0($t1)
	sw $t3, ADDCOL($t1)
	sw $t3, ADD2COL($t1)
	j LINEDONE
	
LINEONE:
	beq $a2, $zero, NOROTONE
	addi $t1, $t1, ADDCOL
NOROTONE:
	sw $t3, -ADDROW($t1)
	sw $t3, 0($t1)
	sw $t3, ADDROW($t1)
	sw $t3, ADD2ROW($t1)
	j LINEDONE
	
LINETWO:
	beq $a2, $zero, NOROTTWO
	addi $t1, $t1, ADDROW
NOROTTWO:
	sw $t3, -ADD2COL($t1)
	sw $t3, -ADDCOL($t1)
	sw $t3, 0($t1)
	sw $t3, ADDCOL($t1)
	
LINEDONE:
	move $v0, $t1
	# lw $ra, 0($sp)
	# addi $sp, $sp, 4
	move $ra, $s7
	jr $ra

# Saves the placed block
LINE_BLOCK_SAVE:
	sub $t0, $a0, $s6
	addi $t0, $t0, -STARTROW
	addi $t0, $t0, -STARTCOL
	li $t1, ADDROW
	div $t0, $t1
	mflo $t2
	mfhi $t3
	addi $t2, $t2, -2
	la $t9, PLACED_BLOCK_DATA
	move $t4, $t9
	li $t5, 40
	mult $t2, $t5
	mflo $t2
	add $t4, $t4, $t2
	add $t4, $t4, $t3
	li $t6, 0xff0000
	sw $t6, 0($t4)

	beq $a1, 0, SAVE_LINE_ZERO
	beq $a1, 1, SAVE_LINE_ONE
	beq $a1, 2, SAVE_LINE_TWO
	j SAVE_LINE_THREE

SAVE_LINE_ZERO:
	sw $t6, -4($t4)
	sw $t6, 4($t4)
	sw $t6, 8($t4)
	jr $ra

SAVE_LINE_ONE:
	sw $t6, -40($t4)
	sw $t6, 40($t4)
	sw $t6, 80($t4)
	jr $ra

SAVE_LINE_TWO:
	sw $t6, -8($t4)
	sw $t6, -4($t4)
	sw $t6, 4($t4)
	jr $ra

SAVE_LINE_THREE:
	sw $t6, -80($t4)
	sw $t6, -40($t4)
	sw $t6, 40($t4)
	jr $ra


drawBoard:
	li $t1, 0x5c5c5c
	li $t2, 0x9e9e9e
	li $t9, STARTROW	 	
	li $t7, ENDROW
	li $t6, ENDCOL
loopDark1:
	li $t8, STARTCOL
	add $t5, $s6, $t9
nestedLoopDark1:
	add $t4, $t5, $t8
	sw $t1, 0($t4)
	addi $t8, $t8, ADD2COL
	ble $t8, $t6, nestedLoopDark1
	
	addi $t9, $t9, ADD2ROW
	ble $t9, $t7, loopDark1
	
	li $t9, STARTROW
	addi $t9, $t9, ADDROW	# offset 1 row
loopDark2:
	li $t8, STARTCOL
	addi $t8, $t8, ADDCOL	# offset 1 square
	add $t5, $s6, $t9
nestedLoopDark2:
	add $t4, $t5, $t8
	sw $t1, 0($t4)
	addi $t8, $t8, ADD2COL
	ble $t8, $t6, nestedLoopDark2
	
	addi $t9, $t9, ADD2ROW
	ble $t9, $t7, loopDark2
	
	li $t9, STARTROW
loopLight1:
	li $t8, STARTCOL
	addi $t8, $t8, ADDCOL	# offset 1 square
	add $t5, $s6, $t9
nestedLoopLight1:
	add $t4, $t5, $t8
	sw $t2, 0($t4)
	addi $t8, $t8, ADD2COL
	ble $t8, $t6, nestedLoopLight1
	
	addi $t9, $t9, ADD2ROW
	ble $t9, $t7, loopLight1
	
	li $t9, STARTROW
	addi $t9, $t9, ADDROW	# offset 1 row
loopLight2:
	li $t8, STARTCOL
	add $t5, $s6, $t9
nestedLoopLight2:
	add $t4, $t5, $t8
	sw $t2, 0($t4)
	addi $t8, $t8, ADD2COL
	ble $t8, $t6, nestedLoopLight2
	
	addi $t9, $t9, ADD2ROW
	ble $t9, $t7, loopLight2
	
	li $t1, 0x000000
	li $t8, STARTCOL
	li $t9, STARTROW
	addi $t9, $t9, -ADDROW
	add $t5, $s6, $t9
blackLine:
	add $t4, $t5, $t8
	sw $t1, 0($t4)
	addi $t8, $t8, ADDCOL
	ble $t8, $t6, blackLine
	
	jr $ra
	
	
	
