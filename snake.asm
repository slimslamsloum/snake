;    set game state memory location
.equ    HEAD_X,         0x1000  ; Snake head's position on x
.equ    HEAD_Y,         0x1004  ; Snake head's position on y
.equ    TAIL_X,         0x1008  ; Snake tail's position on x
.equ    TAIL_Y,         0x100C  ; Snake tail's position on Y
.equ    SCORE,          0x1010  ; Score address
.equ    GSA,            0x1014  ; Game state array address

.equ    CP_VALID,       0x1200  ; Whether the checkpoint is valid.
.equ    CP_HEAD_X,      0x1204  ; Snake head's X coordinate. (Checkpoint)
.equ    CP_HEAD_Y,      0x1208  ; Snake head's Y coordinate. (Checkpoint)
.equ    CP_TAIL_X,      0x120C  ; Snake tail's X coordinate. (Checkpoint)
.equ    CP_TAIL_Y,      0x1210  ; Snake tail's Y coordinate. (Checkpoint)
.equ    CP_SCORE,       0x1214  ; Score. (Checkpoint)
.equ    CP_GSA,         0x1218  ; GSA. (Checkpoint)

.equ    LEDS,           0x2000  ; LED address
.equ    SEVEN_SEGS,     0x1198  ; 7-segment display addresses
.equ    RANDOM_NUM,     0x2010  ; Random number generator address
.equ    BUTTONS,        0x2030  ; Buttons addresses

; button state
.equ    BUTTON_NONE,    0
.equ    BUTTON_LEFT,    1
.equ    BUTTON_UP,      2
.equ    BUTTON_DOWN,    3
.equ    BUTTON_RIGHT,   4
.equ    BUTTON_CHECKPOINT,    5

; array state
.equ    DIR_LEFT,       1       ; leftward direction
.equ    DIR_UP,         2       ; upward direction
.equ    DIR_DOWN,       3       ; downward direction
.equ    DIR_RIGHT,      4       ; rightward direction
.equ    FOOD,           5       ; food

; constants
.equ    NB_ROWS,        8       ; number of rows
.equ    NB_COLS,        12      ; number of columns
.equ    NB_CELLS,       96      ; number of cells in GSA
.equ    RET_ATE_FOOD,   1       ; return value for hit_test when food was eaten
.equ    RET_COLLISION,  2       ; return value for hit_test when a collision was detected
.equ    ARG_HUNGRY,     0       ; a0 argument for move_snake when food wasn't eaten
.equ    ARG_FED,        1       ; a0 argument for move_snake when food was eaten

;Param
.equ    TIMER,          5000   ; latence 


; initialize stack pointer
addi    sp, zero, LEDS

; main
; arguments
;     none
;
; return values
;     This procedure should never return.
main:

    stw zero, CP_VALID(zero) ; cp_valid starts at 0

    ; BEGIN: loop_init_game
    loop_init_game:

        call init_game

        ; BEGIN: loop_get_input
        loop_get_input:
            call get_input
            add t0, zero, v0 ; load which button pressed
            addi t1, zero, 5
            beq t0, t1, checkpoint
            bne t0, t1, not_checkpoint

            ; BEGIN: checkpoint
            checkpoint:

                call restore_checkpoint
                ldw t0, CP_VALID(zero)
                addi t1, zero, 1
                beq t0, t1, cp_valid
                beq t0, zero, cp_not_valid

                ; BEGIN: cp_valid
                cp_valid:

                    call blink_score
                    call clear_leds
                    call draw_array
                    call loop_get_input

                ret
                ; END: cp_valid

                ; BEGIN: cp_not_valid
                cp_not_valid:

                    call loop_get_input

                ret
                ; END: cp_not_valid
            ret
            ; END: checkpoint

            ; BEGIN: not_checkpoint
            not_checkpoint:

                call hit_test
                add t0, zero, v0
                addi t1, zero, 1
                beq t0, t1, eat_food
                bne t0, t1, no_eat_food

                ; BEGIN: eat_food
                eat_food:

                    ldw t0, SCORE(zero)
                    addi t0, t0, 1
                    stw t0, SCORE(zero)

                    call display_score
                    call move_snake
                    call create_food
                    call save_checkpoint

                    add t0, zero, v0

                    addi t1, zero, 1
                    beq t0, t1, save_cp
                    beq t0, zero, dont_save_cp

                    ; BEGIN: save_cp
                    save_cp:

                        call blink_score
                        call clear_leds
                        call draw_array
                        call loop_get_input

                    ret
                    ; END: save_cp
                        
                    ; BEGIN: dont_save_cp
                    dont_save_cp:

                        call clear_leds
                        call draw_array
                        call loop_get_input

                    ret
                    ; END: dont_save_cp

                ret
                ; END: eat_food
                
                ; BEGIN: no_eat_food
                no_eat_food:

                    addi t1, zero, 2
                    beq t0, t1, collide
                    beq t0, zero, dont_collide

                    ; BEGIN: collide
                    collide:

                        call loop_init_game

                    ret
                    ; END: collide

                    ; BEGIN: dont_collide
                    dont_collide:
                        call move_snake
                        call clear_leds
                        call draw_array
                        call loop_get_input

                    ret
                    ; END: dont_collide
                ret
                ; END: no_eat_food
            ret
            ; END: not_checkpoint
        ret
        ; END: loop_get_input
    ret
    ; END: loop_init_game

