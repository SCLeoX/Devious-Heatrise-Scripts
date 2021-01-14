;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname dhr_fragment_selectTrainingMode_1 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
dhr_core.dhr_vendor.DCUR_Strip(Game.GetPlayer(), True)
dhr_core.dhr_trainingQuest.SelectTrainingMode()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

dhrCore Property dhr_core  Auto  
