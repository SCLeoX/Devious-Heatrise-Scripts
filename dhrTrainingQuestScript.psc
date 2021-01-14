Scriptname dhrTrainingQuestScript extends Quest Conditional
{ This is main script for controlling the training quest. }

dhrCore Property dhr Auto

; Trials
; Index:
;  0: Increase vaginal temperature by 10C
;  1: Increase vaginal temperature by 20C
;  2: Increase anal temperature by 10C
;  3: Increase anal temperature by 20C
;  4: Decrease vaginal temperature by 10C
;  5: Decrease vaginal temperature by 20C
;  6: Decrease anal temperature by 10C
;  7: Decrease anal temperature by 20C
;  8: Edge 3 times
;  9: Edge 5 times
; 10: Edge 8 times
; 11: Random shocks for 12 hours
; 12: Random shocks for 24 hours
; 13: Random shocks for 36 hours
; 14: Teasing vibration for 3 hours
; 15: Teasing vibration for 6 hours
; 16: Gag and blindfold
; 17: Armbinder
; 18: Yoke
; 19: Straitjacket
; 20: Boots
; 21: Stamina drain for 12 hours
; 22: Stamina drain for 24 hours
; 23: Stamina drain for 36 hours
; 24: Magicka drain for 6 hours
; 25: Magicka drain for 12 hours
; 26: Magicka drain for 18 hours
;
; 27: Sleep deprivation for 36 hours
; 28: Sleep deprivation for 48 hours
; 29: Sleep deprivation for 60 hours
; 30: Chastity bra
; 31: Nipple piercing
; 32: Clitoral piercing
; 33: Arm & Leg cuffs
; 34: Corset & collar
; 35: Glove

FormList Property dhr_trainingQuestFlags Auto

; Flag value:
; -1: The trial has been checked and determined to be unsuitable
;  0: The trial has not been checked nor selected
;  1: The trial has been checked and selected as an option
;  2: The trial has been selected by the player
GlobalVariable[] trialOptionDisplayedFlags


; Here is an overview of how the checkup works:
; - Arcadia chooses training mode (heat or cold) and informs player
; - Arcadia asks player to choose which orifice to stress more
;   - If choose to stress none, the player has to choose one extra trial
;   - If choose to stress either orifice, the procedure continues normally
;   - If choose to stress both, the player has one extra trial option to choose from
; - Arcadia generates trial options and ask player to choose trials
; - Arcadia adjusts the plug settings and applies punishments

; Stage of training
;
; 0: Training have not started
; 1: Arcadia has not chosen training mode
; 2: Arcadia is waiting for player to decide which orifice to stress more
; 3: Trial options has not been generated
; 4: Trial options has been generated, waiting for the player to select
; 5: The player has selected enough trials to take, waiting for application
; 6: Checkup has been finished, waiting 48 hours before going back to stage 1
Int Property internalStage = 0 Auto Conditional

; Flags for controlling the training mode
Bool Property vaginalIsHeating Auto Conditional
Bool Property analIsHeating Auto Conditional

; Temperature determined by Arcadia
Float Property vaginalTemperature Auto
Float Property analTemperature Auto

; How many trials to select
Int Property nTrials Auto Conditional
; How many options to select trials from
Int Property nOptions Auto

Int Property stageMain = 10 AutoReadOnly
Int Property stageCompleted = 20 AutoReadOnly
Int Property objectiveMeetArcadia = 10 AutoReadOnly
Int Property objectiveWait = 20 AutoReadOnly
Int Property objectiveFinishTraining = 100 AutoReadOnly

Int Property checkupsCompleted = 0 Auto Conditional

; Flag for controlling the message about not counting the checkup due to failed
; trial application.
Bool Property trialApplySuccessful Auto Conditional

; Devious Heatrise will display a message box explaining why the checkup will
; not be counted by default when a trial is failed to apply.
; That message is somewhat immersion-breaking. Therefore that message will only
; be shown once. This variables records whether that message has been shown.
Bool hasShownTrialFailHint = False

; The following 2 variables are used for tracking the status of the belt.
; There are 2 cases where they are used:
; 1. When starting a new checkup, Arcadia requires all edgings have been
;    completed.
; 2. When terminating the training, Arcadia requires all edgings have been
;    completed AND all the timers have ran out.
; These 2 variables are updated by the UpdateStatusFlags() function on the
; training belt script.
Bool Property beltHasEdgingsLeft = False Auto Conditional
Bool Property beltHasTimerLeft = False Auto Conditional

