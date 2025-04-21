# Features completed
# Easy Features: Sound effects, Rows having different speeds. number of lives, retry screen, death animation
# Hard Feature: Randomly appearing ghost
# 5 Easy + 1 Hard



# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data
	displayAddress: 	.word 0x10008000
	frog_y: 		.word 28
	frog_x: 		.word 16
	log_row1:		.space 512
	log_row2: 		.space 512
	car_row1:		.space 512
	car_row2: 		.space 512
	player_1_lives:		.word 3
	str: 			.asciiz "Player 1 Lives: "
	skip_line:		.asciiz "\n"
	game_over_msg:		.asciiz "Game Over! Press <r> to retry \n"
	beep:			.byte 72
	overColor1: 		.word 0xfa7d09
	overColor2: 		.word 0xff4301
	backColor: 		.word 0xffffff
	pressColor: 		.word 0x111d5e
	row1: 			.word 0x10008218
	row2: 			.word 0x10008298
	row3: 			.word 0x10008318
	row4: 			.word 0x10008398
	row5: 			.word 0x10008418
	row6: 			.word 0x10008498
	row7: 			.word 0x10008518
	row8: 			.word 0x10008598
	row9: 			.word 0x10008618
	row10: 			.word 0x10008698
	row11: 			.word 0x10008718
	row12: 			.word 0x10008798
	
.text
	lw $t0, displayAddress # $t0 stores the base address for display


# ----------------------------------------------------------------------------------------------
# Initialization
initialization:
la $a1, car_row1	# load address of array car_row1 into $a1
jal init_car_row	# Fill allocated car_row1 space with pixels for the first vehicle row
la $a1, car_row2	# load address of array car_row2 into $a1
jal init_car_row	# Fill allocated car_row2 space with pixels for the second vehicle row
la $a1, log_row1	# load address of array log_row1 into $a1
jal init_car_row	# Fill allocated array log_row1 space with pixels for the first vehicle row
la $a1, log_row2	# load address of array log_row2 into $a1
jal init_car_row	# Fill allocated array log_row2 with pixels for the second log row
# reset player_1 lives to 3
la $a1, player_1_lives		# $a1 holds Addr(player_1_lives)
li $t1, 3			# t1 holds int 3
sw $t1, 0($a1)			# set value player_1_lives to 3

print_lives:
# Testing
li $v0, 4
la $a0, str
syscall
li $v0, 1
la $a1, player_1_lives
lw $a0, 0($a1)
syscall
li $v0, 4
la $a0, skip_line
syscall


process_control:
# Check for keyboard input & update frog location accordingly
lw $t8, 0xffff0000
beq $t8, 1, keyboard_input	# if $t8 == 1, branch to keyboard_input


keyboard_input:
lw $t9, 0xffff0004
beq $t9, 0x61, respond_to_A
beq $t9, 0x77, respond_to_W
beq $t9, 0x73, respond_to_S
beq $t9, 0x64, respond_to_D
finish_keyboard_input:
sw $zero, 0xffff0000		# Reset keyboard input to zero
sw $zero, 0xffff0004		# Reset keyboard_inpit

jal draw_background
jal init_draw_obs_rows
finish_init_draw_obs_rows:

j display_lives_left
exit_display_lives_left:


jal draw_frog		# Redraw frog 
jal generate_ghost_coords
j draw_ghost
exit_ghost:

# Sleep for 17 ms 
li $v0, 32
li $a0, 300
syscall

la $t9, car_row1	# $t9 holds the address of car_row1
jal shift_left		# shift_left car_row1

la $t9, log_row1	# int[] numbers[128];	<$t9 holds address of log_row1> 
jal shift_left		# shift log_row1 to the left

la $t9, log_row2	# int[] numbers[128];	<$t9 holds address of log_row2> 
jal shift_right		# shift log_row2 to the left

la $t9, car_row2	# $t9 holds the address of car_row2
jal shift_right		# shift_right car_row2

# shift left car_row1 again
la $t9, car_row1	# $t9 holds the address of car_row1
jal shift_left		# shift_left car_row1

# shift right log_row2 again
la $t9, log_row2	# int[] numbers[128];	<$t9 holds address of log_row2> 
jal shift_right		# shift log_row2 to the left

j process_control
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
generate_ghost_coords:

# Generate random int, place inside $a1
li $v0, 42
li $a0, 256
li $a1, 784
syscall
jr $ra

draw_ghost:
#
# Draw Ghost
#

lw $t0, displayAddress 	# $t0 stores the base address for display

# Before drawing the ghost, check if the previous colour was the frog's
lw $s0, 4($t0)		
beq $s0, 0xff1493, collision_by_car

li $t1, 4		# load 128 into $t7
mult $a0, $t1  		# Number of lines
mflo $a3
add $t0, $t0, $a3	# start drawing $a1 / 128 lines down.

