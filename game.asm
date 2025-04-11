#####################################################################
#
# CSCB58 Winter 2025 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Wanlin Zhang, 1007786861, zha10939, wanlin.zhang@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestoneshave been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. shoot enemies
# 2. moving objects
# 3. title screen
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#######################################






# Bitmap display starter code
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.eqv BASE_ADDRESS 0x10008000
.data
#player Data
x: .word 28
y: .word 23
vy: .word 0 #vertical velocity
gravity: .word 1 
bulx: .word -1 # -1 = inactive
buly: .word 0
bulactive: .word 0
score: .word 0
#enemy data
enemyx: .word 0
enemyy: .word 6
enemydir: .word 1
#bg data
ground_level: .word 30
# Platform 1: x = 4 to 9 y = 22
plat1_x_start: .word 4
plat1_x_end:   .word 9
plat1_y:       .word 22
# Platform 2: x = 20 to 25, y = 22
plat2_x_start: .word 20
plat2_x_end:   .word 25
plat2_y:       .word 22
onplat: .word 0
UFOX: .word 0

startx: .word 6
starty: .word 16

exitx: .word 6
exity: .word 24

.text

main:
	li $t0, BASE_ADDRESS # $t0 stores the base address for Display
	li $t4, 1024
	
	jal startscreen
	
	
startloop:
	jal DrawPlayer
	li $t0, 0xFFFF0000
wait_key:
    	lw $t1, 0($t0)
    	andi $t1, $t1, 1
    	beqz $t1, wait_key

    	li $t0, 0xFFFF0004
    	lw $t5, 0($t0)       # ASCII key

    	jal ErasePlayert
	lw $a0, x
	lw $a1, y
	
    	li $t3, 119          # 'w'
    	beq $t5, $t3, move_u

    	li $t3, 115          # 's'
    	beq $t5, $t3, move_d

    	li $t3, 97           # 'a'
    	beq $t5, $t3, move_l

    	li $t3, 100          # 'd'
    	beq $t5, $t3, move_r
   
    	li $t3, 32          # 'space'
    	beq $t5, $t3, selopt

    	j redrawcur

move_u:
    	addi $a1, $a1, -1
    	j redrawcur

move_d:
    	addi $a1, $a1, 1
    	j redrawcur

move_l:
   	addi $a0, $a0, -1
    	j redrawcur

move_r:
    	addi $a0, $a0, 1
    	j redrawcur

selopt:
	#20 x 7
	lw $t1, starty
	lw $t0, startx
	#check y
	ble $a1, $t1, notstart
	addi $t1, $t1, 7
	bge $a1, $t1, notstart
	#check x
	ble $a0, $t0, notstart
	addi $t0, $t0, 20
	bge $a0, $t0, notstart
	
	li $t0, BASE_ADDRESS # $t0 stores the base address for Display
	li $t4, 1024
	j DrawSky
notstart:
	lw $t1, exity
	lw $t0, exitx
	#check y
	ble $a1, $t1, notexit
	addi $t1, $t1, 7
	bge $a1, $t1, notexit
	#check x
	ble $a0, $t0, notexit
	addi $t0, $t0, 20
	bge $a0, $t0, notexit
	
	j quit
notexit:
redrawcur:
    	sw $a0, x
    	sw $a1, y
    	jal DrawPlayer
    	j startloop
	
	
DrawSky:
	li $t9, 0x9fd3f3 # store sky colour	
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 64, DrawSky  # If counter != 3 rows from bottom, repeat the loop

DrawGround:
	li $t9, 0x955113
	sw $t9, 0($t0)
	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
	bne $t4, 0, DrawGround  # bottom
	
DrawPit:
	li $t9, 0x9fd3f3 # store sky colour	
	li $t0, BASE_ADDRESS # $t0 stores the base address for Display
	addi $t0, $t0, 3840
	sw $t9, 56($t0)        
    	sw $t9, 60($t0)
    	sw $t9, 64($t0)
    	sw $t9, 68($t0)
    	addi $t0, $t0, 128
	sw $t9, 56($t0)        
    	sw $t9, 60($t0)
    	sw $t9, 64($t0)
    	sw $t9, 68($t0)
	
#init stats
	li $t0, 0
	sw $t0, score
	jal InitScore	
	jal UpdateScore
	li $t0, BASE_ADDRESS # $t0 stores the base address for Display
	li $t4, 1024	

#init starting pos
	li $a0, 6 #x
	li $a1, 28 #y
	

#loop to draw things ###########################################################################
main_loop:
	
	#save player position
	sw $a0, x #x
	sw $a1, y #y
	#draw platforms
	li $a0, 4
	li $a1, 22
	jal DrawPlat
	li $a0, 20
	li $a1, 22
	jal DrawPlat
	li $a0, 0
	li $a1, 0
	#draw enemu
	jal UpdateUFO
	#draw player stuff
	lw $a1, score
	beq $a1,3, win
	jal DrawPlayer
	jal UpdateBullet
	
