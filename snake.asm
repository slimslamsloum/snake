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


; initialize stack pointer
addi    sp, zero, LEDS

; main
; arguments
;     none
;
; return values
;     This procedure should never return.
main:
    ; TODO: Finish this procedure.

    call clear_leds

    addi t0, zero, 4
    stw t0, GSA(zero)
    

    loop:

        call clear_leds
        call get_input
        addi a0, zero, 0
        call move_snake
        call draw_array
        beq zero, zero, loop

        ret

    ret
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

; END: display_score


; BEGIN: init_game
init_game:

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

; END: hit_test



;BEGIN: get_input
get_input:

    add v0, zero,zero ;init vo to zero 
    ldw t0, BUTTONS+4(zero) ; load edge capture button

    ;none case
    andi t0, t0, 63 ; mask the buttons to get the fourth firts bits
    addi t1, zero, 32; init a mask
    and t2, t0, t1 ; mask it
    beq t1, t2, none; test for checkpoint case 

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

    ;none case 
    srai t1, t1, 1 ; shift again 
    and t2, t0, t1 ; mask it
    beq t1, t2, none ; for none case 

    ; handle none case
    none: 
        stw zero, BUTTONS+4(zero); put buttons at zero
        ret
    ; handle the left case 
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
        addi v0, zero, DIR_LEFT ; init v0 to the good direction's value 
        stw  zero, BUTTONS+4(zero) ; put edge button to zero again 

        ret
    ; handle the up case 
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
        addi v0, zero, 2 ; init v0 to the good direction's value
        stw  zero, BUTTONS+4(zero) ; put edge button to zero again 

        ret
    ;handle the down case 
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
        addi v0, zero, DIR_DOWN ; init v0 to the good direction's value
        stw  zero, BUTTONS+4(zero) ; put edge button to zero again 

        ret
    ;handle the right case 
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
        addi v0, zero, DIR_RIGHT ; init v0 to the good direction's value
        stw  zero, BUTTONS+4(zero) ; put edge button to zero again 

        ret
   
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

 addi t0, t0, -1
 stw t0, HEAD_X(zero)
 addi t4, t4, -32
 stw t3, GSA(t4)

 beq a0, zero, no_food ; branch to no_food if a1 is 0

 ret

 ; END: head_left


; BEGIN: head_up

 head_up: 

 addi t1, t1, -1
 stw t1, HEAD_Y(zero)
 addi t4, t4, -4
 stw t3, GSA(t4)

 beq a0, zero, no_food ; branch to no_food if a1 is 0
 
 ret

 ; END: head_up
 

; BEGIN: head_right

 head_right:   

 addi t0, t0, 1
 stw t0, HEAD_X(zero)
 addi t4, t4, 32
 stw t3, GSA(t4)

 beq a0, zero, no_food ; branch to no_food if a1 is 0

 ret

 ; END: head_right

; BEGIN: head_down

 head_down: 

 addi t1, t1, 1
 stw t1, HEAD_Y(zero)
 addi t4, t4, 4
 stw t3, GSA(t4)

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

 stw zero, GSA(t4)
 addi t0, t0, -1
 stw t0, TAIL_X(zero)
 addi t4, t4, -32
 stw t3, GSA(t4)

 ret

 ; END: tail_left


; BEGIN: tail_up

 tail_up: 

 stw zero, GSA(t4)
 addi t1, t1, -1
 stw t1, TAIL_Y(zero)
 addi t4, t4, -4
 stw t3, GSA(t4)

 ret

 ; END: tail_up
 
     
; BEGIN: tail_right

 tail_right:   

 stw zero, GSA(t4)
 addi t0, t0, 1
 stw t0, TAIL_X(zero)
 addi t4, t4, 32
 stw t3, GSA(t4)

 ret

 ; END: tail_right


; BEGIN: tail_down

 tail_down: 

 stw zero, GSA(t4)
 addi t1, t1, 1
 stw t1, TAIL_Y(zero)
 addi t4, t4, 4
 stw t3, GSA(t4)

 ret

; END: tail_down


; END: move_snake


; BEGIN: save_checkpoint
save_checkpoint:

; END: save_checkpoint


; BEGIN: restore_checkpoint
restore_checkpoint:

; END: restore_checkpoint


; BEGIN: blink_score
blink_score:

; END: blink_score