# Assume that the height and width of the rectangle are in $a0 and $a1
addi $a0, $zero, 1	# set height = 8
addi $a1, $zero, 1	# set width = 32

li $t3, 0x00ffff 	# $t3 stores the cyan colour code
li $t4, 0x000000	# $t4 stores black

# Check if prev. pixel was frog
lw $s0, 4($t0)		
beq $s0, 0xff1493, collision_by_car
sw $t3, 4($t0)
# Check if prev. pixel was frog
lw $s0, 8($t0)		
beq $s0, 0xff1493, collision_by_car
sw $t3, 8($t0)
# Check if prev. pixel was frog
lw $s0, 12($t0)		
beq $s0, 0xff1493, collision_by_car
sw $t3, 12($t0)

# Check if prev. pixel was frog
lw $s0, 132($t0)		
beq $s0, 0xff1493, collision_by_car
sw $t4, 132($t0)
# Check if prev. pixel was frog
lw $s0, 136($t0)		
beq $s0, 0xff1493, collision_by_car
sw $t3, 136($t0)
# Check if prev. pixel was frog
lw $s0, 140($t0)		
beq $s0, 0xff1493, collision_by_car
sw $t4, 140($t0)

# Check if prev. pixel was frog
lw $s0, 260($t0)		
beq $s0, 0xff1493, collision_by_car
sw $t3, 260($t0)
# Check if prev. pixel was frog
lw $s0, 264($t0)		
beq $s0, 0xff1493, collision_by_car
sw $t3, 264($t0)
# Check if prev. pixel was frog
lw $s0, 268($t0)		
beq $s0, 0xff1493, collision_by_car
sw $t3, 268($t0)

# Check if prev. pixel was frog
lw $s0, 388($t0)		
beq $s0, 0xff1493, collision_by_car
sw $t3, 388($t0)
# Check if prev. pixel was frog
lw $s0, 396($t0)		
beq $s0, 0xff1493, collision_by_car
sw $t3, 396($t0)

#end_of_ghost_drawing, jump to exit_ghost if we reach here:
j exit_ghost
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
init_draw_obs_rows:
# Initialize variables for drawing car_row1
lw $t0, displayAddress 	# $t0 stores the base address for display
addi $t0, $t0, 2560	# start drawing 20 lines down.
la $a3, car_row1	# load address of array car_row1 into $a1

# Draw car_row1
li $t1, 0xff0000 	# $t1 stores the red colour code (for the cars)
li $s4, 0x47484c	# $s4 holds the road colour
jal draw_obs_row	# Draw car_row1

# Initialize variables for drawing car_row2
lw $t0, displayAddress 	# $t0 stores the base address for display
addi $t0, $t0, 3072	# start drawing 24 lines down.
la $a3, car_row2	# load address of array car_row1 into $a1

# Draw car_row2
li $t1, 0xff0000 	# $t1 stores the red colour code (for the cars)
li $s4, 0x47484c	# $s4 holds the road colour
jal draw_obs_row	# Draw car_row2

# Initialize variables for drawing log_row1
lw $t0, displayAddress 	# $t0 stores the base address for display
addi $t0, $t0, 1024	# start drawing 8 lines down.
la $a3, log_row1	# load address of array car_row1 into $a1

# Draw log_row1
li $t1, 0x8b4513 	# $t1 stores the brown colour code (for the logs)
li $s4, 0x0000ff	# $s4 holds the river colour
jal draw_obs_row	# Draw car_row1

# Initialize variables for drawing log_row2
lw $t0, displayAddress 	# $t0 stores the base address for display
addi $t0, $t0, 1536	# start drawing 8 lines down.
la $a3, log_row2	# load address of array car_row1 into $a1

# Draw log_row2
li $t1, 0x8b4513 	# $t1 stores the brown colour code (for the logs)
li $s4, 0x0000ff	# $s4 holds the river colour
jal draw_obs_row	# Draw car_row1

j finish_init_draw_obs_rows
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
# Display lives left
display_lives_left:
li $t3, 3		# $t1 - $t3 holds the integers 1 - 3
li $t2, 2
li $t1, 1 
la $t4, player_1_lives	# $t4 = Addr(player_1_lives)
lw $t5, 0($t4)		# $t5 = player_1_lives
beq $t5, $t1, display_one_life
beq $t5, $t2, display_two_lives
beq $t5, $t3, display_three_lives


display_three_lives:
lw $t0, displayAddress 	# $t0 stores the base address for display
addi $t0, $t0, 132	# start drawing 1 lines down and a bit to the right
jal display_life_stroke
lw $t0, displayAddress 	# $t0 stores the base address for display
addi $t0, $t0, 140
jal display_life_stroke
lw $t0, displayAddress 	# $t0 stores the base address for display
addi $t0, $t0, 148
jal display_life_stroke
j exit_displaying_lives


