Scriptname dhrConfigMenu extends SKI_ConfigBase

dhrCore Property dhr Auto
GlobalVariable Property dhr_enableDebugDialogue Auto

Int[] trainingQuestGiftPlugIds

Function AddTemperatureOptionST(String stateName, Bool isAbs, String text, Float value, Int flags = 0)
  If dhr.useFahrenheit
    AddSliderOptionST(stateName, text, dhrCore.CelsiusToFahrenheit(isAbs, value), "{1}F", flags)
  Else
    AddSliderOptionST(stateName, text, value, "{1}C", flags)
  EndIf
EndFunction

Function OnTemperatureSliderOpenST(Bool isAbs, Float currentValue, Float defaultValue, Float minValue, Float maxValue)
  If dhr.useFahrenheit
    SetSliderDialogStartValue(dhrCore.CelsiusToFahrenheit(isAbs, currentValue))
    SetSliderDialogDefaultValue(dhrCore.CelsiusToFahrenheit(isAbs, defaultValue))
    SetSliderDialogRange(dhrCore.CelsiusToFahrenheit(isAbs, minValue), dhrCore.CelsiusToFahrenheit(isAbs, maxValue))
  Else
    SetSliderDialogStartValue(currentValue)
    SetSliderDialogDefaultValue(defaultValue)
    SetSliderDialogRange(minValue, maxValue)
  EndIf
  SetSliderDialogInterval(0.1)
EndFunction

Float Function OnTemperatureSliderAcceptST(Bool isAbs, Float value)
  If dhr.useFahrenheit
    SetSliderOptionValueST(value, "{1}F")
    Return dhrCore.FahrenheitToCelsius(isAbs, value)
  Else
    SetSliderOptionValueST(value, "{1}C")
    Return value
  EndIf
EndFunction

Float Function OnTemperatureDefaultST(Bool isAbs, Float defaultValue)
  If dhr.useFahrenheit
    SetSliderOptionValueST(dhrCore.CelsiusToFahrenheit(isAbs, defaultValue), "{1}F")
  Else
    SetSliderOptionValueST(defaultValue, "{1}C")
  EndIf
  Return defaultValue
EndFunction