; BEGIN: clear_leds
clear_leds:

    stw zero, LEDS(zero)
    stw zero, LEDS+4(zero)
    stw zero, LEDS+8(zero)

    ret

; END: clear_leds


; BEGIN: set_pixel
set_pixel:

    andi t0, a0, 3 ; t0 = a0 mod 4
    slli t0, t0, 3 ; multiply t0 by 8  
    add t0, a1, t0 ; t0 = a1+t0
    addi t1, zero, 1 ; t1 = 1
    sll t0, t1, t0 ; shift t1 by t0
    srli t2, a0, 2 ; a0 is divided by 4 (division entière)
    slli t2, t2, 2 ; t2 is multiplied by 4
    addi t2, t2, LEDS ; t2 has correct leds address
    ldw t3, 0(t2) ; get the previous state of the leds
    or t3, t3, t0 ; combine with new turned on pixel 
    stw t3, 0(t2) ; store new state of pixels in correct address

    ret

; END: set_pixel


; BEGIN: display_score
display_score:
    ldw t0, SCORE(zero) ;load the score 

    addi t1, zero, zero
    addi t2, zero, zero

    ;BEGIN: unit_loop
    unit_loop:
        addi t2, t2, 1
        addi t0, t0, -10
        blt t0, zero, set_process
        br unit_loop
    ; END: unit_loop

    ; BEGIN: set_process
    set_process:
        addi t1, t1, 10
        addi t2, t2, -1

        ret
    ;END: set_process

    ldw t1, digit_map(t1) ; load
    ldw t2, digit_map(t2) ; load
    stw t1, SEVEN_SEGS+12(zero) ; change the value 
    stw t2, SEVEN_SEGS+8(zero) ; change the value 
    
; END: display_score


; BEGIN: init_game
init_game:
    call clear_leds         ; clear the leds

    stw  zero, HEAD_X(zero) ; init the head x
    stw  zero, HEAD_Y(zero) ; init the head y
    stw  zero, TAIL_X(zero) ; init the tail x
    stw  zero, TAIL_Y(zero) ; init the tail y 
    stw zero, SCORE(zero)   ; init the score to zero
    
    addi t0, zero, DIR_RIGHT       ; init the right direction
    stw t0, GSA(zero)       ; put the right direction 
    addi a0, zero, zero     ; reset the values that could be important and put some sides effect 

    call create_food        ; create food at random 
    call display_score      ; display the initial score 
    call draw_array         ; switch on and init the goods leds 

; END: init_game


; BEGIN: create_food
create_food:

    ; init the state 
 	ldw t0, RANDOM_NUM(zero)
    andi t0, t0, 255
	addi t1, zero, 0
	addi t2, zero, 96 
	addi t3, zero, FOOD

	; check the boundaries 0<=
	; BEGIN: check_more_than_zero
	check_more_than_zero: 
		bge t0, t1, check_less
		br create_food
	; END: check_less

	; check the boundaries <96 
	; BEGIN: check_less
	check_less:
		blt t0, t2, check_is_snake
		br create_food 
	;END: check_less

	; check if we overlap with the snake
	; BEGIN: check_is_snake
	check_is_snake:
		slli t0, t0, 2
		ldw t2, GSA(t0) 
		bne t2, t1, create_food
		stw t3, GSA(t0)
		
		ret
	; END: check_is_snake
		

	; END: create_food


