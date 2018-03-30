


-- LOCALIZATION ENUMS AND LOGIC

-- Table used for lookup, to determine the extent of the translation work compelted or not. This will be used as a quick lookup reference rather than parsing and counting the entire dictionaries
GRML.TranslationStatusEnum = {
    English = true,                 -- English is completed
    German = false,
    French = false,
    Italian = false,
    Russian = false,
    SpanishMX = false,
    SpanishEU = false,
    Portuguese = false,
    Korean = false,
    MandarinCN = false,
    MandarinTW = false  
}

GRML.Languages = {
    "English",
    "German",
    "French",
    "Italian",
    "Russian",
    "SpanishMX",
    "SpanishEU",
    "Portuguese" ,
    "Korean",
    "MandarinCN",
    "MandarinTW"
}

-- Array that holds all the initialization functions to load the dictionary of each language.
GRML.LoadLanguage = {
    GRML.English,
    GRML.German,
    GRML.French,
    GRML.Italian,
    GRML.Russian,
    GRML.SpanishMX,
    GRML.SpanishEU,
    GRML.Portuguese,
    GRML.Korean,
    GRML.MandarinCN,
    GRML.MandarinTW
}

-- Method:          GRML.GetFontNameFromLocation ( string )
-- What it does:    Parses out the name of the font from the file
-- Purpose:         To be able to identify any font...
GRML.GetFontNameFromLocation = function ( fontFileLocation )
    local result = "";
    for i = #fontFileLocation , 1 , -1 do
        if string.sub ( fontFileLocation , i , i ) == "\\" then
            result = string.sub ( fontFileLocation , i + 1 , string.find ( fontFileLocation , "%." ) - 1 );
            break;
        end
    end
    result = string.gsub ( result , "_" , "" );
    return result;
end

GRML.FontNames = {
    "Default(" .. GRML.GetFontNameFromLocation ( STANDARD_TEXT_FONT ) .. ")",
    "Blizz FrizQT",
    "Blizz FrizQT(Cyr)",
    "Blizz Korean",
    "Blizz MandarinCN",
    "Blizz MandarinTW",
    "Action Man",
    "Ancient",
    "Bitter",
    "Cardinal",
    "Continuum",
    "Expressway",
    "Merriweather",
    "PT Sans",
    "Roboto",
}

GRML.listOfFonts = {
    -------------------
    -- DEFAULT FONTS
    -------------------
    STANDARD_TEXT_FONT,
    -- Non-Cyrillic Friendly
    "FONTS\\FRIZQT__.TTF",
    -- Cyrillic Friendly
    "FONTS\\FRIZQT___CYR.TTF",
    -- Asian Character Friendly (and Cyrillic)
    -- Korean
    "FONTS\\2002.TTF",
    -- Simplified Chinese
    "FONTS\\ARKai_T.TTF",
    -- Traditional Chines
    "FONTS\\blei00d.TTF",

    ---------------
    -- CUSTOM FONTS (so far none are Asian character friendly)
    ---------------
    "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\Action_Man.TTF",
    "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\Ancient.TTF",
    "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\Bitter-Regular.OTF",
    "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\Cardinal.TTF",      
    "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\Continuum_Medium.TTF",    
    "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\Expressway.TTF",
    "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\Merriweather-Regular.TTF",
    "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\PT_Sans_Narrow.TTF",
    "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\Roboto-Regular.TTF"    
}

-- Method:          GRML.SetNewLanguage ( int , boolean )
-- What it Does:    It establishes both the appropriate region font, and a modifier for the Mandarin text
-- Purpose:         To be able to have an in-game UI option to change the player language.
GRML.SetNewLanguage = function ( index , firstLoad )
    GRML.LoadLanguage[index]();
    GRM_AddonGlobals.FontChoice = GRML.listOfFonts[GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][44]];
    GRML.SetFontModifier();
    if firstLoad then
        GRM_UI.ReloadAllFrames( false );
    else
        GRM_UI.ReloadAllFrames ( true );
    end
