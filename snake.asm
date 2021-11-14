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

    ret


; BEGIN: clear_leds
clear_leds:

; END: clear_leds


; BEGIN: set_pixel
set_pixel:

; END: set_pixel


; BEGIN: display_score
display_score:

; END: display_score


; BEGIN: init_game
init_game:

; END: init_game


; BEGIN: create_food
create_food:

; END: create_food


; BEGIN: hit_test
hit_test:

; END: hit_test

;TODO add the fact that he can't go in the opposite direction 
; BEGIN: get_input
get_input:

add v0, zero,zero ;init vo to zero 
andi t0, BUTTONS+4, 31 ; mask the buttons to get the fourth firts bits
sra t1, t0, 1 ; shift one to get the first bit
addi t2, zero, 1; init a bit
beq t1, t2, none; test for none case 
sra t1, t1, 1 ; shift again
beq t1, t1, left ; for left case 
sra t1, t1, 1 ; shift again 
beq t1, t1, up ; for up case 
sra t1, t1, 1 ; shift again 
beq t1, t1, down ; for down case 
sra t1, t1, 1 ; shift again 
beq t1, t1, right ; for right case 
sra t1, t1, 1 ; shift again 
beq t1, t1, checkpoint ; for checkpoint case 

; handle right case
none: 

stw BUTTONS+4, zero ; put buttons at zero

ret

; handle the left case 
left: 

slli t4, HEAD_X, 3  ; multiply head_x with 8
add t3, HEAD_Y, t4 ; add head_y with (head_x + 8)
slli t3, t3, 2 ; multiply by 4 to get the good word in gsa
addi t2, zero, 1 ; init a register at 1
stw t2, GSA(t3) ; change the value of the head direction in the gsa
addi v0, zero, 1 ; init v0 to the good direction's value 
stw  zero, BUTTONS+4(zero) ; put edge button to zero again 

ret
; handle the up case 
up:

slli t4, HEAD_X, 3 ; multiply head_x with 8
add t3, HEAD_Y, t4 ; add head_y with (head_x + 8)
slli t3, t3, 4 ; multiply by 4 to get the good word in gsa
addi t2, zero, 2 ; init a register at 2
lstw t2, GSA(t3); change gsa
addi v0, zero, 2 ; init v0 to the good direction's value
stw  zero, BUTTONS+4(zero) ; put edge button to zero again 

ret
;handle the down case 
down:

slli t4, HEAD_X, 8  ; multiply head_x with 8
add t3, HEAD_Y, t4 ; add head_y with (head_x + 8)
slli t3, t3, 4 ; multiply by 4 to get the good word in gsa
addi t2, zero, 3 ; init a register at 3
stw t2, GSA(t3); change gsa
addi v0, zero, 3 ; init v0 to the good direction's value
stw  zero, BUTTONS+4(zero) ; put edge button to zero again 
ret
;handle the right case 
right:

slli t4, HEAD_X, 8  ; multiply head_x with 8
add t3, HEAD_Y, t4 ; add head_y with (head_x + 8)
slli t3, t3, 4 ; multiply by 4 to get the good word in gsa
addi t2, zero, 4 ; init a register at 4
stw t2, GSA(t3); change gsa
addi v0, zero, 4 ; init v0 to the good direction's value
stw  zero, BUTTONS+4(zero) ; put edge button to zero again 

ret
;handle the checkpoiny case 
checkpoint:

slli t4, HEAD_X, 8 ; multiply head_x with 8 
add t3, HEAD_Y, t4 ; add head_y with (head_x + 8)
slli t3, t3, 4 ; multiply by 4 to get the good word in gsa
addi t2, zero, 5 ; init a register at 5
stw t2, GSA(t3); change gsa
addi v0, zero, 5 ; init v0 to the good direction's value
stw  zero, BUTTONS+4(zero) ; put edge button to zero again 

ret
; END: get_input


; BEGIN: draw_array
draw_array:

; END: draw_array


; BEGIN: move_snake
move_snake:

ldw t0, 0(CP_HEAD_X)
ldw t1, GSA(t0)

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
