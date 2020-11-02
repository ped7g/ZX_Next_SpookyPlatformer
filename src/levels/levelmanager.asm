TILE_DEFINITIONS_SIZE equ 4096

WORLD_WIDTH equ 160
VIEW_WIDTH equ 40
VIEW_HEIGHT equ 32

VIEW_WIDTH_META equ 20


VIEW_SIZE equ VIEW_WIDTH*VIEW_HEIGHT


current_scroll db 0
scroll_direction db RIGHT

LEVEL_START equ 0
offset db LEVEL_START+VIEW_WIDTH
cam_x db LEVEL_START

test_layer2_scroll db 0


layer2_init:
    CLIP_LAYER2 4,155,0,255 ;layer 2 is basically rotated to do 320x256 mode
    nextreg $70, %00010000 ;bit5-4=320x256x8bpp mode
    nextreg $69, %10000000 ;bit7=enable layer2
	nextreg $12,20 ;layer2 ram page register
    ret

tiles_init:
    CLIPTILES 4,155,0,255
    call tiles_set_palette

    ;load the tile defs
    nextreg $56, 16
    ld hl,$c000
    ld de,$6000
    ld bc,TILE_DEFINITIONS_SIZE
    ldir

    nextreg $6b, %10100000
    nextreg $6c, 0
    nextreg $6e, $40
    nextreg $6f, $60
    nextreg $68, %10000000
    nextreg $43, %00110000

    ; ld a,3
    
    xor a ;black
    nextreg $4c,a ;tilemap transparency colour 
    nextreg $14,a; global transparency colour
    nextreg $31,a ;tiles y offset
    nextreg $30,a ;tiles x offset
   

    call view_init

    ret


layer2_update:
    ld a,(test_layer2_scroll)
    nextreg $16, a
    inc a
    ld (test_layer2_scroll),a
    ret




tiles_set_palette:
    ld hl,caveman_palette
    nextreg $43,%00110000
    xor a
    ld b,16
    nextreg $40,a
uploadpal:
    ld a,(hl)
    nextreg $44,a
    inc hl
    ld a,(hl)
    nextreg $44,a
    inc hl
    djnz uploadpal
    ret


;does 2 passes per 'map' line, due to 2 rows within each supertile
view_init:
    ld ix,metalevel
    ld de,$4280
    ld c,0
view_init_screen:
    ld b,VIEW_WIDTH_META
view_init_line_pass1:
    ld hl,metatiles
    ld a,(ix)
    add a,a
    add a,a ;A*4 (metatile size)
    add hl,a
    ld a,(hl)
    ld (de),a
    inc hl
    inc de
    ld a,(hl)
    ld (de),a
    inc de
    inc ix
    djnz view_init_line_pass1
    ld b,VIEW_WIDTH_META
view_init_golineback:
    dec ix
    djnz view_init_golineback
    ld b,VIEW_WIDTH_META
view_init_line_pass2:
    ld hl,metatiles
    ld a,(ix)
    add a,a
    add a,a ;A*4 (metatile size)
    add hl,a
    inc hl
    inc hl
    ld a,(hl)
    ld (de),a
    inc hl
    inc de
    ld a,(hl)
    ld (de),a
    inc de
    inc ix
    djnz view_init_line_pass2
    push de
    ld de,LEVEL_WIDTH_META-VIEW_WIDTH_META
    add ix,de
    pop de
    inc c
    ld a,c
    cp LEVEL_HEIGHT_META
    jp c,view_init_screen
    ret


        


scroll_left:
    ret

scroll_right:
    ret








; scroll_left:
;     ld a,LEFT
;     ld (scroll_direction),a

;     ld a,(offset)
;     cp LEVEL_START+VIEW_WIDTH+1
;     jp c, p_move_left

;     ld a,(offset)
;     sub VIEW_WIDTH
;     ld (cam_x),a

;     ld a,(current_scroll)
;     inc a
;     cp 8          
;     call z,drawcolumn_left 
;     ld (current_scroll),a
;     ld b,a
;     ld a,8
;     sub b
;     nextreg $30,a
;     ret
; drawcolumn_left:
;     ; ld hl,$4000+1279
;     ; ld de,$4001+1279
;     ld hl,$44FF
;     ld de,$4500
;     ld bc,40*32
;     lddr  ; move whole screen to right 1 tile 
;     ld hl,level1            ; start of tiles 
;     ld a,(cam_x)           ; current offset 
;     dec a
;     add hl,a                ; add this to tile offset 
;     ; dec a                   ; dec the offset 
;     add a,VIEW_WIDTH
;     ld (offset),a
;     ld de,$4000              ; top left cell 
;     ld b,VIEW_HEIGHT
; columnloop_left:
;     ld a,(hl)                   ; get tile from (hl)
;     ld (de),a                   ; put in (de)
;     add de,VIEW_WIDTH                  ; move de to next line
;     add hl,WORLD_WIDTH          ; move hl to next map line
;     djnz columnloop_left             ; loop for 32 lines 
;     xor a
;     ld (current_scroll),a
;     ret 



; scroll_right:
;     ld a,RIGHT
;     ld (scroll_direction),a

;     ld a,(offset)
;     cp WORLD_WIDTH
;     jp nc, p_move_right
;     ld a,(current_scroll)
;     inc a
;     cp 8            
;     call z,nowdrawcolumn 
;     ld (current_scroll),a
;     nextreg $30,a
;     ret
; nowdrawcolumn:
;     ld hl,$4001
;     ld de,$4000
;     ld bc,1280
;     ldir  ; move whole screen to left 1 tile 
;     ld hl,level1            ; start of tiles 
;     ld a,(offset)           ; current offset 
;     add hl,a                ; add this to tile offset 
;     inc a                   ; inc the offset 
;     ld (offset),a
;     ld de,$4027              ; top right cell 
;     ld b,VIEW_HEIGHT
; columnloop:
;     ld a,(hl)                   ; get tile from (hl)
;     ld (de),a                   ; put in (de)
;     add de,VIEW_WIDTH                  ; move de to next line
;     add hl,WORLD_WIDTH          ; move hl to next map line
;     djnz columnloop             ; loop for 32 lines 
;     xor a
;     ld (current_scroll),a
;     ret 