Event OnPageReset(String currentPage)
  If currentPage == ""
    LoadCustomContent("Devious Heatrise/logo.dds", 376 - (267 / 2), 223 - (440 / 2))
    Return
  Else
    UnloadCustomContent()
  EndIf
  If currentPage == "Common"
    AddHeaderOption("General")
    AddEmptyOption()
    AddToggleOptionST("OptionUseFahrenheit", "Use degree fahrenheit", dhr.useFahrenheit)
    AddSliderOptionST("OptionGlobalEffectMultiplier", "Global effect multiplier", dhr.globalEffectMultiplier, "x{1}")
    AddToggleOptionST("OptionShockCauseFallOver", "Shock cause fall over", dhr.shockCauseFallOver)
    AddEmptyOption()

    AddHeaderOption("Register")
    AddEmptyOption()
    If dhr.AreMildPlugsRegistered()
      AddTextOption("Register mild plugs", "Registered", OPTION_FLAG_DISABLED)
    Else
      AddTextOptionST("OptionRegisterMildPlugs", "Register mild plugs", "REGISTER")
    EndIf
    If dhr.AreExtremePlugsRegistered()
      AddTextOption("Register extreme plugs", "Registered", OPTION_FLAG_DISABLED)
    Else
      AddTextOptionST("OptionRegisterExtremePlugs", "Register extreme plugs", "REGISTER")
    EndIf
    
    AddHeaderOption("Frostfall Integration")
    AddEmptyOption()
    If !dhr.HasFrostfall()
      AddTextOption("Frostfall not installed :(", "", OPTION_FLAG_DISABLED)
      AddEmptyOption()
    Else
      AddToggleOptionST("OptionFrostfallFreezingPreventPassOut", "Prevent pass out", dhr.frostfallFreezingPreventPassOut)
      AddSliderOptionST("OptionFrostfallExposurePerTempDiffPerTick", "Exposure change rate", dhr.frostfallExposurePerTempDiffPerTick, "{2}")
    EndIf
  ElseIf currentPage == "Skills"
    dhr.dhr_vaginalHeatResistanceSkill.MCMReset(self)
    dhr.dhr_vaginalColdResistanceSkill.MCMReset(self)
    dhr.dhr_analHeatResistanceSkill.MCMReset(self)
    dhr.dhr_analColdResistanceSkill.MCMReset(self)
  ElseIf currentPage == "Training Quest"
    AddHeaderOption("General")
    AddEmptyOption()
    If dhr.dhr_trainingQuest.internalStage == 0
      AddTextOption("Training in progress", "NO", OPTION_FLAG_DISABLED)
    Else
      AddTextOption("Training in progress", "YES", OPTION_FLAG_DISABLED)
      AddSliderOptionST("OptionTrainingQuestCheckupsCompleted", "Change checkups completed", dhr.dhr_trainingQuest.checkupsCompleted)
      AddTextOptionST("OptionTerminateTraining", "Terminate training", "DO IT")
    EndIf
    AddEmptyOption()

    AddHeaderOption("Gifts (Unlocked plugs)")
    AddTextOptionST("HoverTrainingGifts", "", "Hover for information")
    trainingQuestGiftPlugIds = New Int[18]
    Int i = 0
    While i < dhr.plugGifted.Length
      If dhr.plugGifted[i]
        trainingQuestGiftPlugIds[i] = AddTextOption(dhr.dhr_plugGiftList.GetAt(i).GetName(), "Awarded")
      Else
        trainingQuestGiftPlugIds[i] = AddTextOption(dhr.dhr_plugGiftList.GetAt(i).GetName(), "X", OPTION_FLAG_DISABLED)
      EndIf
      i += 1
    EndWhile
  ElseIf currentPage == "Advanced"
    AddHeaderOption("Health Drain")
    AddEmptyOption()
    AddTemperatureOptionST("OptionHpDrainThreshold", False, "Health drain threshold", dhr.hpDrainThreshold)
    AddSliderOptionST("OptionHpDrainPointsPerTempDiff", "Health drain amount", dhr.hpDrainPointsPerTempDiff, "{2}")
    AddSliderOptionST("OptionHpReservationRatio", "Health drain reservation ratio", dhr.hpDrainReservationRatio * 100, "{0}%")
    AddEmptyOption()

    AddHeaderOption("Magicka Drain")
    AddEmptyOption()
    AddTemperatureOptionST("OptionMpDrainThreshold", False, "Magicka drain threshold", dhr.mpDrainThreshold)
    AddSliderOptionST("OptionMpDrainPointsPerTempDiff", "Magicka drain amount", dhr.mpDrainPointsPerTempDiff, "{2}")
    AddSliderOptionST("OptionMpReservationRatio", "Magicka drain reservation ratio", dhr.mpDrainReservationRatio * 100, "{0}%")
    AddEmptyOption()

    AddHeaderOption("Stamina Drain")
    AddEmptyOption()
    AddTemperatureOptionST("OptionStaminaDrainThreshold", False, "Stamina drain threshold", dhr.staminaDrainThreshold)
    AddSliderOptionST("OptionStaminaDrainPointsPerTempDiff", "Stamina drain amount", dhr.staminaDrainPointsPerTempDiff, "{2}")
    AddSliderOptionST("OptionStaminaReservationRatio", "Stamina drain reservation ratio", dhr.staminaDrainReservationRatio * 100, "{0}%")
    AddEmptyOption()

    AddHeaderOption("Skill")
    AddEmptyOption()
    AddTemperatureOptionST("OptionExpGainingThreshold", False, "EXP gaining threshold", dhr.expGainingThreshold)
    AddSliderOptionST("OptionExpGainingMultiplier", "EXP gaining multiplier", dhr.expGainingMultiplier, "x{1}")
    AddTemperatureOptionST("OptionSkillEffectiveness", False, "Skill effectiveness", dhr.skillEffectiveness)
    AddEmptyOption()

    AddHeaderOption("Volume")
    AddEmptyOption()
    AddToggleOptionST("OptionVibrationSoundVolumeUseDD", "Vibration volume use DD", dhr.vibrationSoundVolumeUseDD)
    If dhr.vibrationSoundVolumeUseDD
      AddSliderOptionST("OptionVibrationSoundVolumeOverride", "Vibration volume override", dhr.vibrationSoundVolumeOverride * 100, "{0}%", OPTION_FLAG_DISABLED)
    Else
      AddSliderOptionST("OptionVibrationSoundVolumeOverride", "Vibration volume override", dhr.vibrationSoundVolumeOverride * 100, "{0}%")
    EndIf
    AddToggleOptionST("OptionMoanSoundVolumeUseDD", "Moan volume use DD", dhr.moanSoundVolumeUseDD)
    If dhr.moanSoundVolumeUseDD
      AddSliderOptionST("OptionMoanSoundVolumeOverride", "Moan volume override", dhr.moanSoundVolumeOverride * 100, "{0}%", OPTION_FLAG_DISABLED)
    Else
      AddSliderOptionST("OptionMoanSoundVolumeOverride", "Moan volume override", dhr.moanSoundVolumeOverride * 100, "{0}%")
    EndIf

    AddHeaderOption("Training Quest")
    AddEmptyOption()
    AddTemperatureOptionST("OptionTrainingBaseTemperatureDiff", False, "Base temperature difference", dhr.trainingBaseTemperatureDiff)
    AddTemperatureOptionST("OptionTrainingStressTemperatureAdditionalDiff", False, "Stress additional temperature difference", dhr.trainingStressTemperatureAdditionalDiff)

    AddSliderOptionST("OptionTrainingRandomShockMinimumHours", "Random shocks min hours", dhr.trainingRandomShockMinimumHours, "{1} hours")
    AddSliderOptionST("OptionTrainingRandomShockHourlyProbabilityMultiplier", "Random shocks probability", dhr.trainingRandomShockHourlyProbabilityMultiplier, "x{1}")
    AddSliderOptionST("OptionTrainingRandomShockDamageMin", "Random shock min damage", dhr.trainingRandomShockDamageMin)
    AddSliderOptionST("OptionTrainingRandomShockDamageMax", "Random shock max damage", dhr.trainingRandomShockDamageMax)
    AddToggleOptionST("OptionTrainingRandomShockDamageRespectHpDrainReservationRatio", "Random shocks use hp reservation", dhr.trainingRandomShockDamageRespectHpDrainReservationRatio)
    AddEmptyOption()

    AddSliderOptionST("OptionTrainingClimaxVibrationIntensityMin", "Min climax vibration intensity", dhr.trainingClimaxVibrationIntensityMin, "{2}")
    AddSliderOptionST("OptionTrainingClimaxVibrationIntensityMax", "Max climax vibration intensity", dhr.trainingClimaxVibrationIntensityMax, "{2}")

    AddSliderOptionST("OptionTrainingEdgingVibrationIntensityMin", "Min edging vibration intensity", dhr.trainingEdgingVibrationIntensityMin, "{2}")
    AddSliderOptionST("OptionTrainingEdgingVibrationIntensityMax", "Max edging vibration intensity", dhr.trainingEdgingVibrationIntensityMax, "{2}")

    AddSliderOptionST("OptionTrainingTeasingVibrationIntensityMin", "Min teasing vibration intensity", dhr.trainingTeasingVibrationIntensityMin, "{2}")
    AddSliderOptionST("OptionTrainingTeasingVibrationIntensityMax", "Max teasing vibration intensity", dhr.trainingTeasingVibrationIntensityMax, "{2}")

    AddSliderOptionST("OptionTrainingRandomVibrationProbability", "Random vibration probability", dhr.trainingRandomVibrationProbability, "{3}")
    AddEmptyOption()

    AddHeaderOption("Miscellaneous")
    AddEmptyOption()
    AddSliderOptionST("OptionInitialShowNotificationCountdown", "Temperature notification countdown", dhr.initialShowNotificationCountdown, "{0}")
    AddToggleOptionST("OptionEnableDebugDialogue", "Enable debug dialogue", dhr_enableDebugDialogue.GetValueInt())
  ElseIf currentPage == "About"
    AddHeaderOption("Devious Heatrise")
    AddEmptyOption()
    AddTextOption("Mod Version", dhr.MOD_VERSION, OPTION_FLAG_DISABLED)
    AddEmptyOption()
    AddTextOption("Migration Version", dhr.currentMigrationVersion + "/" + dhr.MIGRATION_VERSION, OPTION_FLAG_DISABLED)
    AddEmptyOption()
    AddTextOption("Author", "Rin Tepis", OPTION_FLAG_DISABLED)
  EndIf
