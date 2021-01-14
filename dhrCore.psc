Scriptname dhrCore extends Quest
{ This is the central coordinator of Devious Heatrise (aka. a place to put all the global variables) }

Int Property currentMigrationVersion Auto

dhrVendor Property dhr_vendor Auto
dhrTrainingQuestScript Property dhr_trainingQuest Auto
dhrVibrationController Property dhr_vibrationController Auto
zadLibs Property zadQuest Auto
zadDeviceLists Property zadxQuest Auto
Spell Property dhr_zad_electroShockSpellNoDamage Auto
Key Property dhr_climaxKey Auto
PlayerSleepQuestScript Property PlayerSleepQuest Auto
Spell Property dhr_badlyRested Auto

; Updated by PlayerRef script
Bool Property isPCSleeping = False Auto

; Plugs
Armor Property dhr_plugArcticTorturousAnalInventory Auto
Armor Property dhr_plugArcticTorturousVaginalInventory Auto
Armor Property dhr_plugBurningTorturousAnalInventory Auto
Armor Property dhr_plugBurningTorturousVaginalInventory Auto
Armor Property dhr_plugColdAnalInventory Auto
Armor Property dhr_plugColdVaginalInventory Auto
Armor Property dhr_plugFreezingTorturousAnalInventory Auto
Armor Property dhr_plugFreezingTorturousVaginalInventory Auto
Armor Property dhr_plugFrigidAnalInventory Auto
Armor Property dhr_plugFrigidVaginalInventory Auto
Armor Property dhr_plugHotAnalInventory Auto
Armor Property dhr_plugHotVaginalInventory Auto
Armor Property dhr_plugInfernoTorturousAnalInventory Auto
Armor Property dhr_plugInfernoTorturousVaginalInventory Auto
Armor Property dhr_plugWarmAnalInventory Auto
Armor Property dhr_plugWarmVaginalInventory Auto
Armor Property dhr_plugUnstableAnalInventory Auto
Armor Property dhr_plugUnstableVaginalInventory Auto

; Global variables used to control what options to show
GlobalVariable Property dhr_msgShowIncreaseTemperature Auto
GlobalVariable Property dhr_msgShowDecreaseTemperature Auto
GlobalVariable Property dhr_msgShowEnableTortureMode Auto
GlobalVariable Property dhr_msgShowTortureInProgress Auto
GlobalVariable Property dhr_msgShowEdgingInProgress Auto


; Keywords
Keyword Property dhr_heatingPlug Auto
Keyword Property dhr_coolingPlug Auto
Keyword Property dhr_torturousPlug Auto
Keyword Property dhr_manualIncreaseTemperaturePlug Auto
Keyword Property dhr_manualDecreaseTemperaturePlug Auto

Keyword Property zad_DeviousGag Auto
Keyword Property zad_DeviousBlindfold Auto
Keyword Property zad_DeviousHeavyBondage Auto
Keyword Property zad_DeviousBoots Auto


; Message
Message Property dhr_enableTortureModeConfirmationMsg Auto


; Reference to devices that the player is currently wearing to avoid nonsense
; with stacking items.
dhrHeatingPlugScript Property currentVaginalPlug Auto
dhrHeatingPlugScript Property currentAnalPlug Auto
dhrTrainingBeltScript Property currentTrainingBelt Auto


; Constants
Float Property bodyTemperature = 36.5 AutoReadOnly
Float Property fastDeltaRatioPerTick = 0.6 AutoReadOnly
Float Property fastDeltaClearThreshold = 4.0 AutoReadOnly
String Property MOD_VERSION = "V1.0" AutoReadOnly
Int Property MIGRATION_VERSION = 1 AutoReadOnly


; Skills
dhrSkill Property dhr_analHeatResistanceSkill Auto
dhrSkill Property dhr_analColdResistanceSkill Auto
dhrSkill Property dhr_vaginalHeatResistanceSkill Auto
dhrSkill Property dhr_vaginalColdResistanceSkill Auto


; Devices
Armor Property dhr_plugTrainingAnal_scriptInstance Auto
Armor Property dhr_plugTrainingAnalInventory Auto
Armor Property dhr_plugTrainingVaginal_scriptInstance Auto
Armor Property dhr_plugTrainingVaginalInventory Auto
Armor Property dhr_trainingBelt_scriptInstance Auto
Armor Property dhr_trainingBeltInventory Auto