; Flag for whether a gift is given
Bool Property giftSuccessful = False Auto Conditional

; Flag for whether the player has used the reroll option
Bool Property canReroll = False Auto Conditional

; Number of gifts should be given. Increment by every 5 checkups completed
Int shouldGiveGiftAmount = 0
; Number of gifts given.
Int givenGiftAmount = 0

Function SoftAssertInternalStage(Int expectedStage)
  If expectedStage != internalStage
    Debug.MessageBox("Devious Heatrise has detected inconsistent internal training stage. This is likely due to a bug. Please report this. It may be ok to keep playing (as it will try to fix the internal stage now), but it is recommended to load an old save if you have one. (Asserting = " + expectedStage + ", Actual = " + internalStage + ")")
    internalStage = expectedStage
  EndIf
EndFunction

; Reset the parameter of checkup
Function ResetCheckupParameters()
  nTrials = 2
  nOptions = 5
  canReroll = True
EndFunction

; Mark the player chooses to stress her vagina
Function StressVagina()
  If vaginalIsHeating
    vaginalTemperature += dhr.trainingStressTemperatureAdditionalDiff
  Else
    vaginalTemperature -= dhr.trainingStressTemperatureAdditionalDiff
  EndIf
EndFunction

; Mark the player chooses to stress her rectum
Function StressRectum()
  If analIsHeating
    analTemperature += dhr.trainingStressTemperatureAdditionalDiff
  Else
    analTemperature -= dhr.trainingStressTemperatureAdditionalDiff
  EndIf
EndFunction

; This function equips the player with the plugs and the belt
; It also starts the training
; Called by dialogue, transition from stage 0 -> stage 1
Function StartTraining()
  SoftAssertInternalStage(0)
  Reset()
  SetStage(stageMain)
  dhr.zadQuest.LockDevice(dhr.zadQuest.PlayerRef, dhr.dhr_plugTrainingVaginalInventory)
  dhr.zadQuest.LockDevice(dhr.zadQuest.PlayerRef, dhr.dhr_plugTrainingAnalInventory)
  dhr.zadQuest.LockDevice(dhr.zadQuest.PlayerRef, dhr.dhr_trainingBeltInventory)
  Debug.MessageBox("Arcadia pushes two soulgems into your vagina and rectum respectively. Afterwards, she locked a chastity belt around your waist.")
  SetObjectiveDisplayed(objectiveFinishTraining, True)
  internalStage = 1
EndFunction

; Called by dialogue, transition from stage 1 -> stage 2
Function SelectTrainingMode()
  SoftAssertInternalStage(1)
  ResetCheckupParameters()

  ; 5 trials completed, player did not choose to terminate training; Therefore,
  ; restart the counter
  If checkupsCompleted == 5
    checkupsCompleted = 0
    shouldGiveGiftAmount += 1
  EndIf

  Float num = Utility.RandomFloat(0.0, 1.0)

  If num < 0.45
    vaginalIsHeating = True
    analIsHeating = True
  ElseIf num < 0.8
    vaginalIsHeating = False
    analIsHeating = False
  ElseIf num < 0.9
    vaginalIsHeating = True
    analIsHeating = False
  Else
    vaginalIsHeating = False
    analIsHeating = True
  EndIf
  
  If vaginalIsHeating
    vaginalTemperature = dhr.bodyTemperature + dhr.trainingBaseTemperatureDiff + dhr.dhr_vaginalHeatResistanceSkill.level * dhr.skillEffectiveness
  Else
    vaginalTemperature = dhr.bodyTemperature - dhr.trainingBaseTemperatureDiff - dhr.dhr_vaginalColdResistanceSkill.level * dhr.skillEffectiveness
  EndIf
  If analIsHeating
    analTemperature = dhr.bodyTemperature + dhr.trainingBaseTemperatureDiff + dhr.dhr_analHeatResistanceSkill.level * dhr.skillEffectiveness
  Else
    analTemperature = dhr.bodyTemperature - dhr.trainingBaseTemperatureDiff - dhr.dhr_analColdResistanceSkill.level * dhr.skillEffectiveness
  EndIf

  internalStage = 2
EndFunction

