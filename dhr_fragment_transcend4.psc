;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname dhr_fragment_transcend4 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
Actor player = Game.GetPlayer()
dhr_transcendSkillEffectSpell.RemoteCast(player, player, player)
Utility.Wait(1.0)
skill.Transcend()
Debug.MessageBox("As Arcadia casts her magic, you felt your " + skill.skillName + " has became much weaker. However, there is much more room for improvements now.")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

dhrSkill Property skill  Auto  

SPELL Property dhr_transcendSkillEffectSpell  Auto  