; LeveledLists
; There are other lists available in CK prefixed with dhr_dev. However they are
; not used in Devious Heatrise script. You can use them if you want to.
LeveledItem Property dhr_dev_plugs_anal_extreme Auto
LeveledItem Property dhr_dev_plugs_anal_mild Auto
LeveledItem Property dhr_dev_plugs_vaginal_extreme Auto
LeveledItem Property dhr_dev_plugs_vaginal_mild Auto


; Configurations
Bool Property useFahrenheit = False Auto

Bool Property shockCauseFallOver = True Auto

Float Property globalEffectMultiplier = 1.0 Auto

Float Property hpDrainThreshold = 20.0 Auto
Float Property hpDrainPointsPerTempDiff = 4.0 Auto
Float Property hpDrainReservationRatio = 0.5 Auto

Float Property mpDrainThreshold = 15.0 Auto
Float Property mpDrainPointsPerTempDiff = 2.0 Auto
Float Property mpDrainReservationRatio = 0.1 Auto

Float Property staminaDrainThreshold = 15.0 Auto
Float Property staminaDrainPointsPerTempDiff = 2.0 Auto
Float Property staminaDrainReservationRatio = 0.1 Auto

Float Property expGainingThreshold = 10.0 Auto
Float Property expGainingMultiplier = 1.0 Auto

Bool Property vibrationSoundVolumeUseDD = True Auto
Float Property vibrationSoundVolumeOverride = 1.0 Auto
Bool Property moanSoundVolumeUseDD = True Auto
Float Property moanSoundVolumeOverride = 1.0 Auto

; How many degrees Celsius does each level of resistance skill shield the player
Float Property skillEffectiveness = 1.0 Auto

Float Property trainingBaseTemperatureDiff = 15.0 Auto
Float Property trainingStressTemperatureAdditionalDiff = 15.0 Auto

Float Property trainingRandomShockMinimumHours = 1.0 Auto
Float Property trainingRandomShockHourlyProbabilityMultiplier = 3.0 Auto
Float Property trainingRandomShockDamageMin = 10.0 Auto
Float Property trainingRandomShockDamageMax = 60.0 Auto
Bool Property trainingRandomShockDamageRespectHpDrainReservationRatio = True Auto

Float Property trainingClimaxVibrationIntensityMin = 0.6 Auto
Float Property trainingClimaxVibrationIntensityMax = 1.0 Auto

Float Property trainingEdgingVibrationIntensityMin = 0.6 Auto
Float Property trainingEdgingVibrationIntensityMax = 1.0 Auto

Float Property trainingTeasingVibrationIntensityMin = 0.15 Auto
Float Property trainingTeasingVibrationIntensityMax = 0.30 Auto

Float Property trainingRandomVibrationProbability = 0.05 Auto

Bool Property frostfallFreezingPreventPassOut = True Auto
Float Property frostfallExposurePerTempDiffPerTick = 0.2 Auto

Float Property initialShowNotificationCountdown = 100.0 Auto

; The following two properties are for dealing with the training quest.

; Tracking which gifts are given
;  0: warm anal
;  1: warm vaginal
;  2: cold anal
;  3: cold vaginal
;  4: hot anal
;  5: hot vaginal
;  6: frigid anal
;  7: frigid vaginal
;  8: burning anal
;  9: burning vaginal
; 10: freezing anal
; 11: freezing vaginal
; 12: inferno anal
; 13: inferno vaginal
; 14: arctic anal
; 15: arctic vaginal
; 16: unstable anal
; 17: unstable vaginal
Bool[] Property plugGifted Auto
FormList Property dhr_plugGiftList Auto

Bool Function LeveledItemContains(LeveledItem list, Form target)
  Int size = list.GetNumForms()
  Int i = 0
  While i < size
    If list.GetNthForm(i) == target
      Return True
    EndIf
    i += 1
  EndWhile
  Return False
EndFunction

Bool Function AreMildPlugsRegistered()
  Return LeveledItemContains(zadxQuest.zad_dev_plugs_anal, dhr_dev_plugs_anal_mild) && LeveledItemContains(zadxQuest.zad_dev_plugs_vaginal, dhr_dev_plugs_vaginal_mild)
EndFunction

Bool Function AreExtremePlugsRegistered()
  Return LeveledItemContains(zadxQuest.zad_dev_plugs_anal, dhr_dev_plugs_anal_extreme) && LeveledItemContains(zadxQuest.zad_dev_plugs_vaginal, dhr_dev_plugs_vaginal_extreme)
EndFunction

