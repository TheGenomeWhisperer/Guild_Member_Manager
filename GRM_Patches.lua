---UPDATES AND BUG PATCHES


GRM_Patch = {};
local chat = DEFAULT_CHAT_FRAME;

-- Method:          GRM_Patch.SettingsCheck ( float )
-- What it Does:    Holds the patch logic for when people upgrade the addon
-- Purpose:         To keep the database healthy and corrected from dev design errors and unanticipated consequences of code.
GRM_Patch.SettingsCheck = function ( numericV )
    -- Introduced in 1.133 - placed in the beginning to to critcal issue with database
    if numericV < 1.133 then
        GRM.CleanupGuildNames();
    end
    
    -- Introduced Patch R1.092
    -- Alt tracking of the player - so it can auto-add the player's own alts to the guild info on use.
    if #GRM_PlayerListOfAlts_Save == 0 then
        GRM_Patch.SetupAltTracking();
    end

    -- Introduced Patch R1.100
    -- Updating the version for ALL saved accounts.
    if numericV < 1.100 then
        GRM_Patch.UpdateRankControlSettingDefault();
    end

    -- Introduced Patch R1.111
    -- Custom sync'd guild notepad and officer notepad.
    if #GRM_GuildNotePad_Save == 0 then
        GRM_Patch.CustomNotepad();
    end

    -- Introduced Patch R1.111
    -- Added some more booleans to the options for future growth.
    if #GRM_AddonSettings_Save[GRM_G.FID][2][2] == 26 then
        GRM_Patch.ExpandOptions();
    end

    -- Intoduced Patch R1.122
    -- Adds an additional point of logic for "Unknown" on join date...
    if numericV < 1.122 then
        GRM_Patch.IntroduceUnknown();
    end

    -- Introduced Patch R1.125
    -- Bug fix... need to purge of repeats
    if numericV < 1.125 and GRM_AddonSettings_Save[GRM_G.FID][2][2][24] == 0 then
        GRM_Patch.RemoveRepeats();
        GRM_Patch.EstablishThrottleSlider();
    end

    -- Introdued Patch R1.126
    -- Cleans up broken code that might have been causing error.
    if numericV < 1.126 then
        GRM_Patch.CleanupSettings ( 30 );
    end

    -- Introduced Patch R.1.126
    -- Need some more options booleans
    if #GRM_AddonSettings_Save[GRM_G.FID][2][2] == 30 then
        GRM_Patch.ExpandOptionsScalable( 10 , 30 , true );  -- Adding 10 boolean spots
    end

    -- Introdued Patch R1.126
    -- Need some more options int placeholders for dropdown menus
    if #GRM_AddonSettings_Save[GRM_G.FID][2][2] == 40 then
        GRM_Patch.ExpandOptionsScalable( 5 , 40 , false );  -- Adding 5 boolean spots
    end

    -- Introduced Patch R1.126
    -- Minimap Created!!!
    if GRM_AddonSettings_Save[GRM_G.FID][2][2][25] == 0 or GRM_AddonSettings_Save[GRM_G.FID][2][2][26] == 0 then
        GRM_Patch.SetMinimapValues();
    end

    -- Introduced R1.129
    -- Some erroneous promo date formats occurred due to a faulty previous update. These cleans them up.
    if numericV < 1.129 then
        GRM_Patch.CleanupPromoDates();
    end

    -- Introduced R1.130
    -- Sync addon settings should not be enabled by default.
    -- Greenwall users sync was getting slower and slower and slower... this resolves it.
    if numericV < 1.130 then
        GRM_Patch.TurnOffDefaultSyncSettingsOption();
        GRM_Patch.ResetSyncThrottle();
    end

    -- R1.131
    -- Some messed up date formatting needs to be re-cleaned up due to failure to take into consideration month/date formating issues on guildInfo system message on creation date.
    if numericV < 1.131 then
        GRM_Patch.ResetCreationDates();
    end

    -- Some flaw in the left players I noticed... this cleans up old database issues.
    if numericV < 1.132 then
        GRM_Patch.CleanupLeftPlayersDatabaseOfRepeats();
    end

    -- Cleanup the guild backups feature. This will affect almost no one, but I had the methods in the code, this just protects some smarter coders who noticed it and utilized them.
    if numericV < 1.140 then
        chat:AddMessage ( "GRM: Warning!!! Due to a flaw in the database build of the backups that I had missed, the entire backup database had to be wiped and rebuilt. There was a critical flaw in it. I apologize, but this really is the best solution. A new auto-backup will be established the first time you logout, but a manual save is also encouraged." , 1 , 0 , 0 , 1 );
        GRM.ResetAllBackups();
    end

    -- Sets the settings menu configuration and updates the auto backup arrays to include room for the autobackups...
    if numericV < 1.137 then
        GRM_Patch.ConfigureAutoBackupSettings();
    end

    -- Cleans up the Promo dates.
    if numericV < 1.142 then
        GRM_Patch.CleanupPromoDates();
        GRM_Patch.ExpandOptionsType ( 3 , 3 , 45 );
        GRM_Patch.ModifyNewDefaultSetting ( 46 , { 1 , 0 , 0 } );
    end

    if numericV < 1.143 then
        GRM_Patch.ModifyNewDefaultSetting ( 36 , false );
        GRM_Patch.ModifyNewDefaultSetting ( 37 , false );
        GRM_Patch.ModifyNewDefaultSetting ( 43 , GRM_G.LocalizedIndex );
    end

    if numericV < 1.144 then
        GRM_Patch.FixBrokenLanguageIndex();
    end

    if numericV < 1.1461 then
        GRM_Patch.SetProperFontIndex();
        GRM_Patch.ModifyNewDefaultSetting( 45 , 0 );
    end

    if numericV < 1.1471 then
        GRM_Patch.SetMiscConfiguration();
    end

    if numericV < 1.1480 then
        GRM_Patch.ExpandOptionsType ( 1 , 2 , 48 );
        GRM_Patch.ModifyNewDefaultSetting ( 49 , 2 );
        GRM_Patch.ModifyPlayerMetadata ( 23 , { true , 0 , "" , GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][49] , false , "" } , false , -1 );  -- Adding custom note logic
        GRM_Patch.AddNewDefaultSetting ( 3 , true , true );         -- Print log report for custom note boolean
        GRM_Patch.AddNewDefaultSetting ( 13 , true , true );        -- Chat log report for custom note boolean
        GRM_Patch.SetProperRankRestrictions();
    end
    
    if numericV < 1.1482 then
        GRM_Patch.FixAltData();
        GRM_Patch.ExpandOptionsType ( 1 , 1 , 49 );
    end

    if numericV < 1.1490 then
        GRM_Patch.FixAltData();
    end

    if numericV < 1.1492 then
        GRM_Patch.RemoveAllAutoBackups();
    end

    if numericV < 1.1500 then
        GRM_Patch.CleanupAnniversaryEvents();
        GRM_Patch.RemoveTitlesEventDataAndUpdateBirthday();
        GRM_Patch.UpdateCalendarEventsDatabase();
    end

    if numericV < 1.1501 then
        GRM_Patch.RemoveTitlesEventDataAndUpdateBirthday();
    end

    if numericV < 1.1510 then
        GRM_Patch.ExpandOptionsType ( 1 , 1 , 50 );
        GRM_Patch.ExpandOptionsType ( 2 , 1 , 51 );
        GRM_Patch.MatchLanguageTo24HrFormat();
    end

    if numericV < 1.1530 then
        GRM_Patch.FixGuildNotePad();
        GRM_Patch.FixBanListNameGrammar();
    end

    if numericV < 1.20 then
        GRM_Patch.FixDoubleCopiesInLeftPLayers();
        GRM_Patch.ExpandOptionsType ( 2 , 1 , 52 );
        GRM_Patch.ModifyNewDefaultSetting ( 53 , false );
        GRM_Patch.ModifyNewDefaultSetting ( 24 , 1 );
        GRM_Patch.AddPlayerMetaDataSlot ( 41 , "" );            -- Adding the GUID position...
        GRM_Patch.FixPlayerListOfAltsDatabase();
    end

    if numericV < 1.21 then
        GRM_Patch.ExpandOptionsType ( 2 , 1 , 53 );
        GRM_Patch.ModifyNewDefaultSetting ( 54 , false );
    end
    
    if numericV < 1.22 then
        GRM_Patch.ExpandOptionsType ( 2 , 1 , 54 );
        GRM.Report ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "New Feature!" ) .. "\n" .. GRM.L ( "Type !note in guild chat, and anything you add after it will become your Public Note (if an officer with GRM installed is online)" ) );
    end
    
    if numericV < 1.25 then
        GRM_Patch.ExpandOptionsType ( 2 , 2 , 55 );         -- adding 56 and 57
        GRM_Patch.ModifyNewDefaultSetting ( 56 , false );  -- 57 can be true
    end