EndEvent

Event OnConfigInit()
  Pages = New String[5]
  Pages[0] = "Common"
  Pages[1] = "Skills"
  Pages[2] = "Training Quest"
  Pages[3] = "Advanced"
  Pages[4] = "About"
EndEvent

Event OnOptionHighlight(Int option)
  dhr.dhr_vaginalHeatResistanceSkill.MCMOnHighlight(self, option)
  dhr.dhr_vaginalColdResistanceSkill.MCMOnHighlight(self, option)
  dhr.dhr_analHeatResistanceSkill.MCMOnHighlight(self, option)
  dhr.dhr_analColdResistanceSkill.MCMOnHighlight(self, option)
  
  Int giftPlugId = trainingQuestGiftPlugIds.Find(option)
  If giftPlugId >= 0
    If dhr.plugGifted[giftPlugId]
      SetInfoText("Arcadia has already gifted you " + dhr.dhr_plugGiftList.GetAt(giftPlugId).GetName() + ". You can click this option to reset.")
    EndIf
  EndIf
EndEvent

Event OnOptionSelect(Int option)
  Int giftPlugId = trainingQuestGiftPlugIds.Find(option)
  If giftPlugId >= 0
    If ShowMessage("Are you sure you want to remove this plug from unlocked list?")
      dhr.plugGifted[giftPlugId] = False
      SetTextOptionValue(option, "X", True)
      SetOptionFlags(option, OPTION_FLAG_DISABLED)
    EndIf
  EndIf
EndEvent

;;;;; Advanced ;;;;;

; Miscellaneous

State OptionInitialShowNotificationCountdown
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.initialShowNotificationCountdown)
    SetSliderDialogDefaultValue(100)
    SetSliderDialogRange(10, 1000)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.initialShowNotificationCountdown = value
    SetSliderOptionValueST(value, "{0}")
  EndEvent
  Event OnDefaultST()
    dhr.initialShowNotificationCountdown = 100
    SetSliderOptionValueST(100, "{0}")
  EndEvent
  Event OnHighlightST()
    SetInfoText("When the temperatures of the plugs do not change by a large amount, how often should a notification about the current temperature should be displayed. The lower this value, the more often the notifications.")
  EndEvent
EndState

State OptionEnableDebugDialogue
  Event OnSelectST()
    dhr_enableDebugDialogue.SetValueInt((!dhr_enableDebugDialogue.GetValueInt()) As Int)
    SetToggleOptionValueST(dhr_enableDebugDialogue.GetValueInt())
  EndEvent
  Event OnDefaultST()
    dhr_enableDebugDialogue.SetValueInt(0)
    SetToggleOptionValueST(False)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Whether to display an additional debug dialogue option when talking to Arcadia.")
  EndEvent