; BEGIN: hit_test
hit_test:

    ; t0 and t1 will be coordinates of next head position
    ; t4 will be address in gsa of next head position
    ; t2 is columns
    ; t5 is rows

    ldw t0, HEAD_X(zero) ; load head_x coordinate
    slli t4, t0, 3 ; multiply head_x by 8
    ldw t1, HEAD_Y(zero) ; load head_y coordinate
    add t4, t4, t1 ; add head_y and 8*head_x
    slli t4, t4, 2 ; multiply result by 4 
    ldw t3, GSA(t4) ; load word at address GSA + t4

    addi t2, zero, BUTTON_LEFT
    beq t3, t2, get_left ; head left case
    addi t2, zero, BUTTON_UP
    beq t3, t2, get_up ; head up case
    addi t2, zero, BUTTON_RIGHT
    beq t3, t2, get_right ; head right case
    addi t2, zero, BUTTON_DOWN
    beq t3, t2, get_down ; head down case

    ; BEGIN: get_left
    get_left:

        addi t2, zero, NB_COLS
        addi t5, zero, NB_ROWS

        addi t0, t0, -1
        addi t4, t4, -32
        ldw t3, GSA(t4) ; load word at address GSA + t4

        bge t1, t5, end_game ; y coordinate is out of range
        blt t1, zero, end_game ; y coordinate is out of range
        bge t0, t2, end_game ; x coordinate is out of range
        blt t0, zero, end_game ; x coordinate is out of range

        addi t2, zero, 5
        beq t3, t2, is_food ; collision with food

        bne t3, zero, end_game ; collide with itself

        ldw t2, 0(v0) ; load in t2 the value of v0
        addi t5, zero, 1 ; store in t5 the value 1
        blt t2, t5, no_collision ; branch to no_collision if v0 is smaller than 1
        addi t5, zero, 3 ; store in t5 the value 3
        bge t2, t5, no_collision ; branch to no_collision if v0 is bigger or equal than 3

        ret
    ; END: get_left

    ; BEGIN: get_up
    get_up:

        addi t2, zero, NB_COLS
        addi t5, zero, NB_ROWS

        addi t1, t1, -1
        addi t4, t4, -4
        ldw t3, GSA(t4) ; load word at address GSA + t4

        bge t1, t5, end_game ; y coordinate is out of range
        blt t1, zero, end_game ; y coordinate is out of range
        bge t0, t2, end_game ; x coordinate is out of range
        blt t0, zero, end_game ; x coordinate is out of range

        addi t2, zero, 5
        beq t3, t2, is_food ; collision with food

        bne t3, zero, end_game ; collide with itself

        ldw t2, 0(v0) ; load in t2 the value of v0
        addi t5, zero, 1 ; store in t5 the value 1
        blt t2, t5, no_collision ; branch to no_collision if v0 is smaller than 1
        addi t5, zero, 3 ; store in t5 the value 3
        bge t2, t5, no_collision ; branch to no_collision if v0 is bigger or equal than 3

        ret
    ; END: get_up

    ; BEGIN: get_right
    get_right:

        addi t2, zero, NB_COLS
        addi t5, zero, NB_ROWS

        addi t0, t0, 1
        addi t4, t4, 32
        ldw t3, GSA(t4) ; load word at address GSA + t4

        bge t1, t5, end_game ; y coordinate is out of range
        blt t1, zero, end_game ; y coordinate is out of range
        bge t0, t2, end_game ; x coordinate is out of range
        blt t0, zero, end_game ; x coordinate is out of range

        addi t2, zero, 5
        beq t3, t2, is_food ; collision with food

        bne t3, zero, end_game ; collide with itself

        ldw t2, 0(v0) ; load in t2 the value of v0
        addi t5, zero, 1 ; store in t5 the value 1
        blt t2, t5, no_collision ; branch to no_collision if v0 is smaller than 1
        addi t5, zero, 3 ; store in t5 the value 3
        bge t2, t5, no_collision ; branch to no_collision if v0 is bigger or equal than 3

        ret
    ; END: get_right

    ; BEGIN: get_down
    get_down:

        addi t2, zero, NB_COLS
        addi t5, zero, NB_ROWS

        addi t1, t1, 1
        addi t4, t4, 4
        ldw t3, GSA(t4) ; load word at address GSA + t4

        bge t1, t5, end_game ; y coordinate is out of range
        blt t1, zero, end_game ; y coordinate is out of range
        bge t0, t2, end_game ; x coordinate is out of range
        blt t0, zero, end_game ; x coordinate is out of range

        addi t2, zero, 5
        beq t3, t2, is_food ; collision with food

        bne t3, zero, end_game ; collide with itself

        ldw t2, 0(v0) ; load in t2 the value of v0
        addi t5, zero, 1 ; store in t5 the value 1
        blt t2, t5, no_collision ; branch to no_collision if v0 is smaller than 1
        addi t5, zero, 3 ; store in t5 the value 3
        bge t2, t5, no_collision ; branch to no_collision if v0 is bigger or equal than 3

        ret
    ; END: get_down

    ; BEGIN: is_food
    is_food:

        addi v0, zero, 1
        ret
    ; END: is_food

    ; BEGIN: end_game
    end_game:

        addi v0, zero, 2
        ret
    ; END: end_game

    ; BEGIN: no_collision
    no_collision:

        addi v0, zero, 0
        ret
    ; END: no_collision

    ; END: hit_test