display_two_lives:
lw $t0, displayAddress 	# $t0 stores the base address for display
addi $t0, $t0, 132	# start drawing 1 lines down and a bit to the right
jal display_life_stroke
lw $t0, displayAddress 	# $t0 stores the base address for display
addi $t0, $t0, 140
jal display_life_stroke
j exit_displaying_lives


display_one_life:
lw $t0, displayAddress 	# $t0 stores the base address for display
addi $t0, $t0, 132
jal display_life_stroke
j exit_displaying_lives


exit_displaying_lives:
j exit_display_lives_left
# End of Display lives 
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
display_life_stroke:
add $t6, $zero, $zero	# Set index value ($t6) to zero
addi $t7, $zero, 2	# Set $t7 = 2
add $t8, $zero, $zero	# $t8 stores increment
draw_line_life_loop3:
beq $t8, $t7, exit_display_one_life  # If $t8 == 4, jump to end
li $s1, 0xffffff 	# $t4 stores the white colour code
sw $s1, 0($t0)		#   - Draw a pixel at memory location $t0
addi $t0, $t0, 128	#   - Increment $t0 by 4
addi $t8, $t8, 1	#   - Increment $t8 by `
j draw_line_life_loop3	#   - Jump to start of line drawing loop
exit_display_one_life:
jr $ra
# ----------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------
game_over_screen:
lw $t0, overColor1
lw $t1, overColor2
lw $t2, backColor
lw $t3, pressColor

# first row
lw $s0, row1
sw $t2, 0($s0)
sw $t2, 4($s0)
sw $t2, 8($s0)
sw $t2, 12($s0)
sw $t2, 20($s0)
sw $t2, 24($s0)
sw $t2, 28($s0)
sw $t2, 32($s0)
sw $t2, 40($s0)
sw $t2, 56($s0)
sw $t2, 64($s0)
sw $t2, 68($s0)
sw $t2, 72($s0)
sw $t2, 76($s0)

lw $s0, row2
sw $t2, 0($s0)
sw $t0, 4($s0)
sw $t0, 8($s0)
sw $t0, 12($s0)
sw $t0, 16($s0)
sw $t2, 20($s0)
sw $t0, 24($s0)
sw $t0, 28($s0)
sw $t0, 32($s0)
sw $t0, 36($s0)
sw $t2, 40($s0)
sw $t0, 44($s0)
sw $t2, 52($s0)
sw $t2, 56($s0)
sw $t0, 60($s0)
sw $t2, 64($s0)
sw $t0, 68($s0)
sw $t0, 72($s0)
sw $t0, 76($s0)
sw $t0, 80($s0)

lw $s0, row3
sw $t2, 0($s0)
sw $t0, 4($s0)
sw $t2, 8($s0)
sw $t2, 12($s0)
sw $t2, 20($s0)
sw $t0, 24($s0)
sw $t2, 28($s0)
sw $t2, 32($s0)
sw $t0, 36($s0)
sw $t2, 40($s0)
sw $t0, 44($s0)
sw $t0, 48($s0)
sw $t0, 56($s0)
sw $t0, 60($s0)
sw $t2, 64($s0)
sw $t0, 68($s0)
sw $t2, 72($s0)
sw $t2, 76($s0)

lw $s0, row4
sw $t2, 0($s0)
sw $t0, 4($s0)
sw $t0, 12($s0)
sw $t0, 16($s0)
sw $t2, 20($s0)
sw $t0, 24($s0)
sw $t0, 28($s0)
sw $t0, 32($s0)
sw $t0, 36($s0)
sw $t2, 40($s0)
sw $t0, 44($s0)
sw $t0, 52($s0)
sw $t2, 56($s0)
sw $t0, 60($s0)
sw $t2, 64($s0)
sw $t0, 68($s0)
sw $t0, 72($s0)
sw $t0, 76($s0)
sw $t0, 80($s0)

lw $s0, row5
sw $t2, 0($s0)
sw $t1, 4($s0)
sw $t2, 8($s0)
sw $t2, 12($s0)
sw $t1, 16($s0)
sw $t2, 20($s0)
sw $t1, 24($s0)
sw $t2, 32($s0)
sw $t1, 36($s0)
sw $t2, 40($s0)
sw $t1, 44($s0)
sw $t2, 56($s0)
sw $t1, 60($s0)
sw $t2, 64($s0)
sw $t1, 68($s0)
sw $t2, 72($s0)
sw $t2, 76($s0)

lw $s0, row6
sw $t1, 4($s0)
sw $t1, 8($s0)
sw $t1, 12($s0)
sw $t1, 16($s0)
sw $t1, 24($s0)
sw $t1, 36($s0)
sw $t1, 44($s0)
sw $t1, 60($s0)
sw $t1, 68($s0)
sw $t1, 72($s0)
sw $t1, 76($s0)
sw $t1, 80($s0)

