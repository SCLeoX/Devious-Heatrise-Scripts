Scriptname dhrTrainingBeltScript extends zadBeltScript

dhrCore Property dhr Auto
dhrVibrationController Property dhr_vibrationController Auto

Int Property edgingsLeft = 0 Auto
{ How many edgings does the player need to complete }

Float Property shockTimeLeftHours = 0.0 Auto
{ How many hours of random shocks does the player need to endure }

Float Property teasingVibrationTimeLeftHours = 0.0 Auto
{ How many hours of teasing vibration does the player need to endure }

Float Property staminaDrainTimeLeftHours = 0.0 Auto
{ How many hours of stamina drain does the player need to endure }

Float Property magickaDrainTimeLeftHours = 0.0 Auto
{ How many hours of magicka drain does the player need to endure }

Float Property sleepDeprivationLeftHours = 0.0 Auto
{ How many hours of sleep deprivation does the player need to endure }

Float Property lastTickGameTimeHours = 0.0 Auto


; If two ticks are this many hours apart, the clock is not advanced
Float Property SKIP_TIME_THRESHOLD_HOURS = 0.9 AutoReadOnly

Bool isRunningTeasingVibration = False

; If currently edging the player, the session id used in vibration controller
Int edgingSessionId = -1
Float edgingCoolDownHours = 0.0

Float hoursSinceLastShock = 0.0

; This updates the 2 flags in dhrTrainingQuestScript: beltHasEdgingsLeft, and
; beltHasTimerLeft.
; It is required to call this whenever any of the belt functionalities is
; changed.
Function UpdateStatusFlags()
  dhr.dhr_trainingQuest.beltHasEdgingsLeft = edgingsLeft > 0
  dhr.dhr_trainingQuest.beltHasTimerLeft = shockTimeLeftHours > 0 || teasingVibrationTimeLeftHours > 0 || staminaDrainTimeLeftHours > 0 || magickaDrainTimeLeftHours > 0 || sleepDeprivationLeftHours > 0
EndFunction

Function AddEdgingsLeft(Int amount)
  edgingsLeft += amount
  UpdateStatusFlags()
EndFunction

Function AddShockTimeLeft(Int timeHours)
  shockTimeLeftHours += timeHours * dhr.trainingTimedTrialMultiplier
  UpdateStatusFlags()
EndFunction

Function AddTeasingVibrationsTimeLeft(Int timeHours)
  teasingVibrationTimeLeftHours += timeHours * dhr.trainingTimedTrialMultiplier
  UpdateStatusFlags()
EndFunction

Function AddStaminaDrainTimeLeft(Int timeHours)
  staminaDrainTimeLeftHours += timeHours * dhr.trainingTimedTrialMultiplier
  UpdateStatusFlags()
EndFunction

Function AddMagickaDrainTimeLeft(Int timeHours)
  magickaDrainTimeLeftHours += timeHours * dhr.trainingTimedTrialMultiplier
  UpdateStatusFlags()
EndFunction

Function AddSleepDeprivationTimeLeft(Int timeHours)
  sleepDeprivationLeftHours += timeHours * dhr.trainingTimedTrialMultiplier
  UpdateStatusFlags()
EndFunction

Function CheckEdgeResult()
  If edgingSessionId != -1
    ; Edging in progress
    If dhr_vibrationController.IsSessionCompleted(edgingSessionId)
      ; Edging completed
      If dhrCore.SoftAssert(edgingsLeft >= 1, "Edgings left is less than 1.")
        edgingsLeft -= 1
        UpdateStatusFlags()
        Debug.Notification("As you hear a click, the edgings left counter on your belt has decreased by 1.")
        If edgingsLeft >= 1
          Debug.Notification("You just need to edge yourself " + edgingsLeft + " more" + dhrCore.SwitchPlural(edgingsLeft, " time", " times") + ".")
        Else
          Debug.Notification("You do not need to edge yourself any more. ...that is, until Arcadia adds more to the counter.")
        EndIf
      EndIf
      edgingSessionId = -1
      edgingCoolDownHours = 1.0
    EndIf
  EndIf
EndFunction

