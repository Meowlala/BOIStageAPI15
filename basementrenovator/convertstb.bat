set dir=%1\..
set out=%dir%\%~n1.xml
Executables\Gibbed.Afterbirth.ConvertStage.exe %1 %out%
Executables\XMLToLua.exe %out%