EndState



; Training Quest

State OptionTrainingBaseTemperatureDiff
  Event OnSliderOpenST()
    OnTemperatureSliderOpenST(False, dhr.trainingBaseTemperatureDiff, 15, 0, 50)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.trainingBaseTemperatureDiff = OnTemperatureSliderAcceptST(False, value)
  EndEvent
  Event OnDefaultST()
    dhr.trainingBaseTemperatureDiff = OnTemperatureDefaultST(False, 15)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Temperature difference between the plug and max/min comfortable temperature (determined by temperature tolerance skills) when no additional modifier is applied.")
  EndEvent
EndState

State OptionTrainingStressTemperatureAdditionalDiff
  Event OnSliderOpenST()
    OnTemperatureSliderOpenST(False, dhr.trainingStressTemperatureAdditionalDiff, 15, 0, 50)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.trainingStressTemperatureAdditionalDiff = OnTemperatureSliderAcceptST(False, value)
  EndEvent
  Event OnDefaultST()
    dhr.trainingStressTemperatureAdditionalDiff = OnTemperatureDefaultST(False, 15)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Additional temperature difference when a orifice is stressed.")
  EndEvent
EndState

State OptionTrainingRandomShockMinimumHours
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.trainingRandomShockMinimumHours)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(0, 5)
    SetSliderDialogInterval(0.1)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.trainingRandomShockMinimumHours = value
    SetSliderOptionValueST(value, "{1} hours")
  EndEvent
  Event OnDefaultST()
    dhr.trainingRandomShockMinimumHours = 1
    SetSliderOptionValueST(1, "{1} hours")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Minimum time between administering electric shocks when random shocks is enabled.")
  EndEvent
EndState

State OptionTrainingRandomShockHourlyProbabilityMultiplier
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.trainingRandomShockHourlyProbabilityMultiplier)
    SetSliderDialogDefaultValue(3)
    SetSliderDialogRange(0, 10)
    SetSliderDialogInterval(0.1)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.trainingRandomShockHourlyProbabilityMultiplier = value
    SetSliderOptionValueST(value, "x{1}")
  EndEvent
  Event OnDefaultST()
    dhr.trainingRandomShockHourlyProbabilityMultiplier = 3
    SetSliderOptionValueST(3, "x{1}")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Full name: Training random shock hourly probability multiplier. Simply put, the higher this value, the more shocks.")
  EndEvent
EndState

State OptionTrainingRandomShockDamageMin
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.trainingRandomShockDamageMin)
    SetSliderDialogDefaultValue(10)
    SetSliderDialogRange(0, dhr.trainingRandomShockDamageMax)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.trainingRandomShockDamageMin = value
    SetSliderOptionValueST(value)
  EndEvent
  Event OnDefaultST()
    dhr.trainingRandomShockDamageMin = 10
    SetSliderOptionValueST(10)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Minimum amount of damage when a shock is applied.")
  EndEvent
EndState

State OptionTrainingRandomShockDamageMax
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.trainingRandomShockDamageMax)
    SetSliderDialogDefaultValue(60)
    SetSliderDialogRange(dhr.trainingRandomShockDamageMin, 200)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.trainingRandomShockDamageMax = value
    SetSliderOptionValueST(value)
  EndEvent
  Event OnDefaultST()
    dhr.trainingRandomShockDamageMax = 60
    SetSliderOptionValueST(60)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Maximum amount of damage when a shock is applied.")
  EndEvent
EndState

State OptionTrainingRandomShockDamageRespectHpDrainReservationRatio
  Event OnSelectST()
    dhr.trainingRandomShockDamageRespectHpDrainReservationRatio = !dhr.trainingRandomShockDamageRespectHpDrainReservationRatio
    SetToggleOptionValueST(dhr.trainingRandomShockDamageRespectHpDrainReservationRatio)
  EndEvent
  Event OnDefaultST()
    dhr.trainingRandomShockDamageRespectHpDrainReservationRatio = True
    SetToggleOptionValueST(True)
  EndEvent
  Event OnHighlightST()
    SetInfoText("When administering electric shocks, whether to respect health drain reservation ratio set above.")
  EndEvent
EndState