lw $s0, row7
sw $t2, 0($s0)
sw $t2, 4($s0)
sw $t2, 8($s0)
sw $t2, 12($s0)
sw $t2, 20($s0)
sw $t2, 36($s0)
sw $t2, 44($s0)
sw $t2, 48($s0)
sw $t2, 52($s0)
sw $t2, 56($s0)
sw $t2, 64($s0)
sw $t2, 68($s0)
sw $t2, 72($s0)
sw $t2, 76($s0)

lw $s0, row8
sw $t2, 0($s0)
sw $t0, 4($s0)
sw $t0, 8($s0)
sw $t0, 12($s0)
sw $t0, 16($s0)
sw $t2, 20($s0)
sw $t0, 24($s0)
sw $t2, 36($s0)
sw $t0, 40($s0)
sw $t2, 44($s0)
sw $t0, 48($s0)
sw $t0, 52($s0)
sw $t0, 56($s0)
sw $t0, 60($s0)
sw $t2, 64($s0)
sw $t0, 68($s0)
sw $t0, 72($s0)
sw $t0, 76($s0)
sw $t0, 80($s0)

lw $s0, row9
sw $t2, 0($s0)
sw $t0, 4($s0)
sw $t2, 12($s0)
sw $t0, 16($s0)
sw $t0, 24($s0)
sw $t2, 32($s0)
sw $t0, 40($s0)
sw $t2, 44($s0)
sw $t0, 48($s0)
sw $t2, 52($s0)
sw $t2, 56($s0)
sw $t2, 64($s0)
sw $t0, 68($s0)
sw $t2, 72($s0)
sw $t2, 76($s0)
sw $t0, 80($s0)

lw $s0, row10
sw $t2, 0($s0)
sw $t0, 4($s0)
sw $t2, 12($s0)
sw $t0, 16($s0)
sw $t2, 24($s0)
sw $t0, 28($s0)
sw $t2, 32($s0)
sw $t0, 36($s0)
sw $t2, 44($s0)
sw $t0, 48($s0)
sw $t0, 52($s0)
sw $t0, 56($s0)
sw $t0, 60($s0)
sw $t2, 64($s0)
sw $t0, 68($s0)
sw $t0, 72($s0)
sw $t0, 76($s0)
sw $t0, 80($s0)

lw $s0, row11
sw $t2, 0($s0)
sw $t1, 4($s0)
sw $t2, 8($s0)
sw $t2, 12($s0)
sw $t1, 16($s0)
sw $t1, 28($s0)
sw $t1, 36($s0)
sw $t2, 44($s0)
sw $t1, 48($s0)
sw $t2, 52($s0)
sw $t2, 56($s0)
sw $t2, 64($s0)
sw $t1, 68($s0)
sw $t1, 76($s0)

lw $s0, row12
sw $t1, 4($s0)
sw $t1, 8($s0)
sw $t1, 12($s0)
sw $t1, 16($s0)
sw $t1, 32($s0)
sw $t1, 48($s0)
sw $t1, 52($s0)
sw $t1, 56($s0)
sw $t1, 60($s0)
sw $t1, 68($s0)
sw $t1, 80($s0)

jr $ra

# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
# play victory sound
play_victory_sound:
li $v0, 31		# MIDI out, Note: $a0 pitch, $a1 duration in ms, $a2 instrument, $a3 vol
la $a0, beep		
li $a1, 700
li $a2, 10
li $a3, 50
syscall

j exit_victory_sound
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
# play an organ (to be played when dieing in the river)
play_organ:
li $v0, 31		# MIDI out, Note: $a0 pitch, $a1 duration in ms, $a2 instrument, $a3 vol
la $a0, beep		
li $a1, 700
li $a2, 18
li $a3, 120
syscall

jr $ra
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
# play a car horn
play_car_horn:
li $v0, 31		# MIDI out, Note: $a0 pitch, $a1 duration in ms, $a2 instrument, $a3 vol
la $a0, beep		
li $a1, 700
li $a2, 104
li $a3, 80
syscall

jr $ra
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
# Play beep, which plays a laser-sounding sound
# Note 104 car beep
# Note 127 laser 
play_beep:
li $v0, 31		# MIDI out, Note: $a0 pitch, $a1 duration in ms, $a2 instrument, $a3 vol
la $a0, beep		
li $a1, 700
li $a2, 127
li $a3, 80
syscall

jr $ra
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
# Display game over screen
game_over:
jal game_over_screen
li $v0, 4
la $a0, game_over_msg
syscall

# Check for keyboard input r & reset game
wait_for_r:
lw $t8, 0xffff0000
beq $t8, 1, keyboard_input_r	# if $t8 == 1, branch to keyboard_input
j wait_for_r

