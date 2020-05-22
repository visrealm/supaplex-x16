; Supaplex - Commander X16
;
; Electron
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

!zone electron {

; -----------------------------------------------------------------------------
; createElectron
; -----------------------------------------------------------------------------
; Inputs:
;  ZP_ECS_CURRENT_ENTITY, ZP_CURRENT_CELL_X, ZP_CURRENT_CELL_Y are set
; -----------------------------------------------------------------------------
createElectron:
  jsr ecsLocationSetCurrentEntityType
  jsr ecsAnimSetCurrentEntityType
  jsr setLocation

  lda #(animElectron - animationDefs) >> 3
  sta ZP_ECS_CURRENT_ANIM_ID
  ;lda #ANIM_FLAG_REPEAT
  stz ZP_ECS_CURRENT_ANIM_FL
  jsr setAnimation

  jsr pushAnimation
  rts


; -----------------------------------------------------------------------------
; electronAnimCB
; -----------------------------------------------------------------------------
; Animation callback (when an animation completes)
; Inputs:
;  ZP_ECS_CURRENT_ENTITY
;  ZP_CURRENT_CELL_X, ZP_CURRENT_CELL_Y
;  ZP_ECS_CURRENT_ANIM_ID, ZP_ECS_CURRENT_ANIM_FL
; -----------------------------------------------------------------------------
electronAnimCB:
  lda ZP_ECS_CURRENT_ANIM_ID
  cmp #(animElectron - animationDefs) >> 3
  bne +
  lda #(animElectron2 - animationDefs) >> 3
  bra .doneElectron
+
  lda #(animElectron - animationDefs) >> 3

.doneElectron:  
  sta ZP_ECS_CURRENT_ANIM_ID
  stz ZP_ECS_CURRENT_ANIM_FL
  jsr pushAnimation
  rts


; -----------------------------------------------------------------------------

} ; electron