wait_for_key:
    	
    	li $t0, 0xFFFF0000      # KBD_CTRL
    	lw $t1, 0($t0)          # Load control
    	andi $t1, $t1, 1        # Check bit 0
    	
    	#frame by frame
    	beqz $t1, wait_for_key  # Wait if no key
	# clocked
	#li $v0, 32 
	#li $a0, 100 # Wait (60 milliseconds)
	#syscall
	
    	li $t0, 0xFFFF0004      # KBD_DATA
    	lw $t5, 0($t0)          # Load key ASCII into t5

# Load position
    	lw $a0, x
    	lw $a1, y
	jal ErasePlayer
	
#gravity
# Load current y and vy
	lw $t9, x
	lw $t0, y
	lw $t1, vy
	lw $t2, gravity
	lw $t7, onplat
	# Add gravity to vy
	add $t1, $t1, $t2
	sw $t1, vy
	beq $t7, 1, gravityLogic
	bge $t1,1, falling
	j rising
falling:
	add $t0, $t0, 1
	j gravityLogic
rising:
	# Add vy to y
	add $t0, $t0, -1

gravityLogic:
	li $t8, 0 # check if land
#platform 1 
	lw $t3, plat1_y
	lw $t4, plat1_x_start
	lw $t6, plat1_x_end
	
	addi $t7, $t3, -2
	beq $t0, $t7, checkP1X
	j checkP2

		
checkP1X:
	bge $t9, $t4, p1Right
	j checkP2
p1Right:
	ble $t9, $t6, OnP1
	j checkP2
OnP1:
	move $t0, $t7
	li $t1, 0
	li $t8, 1
	j platDone
#platform 2 
checkP2:
	lw $t3, plat2_y
	lw $t4, plat2_x_start
	lw $t6, plat2_x_end
	
	addi $t7, $t3, -2
	beq $t0, $t7, checkP2X
	j platDone
	
checkP2X:
	bge $t9, $t4, p2Right
	j platDone
p2Right:
	ble $t9, $t6, OnP2
	j platDone
OnP2:
	move $t0, $t7
	li $t1, 0
	li $t8, 1

platDone:
	sw $t1, vy              # update velocity
    	sw $t0, y               # update y-position
    	sw $t8, onplat          # update platform flag (0 or 1)
	
	
# Prevent falling below ground (e.g., y >= 28)
	bgt $t0, 28, clamp_to_ground
	j skip_clamp	
	clamp_to_ground:
    	li $t0, 28        # Snap to ground
    	li $t1, 0          # Stop velocity if on ground
    	sw $t1, vy

skip_clamp:
    	sw $t0, y

    # Load position
	
 
# Check movement keys
    	li $t3, 119     # 'w'
    	beq $t5, $t3, jump
    	li $t3, 97      # 'a'
    	beq $t5, $t3, move_left
    	li $t3, 100     # 'd'
    	beq $t5, $t3, move_right
# shoot
	li $t3, 101       # 'e'
	beq $t5, $t3, shoot_bullet
#check admin keys
    	li $t3, 113     # 'q'
	beq $t5, $t3, quit
	li $t3, 114     # 'r'
	li $t0, 23
	sw $t0, x
	sw $t0, y
	beq $t5, $t3, main

	j main_loop
jump:
    	li $t4, 28
    	lw $t5, y
    	bne $t5, $t4, redraw   # Only jump if on ground

    	li $t6, -8             # Upward velocity (tweak as needed)
    	sw $t6, vy
    	j redraw
move_left:
	blt $a0, 1, main_loop
    	addi $a0, $a0, -1
    	sw $a0, x
   	j redraw
move_right:
	bgt $a0, 28, main_loop
    	addi $a0, $a0, 1
    	sw $a0, x
    	j redraw
shoot_bullet:
    	lw $t0, bulactive
    	bnez $t0, redraw        # Only one bullet at a time

    	# Get player position
   	lw $t1, x
    	lw $t2, y
	addi $t1, $t1 1
    	sw $t1, bulx
    	sw $t2, buly
    	li $t4, 1
    	sw $t4, bulactive

    	j redraw

redraw:
	lw $t0, y
	lw $t4, x
	lw $t1, vy
	lw $t2, gravity
	lw $t3, onplat
	
	add $t1, $t1, $t2     # vy += gravity
	sw $t1, vy
	beq $t3, 1, plated
	bne $t0, 28, land 
	blt $t4, 14, land
   	bgt $t4, 18, land
#pit	
	j lose
land:
	blez $t1, rise
	j fall
rise:
	add $t0, $t0, -1     # y += vy
fall:
	blez $t1, skipGrounded	
	li $t3, 28
	bgt $t0, $t3, grounded
	j skipGrounded
plated:
	li $t0, 20
    	li $t1, 0
    	sw $t1, vy
	j draw
	
grounded:
    	li $t0, 28
    	li $t1, 0
    	sw $t1, vy

skipGrounded:
    	sw $t0, y
    	
# draw player
draw:
	jal DrawPlayer
    	j main_loop


lose:
	jal endscreen
	li $v0, 32 
	li $a0, 1000 # Wait (60 milliseconds)
	syscall
	li $t5, 0