end

-- Method:          GRML.SetFontModifier()
-- What it Does:    Since different custom fonts represent font height differently, this normalizes the fonts, relatively close
-- Purpose:         Consistency, as some fonts would be super tiny otherwise.
GRML.SetFontModifier = function()
    -- Reset it...
    GRM_AddonGlobals.FontModifier = 0;
    if GRM_AddonGlobals.FontChoice == "Fonts\\ARKai_T.TTF" then                             -- China
        GRM_AddonGlobals.FontModifier = 0.5;
    elseif GRM_AddonGlobals.FontChoice == "FONTS\\blei00d.TTF" then                         -- Taiwan
        GRM_AddonGlobals.FontModifier = 2;
    elseif GRM_AddonGlobals.FontChoice == "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\Action_Man.TTF" then
        GRM_AddonGlobals.FontModifier = 1;
    elseif GRM_AddonGlobals.FontChoice == "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\Ancient.TTF" then
        GRM_AddonGlobals.FontModifier = 2;
    elseif GRM_AddonGlobals.FontChoice == "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\Cardinal.TTF" then
        GRM_AddonGlobals.FontModifier = 2;
    elseif GRM_AddonGlobals.FontChoice == "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\Continuum_Medium.TTF" then
        GRM_AddonGlobals.FontModifier = 1;
    elseif GRM_AddonGlobals.FontChoice == "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\Expressway.TTF" then
        GRM_AddonGlobals.FontModifier = 1;
    elseif GRM_AddonGlobals.FontChoice == "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\PT_Sans_Narrow.TTF" then
        GRM_AddonGlobals.FontModifier = 2;
    elseif GRM_AddonGlobals.FontChoice == "Interface\\AddOns\\Guild_Roster_Manager\\media\\fonts\\Roboto-Regular.TTF" then
        GRM_AddonGlobals.FontModifier = 1;
    end
    GRM_AddonGlobals.FontModifier = GRM_AddonGlobals.FontModifier + GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][45];
end

-- Method:          GRML.SetNewFont( int )
-- What it Does:    Establishes a new font
-- Purpose:         More player customization controls!!!
GRML.SetNewFont = function( index )
    GRM_AddonGlobals.FontChoice = GRML.listOfFonts[index];
    GRML.SetFontModifier();
    GRM_UI.ReloadAllFrames( true );
end

-- Method:          GRML.GetFontChoice() -- Not necessary for the most part as I can use "STANDARD_TEXT_FONT" - but, just in case...
-- What it Does:    Selects the proper font for the given locale of the addon user.
-- Purpose:         To ensure no ???? are in place and all characters are accounted for.
GRML.GetFontChoiceIndex = function( localizationIndex )
    local result = 1;
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][44] ~= 1 then
        if ( localizationIndex < 5 or ( localizationIndex > 5 and localizationIndex < 9 ) ) then
            result = 2
        else
            result = GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][44];
        end
        -- For Russian, need Cyrilic compatible font.
        if localizationIndex == 5 and GRM_AddonGlobals.Region ~= "ruRU" then
            -- Russian Cyrilic
            result = 3;
        elseif localizationIndex == 9 and GRM_AddonGlobals.Region ~= "koKR" then
            -- Korean
            result = 4;
        elseif localizationIndex == 10 and GRM_AddonGlobals.Region ~= "zhCN" then
            -- Mandarin Chines
            result = 5;
        elseif localizationIndex == 11 and GRM_AddonGlobals.Region ~= "zhTW" then
            -- Taiwanese
            result = 6;
        end
    else
        result = 1;
    end
    return result;
end

-- Method:          GRML.GetNumberUntranslatedLines ( int )
-- What it Does:    It returns the number of language lines that need to be translated
-- Purpose:         To help reach out to the community to build an effort for crowdsupport for translation efforts.
GRML.GetNumberUntranslatedLines = function ( languageIndex )
    local result = 0;
    -- index 1 will always result as 0 since it is written native in English
    if languageIndex > 1 then
        for _ , y in pairs ( GRM_L ) do
            if y == true then
                result = result + 1;
            end
        end
    end
    return result;
