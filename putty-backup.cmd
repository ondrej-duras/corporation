
echo Makes a Backup on Desktop :-)
rem regedit /e "%USERPROFILE%\Desktop\PuTTY-Sessions-Last.reg" "HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions"
rem regedit /e "%USERPROFILE%\Desktop\PuTTY-FullBack-Last.reg" "HKEY_CURRENT_USER\Software\SimonTatham"
rem regedit /e "%USERPROFILE%\Desktop\PuTTY-WinSCP-Last.reg"   "HKEY_CURRENT_USER\Software\Martin Prikryl\WinSCP 2" 

regedit /e "PuTTY-Sessions-Last.reg" "HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions"
regedit /e "PuTTY-FullBack-Last.reg" "HKEY_CURRENT_USER\Software\SimonTatham"
regedit /e "PuTTY-WinSCP-Last.reg"   "HKEY_CURRENT_USER\Software\Martin Prikryl\WinSCP\ 2"

