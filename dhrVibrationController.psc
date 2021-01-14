Scriptname dhrVibrationController extends Quest
{ This script emulates regular vibration effect to block other vibration events from starting. Theoretically, this script should be compatible with other vibration control scripts written in a similar fashion running at the same time. }

Bool Property isControllingVibration = False Auto
dhrCore Property dhr Auto
zadLibs Property zadQuest Auto

; Controls when the vibration effect will end
Int Property terminationMode Auto
; Terminate immediately
Int Property TERMINATION_MODE_IMMEDIATE = 1 AutoReadOnly
; Terminated when termination mode is set to TERMINATION_MODE_IMMEDIATE
Int Property TERMINATION_MODE_MANUAL = 2 AutoReadOnly
; Terminated when actor reaches orgasm
Int Property TERMINATION_MODE_ORGASM = 3 AutoReadOnly
; Terminated when actor is edged
Int Property TERMINATION_MODE_EDGE = 4 AutoReadOnly
; Terminated when a set number of seconds is passed
; Change the value of terminateTimer to set the time
Int Property TERMINATION_MODE_TIMER = 5 AutoReadOnly

; When termination mode is set to TERMINATION_MODE_TIMER, vibration is
; terminated, when this amount of seconds is passed.
Int Property terminateTimer Auto

; Controls how to control orgasms
Int Property orgasmControlMode Auto
; Never edges the player but makes sure she is constantly stimulated and is aroused
Int Property ORGASM_CONTROL_MODE_HOVER = 1 AutoReadOnly
; Always pushes the player towards edge and stops abruptly, then repeat
Int Property ORGASM_CONTROL_MODE_EDGE_ONLY = 2 AutoReadOnly
; Always pushes the player over the boundary and cause orgasm
Int Property ORGASM_CONTROL_MODE_ORGASM_ONLY = 3 AutoReadOnly

; How long to wait before restarting vibration after player orgasms/is edged
Float Property restTimeSeconds Auto

; How fast arousal and internal orgasm meter builds up
Float Property vibrationIntensity Auto

; If there are two plugs causing the vibration
Bool Property pluralPlugs Auto

Int Property vibrationSoundId = -1 Auto
Int Property moanSoundId = -1 Auto

Int Property NOTIFICATION_COUNTDOWN_MAX = 30 AutoReadOnly

Bool preparingArguments = False
Int currentSessionId = 0
Int lastCompletedSessionId = 0

Float currentVibrationIntensity = 0.0

Sound vibrationSound
Float tolerance

Float Function GetCurrentVibrationIntensity()
  Return currentVibrationIntensity
EndFunction

; Locks the script
; Call this prior to setting the arguments
; Make sure to call StartVibrate() afterwards, which will release the lock regardless
Bool Function PrepareArguments()
  If isControllingVibration
    Return False
  EndIf
  If preparingArguments
    Return False
  EndIf
  preparingArguments = True
  currentSessionId += 1
  Return True
EndFunction

Bool Function IsSessionCompleted(Int sessionId)
  Return lastCompletedSessionId >= sessionId
EndFunction

Function RestartSounds()
  If vibrationSoundId != -1
    vibrationSoundId = vibrationSound.Play(zadQuest.PlayerRef)
    UpdateVibrationSoundVolume()
  EndIf
  If moanSoundId != -1
    moanSoundId = zadQuest.MoanSound.Play(zadQuest.PlayerRef)
    UpdateMoanSoundVolume()
  EndIf
EndFunction

Function PlayVibrationSound()
  If !dhrCore.SoftAssert(vibrationSoundId == -1, "Vibration sound is already playing.")
    Return
  EndIf
  vibrationSoundId = vibrationSound.Play(zadQuest.PlayerRef)
  UpdateVibrationSoundVolume()
EndFunction

Function UpdateVibrationSoundVolume()
  If !dhrCore.SoftAssert(vibrationSoundId != -1, "Vibration sound is not playing.")
    Return
  EndIf
  If dhr.vibrationSoundVolumeUseDD
    Sound.SetInstanceVolume(vibrationSoundId, zadQuest.Config.VolumeVibrator * (1 - tolerance))
  Else
    Sound.SetInstanceVolume(vibrationSoundId, dhr.vibrationSoundVolumeOverride * (1 - tolerance))
  EndIf
EndFunction

