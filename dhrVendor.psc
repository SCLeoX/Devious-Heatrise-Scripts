Scriptname dhrVendor extends Quest
{ Script snippets copied from other mods }

; The following functions come from Deviously Cursed Loot
; https://www.loverslab.com/topic/100032-deviously-cursed-loot-se-beta-2/

Light Property Torch01 Auto
FormList Property dhr_dcur_ammolist Auto
Keyword Property zad_DeviousHeavyBondage Auto
SexLabFramework Property SexLab Auto

bool function DCUR_HasAnyWeaponEquipped(actor a)
	if !a.GetEquippedWeapon(true) && !a.GetEquippedWeapon(false) && !a.getEquippedSpell(1) && !a.getEquippedSpell(0) 
		return false
	endif
	return true
EndFunction

function DCUR_StripWeapons(actor a, bool unequiponly = true)		
	int i = 2	
	Spell spl
	Weapon weap
	Armor sh
	While i > 0
		i -= 1
		if i == 0
			;Utility.Wait(1.0) 
		EndIf	
		spl = a.getEquippedSpell(1)
		if spl
			a.unequipSpell(spl, 1)			
		endIf			
		weap = a.GetEquippedWeapon(true)
		if weap 
			a.unequipItem(weap, false, true)									
		endIf			
		sh = a.GetEquippedShield()
		if sh 
			a.unequipItem(sh, false, true)									
		endIf				
		spl = a.getEquippedSpell(0)
		if spl 
			a.unequipSpell(spl, 0)			
		endIf
		weap = a.GetEquippedWeapon(false)
		if weap 			
			a.unequipItem(weap, false, true)									
		endIf		
	EndWhile
endfunction

function DCUR_Strip(actor a, bool animate)
	Spell spl
	Weapon weap
	Armor sh
	Ammo amm
	Form frm		
	while DCUR_HasAnyWeaponEquipped(a)
    DCUR_StripWeapons(a)
	EndWhile
	frm = a.GetWornForm(0x00001000) ; circlet
	if frm && !frm.HasKeyWordString("NoStrip")
    a.unequipItem(frm, abSilent = true)
  endif
  frm = a.GetWornForm(0x00000020) ; amulet
  if frm && !frm.HasKeyWordString("NoStrip")
    a.unequipItem(frm, abSilent = true)
  endif
	; unequip torches
	if a.GetEquippedItemType(0) == 11		
		a.unequipItem(torch01, abSilent = true)
	endif
	; unequip quivers
	int n = dhr_dcur_ammolist.GetSize()
	while n > 0	
		n -= 1
		amm = dhr_dcur_ammolist.GetAt(n) As Ammo
		if a.IsEquipped(amm)
			a.unequipItem(amm, abSilent = true)
		endif		
	endwhile		
	; Temporarily don't use SexLab strip as it's borked in 1.60.
	; int i = 31	
	; while i >= 0
		; frm = a.GetWornForm(Armor.GetMaskForSlot(i + 30))
		; if frm && !frm.HasKeyWord(SexLabNoStrip)
			; If a.IsEquipped(frm)
				; a.UnequipItem(frm, false, true)	
			; Endif
		; endIf
		; i -= 1
	; endWhile	
	If a.WornHasKeyWord(zad_DeviousHeavyBondage)
		animate = false
	EndIf
	SexLab.StripActor(a, doanimate = animate, leadIn = false) 	
EndFunction