end:
	li $t0, 0xFFFF0000      # KBD_CTRL
    	lw $t1, 0($t0)          # Load control
    	andi $t1, $t1, 1        # Check bit 0
    	
    	#frame by frame
    	beqz $t1, end  # Wait if no key
	li $t0, 0xFFFF0004      # KBD_DATA
    	lw $t5, 0($t0)          # Load key ASCII into t5
	
	li $t3, 113     # 'q'
	beq $t5, $t3, quit
	li $t3, 114     # 'r'
	li $t0, 28
	sw $t0, x
	sw $t0, y
	beq $t5, $t3, main
	j quit

win:
	jal winscreen
	li $v0, 32 
	li $a0, 1000 # Wait (60 milliseconds)
	syscall
	li $t5, 0
endw:
	li $t0, 0xFFFF0000      # KBD_CTRL
    	lw $t1, 0($t0)          # Load control
    	andi $t1, $t1, 1        # Check bit 0
    	
    	#frame by frame
    	beqz $t1, endw  # Wait if no key
	li $t0, 0xFFFF0004      # KBD_DATA
    	lw $t5, 0($t0)          # Load key ASCII into t5
	
	li $t3, 113     # 'q'
	beq $t5, $t3, quit
	li $t3, 114     # 'r'
	li $t0, 28
	sw $t0, x
	sw $t0, y
	beq $t5, $t3, main
	j quit

quit:

	li $v0, 10
	syscall
	
	
	

#drawings##################################################################################################################################
startscreen:
	li $t0, BASE_ADDRESS
	li $t1, 1024
DBG1: #fill bg with black
	li $t9, 0x000000 # store black
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, DBG1  # If counter != 3 rows from bottom, repeat the loop
    	
#title
    	li $t0, BASE_ADDRESS
	li $t9, 0xffffff # store white
#A
	addi $t0, $t0, 132
    	sw $t9, 4($t0)
	sw $t9, 128($t0)
	sw $t9, 136($t0)
	sw $t9, 256($t0)
	sw $t9, 264($t0)
	sw $t9, 384($t0)
	sw $t9, 260($t0)
	sw $t9, 392($t0)
	sw $t9, 512($t0)
	sw $t9, 520($t0)
    	
# L	
    	addi $t0, $t0, 16
    	sw $t9, 0($t0)
	sw $t9, 128($t0)
	sw $t9, 256($t0)
	sw $t9, 384($t0)
	sw $t9, 512($t0)
	sw $t9, 516($t0)
	
#i	
	addi $t0, $t0, 12
	sw $t9, 0($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)
	sw $t9, 132($t0)
	sw $t9, 260($t0)
	sw $t9, 388($t0)
	sw $t9, 512($t0)
	sw $t9, 516($t0)
	sw $t9, 520($t0)
#e	
	addi $t0, $t0, 16
	sw $t9, 0($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)
	sw $t9, 128($t0)
	sw $t9, 256($t0)
	sw $t9, 260($t0)
	sw $t9, 384($t0)
	sw $t9, 512($t0)
	sw $t9, 516($t0)
	sw $t9, 520($t0)
#n
	addi $t0, $t0, 16
	sw $t9, 0($t0)
	sw $t9, 12($t0)
	sw $t9, 128($t0)
	sw $t9, 132($t0)
	sw $t9, 140($t0)
	sw $t9, 256($t0)
	sw $t9, 264($t0)
	sw $t9, 268($t0)
	sw $t9, 384($t0)
	sw $t9, 396($t0)
	sw $t9, 512($t0)
	sw $t9, 524($t0)


#p
	addi $t0, $t0, 712
	sw $t9, 0($t0)
	sw $t9, 4($t0)
	sw $t9, 128($t0)
	sw $t9, 136($t0)
	sw $t9, 256($t0)
	sw $t9, 260($t0)
	sw $t9, 384($t0)
	sw $t9, 512($t0)
#O
	addi $t0, $t0, 16
	sw $t9, 4($t0)
	sw $t9, 128($t0)
	sw $t9, 256($t0)
	sw $t9, 384($t0)
	sw $t9, 136($t0)
	sw $t9, 264($t0)
	sw $t9, 392($t0)
	sw $t9, 516($t0)
#P
	addi $t0, $t0, 16
	sw $t9, 0($t0)
	sw $t9, 4($t0)
	sw $t9, 128($t0)
	sw $t9, 136($t0)
	sw $t9, 256($t0)
	sw $t9, 260($t0)
	sw $t9, 384($t0)
	sw $t9, 512($t0)
#P
	addi $t0, $t0, 16
	sw $t9, 0($t0)
	sw $t9, 4($t0)
	sw $t9, 128($t0)
	sw $t9, 136($t0)
	sw $t9, 256($t0)
	sw $t9, 260($t0)
	sw $t9, 384($t0)
	sw $t9, 512($t0)
#E
	addi $t0, $t0, 16
	sw $t9, 0($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)
	sw $t9, 128($t0)
	sw $t9, 256($t0)
	sw $t9, 260($t0)
	sw $t9, 384($t0)
	sw $t9, 512($t0)
	sw $t9, 516($t0)
	sw $t9, 520($t0)