keyboard_input_r:
lw $t9, 0xffff0004
beq $t9, 0x72, respond_to_R
sw $zero, 0xffff0000		# Reset keyboard input to zero
sw $zero, 0xffff0004		# Reset keyboard_input
j wait_for_r

#keyboard_input_retry:
#lw $t9, 0xffff0004
#beq $t9, 0x72, respond_to_R

respond_to_R:
sw $zero, 0xffff0000		# Reset keyboard input to zero
sw $zero, 0xffff0004		# Reset keyboard_input
j initialization 		# jump back to initialization
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
# Update player 1 lives if player 1 died
update_player_1_lives:

la $a1, player_1_lives	# $a1 holds Addr(player_1_lives)
lw $t1, 0($a1)		# $t1 holds the number of lives player 1 has
li $t2, 1		# $t2 holds 1
sub $t1, $t1, $t2	# subtract 1 from $t1
sw $t1, 0($a1)		# restore number of lives into player_1_lives

# if player_1_lives > 0 continue game, else print retry? screen
bge $t1, $t2, print_lives	# Branch to print_lives if number of lives >= 1
j game_over		# else jump to game_over
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
play_death_animation1:

lw $t0, displayAddress	# $t0 sotres the base address for display
la $t7, frog_x 		# $t7 has frog_x's address (ptr to frog_x)
lw $t8, 0($t7)		# Fetch x position of frog (dereference frog_x, *frog_x)
la $t7, frog_y 		# $t7 has frog_y's address (ptr to frog_y)
lw $t9, 0($t7)		# Fetch y position of frog (dereference frog_y, *frog_y)
sll $t8, $t8, 2		# Mult $t8 by 4	
sll $t9, $t9, 7		# Mult $t9 by 128
add $t0, $t0, $t9	# Add y offset to $t0
add $t0, $t0, $t8	# Add x offset to $t0
li $t8, 0xff1493	# Load deep pink into $t8

sw $t8, 0($t0) 		# paint the first (top-left) unit pink.
sw $t8, 12($t0) 	# paint the second (top-right) unit pink.
#sw $t8, 128($t0)	# Painting continued, Top left to bottom right, Beginning of second row
sw $t8, 132($t0)
sw $t8, 136($t0)
#sw $t8, 140($t0)
sw $t8, 260($t0)	# Beginning of third row
sw $t8, 264($t0)
sw $t8, 384($t0)	# Beginning of fourth row
#sw $t8, 388($t0)
#sw $t8, 392($t0)
sw $t8, 396($t0)

# Sleep for 750 ms 
li $v0, 32
li $a0, 500
syscall


jr $ra
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
# Collision detection, reset frog loc to initial spawn if collision detected
collision_by_car:
jal play_car_horn
j collision

collision_by_river:
jal play_organ
j collision

collision:
# Play death animation
jal play_death_animation1

# Reset frog_x and frog_y
la $t7, frog_y 		# $t7 has frog_x's address (ptr to frog_x)
addi $t1, $zero, 28	# $t1 stores frog_y = 28
sw $t1, 0($t7)		# Fetch x position of frog (dereference frog_x, *frog_x)
la $t7, frog_x 		# $t7 has frog_y's address (ptr to frog_y)
addi $t2, $zero, 16	# $t2 stores frog_x = 28
sw $t2, 0($t7)		# Fetch y position of frog (dereference frog_y, *frog_y)

j update_player_1_lives
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
# Respond to Keyboard input (if any)
respond_to_A:
la $a1, frog_x 		# $a1 has frog_x's address (ptr to frog_x)
lw $t8, 0($a1)		# Fetch x position of frog (dereference frog_x, *frog_x)
subi $t8, $t8, 2
sw $t8, 0($a1)		# Store init value of frog_x 
jal play_beep		# Play beep sound
j finish_keyboard_input

respond_to_S:
la $a1, frog_y 		# $a1 has frog_x's address (ptr to frog_x)
lw $t8, 0($a1)		# Fetch x position of frog (dereference frog_x, *frog_x)
addi $t8, $t8, 4
sw $t8, 0($a1)		# Store init value of frog_x 
jal play_beep		# Play beep sound
j finish_keyboard_input

respond_to_W:
la $a1, frog_y 		# $a1 has frog_x's address (ptr to frog_x)
lw $t8, 0($a1)		# Fetch x position of frog (dereference frog_x, *frog_x)
subi $t8, $t8, 4
sw $t8, 0($a1)		# Store init value of frog_x 
jal play_beep		# Play beep sound
j finish_keyboard_input


# Move frog 1 pixel to the right
respond_to_D:
la $a1, frog_x 		# $a1 has frog_x's address (ptr to frog_x)
lw $t8, 0($a1)		# Fetch x position of frog (dereference frog_x, *frog_x)
addi $t8, $t8, 2
sw $t8, 0($a1)		# Store init value of frog_x 
jal play_beep		# Play beep sound
j finish_keyboard_input
# ----------------------------------------------------------------------------------------------