; 0: Stress none
; 1: Stress vagina
; 2: Stress rectum
; 3: Stress both
; Called by dialogue, transition from stage 2 -> stage 3
Function SelectPlayerStress(Int stressSelection)
  SoftAssertInternalStage(2)
  If stressSelection == 0
    nTrials += 1
  ElseIf stressSelection == 1
    StressVagina()
  ElseIf stressSelection == 2
    StressRectum()
  ElseIf stressSelection == 3
    StressVagina()
    StressRectum()
    nOptions += 1
  EndIf
  internalStage = 3
EndFunction

; Called by dialogue, transition from stage 3 -> stage 4
Function ChooseTrialOptions()
  SoftAssertInternalStage(3)
  RandomlySelectNTrialOptions(nOptions)
  internalStage = 4
EndFunction

Function Reroll()
  SoftAssertInternalStage(4)
  dhrCore.SoftAssert(canReroll, "Reroll is not allowed.")
  canReroll = False
  nTrials += 1
  RandomlySelectNTrialOptions(nOptions)
EndFunction

; Called by dialogue, transition from stage 4
;   -> stage 4 (If there are more to be selected)
;   -> stage 5 (If selected enough)
Function SelectTrial(Int trialId)
  SoftAssertInternalStage(4)

  canReroll = False ; Cannot reroll once selected a trial

  ; Sanity check
  If trialOptionDisplayedFlags[trialId].GetValueInt() != 1
    Debug.MessageBox("Devious Heat did not anticipate trial #" + trialId + " to be a valid choice. This is likely a bug, please report this.")
  EndIf
  trialOptionDisplayedFlags[trialId].SetValueInt(2)

  nTrials -= 1
  If nTrials <= 0
    ; Advance stage if selected enough
    internalStage = 5
  EndIf
EndFunction

; Called by dialogue, transition from stage 5 -> stage 6
Function FinishCheckup()
  SoftAssertInternalStage(5)
  trialApplySuccessful = True
  dhrTrainingBeltScript belt = dhr.currentTrainingBelt
  
  ; Sanity check
  If !dhrCore.SoftAssert(belt != None, "Reference to the training belt has been lost.")
    Return
  EndIf

  Int i = 0
  Bool anyFailed = 0
  While i < trialOptionDisplayedFlags.Length
    If trialOptionDisplayedFlags[i].GetValueInt() == 2 ; Selected by the player
      If !ApplyTrial(i, belt)
        trialApplySuccessful = False
      EndIf
    EndIf
    i += 1
  EndWhile

  dhr.currentAnalPlug.ForceSetActiveTemperature(analTemperature)
  dhr.currentVaginalPlug.ForceSetActiveTemperature(vaginalTemperature)

  SetObjectiveCompleted(objectiveMeetArcadia, True)
  SetObjectiveCompleted(objectiveWait, False)
  SetObjectiveDisplayed(objectiveWait, True)

  If trialApplySuccessful
    dhr.zadQuest.PlayerRef.AddItem(dhr.dhr_climaxKey)
    checkupsCompleted += 1
  Else
    If !hasShownTrialFailHint
      Debug.MessageBox("One of the trials has failed to apply. Therefore this will not count as a checkup completed. This is to prevent cheating. For example, one may select the trial to gag herself, put on a gag with manipulation on in between, and Arcadia will fail to lock on another gag afterwards. If you did not cheat (then please report this as a bug), or want this checkup to be counted regardless, you can always go to MCM and manually increment the trials completed counter. This message will only show up once.")
      hasShownTrialFailHint = True
    EndIf
  EndIf

  RegisterForSingleUpdateGameTime(48)
  internalStage = 6
EndFunction

; Triggered by the timer set up above, transition from stage 6 -> stage 1
Event OnUpdateGameTime()
  SoftAssertInternalStage(6)
  SetObjectiveCompleted(objectiveWait, True)
  SetObjectiveCompleted(objectiveMeetArcadia, False)
  SetObjectiveDisplayed(objectiveMeetArcadia, True)
  internalStage = 1
EndEvent