;BEGIN: get_input
get_input:

    add v0, zero,zero ;init vo to zero 
    ldw t0, BUTTONS+4(zero) ; load edge capture button

    ;checkpoint case
    andi t0, t0, 31 ; mask the buttons to get the fourth firts bits
    addi t1, zero, 16; init a mask
    and t2, t0, t1 ; mask it
    beq t1, t2, checkPoint; test for checkpoint case 

    ;right case
    srai t1, t1, 1 ; shift again
    and t2, t0, t1 ; mask it
    beq t1, t2, right ; for right case 

    ;down case
    srai t1, t1, 1 ; shift again 
    and t2, t0, t1 ; mask it
    beq t1, t2, down ; for down case 

    ;up case
    srai t1, t1, 1 ; shift again
    and t2, t0, t1 ; mask it 
    beq t1, t2, up ; for up case 
    
    ;left case
    srai t1, t1, 1 ; shift again 
    and t2, t0, t1 ; mask it
    beq t1, t2, left ; for left case 

    ;handle the none case
    br none

    ; BEGIN: none
    none:
        stw zero, BUTTONS+4(zero); put buttons at zero
        ret
    ; END: none
    
    

    ; BEGIN: checkPoint
    checkPoint:
        stw zero, BUTTONS+4(zero); put buttons at zero
        addi v0, zero, BUTTON_CHECKPOINT ; init v0 to the good button
        ret
    ; END: checkPoint

    ; BEGIN: left
    left: 
        ldw t0, HEAD_X(zero) ; load head x position
        ldw t1, HEAD_Y(zero) ; load head y position 

        slli t4, t0, 3  ; multiply head_x with 8
        add t3, t1, t4 ; add head_y with (head_x * 8)
        slli t3, t3, 2 ; multiply by 4 to get the good word in gsa
        addi t2, zero, DIR_LEFT ; init a register at 1
        addi t5, zero, DIR_RIGHT ; init a register at 4 (right direction)
        ldw t4, GSA(t3); load the current value that is in the gsa
        beq t4, t5, none ; if it indicate an opposite direction ignore the action
        stw t2, GSA(t3) ; change the value of the head direction in the gsa
        addi v0, zero, BUTTON_LEFT ; init v0 to the good direction's value 
        stw  zero, BUTTONS+4(zero) ; put edge button to zero again 

        ret
    ; END: left

    ; BEGIN: up
    up:
        ldw t0, HEAD_X(zero) ; load head x position
        ldw t1, HEAD_Y(zero) ; load head y position 

        slli t4, t0, 3  ; multiply head_x with 8
        add t3, t1, t4 ; add head_y with (head_x * 8)
        slli t3, t3, 2 ; multiply by 4 to get the good word in gsa
        addi t2, zero, DIR_UP ; init a register at 2
        addi t5, zero, DIR_DOWN ; init a register at 3 (down direction)
        ldw t4, GSA(t3); load the current value that is in the gsa
        beq t4, t5, none ; if it indicate an opposite direction ignore the action
        stw t2, GSA(t3); change gsa
        addi v0, zero, BUTTON_UP ; init v0 to the good direction's value
        stw  zero, BUTTONS+4(zero) ; put edge button to zero again 

        ret
    ; END: up

    ; BEGIN: down
    down:
        ldw t0, HEAD_X(zero) ; load head x position
        ldw t1, HEAD_Y(zero) ; load head y position 

        slli t4, t0, 3  ; multiply head_x with 8
        add t3, t1, t4 ; add head_y with (head_x * 8)
        slli t3, t3, 2 ; multiply by 4 to get the good word in gsa
        addi t2, zero, DIR_DOWN ; init a register at 3
        addi t5, zero, DIR_UP ; init a register at 2 (up direction)
        ldw t4, GSA(t3); load the current value that is in the gsa
        beq t4, t5, none ; if it indicate an opposite direction ignore the action
        stw t2, GSA(t3); change gsa
        addi v0, zero, BUTTON_DOWN ; init v0 to the good direction's value
        stw  zero, BUTTONS+4(zero) ; put edge button to zero again 

        ret
    ; END: down
    
    ; BEGIN: right
    right:
        ldw t0, HEAD_X(zero) ; load head x position
        ldw t1, HEAD_Y(zero) ; load head y position 

        slli t4, t0, 3  ; multiply head_x with 8
        add t3, t1, t4 ; add head_y with (head_x * 8)
        slli t3, t3, 2 ; multiply by 4 to get the good word in gsa
        addi t2, zero, DIR_RIGHT ; init a register at 4
        addi t5, zero, DIR_LEFT ; init a register at 1 (left direction)
        ldw t4, GSA(t3); load the current value that is in the gsa
        beq t4, t5, none ; if it indicate an opposite direction ignore the action
        stw t2, GSA(t3); change gsa
        addi v0, zero, BUTTON_RIGHT; init v0 to the good direction's value
        stw  zero, BUTTONS+4(zero) ; put edge button to zero again 

        ret
    ; END: right
   