end

        -------------------------------
        --- START PATCH LOGIC ---------
        -------------------------------


-- Introduced Patch R1.092
-- Alt tracking of the player - so it can auto-add the player's own alts to the guild info on use.
GRM_Patch.SetupAltTracking = function()
    -- Need to check if already added to the guild...
    local guildNotFound = true;
    if GRM_G.guildName ~= nil then
        for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ] do
            if GRM_GuildMemberHistory_Save[GRM_G.FID][i][1][1] == GRM_G.guildName then
                guildNotFound = false;
                break;
            end
        end
    end

    -- Build the table for the first time! It will be unique to the faction and the guild.
    table.insert ( GRM_PlayerListOfAlts_Save , { "Horde" } );
    table.insert ( GRM_PlayerListOfAlts_Save , { "Alliance" } );

    if IsInGuild() and not guildNotFound then
        -- guild is found, let's add the guild!
        table.insert ( GRM_PlayerListOfAlts_Save[ GRM_G.FID ] , { { GRM_G.guildName , GRM_G.guildCreationDate } } );  -- alts list, let's create an index for the guild!

        -- Insert player name too...
    end
end


-- Introduced Patch R1.100
-- Updating the version for ALL saved accounts.
GRM_Patch.UpdateRankControlSettingDefault = function()
    local needsUpdate = true;
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            if GRM_AddonSettings_Save[i][j][2][22] > 0 then
                -- This will signify that the addon has already been updated to current state and will not need update.
                needsUpdate = false;
                break;
            else
                GRM_AddonSettings_Save[i][j][2][22] = 2;      -- Updating rank to general officer rank to be edited.
            end
        end
        if not needsUpdate then     -- No need to cycle through everytime. Resource saving here!
            break;
        end
    end
end


-- Introduced Patch R1.111
-- Custom sync'd guild notepad and officer notepad needs initialization if never
GRM_Patch.CustomNotepad = function()

    -- Build the table for the first time! It will be unique to the faction and the guild.
    table.insert ( GRM_GuildNotePad_Save , { "Horde" } );
    table.insert ( GRM_GuildNotePad_Save , { "Alliance" } );

    if IsInGuild() then
        -- guild is found, let's add the guild!
        table.insert ( GRM_GuildNotePad_Save[ GRM_G.FID ] , { GRM_G.guildName } );  -- alts list, let's create an index for the guild!
    end
end


-- Introduced Patch R1.111
-- Added some more booleans to the options for future growth.
GRM_Patch.ExpandOptions = function()
    -- Updating settings for all
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            if #GRM_AddonSettings_Save[i][j][2] == 26 then
                table.insert ( GRM_AddonSettings_Save[i][j][2] , true );        -- 27th option
                table.insert ( GRM_AddonSettings_Save[i][j][2] , true );        -- 28th option
                table.insert ( GRM_AddonSettings_Save[i][j][2] , true );        -- 29th option
                table.insert ( GRM_AddonSettings_Save[i][j][2] , false );       -- 30th option
            end
        end
    end
end


-- Intoduced Patch R1.122
-- Adds an additional point of logic for "Unknown" on join date...
GRM_Patch.IntroduceUnknown = function()
    for i = 1 , #GRM_GuildMemberHistory_Save do                         -- Horde and Alliance
        for j = 2 , #GRM_GuildMemberHistory_Save[i] do                  -- The guilds in each faction
            for r = 2 , #GRM_GuildMemberHistory_Save[i][j] do           -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                if #GRM_GuildMemberHistory_Save[i][j][r] == 39 then
                    table.insert ( GRM_GuildMemberHistory_Save[i][j][r] , false );      -- isUnknown join
                    table.insert ( GRM_GuildMemberHistory_Save[i][j][r] , false );      -- isUnknown promo
                end
            end
        end
    end

    for i = 1 , #GRM_PlayersThatLeftHistory_Save do                         -- Horde and Alliance
        for j = 2 , #GRM_PlayersThatLeftHistory_Save[i] do                  -- The guilds in each faction
            for r = 2 , #GRM_PlayersThatLeftHistory_Save[i][j] do           -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                if #GRM_PlayersThatLeftHistory_Save[i][j][r] == 39 then
                    table.insert ( GRM_PlayersThatLeftHistory_Save[i][j][r] , false );      -- isUnknown join
                    table.insert ( GRM_PlayersThatLeftHistory_Save[i][j][r] , false );      -- isUnknown promo
                end
            end
        end
    end
end


-- Introduced Patch R1.125
-- Bug fix... need to purge of repeats
GRM_Patch.RemoveRepeats = function()
    local t;
    for i = 1 , #GRM_GuildMemberHistory_Save do                         -- Horde and Alliance
        for j = 2 , #GRM_GuildMemberHistory_Save[i] do                  -- The guilds in each faction
            local r = 2;
            while r <= #GRM_GuildMemberHistory_Save[i][j] do            -- Using while loop to manually increment, rather than auto in a for loop, as table.remove will remove an index.
                t = GRM_GuildMemberHistory_Save[i][j];
                local isRemoved = false;
                for s = 2 , #t do
                    if s ~= r and GRM_GuildMemberHistory_Save[i][j][r][1] == t[s][1] then
                        isRemoved = true;
                        table.remove ( GRM_GuildMemberHistory_Save[i][j] , r );
                        break;
                    end
                end
                if not isRemoved then
                    r = r + 1;
                end
            end
        end
    end
end


-- Introduced Patch R1.125
-- Establishing the slider default value to be 40 for throttle controls ( 100% )
GRM_Patch.EstablishThrottleSlider = function()
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            GRM_AddonSettings_Save[i][j][2][24] = 40;
        end
    end
end

-- Introduced Patch R1.126
-- Ability to add number of options on a specific scale
GRM_Patch.ExpandOptionsScalable = function( numNewIndexesToAdd , baseNumber , addingBoolean )
    -- Updating settings for all
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            if #GRM_AddonSettings_Save[i][j][2] == baseNumber then
                for s = 1 , numNewIndexesToAdd do
                    if addingBoolean then
                        table.insert ( GRM_AddonSettings_Save[i][j][2] , true );        -- X option position
                    else
                        table.insert ( GRM_AddonSettings_Save[i][j][2] , 1 );           -- Adding int instead, placeholder value of 1
                    end
                end
                -- We know it is starting at 30 now.
                if baseNumber == 30 then
                    GRM_AddonSettings_Save[i][j][2][31] = false;                        -- This one value should be defaulted to false.
                end
            end
        end
    end
end

-- Introduced Patch R1.126
-- Minimap Created!!!
GRM_Patch.SetMinimapValues = function()
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            GRM_AddonSettings_Save[i][j][2][25] = 345;
            GRM_AddonSettings_Save[i][j][2][26] = 78;
        end
    end
end