Function StopVibrationSound()
  If !dhrCore.SoftAssert(vibrationSoundId != -1, "Vibration sound is not playing.")
    Return
  EndIf
  Sound.StopInstance(vibrationSoundId)
  vibrationSoundId = -1
EndFunction

Function PlayMoanSound()
  If !dhrCore.SoftAssert(moanSoundId == -1, "Moan sound is already playing.")
    Return
  EndIf
  moanSoundId = zadQuest.MoanSound.Play(zadQuest.PlayerRef)
  UpdateMoanSoundVolume()
EndFunction

Function UpdateMoanSoundVolume()
  If !dhrCore.SoftAssert(moanSoundId != -1, "Moan sound is not playing.")
    Return
  EndIf
  If dhr.moanSoundVolumeUseDD
    Sound.SetInstanceVolume(moanSoundId, zadQuest.GetMoanVolume(zadQuest.PlayerRef) * (1 - tolerance))
  Else
    Sound.SetInstanceVolume(moanSoundId, dhr.moanSoundVolumeOverride * (1 - tolerance))
  EndIf
EndFunction

Function StopMoanSound()
  If !dhrCore.SoftAssert(moanSoundId != -1, "Moan sound is not playing.")
    Return
  EndIf
  Sound.StopInstance(moanSoundId)
  moanSoundId = -1
EndFunction

; Makes sure player is in zad's vibrator faction so no vibration event can start from Devious Device.
Function EnsurePlayerInZadVibratorFaction()
  zadQuest.PlayerRef.SetFactionRank(zadQuest.zadVibratorFaction, 100)
EndFunction

Bool Function RequestControlVibration()
  If !dhrCore.SoftAssert(!isControllingVibration, "Already controlling vibration.")
    Return False
  EndIf
  zadQuest.AcquireAndSpinlock()
  If zadQuest.PlayerRef.IsInFaction(zadQuest.zadVibratorFaction)
    ; Fail to obtain control
    zadQuest.DeviceMutex = False
    Return False
  EndIf
  EnsurePlayerInZadVibratorFaction()
  ; Control obtained
  isControllingVibration = True
  zadQuest.DeviceMutex = False
  Return True
EndFunction

Function ReleaseControl()
  If !dhrCore.SoftAssert(isControllingVibration, "Not controlling vibration.")
    Return
  EndIf
	zadQuest.PlayerRef.SetFactionRank(zadQuest.zadVibratorFaction, 0)
  zadQuest.PlayerRef.RemoveFromFaction(zadQuest.zadVibratorFaction)
  isControllingVibration = False
EndFunction

; Call PrepareArguments() before this
; Returns the sessionId (You may later check if it is completed using IsSessionCompleted(sessionId))
; If -1 is returned, vibration has failed to start
Int Function StartVibrate(Bool blocking)
  If !dhrCore.SoftAssert(preparingArguments, "PrepareArguments() was not called")
    Return -1
  EndIf
  If isControllingVibration
    preparingArguments = False
    Return -1
  EndIf
  If !RequestControlVibration()
    preparingArguments = False
    Return -1
  EndIf
  If blocking
    VibrateMain()
  Else
    SendModEvent("dhr_startVibrateThread")
  EndIf
  Return currentSessionId
EndFunction

Function ManualTerminate()
  dhrCore.SoftAssert(terminationMode == TERMINATION_MODE_MANUAL, "Termination mode is not manual.")
  terminationMode = TERMINATION_MODE_IMMEDIATE
EndFunction

Event StartVibrateThread(String eventName, String strArg, Float numArg, Form sender)
  VibrateMain()
EndEvent

Function RegisterEvents()
  RegisterForModEvent("dhr_startVibrateThread", "StartVibrateThread")
EndFunction