Function RegisterMildPlugs()
  If !LeveledItemContains(zadxQuest.zad_dev_plugs_anal, dhr_dev_plugs_anal_mild)
    zadxQuest.zad_dev_plugs_anal.AddForm(dhr_dev_plugs_anal_mild, 1, 1)
  EndIf
  If !LeveledItemContains(zadxQuest.zad_dev_plugs_vaginal, dhr_dev_plugs_vaginal_mild)
    zadxQuest.zad_dev_plugs_vaginal.AddForm(dhr_dev_plugs_vaginal_mild, 1, 1)
  EndIf
EndFunction

Function RegisterExtremePlugs()
  If !LeveledItemContains(zadxQuest.zad_dev_plugs_anal, dhr_dev_plugs_anal_extreme)
    zadxQuest.zad_dev_plugs_anal.AddForm(dhr_dev_plugs_anal_extreme, 1, 1)
  EndIf
  If !LeveledItemContains(zadxQuest.zad_dev_plugs_vaginal, dhr_dev_plugs_vaginal_extreme)
    zadxQuest.zad_dev_plugs_vaginal.AddForm(dhr_dev_plugs_vaginal_extreme, 1, 1)
  EndIf
EndFunction

Event OnSleepStart(Float afSleepStartTime, Float afDesiredSleepEndTime)
  If dhr_vibrationController.GetCurrentVibrationIntensity() > 0.5
    Debug.MessageBox("You tried to fall asleep, but it is not possible due to intense vibrations of the plugs within your body.")
    ; Interrupt sleep. This took me 2 hours to figure out.
    zadQuest.PlayerRef.MoveTo(zadQuest.PlayerRef)
  ElseIf currentTrainingBelt != None && currentTrainingBelt.sleepDeprivationLeftHours > 0 ; If sleep deprivation is enabled
    Int sessionId = -1
    If dhr_vibrationController.PrepareArguments()
      dhr_vibrationController.terminationMode = dhr_vibrationController.TERMINATION_MODE_EDGE
      dhr_vibrationController.orgasmControlMode = dhr_vibrationController.ORGASM_CONTROL_MODE_EDGE_ONLY
      dhr_vibrationController.vibrationIntensity = 1
      dhr_vibrationController.pluralPlugs = True
      sessionId = dhr_vibrationController.StartVibrate(blocking = False)
    EndIf
    If sessionId != -1
      Debug.MessageBox("As soon as you closed your eyes, the soulgems within your body started to vibrate extremely powerfully. It is not possible to sleep like this.")
    Else
      ; Failed to start vibrations? It is ok, we can shock the player instead :D
      Debug.MessageBox("As soon as you closed your eyes, the soulgems let out an extremely powerful electric shock, waking you up completely.")
      ShockPlayer(40, True)
    EndIf
    ; Interrupt sleep.
    zadQuest.PlayerRef.MoveTo(zadQuest.PlayerRef)
  Else
    isPCSleeping = True
  EndIf
EndEvent

Event OnSleepStop(Bool abInterrupted)
  isPCSleeping = False
  Float intensity = dhr_vibrationController.GetCurrentVibrationIntensity()
  zadQuest.PlayerRef.RemoveSpell(dhr_badlyRested)
  If intensity > 0 && intensity <= 0.5
    Debug.MessageBox("Even though it was really difficult, you finally managed to fall asleep despite the vibrations. However, the vibrations did not stop for a single second during the entire night. As you wake up, you find that a large portion of the bed sheet is soaked with your body fluid. You did not get a good sleep. In addition, you are incredibly horny now.")
    zadQuest.UpdateExposure(zadQuest.PlayerRef, 100, True)
    Utility.Wait(3)
    PlayerSleepQuest.RemoveRested()
    zadQuest.PlayerRef.AddSpell(dhr_badlyRested)
  EndIf
EndEvent

; Drains the actor value to current - amount
Function DrainActorValueBy(Actor player, String actorValueName, Float amount, Float reservationRatio)
  Float maxValue = player.GetActorValueMax(actorValueName)
  Float currentValue = player.GetActorValue(actorValueName)
  Float shouldBe = currentValue - amount
  If shouldBe < maxValue * reservationRatio
    ; If lower than reserved value, bump the value up
    shouldBe = maxValue * reservationRatio
  EndIf
  If shouldBe > currentValue
    ; If it is already worse, don't do anything
    Return
  EndIf
  player.DamageActorValue(actorValueName, currentValue - shouldBe)
EndFunction