; Triggered by dialogue, transition from stage 6 or stage 1 -> stage 0
Function StopTraining()
  If internalStage != 1 && internalStage != 6
    Debug.MessageBox("Devious Heatrise has detected inconsistent internal training stage. This is likely due to a bug. Please report this. It may be ok to keep playing (as it will try to fix the internal stage now), but it is recommended to load an old save if you have one. (Asserting = 1 or 6, Actual = " + internalStage + ")")
  EndIf
  Debug.MessageBox("Arcadia takes out a key and inserts it into the keyhole on your chastity belt. Soon, you instinctively let out a sigh of relief as you feel the belt falls off your waist. Afterwards, Arcadia pulls the two soulgems - which are already fully covered with body fluids - out from your body.")
  StopTrainingNoAssertion()
EndFunction

; Triggered by dialogue, does not change stage. Can only occur after the training has stopped.
Function GiveGifts()
  SoftAssertInternalStage(0)
  shouldGiveGiftAmount += 1
  giftSuccessful = True
  While givenGiftAmount < shouldGiveGiftAmount
    If GiveSingleGift()
      givenGiftAmount += 1
    Else
      giftSuccessful = False
      Return
    EndIf
  EndWhile
EndFunction

Int lastPoolIndex

Function AddToPool(Int[] pool, Int plugId)
  If !dhr.plugGifted[plugId]
    lastPoolIndex += 1
    pool[lastPoolIndex] = plugId
  EndIf
EndFunction

Bool Function GiveSingleGift()
  Int[] pool = New Int[18]
  lastPoolIndex = -1

  ; Tier 1 available at the beginning
  AddToPool(pool, 0)
  AddToPool(pool, 1)
  AddToPool(pool, 2)
  AddToPool(pool, 3)

  ; Tier 2 available after 2 gifts
  If givenGiftAmount >= 2
    AddToPool(pool, 4)
    AddToPool(pool, 5)
    AddToPool(pool, 6)
    AddToPool(pool, 7)

    ; Tier 3 available after 4 gifts
    If givenGiftAmount >= 4
      AddToPool(pool, 8)
      AddToPool(pool, 9)
      AddToPool(pool, 10)
      AddToPool(pool, 11)

      ; Tier 4 available after 6 gifts
      If givenGiftAmount >= 4
        AddToPool(pool, 12)
        AddToPool(pool, 13)
        AddToPool(pool, 14)
        AddToPool(pool, 15)
        AddToPool(pool, 16)
        AddToPool(pool, 17)
      EndIf
    EndIf
  EndIf

  If lastPoolIndex != -1
    Int pick = Utility.RandomInt(0, lastPoolIndex)
    dhr.plugGifted[pick] = True
    Armor plug = dhr.dhr_plugGiftList.GetAt(pick) as Armor
    dhrCore.SoftAssert(plug != None, "Plug should not be null.")
    dhr.zadQuest.PlayerRef.AddItem(plug)
    Return True
  EndIf
  Return False
EndFunction

; Triggered by debug tools or internally by StopTraining()
; Transitions to stage 0 from any stage
Function StopTrainingNoAssertion()
  SetObjectiveCompleted(objectiveFinishTraining, True)
  SetStage(stageCompleted)

  dhrTrainingBeltScript belt = dhr.currentTrainingBelt
  If dhrCore.SoftAssert(belt != None, "Reference to the training belt has been lost.")
    belt.RemoveDevice(dhr.zadQuest.PlayerRef)
  EndIf
  
  dhrHeatingPlugScript vaginalPlug = dhr.currentVaginalPlug
  If dhrCore.SoftAssert(vaginalPlug != None, "Reference to the vaginal plug has been lost.")
    vaginalPlug.RemoveDevice(dhr.zadQuest.PlayerRef)
  EndIf

  dhrHeatingPlugScript analPlug = dhr.currentAnalPlug
  If dhrCore.SoftAssert(analPlug != None, "Reference to the anal plug has been lost.")
    analPlug.RemoveDevice(dhr.zadQuest.PlayerRef)
  EndIf

  internalStage = 0
EndFunction

; Convenient function for testing wether any of the listed trials are already selected as options
; Returns true if none are selected.
Bool Function IsNotReceivingAnyTrialOf(Int id0, Int id1 = -1, Int id2 = -1)
  If trialOptionDisplayedFlags[id0].GetValueInt() == 1
    Return False
  EndIf

  If id1 == -1
    Return True
  EndIf
  If trialOptionDisplayedFlags[id1].GetValueInt() == 1
    Return False
  EndIf

  If id2 == -1
    Return True
  EndIf
  If trialOptionDisplayedFlags[id2].GetValueInt() == 1
    Return False
  EndIf

  Return True
