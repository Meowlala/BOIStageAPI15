local shared = require("scripts.stageapi.shared")
local Callbacks = require("scripts.stageapi.enums.Callbacks")

StageAPI.AddCallback("StageAPI", Callbacks.POST_SELECT_BOSS_MUSIC, 0, function(stage, usingMusic, isCleared)
    if not isCleared then
        if stage.Name == "Necropolis" or stage.Alias == "Necropolis" then
            if shared.Room:IsCurrentRoomLastBoss() 
            and (shared.Level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0 or shared.Level:GetStage() == LevelStage.STAGE3_2) 
            then
                return Music.MUSIC_MOM_BOSS
            end
        elseif stage.Name == "Utero" or stage.Alias == "Utero" then
            if shared.Room:IsCurrentRoomLastBoss() 
            and (shared.Level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0 or shared.Level:GetStage() == LevelStage.STAGE4_2) 
            then
                return Music.MUSIC_MOMS_HEART_BOSS
            end
        end
    end
end)