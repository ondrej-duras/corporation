for /F "usebackq" %%P IN (`enter.pl -sp ">>"`) do @(set PASS=%%P)
@echo %PASS% | md5sum
@echo 67dd5................4dcdbae866a *-