State OptionTrainingClimaxVibrationIntensityMin
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.trainingClimaxVibrationIntensityMin)
    SetSliderDialogDefaultValue(0.6)
    SetSliderDialogRange(0, dhr.trainingClimaxVibrationIntensityMax)
    SetSliderDialogInterval(0.01)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.trainingClimaxVibrationIntensityMin = value
    SetSliderOptionValueST(value, "{2}")
  EndEvent
  Event OnDefaultST()
    dhr.trainingClimaxVibrationIntensityMin = 0.6
    SetSliderOptionValueST(0.6, "{2}")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Minimum vibration intensity when the climax key is inserted. (0.00 is no vibration, while 1.00 is approximately the strength of vanilla Devious Device's \"extremely powerfully\")")
  EndEvent
EndState

State OptionTrainingClimaxVibrationIntensityMax
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.trainingClimaxVibrationIntensityMax)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(dhr.trainingClimaxVibrationIntensityMin, 1.5)
    SetSliderDialogInterval(0.01)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.trainingClimaxVibrationIntensityMax = value
    SetSliderOptionValueST(value, "{2}")
  EndEvent
  Event OnDefaultST()
    dhr.trainingClimaxVibrationIntensityMax = 1
    SetSliderOptionValueST(1, "{2}")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Maximum vibration intensity when the climax key is inserted. (0.00 is no vibration, while 1.00 is approximately the strength of vanilla Devious Device's \"extremely powerfully\")")
  EndEvent
EndState

State OptionTrainingEdgingVibrationIntensityMin
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.trainingEdgingVibrationIntensityMin)
    SetSliderDialogDefaultValue(0.6)
    SetSliderDialogRange(0, dhr.trainingEdgingVibrationIntensityMax)
    SetSliderDialogInterval(0.01)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.trainingEdgingVibrationIntensityMin = value
    SetSliderOptionValueST(value, "{2}")
  EndEvent
  Event OnDefaultST()
    dhr.trainingEdgingVibrationIntensityMin = 0.6
    SetSliderOptionValueST(0.6, "{2}")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Minimum vibration intensity when the \"Edge me\" button is pressed. (0.00 is no vibration, while 1.00 is approximately the strength of vanilla Devious Device's \"extremely powerfully\")")
  EndEvent
EndState

State OptionTrainingEdgingVibrationIntensityMax
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.trainingEdgingVibrationIntensityMax)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(dhr.trainingEdgingVibrationIntensityMin, 1.5)
    SetSliderDialogInterval(0.01)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.trainingEdgingVibrationIntensityMax = value
    SetSliderOptionValueST(value, "{2}")
  EndEvent
  Event OnDefaultST()
    dhr.trainingEdgingVibrationIntensityMax = 1
    SetSliderOptionValueST(1, "{2}")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Maximum vibration intensity when the \"Edge me\" button is pressed. (0.00 is no vibration, while 1.00 is approximately the strength of vanilla Devious Device's \"extremely powerfully\")")
  EndEvent
EndState

State OptionTrainingTeasingVibrationIntensityMin
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.trainingTeasingVibrationIntensityMin)
    SetSliderDialogDefaultValue(0.15)
    SetSliderDialogRange(0, dhr.trainingTeasingVibrationIntensityMax)
    SetSliderDialogInterval(0.01)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.trainingTeasingVibrationIntensityMin = value
    SetSliderOptionValueST(value, "{2}")
  EndEvent
  Event OnDefaultST()
    dhr.trainingTeasingVibrationIntensityMin = 0.15
    SetSliderOptionValueST(0.15, "{2}")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Minimum vibration intensity when teasing the player with weak vibrations. (0.00 is no vibration, while 1.00 is approximately the strength of vanilla Devious Device's \"extremely powerfully\")")
  EndEvent
EndState

State OptionTrainingTeasingVibrationIntensityMax
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.trainingTeasingVibrationIntensityMax)
    SetSliderDialogDefaultValue(0.3)
    SetSliderDialogRange(dhr.trainingTeasingVibrationIntensityMin, 1.5)
    SetSliderDialogInterval(0.01)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.trainingTeasingVibrationIntensityMax = value
    SetSliderOptionValueST(value, "{2}")
  EndEvent
  Event OnDefaultST()
    dhr.trainingTeasingVibrationIntensityMax = 0.3
    SetSliderOptionValueST(0.3, "{2}")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Maximum vibration intensity when teasing the player with weak vibrations. (0.00 is no vibration, while 1.00 is approximately the strength of vanilla Devious Device's \"extremely powerfully\")")
  EndEvent
EndState

State OptionTrainingRandomVibrationProbability
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.trainingRandomVibrationProbability)
    SetSliderDialogDefaultValue(0.05)
    SetSliderDialogRange(0, 0.1)
    SetSliderDialogInterval(0.001)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.trainingRandomVibrationProbability = value
    SetSliderOptionValueST(value, "{3}")
  EndEvent
  Event OnDefaultST()
    dhr.trainingRandomVibrationProbability = 0.05
    SetSliderOptionValueST(0.05, "{3}")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Probability of triggering a random vibration event every tick. The higher this value, the more random vibrations.")
  EndEvent
EndState

; Volume

State OptionVibrationSoundVolumeUseDD
  Event OnSelectST()
    dhr.vibrationSoundVolumeUseDD = !dhr.vibrationSoundVolumeUseDD
    SetToggleOptionValueST(dhr.vibrationSoundVolumeUseDD)
    If dhr.vibrationSoundVolumeUseDD
      SetOptionFlagsST(OPTION_FLAG_DISABLED, False, "OptionVibrationSoundVolumeOverride")
    Else
      SetOptionFlagsST(OPTION_FLAG_NONE, False, "OptionVibrationSoundVolumeOverride")
    EndIf
  EndEvent
  Event OnDefaultST()
    dhr.vibrationSoundVolumeUseDD = True
    SetToggleOptionValueST(True)
    SetOptionFlagsST(OPTION_FLAG_DISABLED, False, "OptionVibrationSoundVolumeOverride")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Whether to use Devious Device's settings for the volume of vibration sound.")
  EndEvent
