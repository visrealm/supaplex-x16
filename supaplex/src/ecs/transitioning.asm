; Supaplex - Commander X16
;
; Transitioning entities
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;

; As a cell transitions, its actual location is immediately
; the new cell. However, the old cell can't yet be occupied
; So, this entity type is used as a placeholder. 
; While it's transitioning, it can be given an animation
; (explosions or explode to infotron) but usually empty



ECS_TRANSITIONING_ASM_ = 1

!ifndef CMN_QUEUE_ASM_ !error "Requires queue"


ecsEntitySetTransitioning:
  lda #ENTITY_TYPE_TRANSITION
  jsr ecsEntitySetType
  
  lda #(animBlank - animationDefs) >> 3
  sta ZP_ECS_CURRENT_ANIM_ID
  lda #0
  sta ZP_ECS_CURRENT_ANIM_FL

  jsr ecsSetAnimation
  jmp ecsAnimationPush

  rts


transitionAnimCB:
  lda #ENTITY_TYPE_EMPTY
  jsr ecsEntitySetType

  rts




; =============================================================================
!zone ecsTransitioningComponent {
; -----------------------------------------------------------------------------



} ; ecsTransitioningComponent





; =============================================================================
!zone ecsTransitioningSystem {
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; falling "awake" queues
; -----------------------------------------------------------------------------
.entityLsbQueueId:  !byte $00
.entityMsbQueueId:  !byte $00

.entityLsbQueueMsb: !byte $00
.entityMsbQueueMsb: !byte $00


; -----------------------------------------------------------------------------
; ecsTransitioningSystemInit
; -----------------------------------------------------------------------------
; Initialise the falling system
; -----------------------------------------------------------------------------
ecsTransitioningSystemInit:
  rts



; -----------------------------------------------------------------------------
; ecsTransitioningSystemTick
; -----------------------------------------------------------------------------
; Called for each frame
; -----------------------------------------------------------------------------
ecsTransitioningSystemTick:
  rts



} ; ecsTransitioningSystem