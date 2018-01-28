---UPDATES AND BUG PATCHES


GRM_Patch = {};

-- Introduced Patch R1.092
-- Alt tracking of the player - so it can auto-add the player's own alts to the guild info on use.
GRM_Patch.SetupAltTracking = function()
    -- Need to check if already added to the guild...
    local guildNotFound = true;
    if GRM_AddonGlobals.guildName ~= nil then
        for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ] do
            if GRM_AddonGlobals.guildName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ][1] then
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
        table.insert ( GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ] , { GRM_AddonGlobals.guildName } );  -- alts list, let's create an index for the guild!

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
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ] do
        if GRM_AddonGlobals.guildName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ][1] then
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

-- /run for i=2,#GRM_AddonSettings_Save[GRM_AddonGlobals.FID] do print(GRM_AddonSettings_Save[GRM_AddonGlobals.FID][i][2][25])end