; Drains the actor value to maxValue - amount
Function DrainActorValueToBy(Actor player, String actorValueName, Float amount, Float reservationRatio)
  Float maxValue = player.GetActorValueMax(actorValueName)
  Float currentValue = player.GetActorValue(actorValueName)
  Float shouldBe = maxValue - amount
  If shouldBe < maxValue * reservationRatio
    ; If lower than reserved value, bump the value up
    shouldBe = maxValue * reservationRatio
  EndIf
  If shouldBe > currentValue
    ; If it is already worse, don't do anything
    Return
  EndIf
  player.DamageActorValue(actorValueName, currentValue - shouldBe)
EndFunction

Function DrainActorValueByMappedTempDiff(Actor player, Float mappedTempDiff, String actorValueName, Float threshold, Float pointsPerTempDiff, Float reservationRatio)
  If mappedTempDiff <= threshold
    Return
  EndIf
  mappedTempDiff -= threshold
  DrainActorValueToBy(player, actorValueName, pointsPerTempDiff * mappedTempDiff * globalEffectMultiplier, reservationRatio)
EndFunction

; This is the clock of Devious Heatrise. In order to prevent putting unnecessary
; stress on Papyrus, this clock is only activated when the player is actually
; wearing any device from this mod.
Event OnUpdateGameTime()
  Bool continued = False
  Float mappedTempDiff = 0.0
  If currentVaginalPlug != None
    RegisterForSingleUpdateGameTime(0.1)
    continued = True
    mappedTempDiff += currentVaginalPlug.Tick()
  EndIf
  If currentAnalPlug != None
    If !continued
      RegisterForSingleUpdateGameTime(0.1)
    EndIf
    mappedTempDiff += currentAnalPlug.Tick()
  EndIf
  If currentTrainingBelt != None
    If !continued
      RegisterForSingleUpdateGameTime(0.1)
    EndIf
    currentTrainingBelt.Tick()
  EndIf
  Actor player = Game.GetPlayer()
  DrainActorValueByMappedTempDiff(player, mappedTempDiff, "Health", hpDrainThreshold, hpDrainPointsPerTempDiff, hpDrainReservationRatio)
  DrainActorValueByMappedTempDiff(player, mappedTempDiff, "Magicka", mpDrainThreshold, mpDrainPointsPerTempDiff, mpDrainReservationRatio)
  DrainActorValueByMappedTempDiff(player, mappedTempDiff, "Stamina", staminaDrainThreshold, staminaDrainPointsPerTempDiff, staminaDrainReservationRatio)
EndEvent

dhrHeatingPlugScript Function GetCurrentPlug(Bool isVaginal)
  If isVaginal
    Return currentVaginalPlug
  Else
    Return currentAnalPlug
  EndIf
EndFunction

Function OnPlugEquipped(dhrHeatingPlugScript plug, Bool isVaginal)
  If isVaginal
    currentVaginalPlug = plug
  Else
    currentAnalPlug = plug
  EndIf
  ; Thus we will always try to restart the task when a new plug is equipped.
  RegisterForSingleUpdateGameTime(0.05)
EndFunction

Function OnPlugUnequipped(Bool isVaginal)
  If isVaginal
    currentVaginalPlug = None
  Else
    currentAnalPlug = None
  EndIf
EndFunction

Function OnTrainingBeltEquipped(dhrTrainingBeltScript belt)
  currentTrainingBelt = belt
  RegisterForSingleUpdateGameTime(0.05)
EndFunction

Function OnTrainingBeltUnequipped()
  currentTrainingBelt = None
EndFunction

; Map the actual temperature to the temperature felt after applying skill bonuses
Float Function MapPlugTemperature(Float actualTemperature, Bool isVaginal)
  Float temperature = actualTemperature
  If temperature > bodyTemperature
    If isVaginal
      temperature -= dhr_vaginalHeatResistanceSkill.level * skillEffectiveness
    Else
      temperature -= dhr_analHeatResistanceSkill.level * skillEffectiveness
    EndIf
    If temperature < bodyTemperature
      temperature = bodyTemperature
    EndIf
  Else
    If isVaginal
      temperature += dhr_vaginalColdResistanceSkill.level * skillEffectiveness
    Else
      temperature += dhr_analColdResistanceSkill.level * skillEffectiveness 
    EndIf
    If temperature > bodyTemperature
      temperature = bodyTemperature
    EndIf
  EndIf
  Return temperature
EndFunction