EndState

State OptionVibrationSoundVolumeOverride
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.vibrationSoundVolumeOverride * 100)
    SetSliderDialogDefaultValue(100)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.vibrationSoundVolumeOverride = value / 100
    SetSliderOptionValueST(value, "{0}%")
  EndEvent
  Event OnDefaultST()
    dhr.vibrationSoundVolumeOverride = 1
    SetSliderOptionValueST(100, "{0}%")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Volume of vibration sound.")
  EndEvent
EndState

State OptionMoanSoundVolumeUseDD
  Event OnSelectST()
    dhr.moanSoundVolumeUseDD = !dhr.moanSoundVolumeUseDD
    SetToggleOptionValueST(dhr.moanSoundVolumeUseDD)
    If dhr.moanSoundVolumeUseDD
      SetOptionFlagsST(OPTION_FLAG_DISABLED, False, "OptionMoanSoundVolumeOverride")
    Else
      SetOptionFlagsST(OPTION_FLAG_NONE, False, "OptionMoanSoundVolumeOverride")
    EndIf
  EndEvent
  Event OnDefaultST()
    dhr.moanSoundVolumeUseDD = True
    SetToggleOptionValueST(True)
    SetOptionFlagsST(OPTION_FLAG_DISABLED, False, "OptionMoanSoundVolumeOverride")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Whether to use Devious Device's settings for the volume of moan sound.")
  EndEvent
EndState

State OptionMoanSoundVolumeOverride
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.moanSoundVolumeOverride * 100)
    SetSliderDialogDefaultValue(100)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.moanSoundVolumeOverride = value / 100
    SetSliderOptionValueST(value, "{0}%")
  EndEvent
  Event OnDefaultST()
    dhr.moanSoundVolumeOverride = 1
    SetSliderOptionValueST(100, "{0}%")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Volume of moan sound.")
  EndEvent
EndState

; Skill

State OptionExpGainingThreshold
  Event OnSliderOpenST()
    OnTemperatureSliderOpenST(False, dhr.expGainingThreshold, 10, 0, 100)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.expGainingThreshold = OnTemperatureSliderAcceptST(False, value)
  EndEvent
  Event OnDefaultST()
    dhr.expGainingThreshold = OnTemperatureDefaultST(False, 10)
  EndEvent
  Event OnHighlightST()
    SetInfoText("You will only start to gain EXP when the body temperature and the plug temperature at least differ by this amount.")
  EndEvent
EndState

State OptionExpGainingMultiplier
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.expGainingMultiplier)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(0, 5)
    SetSliderDialogInterval(0.1)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.expGainingMultiplier = value
    SetSliderOptionValueST(value, "x{1}")
  EndEvent
  Event OnDefaultST()
    dhr.expGainingMultiplier = 1
    SetSliderOptionValueST(dhr.expGainingMultiplier, "x{1}")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Modify the rate of EXP gaining for temperature resistance skills.")
  EndEvent
EndState

State OptionSkillEffectiveness
  Event OnSliderOpenST()
    OnTemperatureSliderOpenST(False, dhr.skillEffectiveness, 1, 0, 10)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.skillEffectiveness = OnTemperatureSliderAcceptST(False, value)
  EndEvent
  Event OnDefaultST()
    dhr.skillEffectiveness = OnTemperatureDefaultST(False, 1)
  EndEvent
  Event OnHighlightST()
    SetInfoText("How much does each level of temperature resistance skills shields.")
  EndEvent
EndState

; Stamina Drain

State OptionStaminaDrainThreshold
  Event OnSliderOpenST()
    OnTemperatureSliderOpenST(False, dhr.staminaDrainThreshold, 15, 0, 100)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.staminaDrainThreshold = OnTemperatureSliderAcceptST(False, value)
  EndEvent
  Event OnDefaultST()
    dhr.staminaDrainThreshold = OnTemperatureDefaultST(False, 15)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Stamina drain will only start when the body temperature and the plug temperature at least differ by this amount.")
  EndEvent
EndState

State OptionStaminaDrainPointsPerTempDiff
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.staminaDrainPointsPerTempDiff)
    SetSliderDialogDefaultValue(2.0)
    SetSliderDialogRange(0, 10)
    SetSliderDialogInterval(0.01)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.staminaDrainPointsPerTempDiff = value
    SetSliderOptionValueST(dhr.staminaDrainPointsPerTempDiff, "{2}")
  EndEvent
  Event OnDefaultST()
    dhr.staminaDrainPointsPerTempDiff = 2.0
    SetSliderOptionValueST(dhr.staminaDrainPointsPerTempDiff, "{2}")
  EndEvent
  Event OnHighlightST()
    SetInfoText("How much stamina does the plug drain for each degree Celsius of difference between the body temperature and the plug temperature.")
  EndEvent
EndState

