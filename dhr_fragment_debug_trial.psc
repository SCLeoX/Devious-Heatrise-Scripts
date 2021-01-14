;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname dhr_fragment_debug_trial Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
dhrTrainingQuestScript trainingQuest = (GetOwningQuest() as dhrTrainingQuestScript)
trainingQuest.StartTraining()
trainingQuest.SelectTrainingMode()
trainingQuest.SelectPlayerStress(1)
trainingQuest.SetObjectiveDisplayed(10, True)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