#R	
	addi $t0, $t0, 16
	sw $t9, 0($t0)
	sw $t9, 4($t0)
	sw $t9, 128($t0)
	sw $t9, 136($t0)
	sw $t9, 256($t0)
	sw $t9, 260($t0)
	sw $t9, 384($t0)
	sw $t9, 392($t0)
	sw $t9, 512($t0)
	sw $t9, 520($t0)
#start button
	addi $t0, $t0, 1084
	addi $t1, $t0 132 # for letters later
	li $t9, 0xa8e61d # store green
	li $t4, 19
	addi $t0, $t0, 4
G1:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, G1  # If counter != 3 rows from bottom, repeat the loop
  	addi $t0, $t0, 128
	li $t4, 21
G2:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, -4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, G2  # If counter != 3 rows from bottom, repeat the loop
	addi $t0, $t0, 132
	li $t4, 21
G3:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, G3  # If counter != 3 rows from bottom, repeat the loop
	addi $t0, $t0, 124
	li $t4, 21
G4:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, -4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, G4  # If counter != 3 rows from bottom, repeat the loop
	addi $t0, $t0, 132
	li $t4, 21
G5:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, G5  # If counter != 3 rows from bottom, repeat the loop
	li $t4, 21
	addi $t0, $t0, 124
G6:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, -4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, G6  # If counter != 3 rows from bottom, repeat the loop
	li $t4, 19
	addi $t0, $t0, 136
G7:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, G7  # If counter != 3 rows from bottom, repeat the loop
 #s
 	
	li $t9, 0x22b14c # store green
	sw $t9, 4($t1)
	sw $t9, 8($t1)
	sw $t9, 128($t1)
	sw $t9, 260($t1)
	sw $t9, 392($t1)
	sw $t9, 512($t1)
	sw $t9, 516($t1)
	#t
	addi $t1, $t1, 16
	sw $t9, 0($t1)
	sw $t9, 4($t1)
	sw $t9, 8($t1)
	sw $t9, 132($t1)
	sw $t9, 260($t1)
	sw $t9, 388($t1)
	sw $t9, 516($t1)
	#a
	addi $t1, $t1, 16
	sw $t9, 4($t1)
	sw $t9, 128($t1)
	sw $t9, 136($t1)
	sw $t9, 256($t1)
	sw $t9, 264($t1)
	sw $t9, 384($t1)
	sw $t9, 260($t1)
	sw $t9, 392($t1)
	sw $t9, 512($t1)
	sw $t9, 520($t1)
  	#r
  	addi $t1, $t1, 16
  	sw $t9, 0($t1)
	sw $t9, 4($t1)
	sw $t9, 128($t1)
	sw $t9, 136($t1)
	sw $t9, 256($t1)
	sw $t9, 260($t1)
	sw $t9, 384($t1)
	sw $t9, 392($t1)
	sw $t9, 512($t1)
	sw $t9, 520($t1)
  	#t
  	addi $t1, $t1, 16
	sw $t9, 0($t1)
	sw $t9, 4($t1)
	sw $t9, 8($t1)
	sw $t9, 132($t1)
	sw $t9, 260($t1)
	sw $t9, 388($t1)
	sw $t9, 516($t1)
  	
  	
#exit button
	addi $t0, $t0, 176
	addi $t1, $t0, 140 # for letters later
	li $t9, 0xff7e00 # store orange
	li $t4, 19
	addi $t0, $t0, 4
O1:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, O1  # If counter != 3 rows from bottom, repeat the loop
  	addi $t0, $t0, 128
	li $t4, 21
O2:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, -4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, O2  # If counter != 3 rows from bottom, repeat the loop
	addi $t0, $t0, 132
	li $t4, 21
O3:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, O3  # If counter != 3 rows from bottom, repeat the loop
	addi $t0, $t0, 124
	li $t4, 21
O4:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, -4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, O4  # If counter != 3 rows from bottom, repeat the loop
	addi $t0, $t0, 132
	li $t4, 21
O5:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, O5  # If counter != 3 rows from bottom, repeat the loop
	li $t4, 21
	addi $t0, $t0, 124
O6:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, -4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, O6  # If counter != 3 rows from bottom, repeat the loop
	li $t4, 19
	addi $t0, $t0, 136
O7:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, O7  # If counter != 3 rows from bottom, repeat the loop
	
	
	li $t9, 0xed1c24 # store green	
#e
	sw $t9, 0($t1)
	sw $t9, 4($t1)
	sw $t9, 8($t1)
	sw $t9, 128($t1)
	sw $t9, 256($t1)
	sw $t9, 260($t1)
	sw $t9, 384($t1)
	sw $t9, 512($t1)
	sw $t9, 516($t1)
	sw $t9, 520($t1)