Function DeviceMenu(Int msgChoice = 0)
  CheckEdgeResult()
  If edgingSessionId != -1
    dhr.dhr_msgShowEdgingInProgress.SetValueInt(1)
  Else
    dhr.dhr_msgShowEdgingInProgress.SetValueInt(0)
  EndIf
  msgChoice = zad_DeviceMsg.Show()
  If msgChoice == 0 ; Check status
    String msg = "Temperatures\n"
    msg += "===============================\n"
    msg += "Vaginal plug temperature: " + dhr.FormatTemperature(dhr.currentVaginalPlug.GetTemperature()) + " (Target: " + dhr.FormatTemperature(dhr.currentVaginalPlug.GetActiveTemperature()) + ")\n"
    msg += "Anal plug temperature: " + dhr.FormatTemperature(dhr.currentAnalPlug.GetTemperature()) + " (Target: " + dhr.FormatTemperature(dhr.currentAnalPlug.GetActiveTemperature()) + ")\n\n"
    msg += "Additional Enabled Modules\n"
    msg += "==============================="

    Bool hasAdditionalEnabledModules = False
  
    If edgingsLeft > 0
      hasAdditionalEnabledModules = True
      msg += "\nEdgings left: " + edgingsLeft + dhrCore.SwitchPlural(edgingsLeft, " time", " times")
      If edgingCoolDownHours > 0
        msg += "\nEdging cool down: " + dhrCore.FormatFloat(edgingCoolDownHours) + dhrCore.SwitchPlural(edgingCoolDownHours, " hour", " hours") + " left"
      EndIf
    EndIf

    If shockTimeLeftHours > 0
      hasAdditionalEnabledModules = True
      msg += "\nRandom shocks: " + dhrCore.FormatFloat(shockTimeLeftHours) + dhrCore.SwitchPlural(shockTimeLeftHours, " hour", " hours") + " left"
    EndIf
  
    If teasingVibrationTimeLeftHours > 0
      hasAdditionalEnabledModules = True
      msg += "\nTeasing vibrations: " + dhrCore.FormatFloat(teasingVibrationTimeLeftHours) + dhrCore.SwitchPlural(teasingVibrationTimeLeftHours, " hour", " hours") + " left"
    EndIf
  
    If staminaDrainTimeLeftHours > 0
      hasAdditionalEnabledModules = True
      msg += "\nStamina drain: " + dhrCore.FormatFloat(staminaDrainTimeLeftHours) + dhrCore.SwitchPlural(staminaDrainTimeLeftHours, " hour", " hours") + " left"
    EndIf
  
    If magickaDrainTimeLeftHours > 0
      hasAdditionalEnabledModules = True
      msg += "\nMagicka drain: " + dhrCore.FormatFloat(magickaDrainTimeLeftHours) + dhrCore.SwitchPlural(magickaDrainTimeLeftHours, " hour", " hours") + " left"
    EndIf

    If sleepDeprivationLeftHours > 0
      hasAdditionalEnabledModules = True
      msg += "\nSleep Deprivation: " + dhrCore.FormatFloat(sleepDeprivationLeftHours) + dhrCore.SwitchPlural(sleepDeprivationLeftHours, " hour", " hours") + " left"
    EndIf

    If !hasAdditionalEnabledModules
      msg += "\nNone"
    EndIf

    Debug.MessageBox(msg)
  ElseIf msgChoice == 1	; Insert climax key
    If dhr.zadQuest.PlayerRef.GetItemCount(dhr.dhr_climaxKey) <= 0
      Debug.MessageBox("You do not possess a climax key. You can get a climax keys when completing a checkup with Arcadia.")
    Else
      If teasingVibrationTimeLeftHours > 0
        Debug.MessageBox("You tried to insert the climax key. However, the keyway seems to be blocked. With frustration, you realize that the belt will not give you an orgasm when it is actively teasing you with weak vibrations.")
      Else
        If edgingsLeft > 0
          Debug.MessageBox("You tried to insert the climax key. However, the keyway seems to be blocked. With frustration, you realize that the belt will not give you an orgasm when there are edgings left.")
        Else
          Int climaxSessionId = -1
          If dhr_vibrationController.PrepareArguments()
            dhr_vibrationController.terminationMode = dhr_vibrationController.TERMINATION_MODE_ORGASM
            dhr_vibrationController.orgasmControlMode = dhr_vibrationController.ORGASM_CONTROL_MODE_ORGASM_ONLY
            dhr_vibrationController.vibrationIntensity = Utility.RandomFloat(dhr.trainingClimaxVibrationIntensityMin, dhr.trainingClimaxVibrationIntensityMax)
            dhr_vibrationController.pluralPlugs = True
            climaxSessionId = dhr_vibrationController.StartVibrate(blocking = False)
          EndIf
          If climaxSessionId == -1
            ; Failed to start
            Debug.MessageBox("You tried to insert the climax key. However, the keyway seems to be blocked. With frustration, you realize that it is probably because something else on you is already stimulating you. It might be wise to try again later.")
          Else
            Int arousal = Aroused.GetActorArousal(dhr.zadQuest.PlayerRef)
            If arousal < libs.ArousalThreshold("Desire")
              Debug.MessageBox("You insert the climax key into the keyhole on the chastity belt. The soulgems within you start to vibrate immediately.")
            ElseIf arousal < libs.ArousalThreshold("Horny")
              Debug.MessageBox("You insert the climax key into the keyhole on the chastity belt. You let out a sigh of relief as soulgems within you start to vibrate immediately.")
            ElseIf arousal < libs.ArousalThreshold("Desperate")
              Debug.MessageBox("Unable to resist your carnal desires any longer, you insert the climax key into the keyhole on the chastity belt. The soulgems within you start to vibrate immediately.")
            Else
              Debug.MessageBox("After several frenzied attempts, your trembling fingers finally manage to insert the climax key. The soulgems within you start to vibrate immediately.")
            EndIf
            dhr.zadQuest.PlayerRef.RemoveItem(dhr.dhr_climaxKey, 1, abSilent = True)
          EndIf
        EndIf
      EndIf
    EndIf
  ElseIf msgChoice == 2 ; Edge me
    dhrCore.SoftAssert(edgingSessionId == -1, "Edging already in progress.")
    If edgingsLeft == 0
      Debug.MessageBox("You press the button labeled \"Edge me\" on your chastity belt, but nothing happened. You realize that you can only edge yourself when Arcadia allows you to do so.")
    ElseIf teasingVibrationTimeLeftHours > 0
      Debug.MessageBox("You press the button labeled \"Edge me\" on your chastity belt, but nothing happened. You realize that you cannot edge yourself when it is teasing you with weak vibrations.")
    ElseIf edgingCoolDownHours > 0
      Debug.MessageBox("You press the button labeled \"Edge me\" on your chastity belt, but nothing happened. You realize that you have to wait " + dhrCore.FormatFloat(edgingCoolDownHours) + " more" + dhrCore.SwitchPlural(edgingCoolDownHours, " hour", " hours") + " before you can edge yourself again.")
    Else
      If dhr_vibrationController.PrepareArguments()
        dhr_vibrationController.terminationMode = dhr_vibrationController.TERMINATION_MODE_EDGE
        dhr_vibrationController.orgasmControlMode = dhr_vibrationController.ORGASM_CONTROL_MODE_EDGE_ONLY
        dhr_vibrationController.vibrationIntensity = Utility.RandomFloat(dhr.trainingEdgingVibrationIntensityMin, dhr.trainingEdgingVibrationIntensityMax)
        dhr_vibrationController.pluralPlugs = True
        edgingSessionId = dhr_vibrationController.StartVibrate(blocking = False)
      EndIf
      If edgingSessionId == -1
        ; Failed to start
        Debug.MessageBox("You press the button labeled \"Edge me\" on your chastity belt, but nothing happened. You realize that it is probably because something else on you is already stimulating you. It might be wise to try again later.")
      Else
        Debug.MessageBox("You pressed the button labeled \"Edge me\" on your chastity belt. The soulgems within you start to vibrate immediately.")
      EndIf
    EndIf
  ElseIf msgChoice == 3 ; Edging in Progress
    Debug.MessageBox("Soulgems within you are already in the process of edging you.")
  EndIf ; Carry on otherwise