# End of responding responding to keyboard inputs
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
# <shift_left> Shifts elements in an array once to the left, wrapping the first element to the last index.

# Code in C:
# int numbers[128] = {1,2,3,4,5,....,128};
# int first_index = 0;
# int second_index = 1;
# int first_element = numbers[0];
#     while (second_index <= 128) {			
#         numbers[first_index] = numbers[second_index];
#         first_index++;
#         second_index++;
#     }
#     numbers[128 - 1] = first_element; 			// numbers[512 - 4] = first_element;
shift_left:

addi $t1, $zero, 512	# int size = 128;	<$t1 holds integer 512>
add $t2, $zero, $zero	# int first_index = 0;	<$t2 holds first_index = 0>
addi $t3, $zero, 4	# int second_index = 1; <$t3 holds second_index = 4>
lw $t4, 0($t9)		# int first_element = numbers[0];	<$t4 holds first element>

shift_left_loop:
bgt $t3, $t1, end_shift_left_loop	# while (second_index <= 128) || exit loop once $t3 <second_index> > 512
	add $t5, $t9, $t2	# $t5 holds Addr(numbers[first_index])
	add $t6, $t9, $t3	# $t6 holds Addr(numbers[second_index])
	lw $s1, 0($t6)		# $s1 = numbers[second_index]
	sw $s1, 0($t5)		# numbers[first_index] = $s1 = numbers[second_index]
	addi $t2, $t2, 4	# Increment first_index
	addi $t3, $t3, 4	# Incremenet second_index
	j shift_left_loop

end_shift_left_loop:
sw $t4, 508($t9)	# numbers[128 - 1] = first_element;
jr $ra
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
# Shift right <Shifts elements to the right, wrapping last element to index 0>

# Code in C:
#    int numbers[8] = {1,2,3,4,5,6,7,8,...,128};
#    int first_index = 0;
#    int second_index = 1;
#    int temp1 = numbers[first_index];
#    int temp2;
#    int last_element = numbers[127];
#    
#    while (first_index < 128) {
#        temp2 = numbers[second_index];
#        numbers[second_index] = temp1;
#        temp1 = temp2;
#        second_index++;
#        first_index++;
#    }
#    numbers[0] = last_element;

shift_right:

addi $t1, $zero, 508	# int size = 128;	<$t1 holds integer 512>
add $t2, $zero, $zero	# int first_index = 0;	<$t2 holds first_index = 0>
addi $t3, $zero, 4	# int second_index = 1; <$t3 holds second_index = 4>
lw $t4, 0($t9)		# int temp1 = numbers[first_index];	<$t4 holds first temp1, which is the first element>
lw $t5, 508($t9)	# int last_element = numbers[127];	<$t5 holds the last element>

shift_right_loop:
bge $t2, $t1, end_shift_right_loop	# Exit loop once $t2 >= $t1 || first_index >= 512
	add $t6, $t9, $t3	# $t6 holds Addr(numbers[second_index])
	add $t7, $t9, $t2	# $t7 holds Addr(numbers[first_index])
	lw $s0, 0($t6)		# $s0 = numbers[second_index]
	add $s1, $s0, $zero	# temp2 = $s1 = numbers[second_index]
	sw $t4, 0($t6)		# numbers[second_index] = temp1;
	add $t4, $zero, $s1	# temp1 = temp2;
	addi $t2, $t2, 4	# increent first_index
	addi $t3, $t3, 4	# increment second_index
	j shift_right_loop

end_shift_right_loop:
sw $t5, 0($t9)			# numbers[0] = last_element;
jr $ra

# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
# Initialize car_row

# Code in C:
# # DEFINE SIZE 512	// array of words
# int i = 0;
# int is_car = 0;
# int j = 0;
# int car_row[SIZE];
# while (j != SIZE) {
# 	if (i == 8) {
# 		i = 1;
#		is_car = 1 - is_car;
#	}
#	car_row[j] = is_car;
#	i++; j++;
# }
init_car_row:

# la $a1, car_row1	# load address of array car_row1 into $a1
add $t3, $zero, $zero	# $t3 holds int i = 0;
add $t4, $zero, $zero 	# $t4 holds int is_car = 0;
add $t5, $zero, $zero 	# $t5 holds j = 0;
addi $t6, $zero, 512	# $t6 holds SIZE 512, representing 512 Bytes (128 Pixels * 4 Bytes each)
addi $t7, $zero, 8	# $t7 holds the costant 8
li $s0, 1		# $s0 holds the constant 1
add $s1, $zero, $zero	# $s1 holds 4 * j, initially 0