EndFunction

; Convenient function for testing wether the player is wearing a device with given keyword.
; Returns true if the player is NOT wearing any.
Bool Function PlayerNotWearing(Keyword kw)
  Return !dhr.zadQuest.PlayerRef.WornHasKeyword(kw)
EndFunction

; This is for filtering whether a trial can be chosen as a possible option.
Bool Function CanReceiveTrial(Int id, dhrTrainingBeltScript belt)
  If id == 0 || id == 1 ; Vaginal temperature increase
    Return vaginalIsHeating && IsNotReceivingAnyTrialOf(0, 1)
  ElseIf id == 2 || id == 3 ; Anal temperature increase
    Return analIsHeating && IsNotReceivingAnyTrialOf(2, 3)
  ElseIf id == 4 || id == 5 ; Vaginal temperature decrease
    Return !vaginalIsHeating && IsNotReceivingAnyTrialOf(4, 5)
  ElseIf id == 6 || id == 7 ; Anal temperature decrease
    Return !analIsHeating && IsNotReceivingAnyTrialOf(6, 7)
  ElseIf id == 8 || id == 9 || id == 10 ; Edge
    Return IsNotReceivingAnyTrialOf(8, 9, 10)
  ElseIf id == 11 || id == 12 || id == 13 ; Random shocks
    Return IsNotReceivingAnyTrialOf(11, 12, 13)
  ElseIf id == 14 || id == 15 ; Teasing vibration
    Return IsNotReceivingAnyTrialOf(14, 15)
  ElseIf id == 16 ; Gag and blindfold
    Return PlayerNotWearing(dhr.zadQuest.zad_DeviousGag) && PlayerNotWearing(dhr.zadQuest.zad_DeviousBlindfold)
  ElseIf id == 17 || id == 18 || id == 19 ; Heavy bondage
    Return IsNotReceivingAnyTrialOf(17, 18, 19) && PlayerNotWearing(dhr.zadQuest.zad_DeviousHeavyBondage)
  ElseIf id == 20 ; Boots
    Return PlayerNotWearing(dhr.zadQuest.zad_DeviousBoots)
  ElseIf id == 21 || id == 22 || id == 23 ; Stamina drain
    Return IsNotReceivingAnyTrialOf(21, 22, 23)
  ElseIf id == 24 || id == 25 || id == 26 ; Magicka drain
    Return IsNotReceivingAnyTrialOf(24, 25, 26)
  ElseIf id == 27 || id == 28 || id == 29 ; Sleep deprivation
    Return IsNotReceivingAnyTrialOf(27, 28, 29)
  ElseIf id == 30 ; Chastity bra
    Return PlayerNotWearing(dhr.zadQuest.zad_DeviousBra)
  ElseIf id == 31 ; Nipple piercing
    Return PlayerNotWearing(dhr.zadQuest.zad_DeviousPiercingsNipple)
  ElseIf id == 32 ; Clitoral piercing
    Return PlayerNotWearing(dhr.zadQuest.zad_DeviousPiercingsVaginal)
  ElseIf id == 33 ; Arm & Leg cuffs
    Return PlayerNotWearing(dhr.zadQuest.zad_DeviousArmCuffs) && PlayerNotWearing(dhr.zadQuest.zad_DeviousLegCuffs)
  ElseIf id == 34 ; Corset & collar
    Return PlayerNotWearing(dhr.zadQuest.zad_DeviousCorset) && PlayerNotWearing(dhr.zadQuest.zad_DeviousCollar)
  ElseIf id == 35 ; Glove
    Return PlayerNotWearing(dhr.zadQuest.zad_DeviousGloves)
  Else
    dhrCore.SoftAssert(False, "Unknown id = " + id)
  EndIf
EndFunction

Function ClearTrialOptions()
  ; We will recreate the array every time
  ; This is to prevent updating the mod from breaking the quest
  trialOptionDisplayedFlags = New GlobalVariable[35] ; UPDATE ME when a new trial is introduced
  Int i = 0
  While i < trialOptionDisplayedFlags.Length
    GlobalVariable variable = dhr_trainingQuestFlags.GetAt(i) As GlobalVariable
    dhrCore.SoftAssert(variable != None, "Variable should not be none.")
    variable.SetValueInt(0)
    trialOptionDisplayedFlags[i] = variable
    i += 1
  EndWhile