#x
	addi $t1, $t1, 16
	sw $t9, 0($t1)
	sw $t9, 8($t1)
	sw $t9, 128($t1)
	sw $t9, 136($t1)
	sw $t9, 260($t1)
	sw $t9, 384($t1)
	sw $t9, 392($t1)
	sw $t9, 512($t1)
	sw $t9, 520($t1)
#i
	addi $t1, $t1, 16
	sw $t9, 0($t1)
	sw $t9, 4($t1)
	sw $t9, 8($t1)
	sw $t9, 132($t1)
	sw $t9, 260($t1)
	sw $t9, 388($t1)
	sw $t9, 512($t1)
	sw $t9, 516($t1)
	sw $t9, 520($t1)

#t
	addi $t1, $t1, 16
	sw $t9, 0($t1)
	sw $t9, 4($t1)
	sw $t9, 8($t1)
	sw $t9, 132($t1)
	sw $t9, 260($t1)
	sw $t9, 388($t1)
	sw $t9, 516($t1)
	
	
	jr $ra
winscreen:
	li $t0, BASE_ADDRESS
	li $t4, 1024
DBG2: #fill bg with black
	li $t9, 0x000000 # store black
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, DBG2  # If counter != 3 rows from bottom, repeat the loop
    	li $t0, BASE_ADDRESS
    	addi $t0, $t0, 136
    	li $t9, 0xffffff # store black
    	sw $t9, 0($t0)
    	sw $t9, 16($t0)
    	sw $t9, 128($t0)
    	sw $t9, 144($t0)
    	sw $t9, 256($t0)
    	sw $t9, 264($t0)
    	sw $t9, 272($t0)
    	sw $t9, 384($t0)
    	sw $t9, 392($t0)
    	sw $t9, 400($t0)
    	sw $t9, 516($t0)
    	sw $t9, 524($t0)
    	addi $t0, $t0, 24
    #i
    	sw $t9, 0($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)
	sw $t9, 132($t0)
	sw $t9, 260($t0)
	sw $t9, 388($t0)
	sw $t9, 512($t0)
	sw $t9, 516($t0)
	sw $t9, 520($t0)
    	addi $t0, $t0, 16
    #n
    	sw $t9, 0($t0)
	sw $t9, 12($t0)
	sw $t9, 128($t0)
	sw $t9, 132($t0)
	sw $t9, 140($t0)
	sw $t9, 256($t0)
	sw $t9, 264($t0)
	sw $t9, 268($t0)
	sw $t9, 384($t0)
	sw $t9, 396($t0)
	sw $t9, 512($t0)
	sw $t9, 524($t0)
	
	jr $ra

endscreen:
	li $t0, BASE_ADDRESS
	li $t4, 1024
DBG: #fill bg with black
	li $t9, 0x000000 # store black
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, DBG  # If counter != 3 rows from bottom, repeat the loop
#draw words	
#g
	li $t0, BASE_ADDRESS
	li $t9, 0xffffff # store white
	addi $t0, $t0, 136
	sw $t9, 4($t0)
	sw $t9, 8($t0)
	sw $t9, 128($t0)
	sw $t9, 256($t0)
	sw $t9, 264($t0)
	sw $t9, 268($t0)
	sw $t9, 384($t0)
	sw $t9, 396($t0)
	sw $t9, 516($t0)
	sw $t9, 520($t0)
# a	
	addi $t0, $t0, 20
	sw $t9, 4($t0)
	sw $t9, 128($t0)
	sw $t9, 136($t0)
	sw $t9, 256($t0)
	sw $t9, 264($t0)
	sw $t9, 384($t0)
	sw $t9, 260($t0)
	sw $t9, 392($t0)
	sw $t9, 512($t0)
	sw $t9, 520($t0)
#m
	addi $t0, $t0, 16
	sw $t9, 0($t0)
	sw $t9, 16($t0)
	sw $t9, 128($t0)
	sw $t9, 132($t0)
	sw $t9, 140($t0)
	sw $t9, 144($t0)
	sw $t9, 256($t0)
	sw $t9, 264($t0)
	sw $t9, 272($t0)
	sw $t9, 384($t0)
	sw $t9, 400($t0)
	sw $t9, 512($t0)
	sw $t9, 528($t0)
#e
	addi $t0, $t0, 24
	sw $t9, 0($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)
	sw $t9, 128($t0)
	sw $t9, 256($t0)
	sw $t9, 260($t0)
	sw $t9, 384($t0)
	sw $t9, 512($t0)
	sw $t9, 516($t0)
	sw $t9, 520($t0)

#o
	addi $t0, $t0, 744
	sw $t9, 4($t0)
	sw $t9, 128($t0)
	sw $t9, 136($t0)
	sw $t9, 256($t0)
	sw $t9, 264($t0)
	sw $t9, 384($t0)
	sw $t9, 392($t0)
	sw $t9, 516($t0)
#v
	addi $t0, $t0, 16
	sw $t9, 0($t0)
	sw $t9, 8($t0)
	sw $t9, 128($t0)
	sw $t9, 136($t0)
	sw $t9, 256($t0)
	sw $t9, 264($t0)
	sw $t9, 384($t0)
	sw $t9, 392($t0)
	sw $t9, 516($t0)