EndFunction

Function OnEquippedPost(actor akActor)
  dhr.OnTrainingBeltEquipped(self)
  Parent.OnEquippedPost(akActor)
EndFunction

Function OnRemoveDevice(Actor akActor)
  dhr.OnTrainingBeltUnequipped()
  Parent.OnRemoveDevice(akActor)
EndFunction

Float Function Max(Float a, Float b)
  If a > b
    Return a
  Else
    Return b
  EndIf
EndFunction

Function Tick()
  Actor player = dhr.zadQuest.PlayerRef
  Float currentGameTimeHours = Utility.GetCurrentGameTime() * 24
  Float timePassed = currentGameTimeHours - lastTickGameTimeHours
  lastTickGameTimeHours = currentGameTimeHours
  If timePassed > SKIP_TIME_THRESHOLD_HOURS
    ; Time skipped
    timePassed = 0
  EndIf
  edgingCoolDownHours = Max(0, edgingCoolDownHours - timePassed)
  CheckEdgeResult()
  If teasingVibrationTimeLeftHours > 0
    If isRunningTeasingVibration
      teasingVibrationTimeLeftHours -= timePassed
      If teasingVibrationTimeLeftHours <= 0
        teasingVibrationTimeLeftHours = 0
        dhr_vibrationController.ManualTerminate()
        isRunningTeasingVibration = False
      EndIf
    Else
      ; Attempt to start teasing vibration
      If dhr_vibrationController.PrepareArguments()
        dhr_vibrationController.terminationMode = dhr_vibrationController.TERMINATION_MODE_MANUAL
        dhr_vibrationController.orgasmControlMode = dhr_vibrationController.ORGASM_CONTROL_MODE_HOVER
        dhr_vibrationController.vibrationIntensity = Utility.RandomFloat(dhr.trainingTeasingVibrationIntensityMin, dhr. trainingTeasingVibrationIntensityMax)
        dhr_vibrationController.pluralPlugs = True
        If dhr_vibrationController.StartVibrate(blocking = False) != -1
          isRunningTeasingVibration = True
        EndIf
      EndIf
    EndIf
  EndIf
  If shockTimeLeftHours > 0 && timePassed > 0
    hoursSinceLastShock += timePassed
    Float probability = (hoursSinceLastShock - dhr.trainingRandomShockMinimumHours) * dhr.trainingRandomShockHourlyProbabilityMultiplier * timePassed
    If Utility.RandomFloat() < probability
      ; Shock
      hoursSinceLastShock = 0.0
      dhr.ShockPlayer(Utility.RandomFloat(dhr.trainingRandomShockDamageMin, dhr.trainingRandomShockDamageMax), respectHpDrainReservationRatio = dhr.trainingRandomShockDamageRespectHpDrainReservationRatio, vaginalShock = True, analShock = True)
    EndIf
    shockTimeLeftHours = Max(0, shockTimeLeftHours - timePassed)
  EndIf
  If staminaDrainTimeLeftHours > 0
    player.DamageActorValue("Stamina", player.GetActorValue("Stamina"))
    staminaDrainTimeLeftHours = Max(0, staminaDrainTimeLeftHours - timePassed)
  EndIf
  If magickaDrainTimeLeftHours > 0
    player.DamageActorValue("Magicka", player.GetActorValue("Magicka"))
    magickaDrainTimeLeftHours = Max(0, magickaDrainTimeLeftHours - timePassed)
  EndIf
  If sleepDeprivationLeftHours > 0
    sleepDeprivationLeftHours = Max(0, sleepDeprivationLeftHours - timePassed)
  EndIf
  ; Random vibration
  If Utility.RandomFloat() < dhr.trainingRandomVibrationProbability
    If dhr_vibrationController.PrepareArguments()
      dhr_vibrationController.terminationMode = dhr_vibrationController.TERMINATION_MODE_TIMER
      dhr_vibrationController.terminateTimer = Utility.RandomInt(10, 120)
      dhr_vibrationController.orgasmControlMode = dhr_vibrationController.ORGASM_CONTROL_MODE_EDGE_ONLY
      dhr_vibrationController.restTimeSeconds = Utility.RandomFloat(5, 15)
      dhr_vibrationController.vibrationIntensity = Utility.RandomFloat(0.2, 0.8)
      dhr_vibrationController.pluralPlugs = True
      dhr_vibrationController.StartVibrate(blocking = False)
    EndIf
  EndIf
  UpdateStatusFlags()
EndFunction
