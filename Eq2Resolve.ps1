function Get-ItemResolve {
	Param($itemId)
	$url = "http://census.daybreakgames.com/s:eq2drona/json/get/eq2/item/$itemId"
	$Json = Invoke-WebRequest -Uri ($url) | ConvertFrom-Json
	return $Json.item_list.modifiers.resolve.value
}

function Get-CharacterEquipmentSlotList {
	Param($toonName)
	$toonName = $toonName.ToLower()
	$url = "http://census.daybreakgames.com/s:eq2drona/json/get/eq2/character/?name.first_lower=$toonName&locationdata.world=Thurgadin&c:show=equipmentslot_list"
	$Json = Invoke-WebRequest -Uri ($url) | ConvertFrom-Json
	return $Json.character_list.equipmentslot_list
}

function Get-CharacterTotalResolve {
  Param($toonName)
  $toonName = $toonName.ToLower()
  $url = "http://census.daybreakgames.com/s:eq2drona/json/get/eq2/character/?locationdata.world=Thurgadin&name.first_lower=$toonName&c:show=name,resists,stats,type,ts,playedtime,locationdata"
  $Json = Invoke-WebRequest -Uri ($url) | ConvertFrom-Json
  
  return $Json.character_list.stats.combat.resolve
}

$ToonList = "Ashkanar","Doominator","Grumpymad","Nastysteel","Satara","Wisk", "Catin", "Drona", 
			"Haarie", "Oskacat", "Sheratan", "Xhalia", "Clawdio", "Firasia", "Laatour", "Raddlesnake", 
			"Warsi", "Zmeu", "Deneb", "Flooho", "Mystille", "Ratulia", "Windtooth", "Zsserghur"


$shouldPrintHeader = $true
foreach ($toonName  in $ToonList) {
	$equipmentSlotList = Get-CharacterEquipmentSlotList $toonName
	$ignore = "Ammo", "Food", "Drink", "Mount Adornment", "Mount Armor"
	$MaxLength = 7
	$totalResolve = Get-CharacterTotalResolve $toonName
	
	if ($shouldPrintHeader) {
		$headerLine = "Name        Resolve "
		foreach ($equipmentSlot in $equipmentSlotList) {
			$displayname = $equipmentSlot.displayname
			If ($displayname -NotIn $ignore) {
				if ($displayname.Length -gt $MaxLength)	{
					$displayname = $displayname.Substring(0, $MaxLength)
				}
				
				$headerLine += "{0} " -f $displayname.PadRight($MaxLength," ")
			}
		}
		Write-Host ($headerLine) -ForegroundColor Yellow
		
		$shouldPrintHeader = $false
	}
	if ($toonName.Length -gt 11) {
		$toonName = $toonName.Substring(0, 11)
	}
	
	$toonName = $toonName.PadRight(11," ")

	$resolveLine = "$toonName {0:F0}    " -f $totalResolve
	foreach ($equipmentSlot in $equipmentSlotList) {
		$displayname = $equipmentSlot.displayname
		If ($displayname -NotIn $ignore) {
			$resolve = Get-ItemResolve $equipmentSlot.item.id
			$temp = "{0:F0}" -f $resolve
			$resolveLine += $temp.PadRight($MaxLength + 1," ")
		}
	}

	$resolveLine
}

