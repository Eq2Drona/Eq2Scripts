function Get-CharacterStat {
  Param($toonName)
  $url = "http://census.daybreakgames.com/s:eq2drona/json/get/eq2/character/?locationdata.world=Thurgadin&name.first=$toonName&c:show=name,resists,stats,type,ts,playedtime,locationdata"
  #$url = "http://census.daybreakgames.com/json/get/eq2/character/?locationdata.world=Thurgadin&name.first=$toonName&c:show=name,resists,stats,type,ts,playedtime,locationdata"
  $Json = Invoke-WebRequest -Uri ($url) | ConvertFrom-Json
  
  return $Json.character_list.stats.combat.resolve, $Json.character_list.stats.combat.basemodifier, $Json.character_list.stats.combat.critbonus, $Json.character_list.stats.combat.spelldoubleattackchance, $Json.character_list.resists.physical.effective, $Json.character_list.stats.combat.fervor
}
Write-Host ("{0,-15} {1,5} {2,10} {3,5} {4,11} {5,15} {6,10}" -f "Name", "Resolve", "Potency", "CB", "SDA", "Mitigation", "Fervor") -ForegroundColor Yellow

$ToonList = "Ashkanar","Doominator","Grumpymad","Nastysteel","Satara","Wisk", "Catin", "Drona", 
			"Haarie", "Oskacat", "Sheratan", "Xhalia", "Clawdio", "Firasia", "Laatour", "Raddlesnake", 
			"Warsi", "Zmeu", "Deneb", "Flooho", "Mystille", "Ratulia", "Windtooth", "Zsserghur"

$ToonList  = $ToonList | Sort-Object

foreach ($ToonName in $ToonList) {
	$resolve, $potency, $critBonus, $spellDa, $Mitigation, $fervor = CharacterStat $ToonName
	Write-Host ("{0, -15} {1:F2} {2,11:F2} {3,9:F2} {4,9:F2} {5,10:F2} {6,12:F2}" -f $ToonName, $resolve, $potency, $critBonus, $spellDa, $Mitigation, $fervor)
	#Start-Sleep -s 5
}

#$name, $resolve, $potency = CharacterStat $toonName

#Write-Host ("Name  Resolve") -ForegroundColor Yellow
#"{0} {1:F2}" -f $name, $resolve

#$url = "http://census.daybreakgames.com/json/get/eq2/character/?locationdata.world=Thurgadin&name.first_lower=$toonName&c:show=name,resists,stats,type,ts,playedtime,locationdata"
#$Json = Invoke-WebRequest -Uri ($url)
#$tem = ConvertFrom-Json $Json
#$tem.character_list.name.first
#$tem.character_list
#$tem.character_list.name.first
#$tem.character_list.stats.health.max
#$tem.character_list.stats.combat.basemodifier
#$tem.character_list.stats.combat.critbonus
#$tem.character_list.stats.combat.abilitydoubleattackchance
#$tem.character_list.stats.combat.fervor
#$tem.character_list.stats.combat.spelldoubleattackchance
#$tem.character_list.stats.combat.resolve
#$tem.character_list.resists.physical.effective
#$Json