-- TEST HELPERS
-- Introduced Patch R1.126
GRM_Patch.CleanupSettings = function ( anyValueGreaterThanThisIndex )
    local settings = GRM_AddonSettings_Save[GRM_G.FID];
    for i = 2 , #settings do
        if #settings[i][2] > anyValueGreaterThanThisIndex then
            while #settings[i][2] > anyValueGreaterThanThisIndex do
                table.remove ( settings[i][2] , #settings[i][2] );
            end
        end
    end
    GRM_AddonSettings_Save[GRM_G.FID] = settings;
end

-- Some Promo dates were erroneously added with a ": 14 Jan '18" format. This fixes that.
-- Introduced Patch R1.129
GRM_Patch.CleanupPromoDates = function()
    local t = GRM_GuildMemberHistory_Save;
    for i = 1 , #t do                         -- Horde and Alliance
        for j = 2 , #t[i] do                  -- The guilds in each faction
            for r = 2 , #t[i][j] do           -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                if t[i][j][r][12] ~= nil and string.find ( t[i][j][r][12] , ":" ) ~= nil then 
                    t[i][j][r][12] = string.sub ( t[i][j][r][12] , 3 );
                    t[i][j][r][36][1] = t[i][j][r][12];
                end
            end
        end
    end

    -- Save the updates...
    GRM_GuildMemberHistory_Save = t;

    local s = GRM_PlayersThatLeftHistory_Save;
    for i = 1 , #s do
        for j = 2 , #s[i] do 
            for r = 2 , #s[i][j] do 
                if s[i][j][r][12] ~= nil and string.find ( s[i][j][r][12] , ":" ) ~= nil then 
                    s[i][j][r][12] = string.sub ( s[i][j][r][12] , 3 );
                    s[i][j][r][36][1] = s[i][j][r][12];
                end
            end
        end
    end

    -- Need to set default setting to sync on all toons to only those with current version. This is to prevent reversion of bug
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            GRM_AddonSettings_Save[i][j][2][19] = true;
        end
    end

end

-- R1.130
-- Sync settings across players in the same guild should not have been set to true. This corrects that.
GRM_Patch.TurnOffDefaultSyncSettingsOption = function()
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            GRM_AddonSettings_Save[i][j][2][31] = false;
        end
    end
end

-- R1.130
-- Logic change dictates a reset... People will need to reconfigure.
GRM_Patch.ResetSyncThrottle = function()
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            GRM_AddonSettings_Save[i][j][2][24] = 40;
        end
    end
end

-- R1.130
-- Need to update for backup saves as well...
-- Added as it appears to be an issue for guilds with the same name, same faction, but different servers...
GRM_Patch.AddGuildCreationDate = function( index )
    if GRM_G.guildCreationDate ~= "" then
        if GRM_GuildMemberHistory_Save[GRM_G.FID][index][1] == GRM.SlimName ( GRM_G.guildName ) then
            GRM_GuildMemberHistory_Save[GRM_G.FID][index][1] = { GRM_G.guildName , GRM_G.guildCreationDate };
            
            -- now need to do the same thing for all the rest...
            for j = 2 , #GRM_CalendarAddQue_Save[GRM_G.FID] do
                if GRM_CalendarAddQue_Save[GRM_G.FID][j][1] == GRM.SlimName ( GRM_G.guildName ) then
                    GRM_CalendarAddQue_Save[GRM_G.FID][j][1] = { GRM_G.guildName , GRM_G.guildCreationDate };
                    break;
                end
            end

            for j = 2 , #GRM_PlayersThatLeftHistory_Save[GRM_G.FID] do
                if GRM_PlayersThatLeftHistory_Save[GRM_G.FID][j][1] == GRM.SlimName ( GRM_G.guildName ) then
                    GRM_PlayersThatLeftHistory_Save[GRM_G.FID][j][1] = { GRM_G.guildName , GRM_G.guildCreationDate };
                    break;
                end
            end

            for j = 2 , #GRM_LogReport_Save[GRM_G.FID] do
                if GRM_LogReport_Save[GRM_G.FID][j][1] == GRM.SlimName ( GRM_G.guildName ) then
                    GRM_LogReport_Save[GRM_G.FID][j][1] = { GRM_G.guildName , GRM_G.guildCreationDate };
                    break;
                end
            end

            for j = 2 , #GRM_GuildNotePad_Save[GRM_G.FID] do
                if GRM_GuildNotePad_Save[GRM_G.FID][j][1] == GRM.SlimName ( GRM_G.guildName ) then
                    GRM_GuildNotePad_Save[GRM_G.FID][j][1] = { GRM_G.guildName , GRM_G.guildCreationDate };
                    break;
                end
            end

            for j = 2 , #GRM_PlayerListOfAlts_Save[GRM_G.FID] do
                if GRM_PlayerListOfAlts_Save[GRM_G.FID][j][1] == GRM.SlimName ( GRM_G.guildName ) then
                    GRM_PlayerListOfAlts_Save[GRM_G.FID][j][1] = { GRM_G.guildName , GRM_G.guildCreationDate };
                    break;
                end
            end
        end
        -- Now need to update the backup info...
        for i = 2 , #GRM_GuildDataBackup_Save[GRM_G.FID] do
            if type ( GRM_GuildDataBackup_Save[GRM_G.FID][i][1] ) == "string" and GRM_GuildDataBackup_Save[GRM_G.FID][i][1] == GRM.SlimName ( GRM_G.guildName ) then
                GRM_GuildDataBackup_Save[GRM_G.FID][i][1] = { GRM_G.guildName , GRM_G.guildCreationDate };
                break;
            end
        end
    end
end

-- R1.130
-- Due to date formatting issue not alligning with US, they need to be wiped and reset, and the English date is made more correct.
GRM_Patch.ResetCreationDates = function()
    for i = 1 , #GRM_GuildMemberHistory_Save do
        for j = 2 , #GRM_GuildMemberHistory_Save[i] do
            -- Only need to fix if it was updated with 1.130
            if GRM_GuildMemberHistory_Save[i][j][1][1] ~= nil then
                GRM_GuildMemberHistory_Save[i][j][1] = GRM_GuildMemberHistory_Save[i][j][1][1];
            end
        end
    end

    for i = 1 , #GRM_CalendarAddQue_Save do
        for j = 2 , #GRM_CalendarAddQue_Save[i] do
            -- Only need to fix if it was updated with 1.130
            if GRM_CalendarAddQue_Save[i][j][1][1] ~= nil then
                GRM_CalendarAddQue_Save[i][j][1] = GRM_CalendarAddQue_Save[i][j][1][1];
            end
        end
    end

    for i = 1 , #GRM_PlayersThatLeftHistory_Save do
        for j = 2 , #GRM_PlayersThatLeftHistory_Save[i] do
            -- Only need to fix if it was updated with 1.130
            if GRM_PlayersThatLeftHistory_Save[i][j][1][1] ~= nil then
                GRM_PlayersThatLeftHistory_Save[i][j][1] = GRM_PlayersThatLeftHistory_Save[i][j][1][1];
            end
        end
    end
    for i = 1 , #GRM_LogReport_Save do
        for j = 2 , #GRM_LogReport_Save[i] do
            -- Only need to fix if it was updated with 1.130
            if GRM_LogReport_Save[i][j][1][1] ~= nil then
                GRM_LogReport_Save[i][j][1] = GRM_LogReport_Save[i][j][1][1];
            end
        end
    end

    for i = 1 , #GRM_GuildNotePad_Save do
        for j = 2 , #GRM_GuildNotePad_Save[i] do
            -- Only need to fix if it was updated with 1.130
            if GRM_GuildNotePad_Save[i][j][1][1] ~= nil then
                GRM_GuildNotePad_Save[i][j][1] = GRM_GuildNotePad_Save[i][j][1][1];
            end
        end
    end

    for i = 1 , #GRM_PlayerListOfAlts_Save do
        for j = 2 , #GRM_PlayerListOfAlts_Save[i] do
            -- Only need to fix if it was updated with 1.130
            if GRM_PlayerListOfAlts_Save[i][j][1][1] ~= nil then
                GRM_PlayerListOfAlts_Save[i][j][1] = GRM_PlayerListOfAlts_Save[i][j][1][1];
            end
        end
    end
end


-- R1.132
-- For cleaning up the Left PLayers database
GRM_Patch.CleanupLeftPlayersDatabaseOfRepeats = function()
    local repeatsRemoved = 1;
    local count = 2;
    for i = 1 , #GRM_PlayersThatLeftHistory_Save do                             -- For each server
        for j = 2 , #GRM_PlayersThatLeftHistory_Save[i] do                      -- for each guild
            for r = 2 , #GRM_PlayersThatLeftHistory_Save[i][j] do            -- For each player
                count = 2;
                while count <= #GRM_PlayersThatLeftHistory_Save[i][j] and r <= #GRM_PlayersThatLeftHistory_Save[i][j] do           -- Scan through the guild for match
                    if r ~= count and GRM_PlayersThatLeftHistory_Save[i][j][count][1] == GRM_PlayersThatLeftHistory_Save[i][j][r][1] then
                        -- match found!
                        table.remove ( GRM_PlayersThatLeftHistory_Save[i][j] , count );
                        repeatsRemoved = repeatsRemoved + 1;
                        -- Don't incrememnt up since you are removing a slot and everything shifts down.
                    else
                        count = count + 1;
                    end
                end
            end
        end
    end
    -- print("GRM Report: " .. repeatsRemoved .. " errors found in database that have been cleaned up!" );
end

-- R1.133
-- For cleaning up a broken database...
GRM.CleanupGuildNames = function()
    for i = 1 , #GRM_GuildMemberHistory_Save do
        for s = 2 , #GRM_GuildMemberHistory_Save[i] do
            if GRM_GuildMemberHistory_Save[i][s][1] == nil then
                -- Let's scan through the guild to see if it has my name!
                local isFound = false;
                for j = 2 , #GRM_GuildMemberHistory_Save[i][s] do
                    if GRM_GuildMemberHistory_Save[i][s][j][1] == GRM_G.addonPlayerName then
                        GRM_GuildMemberHistory_Save[i][s][1] = GRM_G.guildName;
                        isFound = true;
                        break;
                    end
                end
                if not isFound then
                    GRM_GuildMemberHistory_Save[i][s][1] = "";
                end
            end
        end
    end

    for i = 1 , #GRM_PlayersThatLeftHistory_Save do
        for s = 2 , #GRM_PlayersThatLeftHistory_Save[i] do
            if GRM_PlayersThatLeftHistory_Save[i][s][1] == nil then
                -- Let's scan through the guild to see if it has my name!
                local isFound = false;
                for j = 2 , #GRM_PlayersThatLeftHistory_Save[i][s] do
                    if GRM_PlayersThatLeftHistory_Save[i][s][j][1] == GRM_G.addonPlayerName then
                        GRM_PlayersThatLeftHistory_Save[i][s][1] = GRM_G.guildName;
                        isFound = true;
                        break;
                    end
                end
                if not isFound then
                    GRM_PlayersThatLeftHistory_Save[i][s][1] = "";
                end
            end
        end
    end
end

-- R 1.135
-- Cleaning up the broken log
GRM_Patch.FixLogGuildInfo = function()
    for i = 1 , #GRM_LogReport_Save do                  -- Scan the factions
        for j = 2 , #GRM_LogReport_Save[i] do           -- Scan the guilds 
            if type ( GRM_LogReport_Save[i][j][1] ) == "string" then
                -- Needs to be updated!!!
                GRM_LogReport_Save[i][j][1] = { GRM_LogReport_Save[i][j][1] , GRM_LogReport_Save[i][j][2] };
                table.remove ( GRM_LogReport_Save[i][j] , 2 );
            end
        end
    end
end

-- R 1.137
-- Just a tool to use, will not be auto-called...
GRM_Patch.RepairAndMergeGuildLogs = function( newName , oldName , factionID )
    for i = 2 , #GRM_LogReport_Save[factionID] do
        -- First, let's identify the index of the new guild, so we can save over it.
        if type ( GRM_LogReport_Save[factionID][i][1] ) == "table" and GRM_LogReport_Save[factionID][i][1][1] == newName then
            for j = 2 , #GRM_LogReport_Save[factionID] do
                if type ( GRM_LogReport_Save[factionID][j][1] ) == "string" and GRM_LogReport_Save[factionID][j][1] == oldName then
                    GRM.Report ( "Old Guild Name Data Found... Attempting Recovery." );
                    GRM_LogReport_Save[factionID][j][1] = GRM_LogReport_Save[factionID][i][1];      -- Saving new guild info properly...
                    -- Add the log entries...
                    GRM.Report ( "Merging Both Logs..." );
                    for s = 2 , #GRM_LogReport_Save[factionID][i] do
                        table.insert ( GRM_LogReport_Save[factionID][j] , GRM_LogReport_Save[factionID][i][s] );
                    end
                    GRM_LogReport_Save[factionID][i] = GRM_LogReport_Save[factionID][j];            -- Adding the log...
                    -- Removing the old log...
                    GRM.Report ( "Guild Log Recovery Complete!" );
                    table.remove ( GRM_LogReport_Save[factionID] , j );
                    break;
                end
            end
            break;
        end
    end
end

-- Added R 1.137
-- Method:          GRM_Patch.AddAutoBackupIndex()
-- What it Does:    Adds 2 indexes that will be permanently in place for autobackup indexes...
-- Purpose:         So that the autobackup has a place to be set...
GRM_Patch.AddAutoBackupIndex = function()
    for i = 1 , #GRM_GuildDataBackup_Save do    -- For each faction
        for j = 2 , #GRM_GuildDataBackup_Save[i] do
            -- Insert 2 points...
            table.insert ( GRM_GuildDataBackup_Save[i][j] , 2 , {} );   
            table.insert ( GRM_GuildDataBackup_Save[i][j] , 3 , {} );
        end
    end
end

-- Added R1.137
-- Method:          GRM_Patch.ConfigureAutoBackupSettings()
-- What it Does:    Establishes Auto Backup settings
-- Purpose:         For a new feature, all player settings should be set default to 7 days, when the original setting placeholder was 1
GRM_Patch.ConfigureAutoBackupSettings = function()
    -- Updating settings for all
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            GRM_AddonSettings_Save[i][j][2][41] = 7;
        end
    end
end

-- Intoduced Patch R1.142
-- Method:          GRM_Patch.CleanupPromoDates()
-- What it does:    Parses through all of the guild promo and removes the "12:01am" after it...
-- Purpose:         Some patches previously an erroenous stamping was added, this fixes it.
GRM_Patch.CleanupPromoDates = function()
    for i = 1 , #GRM_GuildMemberHistory_Save do                         -- Horde and Alliance
        for j = 2 , #GRM_GuildMemberHistory_Save[i] do                  -- The guilds in each faction
            -- First the current players...
            for r = 2 , #GRM_GuildMemberHistory_Save[i][j] do           -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                if GRM_GuildMemberHistory_Save[i][j][r][12] ~= nil then
                    local timestamp = GRM_GuildMemberHistory_Save[i][j][r][12];
                    GRM_GuildMemberHistory_Save[i][j][r][12] = string.sub ( timestamp , 1 , string.find ( timestamp , "'" ) + 2 );
                end
            end

            -- Now, the left players (i,j indexes will be the same, no need to reloop to find)
            for r = 2 , #GRM_PlayersThatLeftHistory_Save[i][j] do           -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                if GRM_PlayersThatLeftHistory_Save[i][j][r][12] ~= nil then
                    local timestamp = GRM_PlayersThatLeftHistory_Save[i][j][r][12];
                    GRM_PlayersThatLeftHistory_Save[i][j][r][12] = string.sub ( timestamp , 1 , string.find ( timestamp , "'" ) + 2 );
                end
            end
        end
    end
end

-- Introduced patch R1.142
-- Method:          GRM_Patch.ExpandOptionsType(int,int,int)
-- What it Does:    Expands the number of options settings, and initializes the type
-- Purpose:         Reusuable for future flexibility on updates.
-- 1 = number, 2=boolean, 3 = array , 4 = string
GRM_Patch.ExpandOptionsType = function( typeToAdd , numberSlots , referenceCheck )
    local expansionType;
    if typeToAdd == 1 then          -- Int
        expansionType = 1;
    elseif typeToAdd == 2 then      -- Boolean
        expansionType = true;
    elseif typeToAdd == 3 then      -- Array/Table
        expansionType = {};
    elseif typeToAdd == 4 then      -- String
        expansionType = "";
    end
    -- Updating settings for all
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            if #GRM_AddonSettings_Save[i][j][2] == referenceCheck then
                for k = 1 , numberSlots do
                    table.insert ( GRM_AddonSettings_Save[i][j][2] , expansionType );
                end
            end
        end
    end
end

-- Introduced patch R1.142
-- Method:          GRM_Patch.ModifyNewDefaultSetting ( int , object )
-- What it Does:    Modifies the given setting based on the index point in the settings with the new given setting
-- Purpose:         To create a universally reusable patcher.
GRM_Patch.ModifyNewDefaultSetting = function ( index , newSetting )
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            GRM_AddonSettings_Save[i][j][2][index] = newSetting;
        end
    end
end

-- Introduced patch R1.144
-- Method:          GRM_Patch.FixBrokenLanguageIndex()
-- What it does:    Checks if the index value is set to zero, which it should not, but if it is, defaults it to 1 for English
-- Purpose:         Due to an unforeseen circumstance, the placeholder value of zero, which represents no language, could be pulled before setting was established, thus breaking load.
GRM_Patch.FixBrokenLanguageIndex = function()
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            if GRM_AddonSettings_Save[i][j][2][43] == 0 then
                if GRM_G.Region == "" or GRM_G.Region == "enUS" or GRM_G.Region == "enGB" then
                    GRM_AddonSettings_Save[i][j][2][43] = 1;
                elseif GRM_G.Region == "deDE" then
                    GRM_AddonSettings_Save[i][j][2][43] = 2;
                elseif GRM_G.Region == "frFR" then
                    GRM_AddonSettings_Save[i][j][2][43] = 3;
                elseif GRM_G.Region == "itIT" then
                    GRM_AddonSettings_Save[i][j][2][43] = 4;
                elseif GRM_G.Region == "ruRU" then
                    GRM_AddonSettings_Save[i][j][2][43] = 5;
                elseif GRM_G.Region == "esMX" then
                    GRM_AddonSettings_Save[i][j][2][43] = 6;
                elseif GRM_G.Region == "esES" then
                    GRM_AddonSettings_Save[i][j][2][43] = 7;
                elseif GRM_G.Region == "ptBR" then
                    GRM_AddonSettings_Save[i][j][2][43] = 8;
                elseif GRM_G.Region == "koKR" then
                    GRM_AddonSettings_Save[i][j][2][43] = 9;
                elseif GRM_G.Region == "zhCN" then
                    GRM_AddonSettings_Save[i][j][2][43] = 10;
                elseif GRM_G.Region == "zhTW" then
                    GRM_AddonSettings_Save[i][j][2][43] = 11;
                else
                    GRM_AddonSettings_Save[i][j][2][43] = 1;        -- To default back to...
                end
            end
        end
    end
end


-- Method:          GRM_Patch.DoubleGuildFix ( string , string , string )
-- What it Does:    If there are 2 copies of the guild, but one of them is broken because the creation date was incorrect, this fixes it
-- Purpose:         To save people's data!
GRM_Patch.DoubleGuildFix = function ( guildName , creationDate , faction )

    if guildName == GRM_G.guildName then
        GRM.Report ( "\n" .. GRM.L ( "Player Cannot Purge the Guild Data they are Currently In!!!" ) .. "\n" .. GRM.L( "To reset your current guild data type '/grm clearguild'" ) );
    else
        local factionIndex = 1;
        if string.lower ( faction ) == "alliance" then
            factionIndex = 2;
        end
        local badCreationDate = "";
        local guildIndex = -1;
        local purgeGuildIndex = -1;
        local logIndex = -1;
        local purgeLogIndex = -1;

        for i = 2 , #GRM_GuildMemberHistory_Save[factionIndex] do
            if string.lower ( GRM_GuildMemberHistory_Save[factionIndex][i][1][1] ) == string.lower ( guildName ) then   -- String.lower for typos on case sensitivity can be avoided.
                -- Guild Found!!!
                if GRM_GuildMemberHistory_Save[factionIndex][i][1][2] ~= creationDate then      -- Bad Creation date found!
                    badCreationDate = GRM_GuildMemberHistory_Save[factionIndex][i][1][2];
                    guildIndex = i
                elseif GRM_GuildMemberHistory_Save[factionIndex][i][1][2] == creationDate then     -- Ok, correct creation date, but it has overriden the old log data, need to restore...
                    purgeGuildIndex = i;
                end
                if guildIndex ~= -1 and purgeGuildIndex ~= -1 then
                    break;
                end
            end
        end

        -- Determine log indexes since it is possible they are not static.
        for i = 2 , #GRM_LogReport_Save[factionIndex] do
            if string.lower ( GRM_LogReport_Save[factionIndex][i][1][1] ) == string.lower ( guildName ) then
                if GRM_LogReport_Save[factionIndex][i][1][2] == badCreationDate then
                    logIndex = i;
                elseif GRM_LogReport_Save[factionIndex][i][1][2] == creationDate then
                    purgeLogIndex = i;
                end
                if logIndex ~= -1 and purgeLogIndex ~= -1 then
                    break;
                end
            end
        end

        if guildIndex ~= -1 and purgeGuildIndex ~= -1 then

            -- Before we purge, let's merge the logs...
            for i = 2 , #GRM_LogReport_Save[factionIndex][purgeLogIndex] do
                table.insert ( GRM_LogReport_Save[factionIndex][guildIndex] , GRM_LogReport_Save[factionIndex][purgeLogIndex][i] );
            end

            if guildIndex > purgeGuildIndex then
                guildIndex = guildIndex - 1;        -- Need to increment down because we are about to remove an index with the purge
            end
            -- Need to reset these values...
            if GRM_G.FID == factionIndex and purgeGuildIndex < GRM_G.saveGID then
                GRM_G.saveGID = GRM_G.saveGID - 1;
            end
            if GRM_G.FID == factionIndex and purgeLogIndex < GRM_G.logGID then
                GRM_G.logGID = GRM_G.logGID - 1;
            end

            GRM.PurgeGuildFromDatabase ( guildName , creationDate , factionIndex );
                
            -- Now, let's purge the old guild
            
            GRM_GuildMemberHistory_Save[factionIndex][guildIndex][1][2] = creationDate;
            GRM_PlayersThatLeftHistory_Save[factionIndex][guildIndex][1][2] = creationDate;
            GRM_CalendarAddQue_Save[factionIndex][guildIndex][1][2] = creationDate;
            GRM_GuildNotePad_Save[factionIndex][guildIndex][1][2] = creationDate;
            GRM_GuildDataBackup_Save[factionIndex][guildIndex][1][2] = creationDate;
            GRM_LogReport_Save[factionIndex][logIndex][1][2] = creationDate;

            -- Now the backups
            for i = 2 , #GRM_GuildDataBackup_Save[factionIndex][guildIndex] do
                if #GRM_GuildDataBackup_Save[factionIndex][guildIndex][i] > 0 then
                    GRM_GuildDataBackup_Save[factionIndex][guildIndex][i][3][1][2] = creationDate;
                    GRM_GuildDataBackup_Save[factionIndex][guildIndex][i][4][1][2] = creationDate;
                    GRM_GuildDataBackup_Save[factionIndex][guildIndex][i][5][1][2] = creationDate;
                    GRM_GuildDataBackup_Save[factionIndex][guildIndex][i][6][1][2] = creationDate;
                    GRM_GuildDataBackup_Save[factionIndex][guildIndex][i][7][1][2] = creationDate;
                end
            end 

            GRM.Report ( guildName .. "'s Database has been Fixed!" );
        else
            GRM.Report ( guildName .. "'s Database was not fixed... no duplicate copies of the guild were found!" );
        end
    end
end

-- Method:          GRM_Patch.SetProperFontIndex();
-- What it Does:    Sets the defautl font index to their selected language.
-- Purpose:         On introduction of the fonts, this sets the font index in the saves properly...
GRM_Patch.SetProperFontIndex = function()
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            GRM_AddonSettings_Save[i][j][2][44] = GRML.GetFontChoiceIndex( GRM_AddonSettings_Save[i][j][2][43] );
        end
    end
end

-- R1.147
-- Method:          GRM_Patch.SetMiscConfiguration()
-- What it Does:    Configures the new save file by making a uniqe index for each toon already saved
-- Purpose:         To be able to save a player the headache of incomplete tasks that need a marker on where to carryon from where it was left off.
GRM_Patch.SetMiscConfiguration = function()
    -- Reset it just in case...
    GRM_Misc = {};
    -- Now to add for each player...
    for i = 1 , #GRM_PlayerListOfAlts_Save do
        for j = 2 , #GRM_PlayerListOfAlts_Save[i] do
            for r = 2 , #GRM_PlayerListOfAlts_Save[i][j] do
                GRM.ConfigureMiscForPlayer ( GRM_PlayerListOfAlts_Save[i][j][r][1] );
            end
        end
    end
end

-- Added patch 1.148
-- Method:          GRM_Patch.ModifyPlayerMetadata ( int , object , boolean , int )
-- What it Does:    Allows the player to modify the metadata for ALL profiles in every guild in the database with one method
-- Purpose:         One function to rule them all! Keep code bloat down.
GRM_Patch.ModifyPlayerMetadata = function ( index , newValue , toArraySetting , arrayIndex )
    for i = 1 , #GRM_GuildMemberHistory_Save do                         -- Horde and Alliance
        for j = 2 , #GRM_GuildMemberHistory_Save[i] do                  -- The guilds in each faction
            for r = 2 , #GRM_GuildMemberHistory_Save[i][j] do           -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                if not toArraySetting then
                    GRM_GuildMemberHistory_Save[i][j][r][index] = newValue;
                else
                    GRM_GuildMemberHistory_Save[i][j][r][index][arrayIndex] = newValue;
                end
            end
        end
    end

    -- need to update the left player's database too...
    for i = 1 , #GRM_PlayersThatLeftHistory_Save do                         -- Horde and Alliance
        for j = 2 , #GRM_PlayersThatLeftHistory_Save[i] do                  -- The guilds in each faction
            for r = 2 , #GRM_PlayersThatLeftHistory_Save[i][j] do           -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                if not toArraySetting then
                    GRM_PlayersThatLeftHistory_Save[i][j][r][index] = newValue;
                else
                    GRM_PlayersThatLeftHistory_Save[i][j][r][index][arrayIndex] = newValue;
                end
            end
        end
    end
end

-- NEED METHOD TO MODIFY THE BACKUP DATA TOO!!!!!!
-- Added patch 1.20
-- Method:          GRM_Patch.AddPlayerMetaDataSlot ( int , object )
-- What it Does:    Allows the player to insert into the metadata for ALL profiles in every guild in the database with one method
-- Purpose:         One function to rule them all! Keep code bloat down.
GRM_Patch.AddPlayerMetaDataSlot = function ( previousMaxIndex , newValue )
    for i = 1 , #GRM_GuildMemberHistory_Save do                         -- Horde and Alliance
        for j = 2 , #GRM_GuildMemberHistory_Save[i] do                  -- The guilds in each faction
            for r = 2 , #GRM_GuildMemberHistory_Save[i][j] do           -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                if #GRM_GuildMemberHistory_Save[i][j][r] == previousMaxIndex then
                    table.insert ( GRM_GuildMemberHistory_Save[i][j][r] , newValue );
                end
            end
        end
    end

    for i = 1 , #GRM_PlayersThatLeftHistory_Save do                         -- Horde and Alliance
        for j = 2 , #GRM_PlayersThatLeftHistory_Save[i] do                  -- The guilds in each faction
            for r = 2 , #GRM_PlayersThatLeftHistory_Save[i][j] do           -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                if #GRM_PlayersThatLeftHistory_Save[i][j][r] == previousMaxIndex then
                    table.insert ( GRM_PlayersThatLeftHistory_Save[i][j][r] , newValue );
                end
            end
        end
    end
end

-- Introduced patch R1.148
-- Method:          GRM_Patch.AddNewDefaultSetting ( int , object , boolean )
-- What it Does:    Modifies the given setting based on the index point in the settings with the new given setting
-- Purpose:         To create a universally reusable patcher.
GRM_Patch.AddNewDefaultSetting = function ( index , newSetting , isArray )
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            if not isArray then
                GRM_AddonSettings_Save[i][j][2][index] = newSetting;
            else
                table.insert ( GRM_AddonSettings_Save[i][j][2][index] , newSetting );
            end
        end
    end
end

-- patch R1.148
-- Method:          GRM_Patch.SetProperRankRestrictions()
-- What it Does:    Sets the ban list rank and custom note rank to match overall sync filter rank, if necessary
-- Purpose:         Clarity for the addon user on rank filtering.
GRM_Patch.SetProperRankRestrictions = function()
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            -- If ban List rank restriction is not right then set it to proper default
            if GRM_AddonSettings_Save[i][j][2][22] > GRM_AddonSettings_Save[i][j][2][15] then
                GRM_AddonSettings_Save[i][j][2][22] = GRM_AddonSettings_Save[i][j][2][15];
            end
        
            -- Same with custom note
            if GRM_AddonSettings_Save[i][j][2][49] > GRM_AddonSettings_Save[i][j][2][15] then
                GRM_AddonSettings_Save[i][j][2][49] = GRM_AddonSettings_Save[i][j][2][15];
            end
        end
    end
end

-- patch R1.1482
-- Method:          GRM_Patch.FixAltData()
-- What it Does:    Goes to every saved player and changes a boolean to a today's timestamp
-- Purpose:         There was some sync code that erroneously added a boolean instead of the epoch time stamp for when a player's alt was modified. This fixes that problem
-- Limitation:      This has potential to overwrite some other's data if it hasn't sync'd in a while, but it is unlikely to be an issue for 99% of the population.
GRM_Patch.FixAltData = function()
    local timestamp = time();
    for i = 1 , #GRM_GuildMemberHistory_Save do                                 -- Horde and Alliance
        for j = 2 , #GRM_GuildMemberHistory_Save[i] do                          -- The guilds in each faction
            for r = 2 , #GRM_GuildMemberHistory_Save[i][j] do                   -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                -- Alt list
                for k = 1 , #GRM_GuildMemberHistory_Save[i][j][r][11] do        -- the alt lists each player in the guild
                    if type ( GRM_GuildMemberHistory_Save[i][j][r][11][k][6] ) == "boolean" then
                        GRM_GuildMemberHistory_Save[i][j][r][11][k][6] = timestamp;
                    end
                end
                -- Alt Removed List
                for k = 1 , #GRM_GuildMemberHistory_Save[i][j][r][37] do        -- the alt lists each player in the guild
                    if type ( GRM_GuildMemberHistory_Save[i][j][r][37][k][6] ) == "boolean" then
                        GRM_GuildMemberHistory_Save[i][j][r][37][k][6] = timestamp;
                    end
                end
            end
        end
    end

    -- need to update the left player's database too...
    for i = 1 , #GRM_PlayersThatLeftHistory_Save do                         -- Horde and Alliance
        for j = 2 , #GRM_PlayersThatLeftHistory_Save[i] do                  -- The guilds in each faction
            for r = 2 , #GRM_PlayersThatLeftHistory_Save[i][j] do           -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                for k = 1 , #GRM_PlayersThatLeftHistory_Save[i][j][r][11] do        -- the alt lists each player in the guild
                    if type ( GRM_PlayersThatLeftHistory_Save[i][j][r][11][k][6] ) == "boolean" then
                        GRM_PlayersThatLeftHistory_Save[i][j][r][11][k][6] = timestamp;
                    end
                end
                -- Alt Removed List
                for k = 1 , #GRM_PlayersThatLeftHistory_Save[i][j][r][37] do        -- the alt lists each player in the guild
                    if type ( GRM_PlayersThatLeftHistory_Save[i][j][r][37][k][6] ) == "boolean" then
                        GRM_PlayersThatLeftHistory_Save[i][j][r][37][k][6] = timestamp;
                    end
                end
            end
        end
    end
end

-- Method:          GRM_Patch.RemoveAllAutoBackups()
-- What it Does:    Removes all autobackups for all guilds both factions
-- Purpose:         Due to a flaw in the way auto-saved backups were added, this is now fixed.
GRM_Patch.RemoveAllAutoBackups = function()
    local tempBackup = GRM_GuildDataBackup_Save;
    for i = 1 , #tempBackup do
        for j = 2 , #tempBackup[i] do
            -- find a guild, then find if there are any autobackups...
            for s = 2 , 3 do
                if #tempBackup[i][j][s] > 0 then
                    -- We found a backup!!! Let's remove it!!!
                    if type ( tempBackup[i][j][1] ) == "table" then
                        GRM.RemoveGuildBackup ( tempBackup[i][j][1][1] , tempBackup[i][j][1][2] , i , tempBackup[i][j][s][1] , false );
                    else
                        GRM.RemoveGuildBackup ( tempBackup[i][j][1] , "Unknown" , i , tempBackup[i][j][s][1] , false );
                    end
                end
            end
        end
    end
end

-- Method:          GRM_Patch.CleanupAnniversaryEvents()
-- What it Does:    Due to an error with syncing alt join date data, this cleanus up the string for proper format
-- Purpose:         So players are properly reported for anniversary reminders.
GRM_Patch.CleanupAnniversaryEvents = function()
    for i = 1 , #GRM_GuildMemberHistory_Save do                         -- Horde and Alliance
        for j = 2 , #GRM_GuildMemberHistory_Save[i] do                  -- The guilds in each faction
            for r = 2 , #GRM_GuildMemberHistory_Save[i][j] do           -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                if GRM_GuildMemberHistory_Save[i][j][r][22][1][2] ~= nil then
                    if type ( GRM_GuildMemberHistory_Save[i][j][r][22][1][2] ) == "string" then
                        local tempString = string.gsub ( GRM_GuildMemberHistory_Save[i][j][r][22][1][2] , "Joined: " , "" );
                        GRM_GuildMemberHistory_Save[i][j][r][22][1][2] = string.sub ( tempString , 1 , string.find ( tempString , "'" ) + 2 );
                    end
                end
            end
        end
    end

    -- need to update the left player's database too...
    for i = 1 , #GRM_PlayersThatLeftHistory_Save do                         -- Horde and Alliance
        for j = 2 , #GRM_PlayersThatLeftHistory_Save[i] do                  -- The guilds in each faction
            for r = 2 , #GRM_PlayersThatLeftHistory_Save[i][j] do           -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                if GRM_PlayersThatLeftHistory_Save[i][j][r][22][1][2] ~= nil then
                    if type ( GRM_PlayersThatLeftHistory_Save[i][j][r][22][1][2] ) == "string" then
                        local tempString = string.gsub ( GRM_PlayersThatLeftHistory_Save[i][j][r][22][1][2] , "Joined: " , "" );
                        GRM_PlayersThatLeftHistory_Save[i][j][r][22][1][2] = string.sub ( tempString , 1 , string.find ( tempString , "'" ) + 2 );
                    end
                end
            end
        end
    end
end

-- Method:          GRM_Patch.RemoveTitlesEventDataAndUpdateBirthday()
-- What it Does:    Due to a change in the way the events (birthday, anniversary, custom) are handled, and for localization reasons, this "title" can be removed
-- Purpose:         Updating the database to prevent old errors from old databases.
GRM_Patch.RemoveTitlesEventDataAndUpdateBirthday = function()
    for i = 1 , #GRM_GuildMemberHistory_Save do                         -- Horde and Alliance
        for j = 2 , #GRM_GuildMemberHistory_Save[i] do                  -- The guilds in each faction
            for r = 2 , #GRM_GuildMemberHistory_Save[i][j] do           -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                for s = 1 , 2 do
                    if #GRM_GuildMemberHistory_Save[i][j][r][22][s] == 4 and type ( GRM_GuildMemberHistory_Save[i][j][r][22][s][3] ) == "boolean" then
                        table.remove ( GRM_GuildMemberHistory_Save[i][j][r][22][s] , 1 );
                    end
                    if s == 2 and #GRM_GuildMemberHistory_Save[i][j][r][22][s] == 3 then
                        table.insert ( GRM_GuildMemberHistory_Save[i][j][r][22][s] , 0 );       -- extra index for the timestamp of the change
                    end
                end
            end
        end
    end

    for i = 1 , #GRM_PlayersThatLeftHistory_Save do                         -- Horde and Alliance
        for j = 2 , #GRM_PlayersThatLeftHistory_Save[i] do                  -- The guilds in each faction
            for r = 2 , #GRM_PlayersThatLeftHistory_Save[i][j] do           -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                for s = 1 , 2 do
                    if #GRM_PlayersThatLeftHistory_Save[i][j][r][22][s] == 4 and type ( GRM_PlayersThatLeftHistory_Save[i][j][r][22][s][3] ) == "boolean" then
                        table.remove ( GRM_PlayersThatLeftHistory_Save[i][j][r][22][s] , 1 );
                    end
                    if s == 2 and #GRM_PlayersThatLeftHistory_Save[i][j][r][22][s] == 3 then
                        table.insert ( GRM_PlayersThatLeftHistory_Save[i][j][r][22][s] , 0 );
                    end
                end
            end
        end
    end
end

-- Method:          GRM_Patch.UpdateCalendarEventsDatabase()
-- What it Does:    Checks the oldEventsDatabase and adds an eventTypeIndex identifier at the end. In this case, a 1 because ONLY anniversaries have ever been documented
-- Purpose:         To enable all new features to be implemented with the events log and the elimination of errors that will occur with new database changes.
GRM_Patch.UpdateCalendarEventsDatabase = function()
    for i = 1 , #GRM_CalendarAddQue_Save do
        for j = 2 , #GRM_CalendarAddQue_Save[i] do
            for r = 2 , #GRM_CalendarAddQue_Save[i][j] do
                if #GRM_CalendarAddQue_Save[i][j][r] == 6 then
                    table.insert ( GRM_CalendarAddQue_Save[i][j][r] , 1 );
                end
            end
        end
    end
end

-- Method:          GRM_Patch.MatchLanguageTo24HrFormat()
-- What it Does:    Checks the selected language then defaults to 24hr scale or 12hr scale
-- Purpose:         Auto-configure what is the popular hour/min format for the day based on the language preference.
GRM_Patch.MatchLanguageTo24HrFormat = function()
    for i = 1 , #GRM_AddonSettings_Save do
        for j = 2 , #GRM_AddonSettings_Save[i] do
            if GRM_AddonSettings_Save[i][j][2][43] == 1 or GRM_AddonSettings_Save[i][j][2][43] == 6 then         -- 2 German, 3 French default to 24hr scale, the rest 12hr.
                GRM_AddonSettings_Save[i][j][2][39] = false;
            else
                GRM_AddonSettings_Save[i][j][2][39] = true;
            end
        end
    end
end

-- Method:          GRM_Patch.FixBanListNameGrammar()
-- What it Does:    Corrects any ill added names through the manual ban system and corrects their format
-- Purpose:         Human error protection retroactive that is now implemented live.
GRM_Patch.FixBanListNameGrammar = function()
    -- Only need to do this for non-Asian languages.
    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][43] < 9 then
        -- need to update the left player's database too...
        for i = 1 , #GRM_PlayersThatLeftHistory_Save do                         -- Horde and Alliance
            for j = 2 , #GRM_PlayersThatLeftHistory_Save[i] do                  -- The guilds in each faction
                for r = 2 , #GRM_PlayersThatLeftHistory_Save[i][j] do           -- The players in each guild (starts at 2 as position 1 is the name of the guild).
                    local server = string.sub ( GRM_PlayersThatLeftHistory_Save[i][j][r][1] , string.find ( GRM_PlayersThatLeftHistory_Save[i][j][r][1] , "-" ) + 1 );
                    GRM_PlayersThatLeftHistory_Save[i][j][r][1] = GRM.FormatInputName ( GRM.SlimName ( GRM_PlayersThatLeftHistory_Save[i][j][r][1] ) ) .. "-" .. server;
                end
            end
        end
    end
