Scriptname dhrSkill extends Quest
{ Represents a skill }

String Property skillName Auto
String Property skillDescription Auto
Quest Property dhr_transcendSkillQuest Auto
dhrCore Property dhr_core Auto
Int Property transcendSkillQuestObjectiveId Auto
GlobalVariable Property readyToTranscendIndicator Auto
Spell Property effectSpell Auto

Int Property level = 0 Auto
Int Property levelMax = 10 Auto
Int Property transcendLevel = 0 Auto
Float Property exp = 0.0 Auto
Float Property expMax = 50.0 Auto

Bool Function LevelCapEnabled()
  Return !dhr_core.dhr_disableSkillLevelCap.GetValueInt()
EndFunction

Function UpdateReadyToTranscendIndicator()
  If LevelCapEnabled() && level >= levelMax
    readyToTranscendIndicator.SetValueInt(1)
    If !dhr_transcendSkillQuest.IsRunning()
      dhr_transcendSkillQuest.SetStage(10)
    Else
      If dhr_transcendSkillQuest.GetStage() == 20
        ; Quest has been completed, restart
        dhr_transcendSkillQuest.Reset()
        dhr_transcendSkillQuest.SetStage(10)
      EndIf
    EndIf
    If dhr_transcendSkillQuest.IsObjectiveCompleted(transcendSkillQuestObjectiveId)
      dhr_transcendSkillQuest.SetObjectiveCompleted(transcendSkillQuestObjectiveId, False)
    EndIf
    dhr_transcendSkillQuest.SetObjectiveDisplayed(transcendSkillQuestObjectiveId, True)
  Else
    readyToTranscendIndicator.SetValueInt(0)
    If dhr_transcendSkillQuest.IsObjectiveDisplayed(transcendSkillQuestObjectiveId) && !dhr_transcendSkillQuest.IsObjectiveCompleted(transcendSkillQuestObjectiveId)
      dhr_transcendSkillQuest.SetObjectiveCompleted(transcendSkillQuestObjectiveId, True)
      ; If all objectives displayed are marked as completed, finish the quest
      Int i = 0
      While i <= 3
        If dhr_transcendSkillQuest.IsObjectiveDisplayed(i) && !dhr_transcendSkillQuest.IsObjectiveCompleted(i)
          Return
        EndIf
        i += 1
      EndWhile
      dhr_transcendSkillQuest.SetStage(20)
    EndIf
  EndIf
EndFunction

Function UpdateExpMax()
  expMax = 50 + 5 * level
EndFunction

Function UpdateSpell()
  If effectSpell == None
    Return
  EndIf
  Actor player = Game.GetPlayer()
  If player.HasSpell(effectSpell)
    player.RemoveSpell(effectSpell)
  EndIf
  If level != 0
    Float magnitude = level * dhr_core.resistancePercentagePerSkillLevel
    If magnitude > dhr_core.maxResistancePercentagePerOrifice
      magnitude = dhr_core.maxResistancePercentagePerOrifice
    EndIf
    If player.HasSpell(effectSpell)
      player.RemoveSpell(effectSpell)
    EndIf
    effectSpell.SetNthEffectMagnitude(0, magnitude)
    player.AddSpell(effectSpell, False)
  EndIf
EndFunction

Function UpdateState()
  AddExp(0)
EndFunction

Function AddExp(Float amount)
  amount *= dhr_core.expGainingMultiplier
  If dhr_core.dhr_trainingQuest.internalStage != 0 ; Training in progress
    amount *= dhr_core.trainingExpGainingMultiplier
  EndIf
  If !LevelCapEnabled() || level < levelMax
    exp += amount
    Int leveledUp = 0
    While exp >= expMax && (!LevelCapEnabled() || level < levelMax)
      exp -= expMax
      level += 1
      leveledUp += 1
      UpdateExpMax()
    EndWhile
    If leveledUp > 0
      If LevelCapEnabled() && level >= levelMax
        Debug.Notification("You have maxed out your " + skillName + " level.")
      ElseIf leveledUp == 1
        Debug.Notification("Your " + skillName + " level has increased. (Now: " + (level as String) + ")")
      Else
        Debug.Notification("Your " + skillName + " level has increased by " + (leveledUp as String) + ". (Now: " + (level as String) + ")")
      EndIf
      UpdateSpell()
    EndIf
  EndIf
  UpdateReadyToTranscendIndicator()
EndFunction

Int mcmInformationTextId

Function MCMReset(SKI_ConfigBase config)
  config.SetCursorFillMode(1)
  config.AddHeaderOption("Skill: " + skillName)
  mcmInformationTextId = config.AddTextOption("", "Hover for information")
  If LevelCapEnabled()
    config.AddTextOption("Level ", (level as int) + "/" + (levelMax as int), 1)
  Else
    config.AddTextOption("Level ", level as int, 1)
  EndIf
  If LevelCapEnabled() && Level >= levelMax
    config.AddTextOption("Experience ", "MAX", 1)
  Else
    config.AddTextOption("Experience ", (exp as int) + "/" + (expMax as int), 1)
EndIf
  config.AddTextOption("Transcend Level", (transcendLevel as int), 1)
  config.AddEmptyOption()
  config.SetCursorFillMode(2)
  config.AddEmptyOption()
EndFunction

Function Transcend()
  dhrCore.SoftAssert(LevelCapEnabled(), "Shouldn't transcend when level cap is disabled.")
  If level >= levelMax
    level = 0
    levelMax += 5
    exp = 0
    UpdateExpMax()
    transcendLevel += 1
    UpdateSpell()
    UpdateReadyToTranscendIndicator()
  EndIf
EndFunction

Function MCMOnHighlight(SKI_ConfigBase config, Int option)
  If option == mcmInformationTextId
    config.SetInfoText(skillDescription)
  EndIf
EndFunction