#e
	addi $t0, $t0, 16
	sw $t9, 0($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)
	sw $t9, 128($t0)
	sw $t9, 256($t0)
	sw $t9, 260($t0)
	sw $t9, 384($t0)
	sw $t9, 512($t0)
	sw $t9, 516($t0)
	sw $t9, 520($t0)
#r
	addi $t0, $t0, 16
	sw $t9, 0($t0)
	sw $t9, 4($t0)
	sw $t9, 128($t0)
	sw $t9, 136($t0)
	sw $t9, 256($t0)
	sw $t9, 260($t0)
	sw $t9, 384($t0)
	sw $t9, 392($t0)
	sw $t9, 512($t0)
	sw $t9, 520($t0)
	
	jr $ra
	
#DrawPlatform	
DrawPlat:
# Inputs:
    #   $a0 = x-coordinate (0 to 255)
    #   $a1 = y-coordinate (0 to 255)
    # Calculate offset = (y * 1024) + (x * 4)
    	la $t0, BASE_ADDRESS      # Load base address into $t0
    	sll $t1, $a1, 7        # $t0 = y * 32 (shift left by 5)
    	sll $t2, $a0, 2         # $t1 = x * 4 (shift left by 2)
    	add $t0, $t0, $t1       # $t2 = total offset in bytes
    	add $t0, $t0, $t2       # $t2 = total offset in bytes
    
    	li $t9, 0X964B00
	add $t0, $t0, 4
	sw $t9, 0($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)
	sw $t9, 12($t0)
    	sw $t9, 16($t0)
	jr $ra

UpdateUFO:
	addi $sp, $sp, -4 #Make space on Stack
	sw $ra, 0($sp)        # Save return address
	
	jal EraseUFO
	#update position
	lw $t1, enemyx
	lw $t3, enemydir
	add $t1, $t1, $t3
	
	#check border
	blt $t1, $zero, flip
	li $t4, 24
	bgt $t1, $t4, flip
	j saveUFO

flip:
	neg $t3, $t3
	sw $t3, enemydir
	#undo move
	add $t1, $t1, $t3
	
saveUFO:
	sw $t1, enemyx
	jal DrawUFO
	
	lw $ra, 0($sp)     # Restore return address
    	addi $sp, $sp, 4   # Clean up stack
	jr $ra


DrawUFO:
	lw $a0, enemyx
	lw $a1, enemyy
	li $t0, BASE_ADDRESS      # Load base address into $t0
    	sll $t1, $a1, 7        # $t0 = y * 32 (shift left by 5)
    	sll $t2, $a0, 2         # $t1 = x * 4 (shift left by 2)
    	add $t0, $t0, $t1       # $t2 = total offset in bytes
    	add $t0, $t0, $t2
    	
    	li $t9, 0x22b14c #green
	sw $t9, 8($t0)
	sw $t9, 12($t0)
	sw $t9, 16($t0)
	sw $t9, 20($t0)
	sw $t9, 132($t0)
	sw $t9, 140($t0)
	sw $t9, 144($t0)
	sw $t9, 152($t0)
	li $t9, 0x0a0a0a # black
	sw $t9, 136($t0)
	sw $t9, 148($t0)
	li $t9, 0x464646 # grey
	sw $t9, 256($t0)
	sw $t9, 260($t0)
	sw $t9, 264($t0)
	sw $t9, 268($t0)
	sw $t9, 272($t0)
	sw $t9, 276($t0)
	sw $t9, 280($t0)
	sw $t9, 284($t0)
	sw $t9, 388($t0)
	sw $t9, 392($t0)
	sw $t9, 396($t0)
	sw $t9, 400($t0)
	sw $t9, 404($t0)
	sw $t9, 408($t0)
	
	jr $ra
	
EraseUFO:
	lw $a0, enemyx
	lw $a1, enemyy
	li $t0, BASE_ADDRESS      # Load base address into $t0
    	sll $t1, $a1, 7        # $t0 = y * 32 (shift left by 5)
    	sll $t2, $a0, 2         # $t1 = x * 4 (shift left by 2)
    	add $t0, $t0, $t1       # $t2 = total offset in bytes
    	add $t0, $t0, $t2
    	li $t4, 32
    	li $t9, 0x9fd3f3 # store sky colour
 Line1:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 24, Line1  # If counter != 3 rows from bottom, repeat the loop
    	addi $t0, $t0, 96
 Line2:	
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 16, Line2  # If counter != 3 rows from bottom, repeat the loop
    	addi $t0, $t0,96
 Line3:	
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 8, Line3  # If counter != 3 rows from bottom, repeat the loop
    	addi $t0, $t0,96
Line4:	
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bne $t4, 0, Line4  # If counter != 3 rows from bottom, repeat the loop
    	
    	jr $ra
    
#score
InitScore:

	li $t0, BASE_ADDRESS
	li $t9, 0x000000 # store black
	li $t4, 160
