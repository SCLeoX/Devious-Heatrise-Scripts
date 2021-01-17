ScriptName dhrArcadiaRef extends ReferenceAlias
 
dhrCore Property dhr Auto
 
Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
	If akAggressor == dhr.zadQuest.PlayerRef && dhr.dhr_trainingQuest.internalStage != 0
		Debug.Notification("Arcadia shocks you with the training belt.")
		dhr.ShockPlayer(60, respectHpDrainReservationRatio = False, vaginalShock = True, analShock = True)
	EndIf
EndEvent
