Scriptname dhrHeatingPlugScript extends zadPlugScript
{ Despite the name, this script handles both heating plugs and cooling plugs provided by Devious Heatrise }

; All temperature units are in degree celsius

dhrCore Property dhr Auto
Message Property dhr_deviceMsg Auto

Float Property dhr_plugRestingTemperature Auto
{ The plug's temperature when it is removed from the body }

Float Property dhr_plugMinTemperature Auto
{ The absolutely minimal temperature the plug can be }

Float Property dhr_plugMaxTemperature Auto
{ The absolutely maximal temperature the plug can be }

; Active temperature is the temperature that the plug is heating up/cooling down to

Float Property dhr_plugActiveTemperatureMin Auto
{ When picking the active temperature, this is the minimal temperature it can be }

Float Property dhr_plugActiveTemperatureMax Auto
{ When picking the active temperature, this is the maximal temperature it can be }

Float Property dhr_plugActiveTemperatureMinimumChange Auto
{ When picking the active temperature, it must be at least this amount away from current temperature }

Float Property dhr_plugHeatingRate Auto
{ When heating towards the active temperature, this is the maximal temperature it can increase by per tick }

Float Property dhr_plugCoolingRate Auto
{ When cooling towards the active temperature, this is the maximal temperature it can decrease by per tick }

Float Property dhr_plugTemperatureVariance Auto
{ When heating/cooling towards active temperature, the temperature changed will be altered by +- this value }

Float Property dhr_plugChangeTemperatureAmount Auto
{ When using the change temperature functionality of the plug, how many degrees it adds to/subtracts from fastDelta }

Int Property dhr_plugActiveTemperatureChangeTicks Auto
{ On average, how many ticks need to pass before the plug changes its active temperature. }

Int Property dhr_plugActiveTemperatureChangeTicksVariance Auto
{ When deciding how many ticks need to pass before the plug changes its active temperature, the # of ticks is altered by
  +- this value }

Float Property dhr_plugTortureModeTemperature Auto
{ When the torture mode is turned on, what temperature this plug should approach to }

Bool Property dhr_plugTortureModeEdgeOnly Auto
{ When the torture mode is turned on, should the plug only edge player }

; Current temperature of the plug
Float currentTemperature

; The temperature this plug will slowly move towards
Float activeTemperature

; # of ticks before next active temperature change
Int nextActiveTemperatureChange

; The temperature this plug will quickly change by;
; This value is altered by change temperature functionalities of the plug
; (Manually press the "Increase Temperature" / "Decrease Temperature" buttons on
; the plug)
Float fastDelta

; There are two triggers for showing a notification of the current plug
; 1. The temperature has changed by at least 20°C since last notification
; 2. Every tick, current temperature diff is subtracted from a countdown
;    (showNotificationCountdown). Once this countdown hits 0, a notification
;    is shown to the player.
; Either way, when a notification is shown, both metrics are reset.

; Last time the temperature is shown via notification
Float lastShownTemperature

; Countdown to next notification
Float showNotificationCountdown

; Whether the torture mode has been enabled
Bool tortureMode

; Whether this plug is vaginal
Bool isVaginal

; Get the current temperature
Float Function GetTemperature()
  Return currentTemperature
EndFunction

; Use with plugs that does not change active temperature on its own
Function ForceSetActiveTemperature(Float targetActiveTemperature)
  activeTemperature = targetActiveTemperature
EndFunction

; Get the current active temperature (the temperature this plug is heating/cooling towards)
Float Function GetActiveTemperature()
  Return activeTemperature
EndFunction

; Used internally to change the active temperature
; Will not be called on plugs that does not change active temperature on its own
Function ChangeActiveTemperature(Int maxAttempts = 10)
  Float newTemperature = Utility.RandomFloat(dhr_plugActiveTemperatureMin, dhr_plugActiveTemperatureMax)
  If Math.Abs(newTemperature - currentTemperature) < dhr_plugActiveTemperatureMinimumChange
    ChangeActiveTemperature(maxAttempts - 1)
  Else
    activeTemperature = newTemperature
    nextActiveTemperatureChange = dhr_plugActiveTemperatureChangeTicks + Utility.RandomInt(-dhr_plugActiveTemperatureChangeTicksVariance, dhr_plugActiveTemperatureChangeTicksVariance)
  EndIf
EndFunction

; Reset plugs status upon insertion
Function ResetPlug()
  isVaginal = deviceRendered.HasKeyword(libs.zad_DeviousPlugVaginal)
  currentTemperature = dhr_plugRestingTemperature
  If dhr_plugActiveTemperatureChangeTicks >= 0
    ChangeActiveTemperature()
  Else
    ; If active temperature will not change, just set it to the resting temperature
    activeTemperature = dhr_plugRestingTemperature
  EndIf
  fastDelta = 0
  lastShownTemperature = dhr_plugRestingTemperature
  tortureMode = False
EndFunction

Int Function GetTemperatureGroup(Float temperature)
  If temperature < -20
    Return 0
  ElseIf temperature < 0
    Return 1
  ElseIf temperature < 20
    Return 2
  ElseIf temperature < 40
    Return 3
  ElseIf temperature < 60
    Return 4
  ElseIf temperature < 80
    Return 5
  Else
    Return 6
  EndIf
EndFunction

Float Function Tick() ; Returns mapped temperature diff
  If tortureMode
    If currentTemperature < dhr_plugTortureModeTemperature
      currentTemperature += 25
    ElseIf currentTemperature > dhr_plugTortureModeTemperature
      currentTemperature -= 25
    EndIf
  ElseIf fastDelta != 0.0
    ; Apply fast delta
    currentTemperature += fastDelta * dhr.fastDeltaRatioPerTick
    fastDelta -= fastDelta * dhr.fastDeltaRatioPerTick
    If Math.Abs(fastDelta) < dhr.fastDeltaClearThreshold
      currentTemperature += fastDelta
      fastDelta = 0.0
    EndIF
  Else
    Float amount
    If currentTemperature < activeTemperature
      ; Needs heating
      ; The colder, the faster it is to heat up
      Float heatRatio = ((1 - (currentTemperature - dhr_plugRestingTemperature) / (dhr_plugMaxTemperature - dhr_plugRestingTemperature)) * 0.6 + 0.4)
      If heatRatio > 1
        amount = dhr_plugHeatingRate
      Else
        amount = dhr_plugHeatingRate * heatRatio
      EndIf
    Else
      ; Needs cooling
      Float coolRatio = ((1 - (dhr_plugRestingTemperature - currentTemperature) / (dhr_plugRestingTemperature - dhr_plugMinTemperature)) * 0.6 + 0.4)
      If coolRatio > 1
        amount = -dhr_plugCoolingRate
      Else
        amount = -dhr_plugCoolingRate * coolRatio
      EndIf
    EndIf
    amount += Utility.RandomFloat(-dhr_plugTemperatureVariance, dhr_plugTemperatureVariance)

    currentTemperature += amount
  EndIf

  ; Rebound
  If currentTemperature > dhr_plugMaxTemperature
    currentTemperature = dhr_plugMaxTemperature
  EndIf
  If currentTemperature < dhr_plugMinTemperature
    currentTemperature = dhr_plugMinTemperature
  EndIf

  ; If negative, changing active temperature is disabled
  If dhr_plugActiveTemperatureChangeTicks >= 0
    nextActiveTemperatureChange -= 1
  EndIf

  Float mappedTemperature = dhr.MapPlugTemperature(currentTemperature, isVaginal)
  Float mappedTemperatureDiff = Math.Abs(mappedTemperature - dhr.bodyTemperature)
  showNotificationCountdown -= mappedTemperatureDiff

  If dhr_plugActiveTemperatureChangeTicks >= 0 && nextActiveTemperatureChange < 0 && fastDelta == 0 && !tortureMode
    ChangeActiveTemperature()
    Float diff = activeTemperature - currentTemperature
    If diff > 30
      Debug.Notification("The plug inside your " + OrganName(deviceRendered.HasKeyword(libs.zad_DeviousPlugVaginal)) + " starts to rapidly heating up.")
    ElseIf diff > 15
      Debug.Notification("The plug inside your " + OrganName(deviceRendered.HasKeyword(libs.zad_DeviousPlugVaginal)) + " starts to heating up.")
    ElseIf diff > 0
      Debug.Notification("The plug inside your " + OrganName(deviceRendered.HasKeyword(libs.zad_DeviousPlugVaginal)) + " starts to slowly heating up.")
    ElseIf diff > -15
      Debug.Notification("The plug inside your " + OrganName(deviceRendered.HasKeyword(libs.zad_DeviousPlugVaginal)) + " starts to slowly cooling down.")
    ElseIf diff > -30
      Debug.Notification("The plug inside your " + OrganName(deviceRendered.HasKeyword(libs.zad_DeviousPlugVaginal)) + " starts to cooling down.")
    Else
      Debug.Notification("The plug inside your " + OrganName(deviceRendered.HasKeyword(libs.zad_DeviousPlugVaginal)) + " starts to rapidly cooling down.")
    EndIf
  Else
    ; Only show message if active temperature does not change.
    ; This is to avoid showing multiple message for one plug.
    If Math.Abs(lastShownTemperature - mappedTemperature) > 20 || showNotificationCountdown <= 0
      lastShownTemperature = mappedTemperature
      showNotificationCountdown = dhr.initialShowNotificationCountdown
      Int temperatureGroup = GetTemperatureGroup(mappedTemperature)
      String msg
      If temperatureGroup == 0
        msg = "You groan involturaily as the plug freezes up your " + OrganName(isVaginal) + "."
      ElseIf temperatureGroup == 1
        msg = "The plug inside your " + OrganName(isVaginal) + " is freezing cold."
      ElseIf temperatureGroup == 2
        msg = "The plug inside your " + OrganName(isVaginal) + " is a bit chilling."
      ElseIf temperatureGroup == 3
        msg = "The plug inside your " + OrganName(isVaginal) + " is close to your body temperature."
      ElseIf temperatureGroup == 4
        msg = "The plug inside your " + OrganName(isVaginal) + " is quite warm."
      ElseIf temperatureGroup == 5
        msg = "The plug inside your " + OrganName(isVaginal) + " is very hot."
      Else
        msg = "You groan involturaily as the plug burns up your " + OrganName(isVaginal) + "."
      EndIf
      msg += " (" + dhr.FormatTemperature(currentTemperature) + ")"
      Debug.Notification(msg)
    EndIf
  EndIf

  ApplyEffects(mappedTemperature)

  If tortureMode
    If !libs.IsVibrating(libs.PlayerRef)
      libs.VibrateEffect(libs.PlayerRef, 5, 30, dhr_plugTortureModeEdgeOnly)
    EndIf
  EndIf

  Return mappedTemperatureDiff
EndFunction

Function UpdateFrostfallExposure(Float mappedTemperature)
  If !dhr.HasFrostfall()
    Return
  EndIf
  If mappedTemperature < 20
    Float tempDiff = 20 - mappedTemperature
    Float maxExposure = 20 + tempDiff * 2.5
    If maxExposure > 119 && dhr.frostfallFreezingPreventPassOut
      maxExposure = 119
    EndIf 
    FrostUtil.ModPlayerExposure(tempDiff * dhr.frostfallExposurePerTempDiffPerTick * dhr.globalEffectMultiplier, maxExposure)
  ElseIf mappedTemperature > dhr.bodyTemperature
    Float tempDiff = mappedTemperature - dhr.bodyTemperature
    FrostUtil.ModPlayerExposure(-tempDiff * dhr.frostfallExposurePerTempDiffPerTick * dhr.globalEffectMultiplier, 0)
  EndIf
EndFunction

Function UpdateSkillLevel()
  Float tempDiff = Math.Abs(currentTemperature - dhr.bodyTemperature)
  If tempDiff > dhr.expGainingThreshold
    dhrSkill skill
    If currentTemperature > dhr.bodyTemperature
      If isVaginal
        skill = dhr.dhr_vaginalHeatResistanceSkill
      Else
        skill = dhr.dhr_analHeatResistanceSkill
      EndIf
    Else
      If isVaginal
        skill = dhr.dhr_vaginalColdResistanceSkill
      Else
        skill = dhr.dhr_analColdResistanceSkill
      EndIf
    EndIf
    skill.AddExp(Math.pow(tempDiff, 0.6) / 3)
    ; skill.AddExp(1000) ; TODO: Remove this in production
  EndIf
EndFunction

Function ApplyEffects(Float mappedTemperature)
  UpdateFrostfallExposure(mappedTemperature)
  UpdateSkillLevel()
EndFunction

Int Function OnEquippedFilter(Actor akActor, Bool silent = false)
  If akActor != libs.PlayerRef
    If !silent
      Debug.MessageBox("This plug may only be equipped by the player.")
    EndIf
    Return 2
  EndIf
  Return 0
EndFunction

Function DeviceMenu(Int msgChoice = 0)
  If !libs.PlayerRef.IsEquipped(deviceInventory)
    ; If somehow the player access the menu while not having the plug inserted, I still need to display something.
    ; I don't know when it will happen, but there are 51 calls to this from zadEquipScript. I don't know if any of
    ; them will call this while the player does not have the plug equipped. It never occurred during testing, but
    ; I am scared.
    Int choice = zad_DeviceMsg.Show() ; display menu
    If choice == 0
      If deviceRendered.HasKeyword(libs.zad_DeviousPlugAnal) && libs.PlayerRef.WornHasKeyword(libs.zad_DeviousPlugAnal)
        Debug.MessageBox("Your backside is filled with an anal plug already!")
        Return
      EndIf
      If deviceRendered.HasKeyword(libs.zad_DeviousPlugVaginal) && libs.PlayerRef.WornHasKeyword(libs.zad_DeviousPlugVaginal)
        Debug.MessageBox("You are filled with a vaginal plug already!")
        Return
      EndIf
      If libs.PlayerRef.WornHasKeyword(libs.zad_DeviousBelt)
        Debug.MessageBox("Try as you might, the belt you are wearing prevents you from inserting this plug.")
        Return
      EndIf
      If deviceRendered.HasKeyword(libs.zad_DeviousPlugAnal)
        Debug.MessageBox("You slide the plug into your backside, sending waves of pleasure through your body.")
      Else
        Debug.MessageBox("You open your legs and slide the plug inside you, sending waves of pleasure through your body.")
      EndIf
      libs.EquipDevice(libs.PlayerRef, deviceInventory, deviceRendered, zad_DeviousDevice)
    EndIf
    SyncInventory()
    Return
  EndIf

  ; At this point, we are certain this plug has been equipped.

  ; In case of stacking, we need to get the instance that is actually being tracked.
  dhrHeatingPlugScript this = dhr.GetCurrentPlug(isVaginal)
  If this == None
    ; If the plug desynced, just remove it.
    RemoveDevice(libs.PlayerRef)
    SyncInventory()
    Return
  EndIf
  this.SelfDeviceMenu()
EndFunction
Function SelfDeviceMenu()
  If deviceRendered.HasKeyword(dhr.dhr_manualIncreaseTemperaturePlug) && !tortureMode
    dhr.dhr_msgShowIncreaseTemperature.SetValueInt(1)
  Else
    dhr.dhr_msgShowIncreaseTemperature.SetValueInt(0)
  EndIf

  If deviceRendered.HasKeyword(dhr.dhr_manualDecreaseTemperaturePlug) && !tortureMode
    dhr.dhr_msgShowDecreaseTemperature.SetValueInt(1)
  Else
    dhr.dhr_msgShowDecreaseTemperature.SetValueInt(0)
  EndIf

  If deviceRendered.HasKeyword(dhr.dhr_torturousPlug) && !tortureMode
    dhr.dhr_msgShowEnableTortureMode.SetValueInt(1)
  Else
    dhr.dhr_msgShowEnableTortureMode.SetValueInt(0)
  EndIf

  If tortureMode
    dhr.dhr_msgShowTortureInProgress.SetValueInt(1)
  Else
    dhr.dhr_msgShowTortureInProgress.SetValueInt(0)
  EndIf

  Int msgChoice = dhr_deviceMsg.Show()
  If msgChoice == 0 ; Take it out
    RemovePlugNoLock()
    Debug.MessageBox("As soon as the plug leaves your body, you feel the temperature of the plug quickly returns to its resting temperature of " + dhr.FormatTemperature(dhr_plugRestingTemperature) + ".")
  ElseIf msgChoice == 1 ; Check Temperature
    Float mappedTemperature = dhr.MapPlugTemperature(currentTemperature, isVaginal)
    String msg
    If mappedTemperature <= -20
      msg = "You feel your " + OrganName(isVaginal) + " is getting severely burned from the extreme cold of the plug. "
    ElseIf mappedTemperature <= -10
      msg = "You feel your " + OrganName(isVaginal) + " is getting burned from the extreme cold of the plug. "
    ElseIf mappedTemperature <= 5
      msg = "You feel your " + OrganName(isVaginal) + " is freezing from the cold of the plug. "
    ElseIf mappedTemperature <= 20
      msg = "You feel your " + OrganName(isVaginal) + " is getting cooled down by the plug. "
    ElseIf mappedTemperature <= 30
      msg = "You feel the plug is slightly colder than your " + OrganName(isVaginal) + ". "
    ElseIf mappedTemperature <= 40
      msg = "You feel the plug is close to your body temperature. "
    ElseIf mappedTemperature <= 50
      msg = "You feel your " + OrganName(isVaginal) + " is getting warmed up by the plug. "
    ElseIf mappedTemperature <= 60
      msg = "You feel the plug is a bit hot inside your " + OrganName(isVaginal) + ". "
    ElseIf mappedTemperature <= 70
      msg = "You feel the plug inside your " + OrganName(isVaginal) + " is very hot. "
    ElseIf mappedTemperature <= 80
      msg = "You feel your " + OrganName(isVaginal) + " is getting burned by the extremely hot plug. "
    Else
      msg = "You feel your " + OrganName(isVaginal) + " is getting severely burned by the extremely hot plug. "
    EndIf

    If libs.PlayerRef.WornHasKeyword(libs.zad_DeviousBelt)
      If libs.PlayerRef.WornHasKeyword(libs.zad_DeviousHarness)
        msg += "Trapped inside of your harness, the plug's temperature is currently at " + dhr.FormatTemperature(currentTemperature) + ". "
      Else
        msg += "Trapped inside of your belt, the plug's temperature is currently at " + dhr.FormatTemperature(currentTemperature) + ". "
      EndIf
    Else
      msg += "Although one end is exposed in air, the temperature of the soulgem inside you is currently at " + dhr.FormatTemperature(currentTemperature) + ". "
    EndIf

    If mappedTemperature <= -20 || mappedTemperature >= 90
      msg += "You groan involturaily due to the extreme pain caused by the plug. You need to get rid of the plug immediately."
    ElseIf mappedTemperature <= -10 || mappedTemperature >= 80
      msg += "You really need to get it out of your " + OrganName(isVaginal) + " as soon as possible."
    ElseIf mappedTemperature <= 0 || mappedTemperature >= 70
      msg += "You should remove it from your " + OrganName(isVaginal) + " now."
    ElseIf mappedTemperature <= 10 || mappedTemperature >= 60
      msg += "It is quite uncomfortable. You might want to remove it."
    ElseIf mappedTemperature <= 25 || mappedTemperature >= 50
      msg += "It is a little bit uncomfortable, but you can keep it if you like."
    ElseIf mappedTemperature <= 35 || mappedTemperature >= 40
      msg += "It is not bothering you temperature-wise."
    Else
      msg += "Temperature-wise, it is quite comfortable."
    EndIf
    Debug.MessageBox(msg)
  ElseIf msgChoice == 2 ; Increase Temperature
    If fastDelta == 0
      fastDelta += dhr_plugChangeTemperatureAmount
      Debug.MessageBox("You turn the knob on the exposed end of the plug. You feel the plug's temperature starts to increase significantly. You also notice that the knob does not turn the other way. There is no going back now.")
    Else
      fastDelta += dhr_plugChangeTemperatureAmount
      If currentTemperature + fastDelta >= dhr_plugMaxTemperature
        fastDelta = dhr_plugMaxTemperature - currentTemperature
        Debug.MessageBox("Although the effect of last knob turning has not been fully realized, you eagerly turn the knob more. However, the rotation of the knob is stopped by some mechanism inside, as you realize the temperature of the plug will soon be maximized.")
      Else
        Debug.MessageBox("Although the effect of last knob turning has not been fully realized, you eagerly turn the knob more. You feel the plug is going to heat up even more now.")
      EndIf
    EndIf
  ElseIf msgChoice == 3 ; Decrease Temperature
    If fastDelta == 0
      fastDelta -= dhr_plugChangeTemperatureAmount
      Debug.MessageBox("You turn the knob on the exposed end of the plug. You feel the plug's temperature starts to decrease significantly. You also notice that the knob does not turn the other way. There is no going back now.")
    Else
      fastDelta -= dhr_plugChangeTemperatureAmount
      If currentTemperature + fastDelta <= dhr_plugMinTemperature
        fastDelta = dhr_plugMinTemperature - currentTemperature
        Debug.MessageBox("Although the effect of last knob turning has not been fully realized, you eagerly turns the knob more. However, the rotation of the knob is stopped by some mechanism inside, as you realize the temperature of the plug will soon be minimized.")
      Else
        Debug.MessageBox("Although the effect of last knob turning has not been fully realized, you eagerly turns the knob more. You feel the plug is going to cool down even more now.")
      EndIf
    EndIf
  ElseIf msgChoice == 4 ; Enable Torture Mode
    Int choice = dhr.dhr_enableTortureModeConfirmationMsg.Show()
    If choice == 0 ; Press the button
      Debug.MessageBox("You press the button regardless. Suddenly, you feel a strong energy radiating from the plug. You wonder what will happen now.")
      tortureMode = True
      fastDelta = 0.0
    EndIf
  ElseIf msgChoice == 5 ; Torture in Progress
    Debug.MessageBox("Torture mode has been enabled. There is nothing you can do to stop it now.")
  EndIf
	SyncInventory()
EndFunction

Function OnEquippedPost(actor akActor)
  If akActor != dhr.zadQuest.PlayerRef
    ; Just in case
    RemoveDevice(akActor)
    Return
  EndIf
  isVaginal = deviceRendered.HasKeyword(libs.zad_DeviousPlugVaginal)
  ResetPlug()
  dhr.OnPlugEquipped(self, isVaginal)
  Parent.OnEquippedPost(akActor)
EndFunction

Function OnRemoveDevice(Actor akActor)
  Int giftPlugId = dhr.dhr_plugGiftList.Find(deviceInventory)
  ; Remove the item if this plug has not been gifted
  If giftPlugId >= 0 && !dhr.plugGifted[giftPlugId]
    akActor.RemoveItem(deviceInventory, 1, True)
  EndIf
  If akActor != dhr.zadQuest.PlayerRef
    ; Just in case
    Return
  EndIf
  dhr.OnPlugUnequipped(isVaginal)
EndFunction

String Function OrganName(Bool aIsVaginal)
  If aIsVaginal
    Return "vagina"
  Else
    Return "rectum"
  EndIf
EndFunction