end

-- Method:          GRM_Patch.FixGuildNotePad()
-- What it Does:    Removes a nil index in the notepad database
-- Purpose:         For some reason in the database conversion there was a flaw where the index was made nil instead of eliminated for some instances, thus breaking scan logic through the guild
--                  This removes the nil index, shifting the database down and leaving them in their proper index now.
GRM_Patch.FixGuildNotePad = function()
    for i = 1 , #GRM_GuildNotePad_Save do
        if GRM_GuildNotePad_Save[i][2] == nil then
            table.remove ( GRM_GuildNotePad_Save[i] , 2 );
        end
    end
end

-- Method:          GRM_Patch.FixDoubleCopiesInLeftPLayers()
-- What it Does:    Cleans up the left players for double copies which could have happened with the ban list.
-- Purpose:         Fix an error in the code from patch 1.1530 in the ban list modification updates.
GRM_Patch.FixDoubleCopiesInLeftPLayers = function()
    for j = 1 , #GRM_PlayersThatLeftHistory_Save do
        for s = 2 , #GRM_PlayersThatLeftHistory_Save[j] do
            local t = GRM_PlayersThatLeftHistory_Save[j][s];
            local i , c , r = 2;
            while i <= #t do
                c = 0;
                local n = t[i][1];
                for j = 2 , #t do
                    if t[j][1] == n then
                        c = c + 1;
                        if c > 1 then
                            r = j;
                            break;
                        end;
                    end;
                end;
                if c > 1 then 
                    table.remove ( t , r );
                else
                    i = i + 1;
                end;
            end
        end
    end