Function VibrateMain()
  Int thisSessionId = currentSessionId
  preparingArguments = False
  Actor player = zadQuest.PlayerRef
  String vibrationStrengthAdverb
  String plugString
  Bool approachingOrgasmDisplayed = False
  Bool toleranceHighDisplayed = False
  If pluralPlugs
    plugString = " plugs "
  Else
    plugString = " plug "
  EndIf
  If vibrationIntensity >= 0.8
    vibrationSound = zadQuest.VibrateVeryStrongSound
    vibrationStrengthAdverb = zadQuest.GetVibrationStrength(5)
  ElseIf vibrationIntensity >= 0.6
    vibrationSound = zadQuest.VibrateStrongSound
    vibrationStrengthAdverb = zadQuest.GetVibrationStrength(4)
  ElseIf vibrationIntensity >= 0.4
    vibrationSound = zadQuest.VibrateStandardSound
    vibrationStrengthAdverb = zadQuest.GetVibrationStrength(3)
  ElseIf vibrationIntensity >= 0.2
    ; vibrationSound = zadQuest.VibrateWeakSound
    ; The VibrateWeakSound for some reason sounds extremely weak (You literally cannot hear it when the character is moaning)
    vibrationSound = zadQuest.VibrateVeryWeakSound
    vibrationStrengthAdverb = zadQuest.GetVibrationStrength(2)
  Else
    vibrationSound = zadQuest.VibrateVeryWeakSound
    vibrationStrengthAdverb = zadQuest.GetVibrationStrength(1)
  EndIf
  Debug.Notification("The" + plugString + "within you begin to vibrate " + vibrationStrengthAdverb + "!")
  currentVibrationIntensity = vibrationIntensity
  
  Int currentTick = 0
  tolerance = 0
  PlayVibrationSound()
  PlayMoanSound()
  Int animationStartTick = -1
  Int vibrationStoppedTick = -1
  Bool[] cameraState

  ; How much physical pleasure does the player have
  ; Orgasm is reached when pleasure reaches 100
  Float pleasure = 0

  ; How horny the player is
  ; Plays horny idle when reaches 100
  Float horny = 0

  ; Start base expression
  sslBaseExpression expression = zadQuest.SexLab.RandomExpressionByTag("Pleasure")
  zadQuest.ApplyExpression(player, expression, (zadQuest.Aroused.GetActorExposure(player) * 0.75) as Int)

  Int showNotificationCountdown = NOTIFICATION_COUNTDOWN_MAX

  ; Main Loop
  While zadQuest.IsValidActor(player) && terminationMode != TERMINATION_MODE_IMMEDIATE
    If terminationMode == TERMINATION_MODE_TIMER && currentTick >= terminateTimer
      terminationMode = TERMINATION_MODE_IMMEDIATE
    EndIf

    tolerance = -100.0 / (currentTick + 400.0 / 3.0) + 0.75
    If (currentTick % 2) == 0 ; Make noise
      player.CreateDetectionEvent(player, (vibrationIntensity * 50) as int)
    EndIf
    If (currentTick % 5) == 0
      EnsurePlayerInZadVibratorFaction()
    EndIf
    If !approachingOrgasmDisplayed && pleasure > 80 && orgasmControlMode != ORGASM_CONTROL_MODE_HOVER && vibrationStoppedTick == -1
      approachingOrgasmDisplayed = True
      Debug.Notification("You are approaching orgasm.")
    ElseIf !toleranceHighDisplayed && tolerance > 0.5
      toleranceHighDisplayed = True
      Debug.Notification("You are getting used to the constant vibrations.")
    EndIf
    
    If vibrationStoppedTick != -1
      ; The vibration has stopped
      pleasure = pleasure * 0.96
      horny = horny * 0.92
    Else
      ; The vibration has not stopped
      pleasure += vibrationIntensity * 5 * (1 - tolerance)
      horny += vibrationIntensity * 30 * (1 - tolerance)
    EndIf

    If pleasure >= 100
      If orgasmControlMode == ORGASM_CONTROL_MODE_ORGASM_ONLY
        ; Orgasm
        If animationStartTick != -1
          zadQuest.EndThirdPersonAnimation(player, cameraState, permitRestrictive = True)
          animationStartTick = -1
        EndIf
        zadQuest.ApplyExpression(player, expression, 100, openMouth = True)
        Debug.Notification("The" + plugString + "bring you to a thunderous climax.")
        showNotificationCountdown = NOTIFICATION_COUNTDOWN_MAX
        StopMoanSound()
        approachingOrgasmDisplayed = False
        zadQuest.ActorOrgasm(player, Utility.RandomInt(0, 15))
        StopVibrationSound()
        currentVibrationIntensity = 0
        If terminationMode == TERMINATION_MODE_ORGASM
          terminationMode = TERMINATION_MODE_IMMEDIATE
        EndIf
        pleasure = 0
        horny = 0
        zadQuest.ResetExpression(player, expression)
        vibrationStoppedTick = currentTick
        Debug.Notification("The vibrations stop as you recover from the orgasm.")
        showNotificationCountdown = NOTIFICATION_COUNTDOWN_MAX
      ElseIf orgasmControlMode == ORGASM_CONTROL_MODE_EDGE_ONLY
        ; Edge
        If animationStartTick != -1
          zadQuest.EndThirdPersonAnimation(player, cameraState, permitRestrictive = True)
          animationStartTick = -1
        EndIf
        zadQuest.ApplyExpression(player, expression, 100, openMouth = True)
        StopMoanSound()
        StopVibrationSound()
        currentVibrationIntensity = 0
        vibrationStoppedTick = currentTick
        Debug.Notification("The vibrations abruptly stop just short of bringing you to orgasm.")
        showNotificationCountdown = NOTIFICATION_COUNTDOWN_MAX
        approachingOrgasmDisplayed = False
        zadQuest.EdgeActor(player)
        If terminationMode == TERMINATION_MODE_EDGE
          terminationMode = TERMINATION_MODE_IMMEDIATE
        EndIf
        pleasure = 99
        horny = 99
        zadQuest.ResetExpression(player, expression)
      Else
        ; Hover
        pleasure = 99
      EndIf
    EndIf

    If currentTick % 5 == 0 && vibrationStoppedTick == -1; Increment arousal every 5 seconds
      zadQuest.UpdateExposure(player, 20 * vibrationIntensity, skipMultiplier = True)
      UpdateMoanSoundVolume()
      UpdateVibrationSoundVolume()
    EndIf

    If horny >= 100
      horny = 0
      zadQuest.ApplyExpression(player, expression, (zadQuest.Aroused.GetActorExposure(player) * 0.75) as Int, openMouth = True)
      cameraState = zadQuest.StartThirdPersonAnimation(player, zadQuest.AnimSwitchKeyword(player, "Horny01"), permitRestrictive = True)
      animationStartTick = currentTick
    EndIf

    If animationStartTick != -1
      horny = 0 ; The player is touching herself so that should reset horny count
      If (currentTick - animationStartTick) >= 5 ; Stop animation
        zadQuest.ApplyExpression(player, expression, (zadQuest.Aroused.GetActorExposure(player) * 0.75) as Int, openMouth = False)
        zadQuest.EndThirdPersonAnimation(player, cameraState, permitRestrictive = True)
        animationStartTick = -1
      EndIf
    EndIf

    If vibrationStoppedTick != -1 && (currentTick - vibrationStoppedTick) > restTimeSeconds && !dhr.isPCSleeping ; Restart vibration
      vibrationStoppedTick = -1
      PlayMoanSound()
      PlayVibrationSound()
      currentVibrationIntensity = vibrationIntensity
      If restTimeSeconds > 3
        Debug.Notification("You twitch involuntarily as the" + plugString + "within you start to vibrate " + vibrationStrengthAdverb + " again.")
        showNotificationCountdown = NOTIFICATION_COUNTDOWN_MAX
      EndIf
    EndIf

    showNotificationCountdown -= 1
    If showNotificationCountdown <= 0
      Debug.Notification("The" + plugString + "within you continue to vibrate " + vibrationStrengthAdverb + "!")
      showNotificationCountdown = NOTIFICATION_COUNTDOWN_MAX
    EndIf
    Utility.Wait(1)
    currentTick += 1
  EndWhile

  If vibrationStoppedTick == -1 ; Vibration has not stopped
    StopMoanSound()
    StopVibrationSound()
    currentVibrationIntensity = 0
    If zadQuest.Aroused.GetActorExposure(player) >= zadQuest.ArousalThreshold("Desperate")
      If pluralPlugs
        Debug.Notification("You let out a frustrated moan as plugs within you cease to vibrate.")
      Else
        Debug.Notification("You let out a frustrated moan as plug within you ceases to vibrate.")
      EndIf
    Else
      If pluralPlugs
        Debug.Notification("The plugs cease vibrating.")
      Else
        Debug.Notification("The plug ceases vibrating.")
      EndIf
    EndIf
  EndIf

  If zadQuest.IsValidActor(player)
    zadQuest.ResetExpression(player, expression)
  EndIf

  If animationStartTick != -1
    zadQuest.EndThirdPersonAnimation(player, cameraState, permitRestrictive = True)
  EndIf

  zadQuest.UpdateArousalTimeRate(player, 5 * vibrationIntensity)
  zadQuest.Aroused.GetActorArousal(player)

  lastCompletedSessionId = thisSessionId
  ReleaseControl()
EndFunction
