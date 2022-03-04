# Refactor documentation

* All do-blocks in the original main.lua split into separate files
* The fake locals mapped to StageAPI variables replaced with local variables, shared via the "shared.lua" file
* Mod defined not in main.lua but in specific mod.lua file, to allow sharing
* All callbacks replaced by functions "exported" by the file, and added in various callback files, 
to avoid needing to share the mod variable