end

----------------------------------------------
-------- LOCALIZATION SYSTEM MESSAGES --------
-------- DO NOT CHANGE THESE! THEY ARE--------
-------- DIRECT FROM THE SERVER!!!!!! --------
----------------------------------------------

-- All of these values are static and cannot be changed by the addon as they are system messages based on the player's language settings. Whilst they can manually change the language they are 
-- using for the addon, they cannot adjust the language of the WOW client without exiting WOW and adjusting the settings in the Battle.net launcher settings. This is not possible from within game so these values will
-- be static and are used for identifying and parsing system message events.

-- German Defaults
if GRM_AddonGlobals.Region == "deDE" then
    GRM_AddonGlobals.Localized = true
    GRM_AddonGlobals.LocalizedIndex = 2;
    -- SYSTEM MESSAGES (DO NOT CHANGE THESE!!!! They are used for the back-end code to recognize for parsing info out, not for player UI
    GRM_L["has been kicked"] = "aus der Gilde geworfen."
    GRM_L["joined the guild."] = "Gilde angeschlossen."
    GRM_L["has promoted"] = "befördert."
    GRM_L["has demoted"] = "degradiert."
    GRM_L["Professions"] = "Berufe"
    GRM_L["Guild: "] = "Gilde: "
    GRM_L["Guild created "] = "Gilde am "
    GRM_L["added to friends"] = "zur Kontaktliste hinzugefügt."
    GRM_L["is already your friend"] = "ist bereits einer Eurer Kontakte."
    GRM_L["Player not found."] = "Spieler nicht gefunden."

    GRML.LoadLanguage[2]();

-- French Defaults
elseif GRM_AddonGlobals.Region == "frFR" then
    GRM_AddonGlobals.Localized = true
    GRM_AddonGlobals.LocalizedIndex = 3;
    -- SYSTEM MESSAGES (DO NOT CHANGE THESE!!!! They are used for the back-end code to recognize for parsing info out, not for player UI
    GRM_L["has been kicked"] = "a été renvoyé"
    GRM_L["joined the guild."] = "rejoint la guilde."
    GRM_L["has promoted"] = "a promu"
    GRM_L["has demoted"] = "a rétrogradé"
    GRM_L["Professions"] = "Métiers"
    GRM_L["Guild: "] = "Guilde : "
    GRM_L["Guild created "] = "Guilde créée le "
    GRM_L["added to friends"] = "fait maintenant partie de vos contacts."
    GRM_L["is already your friend"] = "est déjà dans votre liste de contacts."
    GRM_L["Player not found."] = "Joueur introuvable."

    GRML.LoadLanguage[3]();

-- Italian Defaults
elseif GRM_AddonGlobals.Region == "itIT" then
    GRM_AddonGlobals.Localized = true
    GRM_AddonGlobals.LocalizedIndex = 4;
    -- SYSTEM MESSAGES (DO NOT CHANGE THESE!!!! They are used for the back-end code to recognize for parsing info out, not for player UI
    GRM_L["has been kicked"] = "stato cacciato dalla"
    GRM_L["joined the guild."] = "si unisce alla gilda."
    GRM_L["has promoted"] = "al grado"
    GRM_L["has demoted"] = " degrada "
    GRM_L["Professions"] = "Professioni"
    GRM_L["Guild: "] = "Gilda: "
    GRM_L["Guild created "] = "Gilda creata il "
    GRM_L["added to friends"] = "è già nell'elenco amici."
    GRM_L["is already your friend"] = "adicionado à lista de amigos."
    GRM_L["Player not found."] = "Personaggio non trovato."

    GRML.LoadLanguage[4]();

-- Russian Defaults
elseif GRM_AddonGlobals.Region == "ruRU" then
    GRM_AddonGlobals.Localized = true
    GRM_AddonGlobals.LocalizedIndex = 5;
    -- SYSTEM MESSAGES (DO NOT CHANGE THESE!!!! They are used for the back-end code to recognize for parsing info out, not for player UI
    GRM_L["has been kicked"] = "исключает из гильдии "
    GRM_L["joined the guild."] = "к гильдии."
    GRM_L["has promoted"] = " производит "
    GRM_L["has demoted"] = " разжалует "
    GRM_L["Professions"] = "Профессии"
    GRM_L["Guild: "] = "Гильдия: "
    GRM_L["Guild created "] = "Гильдия создана: "
    GRM_L["added to friends"] = " в список друзей."
    GRM_L["is already your friend"] = "уже есть в вашем списке друзей."
    GRM_L["Player not found."] = "Игрок не найден."

    GRML.LoadLanguage[5]();

    -- Spanish (MX) Defaults
elseif GRM_AddonGlobals.Region == "esMX" then
    GRM_AddonGlobals.Localized = true
    GRM_AddonGlobals.LocalizedIndex = 6;
    -- SYSTEM MESSAGES (DO NOT CHANGE THESE!!!! They are used for the back-end code to recognize for parsing info out, not for player UI
    GRM_L["has been kicked"] = "ha sido expulsado"
    GRM_L["joined the guild."] = "a la hermandad."
    GRM_L["has promoted"] = "ha ascendido"
    GRM_L["has demoted"] = "ha degradado"
    GRM_L["Professions"] = "Profesiones"
    GRM_L["Guild: "] = "Hermandad: "
    GRM_L["Guild created "] = "Hermandad creada "
    GRM_L["added to friends"] = "añadido como amigo."
    GRM_L["is already your friend"] = "ya está en tu lista de amigos."
    GRM_L["Player not found."] = "No se ha encontrado al jugador."

    GRML.LoadLanguage[6]();

    -- Spanish (EU) Defaults
elseif GRM_AddonGlobals.Region == "esES" then
    GRM_AddonGlobals.Localized = true
    GRM_AddonGlobals.LocalizedIndex = 7;
    GRM_L["has been kicked"] = "ha sido expulsado"
    GRM_L["joined the guild."] = "a la hermandad."
    GRM_L["has promoted"] = "ha ascendido"
    GRM_L["has demoted"] = "ha degradado"
    GRM_L["Professions"] = "Profesiones"
    GRM_L["Guild: "] = "Hermandad: "
    GRM_L["Guild created "] = "Hermandad creada "
    GRM_L["added to friends"] = "añadido como amigo."
    GRM_L["is already your friend"] = "en tu lista de amigos."
    GRM_L["Player not found."] = "No se ha encontrado al jugador."

    GRML.LoadLanguage[7]();

-- Portuguese Defaults
elseif GRM_AddonGlobals.Region == "ptBR" then
    GRM_AddonGlobals.Localized = true
    GRM_AddonGlobals.LocalizedIndex = 8;
    -- SYSTEM MESSAGES (DO NOT CHANGE THESE!!!! They are used for the back-end code to recognize for parsing info out, not for player UI
    GRM_L["has been kicked"] = "foi expulso da"
    GRM_L["joined the guild."] = "entrou na guilda."
    GRM_L["has promoted"] = " promoveu "
    GRM_L["has demoted"] = " rebaixou "
    GRM_L["Professions"] = "Profissões"
    GRM_L["Guild: "] = "Guilda: "
    GRM_L["Guild created "] = "Guilda criada "
    GRM_L["added to friends"] = "já está na lista de amigos."
    GRM_L["is already your friend"] = "è già nell'elenco amici."
    GRM_L["Player not found."] = "Jogador não encontrado."

    GRML.LoadLanguage[8]();

    -- Korean Defaults
elseif GRM_AddonGlobals.Region == "koKR" then
    GRM_AddonGlobals.Localized = true
    GRM_AddonGlobals.LocalizedIndex = 9;
    -- SYSTEM MESSAGES (DO NOT CHANGE THESE!!!! They are used for the back-end code to recognize for parsing info out, not for player UI
    GRM_L["has been kicked"] = "길드에서 추방했습니다."
    GRM_L["joined the guild."] = "님이 길드에 가입했습니다"
    GRM_L["has promoted"] = "로 올렸습니다."
    GRM_L["has demoted"] = "로 내렸습니다."
    GRM_L["Professions"] = "전문 기술"
    GRM_L["Guild: "] = "길드: "
    GRM_L["Guild created "] = "길드 창단일: "
    GRM_L["added to friends"] = "님이 친구 목록에 등록되었습니다."
    GRM_L["is already your friend"] = "님은 이미 친구 목록에 있습니다."
    GRM_L["Player not found."] = "플레이어를 찾을 수 없습니다."

    GRML.LoadLanguage[9]();

    -- Mandarin Chinese (CN) Defaults
elseif GRM_AddonGlobals.Region == "zhCN" then
    GRM_AddonGlobals.Localized = true
    GRM_AddonGlobals.LocalizedIndex = 10;
    -- SYSTEM MESSAGES (DO NOT CHANGE THESE!!!! They are used for the back-end code to recognize for parsing info out, not for player UI
    GRM_L["has been kicked"] = "开除出公会。"
    GRM_L["joined the guild."] = "加入了公会。"
    GRM_L["has promoted"] = "晋升为"
    GRM_L["has demoted"] = "降职为"
    GRM_L["Professions"] = "专业"
    GRM_L["Guild: "] = "公会："
    GRM_L["Guild created "] = "公会创立于"
    GRM_L["added to friends"] = "已被加入好友名单"
    GRM_L["is already your friend"] = "已经在你的好友名单中了"
    GRM_L["Player not found."] = "没有找到玩家。"

    GRML.LoadLanguage[10]();

-- Mandarin Chinese (TW) Defaults
elseif GRM_AddonGlobals.Region == "zhTW" then
    GRM_AddonGlobals.Localized = true
    GRM_AddonGlobals.LocalizedIndex = 11;
    -- SYSTEM MESSAGES (DO NOT CHANGE THESE!!!! They are used for the back-end code to recognize for parsing info out, not for player UI
    GRM_L["has been kicked"] = "踢出公會。"
    GRM_L["joined the guild."] = "加入了公會。"
    GRM_L["has promoted"] = "晉升為"
    GRM_L["has demoted"] = "降職為"
    GRM_L["Professions"] = "專業技能"
    GRM_L["Guild: "] = "公會："
    GRM_L["Guild created "] = "公會創立於"
    GRM_L["added to friends"] = "已被加入好友名單。"
    GRM_L["is already your friend"] = "已經在你的好友名單中了"
    GRM_L["Player not found."] = "找不到該玩家。"

    GRML.LoadLanguage[11]();

-- English Defaults
elseif GRM_AddonGlobals.Region == "enUS" or GRM_AddonGlobals.Region == "enGB" or not GRM_AddonGlobals.Localized then         -- In case the Region is not found at this point, just default it to English.
    GRM_AddonGlobals.Localized = true
    GRM_AddonGlobals.LocalizedIndex = 1;
    -- SYSTEM MESSAGES (DO NOT CHANGE THESE!!!! They are used for the back-end code to recognize for parsing info out, not for player UI
    GRM_L["has been kicked"] = true
    GRM_L["joined the guild."] = true
    GRM_L["has promoted"] = true
    GRM_L["has demoted"] = true
    GRM_L["Professions"] = true
    GRM_L["Guild: "] = true
    GRM_L["Guild created "] = true
    GRM_L["added to friends"] = true
    GRM_L["is already your friend"] = true
    GRM_L["Player not found."] = true

    GRML.LoadLanguage[1]();
end