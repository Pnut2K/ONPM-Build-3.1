del .\Build\Project+\NETPLAY.txt /Q
del .\Build\Project+\NETBOOST.txt /Q
del .\Build\Project+\pf\menu3\dnet.cmnu /Q
rmdir .\Build\Project+\pf\movie /s /q
rmdir .\Build\Project+\pf\sound\netplaylist /s /q
rmdir .\Build\Project+\Source\Netplay /s /q
powershell.exe .\RenameFilesForWiiBuild.ps1
".\Build\Project+\GCTRealMate.exe" -q ".\Build\Project+\RSBE01.txt"
".\Build\Project+\GCTRealMate.exe" -q ".\Build\Project+\BOOST.txt"
".\Build\Project+\GCTRealMate.exe" -q ".\Build\Project+\Source\Injects\MDEF.txt"
".\Build\Project+\GCTRealMate.exe" -q ".\Build\Project+\Source\Injects\DEFINE.txt"
move ".\Build\Project+\Source\Injects\MDEF.GCT" ".\Build\Project+\pf\injects\MDEF.gct"
move ".\Build\Project+\Source\Injects\DEFINE.GCT" ".\Build\Project+\pf\injects\DEFINE.gct"
:: powershell.exe .\ZipWiiFiles.ps1