Function ShockPlayer(Float amount, Bool respectHpDrainReservationRatio)
  Actor player = zadQuest.PlayerRef
  If amount < 20
    Debug.Notification("The plugs within you let out a painful electrical shock!")
  ElseIf amount < 40
    Debug.Notification("The plugs within you let out a very painful electrical shock!")
  Else
    Debug.Notification("The plugs within you let out an extremely painful electrical shock!")
  EndIf
  ; Somehow this creates two threads and the two effects will run at the same time.
  If shockCauseFallOver
    SendModEvent("dhr_shockPlayerEffect_1") ; Trip the player
  EndIf
  SendModEvent("dhr_shockPlayerEffect_2") ; Shock effect
  If respectHpDrainReservationRatio
    DrainActorValueBy(player, "Health", amount, hpDrainReservationRatio)
  Else
    DrainActorValueBy(player, "Health", amount, 0.0)
  EndIf
EndFunction

Event ShockPlayerEffect_1(String eventName, String strArg, Float numArg, Form sender)
  zadQuest.Trip(zadQuest.PlayerRef)
EndEvent

Event ShockPlayerEffect_2(String eventName, String strArg, Float numArg, Form sender)
  ; This uses the no damage spell bundled with Devious Heatrise as the damage is done by papyrus
  dhr_zad_electroShockSpellNoDamage.RemoteCast(zadQuest.PlayerRef, zadQuest.PlayerRef, zadQuest.PlayerRef)
EndEvent

Bool Function HasFrostfall()
  Return Game.GetModByName("Frostfall.esp") != 255
EndFunction

Function Maintenance()
  If currentMigrationVersion != 1
    ; From future?
    Debug.MessageBox("Devious Heatrise maintenance failed\nUnknown previous migration version: " + currentMigrationVersion)
  EndIf
  RegisterForModEvent("dhr_shockPlayerEffect_1", "ShockPlayerEffect_1")
  RegisterForModEvent("dhr_shockPlayerEffect_2", "ShockPlayerEffect_2")
  RegisterForModEvent("DDI_Quest_SigTerm", "OnSigTermReceived")
  dhr_vibrationController.RegisterEvents()
  dhr_vibrationController.RestartSounds()
EndFunction

Event OnInit()
  plugGifted = New Bool[18]
  Maintenance()
  RegisterForSleep()
EndEvent

Event OnSigTermReceived()
  If dhr_trainingQuest.internalStage != 0
    Debug.MessageBox("Devious Heatrise has received DDI_Quest_SigTerm. Terminating training quest now.")
    dhr_trainingQuest.StopTrainingNoAssertion()
  EndIf
EndEvent

; Assert a statement is true. If not, display a message asking the user to report.
Bool Function SoftAssert(Bool criteria, String msg) Global
  If !criteria
    Debug.MessageBox("Devious Heatrise soft assertion failed\n" + msg + "\nThis is most likely a bug, please report.")
  EndIf
  Return criteria
EndFunction

String Function FormatFloat(Float number) Global
  Float rounded = Math.Floor(number * 10 + 0.5) / 10.0
  Int intPart = Math.Floor(rounded)
  Int decimalPart = Math.Floor((rounded - intPart) * 10 + 0.5)
  Return (intPart as String) + "." + (decimalPart as String)
EndFunction

Float Function CelsiusToFahrenheit(Bool isAbs, Float celsius) Global
  If isAbs
    Return AbsCelsiusToFahrenheit(celsius)
  Else
    Return ScaleCelsiusToFahrenheit(celsius)
  EndIf
EndFunction

Float Function FahrenheitToCelsius(Bool isAbs, Float fahrenheit) Global
  If isAbs
    Return AbsFahrenheitToCelsius(fahrenheit)
  Else
    Return ScaleFahrenheitToCelsius(fahrenheit)
  EndIf
EndFunction

; 10°C -> 50°F
Float Function AbsCelsiusToFahrenheit(Float celsius) Global
  Return celsius * 9 / 5 + 32
EndFunction

; 50°F -> 10°C
Float Function AbsFahrenheitToCelsius(Float fahrenheit) Global
  Return (fahrenheit - 32) * 5 / 9
EndFunction

; Diff by 10°C -> Diff by 18°F
Float Function ScaleCelsiusToFahrenheit(Float celsius) Global
  Return celsius * 9 / 5
EndFunction

; Diff by 18°F -> Diff by 10°C
Float Function ScaleFahrenheitToCelsius(Float fahrenheit) Global
  Return fahrenheit * 5 / 9
EndFunction

String Function FormatTemperature(Float temperature)
  If useFahrenheit
    Return FormatFloat(AbsCelsiusToFahrenheit(temperature)) + "F"
  Else
    Return FormatFloat(temperature) + "C"
  EndIf
EndFunction

String Function SwitchPlural(Float amount, String singular, String plural) Global
  If amount == 1.0
    Return singular
  Else
    Return plural
  EndIf
EndFunction