end

-- Method:          GRM_Patch.RemoveAltCopies()
-- What it Does:    Removes any instance or copy of a player due to the merging of the database
-- PurposE:         To cleanup the mistake of a coding error in an earlier build...
GRM_Patch.RemoveAltCopies = function()
    for i = 1 , #GRM_PlayerListOfAlts_Save do
        for j = 2 , #GRM_PlayerListOfAlts_Save[i] do
            for r = #GRM_PlayerListOfAlts_Save[i][j] , 2 , -1  do
                -- Cycling through all the guildies now.
                for k = #GRM_PlayerListOfAlts_Save[i][j] , 2 , -1 do
                    if r ~= k and GRM_PlayerListOfAlts_Save[i][j][r][1] == GRM_PlayerListOfAlts_Save[i][j][k][1] then
                        table.remove ( GRM_PlayerListOfAlts_Save[i][j] , k );
                        break;
                    end
                end
            end
        end
    end
end

-- Method:          GRM_Patch.DoAltListIntegrityCheckAndCleanup()
-- What it Does:    Checks for nil entries, removes them
-- Purpose:         Cleanup the database in case of errors.
GRM_Patch.DoAltListIntegrityCheckAndCleanup = function()
    for i = 1 , #GRM_PlayerListOfAlts_Save do
        for j = #GRM_PlayerListOfAlts_Save[i] , 2 , -1 do -- Cycle backwards in case of index remove.
            if GRM_PlayerListOfAlts_Save[i][j] == nil then
                table.remove ( GRM_PlayerListOfAlts_Save[i] , j );
            else
                for r = #GRM_PlayerListOfAlts_Save[i][j] , 2 , -1 do    -- Cycle backwards in case of index remove.
                    if GRM_PlayerListOfAlts_Save[i][j][r] == nil then
                        table.remove ( GRM_PlayerListOfAlts_Save[i][j] , r );
                    end
                end
            end
        end
    end         
