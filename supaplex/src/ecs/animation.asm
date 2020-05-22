; Supaplex - Commander X16
;
; Animation component and system
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

ECS_ANIMATION_ASM_ = 1


!ifndef CMN_QUEUE_ASM_ !error "Requires queue"

; =============================================================================
!zone ecsAnimationComponent {
; -----------------------------------------------------------------------------
; Used to set and get the animation attributes for a given entity
; =============================================================================

.ANIM_COMPONENT_BANK = 11
.ADDR_ANIM_ID_TABLE  = BANKED_RAM_START
.ADDR_ANIM_FL_TABLE  = BANKED_RAM_START + $1000

; -----------------------------------------------------------------------------
; ecsAnimSetCurrentEntityType
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; -----------------------------------------------------------------------------
ecsAnimSetCurrentEntityType:
  lda ZP_ECS_CURRENT_ENTITY_MSB
  ; TODO - check for index (11:8)
  and #$0f
  clc
  adc #>.ADDR_ANIM_ID_TABLE
  sta ZP_ECS_ANIM_ID_TABLE_MSB
  adc #>(.ADDR_ANIM_FL_TABLE - .ADDR_ANIM_ID_TABLE)
  sta ZP_ECS_ANIM_FL_TABLE_MSB
  rts

; -----------------------------------------------------------------------------
; setAnimation
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
;   ZP_ECS_CURRENT_ANIM_ID
;   ZP_ECS_CURRENT_ANIM_FL
; -----------------------------------------------------------------------------
setAnimation:
  +setRamBank .ANIM_COMPONENT_BANK
  phy

  ; index
  ldy ZP_ECS_CURRENT_ENTITY_LSB

  ; set animation id
  lda ZP_ECS_CURRENT_ANIM_ID
  sta (ZP_ECS_ANIM_ID_TABLE), y
  
  ; set animation flags
  lda ZP_ECS_CURRENT_ANIM_FL
  sta (ZP_ECS_ANIM_FL_TABLE), y

  ply
  rts

; -----------------------------------------------------------------------------
; getAnimation
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; Outputs:
;   ZP_ECS_CURRENT_ANIM_ID
;   ZP_ECS_CURRENT_ANIM_FL
; -----------------------------------------------------------------------------
getAnimation:
  +setRamBank .ANIM_COMPONENT_BANK
  
  phy

  ; index
  ldy ZP_ECS_CURRENT_ENTITY_LSB

  ; set animation id
  lda (ZP_ECS_ANIM_ID_TABLE), y
  sta ZP_ECS_CURRENT_ANIM_ID
  
  ; set animation flags
  lda (ZP_ECS_ANIM_FL_TABLE), y
  sta ZP_ECS_CURRENT_ANIM_FL

  ply
  rts

} ; ecsAnimationComponent




