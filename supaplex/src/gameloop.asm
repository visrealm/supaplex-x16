; Supaplex - Commander X16
;
; The main game loop
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;



gameLoop:
  lda VSYNC_FLAG

  beq tick

  jmp gameLoop


tick:

  stz PLAYER_INPUT
  jsr JOYSTICK_GET
  eor #$ff
  ora PLAYER_INPUT
  sta PLAYER_INPUT

.afterTest
  clc
  lda PLAYER_OFFSET_X
  adc PLAYER_SPEED_X
  sta PLAYER_OFFSET_X
  bne +
  stz PLAYER_SPEED_X
+

  clc
  lda PLAYER_OFFSET_Y
  adc PLAYER_SPEED_Y
  sta PLAYER_OFFSET_Y
  bne +
  stz PLAYER_SPEED_Y
+

  lda PLAYER_OFFSET_X
  bne .afterInput

  lda PLAYER_OFFSET_Y
  bne .afterInput

  jsr doInput

.afterInput

  jsr checkTime

  jsr centreMap

  +vset VERA_SPRITES + 2

  +sub16 PLAYER_X, SCROLL_X
  stx VERA_DATA0
  sta VERA_DATA0
  +sub16 PLAYER_Y, SCROLL_Y
  stx VERA_DATA0

  lda SCROLL_X_L
  sta VERA_L0_HSCROLL_L

  lda SCROLL_X_H
  sta VERA_L0_HSCROLL_H

  ldy SCROLL_Y_L
  lda SCROLL_Y_H

  ; update vert scroll
  sty VERA_L0_VSCROLL_L
  sta VERA_L0_VSCROLL_H
 
  lda PLAYER_SPEED_X
  beq .notMovingX
  
  +vset VERA_SPRITES

  lda FRAME_INDEX
  bit #16 / PLAYER_SPEED
  beq .sprOne
  bit #8 / PLAYER_SPEED
  beq .sprTwo
  +vWriteByte0 ((MURPHY_ADDR + 256) >> 5) & $ff
  +vWriteByte0 ((MURPHY_ADDR  + 256) >> 13) & $ff
  bra .doneSpr
.sprOne
  +vWriteByte0 ((MURPHY_ADDR + 384) >> 5) & $ff
  +vWriteByte0 ((MURPHY_ADDR  + 384) >> 13) & $ff
  bra .doneSpr
.sprTwo
  +vWriteByte0 ((MURPHY_ADDR + 128) >> 5) & $ff
  +vWriteByte0 ((MURPHY_ADDR  + 128) >> 13) & $ff

.doneSpr

  +vset VERA_SPRITES + 6
  +vWriteByte0 $08  
  +vset VERA_SPRITES + 6
  lda PLAYER_SPEED_X
  and #$80
  bne .afterMovingX
  +vWriteByte0 $09  
  bra .afterMovingX

.notMovingX:
  +vset VERA_SPRITES
  +vWriteByte0 ((MURPHY_ADDR) >> 5) & $ff
  +vWriteByte0 ((MURPHY_ADDR) >> 13) & $ff
.afterMovingX:


  lda PLAYER_SPEED_Y
  beq .afterMovingY
  
  +vset VERA_SPRITES

  lda FRAME_INDEX
  bit #16 / PLAYER_SPEED
  beq .sprOneY
  bit #8 / PLAYER_SPEED
  beq .sprTwoY
  +vWriteByte0 ((MURPHY_ADDR + 256) >> 5) & $ff
  +vWriteByte0 ((MURPHY_ADDR  + 256) >> 13) & $ff
  bra .doneSprY
.sprOneY
  +vWriteByte0 ((MURPHY_ADDR + 384) >> 5) & $ff
  +vWriteByte0 ((MURPHY_ADDR  + 384) >> 13) & $ff
  bra .doneSprY
.sprTwoY
  +vWriteByte0 ((MURPHY_ADDR + 128) >> 5) & $ff
  +vWriteByte0 ((MURPHY_ADDR  + 128) >> 13) & $ff

.doneSprY


.afterMovingY:

  inc FRAME_INDEX


  lda #1
  sta VSYNC_FLAG

	jmp gameLoop
