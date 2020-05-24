; Supaplex - Commander X16
;
; Input routines
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;
;


SP_INPUT_ASM_ = 1

!zone input {

; -----------------------------------------------------------------------------
; constants
; -----------------------------------------------------------------------------

; player speed (pixels per frame).
; NOTE: must be evenly divided into tile size (1, 2 or 4 work)
PLAYER_SPEED = 2


; -----------------------------------------------------------------------------
; testCell: check a cell for suitability to invade
; -----------------------------------------------------------------------------
; Inputs:
;  ZP_ECS_TEMP_ENTITY
; Returns:
;  C = if set, passable, otherwise, not
; -----------------------------------------------------------------------------
testCell:

  lda ZP_ECS_TEMP_ENTITY_MSB
  and #$0f
  cmp #ENTITY_TYPE_BASE
  bne +
  +sfxPlay SFX_BASE_ID
  bra .cellPassable
+
  cmp #ENTITY_TYPE_EMPTY
  beq .cellPassable
  cmp #ENTITY_TYPE_INFOTRON
  bne .cellNotPassable
  dec ZP_NUM_INFOTRONS

  +sfxPlay SFX_INFOTRON_ID

  jsr hudSetInfotrons

.cellPassable
  jsr ecsLocationClearTemp
  sec
  rts

.cellNotPassable:
  clc
  rts


; -----------------------------------------------------------------------------
; handle input
;
; HACK: this code is very temporary. just a hack to get some input handling
; -----------------------------------------------------------------------------
doInput:

  stz ZP_PLAYER_INPUT
  jsr JOYSTICK_GET
  eor #$ff
  ora ZP_PLAYER_INPUT
  sta ZP_PLAYER_INPUT

  ; adjust murphy X location based on speed
  clc
  lda ZP_PLAYER_SPEED_X
  beq +
  adc ZP_PLAYER_OFFSET_X
  sta ZP_PLAYER_OFFSET_X
  bne +
  stz ZP_PLAYER_SPEED_X
+

  ; adjust murphy Y location based on speed
  clc
  lda ZP_PLAYER_SPEED_Y
  beq +
  adc ZP_PLAYER_OFFSET_Y
  sta ZP_PLAYER_OFFSET_Y
  bne +
  stz ZP_PLAYER_SPEED_Y
+

  ; no input if player moving
  lda ZP_PLAYER_OFFSET_X
  bne .playerMoving

  lda ZP_PLAYER_OFFSET_Y
  bne .playerMoving

  ; if we get here, we can check for input
  bra .allowInput

.playerMoving:
  rts

!macro checkDirection joystickFlag, incOrDec, xOrY {

  ; check joystick flags
  lda ZP_PLAYER_INPUT
  bit #joystickFlag

  ; no match?, move on
  beq .endCheck

  ; get player location
  lda ZP_PLAYER_CELL_X
  ldy ZP_PLAYER_CELL_Y
  
  ; adjust x or y
  !if incOrDec > 0 {
    !if xOrY = "x" { jsr ecsLocationPeekRight }
    !if xOrY = "y" { jsr ecsLocationPeekDown }
  } else {
    !if xOrY = "x" { jsr ecsLocationPeekLeft }
    !if xOrY = "y" { jsr ecsLocationPeekUp }
  }

  ; test the cell. can we go there?
  jsr testCell
  bcc .endCheck

  ; we can. let's do it
  lda #PLAYER_SPEED * incOrDec

  !if xOrY = "x" { sta ZP_PLAYER_SPEED_X }
  !if xOrY = "y" { sta ZP_PLAYER_SPEED_Y }

  lda #(TILE_SIZE - PLAYER_SPEED) * -incOrDec

  !if xOrY = "x" { sta ZP_PLAYER_OFFSET_X }
  !if xOrY = "y" { sta ZP_PLAYER_OFFSET_Y }

  ; clear old cell
  ldy ZP_PLAYER_CELL_Y
  lda ZP_PLAYER_CELL_X
  jsr clearTile

  ; adjust player location
  !if incOrDec = 1 {
    !if xOrY = "x" { inc ZP_PLAYER_CELL_X }
    !if xOrY = "y" { inc ZP_PLAYER_CELL_Y }
  } else {
    !if xOrY = "x" { dec ZP_PLAYER_CELL_X }
    !if xOrY = "y" { dec ZP_PLAYER_CELL_Y }
  }
  
  ; no further checks (one direction only)
  jmp doneTests

.endCheck:

}

.allowInput:  
  lda ZP_PLAYER_CELL_X
  ldy ZP_PLAYER_CELL_Y
  sta ZP_CURRENT_CELL_X
  sty ZP_CURRENT_CELL_Y
  jsr ecsLocationGetEntity

  +checkDirection JOY_LEFT,  -1, "x"
  +checkDirection JOY_RIGHT,  1, "x"
  +checkDirection JOY_UP,    -1, "y"
  +checkDirection JOY_DOWN,   1, "y"

doneTests:

  ;jsr ecsLocationGetEntity
  ;jsr ecsLocationPeekDown

  ;lda ZP_ECS_TEMP_ENTITY_MSB
  ;and #$0f
  ;jsr hudOutputDebug

  rts

; -----------------------------------------------------------------------------

}