DrawBorder:
	sw $t9, 0($t0)        # Store the blue value at the current address
    	addi $t0, $t0, 4      # Increment the address by 4 (next word)
    	addi $t4, $t4, -1     # Decrement the pixel counter
    	bnez $t4, DrawBorder  # If counter != 3 rows from bottom, repeat the loop
    	#temp store the enemy x
    	li $t0, BASE_ADDRESS      # Load base address into $t0
    	li $t1, 9
    	sll $t2, $t1 , 2         # $t1 = x * 4 (shift left by 2)
    	add $t0, $t0, $t2
    	
    	li $t9, 0x22b14c #green
	sw $t9, 8($t0)
	sw $t9, 12($t0)
	sw $t9, 16($t0)
	sw $t9, 20($t0)
	sw $t9, 132($t0)
	sw $t9, 140($t0)
	sw $t9, 144($t0)
	sw $t9, 152($t0)
	li $t9, 0x0a0a0a # black
	sw $t9, 136($t0)
	sw $t9, 148($t0)
	li $t9, 0x464646 # grey
	sw $t9, 256($t0)
	sw $t9, 260($t0)
	sw $t9, 264($t0)
	sw $t9, 268($t0)
	sw $t9, 272($t0)
	sw $t9, 276($t0)
	sw $t9, 280($t0)
	sw $t9, 284($t0)
	sw $t9, 388($t0)
	sw $t9, 392($t0)
	sw $t9, 396($t0)
	sw $t9, 400($t0)
	sw $t9, 404($t0)
	sw $t9, 408($t0)
    	
    	li $t9, 0xffffff #white
    	li $t0, BASE_ADDRESS
    	#L
    	sw $t9, 76($t0)
	sw $t9, 204($t0)
	sw $t9, 332($t0)
	sw $t9, 460($t0)
	sw $t9, 588($t0)
    	sw $t9, 592($t0)
    	#E
    	sw $t9, 88($t0)
    	sw $t9, 92($t0)
    	sw $t9, 216($t0)
	sw $t9, 344($t0)
	sw $t9, 348($t0)
	sw $t9, 472($t0)
	sw $t9, 600($t0)
    	sw $t9, 604($t0)
    	#F
    	sw $t9, 100($t0)
    	sw $t9, 104($t0)
    	sw $t9, 228($t0)
    	sw $t9, 356($t0)
    	sw $t9, 360($t0)
    	sw $t9, 484($t0)
    	sw $t9, 612($t0)
    	#T
    	sw $t9, 112($t0)
    	sw $t9, 116($t0)
    	sw $t9, 120($t0)
    	sw $t9, 244($t0)
    	sw $t9, 372($t0)
    	sw $t9, 500($t0)
    	sw $t9, 628($t0)
    	
    	jr $ra
    	
UpdateScore:
	addi $sp, $sp, -4 #Make space on Stack
	sw $ra, 0($sp)        # Save return address
	lw $t8, score
	jal DrawScore
	lw $ra, 0($sp)     # Restore return address
    	addi $sp, $sp, 4   # Clean up stack
	jr $ra
	
DrawScore:
	li $t0, BASE_ADDRESS
	addi $t0, $t0, 12
	li $t9, 0x000000 # clear score first	
	sw $t9, 0($t0)        
    	sw $t9, 4($t0)
    	sw $t9, 8($t0)
    	addi $t0, $t0, 128
    	sw $t9, 0($t0)        
    	sw $t9, 4($t0)
    	sw $t9, 8($t0)
    	addi $t0, $t0, 128
    	sw $t9, 0($t0)        
    	sw $t9, 4($t0)
    	sw $t9, 8($t0)
    	addi $t0, $t0, 128
    	sw $t9, 0($t0)        
    	sw $t9, 4($t0)
    	sw $t9, 8($t0)
    	addi $t0, $t0, 128
    	sw $t9, 0($t0)        
    	sw $t9, 4($t0)
    	sw $t9, 8($t0)
    	
    	li $t0, BASE_ADDRESS
	addi $t0, $t0, 12
	li $t9, 0xffffff # write core now	
    	beqz $t8, zero
    	addi $t8, $t8, -1
    	beqz $t8, one
    	addi $t8, $t8, -1
    	beqz $t8, two
    	addi $t8, $t8, -1
    	beqz $t8, three
    	
three:       
    	sw $t9, 4($t0)
    	addi $t0, $t0, 128
    	sw $t9, 0($t0)        
    	sw $t9, 8($t0)
    	addi $t0, $t0, 128
    	sw $t9, 0($t0)        
    	sw $t9, 8($t0)
    	addi $t0, $t0, 128
    	sw $t9, 0($t0)        
    	sw $t9, 8($t0)
    	addi $t0, $t0, 128        
    	sw $t9, 4($t0)
    	j finScore
two:
    	sw $t9, 4($t0)
    	addi $t0, $t0, 128
    	sw $t9, 0($t0)        
    	sw $t9, 4($t0)
    	addi $t0, $t0, 128       
    	sw $t9, 4($t0)
    	addi $t0, $t0, 128
    	sw $t9, 4($t0)
    	addi $t0, $t0, 128
    	sw $t9, 0($t0)        
    	sw $t9, 4($t0)
    	sw $t9, 8($t0)
    	j finScore
