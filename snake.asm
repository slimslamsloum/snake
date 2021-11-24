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

    ldw t0, CP_VALID(zero) ; load word at address CP_VALID
    beq t0, 1, valid ; branch if is valid
    bne t0, 0, not_valid ; branch if isn't valid

    ; BEGIN: valid
    valid: 
    
        addi s0, zero, 0x1204     ; init start checkpoint 
        addi s1, zero, 0x1000     ; init start
        addi s2, zero, 0x1194     ; end 

        ; BEGIN: loop_word
        loop_word:
            addi a0, zero, s0               ; init arg 1
            addi a1, zero, s1               ; init arg 2
            call copy_memory                ; call the copy memory process
            beq s1, s2, return_process      ; testing if reached the end of the GSA
            addi s0, s0, 4                  ; if not then counter +4
            addi s1, s1, 4                  ; if not then counter +4
            br loop_word                    ; branch to the loop again 

        ; END: loop_word 

        ; BEGIN: return_process
        return_process:
            addi v0, zero, 1
            ret
        ; END: return_process
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

; END: blink_score