; END: get_input


; BEGIN: draw_array
draw_array:
		addi s0, zero, NB_CELLS 
        addi t0, zero, 0
        addi s1, zero, 0
    ; BEGIN: search_loop
    search_loop:
        beq s1, s0, draw_end ; test if we are at the end of the GSA
        slli t3, s1, 2 ; multiply by 4 to get the good word 
        ldw t3 , GSA(t3) ; load the word 
        bne zero, t3, switch_on_led ; check if the leds 
        addi s1, s1, 1; if not go to the next word 
        br search_loop
    ; End: search_loop

    ; BEGIN: switch_on_led 
    switch_on_led:
        andi a1, s1, 7 ; get a1->y 
        sub  t4, s1, a1 ; substract y to the value 
        srli a0, t4, 3 ; get a0 -> x

        ; handle the stack pointer 
        addi sp, sp, -4 
        stw ra, 0(sp)

        call set_pixel ; call set pixel => LOOK TO THE GOOD CALL 
        
		;handle the sp
		ldw ra, 0(sp)
		addi sp, sp, 4
		
        addi s1, s1, 1; go to the next word 
        br search_loop
    ; END: switch_on_led

    ; BEGIN: draw_end
    draw_end:
    ret
    ; END: draw_end 

; END: draw_array
    

; BEGIN: move_snake

