-- LOCALIZATION Logic and translations and fonts


-- Set Localization index
-- Core Lua File will already be loaded before this one, so no need to encapsulate in a function.
local localizationIndex = 0;
if GRM_AddonGlobals.Region == "enUS" or GRM_AddonGlobals.Region == "enGB" then      -- English
    localizationIndex = 1;
elseif GRM_AddonGlobals.Region == "deDE" then                                       -- German
    localizationIndex = 2;
elseif GRM_AddonGlobals.Region == "esES" then                                       -- Spanish ( Euro )
    localizationIndex = 3;
elseif GRM_AddonGlobals.Region == "esMX" then                                       -- Spanish ( Latin American )
    localizationIndex = 4;
elseif GRM_AddonGlobals.Region == "frFR" then                                       -- French
    localizationIndex = 5;
elseif GRM_AddonGlobals.Region == "itIT" then                                       -- Italian
    localizationIndex = 6;
elseif GRM_AddonGlobals.Region == "ptBR" then                                       -- Portuguese
    localizationIndex = 7;
elseif GRM_AddonGlobals.Region == "ruRU" then                                       -- Russian
    localizationIndex = 8;
elseif GRM_AddonGlobals.Region == "koKR" then                                       -- Korean
    localizationIndex = 9;
elseif GRM_AddonGlobals.Region == "zhCN" then                                       -- Chinese (Mandarin)
    localizationIndex = 10;
elseif GRM_AddonGlobals.Region == "zhTW" then                                       -- Chinese (Taiwan)
    localizationIndex = 11;
end

-- 2D Array that will carry all Localized files, in order of their Region Index given above.
-- This method ensures a rapid-fire localization and minimal resource use.
local phrases = {
    -- Exact Phrasing From Server - No custom translation necessary, just pull from client.
    -- Guild_Roster_Manager.Lua
    { "has been kicked" , "aus der Gilde geworfen." , "ha sido expulsado" , "ha sido expulsado" , "a été renvoyé" , "stato cacciato dalla" , "foi expulso da" , "исключает из гильдии " , "길드에서 추방했습니다." , "开除出公会。" , "踢出公會。" },
    { "joined the guild." , "Gilde angeschlossen." , "a la hermandad." , "a la hermandad." , "rejoint la guilde." , "si unisce alla gilda." , "entrou na guilda." , "к гильдии." , "님이 길드에 가입했습니다" , "加入了公会。" , "加入了公會。" },
    { "has promoted" , "befördert." , "ha ascendido" , "ha ascendido" , "a promu" , "al grado" , " promoveu " , " производит " , "로 올렸습니다." , "晋升为" , "晉升為" },
    { "has demoted" , "degradiert." , "ha degradado" , "ha degradado" , "a rétrogradé" , " degrada " , " rebaixou " , " разжалует " , "로 내렸습니다." , "降职为" , "降職為" },
    { "Level: " , "Stufe: " , "Nivel: " , "Nivel: " , "Niveau: " , "Livello: " , "Nível: " , "-го уровня" , " 레벨" , "等级" , "等級" },

    -- GRM_UI.lua
    { "Note:" , "Notiz:" , "Nota:" , "Nota:" , "Note :" , "Nota:" , "Nota:" , "Заметка:" , "쪽지:" , "备注：" , "註記：" },
    { "Officer's Note:" , "Offiziersnotiz:" , "Nota de oficial:" , "Nota de oficial:" , "Note d'officier :" , "Nota degli ufficiali:" , "Nota de oficial:" , "Заметка для офицеров:" , "길드관리자 쪽지:" , "官员备注:" , "幹部註記:" },
    { "Zone:" , "Zone:" , "Zona:" , "Zona:" , "Zone:" , "Zona:" , "Zone:" , "Зона:" , "지역:" , "地区：" , "區域：" },
    
    -- CLASSES
    { "DEATHKNIGHT" },
    { "DEMONHUNTER" }, 
    { "DRUID" },
    { "HUNTER" }, 
    { "MAGE" }, 
    { "MONK" },
    { "PALADIN" }, 
    { "PRIEST" }, 
    { "ROGUE" }, 
    { "SHAMAN" }, 
    { "WARLOCK" }, 
    { "WARRIOR" }
}

-- Method:          GRM_Localize ( string );
-- What it Does:    It takes the given string, matches it in English, then returns the corresponding string based on the region Locale
-- Purpose:         Localization of the addon of course! Translation for quality of life for all!
GRM_Localize = function ( phrase )
    local result = "";
    for i = 1 , #phrases do
        if phrases[i][1] == phrase then
            if phrases[i][localizationIndex] ~= nil then
                result = phrases[i][localizationIndex];                
            end
            break;
        end
    end

    -- if no match was found (possibly no translation as yet provided), then keep the input as the output.
    if result == "" then
        result = phrase;
    end
    return result;