EndFunction

Function RandomlySelectNTrialOptions(Int optionsCount)
  ClearTrialOptions()
  Int maxTrialId = trialOptionDisplayedFlags.Length - 1
  dhrTrainingBeltScript belt = dhr.currentTrainingBelt
  
  ; Sanity check
  If !dhrCore.SoftAssert(belt != None, "Reference to the training belt has been lost.")
    Return
  EndIf
  
  Int selected = 0
  Int triesLeft = 300 ; This is to prevent running into infinite loops
  While selected < optionsCount && triesLeft > 0
    Int trialId = Utility.RandomInt(0, maxTrialId)
    If trialOptionDisplayedFlags[trialId].GetValueInt() == 0
      If CanReceiveTrial(trialId, belt)
        trialOptionDisplayedFlags[trialId].SetValueInt(1)
        selected += 1
        ; Debug.MessageBox("Success: " + trialId)
      Else
        ; Set the flag to -1 in order to prevent running the checks twice
        trialOptionDisplayedFlags[trialId].SetValueInt(-1)
        ; Debug.MessageBox("Fail: " + trialId)
      EndIf
    Else
      ; Debug.MessageBox("Skip: " + trialId)
    EndIf
    triesLeft -= 1
  EndWhile
  If triesLeft == 0
    Debug.MessageBox("Devious Heatrise has failed to find enough trial options in alloted attempts.")
  EndIf
EndFunction

Bool Function EquipPlayerWithRandomDevice(Keyword testing_keyword, LeveledItem list)
  If !PlayerNotWearing(testing_keyword)
    Return False
  EndIf
  Armor inventoryDevice = dhr.zadxQuest.GetRandomDevice(list)
  If inventoryDevice == None
    Debug.MessageBox("Devious Heatrise has failed to find a device within list \"" + list.GetName() + "\".")
    Return False
  EndIf
  dhr.zadQuest.LockDevice(dhr.zadQuest.PlayerRef, inventoryDevice)
  Return True
EndFunction