move_snake:

    ; t0 is head_x or tail_x
    ; t1 is head_y or tail_y
    ; t3 is direction
    ; t4 is head/tail gsa


    ldw t0, HEAD_X(zero) ; load head_x coordinate
    slli t4, t0, 3 ; multiply head_x by 8
    ldw t1, HEAD_Y(zero) ; load head_y coordinate
    add t4, t4, t1 ; add head_y and 8*head_x
    slli t4, t4, 2 ; multiply result by 4 
    ldw t3, GSA(t4) ; load word at address GSA + t4

    addi t2, zero, BUTTON_LEFT
    beq t3, t2, head_left ; head left case
    addi t2, zero, BUTTON_UP
    beq t3, t2, head_up ; head up case
    addi t2, zero, BUTTON_RIGHT
    beq t3, t2, head_right ; head right case
    addi t2, zero, BUTTON_DOWN
    beq t3, t2, head_down ; head down case


    ; BEGIN: head_left
    head_left: 

        addi t0, t0, -1 ; substract 1 from x coordinates
        stw t0, HEAD_X(zero) ; store in head_x new value
        addi t4, t4, -32 ; get new corresponding position of head
        stw t3, GSA(t4) ; store in new position of head the direction

        beq a0, zero, no_food ; branch to no_food if a1 is 0

        ret
    ; END: head_left


    ; BEGIN: head_up
    head_up: 

        addi t1, t1, -1 ; substract 1 from y coordinates
        stw t1, HEAD_Y(zero) ; store in head_y new value
        addi t4, t4, -4 ; get new corresponding position of head
        stw t3, GSA(t4) ; store in new position of head the direction

        beq a0, zero, no_food ; branch to no_food if a1 is 0
        
        ret
    ; END: head_up
    

    ; BEGIN: head_right
    head_right:   

        addi t0, t0, 1 ; add 1 to x coordinates
        stw t0, HEAD_X(zero) ; store in head_x new value
        addi t4, t4, 32 ; get new corresponding position of head
        stw t3, GSA(t4) ; store in new position of head the direction

        beq a0, zero, no_food ; branch to no_food if a1 is 0

        ret
    ; END: head_right

    ; BEGIN: head_down
    head_down: 

        addi t1, t1, 1 ; add 1 to y coordinates
        stw t1, HEAD_Y(zero) ; store in head_y new value
        addi t4, t4, 4 ; get new corresponding position of head
        stw t3, GSA(t4) ; store in new position of head the direction

        beq a0, zero, no_food ; branch to no_food if a1 is 0

        ret
    ; END: head_down


    ; BEGIN: no_food
    no_food:

        ldw t0, TAIL_X(zero) ; load tail_x coordinate
        slli t4, t0, 3 ; multiply tail_x by 8
        ldw t1, TAIL_Y(zero) ; load tail_y coordinate
        add t4, t4, t1 ; add tail_y and 8*tail_x
        slli t4, t4, 2 ; multiply result by 4 
        ldw t3, GSA(t4) ; get current 

        addi t2, zero, BUTTON_LEFT
        beq t3, t2, tail_left ; tail left case
        addi t2, zero, BUTTON_UP
        beq t3, t2, tail_up ; tail up case
        addi t2, zero, BUTTON_RIGHT
        beq t3, t2, tail_right ; tail right case
        addi t2, zero, BUTTON_DOWN
        beq t3, t2, tail_down ; tail down case

        ret

    ; END: no_food


    ; BEGIN: tail_left
    tail_left: 

        stw zero, GSA(t4) ; previous tail value in GSA is 0
        addi t0, t0, -1 ; tail_x is substracted by 1
        stw t0, TAIL_X(zero) ; store new value of tail_x in TAIL_X
       

        ret
    ; END: tail_left


    ; BEGIN: tail_up
    tail_up: 

        stw zero, GSA(t4) ; previous tail value in GSA is 0
        addi t1, t1, -1 ; tail_y is substracted by 1
        stw t1, TAIL_Y(zero) ; store new value of tail_y in TAIL_Y
      
        ret
    ; END: tail_up
    
        
    ; BEGIN: tail_right
    tail_right:   

        stw zero, GSA(t4) ; previous tail value in GSA is 0
        addi t0, t0, 1 ; we add 1 to tail_x
        stw t0, TAIL_X(zero) ; store new value of tail_x in TAIL_X
 
        ret
    ; END: tail_right


    ; BEGIN: tail_down

    tail_down: 

        stw zero, GSA(t4) ; previous tail value in GSA is 0
        addi t1, t1, 1 ; we add 1 to tail_y
        stw t1, TAIL_Y(zero) ; store new value of tail_y in TAIL_Y
       ; addi t4, t4, 4 ; get new corresponding value of tail in GSA
       ; stw t3, GSA(t4) ; store direction of new tail in GSA

        ret

    ; END: tail_down


; END: move_snake