loop1:
bge $s1, $t6, end_loop1	# exit loop when $s1 >= SIZE
	blt $t3, $t7 exit_if1	# if i < 8 jump to exit_if, skip lines below. But if i => 8, exec lines below
	addi $t3, $zero, 0	# $t3 holds i = 0;
	sub $t4, $s0, $t4	# is_car = 1 - is_car;

exit_if1:
add $t9, $a1, $s1	# $t9 = addr(car_row1) + j * 4 = addr(car_row[j])
sw $t4, 0($t9)		# car_row[j] = is_car = $t4
addi $s1, $s1, 4	# update offset in $s1
addi $t3, $t3, 1	# increment i
addi $t5, $t5, 1	# increment j
j loop1

end_loop1:

jr $ra 			# jump back to the calling program
# ----------------------------------------------------------------------------------------------



# ----------------------------------------------------------------------------------------------
# Draw car_row1
draw_obs_row:

add $s0, $zero, $zero	# $s0 holds 4 * i; initially zero
li $s3, 0		# $s3 holds constant 0

# Assume that the height and width of the rectangle are in $a0 and $a1
addi $a0, $zero, 4	# set height = 4
addi $a1, $zero, 32	# set width = 32

# Draw car_row:
add $t6, $zero, $zero	# Set index value ($t6) to zero
draw_rect_loop4:
beq $t6, $a0, end_car_row  	# If $t6 == height ($a0), jump to end_car_row

# Draw a line:
add $t5, $zero, $zero	# Set index value ($t5) to zero
draw_line_loop4:
beq $t5, $a1, end_draw_line4  # If $t5 == width ($a1), jump to end
add $s1, $a3, $s0	# $s1 holds addr(obs_row[i])
lw $s2, 0($s1)		# $s2 = obs_row[i] 
	beq $s2, $s3, draw_road1 	# if car_row[i] == 0, jump to draw_road1
	sw $t1, 0($t0)			# Draw a car color at memory location $t0
	addi $s0, $s0, 4		# increment $s0 by 4 (Offset)
	j exit_drawing
	
	draw_road1:
	sw $s4, 0($t0)			# Draw road colour at mem loc $t0
	addi $s0, $s0, 4		# increment $s0 by 4 (Offset)
	
exit_drawing:
addi $t0, $t0, 4	#   - Increment $t0 by 4
addi $t5, $t5, 1	#   - Increment $t5 by 1
j draw_line_loop4	#   - Jump to start of line drawing loop
end_draw_line4:

addi $t0, $t0, 0	# Set $t0 to the first pixel of the next line.
			# Note: This value really should be calculated.
addi $t6, $t6, 1	#   - Increment $t6 by 1
j draw_rect_loop4	#   - Jump to start of rectangle drawing loop

#
# End of draw_car_row
#
end_car_row:

jr $ra
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
# Draws start, safe, and goal region 
draw_background:

#
# Section 1: Draw goal region
#

lw $t0, displayAddress 	# $t0 stores the base address for display
addi $t0, $t0, 0	# start drawing 0 lines down.

# Assume that the height and width of the rectangle are in $a0 and $a1
addi $a0, $zero, 8	# set height = 8
addi $a1, $zero, 32	# set width = 32

# Draw goal area:
add $t6, $zero, $zero	# Set index value ($t6) to zero
draw_rect_loop:
beq $t6, $a0, Safe  	# If $t6 == height ($a0), jump to Safe

# Draw a line:
add $t5, $zero, $zero	# Set index value ($t5) to zero
draw_line_loop:
beq $t5, $a1, end_draw_line  # If $t5 == width ($a1), jump to end
li $t3, 0x00ff00 	# $t3 stores the green colour code
sw $t3, 0($t0)		#   - Draw a pixel at memory location $t0
addi $t0, $t0, 4	#   - Increment $t0 by 4
addi $t5, $t5, 1	#   - Increment $t5 by 1
j draw_line_loop	#   - Jump to start of line drawing loop
end_draw_line:

addi $t0, $t0, 0	# Set $t0 to the first pixel of the next line.
			# Note: This value really should be calculated.
addi $t6, $t6, 1	#   - Increment $t6 by 1
j draw_rect_loop	#   - Jump to start of rectangle drawing loop

#
# End of Section 1
#

#
# Section 2: Draw safe region
#
Safe:
lw $t0, displayAddress 	# $t0 stores the base address for display
addi $t0, $t0, 2048	# start drawing 16 lines down.

# Assume that the height and width of the rectangle are in $a0 and $a1
addi $a0, $zero, 4	# set height = 8
addi $a1, $zero, 32	# set width = 32

# Draw goal area:
add $t6, $zero, $zero	# Set index value ($t6) to zero
draw_rect_loop2:
beq $t6, $a0, Start  	# If $t6 == height ($a0), jump to Safe

