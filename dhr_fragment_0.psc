;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname dhr_fragment_0 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
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

Spell Property dhr_transcendSkillEffectSpell Auto

dhrSkill Property skill Auto