State OptionStaminaReservationRatio
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.staminaDrainReservationRatio * 100)
    SetSliderDialogDefaultValue(10)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.staminaDrainReservationRatio = value / 100
    SetSliderOptionValueST(value, "{0}%")
  EndEvent
  Event OnDefaultST()
    dhr.staminaDrainReservationRatio = 0.1
    SetSliderOptionValueST(10, "{0}%")
  EndEvent
  Event OnHighlightST()
    SetInfoText("When draining stamina, what percentage of the maximum stamina should be preserved.")
  EndEvent
EndState

; Magicka Drain

State OptionMpDrainThreshold
  Event OnSliderOpenST()
    OnTemperatureSliderOpenST(False, dhr.mpDrainThreshold, 15, 0, 100)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.mpDrainThreshold = OnTemperatureSliderAcceptST(False, value)
  EndEvent
  Event OnDefaultST()
    dhr.mpDrainThreshold = OnTemperatureDefaultST(False, 15)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Magicka drain will only start when the body temperature and the plug temperature at least differ by this amount.")
  EndEvent
EndState

State OptionMpDrainPointsPerTempDiff
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.mpDrainPointsPerTempDiff)
    SetSliderDialogDefaultValue(2.0)
    SetSliderDialogRange(0, 10)
    SetSliderDialogInterval(0.01)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.mpDrainPointsPerTempDiff = value
    SetSliderOptionValueST(dhr.mpDrainPointsPerTempDiff, "{2}")
  EndEvent
  Event OnDefaultST()
    dhr.mpDrainPointsPerTempDiff = 2.0
    SetSliderOptionValueST(dhr.mpDrainPointsPerTempDiff, "{2}")
  EndEvent
  Event OnHighlightST()
    SetInfoText("How much magicka does the plug drain for each degree Celsius of difference between the body temperature and the plug temperature.")
  EndEvent
EndState

State OptionMpReservationRatio
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.mpDrainReservationRatio * 100)
    SetSliderDialogDefaultValue(10)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.mpDrainReservationRatio = value / 100
    SetSliderOptionValueST(value, "{0}%")
  EndEvent
  Event OnDefaultST()
    dhr.mpDrainReservationRatio = 0.1
    SetSliderOptionValueST(10, "{0}%")
  EndEvent
  Event OnHighlightST()
    SetInfoText("When draining magicka, what percentage of the maximum magicka should be preserved.")
  EndEvent
EndState

; Health Drain

State OptionHpDrainThreshold
  Event OnSliderOpenST()
    OnTemperatureSliderOpenST(False, dhr.hpDrainThreshold, 20, 0, 100)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.hpDrainThreshold = OnTemperatureSliderAcceptST(False, value)
  EndEvent
  Event OnDefaultST()
    dhr.hpDrainThreshold = OnTemperatureDefaultST(False, 20)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Health drain will only start when the body temperature and the plug temperature at least differ by this amount.")
  EndEvent
EndState

State OptionHpDrainPointsPerTempDiff
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.hpDrainPointsPerTempDiff)
    SetSliderDialogDefaultValue(4.0)
    SetSliderDialogRange(0, 10)
    SetSliderDialogInterval(0.01)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.hpDrainPointsPerTempDiff = value
    SetSliderOptionValueST(dhr.hpDrainPointsPerTempDiff, "{2}")
  EndEvent
  Event OnDefaultST()
    dhr.hpDrainPointsPerTempDiff = 4.0
    SetSliderOptionValueST(dhr.hpDrainPointsPerTempDiff, "{2}")
  EndEvent
  Event OnHighlightST()
    SetInfoText("How much health does the plug drain for each degree Celsius of difference between the body temperature and the plug temperature.")
  EndEvent
EndState

State OptionHpReservationRatio
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.hpDrainReservationRatio * 100)
    SetSliderDialogDefaultValue(50)
    SetSliderDialogRange(0, 100)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.hpDrainReservationRatio = value / 100
    SetSliderOptionValueST(value, "{0}%")
  EndEvent
  Event OnDefaultST()
    dhr.hpDrainReservationRatio = 0.5
    SetSliderOptionValueST(50, "{0}%")
  EndEvent
  Event OnHighlightST()
    SetInfoText("When draining health, what percentage of the maximum health should be preserved.")
  EndEvent
EndState

;;;;; Common ;;;;;

State OptionShockCauseFallOver
  Event OnSelectST()
    dhr.shockCauseFallOver = !dhr.shockCauseFallOver
    SetToggleOptionValueST(dhr.shockCauseFallOver)
  EndEvent
  Event OnDefaultST()
    dhr.shockCauseFallOver = True
    SetToggleOptionValueST(True)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Whether to play a fall over animation when a shock is applied.")
  EndEvent
EndState

State HoverTrainingGifts
  Event OnHighlightST()
    SetInfoText("Plugs provided by Devious Heatrise will be awarded at the end of Arcadia's training. If a plug type has never been gifted, instances of that plug will disappear when unequipped.")
  EndEvent
EndState

