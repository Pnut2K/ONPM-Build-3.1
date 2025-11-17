#Numbers of lines will probably need to change when edits to RSBE01.txt or BOOST.txt are made.

copy "../Build/Project+/RSBE01.txt" "../Build/Project+/NETPLAY.txt" -Force -erroraction 'silentlycontinue'
copy "../Build/Project+/BOOST.txt" "../Build/Project+/NETBOOST.txt" -Force -erroraction 'silentlycontinue'
New-Item -ItemType Directory -Force -Path "../Build/Project+/Source/Netplay/"
copy "../Build/Project+/Source/Project+/StageFiles.asm" "../Build/Project+/Source/Netplay/Net-StageFiles.asm" -Force -erroraction 'silentlycontinue'
copy "../Build/Project+/Source/Project+/Random.asm" "../Build/Project+/Source/Netplay/Net-Random.asm" -Force -erroraction 'silentlycontinue'
copy "../Build/Project+/Source/Project+/MyMusic.asm" "../Build/Project+/Source/Netplay/Net-MyMusic.asm" -Force -erroraction 'silentlycontinue'
copy "../NetplayFiles/seal" "../Build/Project+/pf/toy/" -Force -Recurse -erroraction 'silentlycontinue'
copy "../NetplayFiles/Netplay" "../Build/Project+/Source/" -Force -Recurse -erroraction 'silentlycontinue'
copy "../NetplayFiles/dnet.cmnu" "../Build/Project+/pf/menu3/" -Force -erroraction 'silentlycontinue'
del "../Build/Project+/pf/sound/netplaylist" -Confirm:$false -Recurse -erroraction 'silentlycontinue'
Copy-Item "../Build/Project+/pf/sound/tracklist" -Destination "../Build/Project+/pf/sound/netplaylist" -Force -Recurse -erroraction 'silentlycontinue'
Move-Item "../Build/Project+/st" -Destination "../stBackup" -Force

#NETPLAY.txt
$netplayPath = "..\Build\Project+\NETPLAY.txt"
(Get-Content $netplayPath).replace('Source/Project+/MultiGCT.asm', 'Source/Netplay/Net-MultiGCT.asm') | Set-Content $netplayPath
(Get-Content $netplayPath).replace('Source/CodeMenu/CodeMenu.asm', 'Source/Netplay/Net-CodeMenu.asm') | Set-Content $netplayPath
$netplayContent = Get-Content $netplayPath
$netplayContent[15] += "`r`n`r`n# Netplay Codeset Differences:`r`n"
$netplayContent[15] += "#`r`n"
$netplayContent[15] += "# NETBOOST.GCT is loaded instead of BOOST.GCT (see bottom of codeset)`r`n"
$netplayContent[15] += '# "Source/Netplay/Net-CodeMenu.asm" is loaded instead of "Source/CodeMenu/CodeMenu.asm"'
$netplayContent[15] += "`r`n#`r`n"
$netplayContent[15] += "#############################################################################"
$netplayContent | Set-Content $netplayPath

#NETBOOST.txt
$netboostPath = "..\Build\Project+\NETBOOST.txt"
(Get-Content $netboostPath).replace('Source/Project+/StageFiles.asm', 'Source/Netplay/Net-StageFiles.asm') | Set-Content $netboostPath
(Get-Content $netboostPath).replace('.include Source/Extras/Console.asm', '#.include Source/Extras/Console.asm') | Set-Content $netboostPath
(Get-Content $netboostPath).replace('#.include Source/Extras/Netplay.asm', '.include Source/Extras/Netplay.asm') | Set-Content $netboostPath

#Net-MultiGCT
(Get-Content "..\Build\Project+\Source\Project+\MultiGCT.asm") -replace 'BOOST.GCT', 'NETBOOST.GCT' | Out-File -encoding ASCII "..\Build\Project+\Source\Netplay\Net-MultiGCT.asm"

#Net-StageFiles
$stagefilesPath = "..\Build\Project+\Source\Netplay\Net-StageFiles.asm"
(Get-Content $stagefilesPath).replace('/sound/tracklist/', '/sound/netplaylist/') | Set-Content $stagefilesPath
(Get-Content $stagefilesPath).replace('source/Project+/MyMusic.asm', 'source/Netplay/Net-MyMusic.asm') | Set-Content $stagefilesPath
(Get-Content $stagefilesPath).replace('source/Project+/Random.asm', 'source/Netplay/Net-Random.asm') | Set-Content $stagefilesPath
$stagefilesContent = Get-Content $stagefilesPath
$stagefilesContent[0] = "#`r`n"
$stagefilesContent[0] += "# This file is nearly identical to Project+/StageFiles.asm but changes the following:`r`n"
$stagefilesContent[0] += "# -it points to Netplay/Net-Random.asm instead of Project+/Random.asm`r`n"
$stagefilesContent[0] += "# -it points to Netplay/Net-MyMusic.asm instead of Project+/MyMusic.asm`r`n"
$stagefilesContent[0] += '# -string "/sound/tracklist/" -> "sound/netplaylist/"'
$stagefilesContent[0] += "`r`n#`r`n#################################"
$stagefilesContent | Set-Content $stagefilesPath

#Net-MyMusic
$mymusicPath = "..\Build\Project+\Source\Netplay\Net-MyMusic.asm"
(Get-Content $mymusicPath).replace("CMM SD File Saver (Uses SD Root Code’s Directory) [Desi, Fracture, DukeItOut]", "# Note that CMM SD File Saver isn’t present here, that’s by design! Netplay doesn’t save tracklists on purpose!`r`n!CMM SD File Saver (Uses SD Root Code’s Directory) [Desi, Fracture, DukeItOut]") | Set-Content $mymusicPath

#Net-Random
$randomPath = "..\Build\Project+\Source\Netplay\Net-Random.asm"
(Get-Content $randomPath).replace("0x00	# Index of main .rss to load/save, Netplay - 0xFF", "0xFF	# Index of main .rss to load/save; is set to 0xFF for Netplay!") | Set-Content $randomPath
(Get-Content $randomPath).replace("%call (gfFileIO__writeSDFile)", "#%call (gfFileIO__writeSDFile)") | Set-Content $randomPath



#RSBE01.txt
$rsbe01Path = "..\Build\Project+\RSBE01.txt"
$strapcode = Select-String -Path $rsbe01Path -Pattern "046CADE8"
if ($strapcode -eq $null)
{
	(Get-Content $rsbe01Path).replace("80078E14", "80078E14`r`n* 046CADE8 48000298") | Set-Content $rsbe01Path
}