Bool Function ApplyTrial(Int trialId, dhrTrainingBeltScript belt)
  If trialId == 0 ; Increase vaginal temperature by 10C
    vaginalTemperature += 10
  ElseIf trialId == 1 ; Increase vaginal temperature by 20C
    vaginalTemperature += 20
  ElseIf trialId == 2 ; Increase anal temperature by 10C
    analTemperature += 10
  ElseIf trialId == 3 ; Increase anal temperature by 20C
    analTemperature += 20
  ElseIf trialId == 4 ; Decrease vaginal temperature by 10C
    vaginalTemperature -= 10
  ElseIf trialId == 5 ; Decrease vaginal temperature by 20C
    vaginalTemperature -= 20
  ElseIf trialId == 6 ; Decrease anal temperature by 10C
    analTemperature -= 10
  ElseIf trialId == 7 ; Decrease anal temperature by 20C
    analTemperature -= 20
  ElseIf trialId == 8 ; Edge 3 times
    belt.edgingsLeft += 3
    belt.UpdateStatusFlags()
  ElseIf trialId == 9 ; Edge 5 times
    belt.edgingsLeft += 5
    belt.UpdateStatusFlags()
  ElseIf trialId == 10 ; Edge 8 times
    belt.edgingsLeft += 8
    belt.UpdateStatusFlags()
  ElseIf trialId == 11 ; Random shocks for 12 hours
    belt.shockTimeLeftHours += 12
    belt.UpdateStatusFlags()
  ElseIf trialId == 12 ; Random shocks for 24 hours
    belt.shockTimeLeftHours += 24
    belt.UpdateStatusFlags()
  ElseIf trialId == 13 ; Random shocks for 36 hours
    belt.shockTimeLeftHours += 36
    belt.UpdateStatusFlags()
  ElseIf trialId == 14 ; Teasing vibration for 3 hours
    belt.teasingVibrationTimeLeftHours += 3
    belt.UpdateStatusFlags()
  ElseIf trialId == 15 ; Teasing vibration for 6 hours
    belt.teasingVibrationTimeLeftHours += 6
    belt.UpdateStatusFlags()
  ElseIf trialId == 16 ; Gag and blindfold
    Return EquipPlayerWithRandomDevice(dhr.zadQuest.zad_DeviousGag, dhr.zadxQuest.zad_dev_gags) && EquipPlayerWithRandomDevice(dhr.zadQuest.zad_DeviousBlindfold, dhr.zadxQuest.zad_dev_blindfolds)
  ElseIf trialId == 17 ; Armbinder
    Return EquipPlayerWithRandomDevice(dhr.zadQuest.zad_DeviousHeavyBondage, dhr.zadxQuest.zad_dev_armbinders_all)
  ElseIf trialId == 18 ; Yoke
    Return EquipPlayerWithRandomDevice(dhr.zadQuest.zad_DeviousHeavyBondage, dhr.zadxQuest.zad_dev_yokes)
  ElseIf trialId == 19 ; Straitjacket
    Return EquipPlayerWithRandomDevice(dhr.zadQuest.zad_DeviousHeavyBondage, dhr.zadxQuest.zad_dev_suits_straitjackets_dress)
  ElseIf trialId == 20 ; Boots
    Return EquipPlayerWithRandomDevice(dhr.zadQuest.zad_DeviousBoots, dhr.zadxQuest.zad_dev_boots)
  ElseIf trialId == 21 ; Stamina drain for 12 hours
    belt.staminaDrainTimeLeftHours += 12
    belt.UpdateStatusFlags()
  ElseIf trialId == 22 ; Stamina drain for 24 hours
    belt.staminaDrainTimeLeftHours += 24
    belt.UpdateStatusFlags()
  ElseIf trialId == 23 ; Stamina drain for 36 hours
    belt.staminaDrainTimeLeftHours += 36
    belt.UpdateStatusFlags()
  ElseIf trialId == 24 ; Magicka drain for 6 hours
    belt.magickaDrainTimeLeftHours += 6
    belt.UpdateStatusFlags()
  ElseIf trialId == 25 ; Magicka drain for 12 hours
    belt.magickaDrainTimeLeftHours += 12
    belt.UpdateStatusFlags()
  ElseIf trialId == 26 ; Magicka drain for 18 hours
    belt.magickaDrainTimeLeftHours += 18
    belt.UpdateStatusFlags()
  ElseIf trialId == 27 ; Sleep deprivation for 36 hours
    belt.sleepDeprivationLeftHours += 36
    belt.UpdateStatusFlags()
  ElseIf trialId == 28 ; Sleep deprivation for 48 hours
    belt.sleepDeprivationLeftHours += 48
    belt.UpdateStatusFlags()
  ElseIf trialId == 29 ; Sleep deprivation for 60 hours
    belt.sleepDeprivationLeftHours += 60
    belt.UpdateStatusFlags()
  ElseIf trialId == 30 ; Chastity bra
    Return EquipPlayerWithRandomDevice(dhr.zadQuest.zad_DeviousBra, dhr.zadxQuest.zad_dev_chastitybras)
  ElseIf trialId == 31 ; Nipple piercing
    Return EquipPlayerWithRandomDevice(dhr.zadQuest.zad_DeviousPiercingsNipple, dhr.zadxQuest.zad_dev_piercings_nipple)
  ElseIf trialId == 32 ; Clitoral piercing
    Return EquipPlayerWithRandomDevice(dhr.zadQuest.zad_DeviousPiercingsVaginal, dhr.zadxQuest.zad_dev_piercings_vaginal)
  ElseIf trialId == 33 ; Arm & Leg cuffs
    Return EquipPlayerWithRandomDevice(dhr.zadQuest.zad_DeviousArmCuffs, dhr.zadxQuest.zad_dev_armcuffs) && EquipPlayerWithRandomDevice(dhr.zadQuest.zad_DeviousLegCuffs, dhr.zadxQuest.zad_dev_legcuffs)
  ElseIf trialId == 34 ; Corset & collar
    Return EquipPlayerWithRandomDevice(dhr.zadQuest.zad_DeviousCorset, dhr.zadxQuest.zad_dev_corsets) && EquipPlayerWithRandomDevice(dhr.zadQuest.zad_DeviousCollar, dhr.zadxQuest.zad_dev_collars)
  ElseIf trialId == 35 ; Glove
    Return EquipPlayerWithRandomDevice(dhr.zadQuest.zad_DeviousGloves, dhr.zadxQuest.zad_dev_gloves)
  Else
    Return False
  EndIf
  Return True
EndFunction