one:
	sw $t9, 0($t0)        
    	sw $t9, 4($t0)
    	addi $t0, $t0, 128
    	sw $t9, 8($t0)
    	addi $t0, $t0, 128
    	sw $t9, 4($t0)
    	addi $t0, $t0, 128
    	sw $t9, 0($t0)        
    	addi $t0, $t0, 128
    	sw $t9, 0($t0)        
    	sw $t9, 4($t0)
    	sw $t9, 8($t0)
    	j finScore
zero:
	sw $t9, 0($t0)        
    	sw $t9, 4($t0)
    	addi $t0, $t0, 128
    	sw $t9, 8($t0)
    	addi $t0, $t0, 128      
    	sw $t9, 4($t0)
    	addi $t0, $t0, 128
    	sw $t9, 8($t0)
    	addi $t0, $t0, 128
    	sw $t9, 0($t0)        
    	sw $t9, 4($t0)
    	j finScore
 finScore:
    	jr $ra
    	
DrawPlayer:
	lw $a0, x #x
	lw $a1, y #y
	li $t0, BASE_ADDRESS      # Load base address into $t0
    	sll $t1, $a1, 7        # $t0 = y * 32 (shift left by 5)
    	sll $t2, $a0, 2         # $t1 = x * 4 (shift left by 2)
    	add $t0, $t0, $t1       # $t2 = total offset in bytes
    	add $t0, $t0, $t2       # $t2 = total offset in bytes

	li $t9, 0xff0000
	add $t0, $t0, 4
	sw $t9, 0($t0)
	add $t0, $t0, 124
	sw $t9, 0($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)
	
	jr $ra

#erases player 

ErasePlayert:
	lw $a0, x
    	lw $a1, y
	li $t0, BASE_ADDRESS      # Load base address into $t0
    	sll $t1, $a1, 7        # $t0 = y * 32 (shift left by 5)
    	sll $t2, $a0, 2         # $t1 = x * 4 (shift left by 2)
    	add $t0, $t0, $t1       # $t2 = total offset in bytes
    	add $t0, $t0, $t2       # $t2 = total offset in bytes

	li $t9, 0x000000
	add $t0, $t0, 4
	sw $t9, 0($t0)
	add $t0, $t0, 124
	sw $t9, 0($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)

    	jr $ra
ErasePlayer:
	lw $a0, x
    	lw $a1, y
	li $t0, BASE_ADDRESS      # Load base address into $t0
    	sll $t1, $a1, 7        # $t0 = y * 32 (shift left by 5)
    	sll $t2, $a0, 2         # $t1 = x * 4 (shift left by 2)
    	add $t0, $t0, $t1       # $t2 = total offset in bytes
    	add $t0, $t0, $t2       # $t2 = total offset in bytes

	li $t9, 0x9fd3f3
	add $t0, $t0, 4
	sw $t9, 0($t0)
	add $t0, $t0, 124
	sw $t9, 0($t0)
	sw $t9, 4($t0)
	sw $t9, 8($t0)

    	jr $ra
	
UpdateBullet:
	addi $sp, $sp, -4 #Make space on Stack
	sw $ra, 0($sp)        # Save return address
	lw $t3 bulactive
	beqz $t3, endbul
	
	 # Erase old bullet
    	li $t9, 0x9fd3f3   # background color
    	jal DrawPixel
    	lw $t2, buly
	 # Move bullet
    	add $t2, $t2, -1
    	sw $t2, buly
	lw $t3, bulx
# Enemy collision
	lw $t0, enemyx
	lw $t1, enemyy
	# check y
	ble $t2, $t1, nohit
	addi $t1, $t1, 4
	bge $t2, $t1, nohit
	#check x
	ble $t3, $t0, nohit
	addi $t0, $t0, 8
	bge $t3, $t0, nohit
	
#hit
	lw $t8, score
	addi $t8, $t8, 1 # increse score by 1
	sw $t8, score
	jal EraseUFO
	jal UpdateScore
	#randomize new location of UFO
	j deactivate_bullet
	
nohit:
    	# Out of bounds?
    	blt $t2, 5, deactivate_bullet

    	# Draw bullet
    	li $t9, 0x000000   # black bullet
    	jal DrawPixel
 	j endbul
deactivate_bullet:
    	li $t3, 0
    	sw $t3, bulactive
endbul:
	lw $ra, 0($sp)     # Restore return address
    	addi $sp, $sp, 4   # Clean up stack
    	jr $ra

DrawPixel:
	lw $a0, bulx
	lw $a1, buly
	li $t0, BASE_ADDRESS      # Load base address into $t0
    	sll $t1, $a1, 7        # $t0 = y * 32 (shift left by 5)
    	sll $t2, $a0, 2         # $t1 = x * 4 (shift left by 2)
    	add $t0, $t0, $t1       # $t2 = total offset in bytes
    	add $t0, $t0, $t2       # $t2 = total offset in bytes

	sw $t9, 0($t0)
    	jr $ra
	