end

-- Method:          GRM_Patch.FixPlayerListOfAltsDatabase()
-- What it Does:    Fixes the double guild references left over from a database conversion in the alts list
-- Purpose:         when trying to sync settings between alts, the list tree of alts was split between multiple references of the guild. This clears that up.
GRM_Patch.FixPlayerListOfAltsDatabase = function()
    local isMatch = false;
    local guildName = "";
    local isProper = false;
    GRM_Patch.DoAltListIntegrityCheckAndCleanup(); -- Important to do this first...

    for i = 1 , #GRM_PlayerListOfAlts_Save do
        for j = #GRM_PlayerListOfAlts_Save[i] , 2 , -1 do   -- Cycle backwards...
            -- Look for matches within the guilds.
            -- Get name of the guild considering new and old database...
            guildName = "";
            isProper = false;
            isMatch = false;
            if type(GRM_PlayerListOfAlts_Save[i][j][1]) == "table" then
                guildName = GRM_PlayerListOfAlts_Save[i][j][1][1];
            elseif type(GRM_PlayerListOfAlts_Save[i][j][1]) == "string" then
                guildName = GRM_PlayerListOfAlts_Save[i][j][1];
            end

            if string.find ( guildName , "-" ) ~= nil then              -- If it has a yphen, it's a new database guild, it is the one we want.
                isProper = true;
            end
            
            -- Need to purge the double if 2x outdated...
            if not isProper then
                -- The guild name does not have the server name attached.
                for r = #GRM_PlayerListOfAlts_Save[i] , 2 , -1 do
                    if r ~= j then
                        if type ( GRM_PlayerListOfAlts_Save[i][r][1] ) == "table" and GRM.SlimName ( GRM_PlayerListOfAlts_Save[i][r][1][1] ) == guildName then
                            -- guild match with a propper guild
                            if string.find ( GRM_PlayerListOfAlts_Save[i][r][1][1] , "-" ) ~= nil then
                                isMatch = true;
                            end
                        elseif type ( GRM_PlayerListOfAlts_Save[i][r][1] ) == "string" and GRM.SlimName ( GRM_PlayerListOfAlts_Save[i][r][1] ) == guildName then
                            if string.find ( GRM_PlayerListOfAlts_Save[i][r][1] , "-" ) ~= nil then
                                isMatch = true;
                            end
                        end
                        
                        -- Now, need to copy my databse over to this proper one...
                        if isMatch then
                            for k = 2 , #GRM_PlayerListOfAlts_Save[i][j] do
                                table.insert ( GRM_PlayerListOfAlts_Save[i][r] , GRM_PlayerListOfAlts_Save[i][j][k] );
                            end
                            -- Now remove the unpropper guild.
                            table.remove ( GRM_PlayerListOfAlts_Save[i] , j );
                            break;
                        end
                    end
                end

                if not isMatch then
                    -- if not a match, then let's just leave the guild name and purge the reset
                    while #GRM_PlayerListOfAlts_Save[i][j] > 1 do
                        table.remove ( GRM_PlayerListOfAlts_Save[i][j] , 2 );
                    end
                end
            else
                -- Now, determine if there is a match
                for r = #GRM_PlayerListOfAlts_Save[i] , 2 , -1 do         -- cycle through the guilds...
                    if r ~= j then                                              -- make sure it is not the same 
                        if type ( GRM_PlayerListOfAlts_Save[i][r][1] ) == "table" and GRM.SlimName ( GRM_PlayerListOfAlts_Save[i][r][1][1] ) == GRM.SlimName ( guildName ) then
                            -- guild match with a propper guild
                            if string.find ( GRM_PlayerListOfAlts_Save[i][r][1][1] , "-" ) ~= nil then
                                isMatch = true;
                            end
                        elseif type ( GRM_PlayerListOfAlts_Save[i][r][1] ) == "string" and GRM.SlimName ( GRM_PlayerListOfAlts_Save[i][r][1] ) == GRM.SlimName ( guildName ) then
                            if string.find ( GRM_PlayerListOfAlts_Save[i][r][1] , "-" ) ~= nil then
                                isMatch = true;
                            end
                        end
                        
                        -- Now, need to copy my databse over to this proper one...
                        if isMatch then
                            for k = 2 , #GRM_PlayerListOfAlts_Save[i][r] do
                                table.insert ( GRM_PlayerListOfAlts_Save[i][j] , GRM_PlayerListOfAlts_Save[i][r][k] );
                            end
                            -- Now remove the unpropper guild.
                            table.remove ( GRM_PlayerListOfAlts_Save[i] , r );
                            break;
                        end
                    end
                end
            end
        end
    end

    -- Now, need to purge the copies...
    GRM_Patch.RemoveAltCopies();
