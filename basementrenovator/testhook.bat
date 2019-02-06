set out=roomTest.xml
xcopy /i/y %1 %out%*
Executables\XMLToLua.exe %out%