State OptionTerminateTraining
  Event OnSelectST()
    If ShowMessage("Are you sure you want to terminate the training quest?")
      SetTextOptionValueST("DONE, EXIT MENU TO APPLY", True)
      SetOptionFlagsST(OPTION_FLAG_DISABLED)
      dhr.dhr_trainingQuest.StopTrainingNoAssertion()
    EndIf
  EndEvent
  Event OnHighlightST()
    SetInfoText("Forcefully terminate the training quest.")
  EndEvent
EndState

State OptionTrainingQuestCheckupsCompleted
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.dhr_trainingQuest.checkupsCompleted)
    SetSliderDialogDefaultValue(dhr.dhr_trainingQuest.checkupsCompleted)
    SetSliderDialogRange(0, 5)
    SetSliderDialogInterval(1)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.dhr_trainingQuest.checkupsCompleted = value as Int
    SetSliderOptionValueST(dhr.dhr_trainingQuest.checkupsCompleted)
  EndEvent
  Event OnHighlightST()
    SetInfoText("Manually modify number of checkups completed. Set to 5 will allow the player to stop training when talking to Arcadia.")
  EndEvent
EndState

State OptionRegisterMildPlugs
  Event OnSelectST()
    If ShowMessage("Are you sure you want to register those mild plugs? Due to limitations of Skyrim, you cannot unregister.")
      dhr.RegisterMildPlugs()
      SetTextOptionValueST("Registered", True)
      SetOptionFlagsST(OPTION_FLAG_DISABLED)
    EndIf
  EndEvent
  Event OnHighlightST()
    SetInfoText("Register plugs that are mild (i.e. not devastating) from Devious Heatrise to Devious Device's item list. Other content mods may choose to use them when registered. However, plugs added by other content mods will disappear when unequipped, if they have not been unlocked (gifted by Arcadia after a training).")
  EndEvent
EndState

State OptionRegisterExtremePlugs
  Event OnSelectST()
    If ShowMessage("Are you sure you want to register those extreme plugs? Due to limitations of Skyrim, you cannot unregister.")
      dhr.RegisterExtremePlugs()
      SetTextOptionValueST("Registered", True)
      SetOptionFlagsST(OPTION_FLAG_DISABLED)
    EndIf
  EndEvent
  Event OnHighlightST()
    SetInfoText("Register plugs that are extreme (i.e. usually devastating to the player) from Devious Heatrise to Devious Device's item list. Other content mods may choose to use them when registered. However, plugs added by other content mods will disappear when unequipped, if they have not been unlocked (gifted by Arcadia after a training).")
  EndEvent
EndState

State OptionFrostfallFreezingPreventPassOut
  Event OnSelectST()
    dhr.frostfallFreezingPreventPassOut = !dhr.frostfallFreezingPreventPassOut
    SetToggleOptionValueST(dhr.frostfallFreezingPreventPassOut)
  EndEvent
  Event OnDefaultST()
    dhr.frostfallFreezingPreventPassOut = True
    SetToggleOptionValueST(True)
  EndEvent
  Event OnHighlightST()
    SetInfoText("If enabled, when a cooling plug is equipped, Devious Heatrise will not completely drain player's exposure.")
  EndEvent
EndState

State OptionFrostfallExposurePerTempDiffPerTick
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.frostfallExposurePerTempDiffPerTick)
    SetSliderDialogDefaultValue(0.2)
    SetSliderDialogRange(0, 2)
    SetSliderDialogInterval(0.01)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.frostfallExposurePerTempDiffPerTick = value
    SetSliderOptionValueST(value, "{2}")
  EndEvent
  Event OnDefaultST()
    dhr.frostfallExposurePerTempDiffPerTick = 0.2
    SetSliderOptionValueST(0.2, "{2}")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Rate Devious Heatrise affects the exposure used by Frostfall.")
  EndEvent
EndState

State OptionUseFahrenheit
  Event OnSelectST()
    dhr.useFahrenheit = !dhr.useFahrenheit
    SetToggleOptionValueST(dhr.useFahrenheit)
  EndEvent
  Event OnDefaultST()
    dhr.useFahrenheit = False
    SetToggleOptionValueST(False)
  EndEvent
  Event OnHighlightST()
    SetInfoText("By default, Devious Heatrise uses degree Celsius to display temperature. Select this to use degree Fahrenheit instead.")
  EndEvent
EndState

State OptionGlobalEffectMultiplier
  Event OnSliderOpenST()
    SetSliderDialogStartValue(dhr.globalEffectMultiplier)
    SetSliderDialogDefaultValue(1)
    SetSliderDialogRange(0, 5)
    SetSliderDialogInterval(0.1)
  EndEvent
  Event OnSliderAcceptST(Float value)
    dhr.globalEffectMultiplier = value
    SetSliderOptionValueST(dhr.globalEffectMultiplier, "x{1}")
  EndEvent
  Event OnDefaultST()
    dhr.globalEffectMultiplier = 1
    SetSliderOptionValueST(dhr.globalEffectMultiplier, "x{1}")
  EndEvent
  Event OnHighlightST()
    SetInfoText("Set the strength of Devious Heatrise's effects. Effects can be positive (e.g. warm you up if Frostfall is installed) or negative (e.g. Drain your health if the plugs are too hot).")
  EndEvent
EndState