; =============================================================================
!zone ecsAnimationSystem {
; -----------------------------------------------------------------------------
; the animation system runs the animations using data provided by the
; animation components.
; when an animation is started, its data is set in its entity's animation
; component. it is then added to the animation system's queue. each tick
; the queue is processed. if an animation completes, it is removed from the
; queue.
; =============================================================================


; -----------------------------------------------------------------------------
; animation queues
; -----------------------------------------------------------------------------
.entityLsbQueueId:  !byte $00
.entityMsbQueueId:  !byte $00

.entityLsbQueueMsb: !byte $00
.entityMsbQueueMsb: !byte $00


; 0: repeat[7]  reverse[6]  rate? additional id? unused? [5-4] step[3-0]
; 1: animId[7 - 0]

TMP_ANIM_DEF_ADDR =   R3
TMP_ANIM_DEF_ADDR_L = R3L
TMP_ANIM_DEF_ADDR_H = R3H

TMP_ANIM_FL = R2


; -----------------------------------------------------------------------------
; NOTES
; -----------------------------------------------------------------------------

; keep a full level map. 2 bytes per cell
; that way we can go back and get the entity
; or we can set an animation on a cell without
; needing an entity and we limit the entire
; data requirements to 4KB (plus queues)
; need a lookup from entityId to cell x/y

; keep a queue of active cells (or entities)

; all cell animations are 8 frames (16 bytes) long, so can be placed in a queue
; *if* an animation needs to replace the old one (eg. explosion)
; no problem.. it will as the queue will sort it out



; -----------------------------------------------------------------------------
; animation definition macros
; -----------------------------------------------------------------------------
!macro animDefByte tileAddress {
    !byte (tileAddress - tileTable) >> 1
}

!macro animDef id, tile0, tile1, tile2, tile3, tile4, tile5, tile6, tile7 {
  +animDefByte tile0
  +animDefByte tile1
  +animDefByte tile2
  +animDefByte tile3
  +animDefByte tile4
  +animDefByte tile5
  +animDefByte tile6
  +animDefByte tile7
}

; -----------------------------------------------------------------------------
; animation definitions
; -----------------------------------------------------------------------------
!align 255,0
animationDefs:
snikU2L: +animDef 0, tileSnikUp, tileSnikUp, tileSnikUl, tileSnikUl, tileSnikUl, tileSnikUl, tileSnikL, tileSnikL
snikL2D: +animDef 1, tileSnikL, tileSnikL, tileSnikDl, tileSnikDl, tileSnikDl, tileSnikDl, tileSnikDn, tileSnikDn
snikD2R: +animDef 2, tileSnikDn, tileSnikDn, tileSnikDr, tileSnikDr, tileSnikDr, tileSnikDr, tileSnikR, tileSnikR
snikR2U: +animDef 3, tileSnikR, tileSnikR, tileSnikUr, tileSnikUr, tileSnikUr, tileSnikUr, tileSnikUp, tileSnikUp
termGreen: +animDef 4, tileConsoleGn1, tileConsoleGn2, tileConsoleGn3, tileConsoleGn4, tileConsoleGn5, tileConsoleGn6, tileConsoleGn7, tileConsoleGn8

; TODO: Add a lookup for the above to save computing the address each time


; -----------------------------------------------------------------------------
; animation callbacks
; an entity-type specific function is called when an animation completes
; -----------------------------------------------------------------------------
animationCallbacks:
  !word emptyAnimCB
  !word zonkAnimCB
  !word playerAnimCB
  !word baseAnimCB
  !word yellowDiskAnimCB
  !word redDiskAnimCB
  !word orangeDiskAnimCB
  !word terminalAnimCB
  !word portAnimCB
  !word exitAnimCB
  !word bugAnimCB
  !word infotronAnimCB
  !word electronAnimCB
  !word snikSnakAnimCB
  !word ramAnimCB
  !word hardwareAnimCB

emptyAnimCB:
zonkAnimCB:
playerAnimCB:
baseAnimCB:
yellowDiskAnimCB:
redDiskAnimCB:
orangeDiskAnimCB:
terminalAnimCB:
portAnimCB:
exitAnimCB:
bugAnimCB:
infotronAnimCB:
electronAnimCB:
ramAnimCB:
hardwareAnimCB:
  rts

snikSnakAnimCB:
  rts


; -----------------------------------------------------------------------------
; initialise the animation system
; -----------------------------------------------------------------------------
ecsAnimationSystemInit:
  stz ZP_ECS_ANIM_ID_TABLE_LSB
  stz ZP_ECS_ANIM_FL_TABLE_LSB

  +qCreate .entityLsbQueueId, .entityLsbQueueMsb
  sta .smcEntityLsb - 1

  +qCreate .entityMsbQueueId, .entityMsbQueueMsb
  sta .smcEntityMsb - 1

  rts

; -----------------------------------------------------------------------------
; pushAnimation
; -----------------------------------------------------------------------------
; Inputs:
;   ZP_ECS_CURRENT_ENTITY
; -----------------------------------------------------------------------------
pushAnimation:
  lda ZP_ECS_CURRENT_ENTITY_LSB
  ldx .entityLsbQueueId
  jsr qPush

  lda ZP_ECS_CURRENT_ENTITY_MSB
  ;+dbgBreak
  ldx .entityMsbQueueId
  jsr qPush

  rts



ecsAnimationSystemTick:
  +vchannel0
  ldx .entityLsbQueueId
  jsr qSize
  beq .end

  sta R9 ; store queue size in R9
  
  jsr qIterate ; get starting point (y)
;  +dbgBreak

.loop:
  lda SELF_MODIFY_MSB_ADDR, y   ; modified to address of .entityLsbQueueId
.smcEntityLsb:
  sta ZP_ECS_CURRENT_ENTITY_LSB

  lda SELF_MODIFY_MSB_ADDR, y   ; modified to address of .entityMsbQueueId
.smcEntityMsb:
  sta ZP_ECS_CURRENT_ENTITY_MSB

  phy

  ;+dbgBreak

  jsr ecsAnimSetCurrentEntityType ; TODO: can we make this smarter? do it less?
  jsr ecsLocationSetCurrentEntityType
  jsr getAnimation
  jsr getLocation
  
  jsr vSetCurrent

  ; fill ZP_ECS_CURRENT_ANIM_ID and ZP_ECS_CURRENT_ANIM_FL

  lda ZP_ECS_CURRENT_ANIM_ID   ; TODO:  replace this calculation with a lookup
  +dbgBreak
  stz TMP_ANIM_DEF_ADDR_H
  asl 
  rol TMP_ANIM_DEF_ADDR_H
  asl 
  rol TMP_ANIM_DEF_ADDR_H
  asl 
  rol TMP_ANIM_DEF_ADDR_H
  clc
  adc #<animationDefs
  sta TMP_ANIM_DEF_ADDR_L
  lda TMP_ANIM_DEF_ADDR_H
  adc #>animationDefs
  sta TMP_ANIM_DEF_ADDR_H

  ldy ZP_ECS_CURRENT_ANIM_FL   ; step (3:0)  TODO: account for (7:4)
  lda (TMP_ANIM_DEF_ADDR), y
  iny
  sty ZP_ECS_CURRENT_ANIM_FL   ; write it back

  ; here, a is the tile Id

  asl ; double it
  tay

  lda tileTable, y
  sta VERA_DATA0  
  lda tileTable + 1, y
  sta VERA_DATA0  

  ply

  lda ZP_ECS_CURRENT_ANIM_FL
  cmp #$08
  bne +
  stz ZP_ECS_CURRENT_ANIM_FL
+
  jsr setAnimation

  iny
  dec R9
  bne .loop

.end:
  rts

}