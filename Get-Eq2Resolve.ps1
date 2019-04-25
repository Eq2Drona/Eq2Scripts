<#
.synopsis
Get EQ2 resolve values for list of characters.

.description
This script will query EQ2 census database and display resolve values for a list of charcters.
It will show total as well as indsvual equipment slot resolves.

.parameter FileName
The file which contains the list of characters.

.parameter ServerName
The server name of the characters in the list.

.parameter ServiceId
The Daybreak Census ID to perform your queries through. If you
are going to use this script more than a few time you should 
create your own service ID to help Daybreak track usage. You can
set up your own service ID for free at:

  https://census.daybreakgames.com/#devSignup

.outputs
  Resolve

.example

.\Get-Eq2Resolve.ps1 CharacterList.txt -ServerName Thurgadin -ServiceId eq2drona

.link
https://github.com/Eq2Drona/Eq2Scripts

#>

[CmdletBinding(PositionalBinding=$false)]
param (
	[Parameter(Position=0)]
	[string]$FileName = "CharacterList.txt",
	[string]$ServerName = "Thurgadin",
	[string]$ServiceId = "eq2drona",
	[long[]]$ExtraIds = @()
)

if ($ServiceId) { $ServiceId = '/s:' + $ServiceId }

# Returns a list of characters from the file supplied.
# Assumes one character name per line.
 function Get-CharacterList {
	Param($FileName)

	$Lines = Get-Content (Join-Path $PSScriptRoot $FileName)

	[string[]] $CharacterList = @()
	foreach($Line in $Lines) {
		$CharacterList += $Line.Trim()
	}
	
	return $CharacterList
}

# Get character info from census database.
function Get-CharacterInfo {
	Param($CharacterName, $ServerName, $ServiceId)
	
	$CharacterName = $CharacterName.ToLower()

	$Url = "http://census.daybreakgames.com{0}/json/get/eq2/character/?locationdata.world={1}&name.first_lower={2}&c:show=name,stats,equipmentslot_list" -f $ServiceId, $ServerName,$CharacterName

	$Json = Invoke-WebRequest -Uri ($Url) | ConvertFrom-Json

	return $Json
}

# Get item's resolve
function Get-ItemResolve {
	Param($ItemId, $ServiceId)
	$Url = "http://census.daybreakgames.com{0}/json/get/eq2/item/{1}" -f $ServiceId, $ItemId
	$Json = Invoke-WebRequest -Uri ($url) | ConvertFrom-Json
	return $Json.item_list.modifiers.resolve.value
}

$CharacterList = Get-CharacterList $FileName
$CharacterList  = $CharacterList | Sort-Object

$Ignore = "Ammo", "Food", "Drink", "Mount Adornment", "Mount Armor"
$MaxLength = 7
$ShouldPrintHeader = $true

foreach ($toonName  in $CharacterList) {
	$Json = Get-CharacterInfo $toonName $ServerName $ServiceId

	$EquipmentSlotList = $Json.character_list.equipmentslot_list
	$TotalResolve = $Json.character_list.stats.combat.resolve

	# Printer a header for the first time
	if ($ShouldPrintHeader) {
		$headerLine = "Name        Resolve "
		foreach ($EquipmentSlot in $EquipmentSlotList) {
			$displayname = $EquipmentSlot.displayname
			If ($displayname -NotIn $Ignore) {
				if ($displayname.Length -gt $MaxLength)	{
					$displayname = $displayname.Substring(0, $MaxLength)
				}
				
				$headerLine += "{0} " -f $displayname.PadRight($MaxLength," ")
			}
		}
		Write-Host ($headerLine) -ForegroundColor Yellow
		
		$ShouldPrintHeader = $false
	}
	if ($toonName.Length -gt 11) {
		$toonName = $toonName.Substring(0, 11)
	}
	
	$toonName = $toonName.PadRight(11," ")

	$resolveLine = "$toonName {0:F0}    " -f $TotalResolve
	foreach ($EquipmentSlot in $EquipmentSlotList) {
		$displayname = $EquipmentSlot.displayname
		If ($displayname -NotIn $Ignore) {
			$resolve = Get-ItemResolve $EquipmentSlot.item.id $ServiceId
			$temp = "{0:F0}" -f $resolve
			$resolveLine += $temp.PadRight($MaxLength + 1," ")
		}
	}

	$resolveLine
}