end

-- GRM.Cleanup24HrErroneousTags = function()
--     local t = GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID];
--     for i = 2 , #t do if string.find(t[i][35][1],"24HR")~=nil then t[i][35][1]=string.sub(t[i][35][1],1,string.find(t[i][35][1],"24HR")-1);print(t[i][35][1]);end;end
-- end

-- /run table.insert ( GRM_PlayersThatLeftHistory_Save[GRM_G.FID][GRM_G.saveGID] , GRM_PlayersThatLeftHistory_Save[GRM_G.FID][GRM_G.saveGID][10])
-- /run local t=GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID];local s=GRM.

-- ( string.sub ( t[2][20][#t[2][20]] , 1 , string.find ( t[2][20][#t[2][20]] , "'" ) + 2 ));print(s[4])
-- /run local t=GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID];print ( GRM.GetTimePassedUsingStringStamp ( string.sub ( t[316][20][#t[316][20]] , 1 , string.find ( t[316][20][#t[316][20]] , "'" ) + 2 ) ) );
-- Potential alt and removed alt patch check...
-- /run local t=GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID];for i=2,#t do for j=1,#t[i][11] do if type(t[i][11][j][6])=="boolean" then print(t[i][1]);break;end;end;end
-- /run local t=GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID];for i=2,#t do for j=1,#t[i][37] do if t[i][37][j][6]==nil then print(t[i][1]);end;end;end
-- /run local t=GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID];for i=2,#t do print(t[i][22][1][2]); end