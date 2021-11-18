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

; Param
.equ    TIMER,          15000   ; latence 

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

; END: init_game


; BEGIN: create_food
create_food:

; END: create_food


; BEGIN: hit_test
hit_test:

; END: hit_test


; BEGIN: get_input
get_input:

; END: get_input


; BEGIN: draw_array
draw_array:

; END: draw_array


; BEGIN: move_snake
move_snake:

; END: move_snake


; BEGIN: save_checkpoint
save_checkpoint:

; END: save_checkpoint


; BEGIN: restore_checkpoint
restore_checkpoint:

; END: restore_checkpoint


; BEGIN: blink_score
blink_score:
    addi s1, zero, 6

    ; BEGIN: blink_procedure
    blink_procedure:
        slli t0, s1, 1 ; modulo 2 
        beq t0, zero, switch_on ; if the counter modulo 2 then switch on the light
        bne t0, zero, switch_off; if the counter is not modulo 2 then switch off 
        addi s1, s1, -1
        jmpi blink_procedure
    ; END: blink_procedure

    ; BEGIN: switch_on 
    switch_on:
        call display_score ; switch on the light 
    ; END: switch_on 

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

    ; BEGIN
    loop_time:
        beq s0, zero, return_procedure
        addi s0, t0, -1
    ; END

    ; BEGIN
    return_procedure:
        ret
    ; END

; EnD: wait_procedure

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