end

-- Method:          GRM_GetFontChoice() -- Not necessary for the most part as I can use "STANDARD_TEXT_FONT" - but, just in case...
-- What it Does:    Selects the proper font for the given locale of the addon user.
-- Purpose:         To ensure no ???? are in place and all characters are accounted for.
GRM_GetFontChoice = function()
    local result = "Fonts\\FRIZQT__.TTF";
    -- For Russian, need Cyrilic compatible font.
    if localizationIndex == 8 then
        -- Russian Cyrilic
        result = "FONTS\\FRIZQT___CYR.TTF";
    elseif localizationIndex == 9 then
        -- Korean
        result = "FONTS\\2002.TTF";
    elseif localizationIndex == 10 then
        -- Mandarin Chines
        result = "Fonts\\ARKai_T.TTF";
    elseif localizationIndex == 11 then
        -- Taiwanese
        result = "FONTS\\blei00d.TTF";
    end
    return result;
end


-- Fontstring names...
-- /run GRM_LocalizationHelper.GRM_LocalizationHelperText:SetText( GuildMemberDetailNoteLabel:GetText());
-- /run GRM_LocalizationHelper.GRM_LocalizationHelperText:SetText( GuildMemberDetailOfficerNoteLabel:GetText());
-- /run GRM_LocalizationHelper.GRM_LocalizationHelperText:SetText( GuildMemberDetailLevel:GetText());
-- /run local name = GuildMemberDetailName:GetFont();print(name)
-- /run GRM_LocalizationHelper.GRM_LocalizationHelperText:SetText (GuildMemberDetailZoneLabel:GetText())



-- UI Helper to make my localization process much easier!!!
-- Disable when not using by commenting out.,..
-- GRM_LocalizationHelper = CreateFrame ( "Frame" , "GRM_LocalizationHelper" , UIParent , "TranslucentFrameTemplate" );
-- GRM_LocalizationHelper:SetPoint ( "CENTER" , UIParent );
-- GRM_LocalizationHelper:SetSize ( 400 , 200 );
-- GRM_LocalizationHelper:EnableMouse ( true );
-- GRM_LocalizationHelper:SetMovable ( true );
-- GRM_LocalizationHelper:RegisterForDrag ( "LeftButton" );
-- GRM_LocalizationHelper:SetScript ( "OnDragStart" , GRM_LocalizationHelper.StartMoving );
-- GRM_LocalizationHelper:SetScript ( "OnDragStop" , GRM_LocalizationHelper.StopMovingOrSizing );

-- GRM_LocalizationHelper.GRM_LocalizationHelperText = GRM_LocalizationHelper:CreateFontString ( "GRM_LocalizationHelper.GRM_LocalizationHelperText" , "OVERLAY" , "GameFontWhiteTiny" );
-- GRM_LocalizationHelper.GRM_LocalizationHelperText:SetPoint ( "CENTER" , GRM_LocalizationHelper , 0 , 25 );
-- GRM_LocalizationHelper.GRM_LocalizationHelperText:SetFont ( GRM_GetFontChoice() , 12 );
-- GRM_LocalizationHelper.GRM_LocalizationHelperText:SetWordWrap ( true );
-- GRM_LocalizationHelper.GRM_LocalizationHelperText:SetWidth ( 375)
-- GRM_LocalizationHelper.GRM_LocalizationHelperText:SetText ( "Waiting for Chat Response" );

-- GRM_LocalizationHelper.GRM_LocalizationButton = CreateFrame ( "Button" , "GRM_LocalizationButton" , GRM_LocalizationHelper , "UIPanelButtonTemplate" );
-- GRM_LocalizationHelper.GRM_LocalizationButton:SetPoint ( "BOTTOM" , GRM_LocalizationHelper , 0 , 5 );
-- GRM_LocalizationHelper.GRM_LocalizationButton:SetSize ( 60 , 50 );
-- GRM_LocalizationHelper.GRM_LocalizationButton:SetText ( "Link" );
-- GRM_LocalizationHelper.GRM_LocalizationButton:SetScript ( "OnClick" , function( self , button )
--     if button == "LeftButton" then
--         ChatFrame1EditBox:SetFocus();
--         ChatFrame1EditBox:SetText ( GRM_LocalizationHelper.GRM_LocalizationHelperText:GetText() );
--     end
-- end);

-- local count = 0;
-- GRM_LocalizationHelper:RegisterEvent ( "CHAT_MSG_SYSTEM")
-- GRM_LocalizationHelper:SetScript ( "OnEvent" , function( self , event , msg )
--     if event == "CHAT_MSG_SYSTEM" then
--         count = count + 1;
--         -- if count == 2 then
--             GRM_LocalizationHelper.GRM_LocalizationHelperText:SetText ( msg );
--         -- end
--     end
-- end);