; BEGIN: save_checkpoint
save_checkpoint:
    addi v0, zero, zero     ; init to zero the return value
    addi t0, zero, 10       ; init the 10 immediate
    ldw t1, SCORE(zero)     ; load the current score 

    ; BEGIN: ten_loop
    ten_loop:
    addi t1, t1, -10                ; sub ten to the score
    beq t1, zero, saving_procedure  ; check if i am a multiple of 10 
    blt t1, zero, no_checkpoint     ; no checkpoint procedure
    br ten_loop                     ; if no test is fullfield the loop
    ; END; ten_loop

    ; BEGIN: saving_procedure 
    saving_procedure:
    
        addi t0, zero, 1        ; init a bit  
        addi v0, zero, 1        ; init v0 to 1
        stw t0, CP_VALID(zero)  ; init the checkpoint 

        addi s0, zero, 0x1000     ; init a register to the number of word in the GSA 
        addi s1, zero, 0x1204     ; init start of checkpoint
        addi s2, zero, 0x1194     ; end 

        ; BEGIN: loop_word
        loop_word:
            addi a0, zero, s0               ; init arg 1
            addi a1, zero, s1               ; init arg 2
            call copy_memory                ; call the copy memory process
            beq s0, s2, return_process      ; testing if reached the end of the GSA
            addi s0, s0, 4                  ; if not then counter +4
            addi s1, s1, 4                  ; if not then counter +4
            br loop_word                    ; branch to the loop again 

        ; END: loop_word 

        ; BEGIN: return_process
        return_process:
            ret
        ; END: return_process

        ret
    ; END: saving_procedure 

    ; BEGIN: no_checkpoint
    no_checkpoint:
        ret
    ; END: no_checkpoint

; END: save_checkpoint


; BEGIN: restore_checkpoint
restore_checkpoint:
    addi t2, zero, 1
    ldw t0, CP_VALID(zero) ; load word at address CP_VALID
    beq t0, t2, valid ; branch if is valid
    bne t0, zero, not_valid ; branch if isn't valid

    ; BEGIN: valid
    valid: 
    
        addi s0, zero, 0x1204     ; init start checkpoint 
        addi s1, zero, 0x1000     ; init start
        addi s2, zero, 0x1194     ; end 

        ; BEGIN: loop_word_res
        loop_word_res:
            addi a0, zero, s0               ; init arg 1
            addi a1, zero, s1               ; init arg 2
            call copy_memory                ; call the copy memory process
            beq s1, s2, ret_process      ; testing if reached the end of the GSA
            addi s0, s0, 4                  ; if not then counter +4
            addi s1, s1, 4                  ; if not then counter +4
            br loop_word_res                    ; branch to the loop again 

        ; END: loop_word_res 

        ; BEGIN: ret_process
        ret_process:
            addi v0, zero, 1
            ret
        ; END: ret_process
        ret
    ; END: valid

    ; BEGIN: not_valid
    not_valid: 
        addi v0, zero, 0
        ret
    ; END: not_valid

; END: restore_checkpoint

; BEGIN: copy_memory
copy_memory:
    ; a0 is the start memory address 
    ; a1 is the destination memory address 
    ldw t0, a0(zero)    ; load the memory region
    stw t0, a1(zero)    ; and copy the good memory region in the destination

    ret
; END: copy_memory


; BEGIN: blink_score
blink_score:
    addi s1, zero, 6

    ; BEGIN: blink_procedure
    blink_procedure:
        slli t0, s1, 1              ; modulo 2 
        beq t0, zero, display_score ; if the counter modulo 2 then switch on the light
        bne t0, zero, switch_off    ; if the counter is not modulo 2 then switch off 
        call wait_procedure         ; call the waiting procedure 
        addi s1, s1, -1
        jmpi blink_procedure
    ; END: blink_procedure

    ; BEGIN: switch_off
    switch_off:
        stw zero, SEVEN_SEGS(zero)   ; switch off the light
        stw zero, SEVEN_SEGS+4(zero) ; switch off the light
        stw zero, SEVEN_SEGS+8(zero) ; switch off the light 
        stw zero, SEVEN_SEGS+12(zero); switch off the light 
    ; END: switch_off 

; END: blink_score

; BEGIN: wait_procedure
wait_procedure:

    addi s0, zero, TIMER
    slli s0, s0, 10 

    ; BEGIN
    loop_time:
        beq s0, zero, return_procedure
        addi s0, t0, -1
    ; END

    ; BEGIN
    return_procedure:
        ret
    ; END

; END: wait_procedure

; BEGIN: digit_map
digit_map:
    .word 0xFC ; 0
    .word 0x60 ; 1
    .word 0xDA ; 2
    .word 0xF2 ; 3
    .word 0x66 ; 4
    .word 0xB6 ; 5
    .word 0xBE ; 6
    .word 0xE0 ; 7
    .word 0xFE ; 8
    .word 0xF6 ; 9