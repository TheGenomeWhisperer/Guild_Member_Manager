---UPDATES AND BUG PATCHES


GRM_Patch = {};

-- Introduced Patch R1.092
-- Alt tracking of the player - so it can auto-add the player's own alts to the guild info on use.
GRM_Patch.SetupAltTracking = function()
    -- Need to check if already added to the guild...
    local guildNotFound = true;
    if GRM_AddonGlobals.guildName ~= nil then
        for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ] do
            if GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][i][1][1] == GRM_AddonGlobals.guildName and GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][i][1][2] == GRM_AddonGlobals.guildCreationDate then
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
        table.insert ( GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ] , { { GRM_AddonGlobals.guildName , GRM_AddonGlobals.guildCreationDate } } );  -- alts list, let's create an index for the guild!

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
    
    -- Need to check if already added to the guild...
    local guildNotFound = true;
    for i = 2 , #GRM_GuildNotePad_Save[ GRM_AddonGlobals.FID ] do
        if GRM_GuildNotePad_Save[GRM_AddonGlobals.FID][i][1][1] == GRM_AddonGlobals.guildName and GRM_GuildNotePad_Save[GRM_AddonGlobals.FID][i][1][2] == GRM_AddonGlobals.guildCreationDate then
            guildNotFound = false;
            break;
        end
    end

    -- Build the table for the first time! It will be unique to the faction and the guild.
    table.insert ( GRM_GuildNotePad_Save , { "Horde" } );
    table.insert ( GRM_GuildNotePad_Save , { "Alliance" } );

    if IsInGuild() and not guildNotFound then
        -- guild is found, let's add the guild!
        table.insert ( GRM_GuildNotePad_Save[ GRM_AddonGlobals.FID ] , { GRM_AddonGlobals.guildName } );  -- alts list, let's create an index for the guild!
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
    local settings = GRM_AddonSettings_Save[GRM_AddonGlobals.FID];
    for i = 2 , #settings do
        if #settings[i][2] > anyValueGreaterThanThisIndex then
            while #settings[i][2] > anyValueGreaterThanThisIndex do
                table.remove ( settings[i][2] , #settings[i][2] );
            end
        end
    end
    GRM_AddonSettings_Save[GRM_AddonGlobals.FID] = settings;
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
    if GRM_AddonGlobals.guildCreationDate ~= "" then
        if GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][index][1] == GRM_AddonGlobals.guildName then
            GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][index][1] = { GRM_AddonGlobals.guildName , GRM_AddonGlobals.guildCreationDate };
            
            -- now need to do the same thing for all the rest...
            for j = 2 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID] do
                if GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][j][1] == GRM_AddonGlobals.guildName then
                    GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][j][1] = { GRM_AddonGlobals.guildName , GRM_AddonGlobals.guildCreationDate };
                    break;
                end
            end

            for j = 2 , #GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID] do
                if GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][j][1] == GRM_AddonGlobals.guildName then
                    GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][j][1] = { GRM_AddonGlobals.guildName , GRM_AddonGlobals.guildCreationDate };
                    break;
                end
            end

            for j = 2 , #GRM_LogReport_Save[GRM_AddonGlobals.FID] do
                if GRM_LogReport_Save[GRM_AddonGlobals.FID][j][1] == GRM_AddonGlobals.guildName then
                    GRM_LogReport_Save[GRM_AddonGlobals.FID][j][1] = { GRM_AddonGlobals.guildName , GRM_AddonGlobals.guildCreationDate };
                    break;
                end
            end

            for j = 2 , #GRM_GuildNotePad_Save[GRM_AddonGlobals.FID] do
                if GRM_GuildNotePad_Save[GRM_AddonGlobals.FID][j][1] == GRM_AddonGlobals.guildName then
                    GRM_GuildNotePad_Save[GRM_AddonGlobals.FID][j][1] = { GRM_AddonGlobals.guildName , GRM_AddonGlobals.guildCreationDate };
                    break;
                end
            end

            for j = 2 , #GRM_PlayerListOfAlts_Save[GRM_AddonGlobals.FID] do
                if GRM_PlayerListOfAlts_Save[GRM_AddonGlobals.FID][j][1] == GRM_AddonGlobals.guildName then
                    GRM_PlayerListOfAlts_Save[GRM_AddonGlobals.FID][j][1] = { GRM_AddonGlobals.guildName , GRM_AddonGlobals.guildCreationDate };
                    break;
                end
            end
        end
        -- Now need to update the backup info...
        for i = 2 , #GRM_GuildDataBackup_Save[GRM_AddonGlobals.FID] do
            if type ( GRM_GuildDataBackup_Save[GRM_AddonGlobals.FID][i][1] ) == "string" and GRM_GuildDataBackup_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.guildName then
                GRM_GuildDataBackup_Save[GRM_AddonGlobals.FID][i][1] = { GRM_AddonGlobals.guildName , GRM_AddonGlobals.guildCreationDate };
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
                    if GRM_GuildMemberHistory_Save[i][s][j][1] == GRM_AddonGlobals.addonPlayerName then
                        GRM_GuildMemberHistory_Save[i][s][1] = GRM_AddonGlobals.guildName;
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
    if typeToAdd == 1 then
        expansionType = 1;
    elseif typeToAdd == 2 then
        expansionType = true;
    elseif typeToAdd == 3 then
        expansionType = {};
    elseif typeToAdd == 4 then
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
                if GRM_AddonGlobals.Region == "" or GRM_AddonGlobals.Region == "enUS" or GRM_AddonGlobals.Region == "enGB" then
                    GRM_AddonSettings_Save[i][j][2][43] = 1;
                elseif GRM_AddonGlobals.Region == "deDE" then
                    GRM_AddonSettings_Save[i][j][2][43] = 2;
                elseif GRM_AddonGlobals.Region == "frFR" then
                    GRM_AddonSettings_Save[i][j][2][43] = 3;
                elseif GRM_AddonGlobals.Region == "itIT" then
                    GRM_AddonSettings_Save[i][j][2][43] = 4;
                elseif GRM_AddonGlobals.Region == "ruRU" then
                    GRM_AddonSettings_Save[i][j][2][43] = 5;
                elseif GRM_AddonGlobals.Region == "esMX" then
                    GRM_AddonSettings_Save[i][j][2][43] = 6;
                elseif GRM_AddonGlobals.Region == "esES" then
                    GRM_AddonSettings_Save[i][j][2][43] = 7;
                elseif GRM_AddonGlobals.Region == "ptBR" then
                    GRM_AddonSettings_Save[i][j][2][43] = 8;
                elseif GRM_AddonGlobals.Region == "koKR" then
                    GRM_AddonSettings_Save[i][j][2][43] = 9;
                elseif GRM_AddonGlobals.Region == "zhCN" then
                    GRM_AddonSettings_Save[i][j][2][43] = 10;
                elseif GRM_AddonGlobals.Region == "zhTW" then
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

    if guildName == GRM_AddonGlobals.guildName and creationDate == GRM_AddonGlobals.guildCreationDate then
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
            if GRM_AddonGlobals.FID == factionIndex and purgeGuildIndex < GRM_AddonGlobals.saveGID then
                GRM_AddonGlobals.saveGID = GRM_AddonGlobals.saveGID - 1;
            end
            if GRM_AddonGlobals.FID == factionIndex and purgeLogIndex < GRM_AddonGlobals.logGID then
                GRM_AddonGlobals.logGID = GRM_AddonGlobals.logGID - 1;
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