# Draw a line:
add $t5, $zero, $zero	# Set index value ($t5) to zero
draw_line_loop2:
beq $t5, $a1, end_draw_line2  # If $t5 == width ($a1), jump to end
li $t4, 0xc2b280 	# $t4 stores the light pink colour code
sw $t4, 0($t0)		#   - Draw a pixel at memory location $t0
addi $t0, $t0, 4	#   - Increment $t0 by 4
addi $t5, $t5, 1	#   - Increment $t5 by 1
j draw_line_loop2	#   - Jump to start of line drawing loop
end_draw_line2:

addi $t0, $t0, 0	# Set $t0 to the first pixel of the next line.
			# Note: This value really should be calculated.
addi $t6, $t6, 1	#   - Increment $t6 by 1
j draw_rect_loop2	#   - Jump to start of rectangle drawing loop

#
# End of section 2
#

#
# Section 3: Draw start region
#
Start:
lw $t0, displayAddress 	# $t0 stores the base address for display
addi $t0, $t0, 3584	# start drawing 28 lines down.

# Assume that the height and width of the rectangle are in $a0 and $a1
addi $a0, $zero, 4	# set height = 8
addi $a1, $zero, 32	# set width = 32

# Draw goal area:
add $t6, $zero, $zero	# Set index value ($t6) to zero
draw_rect_loop3:
beq $t6, $a0, end_bckrnd 	# If $t6 == height ($a0), jump to Safe

# Draw a line:
add $t5, $zero, $zero	# Set index value ($t5) to zero
draw_line_loop3:
beq $t5, $a1, end_draw_line3  # If $t5 == width ($a1), jump to end
sw $t3, 0($t0)		#   - Draw a pixel at memory location $t0
addi $t0, $t0, 4	#   - Increment $t0 by 4
addi $t5, $t5, 1	#   - Increment $t5 by 1
j draw_line_loop3	#   - Jump to start of line drawing loop
end_draw_line3:

addi $t0, $t0, 0	# Set $t0 to the first pixel of the next line.
			# Note: This value really should be calculated.
addi $t6, $t6, 1	#   - Increment $t6 by 1
j draw_rect_loop3	#   - Jump to start of rectangle drawing loop

#
# End of section 2
#
end_bckrnd:
jr $ra			
# End of function draw_background, pass control back to whoever called draw_background
# ----------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------
# Draw frog
draw_frog:

# 
# Section 3: Draw frog
#
Frog:
lw $t0, displayAddress	# $t0 sotres the base address for display
la $t7, frog_x 		# $t7 has frog_x's address (ptr to frog_x)
lw $t8, 0($t7)		# Fetch x position of frog (dereference frog_x, *frog_x)
la $t7, frog_y 		# $t7 has frog_y's address (ptr to frog_y)
lw $t9, 0($t7)		# Fetch y position of frog (dereference frog_y, *frog_y)
sll $t8, $t8, 2		# Mult $t8 by 4	
sll $t9, $t9, 7		# Mult $t9 by 128
add $t0, $t0, $t9	# Add y offset to $t0
add $t0, $t0, $t8	# Add x offset to $t0
li $t8, 0xff1493	# Load deep pink into $t8

# Before drawing the frog, check if the previous colour was either blue or red (river/car)
lw $s0, 0($t0)		# load value of $t0 into $s0
# Checks if left side collided
beq $s0, 0xff0000, collision_by_car	
beq $s0, 0x0000ff, collision_by_river
beq $s0, 0x00ffff, collision_by_car	# collides with ghost
# Check if right side collided
lw $s1, 136($t0)
beq $s1, 0xff0000, collision_by_car	
beq $s1, 0x0000ff, collision_by_river
beq $s1, 0x00ffff, collision_by_car	# collides with ghost

# Check if frog is at goal region, play winning sound if so
la $s2, frog_y		# $s2 = Addr(frog_y)
lw $s3, 0($s2)		# $s3 = frog_y
li $s4, 4		# $s4 = 4
ble $s3, $s4, play_victory_sound	
exit_victory_sound:

sw $t8, 0($t0) 		# paint the first (top-left) unit pink.
sw $t8, 12($t0) 	# paint the second (top-right) unit pink.
sw $t8, 128($t0)	# Painting continued, Top left to bottom right, Beginning of second row
sw $t8, 132($t0)
sw $t8, 136($t0)
sw $t8, 140($t0)
sw $t8, 260($t0)	# Beginning of third row
sw $t8, 264($t0)
sw $t8, 384($t0)	# Beginning of fourth row
sw $t8, 388($t0)
sw $t8, 392($t0)
sw $t8, 396($t0)

#
# End of section 3
#

jr $ra
# End of the function draw_frog
# ----------------------------------------------------------------------------------------------


Exit:
li $v0, 10 # terminate the program gracefully
syscall
