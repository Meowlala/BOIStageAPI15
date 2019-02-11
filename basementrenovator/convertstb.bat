set out="%~1\..\%~n1.xml"
Executables\Gibbed.Afterbirth.ConvertStage.exe %1 %out%
Executables\XMLToLua.exe %out%
