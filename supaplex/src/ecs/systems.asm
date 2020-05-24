; Supaplex - Commander X16
;
; ECS Systems
;
; Copyright (c) 2020 Troy Schrapel
;
; This code is licensed under the MIT license
;
; https://github.com/visrealm/supaplex-x16
;


; -----------------------------------------------------------------------------
; register all ecs systems
; -----------------------------------------------------------------------------
ecsRegisterSystems:
  jsr ecsAnimationSystemInit
  jsr ecsLocationSystemInit
  jsr ecsEnemySystemInit
  jsr ecsFallingSystemInit
  rts

; -----------------------------------------------------------------------------
; tick all ecs systems
; -----------------------------------------------------------------------------
ecsTickSystems:
  jsr ecsEnemySystemTick
  jsr ecsFallingSystemTick
  jsr ecsAnimationSystemTick
  rts  