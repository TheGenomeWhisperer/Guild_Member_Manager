-- Author: Arkaan
-- Addon Name: "Guild Roster Manager"

-- Table to hold all functions
GRM = {};

-- Global tables saved account wide.
-- Just load the settings the first time addon is loaded.
GRM_AddonSettings_Save = {};             -- Configuration saved here for all alts. Each toon gets their own configuration table as they might be in different guilds, thus player may want to configure different.
GRM_LogReport_Save = {};                 -- This will be the stored Log of events and changes.
GRM_GuildMemberHistory_Save = {}         -- Detailed information on each guild member
GRM_PlayersThatLeftHistory_Save = {};    -- Data storage of all players that left the guild, so metadata is stored if they return. Useful for "rejoin" tracking, and to see if players were banned.
GRM_CalendarAddQue_Save = {};            -- Since the add to calendar is protected, and requires a player input, this will be qued here between sessions. { name , eventTitle , eventMonth , eventDay , eventYear , eventDescription } 
GRM_PlayerListOfAlts_Save = {};          -- This is used so the player has a working alt list to reference, so they can add themselves to an alt list.

-- slash commands
SLASH_GRM1 = '/roster';

-- Useful Variables ( kept in table to keep low upvalues count )
GRM_AddonGlobals = {};

-- Addon Details:
GRM_AddonGlobals.Version = "7.3.2R1.104";
GRM_AddonGlobals.PatchDay = 1510382521;             -- In Epoch Time
GRM_AddonGlobals.PatchDayString = "1510382521";     -- 2 Versions saves on conversion computational costs... just keep one stored in memory. Extremely minor gains, but very useful if syncing thousands of pieces of data in large guilds.
GRM_AddonGlobals.Patch = "7.3.2";

-- Initialization Useful Globals 
-- ADDON
GRM_AddonGlobals.addonName = "Guild_Roster_Manager";
-- Player Details
GRM_AddonGlobals.guildName = GetGuildInfo ( "PLAYER" );
GRM_AddonGlobals.realmName = string.gsub ( string.gsub ( GetRealmName() , "-" , "" ) , "%s+" , "" );       -- Remove the space since server return calls don't include space on multi-name servers, also removes a hyphen if server is hyphened.
GRM_AddonGlobals.addonPlayerName = ( GetUnitName ( "PLAYER" , false ) .. "-" .. GRM_AddonGlobals.realmName );
GRM_AddonGlobals.faction = UnitFactionGroup ( "PLAYER" );
GRM_AddonGlobals.rank = 1;
GRM_AddonGlobals.FID = 0;        -- index for Horde = 1; Ally = 2
GRM_AddonGlobals.logGID = 0;     -- index of the guild, so no need for repeat lookups.
GRM_AddonGlobals.saveGID = 0;    -- Needs a separate GID "Guild Index ID" because it may not match the log index depending on if a log entry is cleared vs guild info, whcih can be separate.
GRM_AddonGlobals.setPID = 0;     -- Since settings are player unique, PID = Player ID

-- To ensure frame initialization occurse just once... what a waste in resources otherwise.
GRM_AddonGlobals.timeDelayValue = 0;
GRM_AddonGlobals.timeDelayValue2 = 0;
GRM_AddonGlobals.FramesInitialized = false;
GRM_AddonGlobals.OnFirstLoad = true;
GRM_AddonGlobals.currentlyTracking = false;
GRM_AddonGlobals.trackingTriggered = false;

-- Guild Status holder for checkover.
GRM_AddonGlobals.guildStatusChecked = false;

-- Tempt Logs For FinalReport()
GRM_AddonGlobals.TempNewMember = {};
GRM_AddonGlobals.TempLogPromotion = {};
GRM_AddonGlobals.TempInactiveReturnedLog = {};
GRM_AddonGlobals.TempEventRecommendKickReport = {};
GRM_AddonGlobals.TempLogDemotion = {};
GRM_AddonGlobals.TempLogLeveled = {};
GRM_AddonGlobals.TempLogNote = {};
GRM_AddonGlobals.TempLogONote = {};
GRM_AddonGlobals.TempRankRename = {};
GRM_AddonGlobals.TempRejoin = {};
GRM_AddonGlobals.TempBannedRejoin = {};
GRM_AddonGlobals.TempLeftGuild = {};
GRM_AddonGlobals.TempNameChanged = {};
GRM_AddonGlobals.TempEventReport = {};

-- Useful Globals for Quick Use
GRM_AddonGlobals.rankIndex = 1;
GRM_AddonGlobals.playerIndex = -1;
GRM_AddonGlobals.monthIndex = 1;
GRM_AddonGlobals.yearIndex = 1;
GRM_AddonGlobals.dayIndex = 1;

-- Alt Helpers
GRM_AddonGlobals.selectedAlt = {};
GRM_AddonGlobals.selectedAltList = {};
GRM_AddonGlobals.currentHighlightIndex = 1;

-- Guildie info
GRM_AddonGlobals.listOfGuildies = {};

-- MISC Globals for resource handling... generally to avoid wasteful checks based on timers, position, pause controls.
-- Some of this is just to prevent messy carryover by keeping 1 less argument to a method, by just keeping a global. 
-- Some are for frame/UI control, like "pause" to stop mouseover updates if you are adjusting an input or editing a date or something similar.
GRM_AddonGlobals.timer = 0;
GRM_AddonGlobals.timer2 = 0; 
GRM_AddonGlobals.timer3 = 0;
GRM_AddonGlobals.timer4 = 0;
GRM_AddonGlobals.timer5 = 0;                -- For use with the AddonUsersSyncInfo window...
GRM_AddonGlobals.DelayedAtLeastOnce = false;
GRM_AddonGlobals.CalendarAddDelay = 0; -- Needs to be at least 5 seconds due to server restriction on adding to calendar no more than once per 5 sec. First time can be zero.
GRM_AddonGlobals.RaidGCountBeingChecked = false;
GRM_AddonGlobals.timerUIChange = 0;
GRM_AddonGlobals.position = 0;
GRM_AddonGlobals.ScrollPosition = 0;
GRM_AddonGlobals.ShowOfflineChecked = false;
GRM_AddonGlobals.pause = false;
GRM_AddonGlobals.rankDateSet = false;
GRM_AddonGlobals.editPromoDate = false;
GRM_AddonGlobals.editJoinDate = false;
GRM_AddonGlobals.editFocusPlayer = false;
GRM_AddonGlobals.editStatusNotify = false
GRM_AddonGlobals.editOnlineStatus = false;
GRM_AddonGlobals.numPlayersRequestingGuildInv = 0;
GRM_AddonGlobals.guildFinderReported = false;
GRM_AddonGlobals.changeHappenedExitScan = false;
GRM_AddonGlobals.currentName = "";
GRM_AddonGlobals.RecursiveStop = false;
GRM_AddonGlobals.isChecked = false;
GRM_AddonGlobals.isChecked2 = false;
GRM_AddonGlobals.ClickCount = 0;
GRM_AddonGlobals.HasAccessToGuildChat = false;
GRM_AddonGlobals.HasAccessToOfficerChat = false;
GRM_AddonGlobals.tempAltName = "";
GRM_AddonGlobals.firstTimeWarning = true;
GRM_AddonGlobals.tempAddBanClass = "";

-- Current Addon users
GRM_AddonGlobals.currentAddonUsers = {};

-- Dropdown logic helpers and Roster UI Logic
GRM_AddonGlobals.RosterButtons = {};
GRM_AddonGlobals.CurrentRank = "";

GRM_AddonGlobals.VersionChecked = false;
GRM_AddonGlobals.VersionCheckRegistered = false;
GRM_AddonGlobals.VersionCheckedNames = {};
GRM_AddonGlobals.NeedsToAddSelfToList = false;

GRM_AddonGlobals.ActiveCheckQue = {};
GRM_AddonGlobals.ActiveStatusQue = {};

-- For Temporary Slash Command Actions
GRM_AddonGlobals.TemporarySync = false;
GRM_AddonGlobals.ManualScanEnabled = false;

-- Banning players
GRM_AddonGlobals.TempBanTarget = "";

-- FOR LOCALIZATION
GRM_AddonGlobals.Region = GetLocale();
GRM_AddonGlobals.FontChoice = "";
GRM_AddonGlobals.FontModifier = 0;

-- Useful Lookup Tables for date indexing.
local monthEnum = { Jan = 1 , Feb = 2 , Mar = 3 , Apr = 4 , May = 5 , Jun = 6 , Jul = 7 , Aug = 8 , Sep = 9 , Oct = 10 , Nov = 11 , Dec = 12 };
local monthEnum2 = { ['1'] = "Jan" , ['2'] = "Feb" , ['3'] = "Mar", ['4'] = "Apr" , ['5'] = "May" , ['6'] = "Jun" , ['7'] = "Jul" , ['8'] = "Aug" , ['9'] = "Sep" , ['10'] = "Oct" , ['11'] = "Nov" , ['12'] = "Dec" };
local monthsFullnameEnum = { January = 1 , February = 2 , March = 3 , April = 4 , May = 5 , June = 6 , July = 7 , August = 8 , September = 9 , October = 10 , November = 11 , December = 12 };
local daysBeforeMonthEnum = { ['1']=0 , ['2']=31 , ['3']=31+28 , ['4']=31+28+31 , ['5']=31+28+31+30 , ['6']=31+28+31+30+31 , ['7']=31+28+31+30+31+30 , 
                                ['8']=31+28+31+30+31+30+31 , ['9']=31+28+31+30+31+30+31+31 , ['10']=31+28+31+30+31+30+31+31+30 ,['11']=31+28+31+30+31+30+31+31+30+31, ['12']=31+28+31+30+31+30+31+31+30+31+30 };
local daysInMonth = { ['1']=31 , ['2']=28 , ['3']=31 , ['4']=30 , ['5']=31 , ['6']=30 , ['7']=31 , ['8']=31 , ['9']=30 , ['10']=31 , ['11']=30 , ['12']=31 };
local AllClasses = { "DEATHKNIGHT" , "DEMONHUNTER" , "DRUID" , "HUNTER" , "MAGE" , "MONK" , "PALADIN" , "PRIEST" , "ROGUE" , "SHAMAN" , "WARLOCK" , "WARRIOR" };

-- Which frame to send AddMessage
local chat = DEFAULT_CHAT_FRAME;

-- Let's global some of these useful frames into a table.
local GuildRanks = {};
-- GuildRosterFontstrings = {};

------------------------
------ FRAMES ----------
------------------------

-- Live Frames
local Initialization = CreateFrame ( "Frame" );
local GeneralEventTracking = CreateFrame ( "Frame" );
local UI_Events = CreateFrame ( "Frame" );
local VersionCheck = CreateFrame ( "Frame" );
local KickAndRankChecking = CreateFrame ( "Frame" );
local GuildBankInfoTracking = CreateFrame ( "Frame" );
local AddonUsersCheck = CreateFrame ( "Frame" );

-- MISC FRAMES
UI_Events.GRM_NumGuildiesText = UI_Events:CreateFontString ( "GRM_NumGuildiesText" , "OVERLAY" , "GameFontNormalSmall" );

--------------------------
--- FUNCTIONS ------------
--------------------------

-- Method:          GRM.ClearPermData()
-- What it Does:    Resets all the saved data back to nothing... and does not rebuid it.
-- Purpose:         Mainly for use if ever there is a need to purge the data, in beta, without rebuilding the roster.
GRM.ClearPermData = function()
    -- SPECIAL NOTE (if ever needed);

    GRM_GuildMemberHistory_Save = nil;
    GRM_GuildMemberHistory_Save = {};
    table.insert ( GRM_GuildMemberHistory_Save , { "Horde" } );
    table.insert ( GRM_GuildMemberHistory_Save , { "Alliance" } );

    GRM_PlayersThatLeftHistory_Save = nil;
    GRM_PlayersThatLeftHistory_Save = {};
    table.insert ( GRM_PlayersThatLeftHistory_Save , { "Horde" } );
    table.insert ( GRM_PlayersThatLeftHistory_Save , { "Alliance" } );

    GRM_LogReport_Save = nil;
    GRM_LogReport_Save = {};
    table.insert ( GRM_LogReport_Save , { "Horde" } );
    table.insert ( GRM_LogReport_Save , { "Alliance" } );

    GRM_CalendarAddQue_Save = nil;
    GRM_CalendarAddQue_Save = {};
    table.insert ( GRM_CalendarAddQue_Save , { "Horde" } );
    table.insert ( GRM_CalendarAddQue_Save , { "Alliance" } );
    
    GRM_AddonSettings_Save = nil;
    GRM_AddonSettings_Save = {};
    table.insert ( GRM_AddonSettings_Save , { "Horde" } );
    table.insert ( GRM_AddonSettings_Save , { "Alliance" } );

    GRM_PlayerListOfAlts_Save = nil;
    GRM_PlayerListOfAlts_Save = {};
    table.insert ( GRM_PlayerListOfAlts_Save , { "Horde" } );
    table.insert ( GRM_PlayerListOfAlts_Save , { "Alliance" } );
    
end

-- Method:          GRM.LoadSettings()
-- What it Does:    On first time loading addon, it builds default addon settings. It checks for addon version change
--                  And, if there are any changes, they will be added into that logic block. 
--                  And new setting can be tagged on.
-- Purpose:         Saving settings between gaming sessions. Also, this is built to provide backwards compatibility for future flexibility on feature adding, if necessary.
GRM.LoadSettings = function()
    -- Build the settings
    -- First, determine if addon settings have ever been initialized.
    if GRM_AddonSettings_Save[1] == nil then
        GRM.ClearPermData();                        -- This will purge the old data and then it needs to be built and reinitialized.
    end

    -- Find the player
    local isFound = false;
    local indexFound = 0;
    for i = 2 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] do
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.addonPlayerName then
            isFound = true;
            indexFound = i;
        end
    end

    -- Build settings for first time.
    if not isFound then
         -- Add new player
        table.insert ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID] , { GRM_AddonGlobals.addonPlayerName } );
        print ( "\nConfiguring Guild Roster Manager for " .. GetUnitName ( "PLAYER" , false ) .. " for the first time." );

        local AllDefaultSettings = {

            GRM_AddonGlobals.Version,                                                                               -- 1)  Version
            true,                                                                                                   -- 2)  View on Load
            { true , true , true , true , true , true , true , true , true , true , true , true , true },           -- 3)  All buttons are checked in the log window (13 so far)
            336,                                                                                                    -- 4)  Report inactive return of player coming back (2 weeks is default value)
            14,                                                                                                     -- 5)  Event Announce in Advance - Cannot be higher than 4 weeks ( 28 days ) ( 1 week is default);
            10,                                                                                                     -- 6)  How often to check for changes ( in seconds )
            true,                                                                                                   -- 7)  Add Timestamp on join to Officer Note
            true,                                                                                                   -- 8)  Use Calendar Announcements
            12,                                                                                                     -- 9)  Months Player Has Been Offline to Add Announcement To Kick
            false,                                                                                                  -- 10) Recommendations!
            true,                                                                                                   -- 11) Report Inactive Returns
            true,                                                                                                   -- 12) Announce Upcoming Events.
            { true , true , true , true , true , true , true , true , true , true , true , true , true },           -- 13) Checkbox for message frame announcing. Disable 
            true,                                                                                                   -- 14) Allow Data sharing between guildies
            2,                                                                                                      -- 15) Rank Player must be to accept sync updates from them.
            true,                                                                                                   -- 16) Receive Notifications if others in the guild send updates!
            false,                                                                                                  -- 17) Only announce the anniversary of players set as the "main"
            true,                                                                                                   -- 18) Scan for changes
            true,                                                                                                   -- 19) Sync only with players who have current version or higher.
            true,                                                                                                   -- 20) ''
            true,                                                                                                   -- 21) Sync Ban List
            2,                                                                                                      -- 22) Rank player must be to send or receive Ban List sync updates!
            0,                                                                                                      -- 23) ''
            0,                                                                                                      -- 24) ''
            0,                                                                                                      -- 25) ''
            0                                                                                                       -- 26) ''

        };
       
        -- Unique Settings added to the player.
        table.insert ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][ #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] ] , AllDefaultSettings );

    elseif GRM_AddonSettings_Save[GRM_AddonGlobals.FID][indexFound][2][1] ~= GRM_AddonGlobals.Version then
        -- Table that will have all of the release patch names.
        -- local ListOfReleasePatches = { "7.2.5r1.00" , "7.2.5r1.01" } ;
            
        -------------------------------
        --- START PATCH FIXES ---------
        -------------------------------

        
        -- Introduced Patch R1.092
        -- Alt tracking of the player - so it can auto-add the player's own alts to the guild info on use.
        if #GRM_PlayerListOfAlts_Save == 0 then

            -- Need to check if already added to the guild...
            local guildNotFound = true;
            for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ] do
                if GRM_AddonGlobals.guildName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ][1] then
                    guildNotFound = false;
                    break;
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

        -- Introduced Patch R1.1000
        -- Updating the version for ALL saved accounts.
        local needsUpdate = true;
        for i = 1 , #GRM_AddonSettings_Save do
            for j = 2 , #GRM_AddonSettings_Save[i] do
                if GRM_AddonSettings_Save[i][j][2][22] > 0 then
                    -- This will signify that the addon has already been updated to current state and will not need update.
                    needsUpdate = false;
                    break;
                else
                    GRM_AddonSettings_Save[i][j][2][22] = 2;      -- Updatingr rank to general officer rank to be edited.
                end
            end
            if not needsUpdate then     -- No need to cycle through everytime. Resource saving here!
                break;
            end
        end


        -------------------------------
        -- END OF PATCH FIXES ---------
        -------------------------------

        -- Ok, let's update the version!
        print ( GRM_AddonGlobals.addonName .. " v" .. string.sub ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][indexFound][2][1] , 6 ) .. " has been Updated to v" .. string.sub ( GRM_AddonGlobals.Version , 6 ) );

        -- Updating the version for ALL saved accoutns.
        for i = 1 , #GRM_AddonSettings_Save do
            for j = 2 , #GRM_AddonSettings_Save[i] do
                GRM_AddonSettings_Save[i][j][2][1] = GRM_AddonGlobals.Version;      -- Changing version for all indexes.
            end
        end
    end
end

-- Method:          GRM.ResetDefaultSettings()
-- What it Does:    Resets the OPTIONS to the default one for only the currently logged in player
-- Purpose:         Easy, quality of life for user in the options, for simple reset.
GRM.ResetDefaultSettings = function()
    
    -- Purge it from memory
    GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2] = nil;
    -- Reset to default
    GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2] = {

        GRM_AddonGlobals.Version,                                                                               -- 1)  Version
        true,                                                                                                   -- 2)  View on Load
        { true , true , true , true , true , true , true , true , true , true , true , true , true },           -- 3)  All buttons are checked in the log window (13 so far)
        336,                                                                                                    -- 4)  Report inactive return of player coming back (2 weeks is default value)
        14,                                                                                                     -- 5)  Event Announce in Advance - Cannot be higher than 4 weeks ( 28 days ) ( 1 week is default);
        10,                                                                                                     -- 6)  How often to check for changes ( in seconds )
        true,                                                                                                   -- 7)  Add Timestamp on join to Officer Note
        true,                                                                                                   -- 8)  Use Calendar Announcements
        12,                                                                                                     -- 9)  Months Player Has Been Offline to Add Announcement To Kick
        false,                                                                                                  -- 10) Recommendations!
        true,                                                                                                   -- 11) Report Inactive Returns
        true,                                                                                                   -- 12) Announce Upcoming Events.
        { true , true , true , true , true , true , true , true , true , true , true , true , true },           -- 13) Checkbox for message frame announcing. Disable 
        true,                                                                                                   -- 14) Allow Data sharing between guildies
        2,                                                                                                      -- 15) Rank Player must be to accept sync updates from them.
        true,                                                                                                   -- 16) Receive Notifications if others in the guild send updates!
        false,                                                                                                  -- 17) Only announce the anniversary of players set as the "main"
        true,                                                                                                   -- 18) Scan for changes
        true,                                                                                                   -- 19) Sync only with players who have current version or higher.

        true,                                                                                                   -- 20) ''
        true,                                                                                                   -- 21) Sync Ban List
        2,                                                                                                      -- 22) Rank player must be to send or receive Ban List sync updates!
        0,                                                                                                      -- 23) ''
        0,                                                                                                      -- 24) ''
        0,                                                                                                      -- 25) ''
        0                                                                                                       -- 26) ''
    }

    if GRM_RosterChangeLogFrame:IsVisible() then
        GRM_UI.BuildLogFrames();
    end
end

-- Method:          GRM.SlimName(string)
-- What it Does:    Removes the server name after character name.
-- Purpose:         Server name is not important in a guild since all will be server name.
GRM.SlimName = function( name )
    if string.find ( name , "-" , 1 ) ~= nil then
        return string.sub ( name , 1 , string.find ( name ,"-" ) - 1 );
    else
        return name;
    end
end

--------------------------------------
------ GROUP METHODS AND LOGIC -------
--------------------------------------

-- Method:          GRM.GetNumGuildies()
-- What it Does:    Returns the int number of total toons within the guild, including main/alts
-- Purpose:         For book-keeping and tracking total guild membership.
--                  Overall, this is mostly redundant as a simple GetNumGuildMembers() call is the same thing, however, this is just a tech Demo
--                  as a coding example of how to pull info and return it in your own function.
--                  A simple "GetNumGuildMembers()" would result in the same result in less steps. This is just more explicit to keep it within the style of the functions of the addon.
GRM.GetNumGuildies = function()
    return GetNumGuildMembers();
end

-- Method:          GRM.IsGuildieInSameGroup ( string )  -- proper format of the name should be "PlayerName-ServerName"
-- What it Does:    Returns true if the given guildie is grouped with you.
-- Purpose:         To determine if you are grouped with a guildie!
GRM.IsGuildieInSameGroup = function ( guildMember )
    local result = false;
    for i = 1 , GetNumGroupMembers() do
        local raidPlayer = GetRaidRosterInfo ( i );
        if raidPlayer == GRM.SlimName ( guildMember ) then
            result = true;
            break;
        end
    end
    return result;
end

-- Method:          GRM.GetAllGuildiesOnline( boolean )
-- What it Does:    Returns a table of names of all guildies that are currently online in the guild
-- Purpose:         Group management info and reporting. Pretty much some UI features, but possibly will be expanded upon.
GRM.GetAllGuildiesOnline = function( fullNameNeeded )
    GuildRoster();
    local listOfNames = {};
    for i = 1 , GRM.GetNumGuildies() do
        local name , _ , _ , _ , _ , _ , _ , _ , online = GetGuildRosterInfo ( i );
        if online then
            if name ~= nil then
                if not fullNameNeeded then
                    table.insert ( listOfNames , GRM.SlimName ( name) );
                else
                    table.insert ( listOfNames , name );
                end
            end
        end
    end
    return listOfNames;
end

-- Method:          GRM.GetNumGuildiesOnline()
-- What it Does:    Returns the int number of players currently online, with option to include those only on mobile, but not physically in the game, or not.
-- Purpose:         So on mouseover, the index on the roster call can be determined properly as online people are indexed first.
GRM.GetNumGuildiesOnline = function( includeMobile )
    local count = 0;
    for i = 1 , GRM.GetNumGuildies() do 
        local _ , _ , _ , _ , _ , _ , _ , _ , online , _ , _ , _ , _ , isMobile = GetGuildRosterInfo ( i );
        if online then
            if isMobile and not includeMobile then
                -- Don't count!
            else
                count = count + 1;
            end
        end
    end
    return count;
end

-- Method:          GRM.GetGroupUnitsOfflineOrAFK()
-- What it Does:    Returns a 2D array of the names of the players (not including server names) that are offline and afk in group
-- Purpose:         Mainly to notify the group leader who is AFK, possibly to make room for others in raid by informing leader of offline members.
GRM.GetGroupUnitsOfflineOrAFK = function()
    local offline = {};
    local afkMembers = {};
    
    for i = 1 , GetNumGroupMembers() do
        local raidPlayer , _ , _ , _ , _ , _ , _ , isOnline = GetRaidRosterInfo ( i );
        if isOnline ~= true then
            table.insert ( offline , raidPlayer );
        end
        if isOnline and UnitIsAFK( raidPlayer ) then
            table.insert ( afkMembers , raidPlayer );
        end        
    end
    local result = { offline , afkMembers };
    return result;
end

-- Method:          GRM.GetNumGuildiesInGroup()
-- What it Does:    Returns the int number of guildies you are grouped with, either in party or raid.
-- Purpose:         To report how many players are grouped with you from the guild. Helps you realize who is grouped with you
GRM.GetNumGuildiesInGroup = function()
    local result = 0;
    local allGuildiesOnline = GRM.GetAllGuildiesOnline( false );
    for i = 1 , GetNumGroupMembers() do
        local groupMemberName = GetRaidRosterInfo ( i );
        for j = 1 , #allGuildiesOnline do
            if groupMemberName == allGuildiesOnline[j] then
                result = result + 1;
                break;
            end
        end
        if result >= #allGuildiesOnline then
            -- No need to keep scanning, just break out.
            break;
        end
    end
    return result;
end

-- Method:          GRM.GetGuildMemberRankID ( string )
-- What it does:    Returns the rank index of the given player's name, or 0 if unable to find player
-- Purpose:         Rank needs to be known in certain circumstances, like knowing if something was a promotion or a demotion.
GRM.GetGuildMemberRankID = function( name )
    local result = -1;
    -- Prevents errors if the other players sends a sync call too early, it will just ignore it.
    if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] ~= nil then
        for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == name then
                result = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][5];
                break;
            end
        end
    end
    return result;
end

-- Method:          GRM.GetRankPermissions(...)
-- What it Does:    Returns an array of booleans, in string form, of all the permissions of the guild rank tagged
-- Purpose:         Useful to keep track of permissions, such as if player has access to guild chat channel. If restricted, sync will not work.
-- GuildControlSetRank ( rankIndex ) needs to be set before using
GRM.GetRankPermissions = function ( ... ) -- Note, Guild Leader = 1, so next highest rank is index = 2 
    local result = {};
    
    for i = 1 , select ( "#" , ... ) do 
        table.insert ( result , tostring ( select ( i , ... ) ) );
    end
    
    return result;
end

-- Method:          GRM.RegisterGuildChatPermission()
-- What it Does:    Returns true of the player has permission to use the guild chat channel.
-- Purpose:         If guild chat channel is restricted then sync cannot be enabled either...
GRM.RegisterGuildChatPermission = function()
    GRMsync.SendMessage ( "GRM_GCHAT" , "" , "GUILD" );
    GRMsync.SendMessage ( "GRM_GCHAT" , "" , "OFFICER");
end

-- Method:          GRM.AddPlayerActiveCheck ( string )
-- What it Does:    Adds the given player to the "Notify when returns to ACTIVE" status.
-- Purpose:         So player can be notified when someone comes back from being AFK!
GRM.AddPlayerActiveCheck = function ( name )
    local isFound = false;
    for i = 1 , #GRM_AddonGlobals.ActiveCheckQue do
        if name == GRM_AddonGlobals.ActiveCheckQue[i] then
            isFound = true;
        end
    end
    
    if not isFound then
        table.insert ( GRM_AddonGlobals.ActiveCheckQue , name );
        chat:AddMessage ( "|cffff0000Notification Set: |cffffd600Report When " .. GRM.SlimName  ( name ) .. " is ACTIVE Again!" );
    else
        print ( "Notification Has Already Been Arranged..." );
    end
end

GRM.AddPlayerOnlineStatusCheck = function ( name )
    local isFound = false;
    for i = 1 , #GRM_AddonGlobals.ActiveStatusQue do
        if name == GRM_AddonGlobals.ActiveStatusQue[i] then
            isFound = true;
        end
    end
    
    if not isFound then
        table.insert ( GRM_AddonGlobals.ActiveStatusQue , name );
        chat:AddMessage ( "|cffff0000Notification Set: |cffffd600Report When " .. GRM.SlimName  ( name ) .. " Comes Online!" );
    else
        print ( "Notification Has Already Been Arranged..." );
    end
end

GRM.AddPlayerOfflineStatusCheck = function ( name )
    local isFound = false;
    for i = 1 , #GRM_AddonGlobals.ActiveStatusQue do
        if name == GRM_AddonGlobals.ActiveStatusQue[i] then
            isFound = true;
        end
    end
    
    if not isFound then
        table.insert ( GRM_AddonGlobals.ActiveStatusQue , name );
        chat:AddMessage ( "|cffff0000Notification Set: |cffffd600Report When " .. GRM.SlimName  ( name ) .. " Goes Offline!" );
    else
        print ( "Notification Has Already Been Arranged..." );
    end
end

GRM.IsGuildieOnline = function ( name )
    GuildRoster();
    local result = false;
    for i = 1 , GRM.GetNumGuildies() do
        local fullName , _, _, _, _, _, _, _, online = GetGuildRosterInfo ( i );
        if name == fullName then
            result = online;
            break;
        end
    end
    return result;
end



-----------------------------------
--------- Version Tracking --------
--------- Addon User Tracking -----
-----------------------------------

-- Method:          VersionCheck ( string )
-- What it Does:    Checks player version compared to another player's and recommends updating your version if needed
-- Purpose:         Encourage the player to keep their addon up to date!
GRM.VersionCheck = function( msg )
    -- parse the message
    local version = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local time = tonumber ( string.sub ( msg , string.find ( msg , "?" ) + 1 ) );

    -- If the versions are not equal and the received data is larger (more recent) than player's time, player should receive reminder to update!
    if version ~= GRM_AddonGlobals.Version then
        if not GRM_AddonGlobals.VersionChecked and time > GRM_AddonGlobals.PatchDay then
            -- Let's report the need to update to the player!
            chat:AddMessage ( "|cff00c8ffGRM: |cffffffffA new version of Guild Roster Manager is Available! |cffff0044Please Upgrade!");
            -- No need to send comm because he has the update, not you!

        elseif time < GRM_AddonGlobals.PatchDay then
            -- Your version is more up to date! Send comms out!
            SendAddonMessage ( "GRMVER" , GRM_AddonGlobals.Version .. "?" .. GRM_AddonGlobals.PatchDayString , "GUILD" ); -- Remember, patch day is an int in epoch time, so needs to be converted to string for comms
        end
    end
end

-- Method:          GRM.RegisterVersionCheck()
-- What it Does:    Registers the logic for comm talk between addon users to do a version check.
-- Purpose:         Version checking! Encourages the player to upgrade their addon if it is outdated!
GRM.RegisterVersionCheck = function()
    -- Registering comm prefix, establishing event monitoring for comm activity across guild channel.
    RegisterAddonMessagePrefix ( "GRMVER" );
    VersionCheck:RegisterEvent ( "CHAT_MSG_ADDON" );
    -- Register used prefixes!

    -- Setup tracking actions
    VersionCheck:SetScript ( "OnEvent" , function( self , event , prefix , msg , channel , sender )
        if event == "CHAT_MSG_ADDON" and prefix == "GRMVER" and channel == "GUILD" then
            -- sender = GRMsync.SyncName ( sender , "enGB" ) -- This will eventually be localized
                -- Gotta filter my own messages out too!
            if sender ~= GRM_AddonGlobals.addonPlayerName then

                -- Just to ensure it only does a check one time from each player with the addon installed.
                local isFound = false;
                for i = 1 , #GRM_AddonGlobals.VersionCheckedNames do
                    if GRM_AddonGlobals.VersionCheckedNames[i] == sender then
                        isFound = true;
                        break;
                    end
                end

                -- Player has never commed on version with you. Add their name, then do a version check!
                if not isFound then
                    table.insert ( GRM_AddonGlobals.VersionCheckedNames , sender );
                    GRM.VersionCheck ( msg );
                end
            end
        end
    end);
end

-- Method:          RegisterGuildAddonUsersRefresh ( boolean )
-- What it Does:    Two uses. One, it checks to see if all the people on the list of users with addon installed are still online, and if not, purges them
--                  and two, requests data from the players again to be updated. This is useful because players may change their settings.
-- Purpose:         To keep the UI up to date. It is necessary to refresh the info occasionally rather than just on login.
GRM.RegisterGuildAddonUsersRefresh = function ()              -- LoadRefresh is just OnShow() for the window, no need to have 10 sec delay as we are not oging to send requests, just purge the offlines.
    -- Purge the players that are no longer online...
    local listOfNames = GRM.GetAllGuildiesOnline( true );
    local notFound = true;

    for i = 1 , #GRM_AddonGlobals.currentAddonUsers do
        notFound = true;
        for j = 1 , #listOfNames do
            if GRM_AddonGlobals.currentAddonUsers[i] ~= nil and listOfNames[j] ~= nil then
                if listOfNames[j] == GRM_AddonGlobals.currentAddonUsers[i][1] then
                    notFound = false;
                    break;
                end
            end
        end
        
        -- if notfound, purge em. They're no longer online...
        if notFound then
            table.remove ( GRM_AddonGlobals.currentAddonUsers , i );
        end
    end
    -- Request the updated info!
    SendAddonMessage ( "GRMUSER" , "REQ?_" , "GUILD" );
    GRM_AddonGlobals.refreshAddonUserDelay = time();

    -- Updating the frames. Giving 2 seconds to receive responses!
    C_Timer.After ( 2 , function()
        GRM.BuildAddonUserScrollFrame();
    end);
end

-- Method:          GRM.AddonUserRegister ( string , string )
-- What it Does:    Analyzes to see if the addon user communicating with you is capable of syncing with you, as you could filter them or they could filter you.
-- Purpose:         Having a UI showing who has the addon, what version, if you can sync is just useful information. Not necessary for addon functionality, but is good for Quality of Life.
GRM.AddonUserRegister = function( sender , msg )
    local rankOfSender = GRM.GetGuildMemberRankID ( sender );
    local playerRankID = GRM.GetGuildMemberRankID ( GRM_AddonGlobals.addonPlayerName )

    -- If rank call fails.
    if rankOfSender == -1 or playerRankID == -1 then
        return;
    end
    local result = "Ok!";

    -- Parsed Data
    local version = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local epochTimeVersion = tonumber ( string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 ) );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local syncOnlyCurrent = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local senderRankRequirement = tonumber ( string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 ) );
    local syncIsEnabled = string.sub ( msg , string.find ( msg , "?" ) + 1 );

    -- Useful logic controls.
    

    -- First, determine if the addon user will sync with you.
    if syncIsEnabled == "true" then
        if rankOfSender > GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] or senderRankRequirement < playerRankID then
            -- Ranks do not sync, let's get it right.
            -- For messaging the reason why.
            if rankOfSender > GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] then
                result = "Rank too Low";
            else
                result = "Your Rank too Low";
            end
        -- Check if versions are outdated as well.
        elseif syncOnlyCurrent == "true" or GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][19] then
            -- If versions are different. Just filtering out unnecessary computations if verisons are the same.
            if epochTimeVersion ~= GRM_AddonGlobals.PatchDay then
                -- If their version is older than yours...
                if epochTimeVersion < GRM_AddonGlobals.PatchDay and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][19] then
                    result = "Outdated Version";
                elseif GRM_AddonGlobals.PatchDay < epochTimeVersion and syncOnlyCurrent == "true" then
                    result = "You Need Updated Version";
                end
            end
        end 
    else
        result = "Player Sync Disabled";
    end
    
    -- Now, let's see if they are already in the table.
    local isFound = false;
    for i = 1 , #GRM_AddonGlobals.currentAddonUsers do
        if GRM_AddonGlobals.currentAddonUsers[i][1] == sender then
            GRM_AddonGlobals.currentAddonUsers[i][2] = result;
            GRM_AddonGlobals.currentAddonUsers[i][3] = version;
            isFound = true;
            break;
        end
    end

    if not isFound then
        table.insert ( GRM_AddonGlobals.currentAddonUsers , { sender , result , version } );
        GRM.RegisterGuildAddonUsersRefresh();
    end
    
end

-- Method           GRM.RegisterGuildAddonUsers()
-- What it Does:    Initiates the event listening for sync'd user addon info
-- Purpose:         So player can see who has the addon installed and if you are good to sync with each other and if not, why not.
GRM.RegisterGuildAddonUsers = function()

    -- Registering frames for event listening.
    RegisterAddonMessagePrefix ( "GRMUSER" );
    AddonUsersCheck:RegisterEvent ( "CHAT_MSG_ADDON" );

    -- Event listening for addon talk on successful event found!
    AddonUsersCheck:SetScript ( "OnEvent" , function( self , event , prefix , msg , channel , sender )
        if event == "CHAT_MSG_ADDON" and prefix == "GRMUSER" and channel == "GUILD" and sender ~= GRM_AddonGlobals.addonPlayerName then
            -- parse out the header
            local header = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
            msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
            if header == "INIT" then
                GRM.AddonUserRegister ( sender , msg );
            elseif header == "REQ" then
                -- player is requesting info again. Sending update!
                SendAddonMessage ( "GRMUSER" , "INIT?" .. GRM_AddonGlobals.Version .. "?" .. GRM_AddonGlobals.PatchDayString .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][19] ) .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] ) .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] ) , "GUILD" );
            end
        end
    end);

    -- Send out initial comms
    -- Name Version , epochTimestamp of update , string version of boolean if player restricts sync only to those with latest version of addon or higher.
    SendAddonMessage ( "GRMUSER" , "INIT?" .. GRM_AddonGlobals.Version .. "?" .. GRM_AddonGlobals.PatchDayString .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][19] ) .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] ) .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] ) , "GUILD" );
    -- Request for their data.
    SendAddonMessage ( "GRMUSER" , "REQ?_" , "GUILD" );
end

-- Method:          GRM.IsNumInString(string) 
-- What it Does:    Returns true if a numerical value is found in the form of a string.
-- Purpose:         Useful for player name submission, to verify if valid formatting.
GRM.IsNumInString = function( text )
    local numFound = false;
    for i = 1 , #text do
        if tonumber ( string.sub ( text , i , i ) ) ~= nil then
            -- NUM FOUND!
            numFound = true;
            break
        end
    end
    return numFound;
end


-- STILL NEED TO COMPLETE OTHER REGIONS!!!!!!!!!!
-- Method:          GRM.IsValidName(string)
-- What it Does:    Returns true if the name only contains valid characters in it...
-- Purpose:         When player is manually adding someone to the player data, we need ot ensure only proper characters are allowed.
GRM.IsValidName = function ( name )
    local result = true;
    name = GRM.Trim ( name ); -- In case any whitespace before or after...

    for i = 1, #name do
        local byteValue = string.byte ( string.sub ( name , i , i ) );

        if GRM_AddonGlobals.FontChoice == "Fonts\\FRIZQT__.TTF" then
            if byteValue ~= 127 and ( ( byteValue > 64 and byteValue < 91 ) or 
            ( byteValue > 96 and byteValue < 123 ) or 
            ( byteValue > 127 and byteValue < 166 ) or 
            ( byteValue > 180 and byteValue < 184 ) or 
            ( byteValue > 197 and byteValue < 200 ) or 
            ( byteValue > 207 and byteValue < 217 ) or 
            ( byteValue > 223 and byteValue < 238 ) ) then
                -- We're good!
            else
                result = false;
                break;
            end
        elseif GRM_AddonGlobals.FontChoice == "Fonts\\FRIZQT___CYR.TTF" then        -- Cyrilic
        
        elseif GRM_AddonGlobals.FontChoice == "FONTS\\2002.TTF" then                -- Korean

        elseif GRM_AddonGlobals.FontChoice == "Fonts\\ARKai_T.TTF" then             -- Mandarin Chinese

        elseif GRM_AddonGlobals.FontChoice == "FONTS\\blei00d.TTF" then             -- Mandarin Taiwanese

        end
    end
    return result;
end

-- Method           GRM.Trim ( string )
-- What it Does:    Removes the white space at front and at tail of string.
-- Purpose:         Cleanup strings for ease of logic control, as needed.
GRM.Trim = function ( str )
    return ( str:gsub ( "^%s*(.-)%s*$" , "%1" ) );
end

-- Method:          GRM.ResetTempLogs()
-- What it Does:    Empties the arrays of the reporting logs
-- Purpose:         Logs are used to build changes in the guild and then to cleanly report them in order.
GRM.ResetTempLogs = function()
    GRM_AddonGlobals.TempNewMember = {};
    GRM_AddonGlobals.TempInactiveReturnedLog = {};
    GRM_AddonGlobals.TempLogPromotion = {};
    GRM_AddonGlobals.TempLogDemotion = {};
    GRM_AddonGlobals.TempLogLeveled = {};
    GRM_AddonGlobals.TempLogNote = {};
    GRM_AddonGlobals.TempLogONote = {};
    GRM_AddonGlobals.TempRankRename = {};
    GRM_AddonGlobals.TempRejoin = {};
    GRM_AddonGlobals.TempBannedRejoin = {};
    GRM_AddonGlobals.TempLeftGuild = {};
    GRM_AddonGlobals.TempNameChanged = {};
    GRM_AddonGlobals.TempEventReport = {};
    GRM_AddonGlobals.TempEventRecommendKickReport = {};
end

-- Method:          GRM.ModifyCustomNote(string,string)
-- What it Does:    Adds a new note to the custom notes string
-- Purpose:         For expanded information on players to create in-game notes or tracking.
GRM.ModifyCustomNote = function ( newNote , playerName )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                       -- Scanning through guild Roster
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then       -- Player Found
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][23] = newNote;             -- Storing new note.
            break;
        end
    end
end

------------------------------------
------ TIME TRACKING TOOLS ---------
--- TIMESTAMPS , TIMEPASSED, ETC. --
------------------------------------


-- Method:          GRM.IsLeapYear(int)
-- What it Does:    Returns true if the given year is a leapYear
-- Purpose:         For this addon, the calendar date selection, allows it to know to produce 29 days on leap year.
GRM.IsLeapYear = function ( yearDate )
    if ( ( ( yearDate % 4 == 0 ) and ( yearDate % 100 ~= 0 ) ) or ( yearDate % 400 == 0 ) ) then
        return true;
    else
        return false;
    end
end

-- Method:          GRM.GetHoursSinceLastOnline(int)
-- What it Does:    Returns the total numbner of hours since the player last logged in at given index position of guild roster
-- Purpose:         For player management to notify addon user of too much time has passed, for recommendation to kick,
GRM.GetHoursSinceLastOnline = function ( index )
    local years , months, days, hours = GetGuildRosterLastOnline ( index );
    if years == nil then
        years = 0;
    end
    if months == nil then
        months = 0;
    end
    if days == nil then
        days = 0;
    end
    if hours == nil then
        hours = 0;
    end
    if ( years == 0 ) and ( months == 0 ) and ( days == 0 ) and ( hours == 0) then
        hours = 0.5;    -- This can be any value less than 1, but must be between 0 and 1, to just make the point that total number of hrs since last login is < 1
    end
    local totalHours = math.floor ( ( years * 8766 ) + ( months * 730 ) + ( days * 24 ) + hours );
    return totalHours;
end

-- Method:          GRM.IsValidSubmitDate ( int , int , boolean )
-- What it Does:    Returns true if the submission date is valid (not an untrue day or in the future)
-- Purpose:         Check to ensure the wrong date is not submitted on accident.
GRM.IsValidSubmitDate = function ( daySelected , monthSelected , yearSelected , IsLeapYearSelected )
    local closeButtons = true;
    local _ , month , day , year = CalendarGetDate()
    local numDays;

    if monthSelected == 1 or monthSelected == 3 or monthSelected == 5 or monthSelected == 7 or monthSelected == 8 or monthSelected == 10 or monthSelected == 12 then
        numDays = 31;
    elseif monthSelected == 2 and IsLeapYearSelected then
        numDays = 29;
    elseif monthSelected == 2 then
        numDays = 28;
    else
        numDays = 30;
    end
    if daySelected > numDays then
        closeButtons = false;
    end
    
    if closeButtons then
        if ( year < yearSelected ) or ( year == yearSelected and month < monthSelected ) or ( year == yearSelected and month == monthSelected and day < daySelected ) then
            print ( "Player Does Not Have a Time Machine!" );
            closeButtons = false;
        end
    end

    if closeButtons == false then
        print ( "Please choose a valid DAY" );
    end
    return closeButtons;
end

-- Method:          GRM.TimeStampToEpoch(timestamp)
-- What it Does:    Converts a given timestamp: "22 Mar '17" into Epoch Seconds time.
-- Purpose:         On adding notes, epoch time is considered when calculating how much time has passed, for exactness and custom dates need to include it.
GRM.TimeStampToEpoch = function ( timestamp )
    -- Parsing Timestamp to useful data.
    local year = tonumber ( string.sub ( timestamp , string.find ( timestamp , "'" )  + 1 ) ) + 2000;
    local leapYear = GRM.IsLeapYear ( year );
    -- Find second index of spaces
    local count = 0;
    local index = 0;
    local dayInd = -1;
    for i = 1 , #timestamp do
        if string.sub( timestamp , i , i ) == " " then
            count = count + 1;
        end
        if count == 1 and dayInd == -1 then
            dayInd = i;
        end
        if count == 2 then
            index = i;
            break;
        end
    end
    local month = monthEnum [ string.sub ( timestamp , index + 1 , index + 3) ];
    local day = tonumber ( string.sub ( timestamp , dayInd + 1 , index - 1 ) );

    -- End timestamp Parsing... 
    local hour , minute = GetGameTime();
    local tempTime = date ( '*t' );
    local seconds = tempTime.sec;

    -- calculate the number of seconds passed since 1970 based on number of years that have passed.
    local totalSeconds = 0;
    for i = year - 1 , 1970 , -1 do
        if GRM.IsLeapYear ( i ) then
            totalSeconds = totalSeconds + ( 366 * 24 * 3600 ); -- leap year = 366 days
        else
            totalSeconds = totalSeconds + ( 365 * 24 * 3600 ); -- 365 days in normal year
        end
    end
    
    -- Now lets calculate how much time this year...
    local monthDays = daysBeforeMonthEnum [ tostring ( month ) ];
    if month > 2 and leapYear then -- Adding 1 for the leap year
        monthDays = monthDays + 1;
    end
    -- adding month days so far this year to result so far.
    totalSeconds = totalSeconds + ( monthDays * 24 * 3600);

    -- The rest is easy... as of now, I will not import hours/minutes/seconds, but I will leave the calculations in place in case need arises.
    totalSeconds = totalSeconds + ( ( day - 1 ) * 24 * 3600 );  -- days
    totalSeconds = totalSeconds + ( hour * 3600 );
    totalSeconds = totalSeconds + ( minute * 60 );
    totalSeconds = totalSeconds + seconds;
    
    return totalSeconds;
end


-- Method:          GRM.GetTimestamp()
-- What it Does:    Reports the current moment in time in a much more clear, concise, pretty way. Example: "9 Feb '17 1:36pm" instead of 09/02/2017/13:36
-- Purpose:         Just for cleaner presentation of the results. Also, need to report based on server time. In-game API only returns hour/min, not month and day. This resolves that.
GRM.GetTimestamp = function()
    -- Time Variables
    local morning = true;
    local months = { "Jan" , "Feb" , "Mar" , "Apr" , "May" , "Jun" , "Jul" , "Aug" , "Sep" , "Oct" , "Nov" , "Dec" };
    local hour, minutes = GetGameTime();
    local weekday, month, day, year = CalendarGetDate();
    local stampMonth = months [ month ];

    -- Formatting...
    if minutes < 10 then
        minutes = ( "0" .. minutes ); -- Example, if it was 6:09, the minutes would only be "9" not "09" - so this looks better.
    end
     -- Swap from military time
    if hour > 12 then
        hour = hour - 12;
        morning = false;
    elseif hour == 12 then
        morning = false;
    elseif hour == 0 then
        hour = 12;
    end

    year = tostring ( year );
    year = string.sub ( year , 3 );
   
    -- Establishing proper format
    local time = ( day .. " " .. stampMonth .. " '" .. year .. " " .. hour .. ":" .. minutes );
    if morning then
        time =  ( time .. "am" );
    else
        time =  ( time .. "pm" );
    end
    return time;
end

-- Method:          GRM.GetTimePassed ( oldTimestamp )
-- What it Does:    Reports back the elapsed, in English, since the previous given timestamp, based on the 1970 seconds count.
-- Purpose:         Time tracking to keep track of elapsed time since previous action.
GRM.GetTimePassed = function ( oldTimestamp )

    -- Need to consider Leap year, but for now, no biggie. 24hr differentiation only in 4 years.
    local totalSeconds = time() - oldTimestamp;
    local year = math.floor ( totalSeconds / 31536000 ); -- seconds in a year
    local yearTag = "year";
    local month = math.floor ( ( totalSeconds % 31536000 ) / 2592000 ); -- etc. 
    local monthTag = "month";
    local days = math.floor ( ( totalSeconds % 2592000) / 86400 );
    local dayTag = "day";
    local hours = math.floor ( ( totalSeconds % 86400 ) / 3600 );
    local hoursTag = "hour";
    local minutes = math.floor ( ( totalSeconds % 3600 ) / 60 );
    local minutesTag = "minute";
    local seconds = math.floor ( ( totalSeconds % 60) );
    local secondsTag = "second";
    
    local timestamp = "";
    if year > 1 then
        yearTag = "years";
    end
    if month > 1 then
        monthTag = "months";
    end
    if days > 1 then
        dayTag = "days";
    end
    if hours > 1 then
        hoursTag = "hours";
    end
    if minutes > 1 then
        minutesTag = "minutes";
    end
    if seconds > 1 then
        secondsTag = "seconds";
    end

    if year > 0 or month > 0 or days > 0 then
        if year > 0 then
            timestamp = ( year .. " " .. yearTag );
        end
        if month > 0 then
            timestamp = ( timestamp .. " " .. month .. " " .. monthTag );
        end
        if days > 0 then
            timestamp = ( timestamp .. " " .. days .. " " .. dayTag );
        else
            timestamp = ( timestamp .. " " .. days .. " " .. "days" ); -- exception to put zero days since it seems smoother, aesthetically.
        end
    else
        if hours > 0 or minutes > 0 then
            if hours > 0 then
                timestamp = ( timestamp .. " " .. hours .. " " .. hoursTag );
            end
            if minutes > 0 then
                timestamp = ( timestamp .. " " .. minutes .. " " .. minutesTag );
            end
        else
            timestamp = ( seconds .. " " .. secondsTag );
        end
    end
    
    return timestamp;
end

-- Method:          GRM.EpochToDateFormat( int )
-- What it Does:    It takes an epoch timestamp and converts it into a string format as desired.
-- Purpose:         Epoch is very exact, to the second. It is nice to store that info than hard to interpret, non-mathematical text, for a computer. \
--                  This is just easy formatting for human consumption
GRM.EpochToDateFormat = function ( epochstamp )
    local timeTable = date( "*t" , epochstamp );
    local day = tostring ( timeTable.day );
    local month = monthEnum2 [ '' .. timeTable.month .. '' ];
    local year = string.sub ( tostring ( timeTable.year ) , 3 );    
    
    return ( day .. " " .. month .. " '" .. year );
end

-- Method:          GRM.GetTimePassedUsingStringStamp()
-- What it Does:    Returns the Years, hours, and days that have passed since the given timestamp ( In format "day mon 'year")
-- Purpose:         Honestly, simpler solution than build a solution to parse through epoch time, since I don't need hours, minutes, seconds.
GRM.GetTimePassedUsingStringStamp = function ( timestamp )
    local startYear = tonumber ( string.sub ( timestamp , string.find ( timestamp , "'" )  + 1 ) ) + 2000;
    local index = string.find ( timestamp , " " );
    local monthName = string.sub ( timestamp , index + 1 , index + 3 );
    local startMonth = monthEnum [ monthName ];
    local startDay = tonumber ( string.sub ( timestamp , 0 , index - 1 ) );
    local _ , month , day , year = CalendarGetDate();
    local LeapYear = GRM.IsLeapYear ( year );
    local result = { 0 , 0 , 0 , "" };           -- resultYear, resultMonth , resultDay;
    -- Narrow down the year!
    if year > startYear then                -- If this event happened in a previous year.
        result[1] = year - startYear;
        if month < startMonth then          -- Event is less than a year!
            result[1] = result[1] - 1;
        elseif month == startMonth then
            -- Need to check the day!
            if day < startDay then
                result[1] = result[1] - 1;
            else
                result[1] = year - startYear;   -- If >= then it counts as 1 year.
            end
        else                                -- month > start meaning it's been a year.
            result[1] = year - startYear;
        end
    else
        result[1] = 0;
    end

    -- Ok, now let's get the month! Much easier!
    if month < startMonth then
        result[2] = month + ( 12 - startMonth );
        if day < startDay then          -- Not quite 1 month
            result[2] = result[2] - 1;
        end
    elseif month == startMonth then
        if startYear == year then
            result[2] = 0;
        else
            if day < startDay then
                result[2] = 11;
            else
                result[2] = 0;
            end
        end
    else                        -- month > start 
        if day < startDay then
            result[2] = ( month - startMonth ) - 1;
        else
            result[2] = month - startMonth;
        end
    end

    -- Finally, let's do the day!
    if day < startDay then
        -- Gonna have to take leap year into account now!
        local tempMonth = month;
        if tempMonth == 12 then
            tempMonth = 1;
        end
        result[3] = day + ( daysInMonth [ tostring ( tempMonth ) ] - startDay );
        if LeapYear then
            result[3] = result[3] + 1;
        end
    else
        result[3] = day - startDay;
    end

    --Final text report
    if result[1] > 0 then
        if result[1] == 1 then
            result[4] = result[1] .. " year ";
        else
            result[4] =  result[1] .. " years ";
        end
    end
    if result[2] > 0 then
        if result[2] == 1 then
            result[4] = result[4] .. "" .. result[2] .. " month ";
        else
            result[4] = result[4] .. "" .. result[2] .. " months ";
        end
    end
    if result[3] > 0 then
        if result[3] == 1 then
            result[4] = result[4] .. "" .. result[3] .. " day";
        else
            result[4] = result[4] .. "" .. result[3] .. " days";
        end
    end
    -- Clear off any white space.
    if result[1] == 0 and result[2] == 0 and result[3] == 0 then
        result[4] = "< 1 day";
    else
        result[4] = GRM.Trim ( result[4] );
    end
    return result;
end

-- Method:          GRM.HoursReport(int)
-- What it Does:    Reports as a string the time passed since player last logged on.
-- Purpose:         Cleaner reporting to the log, and it just reports the lesser info, no seconds and so on.
GRM.HoursReport = function ( hours )
    local result = "";
    local years = math.floor ( hours / 8766 );
    local months = math.floor ( ( hours % 8766 ) / 730.5 );
    local days = math.floor ( ( hours % 730.5 ) / 24 );

    -- Continue calculations.
    local hours = math.floor ( ( ( hours % 8760 ) % 730 ) % 24 );
    
    
    if years >= 1 then
        if years > 1 then
            result = result .. "" .. years .. " yrs ";
        else
            result = result .. "" .. years .. " yr ";
        end
    end

    if months >= 1 then
        if years > 0 then
            result = GRM.Trim ( result ) .. ", ";
        end
        if months > 1 then
            result = result .. "" .. months .. " mos ";
        else
            result = result .. "" .. months .. " mo ";
        end
    end

    if days >= 1 then
        if months > 0 then
            result = GRM.Trim ( result ) .. ", ";
        end
        if days > 1 then
            result = result .. "" .. days .. " days ";
        else
            result = result .. "" .. days .. " day ";
        end
    end

    if hours >= 1 and years < 1 and months < 1 then  -- No need to give exact hours on anything over than a month, just the day is good enough.
        if days > 0 then
            result = GRM.Trim ( result ) .. ", ";
        end
        if hours > 1 then
            result = result .. "" .. hours .. " hrs";
        else
            result = result .. "" .. hours .. " hr";
        end
    end

    if result == "" or result == nil then
        result = result .. "< 1 hour"
    end
    return result;
end

------------------------------------
------ END OF TIME METHODS ---------
------------------------------------


------------------------------------
---- ALT MANAGEMENT METHODS --------
------------------------------------

-- Method:                  GRM.GetRosterName ( fontstring , fontstring )
-- What it Does:            Gets the player's full server name based on the mouseover position of the roster frames
-- Purpose:                 In patch 7.3 players can no longer use :Click() on roster buttons to initiate selection and pull the data.
GRM.GetRosterName = function( fontstring1 , fontstring2 , buttonIndex )
    local name = "";
    local MobileIconCheck = "";
    local length = 84;
    local playerStatusScreen = false;
    local result = "";

    -- If true, then we know we are on "Player Status Screen" -- I could probably just check if we are?
    if tonumber ( GuildRosterContainerButton1String1:GetText() ) ~= nil then
        playerStatusScreen = true;
        MobileIconCheck = "\"" .. fontstring1:GetText() .. "\"";
        if #MobileIconCheck > 50 then
            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                length = 85
            end
            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
        else
            name = fontstring1:GetText();
        end
    else
        MobileIconCheck = "\"" .. fontstring2:GetText() .. "\"";
        if #MobileIconCheck > 50 then
            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                length = 85
            end
            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
        else
            name = fontstring2:GetText();
        end
    end

    -- Now, we need to determine if there are more than 1 persons in the guild with this name!
    local tempListNames = {};

    for i = 1 , GRM.GetNumGuildies() do
        local fullName, rank, _, level, class, zone, note, isOnline = GetGuildRosterInfo ( i );
        local tempTable = { fullName , rank , level , class , zone , note , isOnline , i };                        -- Add the player details to a temp array
        -- If the text string matches a guild member name, then add it. We will know if there is more than 1 player in a merged realm with the same name
        if name == GRM.SlimName ( fullName ) or ( string.find ( name , "-" ) ~= nil and name == fullName ) then                                                      
            table.insert ( tempListNames , tempTable );
        end
    end

    -- Ok, are there any matches?
    if #tempListNames == 1 then
        -- SetGuildRosterSelection ( tempListNames[1][7] );      
        result = tempListNames[1][1];
    elseif #tempListNames == 0 then
        -- Unable to identify name...
        -- This should never happen, but I am adding this note just in case I need to come back here...
    end
    return result;
end

-- DEPRECATED DUE TO TAINT AS OF PATCH 7.3!!!!!!!!!!
-- Method:          GRM.GetMouseOverName()
-- What it Does:    Returns the full player's name with server on mouseover
-- Purpose:         Name needed to check metadata to populate UI window.
GRM.GetMouseOverName = function( button )
    -- This disables the annoying mouseover sound.
    local isSoundEnabled = ( GetCVar ( "Sound_EnableAllSound") == "1" );
    SetCVar ( "Sound_EnableAllSound" , false );
    button:Click();
    button:UnlockHighlight();
    SetCVar ( "Sound_EnableAllSound" , isSoundEnabled );

    local name = GRM_AddonGlobals.currentName;
    local MobileIconCheck = "\"" .. name .. "\"";
    local length = 84;

    if #MobileIconCheck > 50 then
        if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
            length = 85
        end
        name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
    end
    return name;
end

-- Method:          GRM.GetMobileFreeName()
-- What it Does:    Returns the cleared name properly as if player is on mobile the string will not pass through data right.
-- Purpose:         String name has an icon attached. This resolves that.
GRM.GetMobileFreeName = function ( name )
    if name == nil or name == "" then
        name = "";
        return name;
    else
        local MobileIconCheck = "\"" .. name .. "\"";
        local length = 84;

        if #MobileIconCheck > 50 then
            if string.sub ( MobileIconCheck , length - 1 , length - 1 ) ~= "t" then
                length = 85
            end
            name = string.sub ( MobileIconCheck , length , #MobileIconCheck - 1 );
        end
    end
    return name;
end

-- Method:          GRM.AltButtonPos(int)
-- What it Does:    Returns the horizontal and vertical coordinates for the button position on frame
-- Purpose:         To adjust the position of the AddAlt button based on the number of alts.
GRM.AltButtonPos = function ( index )
    local result;
    if index == 0 then
        result = { 2 , -16 };
    elseif index == 1 then
        result = { 32 , -20 };
    elseif index == 2 then
        result = { -32 , -37 };
    elseif index == 3 then
        result = { 32 , -37 };
    elseif index == 4 then
        result = { -32 , -54 };
    elseif index == 5 then
        result = { 32 , -54 };
    elseif index == 6 then
        result = { -32 , -71 };
    elseif index == 7 then
        result = { 32 , -71 };
    elseif index == 8 then
        result = { -32 , -88 };
    elseif index == 9 then
        result = { 32 , -88 };
    elseif index == 10 then
        result = { -32 , -103 };
    elseif index == 11 then
        result = { 32 , -103 };
    else -- is 12+ alts
        result = { -64 , -124 };
    end
    return result;
end

-- Method:          GRM.PopulateAltFrames(string, int , int )
-- What it Does:    This generates the alt frames in the main addon metadata detail frame
-- Purpose:         Clean formatting of the alt frames.
GRM.PopulateAltFrames = function ( index1 )
    -- let's start by prepping the frames.
    local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11];
    local numAlts = #listOfAlts

    if numAlts < 13 then
        local butPos = GRM.AltButtonPos ( numAlts );
        GRM_AddAltButton:SetPoint ( "TOP" , GRM_CoreAltFrame , butPos[1] , butPos[2] );
        GRM_AddAltButton:Show();
        GRM_CoreAltScrollFrame:Hide();
        -- now, let's populate them
        if numAlts > 0 then
            local result = GRM.SlimName ( listOfAlts[1][1] );
            if listOfAlts[1][5] == true then  --- this person is the main!
                result = result .. "\n|cffff0000(main)"
            end
            GRM_AltName1:SetText ( result );
            GRM_AltName1:SetTextColor ( listOfAlts[1][2] , listOfAlts[1][3] , listOfAlts[1][4] , 1.0 );
            GRM_AltName1:Show();
        else
            GRM_AltName1:Hide();
        end
        if numAlts > 1 then
            GRM_AltName2:SetText ( GRM.SlimName ( listOfAlts[2][1] ) );
            GRM_AltName2:SetTextColor ( listOfAlts[2][2] , listOfAlts[2][3] , listOfAlts[2][4] , 1.0 );
            GRM_AltName2:Show();
        else
            GRM_AltName2:Hide();
        end
        if numAlts > 2 then
            GRM_AltName3:SetText ( GRM.SlimName ( listOfAlts[3][1] ) );
            GRM_AltName3:SetTextColor ( listOfAlts[3][2] , listOfAlts[3][3] , listOfAlts[3][4] , 1.0 );
            GRM_AltName3:Show();
        else
            GRM_AltName3:Hide();
        end
        if numAlts > 3 then
            GRM_AltName4:SetText ( GRM.SlimName ( listOfAlts[4][1] ) );
            GRM_AltName4:SetTextColor ( listOfAlts[4][2] , listOfAlts[4][3] , listOfAlts[4][4] , 1.0 );
            GRM_AltName4:Show();
        else
            GRM_AltName4:Hide();
        end
        if numAlts > 4 then
            GRM_AltName5:SetText ( GRM.SlimName ( listOfAlts[5][1] ) );
            GRM_AltName5:SetTextColor ( listOfAlts[5][2] , listOfAlts[5][3] , listOfAlts[5][4] , 1.0 );
            GRM_AltName5:Show();
        else
            GRM_AltName5:Hide();
        end
        if numAlts > 5 then
            GRM_AltName6:SetText ( GRM.SlimName ( listOfAlts[6][1] ) );
            GRM_AltName6:SetTextColor ( listOfAlts[6][2] , listOfAlts[6][3] , listOfAlts[6][4] , 1.0 );
            GRM_AltName6:Show();
        else
            GRM_AltName6:Hide();
        end
        if numAlts > 6 then
            GRM_AltName7:SetText ( GRM.SlimName ( listOfAlts[7][1] ) );
            GRM_AltName7:SetTextColor ( listOfAlts[7][2] , listOfAlts[7][3] , listOfAlts[7][4] , 1.0 );
            GRM_AltName7:Show();
        else
            GRM_AltName7:Hide();
        end
        if numAlts > 7 then
            GRM_AltName8:SetText ( GRM.SlimName ( listOfAlts[8][1] ) );
            GRM_AltName8:SetTextColor ( listOfAlts[8][2] , listOfAlts[8][3] , listOfAlts[8][4] , 1.0 );
            GRM_AltName8:Show();
        else
            GRM_AltName8:Hide();
        end
        if numAlts > 8 then
            GRM_AltName9:SetText ( GRM.SlimName ( listOfAlts[9][1] ) );
            GRM_AltName9:SetTextColor ( listOfAlts[9][2] , listOfAlts[9][3] , listOfAlts[9][4] , 1.0 );
            GRM_AltName9:Show();
        else
            GRM_AltName9:Hide();
        end
        if numAlts > 9 then
            GRM_AltName10:SetText ( GRM.SlimName ( listOfAlts[10][1] ) );
            GRM_AltName10:SetTextColor ( listOfAlts[10][2] , listOfAlts[10][3] , listOfAlts[10][4] , 1.0 );
            GRM_AltName10:Show();
        else
            GRM_AltName10:Hide();
        end
        if numAlts > 10 then
            GRM_AltName11:SetText ( GRM.SlimName ( listOfAlts[11][1] ) );
            GRM_AltName11:SetTextColor ( listOfAlts[11][2] , listOfAlts[11][3] , listOfAlts[11][4] , 1.0 );
            GRM_AltName11:Show();
        else
            GRM_AltName11:Hide();
        end
        if numAlts > 11 then
            GRM_AltName12:SetText ( GRM.SlimName ( listOfAlts[12][1] ) );
            GRM_AltName12:SetTextColor ( listOfAlts[12][2] , listOfAlts[12][3] , listOfAlts[12][4] , 1.0 );
            GRM_AltName12:Show();
        else
            GRM_AltName12:Hide();
        end
    
    else

        --- ALT SCROLL FRAME IF PLAYER HAS MORE THAN 12 ALTS!!!
        GRM_AddAltButton:Hide();
        GRM_AltName1:Hide();GRM_AltName2:Hide();GRM_AltName3:Hide();GRM_AltName4:Hide();GRM_AltName5:Hide();GRM_AltName6:Hide();GRM_AltName7:Hide();
        GRM_AltName8:Hide();GRM_AltName9:Hide();GRM_AltName10:Hide();GRM_AltName11:Hide();GRM_AltName12:Hide();
        GRM_CoreAltScrollFrame:Show();
        GRM_CoreAltScrollChildFrame:Show();
        local scrollHeight = 0;
        local scrollWidth = 128;
        local buffer = 1;

        GRM_CoreAltScrollChildFrame.allFrameButtons = GRM_CoreAltScrollChildFrame.allFrameButtons or {};  -- Create a table for the Buttons.
        -- populating the window correctly.
        for i = 1 , numAlts do
            --GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11]
            -- if font string is not created, do so.
            if not GRM_CoreAltScrollChildFrame.allFrameButtons[i] then
                local tempButton = CreateFrame ( "Button" , "GRM_AltAdded" .. i , GRM_CoreAltScrollChildFrame ); -- Names each Button 1 increment up
                GRM_CoreAltScrollChildFrame.allFrameButtons[i] = { tempButton , tempButton:CreateFontString ( "GRM_AltAddedText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) };
            end

            if i == numAlts and #GRM_CoreAltScrollChildFrame.allFrameButtons > numAlts then
                for j = numAlts + 1 , #GRM_CoreAltScrollChildFrame.allFrameButtons do
                    GRM_CoreAltScrollChildFrame.allFrameButtons[j][1]:Hide();
                end
            end

            local AltButtons = GRM_CoreAltScrollChildFrame.allFrameButtons[i][1];
            local AltButtonsText = GRM_CoreAltScrollChildFrame.allFrameButtons[i][2];
            AltButtons:SetWidth ( 65 );
            AltButtons:SetHeight ( 15 );
            AltButtons:RegisterForClicks( "RightButtonDown" , "LeftButtonDown" );

            -- Check if main
            local result = GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][ index1 ][11][i][1] );
            if i == 1 then
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][ index1 ][11][i][5] == true then  --- this person is the main!
                    result = result .. "\n|cffff0000(main)"
                    AltButtonsText:SetWordWrap ( true );
                end
            else
                AltButtonsText:SetWordWrap ( false );
            end
            AltButtonsText:SetText ( result );
            AltButtonsText:SetTextColor ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][ index1 ][11][i][2] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][ index1 ][11][i][3] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][ index1 ][11][i][4] , 1.0 );
            AltButtonsText:SetWidth ( 63 );
            
            AltButtonsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 7.5 );
            AltButtonsText:SetPoint ( "CENTER" , AltButtons );
            AltButtonsText:SetJustifyH ( "CENTER" );

            -- Logic
            AltButtons:SetScript ( "OnClick" , function ( self , button )
                if button == "RightButton" then
                    -- Parse the button number, so the alt position can be identified...
                    local altNum;
                    local isMain = false;
                    if tonumber ( string.sub ( AltButtons:GetName() , #AltButtons:GetName() - 1 ) ) ~= nil then
                        altNum = tonumber ( string.sub ( AltButtons:GetName() , #AltButtons:GetName() - 1 ) );
                    else
                        altNum = tonumber ( string.sub ( AltButtons:GetName() , #AltButtons:GetName() ) );
                    end

                    -- Ok, populate the buttons properly...
                    GRM_AddonGlobals.pause = true;
                    local cursorX , cursorY = GetCursorPosition();
                    GRM_altDropDownOptions:ClearAllPoints();
                    GRM_altDropDownOptions:SetPoint( "TOPLEFT" , UIParent , "BOTTOMLEFT" , cursorX , cursorY );

                    if string.find ( AltButtonsText:GetText() , "(main)" ) == nil then
                        GRM_altSetMainButtonText:SetText ( "Set as Main" );
                        GRM_altOptionsText:SetText ( AltButtonsText:GetText() );
                    else -- player IS the main... place option to Demote From Main rahter than set as main.
                        GRM_altSetMainButtonText:SetText ( "Set as Alt" );
                        isMain = true;
                        GRM_altOptionsText:SetText ( string.sub ( AltButtonsText:GetText() , 1 , string.find ( AltButtonsText:GetText() , "\n" ) - 1 ) );
                    end

                    
                    local width = 70;
                    if GRM_altOptionsText:GetStringWidth() + 15 > width then       -- For scaling the frame based on size of player name.
                        width = GRM_altOptionsText:GetStringWidth() + 15;
                    end
                    GRM_altDropDownOptions:SetSize ( width , 92 );
                    GRM_altDropDownOptions:Show();

                    GRM_altRemoveButtonText:SetText ( "Remove" );

                    -- Set the Global info now!
                    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == GRM_AddonGlobals.currentName then
                            GRM_AddonGlobals.selectedAlt = { GRM_AddonGlobals.currentName , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][altNum][1] , GRM_AddonGlobals.guildName , isMain };
                            break;
                        end
                    end
                elseif button == "LeftButton" then
                    if GRM_MemberDetailServerNameToolTip:IsVisible() then
                        -- This makes the main window the alt that was clicked on! TempAltName is saved when mouseover action occurs.
                        if GRM_AddonGlobals.tempAltName ~= "" then
                            GRM.SelectPlayerOnRoster ( GRM_AddonGlobals.tempAltName );
                        end
                    end
                end
            end);
            
            -- Now let's pin it!
            if i == 1 then
                AltButtons:SetPoint( "TOPLEFT" , GRM_CoreAltScrollChildFrame , 0 , - 1 );
                scrollHeight = scrollHeight + AltButtons:GetHeight();
            elseif i == 2 then
                AltButtons:SetPoint( "TOPLEFT" , GRM_CoreAltScrollChildFrame.allFrameButtons[i - 1][1] , "TOPRIGHT" , 1 , 0 );
            else
                AltButtons:SetPoint( "TOPLEFT" , GRM_CoreAltScrollChildFrame.allFrameButtons[i - 2][1] , "BOTTOMLEFT" , 0 , - buffer );
                if i % 2 ~= 0 then
                    scrollHeight = scrollHeight + AltButtons:GetHeight() + buffer;
                end
            end
            -- Ok, let's place the button now!
            if i == numAlts then
                GRM_AddAltButton2:SetPoint( "TOPLEFT" , GRM_CoreAltScrollChildFrame.allFrameButtons[numAlts - 1][1] , "BOTTOMLEFT" , 0 , - buffer );
                if numAlts % 2 == 0 then
                    scrollHeight = scrollHeight + AltButtons:GetHeight() + buffer;
                end
                GRM_AddAltButton2:Show();
            end
            AltButtons:Show();
        end

        

        -- Update the size -- it either grows or it shrinks!
        GRM_CoreAltScrollChildFrame:SetSize ( scrollWidth , scrollHeight );

        --Set Slider Parameters ( has to be done after the above details are placed )
        local scrollMax = ( scrollHeight - 90 ) + ( buffer * .5 );
        if scrollMax < 0 then
            scrollMax = 0;
        end
        
        GRM_CoreAltScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
        -- Mousewheel Scrolling Logic
        GRM_CoreAltScrollFrame:EnableMouseWheel( true );
        GRM_CoreAltScrollFrame:SetScript( "OnMouseWheel" , function( self , delta )
            local current = GRM_CoreAltScrollFrameSlider:GetValue();
            
            if IsShiftKeyDown() and delta > 0 then
                GRM_CoreAltScrollFrameSlider:SetValue ( 0 );
            elseif IsShiftKeyDown() and delta < 0 then
                GRM_CoreAltScrollFrameSlider:SetValue ( scrollMax );
            elseif delta < 0 and current < scrollMax then
                GRM_CoreAltScrollFrameSlider:SetValue ( current + 20 );
            elseif delta > 0 and current > 1 then
                GRM_CoreAltScrollFrameSlider:SetValue ( current - 20 );
            end
        end);

        
    end
    GRM_CoreAltFrame:Show();
end

-- Method:          GRM.GetClassColorRGB ( string )
-- What it Does:    Returns the 0-1 RGB color scale for the player class
-- Purpose:         Easy class color tagging for UI feature.
GRM.GetClassColorRGB = function ( className )
    local result = {};
     if className == "DEATHKNIGHT" then
        result = { 0.77 , 0.12 , 0.23 }
    elseif className == "DEMONHUNTER" then
        result = { 0.64 , 0.19 , 0.79 }
    elseif className == "DRUID" then
        result = { 1.0 , 0.49 , 0.04 }
    elseif className == "HUNTER" then
        result = { 0.67 , 0.83 , 0.45 }
    elseif className == "MAGE" then
        result = { 0.41 , 0.80 , 0.94 }
    elseif className == "MONK" then
        result = { 0.0 , 1.0 , 0.59 }
    elseif className == "PALADIN" then
        result = { 0.96 , 0.55 , 0.73 }
    elseif className == "PRIEST" then
        result = { 1.0 , 1.0 , 1.0 }
    elseif className == "ROGUE" then
        result = { 1.0 , 0.96 , 0.41 }
    elseif className == "SHAMAN" then
        result = { 0.0 , 0.44 , 0.87 }
    elseif className == "WARLOCK" then
        result = { 0.58 , 0.51 , 0.79 }
    elseif className == "WARRIOR" then
        result = { 0.78 , 0.61 , 0.43 }
    end
    return result;
end

-- Method:          GRM.RemoveAlt(string , string , string , boolean , int )
-- What it Does:    Detags the given altName to that set of toons.
-- Purpose:         Alt management, so whoever has addon installed can tag player.
GRM.RemoveAlt = function ( playerName , altName , guildName , isSync , syncTimeStamp )
    local isRemoveMain = false;
    local epochTime;
    if isSync then
        epochTime = syncTimeStamp;
    else
        epochTime = time();
    end

    if playerName ~= altName then
        local index1;
        local altIndex1;
        local count = 0;

        -- This block is mainly for resource efficiency, to prevent the blocks from getting too nested, and to store index location for quick access.
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do      
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then        -- Identify position of player
                count = count + 1;
                index1 = j;
            end
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == altName then           -- Pull altName to attach class on Color
                count = count + 1;
                altIndex1 = j;
                -- Need to preserve the list, in the case of syncing to live update the frames if they are on the alt of the alt.
                if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                    GRM_AddonGlobals.selectedAltList = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];
                end
                if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 1 and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] then -- No need to report if the person is removing the last alt. No need to set oneself as main.
                    isRemoveMain = true;
                end
            end
            if count == 2 then
                break;
            end
        end

        -- Removing the alt from all of the player's alts.'
        local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11];
        if #listOfAlts > 0 then                                                                                                     -- There is more than 1 alt for new alt to be added to
            for i = 1 , #listOfAlts do
                if listOfAlts[i][1] ~= altName then                                                                                 -- Cycle through previously known alt names to add new on each, one by one.
                    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                                                             -- Need to now cycle through all toons in the guild to set the alt
                        if listOfAlts[i][1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then                                       -- name on current focus altList found in the metadata and is not the alt to be removed.
                            -- Now, we have the list!
                            for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] do
                                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][1] == altName then
                                    table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][37] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m] ) -- Adding the alt to removed alts list
                                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][37][ #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][37] ][6] = epochTime;
                                    table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] , m );     -- removing the alt
                                    break;
                                end
                            end
                            break;
                        end
                    end
                end
            end
        end
        -- Remove the alt name from the current focus
        for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11][i][1] == altName then
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][37] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11][i] ) -- Adding the alt to removed alts list
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][37][ #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][37] ][6] = epochTime;
                table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11] , i );
                break;
            end
        end
        -- Resetting the alt's list
        if isRemoveMain then 
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex1][10] = false;
        end
        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex1][11] = nil;
        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex1][11] = {};
        -- Insta update the frames!
        if GRM_MemberDetailMetaData ~= nil and GRM_MemberDetailMetaData:IsVisible() then
            local altFound = false;
            if #GRM_AddonGlobals.selectedAltList > 0 then
                for m = 1 , #GRM_AddonGlobals.selectedAltList do
                    if GRM_AddonGlobals.selectedAltList[m][1] == GRM_AddonGlobals.currentName then
                        -- Alt is found! Let's update the alt frames!
                        altFound = true;
                        for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == GRM_AddonGlobals.selectedAltList[m][1] then
                                -- woot! Now have the index of the alt and can successfully populate the alt frames.
                                GRM.PopulateAltFrames ( i );
                            end
                        end
                        break;
                    end
                end
            end
            -- If it is just the player's same frame, then update it!
            if not altFound and playerName == GRM_AddonGlobals.currentName then
                GRM.PopulateAltFrames ( index1 );
            end
        end
    else
        print ( GRM.SlimName ( playerName ) .. " cannot remove themselves from alts." );
    end
end

-- Method:          GRM.RemovePlayerFromRemovedAltTable( string )
-- What it Does:    When a player removes an alt, it stores that removal in a special table for syncing purposes.
--                  If the alt is re-added, it removes the player from the removed list
-- Purpose:         Syncing data needs timestamps and thus needs good table management of the metadata of add/remove alts lists.
GRM.RemovePlayerFromRemovedAltTable = function ( name , index )
    if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index][37] > 0 then
        for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index][37] do
            if name == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index][37][i][1] then
                table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index][37] , i );
                break;
            end
        end
    end
end
    
-- Method:          GRM.AddAlt (string,string,string,boolean,int)
-- What it Does:    Tags toon to a player's set of alts. It will tag them not just to the given player, but reverse tag itself to all of the alts.
-- Purpose:         Organizing a player and their alts.
GRM.AddAlt = function ( playerName , altName , guildName , isSync , syncTimeStamp )
    if playerName ~= altName then
        -- First, let's identify player index, then identify the classColor of the alt
        local index2;
        local altIndex2;
        local count = 0;
        local classAlt = "";
        local classMain = "";
        local classColorsAlt , classColorsMain , classColorsTemp;
        local isMain = false;
        local timeEpochAdd;
        if isSync then
            timeEpochAdd = syncTimeStamp;
        else
            timeEpochAdd = time();
        end

        -- This block is mainly for resource efficiency, to prevent the blocks from getting too nested, and to store index location for quick access.
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do      
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then        -- Identify position of player
                count = count + 1;
                index2 = j;
                classMain = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][9];
            end
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == altName then           -- Pull altName to attach class on Color
                count = count + 1;
                altIndex2 = j;
                -- Need to preserve the list, in the case of syncing to live update the frames if they are on the alt of the alt.
                if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                    GRM_AddonGlobals.selectedAltList = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];
                end
                classAlt = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][9];
            end
            if count == 2 then
                break;
            end
        end

        -- NEED TO VERIFY IT IS NOT AN ALT FIRST!!! it is removing and re-adding if it is same person.
        local isFound = false;
        if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11] > 0 then
            local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11];
            
            for m = 1 , #listOfAlts do                                              -- Let's quickly verify that this is not a repeat alt add.
                if listOfAlts[m][1] == playerName then
                    print ( GRM.SlimName ( altName ) .. " is Already Listed as an Alt." );
                    isFound = true;
                    break;
                end
            end
        end
        -- If player is trying to add this toon to a list that is already on a list then it adds it in reverse
        if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11] > 0 and #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] > 0 and not isFound then  -- Oh my! Both players have current lists!!! Remove the alt from his list, add to this new one.
            GRM.RemoveAlt ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11][1][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][1] , guildName , isSync , syncTimeStamp );
        end

        -- Main Status check
        local isMain = false;
        if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] > 0 then
            
            for s = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] do
                if s == 1 then
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] then
                        isMain = true;
                    end
                end
                if not isMain then
                    for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][s][1] then
                            -- Ok, let's see if the alt is main...
                            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][10] then
                                isMain = true;
                            end
                            break;
                        end
                    end
                end
                if isMain then
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] = false;
                    break;
                end
            end
        end

        -- if the alt has a list... then reverse
        if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11] > 0 then

            if not isFound then
                -- if the player is main, but the alt has a grouping, let's check if any alts on the list are main. If they are, demote oneself to alt as the group takes priority...
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] then
                    isMain = false;
                    for s = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11] do
                        if s == 1 then
                            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] then
                                isMain = true;
                            end
                        end
                        if not isMain then
                            for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11][s][1] then
                                    -- Ok, let's see if the alt is main...
                                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][10] then
                                        isMain = true;
                                    end
                                    break;
                                end
                            end
                        end
                        if isMain then
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] = false;
                            GRM_MemberDetailMainText:Hide();
                            break;
                        end
                    end
                end
                -- Just in case, let's remove MAIN status if needed.
                GRM.AddAlt ( altName , playerName , guildName , isSync , syncTimeStamp );
            end
            
        else
            -- add altName to each of the previously
            local isFound2 = false;
            classColorsAlt = GRM.GetClassColorRGB ( classAlt );
            local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11];
            if #listOfAlts > 0 then                                                                 -- There is more than 1 alt for new alt to be added to
                for i = 1 , #listOfAlts do                                                          -- Cycle through previously known alt names to add new on each, one by one.
                    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                             -- Need to now cycle through all toons in the guild to set the alt
                        if listOfAlts[i][1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then       -- name on current focus altList found in the metadata!
                            -- Now, make sure it is not a repeat add!
                            
                            for m = 1 , #listOfAlts do                                              -- Let's quickly verify that this is not a repeat alt add.
                                if listOfAlts[m][1] == altName then
                                    print( GRM.SlimName ( altName ) .. " is Already Listed as an Alt." );
                                    isFound2 = true;
                                    break;
                                end
                            end
                            if not isFound2 then
                                classColorsTemp = GRM.GetClassColorRGB ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][9] );
                                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] , { altName , classColorsAlt[1] , classColorsAlt[2] , classColorsAlt[3] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] , timeEpochAdd } ); -- altName is added to a currentFocus previously added alt.
                                GRM.RemovePlayerFromRemovedAltTable ( altName , j );
                                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11] , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , classColorsTemp[1] , classColorsTemp[2] , classColorsTemp[3] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] , timeEpochAdd } );
                                GRM.RemovePlayerFromRemovedAltTable ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , altIndex2 );
                            end
                            break;
                        end
                    end
                    if isFound2 then
                        break;
                    end
                end
            end

            if not isFound2 then
                -- Add all of the CurrentFocus player's alts to the new alt
                -- then add the currentFocus player as well
                classColorsMain = GRM.GetClassColorRGB ( classMain );
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] then
                    table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11] , 1 , { playerName , classColorsMain[1] , classColorsMain[2] , classColorsMain[3] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] , timeEpochAdd } );
                else
                    table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11] , { playerName , classColorsMain[1] , classColorsMain[2] , classColorsMain[3] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] , timeEpochAdd } );
                end
                GRM.RemovePlayerFromRemovedAltTable ( playerName , altIndex2 );
                -- Finally, let's add the alt to the player's currentFocus.
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] , { altName , classColorsAlt[1] , classColorsAlt[2] , classColorsAlt[3] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] , timeEpochAdd } );
                GRM.RemovePlayerFromRemovedAltTable ( altName , index2 );
            end
            -- Insta update the frames!
            if GRM_MemberDetailMetaData ~= nil and GRM_MemberDetailMetaData:IsVisible() then
                -- For use with syncing UI LIVE
                local altFound = false;
                if #GRM_AddonGlobals.selectedAltList > 0 then
                    for m = 1 , #GRM_AddonGlobals.selectedAltList do
                        if GRM_AddonGlobals.selectedAltList[m][1] == GRM_AddonGlobals.currentName then
                            -- Alt is found! Let's update the alt frames!
                            altFound = true;
                            for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == GRM_AddonGlobals.selectedAltList[m][1] then
                                    -- woot! Now have the index of the alt and can successfully populate the alt frames.
                                    GRM.PopulateAltFrames ( i );
                                end
                            end
                            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] > 0 and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] then
                                GRM.SetMain ( GRM_AddonGlobals.currentName , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][1] , GRM_AddonGlobals.guildName , false , 0 );
                            end
                            break;
                        end
                    end
                end

                if not altFound then
                    local frameName = GRM_AddonGlobals.currentName;
                    if playerName == frameName then
                        GRM.PopulateAltFrames ( index2 );
                    elseif altName == frameName then
                        GRM.PopulateAltFrames ( altIndex2 );
                    end
                    if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] > 0 and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] then
                        GRM.SetMain ( GRM_AddonGlobals.currentName , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][1] , GRM_AddonGlobals.guildName , false , 0 );
                    end
                end
            end
        end
    else
        print ( GRM.SlimName ( playerName ) .. " cannot become their own alt!" );
    end
end

-- Method:          GRM.AddPlayerToOwnAltList( int )
-- What it Does:    For the first time a player logs on that toon, or joins a guild with that toon, it adds them to their own alt list.
-- Purpose:         For easy alt management. AUTO adds alt info for a guild :D
GRM.AddPlayerToOwnAltList = function( guildIndex )
    -- Ok, now let's add the player to an alt list...
    -- First, find the player in member save and determine if they are the main, if not, check his alt list, determine who is main.
    -- if no main, first person on list can add.
    -- if main, then main will add this player.
    local playerIsFound = false;
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == GRM_AddonGlobals.addonPlayerName then
        playerIsFound = true;
            -- Ok, adding the player!
            table.insert ( GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ][guildIndex] , { GRM_AddonGlobals.addonPlayerName , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][10] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][9] } );

            -- if the player already is on a list, let's not add them automatically.
            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11] == 0 then
                -- Ok, good, let's check the alt list!
                -- Don't want to add them if they are already on a list...
                for j = 2 , #GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ] do
                    if GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ][j][1] == GRM_AddonGlobals.guildName then
                        if #GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ][j] > 2 then                   -- No need if it is just myself... Count of alts is # minus due to index position starting at 2.\
                            local isAdded = false;
                            for r = 2 , #GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ][j] do
                                -- Make sure it is not the player.
                                if GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ][j][r][1] ~= GRM_AddonGlobals.addonPlayerName then
                                    if GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ][j][r][2] then -- if maim
                                        -- ADD ALT HERE!!!!!!
                                        GRM.AddAlt ( GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ][j][r][1] , GRM_AddonGlobals.addonPlayerName , guildName , false , 0 );
                                        isAdded = true;
                                        break;
                                    end
                                end
                            end
                            -- if it was not added, then add it here! No alt was set as main.
                            if not isAdded then
                                -- ADD ALT, just use index 2
                                GRM.AddAlt ( GRM_AddonGlobals.addonPlayerName , GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ][j][2][1] , guildName , false , 0 );
                            end
                        end
                        break;
                    end
                end
            end
            break;
        end
    end
    -- Player was just invited, and his metadata details have not been populated as of yet. Let's retry in a moment.
    if not playerIsFound then
        C_Timer.After ( 5 , function()
            GRM.AddPlayerToOwnAltList ( guildIndex );
        end);
    end
end


-- Method:              GRM.SortMainToTop (string , int , int , string)
-- What it Does:        Sorts the alts list and sets the main to the top.
-- Purpose:             To keep the main as the first name in the list of alts.
GRM.SortMainToTop = function ( playerName , index2 )
    local tempList;
    -- Ok, now, let's grab the list and do some sorting!
    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] ~= true then                               -- no need to attempt sorting if they are all alts, none are the main.
        for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] do                           -- scanning through the list of alts
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][i][5] then                         -- if one of them equals the main!
                tempList = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][i];                    -- Saving main's info to temp holder
                table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] , i );             -- removing
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] , 1 , tempList );  -- Re-adding it to the front and done!
                break
            end
        end
    end
end

-- Method:              GRM.SetMain (string,string,string , boolean , int )
-- What it Does:        Sets the player as main, as well as updates that status among the alt grouping.
-- Purpose:             Main/alt management control.
GRM.SetMain = function ( playerName , mainName , guildName , isSync , syncTimeStamp )
    local index2;
    local altIndex2;
    local count = 0;
    local timeEpochMain;
    if isSync then
        timeEpochMain = syncTimeStamp;
    else
        timeEpochMain = time();
    end

    -- This block is mainly for resource efficiency, to prevent the blocks from getting too nested,difficult to follow, and bloated.
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do      
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then        -- Identify position of player
            index2 = j;
            -- Establishing list of alts...
            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                GRM_AddonGlobals.selectedAltList = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];
            end
            if playerName == mainName then                               -- no need to identify an alt if there is none.
                break;
            else
                count = count + 1;
            end
        end
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == mainName then           -- Pull mainName to attach class on Color
            count = count + 1;
            altIndex2 = j;
        end
        if count == 2 then
            break;
        end
    end

    local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11];
    if #listOfAlts > 0 then
        -- Need to tag each alt's list with who is the main.
        for i = 1 , #listOfAlts do
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                                  -- Cycling through the guild names to find the alt match
                if listOfAlts[i][1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then            -- Alt location identified!
                    -- Now need to find the name of the alt to tag it.
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == mainName then                -- this alt is the main!
                        if not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] then
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] = true;                       -- Setting toon as main!
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][39] = timeEpochMain;                  -- Setting timeStampOfChange!
                        end
                        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] do               -- making sure all their alts are listed as notMain
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][5] = false;
                        end
                    else
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] then
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] = false;                      -- ensure alt is not listed as main
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][39] = timeEpochMain;
                        end
                        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] do               -- identifying who is to be tagged as main
                            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][1] == mainName then
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][5] = true;
                            else
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][5] = false;        -- tagging everyone not the main as false
                            end
                        end
                    end

                    -- Now, let's sort
                    GRM.SortMainToTop ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , j );
                    break
                end
            end            
        end
        -- Do one last pass to set your own alts list proper.
        for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] do
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][i][5] = false;
        end
    end

    -- Let's ensure the main is the main!
    if playerName ~= mainName then
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] then
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] = false;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][39] = timeEpochMain;
        end
        if not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] then
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] = true;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][39] = timeEpochMain;
        end
        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] do               -- identifying who is to be tagged as main
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][m][1] == mainName then
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][m][5] = true;
            else
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][m][5] = false;        -- tagging everyone not the main as false
            end
        end
        GRM.SortMainToTop ( playerName , index2 );
    else
        if not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] then
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] = true;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][39] = timeEpochMain;
        end
    end
    -- Insta update the frames!
    if GRM_MemberDetailMetaData ~= nil and GRM_MemberDetailMetaData:IsVisible() then
        local altFound = false;
        if #GRM_AddonGlobals.selectedAltList > 0 then
            for m = 1 , #GRM_AddonGlobals.selectedAltList do
                if GRM_AddonGlobals.selectedAltList[m][1] == GRM_AddonGlobals.currentName then
                    -- Alt is found! Let's update the alt frames!
                    altFound = true;
                    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == GRM_AddonGlobals.selectedAltList[m][1] then
                            -- woot! Now have the index of the alt and can successfully populate the alt frames.
                            GRM.PopulateAltFrames ( i );
                        end
                    end
                    break;
                end
            end
        end
        
        if not altFound then
            local frameName = GRM_AddonGlobals.currentName;
            if playerName == frameName then
                GRM.PopulateAltFrames ( index2 );
            elseif mainName == frameName then
                GRM.PopulateAltFrames ( altIndex2 );
            end
        end
    end
end

-- Method:          GRM.PlayerHasMain( string , int , int )
-- What it Does:    Returns true if either the player has a main or is a main themselves
-- Purpose:         Better alt management logic.
GRM.PlayerHasMain = function ( playerName , index2 )
    local hasMain = false;

    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] then
        hasMain = true;
    else
        for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][i][5] then
                hasMain = true;
                break;
            end
        end
    end
    return hasMain;
end

-- Method:          GRM.GetCoreFontStringClicked()
-- What it Does:    Returns a table with the name of the player, the altName, and the guild.
-- Puspose:         To easily pass the info on without having to use a global variable, and set one function to all 12 alt frames.
GRM.GetCoreFontStringClicked = function()
    local altName;
    local focusName = GRM_AddonGlobals.currentName;
    local isMain = false;
    local isAlt1 = false;
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == focusName then
    
            if GRM_AltName1:IsVisible() and GRM_AltName1:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][1][1];
                isAlt1 = true;
            elseif GRM_AltName2:IsVisible() and GRM_AltName2:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][2][1];
            elseif GRM_AltName3:IsVisible() and GRM_AltName3:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][3][1];
            elseif GRM_AltName4:IsVisible() and GRM_AltName4:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][4][1];
            elseif GRM_AltName5:IsVisible() and GRM_AltName5:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][5][1];
            elseif GRM_AltName6:IsVisible() and GRM_AltName6:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][6][1];
            elseif GRM_AltName7:IsVisible() and GRM_AltName7:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][7][1];
            elseif GRM_AltName8:IsVisible() and GRM_AltName8:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][8][1];
            elseif GRM_AltName9:IsVisible() and GRM_AltName9:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][9][1];
            elseif GRM_AltName10:IsVisible() and GRM_AltName10:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][10][1];
            elseif GRM_AltName11:IsVisible() and GRM_AltName11:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][11][1];
            elseif GRM_AltName12:IsVisible() and GRM_AltName12:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][12][1];
            elseif ( GRM_MemberDetailRankDateTxt:IsVisible() and GRM_MemberDetailRankDateTxt:IsMouseOver ( 2 , -2 , -2 , 2 ) ) or ( GRM_JoinDateText:IsVisible() and GRM_JoinDateText:IsMouseOver ( 2 , -2 , -2 , 2 ) ) or ( GRM_MemberDetailPlayerStatus:IsVisible() and GRM_MemberDetailPlayerStatus:IsMouseOver ( 2 , -2 , -2 , 2 ) ) or GRM_MemberDetailNameText:IsMouseOver ( 2 , -2 , -2 , 2 ) then -- Covers both promo date and join date focus.
                altName = focusName;
            else
                -- MOUSE WAS NOT OVER, EVEN ON A RIGHT CLICK OF THE FRAME!!!
                focusName = nil;
                altName = nil;
            end
            break;
        end
    end
    if ( isAlt1 and altName ~= nil and string.find ( GRM_AltName1:GetText() , "(main)" ) ~= nil ) then        -- This is the main! Let's parse main out of the name!
        isMain = true;
    elseif altName == focusName and GRM_MemberDetailMainText:IsVisible() then
        isMain = true;
    end
    return { focusName , altName , GRM_AddonGlobals.guildName , isMain };
end


-- Method:              GRM.DemoteFromMain ( string , string , string )
-- What it Does:        If the player is "main" then it removes the main tag to false
-- Purpose:             User Experience (UX) and alt management!
GRM.DemoteFromMain = function ( playerName , mainName , guildName , isSync , syncTimeStamp )
    local index2;
    local altIndex2;
    local count = 0;
    local RMVtimeEpochMain;
    if isSync then
        RMVtimeEpochMain = syncTimeStamp;
    else
        RMVtimeEpochMain = time();
    end
    
    -- This block is mainly for resource efficiency, to prevent the blocks from getting too nested,difficult to follow, and bloated.
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do      
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then   -- Identify position of player
            index2 = j;
            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                GRM_AddonGlobals.selectedAltList = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];
            end
            if playerName == mainName then                                                                          -- no need to identify an alt if there is none.
                break;
            else
                count = count + 1;
            end
        end
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == mainName then     -- Pull mainName to attach class on Color
            count = count + 1;
            altIndex2 = j;
        end
        if count == 2 then
            break;
        end
    end

    local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11];
    if #listOfAlts > 0 then
        -- Need to tag each alt's list with who is the main.
        for i = 1 , #listOfAlts do
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                                  -- Cycling through the guild names to find the alt match
                if listOfAlts[i][1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then            -- Alt location identified!
                    -- Now need to find the name of the alt to tag it.
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == mainName then                -- this alt is the main!
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] then
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] = false;                       -- Demoting the toon from main!
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][39] = RMVtimeEpochMain;
                        end
                        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] do               -- making sure all their alts are listed as notMain
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][5] = false;
                        end
                    else
                        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] do               -- identifying who is to be tagged as main
                            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][1] == mainName then
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][5] = false;
                            else
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][5] = false;        -- tagging everyone not the main as false
                            end
                        end
                    end

                    -- Now, let's sort
                    GRM.SortMainToTop ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , j );
                    break
                end
            end            
        end
    end

    -- Let's ensure the main is the main!
    if playerName ~= mainName then
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] then
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] = false;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][39] = RMVtimeEpochMain;
        end
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] then
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][10] = false;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][39] = RMVtimeEpochMain;
        end
        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] do               -- identifying who is to be tagged as main
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][m][1] == mainName then
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][m][5] = false;
            else
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11][m][5] = false;        -- tagging everyone not the main as false
            end
        end
        GRM.SortMainToTop ( playerName , index2 );
    else
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] then
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][10] = false;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][39] = RMVtimeEpochMain;
        end
    end
    -- Insta update the LIVE frames for sync, if player is on a diff. frame.
    if GRM_MemberDetailMetaData ~= nil and GRM_MemberDetailMetaData:IsVisible() then
        local altFound = false;
        if #GRM_AddonGlobals.selectedAltList > 0 then
            for m = 1 , #GRM_AddonGlobals.selectedAltList do
                if GRM_AddonGlobals.selectedAltList[m][1] == GRM_AddonGlobals.currentName then
                    -- Alt is found! Let's update the alt frames!
                    altFound = true;
                    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == GRM_AddonGlobals.selectedAltList[m][1] then
                            -- woot! Now have the index of the alt and can successfully populate the alt frames.
                            GRM.PopulateAltFrames ( i );
                        end
                    end
                    break;
                end
            end
        end

        if not altFound then
            local frameName = GRM_AddonGlobals.currentName;
            if playerName == frameName then
                GRM.PopulateAltFrames ( index2 );
            elseif mainName == frameName then
                GRM.PopulateAltFrames ( altIndex2 );
            end
        end
    end
end

-- Method:          GRM.ResetAltButtonHighlights();
-- What it Does:    Just resets the highlight of the tab/alt-tab highlight for a better user-experience to default position
-- Purpose:         UX
GRM.ResetAltButtonHighlights = function()
    GRM_AddAltNameButton1:LockHighlight();
    GRM_AddAltNameButton2:UnlockHighlight();
    GRM_AddAltNameButton3:UnlockHighlight();
    GRM_AddAltNameButton4:UnlockHighlight();
    GRM_AddAltNameButton5:UnlockHighlight();
    GRM_AddAltNameButton6:UnlockHighlight();
    GRM_AddonGlobals.currentHighlightIndex = 1;
end


-- Method:          GRM.AddAltAutoComplete()
-- What it Does:    Takes the entire list of guildies, then sorts them as player types to be added to alts list
-- Purpose:         Eliminates the possibility of a person entering a fake name of a player no longer in the guild.
GRM.AddAltAutoComplete = function()
    local partName = GRM_AddAltEditBox:GetText();
    GRM_AddonGlobals.listOfGuildies = nil;
    GRM_AddonGlobals.listOfGuildies = {};
    local numButtons = 6;

    for i = 1 , GRM.GetNumGuildies() do
        local name = GetGuildRosterInfo( i );
        if name ~= GRM_AddonGlobals.currentName then   -- no need to go through player's own window
            table.insert ( GRM_AddonGlobals.listOfGuildies , name );
        end
    end
    sort ( GRM_AddonGlobals.listOfGuildies );    -- Alphabetizing it for easier parsing for buttontext updating.
    
    -- Now, let's identify the names that match
    local count = 0;
    local matchingList = {};
    local found = false;
    for i = 1 , #GRM_AddonGlobals.listOfGuildies do
        local innerFound = false;
        if string.lower ( partName ) == string.lower ( string.sub ( GRM_AddonGlobals.listOfGuildies[i] , 1 , #partName ) ) then
            innerFound = true;
            found = true;
            count = count + 1;
            table.insert ( matchingList , GRM_AddonGlobals.listOfGuildies[i] );
        end
        if count > 6 then
            break;
        end
        if innerFound ~= true and found then    -- resource saving
            break;
        end
    end
    
    -- Populate the buttons now...
    if partName ~= nil and partName ~= "" then
        local resultCount = #matchingList;
        GRM.ResetAltButtonHighlights();
        if resultCount > 0 then
            GRM_AddAltEditFrameHelpText:Hide();
            GRM_AddAltEditFrameHelpText2:Hide();
            GRM_AddAltNameButton1Text:SetText ( matchingList[1] );
            GRM_AddAltNameButton1:Enable();
            GRM_AddAltNameButton1:Show();
            GRM_AddAltEditFrameTextBottom:Show();
        else
            GRM_AddAltEditFrameHelpText:Show();
            GRM_AddAltEditFrameHelpText2:Show();
            GRM_AddAltNameButton1:Hide();
            GRM_AddAltEditFrameTextBottom:Hide();
            if string.lower ( GRM_AddonGlobals.currentName ) == string.lower ( partName ) then
                GRM_AddAltEditFrameHelpText:SetText ( "Player Cannot Add\nThemselves as an Alt" );
                GRM_AddAltEditFrameHelpText2:Hide();
            else
                GRM_AddAltEditFrameHelpText:SetText ( "Player Not Found" );
            end
        end
        if resultCount > 1 then
            GRM_AddAltNameButton2Text:SetText ( matchingList[2] );
            GRM_AddAltNameButton2:Enable();
            GRM_AddAltNameButton2:Show();
        else
            GRM_AddAltNameButton2:Hide();
        end
        if resultCount > 2 then
            GRM_AddAltNameButton3Text:SetText ( matchingList[3] );
            GRM_AddAltNameButton3:Enable();
            GRM_AddAltNameButton3:Show();
        else
            GRM_AddAltNameButton3:Hide();
        end
        if resultCount > 3 then
            GRM_AddAltNameButton4Text:SetText ( matchingList[4] );
            GRM_AddAltNameButton4:Enable();
            GRM_AddAltNameButton4:Show();
        else
            GRM_AddAltNameButton4:Hide();
        end
        if resultCount > 4 then
            GRM_AddAltNameButton5Text:SetText ( matchingList[5] );
            GRM_AddAltNameButton5:Enable();
            GRM_AddAltNameButton5:Show();
        else
            GRM_AddAltNameButton5:Hide();
        end
        if resultCount > 5 then
            if resultCount == 6 then
                GRM_AddAltNameButton6Text:SetText ( matchingList[6] );
                GRM_AddAltNameButton6:Enable();
            else
                GRM_AddAltNameButton6Text:SetText ( "..." );
                GRM_AddAltNameButton6:Disable();
            end
            GRM_AddAltNameButton6:Show();
        else
            GRM_AddAltNameButton6:Hide();
        end
    else
        GRM_AddAltNameButton1:Hide();
        GRM_AddAltNameButton2:Hide();
        GRM_AddAltNameButton3:Hide();
        GRM_AddAltNameButton4:Hide();
        GRM_AddAltNameButton5:Hide();
        GRM_AddAltNameButton6:Hide();
        GRM.ResetAltButtonHighlights();
        GRM_AddAltEditFrameTextBottom:Hide();
        GRM_AddAltEditFrameHelpText:SetText ( "Please Type the Name\nof the alt" );
        GRM_AddAltEditFrameHelpText:Show();
        GRM_AddAltEditFrameHelpText2:Show();
    end
end

-- Method:              GRM.KickAllAlts ( string , string )
-- What it Does:        Bans all listed alts of the player as well and adds them to the ban list. Of note, addons cannot kick players anymore, so this only adds to ban list.
-- Purpose:             QoL. Option to ban players' alts as well if they are getting banned.
GRM.KickAllAlts = function ( playerName , guildName )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do      
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then        -- Identify position of player
        -- Ok, let's parse the player's data!
            local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];
            if #listOfAlts > 0 then                                  -- There is at least 1 alt
                for m = 1 , #listOfAlts do                           -- Cycling through the alts
                    if GRM_PopupWindowCheckButton1:GetChecked() then     -- Player wants to BAN the alts confirmed!
                        for s = 1 , #listOfAlts do
                            for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == listOfAlts[s][1] and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] ~= GRM_AddonGlobals.addonPlayerName then        -- Logic to avoid kicking oneself ( or at least to avoid getting error notification )
                                    -- Set the banned info.
                                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][1] = true;
                                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][2] = time();
                                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][3] = false;
                                    local instructionNote = "Reason Banned?\nClick \"Yes\" When Done";
                                    local result = GRM_MemberDetailPopupEditBox:GetText();

                                    if result ~= nil and result ~= instructionNote and result ~= "" then
                                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] = result;
                                    elseif result == nil then
                                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] = "";
                                    else
                                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] = result;
                                    end
                                    break;
                                end
                            end
                        end
                        break;
                    else
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][1] ~= GRM_AddonGlobals.addonPlayerName then
                        end                       
                    end
                end
            end
            break;
        end
    end
end


------------------------------------
---- END OF ALT MANAGEMENT ---------
------------------------------------



------------------------------------
------ METADATA TRACKING LOGIC -----
--- Reporting, Live Tracking, Etc --
------------------------------------

-- Method:          GRM.AddMemberRecord()
-- What it Does:    Builds Member Record into Guild History with various metadata
-- Purpose:         For reliable guild data tracking.
GRM.AddMemberRecord = function ( memberInfo , isReturningMember , oldMemberInfo , guildName )
    -- Metadata to track on all players.
    -- Basic Info
    local timeSeconds = time();
    local name = memberInfo[1];
    local slim = GRM.SlimName ( name );
    local joinDate = GRM.GetTimestamp();
    local joinDateMeta = timeSeconds;  -- Saved in Seconds since Jan 1, 1970, to be parsed later
    local rank = memberInfo[2];
    local rankInd = memberInfo[3];
    local currentLevel = memberInfo[4];
    local note = memberInfo[5];
    local officerNote = memberInfo[6];
    local class = memberInfo[7]; 
    local isMainToon = false;
    local listOfAltsInGuild = {};
    local dateOfLastPromotion = nil;
    local dateOfLastPromotionMeta = nil;
    local birthday = nil;

    -- Event and Anniversary tracking.
    local eventTrackers = { { slim .. "'s Anniversary!" , nil , false , "" } , { slim .. "'s Birthday!" , nil , false , "" } };  -- Position 1 = anniversary , Position 2 = birthday , 3 = anniversary For Each = { date , needsToNotify , SpecialNotes }
    local customNote = ""; -- Extra note space, for GM to add futher info.

    -- Info nil now, but to be populated on leaving the guild
    local leftGuildDate = {};
    local leftGuildDateMeta = {};
    local bannedFromGuild = { false , 0 , false };  -- { isBanned , timeOfBanInEpoch or unban , isBanRemoved }
    local reasonBanned = "";
    local oldRank = nil;
    local oldJoinDate = {}; -- filled upon player leaving the guild.
    local oldJoinDateMeta = {};

    -- Pieces info that were added on later-- from index 24 of metaData array, so as not to mess with previous code
    local lastOnline = 0;                                                                           -- Stores it in number of HOURS since last online.
    local rankHistory = {};
    local playerLevelOnJoining = currentLevel;
    local recommendToKickReported = false;
    -- More metadata!
    local zone = memberInfo[9];
    local achievementPoints = memberInfo[10];
    local isMobile = memberInfo[11];
    local rep = memberInfo[12];
    local timePlayerEnteredZone = timeSeconds;  -- ( time() - timePlayerEnteredZone ) = seconds passed. If zone changes, player re-timestamps it...
    local isOnline = memberInfo[13];
    local currentStatus = memberInfo[14];       -- AFK, Active, Busy

    -- FOR SYNC PURPOSES!!!
    local joinDateTimestamp = { "" , 0 };
    local promoDateTimestamp = { "" , 0 };
    local listOfRemovedAlts = {};
    local mainStatusChangeTimestamp = {};
    local timeMainStatusAltered = 0;

    -- Returning member info to be carried over.
    if isReturningMember then
        dateOfLastPromotion = oldMemberInfo[12];
        dateOfLastPromotionMeta = oldMemberInfo[13];
        birthday = oldMemberInfo[14];
        leftGuildDate = oldMemberInfo[15];
        leftGuildDateMeta = oldMemberInfo[16];
        bannedFromGuild = oldMemberInfo[17];
        reasonBanned = oldMemberInfo[18];
        oldRank = oldMemberInfo[19];
        oldJoinDate = oldMemberInfo[20];
        table.insert ( oldJoinDate , joinDate );                -- Add the new join date to history
        oldJoinDateMeta = oldMemberInfo[21];
        table.insert ( oldJoinDateMeta , joinDateMeta );        -- likewise, add the meta seconds.
        specialTrackers = oldMemberInfo[22];
        customNote = oldMemberInfo[23];
        rankHistory = oldMemberInfo[25];
        playerLevelOnJoining = oldMemberInfo[26];
        joinDateTimestamp[1] = joinDate;
        joinDateTimestamp[2] = timeSeconds;
    end

    -- For both returning players and new adds
    table.insert ( rankHistory , { rank , string.sub ( joinDate , 1 , string.find ( joinDate , "'" ) + 2 ) , joinDateMeta } );

    table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] , { name , joinDate , joinDateMeta , rank , rankInd , currentLevel , note , officerNote , class , isMainToon ,
        listOfAltsInGuild , dateOfLastPromotion , dateOfLastPromotionMeta , birthday , leftGuildDate , leftGuildDateMeta , bannedFromGuild , reasonBanned , oldRank ,
            oldJoinDate , oldJoinDateMeta , eventTrackers , customNote , lastOnline , rankHistory , playerLevelOnJoining , recommendToKickReported , zone , achievementPoints ,
                isMobile , rep , timePlayerEnteredZone , isOnline , memberStatus , joinDateTimestamp , promoDateTimestamp , listOfRemovedAlts , mainStatusChangeTimestamp , timeMainStatusAltered } );  -- 39 so far. (35-39 = sync stamps)
end

-- Method:          GRM.AddMemberToLeftPlayers ( array , string , int , string , int )
-- What it does:    First, it adds a new player to the saved list. This basically builds a metadata profile. Then, we add that player to players that left, then remove it from current guildies list.
-- Purpose:         If a player installs the addon AFTER people have left the guild, for example, you need to know their details to have them on the ban list. This builds a profile if another sync'd player has them banned
--                  as you cannot just add the name as banned, you literally have to build a full metadata file for them for it to work properly in the case that they return to the guild.
GRM.AddMemberToLeftPlayers = function ( memberInfo , leftGuildDate , leftGuildMeta , oldJoinDate , oldJoinDateMeta )
    -- First things first, add them!
    GRM.AddMemberRecord( memberInfo , false , nil , GRM_AddonGlobals.guildName );
    -- Ok, now that it is added, what we need to do now is REMOVE the player from the GRM_GuildMemberHistory_Save and then add it to the end of the left player history.
    -- Some updates must be had, however.
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == memberInfo[1] then
            table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][15], leftGuildDate );                                                                 -- leftGuildDate
            table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][16], leftGuildMeta );                                                                 -- leftGuildDateMeta
            table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] , { "|cFFC41F3BLeft Guild" , GRM.Trim ( string.sub ( leftGuildDate , 1 , 10 ) ) } );
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][19] = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][4];         -- old Rank on leaving.
            table.insert( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20] , oldJoinDate );                                                                   -- oldJoinDate
            table.insert( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][21] , oldJoinDateMeta );                                                               -- oldJoinDateMeta

            -- If not banned, then let's ensure we reset his data.
            if not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][1] then
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][1] = false;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][2] = 0;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][3] = false;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][18] = "";
            end
            -- Adding to LeftGuild Player history library
            table.insert ( GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j] );
            break;
        end
    end

    -- Now need to remove it from the end position. But should still cycle through just in case over overlapping parallel actions.
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == memberInfo[1] then
            table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] );
            break;
        end
    end
    
end

-- Method:          GRM.GetGuildEventString ( int , string )
-- What it Does:    Gets more exact info from the actual Guild Event Log ( can only be queried once per 10 seconds) as a string
-- Purpose:         This parses more exact info, like "who" did the kicking, or "who" invited who, and so on.
GRM.GetGuildEventString = function ( index , playerName )
    -- index 1 = demote , 2 = promote , 3 = remove/quit , 4 = invite/join
    local result = "";
    local eventType = { "demote" , "promote" , "invite" , "join" , "quit" , "remove" };
    QueryGuildEventLog();

    if index == 1 or index == 2 then
        for i = GetNumGuildEvents() , 1 , -1 do
            local type , p1, p2 = GetGuildEventInfo ( i );
            if p1 ~= nil then                                                 ---or eventType [ 2 ] == type ) and ( p2 ~= nil and p2 == playerName ) and p1 ~= nil then
                if index == 1 and eventType [ 1 ] == type and p2 ~= nil and p2 == playerName then
                    result = ( p1 .. " DEMOTED " .. p2 );
                    break;
                elseif index == 2 and eventType [ 2 ] == type and p2 ~= nil and p2 == playerName then
                    result = ( p1 .. " PROMOTED " .. p2 );
                    break;
                end
            end
        end
   elseif index == 3 then
        local notFound = true;
        for i = GetNumGuildEvents() , 1 , -1 do 
            local type , p1, p2 = GetGuildEventInfo ( i );
            if p1 ~= nil then 
                if eventType [ 5 ] == type or eventType [ 6 ] == type then   -- Quit or Remove
                    if eventType [ 6 ] == type and p2 ~= nil and p2 == playerName then
                        result = ( p1 .. " KICKED " .. p2 .. " from the Guild!" );
                        notFound = false;
                    elseif eventType [ 5 ] == type and p1 == playerName then
                        -- FOUND!
                        result = ( p1 .. " has Left the Guild" );
                        notFound = false;
                    end
                    if notFound ~= true then
                        break;
                    end
                end
            end
        end
    elseif index == 4 then
        for i = GetNumGuildEvents() , 1 , -1 do 
            local type , p1, p2 = GetGuildEventInfo ( i );
            if eventType [ 3 ] == type and p1 ~= nil and p2 ~= nil and p2 == playerName then   -- invite
                result = ( p1 .. " INVITED " .. p2 .. " to the guild." );
                break;
            end
        end
    end

    return result;
end

-- Method:          GRM.GetMessageRGB( int )
-- What it Does:    Returns the 3 RGB colors colors based on the given index on a 1.0 scale
-- Purpose:         Save on code when need color call. I also did this as a 3 argument return, rather than a single array, just as a proof of concept
--                  since this whole project was also a bit of a Lua learning moment.
GRM.GetNMessageRGB = function ( index )
    local r = 0;
    local g = 0;
    local b = 0;

    if index == 1 then      -- Promotion 
        r = 1.0;
        g = 0.914;
        b = 0.0;
    elseif index == 2 then  -- Demotion
        r = 0.91;
        g = 0.388;
        b = 0.047;
    elseif index == 3 then  -- Leveled
        r = 0;
        g = 0.44;
        b = 0.87;
    elseif index == 4 then  -- Note
        r = 1.0;
        g = 0.6;
        b = 1.0;
    elseif index == 5 then  -- OfficerNote
        r = 1.0;
        g = 0.094;
        b = 0.93;
    elseif index == 6 then  -- Rank Rename
        r = 0.64;
        g = 0.102;
        b = 0.102;
    elseif index == 7 or index == 8 then  -- Join/Rejoin
        r = 0.5;
        g = 1.0;
        b = 0;
    elseif index == 9 then  -- Banned Player
        r = 1.0;
        g = 0;
        b = 0;
    elseif index == 10 then -- Left Guild
        r = 0.5;
        g = 0.5;
        b = 0.5;
    elseif index == 11 then -- NameChange
        r = 0.90;
        g = 0.82;
        b = 0.62;
    elseif index == 12 then -- WhiteText
        r = 1.0;
        g = 1.0;
        b = 1.0;
    elseif index == 13 then -- Rejoining Player Warning (RED)
        r = 0.4;
        g = 0.71;
        b = 0.9;
    elseif index == 14 then -- Return from inactivity
        r = 0;
        g = 1.0;
        b = 0.87;
    elseif index == 15 then -- Event Announcement
        r = 0;
        g = 0.8;
        b = 1.0;
    elseif index == 16 then -- Recommendations
        r = 0.39;
        g = 0.0;
        b = 0.69;
    elseif index == 17 then -- Ban 
        r = 1.0;
        g = 0.0;
        b = 0.0;
    elseif index == 18 then  -- Ban Reason - White txt
        r = 1.0;
        g = 1.0;
        b = 1.0;
    end

    return r , g , b;
end

-- Method:          GRM.AddLog(int , string)
-- What it Does:    Adds a simple array to the Logreport that includes the indexcode for color, and the included changes as a string
-- Purpose:         For ease in adding to the core log.
GRM.AddLog = function ( indexCode , logEntry )
    table.insert ( GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] , { indexCode , logEntry } );
end

-- Method:          GRM.PrintLog(index)
-- What it Does:    Sets the color of the string to be reported to the frame (typically chat frame, or to the Log Report frame)
-- Purpose:         Color coding log and chat frame reporting.
GRM.PrintLog = function ( index , logReport , LoggingIt ) -- 2D array index and logReport ?? 
    -- index of what kind of report, thus determining color
    if ( index == 1 ) then -- Promoted
        if LoggingIt then
            -- Add to log
        else
            -- sending it to chatFrame
            chat:AddMessage( logReport , 1.0 , 0.914 , 0.0 );
        end
    elseif ( index == 2 ) then -- Demoted
        if LoggingIt then
            -- Add to log
        else
            -- sending it to chatFrame
            chat:AddMessage( logReport , 0.91 , 0.388 , 0.047 );
        end
    elseif ( index == 3 ) then -- Leveled
        if LoggingIt then
            -- Add to log
        else
            -- sending it to chatFrame
            chat:AddMessage( logReport , 0.0 , 0.44 , 0.87 );
        end
    elseif ( index == 4 ) then -- Note
        if LoggingIt then
            
        else
            chat:AddMessage( logReport , 1.0 , 0.6 , 1.0 );
        end
    elseif ( index == 5 ) then -- Officer Note
        if LoggingIt then
            
        else
            chat:AddMessage( logReport , 1.0 , 0.094 , 0.93 );
        end
    elseif ( index == 6 ) then -- Rank Renamed
        if LoggingIt then
            
        else
            chat:AddMessage( logReport , 0.64 , 0.102 , 0.102 );
        end
    elseif ( index == 7 ) or ( index == 8 ) then -- Join and Rejoin!
        if LoggingIt then
            
        else
            chat:AddMessage( logReport, 0.5, 1.0, 0 );
        end
    elseif ( index == 9 ) then -- WARNING BANNED PLAYER REJOIN!
        if LoggingIt then
            
        else
            chat:AddMessage( logReport , 1.0 , 0.0 , 0.0 );
        end
    elseif ( index == 10 ) then -- Left the guild
        if LoggingIt then
            
        else
            chat:AddMessage( logReport, 0.5, 0.5, 0.5 );
        end
    elseif ( index == 11 ) then -- Namechanged
        if LoggingIt then
            
        else
            chat:AddMessage( logReport, 0.9 , 0.82 , 0.62 );
        end
    elseif ( index == 12 ) then -- WHITE TEXT IGNORE RGB COLORING
        if LoggingIt then

        else
            chat:AddMessage( logReport , 1.0 , 1.0 , 1.0 );
        end
    elseif ( index == 13 ) then -- Rejoining PLayer Custom Note Report
        if LoggingIt then

        else
            chat:AddMessage( logReport , 0.4 , 0.71 , 0.9 )
        end
    elseif ( index == 14 ) then -- Player has returned from inactivity
        if LoggingIt then

        else
            chat:AddMessage( logReport , 0 , 1.0 , 0.87 );
        end
    elseif ( index == 15 ) then -- For event notifications like upcoming anniversaries.
        if LoggingIt then

        else
            chat:AddMessage( logReport , 0 , 0.8 , 1.0 );
        end
    elseif ( index == 16 ) then -- For Recommendations
        if LoggingIt then

        else
            chat:AddMessage( logReport , 0.39 , 0.0 , 0.69 );
        end
    elseif ( index == 17 ) then -- For Banning
        if LoggingIt then

        else
            chat:AddMessage( logReport , 1.0 , 0.0 , 0.0 );
        end
    elseif ( index == 18 ) then -- For Banning Reason
        if LoggingIt then

        else
            chat:AddMessage( logReport , 1.0 , 1.0 , 1.0 );
        end
    
    elseif ( index == 99 ) then
        -- Addon Name Report Colors!
    end
end

-- Method:          GRM.Report ( string )
-- What it Does:    Sends to the main chat window messages on various events as deemed necessary to report on by addon creator.
-- Purpose:         To clean up the reporting and have a way to present the information blended into the default system UI
GRM.Report = function ( msg )
    -- chat:AddMessage ( string , R , G , B ) on 1.0 scale
    chat:AddMessage ( msg , 1.0 , 0.84 , 0 );
end

-- Method:          GRM.BuildEventCalendarManagerScrollFrame()
-- What it Does:    This populates properly the event ScrollFrame
-- Purpose:         Scroll Frame management for smoother User Experience
GRM.BuildEventCalendarManagerScrollFrame = function()
    -- SCRIPT LOGIC ON ADD EVENT SCROLLING FRAME
    local scrollHeight = 0;
    local scrollWidth = 220;
    local buffer = 5;

    GRM_AddEventScrollChildFrame.allFrameButtons = GRM_AddEventScrollChildFrame.allFrameButtons or {};  -- Create a table for the Buttons.
    -- populating the window correctly.
    for i = 1 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] - 1 do
        -- if font string is not created, do so.
        if not GRM_AddEventScrollChildFrame.allFrameButtons[i] then
            local tempButton = CreateFrame ( "Button" , "PlayerToAdd" .. i , GRM_AddEventScrollChildFrame ); -- Names each Button 1 increment up
            GRM_AddEventScrollChildFrame.allFrameButtons[i] = { tempButton , tempButton:CreateFontString ( "PlayerToAddText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "PlayerToAddTitleText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) };
        end

        local EventButtons = GRM_AddEventScrollChildFrame.allFrameButtons[i][1];
        local EventButtonsText = GRM_AddEventScrollChildFrame.allFrameButtons[i][2];
        local EventButtonsText2 = GRM_AddEventScrollChildFrame.allFrameButtons[i][3];
        EventButtons:SetPoint ( "TOP" , GRM_AddEventScrollChildFrame , 7 , -99 );
        EventButtons:SetWidth ( 110 );
        EventButtons:SetHeight ( 19 );
        EventButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        EventButtonsText:SetText ( GRM.SlimName ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][1] ) );
        EventButtonsText:SetWidth ( 105 );
        EventButtonsText:SetWordWrap ( false );
        EventButtonsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
        EventButtonsText:SetPoint ( "LEFT" , EventButtons );
        EventButtonsText:SetJustifyH ( "LEFT" );
        EventButtonsText2:SetText ( GRM.SlimName( string.sub ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2] , 0 , ( string.find ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2] , " " ) - 1 ) ) ) .. string.sub ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2] , string.find ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2] , " " ) , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2] ) );
        EventButtonsText2:SetWidth ( 162 );
        EventButtonsText2:SetWordWrap ( false );
        EventButtonsText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
        EventButtonsText2:SetPoint ( "LEFT" , EventButtons , "RIGHT" , 5 , 0 );
        EventButtonsText2:SetJustifyH ( "LEFT" );
        -- Logic
        EventButtons:SetScript ( "OnClick" , function ( self , button )
            if button == "LeftButton" then
                -- For highlighting purposes
                for j = 1 , #GRM_AddEventScrollChildFrame.allFrameButtons do
                    if EventButtons ~= GRM_AddEventScrollChildFrame.allFrameButtons[j][1] then
                        GRM_AddEventScrollChildFrame.allFrameButtons[j][1]:UnlockHighlight();
                    else
                        GRM_AddEventScrollChildFrame.allFrameButtons[j][1]:LockHighlight();
                    end
                end
                GRM_AddEventFrameNameToAddText:SetText ( EventButtonsText2:GetText() );
                GRM_AddEventFrameNameToAddTitleText:SetText ( EventButtonsText: GetText() );
                
                -- parse out the button number, which will correlate with addonque frame...
                local buttonName = self:GetName();
                local index = tonumber ( string.sub ( buttonName , #buttonName ) ) + 1; -- It has to be incremented up by one as the stored data begins at index 2, not 1, as that references the guild.
                
                GRM_AddEventFrameNameDateText:SetText(  monthEnum2 [ '' .. GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][index][3] .. '' ] .. " " .. GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][index][4] );

                if GRM_AddEventFrameStatusMessageText:IsVisible() then
                    GRM_AddEventFrameStatusMessageText:Hide();
                    GRM_AddEventFrameNameToAddText:Show();
                    GRM_AddEventFrameNameDateText:Show();
                end
            end
        end);
        
        -- Now let's pin it!
        if i == 1 then
            EventButtons:SetPoint( "TOPLEFT" , 0 , - 5 );
            scrollHeight = scrollHeight + EventButtons:GetHeight();
        else
            EventButtons:SetPoint( "TOPLEFT" , GRM_AddEventScrollChildFrame.allFrameButtons[i - 1][1] , "BOTTOMLEFT" , 0 , - buffer );
            scrollHeight = scrollHeight + EventButtons:GetHeight() + buffer;
        end
        EventButtons:Show();
    end
    -- Update the size -- it either grows or it shrinks!
    GRM_AddEventScrollChildFrame:SetSize ( scrollWidth , scrollHeight );

    --Set Slider Parameters ( has to be done after the above details are placed )
    local scrollMax = ( scrollHeight - 145 ) + ( buffer * .5 );
    if scrollMax < 0 then
        scrollMax = 0;
    end
    GRM_AddEventScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
    -- Mousewheel Scrolling Logic
    GRM_AddEventScrollFrame:EnableMouseWheel( true );
    GRM_AddEventScrollFrame:SetScript( "OnMouseWheel" , function( self , delta )
        local current = GRM_AddEventScrollFrameSlider:GetValue();
        
        if IsShiftKeyDown() and delta > 0 then
            GRM_AddEventScrollFrameSlider:SetValue ( 0 );
        elseif IsShiftKeyDown() and delta < 0 then
            GRM_AddEventScrollFrameSlider:SetValue ( scrollMax );
        elseif delta < 0 and current < scrollMax then
            GRM_AddEventScrollFrameSlider:SetValue ( current + 20 );
        elseif delta > 0 and current > 1 then
            GRM_AddEventScrollFrameSlider:SetValue ( current - 20 );
        end
    end);
end


-- Method:          GRM.BuildAddonUserScrollFrame()
-- What it Does:    Builds the potential scroll frame to house the entire list of all guildies who have addon installed and enabled
-- Purpose:         Much better and cleaner UI to have a scroll window, imo.
GRM.BuildAddonUserScrollFrame = function()
    local scrollHeight = 0;
    local scrollWidth = 370;
    local buffer = 7;

    GRM_AddonUsersScrollChildFrame.AllFrameFontstrings = GRM_AddonUsersScrollChildFrame.AllFrameFontstrings or {};  -- Create a table for the Buttons.
    -- Building all the fontstrings.
    for i = 1 , #GRM_AddonGlobals.currentAddonUsers do
        -- We know there is at least one, so let's hide the warning string...
        GRM_AddonUsersScrollChildFrame.GRM_AddonUsersCoreFrameTitleText2:Hide();
        -- if font string is not created, do so.
        if not GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i] then
            GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i] = { GRM_AddonUsersScrollChildFrame:CreateFontString ( "GRM_AddonUserNameText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_AddonUsersScrollChildFrame:CreateFontString ( "GRM_AddonUserSyncText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_AddonUsersScrollChildFrame:CreateFontString ( "GRM_AddonUserVersionText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) };
        end

        local AddonUserText1 = GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][1];
        local AddonUserText2 = GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][2];
        local AddonUserText3 = GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][3];
        AddonUserText1:SetText ( GRM.SlimName ( GRM_AddonGlobals.currentAddonUsers[i][1] ) );
        AddonUserText1:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
        AddonUserText1:SetJustifyH ( "LEFT" );

        -- Get the right RGB coloring for the text.
        local r , g , b;
        if GRM_AddonGlobals.currentAddonUsers[i][2] == "Ok!" then
            r = 0;
            g = 0.77;
            b = 0.063;
        else
            r = 0.64;
            g = 0.102;
            b = 0.102;
        end
        AddonUserText2:SetTextColor ( r , g , b , 1.0 ); 
        AddonUserText2:SetText ( GRM_AddonGlobals.currentAddonUsers[i][2] );
        AddonUserText2:SetWidth ( 200 );
        AddonUserText2:SetWordWrap ( false );
        AddonUserText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
        AddonUserText2:SetJustifyH ( "CENTER" );
        AddonUserText3:SetText ( string.sub ( GRM_AddonGlobals.currentAddonUsers[i][3] , string.find ( GRM_AddonGlobals.currentAddonUsers[i][3] , "R" , -8 ) , #GRM_AddonGlobals.currentAddonUsers[i][3] ) );
        AddonUserText3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
        AddonUserText3:SetJustifyH ( "RIGHT" );

        local stringHeight = AddonUserText1:GetStringHeight();

        -- Now let's pin it!
        if i == 1 then
            AddonUserText1:SetPoint( "TOPLEFT" , GRM_AddonUsersScrollChildFrame , 2 , - 5 );
            AddonUserText2:SetPoint( "TOP" , GRM_AddonUsersScrollChildFrame , 0 , - 5 );
            AddonUserText3:SetPoint( "TOPRIGHT" , GRM_AddonUsersScrollChildFrame , -17 , - 5 );
            scrollHeight = scrollHeight + stringHeight;
        else
            AddonUserText1:SetPoint( "TOPLEFT" , GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i - 1][1] , "BOTTOMLEFT" , 0 , - buffer );
            AddonUserText2:SetPoint( "TOPLEFT" , GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i - 1][2] , "BOTTOMLEFT" , 0 , - buffer );
            AddonUserText3:SetPoint( "TOPLEFT" , GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i - 1][3] , "BOTTOMLEFT" , 0 , - buffer );
            scrollHeight = scrollHeight + stringHeight + buffer;
        end
        AddonUserText1:Show();
        AddonUserText2:Show();
        AddonUserText3:Show();
    end
            
    -- Hides all the additional strings... if necessary ( necessary because some people may have logged off thus you need to hide those frames)
    for i = #GRM_AddonGlobals.currentAddonUsers + 1 , #GRM_AddonUsersScrollChildFrame.AllFrameFontstrings do
        GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][1]:Hide();
        GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][2]:Hide();
        GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][3]:Hide();
    end 

    -- Update the size -- it either grows or it shrinks!
    GRM_AddonUsersScrollChildFrame:SetSize ( scrollWidth , scrollHeight );

    --Set Slider Parameters ( has to be done after the above details are placed )
    local scrollMax = ( scrollHeight - 145 ) + ( buffer * .5 );  -- 18 comes from fontSize (11) + buffer (7);
    if scrollMax < 0 then
        scrollMax = 0;
    end
    GRM_AddonUsersScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
    -- Mousewheel Scrolling Logic
    GRM_AddonUsersScrollFrame:EnableMouseWheel( true );
    GRM_AddonUsersScrollFrame:SetScript( "OnMouseWheel" , function( self , delta )
        local current = GRM_AddonUsersScrollFrameSlider:GetValue();
        
        if IsShiftKeyDown() and delta > 0 then
            GRM_AddonUsersScrollFrameSlider:SetValue ( 0 );
        elseif IsShiftKeyDown() and delta < 0 then
            GRM_AddonUsersScrollFrameSlider:SetValue ( scrollMax );
        elseif delta < 0 and current < scrollMax then
            GRM_AddonUsersScrollFrameSlider:SetValue ( current + 20 );
        elseif delta > 0 and current > 1 then
            GRM_AddonUsersScrollFrameSlider:SetValue ( current - 20 );
        end
    end);

    -- Statement on who is using the addon!
    if #GRM_AddonGlobals.currentAddonUsers == 0 then
        local numGuildiesOnline = GRM.GetNumGuildiesOnline( false ) - 1; -- Don't include yourself!
        local result = "No Guildie Online With Addon.";
        if numGuildiesOnline == 1 then
            result = result .. "\nONE Person is Online. Recommend It!";
        elseif numGuildiesOnline > 1 then
            result = result .. "\n" .. numGuildiesOnline .. " Others are Online! Recommend It!";
        end
        GRM_AddonUsersScrollChildFrame.GRM_AddonUsersCoreFrameTitleText2:SetText ( result );
        GRM_AddonUsersScrollChildFrame.GRM_AddonUsersCoreFrameTitleText2:Show();
    end
end

-- Method:          RefreshAddonUserFrames()
-- What it Does:    It Initializes and rebuilds the frames to see who you are syncing with in the guild and if not, why not.
-- Purpose:         Purely quality of life information.
GRM.RefreshAddonUserFrames = function()
    -- To prevent double spam...
    GRM_AddonGlobals.timer5 = 0;

    -- Notification that player has sync disabled themselves.
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
        GRM_UI.GRM_AddonUsersCoreFrame.GRM_AddonUsersSyncEnabledText:Hide();
    else
        GRM_UI.GRM_AddonUsersCoreFrame.GRM_AddonUsersSyncEnabledText:Show();
    end

    -- Now, let's load and refresh the data!
    GRM.RegisterGuildAddonUsersRefresh ();
    GRM.BuildAddonUserScrollFrame();
end 

-- Method:          GRM.RefreshAddEventFrame();
-- What it Does:    Refreshes the details, in case an event happes WHILE the window is open
-- Purpose:         QOL - Clean user experience. User it not forced to close window and reopen it to trigger updates. This will be used on the fly.
GRM.RefreshAddEventFrame = function()
    -- Clear the buttons first
    if GRM_AddEventScrollChildFrame.allFrameButtons ~= nil then
        for i = 1 , #GRM_AddEventScrollChildFrame.allFrameButtons do
            GRM_AddEventScrollChildFrame.allFrameButtons[i][1]:Hide();
            GRM_AddEventScrollChildFrame.allFrameButtons[i][1]:UnlockHighlight();
        end
    end
    -- Status Notification logic
    if #GRM_CalendarAddQue_Save > 0 then
        GRM_AddEventFrameStatusMessageText:SetText ( "Please Select\na Player" );
        GRM_AddEventFrameStatusMessageText:Show();
        GRM_AddEventFrameNameToAddText:Hide();
        GRM_AddEventFrameNameDateText:Hide();
    else
        GRM_AddEventFrameStatusMessageText:SetText ( "No Events\nto Add");
        GRM_AddEventFrameStatusMessageText:Show();
        GRM_AddEventFrameNameToAddText:Hide();
        GRM_AddEventFrameNameDateText:Hide();
    end
    -- Ok Building Frame!
    GRM.BuildEventCalendarManagerScrollFrame();
end

-- Method:          GRM.FinalReport()
-- What it Does:    Organizes flow of final report and send it to chat frame and to the logReport.
-- Purpose:         Clean organization for presentation.
GRM.FinalReport = function()
    local needToReport = false;

    if #GRM_AddonGlobals.TempNewMember > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] then
        for i = 1 , #GRM_AddonGlobals.TempNewMember do
            GRM.PrintLog ( GRM_AddonGlobals.TempNewMember[i][1] , GRM_AddonGlobals.TempNewMember[i][2] , GRM_AddonGlobals.TempNewMember[i][3] );   -- Send to print to chat window
        end
    end
   
    if #GRM_AddonGlobals.TempRejoin > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] then
        for i = 1 , #GRM_AddonGlobals.TempRejoin do
            GRM.PrintLog ( GRM_AddonGlobals.TempRejoin[i][1] , GRM_AddonGlobals.TempRejoin[i][2] , GRM_AddonGlobals.TempRejoin[i][3] );            -- Same Comments on down
            GRM.PrintLog ( GRM_AddonGlobals.TempRejoin[i][4] , GRM_AddonGlobals.TempRejoin[i][5] , GRM_AddonGlobals.TempRejoin[i][3] );
            if GRM_AddonGlobals.TempRejoin[i][6] then
                GRM.PrintLog ( GRM_AddonGlobals.TempRejoin[i][7] , GRM_AddonGlobals.TempRejoin[i][8] );
            end
        end
    end

    if #GRM_AddonGlobals.TempBannedRejoin > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] then
        for i = 1 , #GRM_AddonGlobals.TempBannedRejoin do
            GRM.PrintLog ( GRM_AddonGlobals.TempBannedRejoin[i][1] , GRM_AddonGlobals.TempBannedRejoin[i][2] , GRM_AddonGlobals.TempBannedRejoin[i][3] );
            GRM.PrintLog ( GRM_AddonGlobals.TempBannedRejoin[i][4] , GRM_AddonGlobals.TempBannedRejoin[i][5] , GRM_AddonGlobals.TempBannedRejoin[i][3] );
            if GRM_AddonGlobals.TempBannedRejoin[i][6] then
                GRM.PrintLog ( GRM_AddonGlobals.TempBannedRejoin[i][7] , GRM_AddonGlobals.TempBannedRejoin[i][8] );
            end
        end
    end

    if #GRM_AddonGlobals.TempLeftGuild > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][11] then
        for i = 1 , #GRM_AddonGlobals.TempLeftGuild do
            GRM.PrintLog ( GRM_AddonGlobals.TempLeftGuild[i][1] , GRM_AddonGlobals.TempLeftGuild[i][2] , GRM_AddonGlobals.TempLeftGuild[i][3] );
        end
    end

    if #GRM_AddonGlobals.TempInactiveReturnedLog > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][3] then
        for i = 1 , #GRM_AddonGlobals.TempInactiveReturnedLog do
            GRM.PrintLog ( GRM_AddonGlobals.TempInactiveReturnedLog[i][1] , GRM_AddonGlobals.TempInactiveReturnedLog[i][2] , GRM_AddonGlobals.TempInactiveReturnedLog[i][3] );
        end
    end

    if #GRM_AddonGlobals.TempNameChanged > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][8] then
        for i = 1 , #GRM_AddonGlobals.TempNameChanged do
            GRM.PrintLog ( GRM_AddonGlobals.TempNameChanged[i][1] , GRM_AddonGlobals.TempNameChanged[i][2] , GRM_AddonGlobals.TempNameChanged[i][3] );
        end
    end

    if #GRM_AddonGlobals.TempLogPromotion > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] then
        for i = 1 , #GRM_AddonGlobals.TempLogPromotion do
            GRM.PrintLog ( GRM_AddonGlobals.TempLogPromotion[i][1] , GRM_AddonGlobals.TempLogPromotion[i][2] , GRM_AddonGlobals.TempLogPromotion[i][3] );
        end
    end

    if #GRM_AddonGlobals.TempLogDemotion > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][5] then
        for i = 1 , #GRM_AddonGlobals.TempLogDemotion do
            GRM.PrintLog ( GRM_AddonGlobals.TempLogDemotion[i][1] , GRM_AddonGlobals.TempLogDemotion[i][2] , GRM_AddonGlobals.TempLogDemotion[i][3] );                          
        end
    end

    if #GRM_AddonGlobals.TempRankRename > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][9] then
        for i = 1 , #GRM_AddonGlobals.TempRankRename do
            GRM.PrintLog ( GRM_AddonGlobals.TempRankRename[i][1] , GRM_AddonGlobals.TempRankRename[i][2] , GRM_AddonGlobals.TempRankRename[i][3] );
        end
    end

    if #GRM_AddonGlobals.TempLogLeveled > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][2] then
        for i = 1 , #GRM_AddonGlobals.TempLogLeveled do
            GRM.PrintLog ( GRM_AddonGlobals.TempLogLeveled[i][1] , GRM_AddonGlobals.TempLogLeveled[i][2] , GRM_AddonGlobals.TempLogLeveled[i][3] );                  
        end
    end

    if #GRM_AddonGlobals.TempLogNote > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][6] then
        for i = 1 , #GRM_AddonGlobals.TempLogNote do
            GRM.PrintLog ( GRM_AddonGlobals.TempLogNote[i][1] , GRM_AddonGlobals.TempLogNote[i][2] , GRM_AddonGlobals.TempLogNote[i][3] );         
        end
    end

    if #GRM_AddonGlobals.TempLogONote > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][7] then
        for i = 1 , #GRM_AddonGlobals.TempLogONote do
            GRM.PrintLog ( GRM_AddonGlobals.TempLogONote[i][1] , GRM_AddonGlobals.TempLogONote[i][2] , GRM_AddonGlobals.TempLogONote[i][3] );  
        end
    end

    if #GRM_AddonGlobals.TempEventReport > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][10] then
        for i = 1 , #GRM_AddonGlobals.TempEventReport do
            GRM.PrintLog ( GRM_AddonGlobals.TempEventReport[i][1] , GRM_AddonGlobals.TempEventReport[i][2] , GRM_AddonGlobals.TempEventReport[i][3] );
        end
    end

    if #GRM_AddonGlobals.TempEventRecommendKickReport > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][12] then
        for i = 1 , #GRM_AddonGlobals.TempEventRecommendKickReport do
            GRM.PrintLog ( GRM_AddonGlobals.TempEventRecommendKickReport[i][1] , GRM_AddonGlobals.TempEventRecommendKickReport[i][2] , GRM_AddonGlobals.TempEventRecommendKickReport[i][3]); 
        end
    end

    -- OK, NOW LET'S REPORT TO LOG FRAME IN REVERSE ORDER!!!

    if #GRM_AddonGlobals.TempEventRecommendKickReport > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempEventRecommendKickReport do
            GRM.AddLog ( GRM_AddonGlobals.TempEventRecommendKickReport[i][1] , GRM_AddonGlobals.TempEventRecommendKickReport[i][2]);                    
        end
    end

    if #GRM_AddonGlobals.TempEventReport > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempEventReport do
            GRM.AddLog( GRM_AddonGlobals.TempEventReport[i][1] , GRM_AddonGlobals.TempEventReport[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempLogONote > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempLogONote do
            GRM.AddLog ( GRM_AddonGlobals.TempLogONote[i][1] , GRM_AddonGlobals.TempLogONote[i][2] );                    
        end
    end
 
    if #GRM_AddonGlobals.TempLogNote > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempLogNote do
            GRM.AddLog ( GRM_AddonGlobals.TempLogNote[i][1] , GRM_AddonGlobals.TempLogNote[i][2] );                    
        end
    end

    if #GRM_AddonGlobals.TempLogLeveled > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempLogLeveled do
            GRM.AddLog ( GRM_AddonGlobals.TempLogLeveled[i][1] , GRM_AddonGlobals.TempLogLeveled[i][2] );                    
        end
    end

    if #GRM_AddonGlobals.TempRankRename > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempRankRename do
            GRM.AddLog ( GRM_AddonGlobals.TempRankRename[i][1] , GRM_AddonGlobals.TempRankRename[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempLogDemotion > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempLogDemotion do
            GRM.AddLog ( GRM_AddonGlobals.TempLogDemotion[i][1] , GRM_AddonGlobals.TempLogDemotion[i][2] );                           
        end
    end

    if #GRM_AddonGlobals.TempLogPromotion > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempLogPromotion do
            GRM.AddLog ( GRM_AddonGlobals.TempLogPromotion[i][1] , GRM_AddonGlobals.TempLogPromotion[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempNameChanged > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempNameChanged do
            GRM.AddLog ( GRM_AddonGlobals.TempNameChanged[i][1] , GRM_AddonGlobals.TempNameChanged[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempInactiveReturnedLog > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempInactiveReturnedLog do
            GRM.AddLog ( GRM_AddonGlobals.TempInactiveReturnedLog[i][1] , GRM_AddonGlobals.TempInactiveReturnedLog[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempLeftGuild > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempLeftGuild do
            GRM.AddLog ( GRM_AddonGlobals.TempLeftGuild[i][1] , GRM_AddonGlobals.TempLeftGuild[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempBannedRejoin > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempBannedRejoin do
            if GRM_AddonGlobals.TempBannedRejoin[i][6] then
                GRM.AddLog ( GRM_AddonGlobals.TempBannedRejoin[i][7] , GRM_AddonGlobals.TempBannedRejoin[i][8] );
            end
            GRM.AddLog ( GRM_AddonGlobals.TempBannedRejoin[i][4] , GRM_AddonGlobals.TempBannedRejoin[i][5] );
            GRM.AddLog ( GRM_AddonGlobals.TempBannedRejoin[i][1] , GRM_AddonGlobals.TempBannedRejoin[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempRejoin > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempRejoin do
            if GRM_AddonGlobals.TempRejoin[i][6] then
                GRM.AddLog ( GRM_AddonGlobals.TempRejoin[i][7] , GRM_AddonGlobals.TempRejoin[i][8] );
            end
            GRM.AddLog ( GRM_AddonGlobals.TempRejoin[i][4] , GRM_AddonGlobals.TempRejoin[i][5] );
            GRM.AddLog ( GRM_AddonGlobals.TempRejoin[i][1] , GRM_AddonGlobals.TempRejoin[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempNewMember > 0 then
        needToReport = true;
        for i = 1 , #GRM_AddonGlobals.TempNewMember do
            GRM.AddLog ( GRM_AddonGlobals.TempNewMember[i][1] , GRM_AddonGlobals.TempNewMember[i][2] );                                           -- Adding to the Log of Events
        end
    end


    -- Update the Add Event Window
    if #GRM_AddonGlobals.TempEventReport > 0 and GRM_AddEventFrame:IsVisible() then
        GRM.RefreshAddEventFrame();
    end

    -- Clear the changes.
    GRM.ResetTempLogs();

    -- Let's update the frames!
    if needToReport and GRM_RosterChangeLogFrame ~= nil and GRM_RosterChangeLogFrame:IsVisible() then
        GRM.BuildLog();
    end
    GRM_AddonGlobals.changeHappenedExitScan = false;
end  

-- Method:          GRM.RecordKickChanges ( string , string , string , boolean )
-- What it Does:    Records and logs the changes for when a guildie either is KICKED or leaves the guild
-- Purpose:         Having its own function saves on repeating a lot of code here.
GRM.RecordKickChanges = function ( unitName , simpleName , guildName , playerKicked )
    local timestamp = GRM.GetTimestamp();
    local logReport = "";
    local tempStringRemove = "";

    if not playerKicked then
        tempStringRemove = GRM.GetGuildEventString ( 3 , simpleName ); -- Kicked from the guild.
        if tempStringRemove ~= nil and tempStringRemove ~= "" then
            logReport = ( timestamp .. " : " .. tempStringRemove );
        else
            logReport = ( timestamp .. " : " .. simpleName .. " has Left the guild" );
        end
    else
        -- The player kicked them right now!
        logReport = ( timestamp .. " : " .. GRM.SlimName ( GRM_AddonGlobals.addonPlayerName ) .. " KICKED " .. simpleName .. " from the Guild!" );
    end
    
    -- Finding Player's record for removal of current guild and adding to the Left Guild table.
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do  -- Scanning through all entries
        if unitName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then -- Matching member leaving to guild saved entry
            -- Found!
            table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][15], timestamp );                                  -- leftGuildDate
            table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][16], time() );                                     -- leftGuildDateMeta
            table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] , { "|cFFC41F3BLeft Guild" , GRM.Trim ( string.sub ( timestamp , 1 , 10 ) ) } );
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][19] = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][4];         -- old Rank on leaving.
            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20] == 0 then                                                 -- Let it default to date addon was installed if date joined was never given
                table.insert( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][2] );   -- oldJoinDate
                table.insert( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][21] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][3] );   -- oldJoinDateMeta
            end

            -- If not banned, then let's ensure we reset his data.
            if not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][1] then
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][1] = false;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][2] = 0;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][3] = false;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][18] = "";
            end
            -- Adding to LeftGuild Player history library
            table.insert ( GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j] );
                    
            -- Removing it from the alt list
            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                -- Let's add them to the end of the report
                local countAlts = #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];
                for m = 1 , countAlts do
                    if m == 1 then
                        logReport = logReport .. "\n ALTS IN GUILD: " .. GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] );
                    else
                        logReport = logReport .. ", " .. GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][m][1] );
                    end

                    -- Just show limited number of alts...
                    if m == 5 and m < countAlts then
                        logReport = logReport .. " (+" .. ( countAlts - m ) .. " More)";
                        break;
                    end
                end

                GRM.RemoveAlt ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] ,GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , guildName , false , 0 );
            end
            -- removing from active member library
            table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] , j );
            
            break;
        end
    end
    -- Update the live frames too!
    if GRM_UI.GRM_CoreBanListFrame:IsVisible() then
        GRM.RefreshBanListFrames();
    end
    return logReport;
end

-- Method:          GRM.RecordJoinChanges ( array , string )
-- What it Does:    Checks and records the new player changes... are they a returning player or completely new. Were they previously banned?
-- Purpose:         Keep the methods clean by compartmentalizing this rather lengthy function. It is also useful to not double the code as this will be called to on a live tracked event.
GRM.RecordJoinChanges = function ( memberInfo , simpleName )
    -- Check against old member list first to see if returning player!
    local rejoin = false;
    local logReport = "";
    local tempStringInv = GRM.GetGuildEventString ( 4 , simpleName ); -- For determining who did the invite.

        for j = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID] do -- Number of players that have left the guild.
            if memberInfo[1] == GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][1] then
                -- MATCH FOUND - Player is RETURNING to the guild!
                -- Now, let's see if the player was banned before!
                local numTimesInGuild = #GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][20];
                local numTimesString = "";
                if numTimesInGuild > 1 then
                    numTimesString = ( simpleName .. " has Been in the Guild " .. numTimesInGuild .. " Times Before" );
                else
                    numTimesString = ( simpleName .. " is Returning for the First Time." );
                end

                local timeStamp = GRM.GetTimestamp();
                if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][17][1] then
                    -- Player was banned! WARNING!!!
                    local reasonBanned = GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][18];
                    if reasonBanned == nil or reasonBanned == "" then
                        reasonBanned = "<None Given>";
                    end
                    local warning = "";
                    if tempStringInv ~= nil and tempStringInv ~= "" then
                        warning = ( "     " .. timeStamp .. " :\n---------- WARNING! WARNING! WARNING! WARNING! ----------\n" .. simpleName .. " has REJOINED the guild but was previously BANNED! \nInvited by: " .. string.sub ( tempStringInv , 1 , string.find ( tempStringInv , " " ) - 1 ) );
                    else
                        warning = ( "     " .. timeStamp .. " :\n---------- WARNING! WARNING! WARNING! WARNING! ----------\n" .. simpleName .. " has REJOINED the guild but was previously BANNED!" );
                    end
                    logReport = ("Date of Ban:                       " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][15][#GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][15]] .. " (" .. GRM.GetTimePassed ( GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][16][#GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][16]] ) .. " ago)\nReason:                               " .. reasonBanned .. "\nDate Originally Joined:    " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][20][1] .. "\nOld Guild Rank:                 " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][19] .. "\n" .. numTimesString );
                    local custom = "";
                    local toReport = { 9 , warning , false , 12 , logReport , false , 13 , custom };
                    -- Extra Custom Note added for returning players.
                    if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][23] ~= "" then
                        custom = ( "Notes:     " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][23] );
                        toReport[6] = true;
                        toReport[8] = custom;
                    end
                    table.insert ( GRM_AddonGlobals.TempBannedRejoin , toReport );
                else
                    -- No Ban found, player just returning!
                    if tempStringInv ~= nil and tempStringInv ~= "" then
                        logReport = ( timeStamp .. " : " .. string.sub ( tempStringInv , 1 , string.find ( tempStringInv , " " ) - 1 ) .. " has REINVITED " .. simpleName .. " to the guild (LVL: " .. memberInfo[4] .. ")");
                    else
                        logReport = ( timeStamp .. " : " .. simpleName .. " has REJOINED the guild (LVL: " .. memberInfo[4] .. ")");
                    end
                    local custom = "";
                    local details = ( "Date Left:                           " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][15][#GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][15]] .. " (" .. GRM.GetTimePassed(GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][16][#GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][16]]) .. " ago)\nDate Originally Joined:    " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][20][1] .. "\nOld Guild Rank:                 " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][19] .. "\n" .. numTimesString );
                    local toReport = { 7 , logReport , false , 12 , details , false , 13 , custom };
                    -- Extra Custom Note added for returning players.
                    if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][23] ~= "" then
                        custom = ( "Notes:     " .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j][23]) ;
                        toReport[6] = true;
                        toReport[8] = custom;
                    end
                    table.insert ( GRM_AddonGlobals.TempRejoin , toReport );
                end
                rejoin = true;
                -- AddPlayerTo MemberHistory

                -- Adding timestamp to new Player.
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] and CanEditOfficerNote() then
                    for h = 1 , GRM.GetNumGuildies() do
                        local name ,_,_,_,_,_,_, oNote = GetGuildRosterInfo( h );
                        if name == memberInfo[1] and oNote == "" then
                            GuildRosterSetOfficerNote( h , ( "Rejoined: " .. GRM.Trim ( string.sub ( GRM.GetTimestamp() , 1 , 10 ) ) ) );
                            break;
                        end
                    end
                end
                -- Do extra query
                GuildRoster();

                GRM.AddMemberRecord( memberInfo , true , GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID][j] , guildName );
                
                -- Removing Player from LeftGuild History (Yes, they will be re-added upon leaving the guild.)
                table.remove ( GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID] , j );
                break;
            end
        end
            
    if rejoin ~= true then
        -- New Guildie. NOT a rejoin!
        local tempTimeStamp = GRM.GetTimestamp();
        local timeEpoch = time();
        if tempStringInv ~= nil and tempStringInv ~= "" then
            logReport = ( GRM.GetTimestamp() .. " : " .. simpleName .. " has JOINED the guild! (LVL: " .. memberInfo[4] .. ") - Invited By: " .. string.sub ( tempStringInv , 1 , string.find ( tempStringInv , " " ) - 1 ) );
        else
            logReport = ( tempTimeStamp .. " : " .. simpleName .. " has JOINED the guild! (LVL: " .. memberInfo[4] .. ")");
        end
        local finalTStamp = ( "Joined: " .. GRM.Trim ( string.sub ( GRM.GetTimestamp() , 1 , 10 ) ) );

        -- Adding timestamp to new Player.
        local currentOfficerNote = memberInfo[6];
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] and CanEditOfficerNote() then
            for s = 1 , GRM.GetNumGuildies() do
                local name ,_,_,_,_,_,_, oNote = GetGuildRosterInfo ( s );
                if name == memberInfo[1] and ( oNote == "" or oNote == nil ) then
                    GuildRosterSetOfficerNote ( s , finalTStamp );
                    break;
                end
            end
        end
        -- Do extra query
        GuildRoster();

        -- Adding to global saved array, adding to report 
        GRM.AddMemberRecord ( memberInfo , false , nil , guildName );
        table.insert ( GRM_AddonGlobals.TempNewMember , { 8 , logReport , false } );
        
        -- adding join date to history and rank date.
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                     -- Number of players that have left the guild.
            if memberInfo[1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then
                -- Add the tempTimeStamp to officer note... this avoids report spam

                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][12] = string.sub ( tempTimeStamp , 1 , string.find ( tempTimeStamp , "'" ) + 2 );  -- Date of Last Promotion
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][13] = timeEpoch;                                                       -- Date of Last Promotion Epoch time.
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20] , tempTimeStamp );
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][21] , timeEpoch );
                -- For Event tracking!
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][1][2] = tempTimeStamp;

                if currentOfficerNote == nil or currentOfficerNote == "" then
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][8] = finalTStamp;
                    -- For SYNC
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][35][1] = tempTimeStamp;
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][35][2] = timeEpoch;

                elseif currentOfficerNote ~= nil and currentOfficerNote ~= "" then
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][8] = currentOfficerNote;
                    -- For SYNC
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][35][1] = "1 Jan '01 4:20am";  -- Behind the scenes numbers ensuring you are not the person with most current sync info.
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][35][2] = 978348001;
                end
                break;
            end
        end
    end
end

-- Method           GRM.RecordChanges()
-- What it does:    Builds all the changes, sorts them, then adds them to change report
-- Purpose:         Consolidation of data for final output report.
GRM.RecordChanges = function ( indexOfInfo , memberInfo , memberOldInfo , guildName )
    if GRM_AddonGlobals.changeHappenedExitScan then
        GRM.ResetTempLogs();
        GRM_AddonGlobals.changeHappenedExitScan = false;
        return;
    end
    local logReport = "";
    local simpleName = "";
    if memberInfo[1] == nil then
        simpleName = GRM.SlimName ( memberInfo );
    else
        simpleName = GRM.SlimName ( memberInfo[1] );
    end

    -- 2 = Guild Rank Promotion
    if indexOfInfo == 2 then
        local tempString = GRM.GetGuildEventString ( 2 , simpleName );
        if tempString ~= nil and tempString ~= "" then
            logReport = ( GRM.GetTimestamp() .. " : " .. tempString .. " from " .. memberOldInfo[4] .. " to " .. memberInfo[2] );
        else
            logReport = ( GRM.GetTimestamp() .. " : " .. simpleName .. " has been PROMOTED from " .. memberOldInfo[4] .. " to " .. memberInfo[2] );
        end
        table.insert ( GRM_AddonGlobals.TempLogPromotion , { 1 , logReport , false } );
    -- 9 = Guild Rank Demotion
    elseif indexOfInfo == 9 then
        local tempString = GRM.GetGuildEventString ( 1 , simpleName );
        if tempString ~= nil and tempString ~= "" then
            logReport = ( GRM.GetTimestamp() .. " : " .. tempString .. " from " .. memberOldInfo[4] .. " to " .. memberInfo[2] );
        else
            logReport = ( GRM.GetTimestamp() .. " : " .. simpleName .. " has been DEMOTED from " .. memberOldInfo[4] .. " to " .. memberInfo[2] );
        end
        table.insert ( GRM_AddonGlobals.TempLogDemotion , { 2 , logReport , false } );
    -- 4 = level
    elseif indexOfInfo == 4 then
        local numGained = memberInfo[4] - memberOldInfo[6];
        if numGained > 1 then
            logReport = ( GRM.GetTimestamp() .. " : " .. simpleName .. " has Leveled to " .. memberInfo[4] .. " (+ " .. numGained .. " levels)" );
        else
            logReport = ( GRM.GetTimestamp() .. " : " .. simpleName .. " has Leveled to " .. memberInfo[4] .. " (+ " .. numGained .. " level)" );
        end
        table.insert ( GRM_AddonGlobals.TempLogLeveled , { 3 , logReport , false } );
    -- 5 = note
    elseif indexOfInfo == 5 then
        logReport = ( GRM.GetTimestamp() .. " : " .. simpleName .. "'s PUBLIC Note has Changed\nFrom:  " .. memberOldInfo[7] .. "\nTo:       " .. memberInfo[5] );
        table.insert ( GRM_AddonGlobals.TempLogNote , { 4 , logReport , false } );
    -- 6 = officerNote
    elseif indexOfInfo == 6 then
        logReport = ( GRM.GetTimestamp() .. " : " .. simpleName .. "'s OFFICER Note has Changed\nFrom:  " .. memberOldInfo[8] .. "\nTo:       " .. memberInfo[6] );
        table.insert ( GRM_AddonGlobals.TempLogONote , { 5 , logReport , false } );
    -- 8 = Guild Rank Name Changed to something else
    elseif indexOfInfo == 8 then
        logReport = ( GRM.GetTimestamp() .. " : Guild Rank Renamed from " .. memberOldInfo[4] .. " to " .. memberInfo[2] );
        table.insert ( GRM_AddonGlobals.TempRankRename , { 6 , logReport , false } );
    -- 10 = New Player
    elseif indexOfInfo == 10 then
        -- Check against old member list first to see if returning player!
        GRM.RecordJoinChanges ( memberInfo , simpleName );
    -- 11 = Player Left  
    elseif indexOfInfo == 11 then
        logReport = GRM.RecordKickChanges( memberInfo[1] , simpleName , guildName , false );
        table.insert( GRM_AddonGlobals.TempLeftGuild , { 10 , logReport , false } );
    -- 12 = NameChanged
    elseif indexOfInfo == 12 then
        logReport = ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( memberOldInfo[1] ) .. " has Name-Changed to ".. simpleName );
        table.insert ( GRM_AddonGlobals.TempNameChanged , { 11 , logReport , false } );
    -- 13 = Inactive Members Return!
    elseif indexOfInfo == 13 then
        logReport = ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( memberInfo ) .. " has Come ONLINE after being INACTIVE for " .. GRM.HoursReport ( memberOldInfo ) );
        table.insert( GRM_AddonGlobals.TempInactiveReturnedLog , { 14 , logReport , false } );
    end
end

-- Method:          GRM.ReportLastOnline( string , string , int )
-- What it Does:    Like the "GRM.CheckPlayerChanges()", this one does a one time scan on login or reload of notable changes of players who have returned from being offline for an extended period of time.
-- Purpose:         To inform the guild leader that a guildie who has not logged in in a while has returned!
GRM.ReportLastOnline = function ( name , guildName , index )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                           -- Scanning through roster so can check changes (position 1 is guild name, so no need to rescan)
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then                 -- Player matched.
            local hours = GRM.GetHoursSinceLastOnline ( index );            -- index is location in in-game Guild Roster for lookup to only query server one time, not multiple.
            
            -- Report player return after being inactive!
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][11] and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][24] > GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][4] and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][24] > hours then  -- Player has logged in after having been inactive for greater than 2 weeks!
                GRM.RecordChanges ( 13 , name , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][24] , guildName );      -- Recording the change in hours to log
            end

            -- Recommend to kick offline if player has the power to!
            if CanGuildRemove() then
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][10] and not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][27] and ( 30 * 24 * GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][9] ) <= hours then
                    -- Player has been offline for longer than the given time... REPORT RECOMMENDATION TO KICK!!!
                    local logReport = ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( name ) .. " has been OFFLINE for " .. GRM.HoursReport ( hours ) .. ". Kick Recommended!" );
                    table.insert ( GRM_AddonGlobals.TempEventRecommendKickReport , { 16 , logReport , false } );
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][27] = true;    -- No need to report more than once.
                elseif GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][27] and ( 30 * 24 * GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][9] ) > hours  then
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][27] = false;
                end
            end
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][24] = hours;                   -- Set new hours since last login.
            break;
        end
    end
end

-- Method:          GRM.CheckPlayerChanges ( array , string )
-- What it Does:    Scans through guild roster and re-checks for any  (Will only fire if guild is found!)
-- Purpose:         Keep whoever uses the addon in the know instantly of what is going and changing in the guild.
GRM.CheckPlayerChanges = function ( metaData , guildName )
    if GRM_AddonGlobals.changeHappenedExitScan then
        GRM.ResetTempLogs();
        GRM_AddonGlobals.changeHappenedExitScan = false;
        return;
    end
    local newPlayerFound;
    local guildRankIndexIfChanged = -1; -- Rank index must start below zero, as zero is Guild Leader.

    -- new member and leaving members arrays to check at the end
    local newPlayers = {};
    local leavingPlayers = {};

    for j = 1 , #metaData do
        newPlayerFound = true;
        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do -- Number of members in guild (Position 1 = guild name, so we skip)
            if metaData[j][1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] then
                newPlayerFound = false;
                for k = 2 , 14 do
                    
                    if k ~= 3 and k < 7 and metaData[j][k] ~= GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][k + 2] then -- CHANGE FOUND! New info and old info are not equal!
                        -- Ranks
                        if k == 2 and metaData[j][3] ~= GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] and metaData[j][2] ~= GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] then -- This checks to see if guild just changed the name of a rank.
                            -- Promotion Obtained
                            if metaData[j][3] < GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] then
                                GRM.RecordChanges ( k , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                            -- Demotion Obtained
                            elseif metaData[j][3] > GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] then
                                GRM.RecordChanges ( 9 , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                            end
                            local timestamp = GRM.GetTimestamp();
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] = metaData[j][2]; -- Saving new rank Info
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] = metaData[j][3]; -- Saving new rank Index Info
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] = string.sub ( timestamp , 1 , string.find ( timestamp , "'" ) + 2 ) -- Time stamping rank change
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13] = time();

                            -- For SYNC
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][1] = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12];
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][2] = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13];

                            table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25] , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13] } ); -- New rank, date, metatimestamp
                            
                            -- Update the player index if it is the player themselves that received the change in rank.
                            if metaData[j][1] == GRM_AddonGlobals.addonPlayerName then
                                GRM_AddonGlobals.playerIndex = metaData[j][3];

                                -- Let's do a resync check as well... If permissions have changed, we should resync check em.
                                -- First, RESET all..
                                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and not GRMsyncGlobals.currentlySyncing and GRM_AddonGlobals.HasAccessToGuildChat then
                                    GRMsync.TriggerFullReset();
                                    -- Now, let's add a brief delay, 3 seconds, to trigger sync again
                                    C_Timer.After ( 3 , GRMsync.Initialize );
                                end

                                GRM_UI.BuildLogFrames();
                                
                                -- Determine if player has access to guild chat or is in restricted chat rank - need to recheck with rank change.
                                GRM_AddonGlobals.HasAccessToGuildChat = false;
                                GRM_AddonGlobals.HasAccessToOfficerChat = false;
                                GRM.RegisterGuildChatPermission();
                            end
                        elseif k == 2 and metaData[j][2] ~= GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] and metaData[j][3] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] then
                            -- RANK RENAMED!
                            if guildRankIndexIfChanged ~= metaData[j][3] then -- If alrady been reported, no need to report it again.
                                GRM.RecordChanges ( 8 , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                                guildRankIndexIfChanged = metaData[j][3]; -- Avoid repeat reporting for each member of that rank upon a namechange.
                            end
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] = metaData[j][2]; -- Saving new Info
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25][#GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25]][1] = metaData[j][2];   -- Adjusting the historical name if guild rank changes.
                        -- Level
                        elseif k == 4 then
                            GRM.RecordChanges ( k , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][6] = metaData[j][4]; -- Saving new Info
                        -- Note
                        elseif k == 5 then
                            GRM.RecordChanges ( k , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][7] = metaData[j][5];
                        -- Officer Note
                        elseif k == 6 and CanViewOfficerNote() then
                            if metaData[j][k] == nil or GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8] == nil then
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8] = metaData[j][6];
                            else
                                GRM.RecordChanges ( k , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8] = metaData[j][6];
                            end
                        end

                        -- Zone Last Spotted
                    elseif k == 9 then
                        if ( metaData[j][13] and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= metaData[j][9] ) or GRM_AddonGlobals.OnFirstLoad then     -- If player is currently online and in a different zone! - Also, you need to reset on first load anyway because if player has not zone-changed when you login, you will get crazy long hours and it will be wrong.
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] = time();                                                                          -- Resetting the time on hitting this zone.
                        end
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] = metaData[j][9];
                    -- Player non-account wide achievement points total
                    elseif k == 10 then
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][29] = metaData[j][10];
                    -- Player is not online in-game, but is on Mobile armory app for chat
                    elseif k == 11 then
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][30] = metaData[j][11];
                    -- GuilD reputation ( 8 = exalted)
                    elseif k == 12 then
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][31] = metaData[j][12];
                    elseif k == 13 then
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] ~= metaData[j][13] then
                            -- Status has changed!!!
                            -- Let's see if there is a list to check
                            if #GRM_AddonGlobals.ActiveStatusQue > 0 then
                                -- There is! Let's see if player is on notification list to announce if returns from being AFK.
                                if metaData[j][13] then
                                    -- Nice, player is now active and was not before!!! Let's see if they are on the list!
                                    for m = 1 , #GRM_AddonGlobals.ActiveStatusQue do
                                        if metaData[j][1] == GRM_AddonGlobals.ActiveStatusQue[m] then
                                            -- Player Has been found!
                                            chat:AddMessage ( "\n----------------------------------------------------------\n|cffffffffNOTIFICATION: " .. GRM.SlimName ( GRM_AddonGlobals.ActiveStatusQue[m] ) .. " is now ONLINE!\n|cffff0000----------------------------------------------------------\n\n" , 1.0 , 0 , 0 );
                                            table.remove ( GRM_AddonGlobals.ActiveStatusQue , m );
                                            break;
                                        end
                                    end
                                else
                                    for m = 1 , #GRM_AddonGlobals.ActiveStatusQue do
                                        if metaData[j][1] == GRM_AddonGlobals.ActiveStatusQue[m] then
                                            -- Player Has been found!
                                            chat:AddMessage ( "\n----------------------------------------------------------\n|cffffffffNOTIFICATION: " .. GRM.SlimName ( GRM_AddonGlobals.ActiveStatusQue[m] ) .. " is now OFFLINE!\n|cffff0000----------------------------------------------------------\n\n" , 1.0 , 0 , 0 );
                                            table.remove ( GRM_AddonGlobals.ActiveStatusQue , m );
                                            break;
                                        end
                                    end
                                end
                            end

                            -- Saving new info!
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] = metaData[j][13];
                        end
                    elseif k == 14 then
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][34] ~= metaData[j][14] then
                            -- Status has changed!!!
                            -- Let's see if there is a list to check
                            if #GRM_AddonGlobals.ActiveCheckQue > 0 then
                                -- There is! Let's see if player is on notification list to announce if returns from being AFK.
                                if metaData[j][14] == 0 then
                                    -- Nice, player is now active and was not before!!! Let's see if they are on the list!
                                    for m = 1 , #GRM_AddonGlobals.ActiveCheckQue do
                                        if metaData[j][1] == GRM_AddonGlobals.ActiveCheckQue[m] then
                                            -- Player Has been found!
                                            chat:AddMessage ( "\n---------------------------------------------------------------\n|cffffffffNOTIFICATION: " .. GRM.SlimName ( GRM_AddonGlobals.ActiveCheckQue[m] ) .. " is No Longer AFK or Busy!\n|cffff0000---------------------------------------------------------------\n\n" , 1.0 , 0 , 0 );
                                            table.remove ( GRM_AddonGlobals.ActiveCheckQue , m );
                                            break;
                                        end
                                    end
                                end
                            end

                            -- Saving new info!
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][34] = metaData[j][14];
                        end
                    end
                end
                break;
            end
        end
        -- NEW PLAYER FOUND! (Maybe)
        if newPlayerFound then
            newPlayers[#newPlayers + 1] = {};     -- Player "maybe" found. Let's store info to compare notes of players that left guild in case of name change.
            newPlayers[#newPlayers] = metaData[j];
        end
    end
    -- Checking if any players left the guild
    local playerLeftGuild;
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        playerLeftGuild = true;
        for k = 1 , #metaData do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == metaData[k][1] then
                playerLeftGuild = false;
                break;
            end
        end
        -- PLAYER LEFT! (maybe)
        if playerLeftGuild then
            table.insert ( leavingPlayers , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j] );
        end
    end
    -- Final check on players that left the guild to see if they are namechanges.CanViewOfficerNote
    local playerNotMatched = true;
    if #leavingPlayers > 0 and #newPlayers > 0 then
        for k = 1 , #leavingPlayers do
            for j = 1 , #newPlayers do
               if ( leavingPlayers[k] ~= nil and newPlayers[j] ~= nil ) and leavingPlayers[k][9] == newPlayers[j][7] -- Class is the sane
                    and leavingPlayers[k][5] == newPlayers[j][3]  -- Guild Rank is the same
                        and ( newPlayers[j][10] >= leavingPlayers[k][29] - 50 and newPlayers[j][10] <= leavingPlayers[k][29] + 100 ) then -- In other words, sometimes patches can remove achievements, so gives negative cushion, but assumes they didn't gain 100 + pts since last you noticed

                    -- PLAYER IS A NAMECHANGE!!!
                    playerNotMatched = false;
                    GRM.RecordChanges ( 12 , newPlayers[j] , leavingPlayers[k] , guildName );
                    for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if leavingPlayers[k][9] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][9] -- Mathching the Leaving player to historical index so it can be identified and new name stored.
                            and leavingPlayers[k][5] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5]
                                and leavingPlayers[k][29] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][29] then

                            -- Need to remove him from list of alts IF he has a lot of alts...
                            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][11] > 0 then
                                local tempNameToReAddAltTo = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][11][1][1];
                                GRM.RemoveAlt ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][11][1][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] , guildName , false , 0 );
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] = newPlayers[j][1]; -- Changing the name...
                                -- Now, let's re-add him back.
                                GRM.AddAlt ( tempNameToReAddAltTo , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] , guildName , false , 0 );
                            else
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] = newPlayers[j][1]; -- Changing the name!
                            end

                            break
                        end
                    end
                    -- since namechange identified, also need to remove name from newPlayers array now.
                    if #newPlayers == 1 then
                        newPlayers = {}; -- Clears the array of the one name.
                    else
                        local tempArray = {};
                        local count = 1;
                        for r = 1 , #newPlayers do -- removing the namechange from newPlayers list.
                            if r ~= j then  -- j = the position of the nameChanged player, so I am SKIPPING the nameChange player when adding to new array.
                                tempArray[count] = {};
                                tempArray[count] = newPlayers[r];
                                count = count + 1;
                            end
                        end
                        newPlayers = {};
                        newPlayers = tempArray;
                    end
                end
            end
            -- Player not matched! For sure this player has left the guild!
            if playerNotMatched then
                GRM.RecordChanges ( 11 , leavingPlayers[k] , leavingPlayers[k] , guildName );
            end
        end
    elseif #leavingPlayers > 0 then
        for k = 1 , #leavingPlayers do
            GRM.RecordChanges ( 11 , leavingPlayers[k] , leavingPlayers[k] , guildName );
        end
    end
    if #newPlayers > 0 then
        for k = 1 , #newPlayers do
            GRM.RecordChanges ( 10 , newPlayers[k] , newPlayers[k] , guildName );
        end
    end
end

-- Method:          GRM.GuildNameChanged()
-- What it Does:    Returns true if the player's guild is the same, it just changed its name
-- Purpose:         Good to know... what a pain it would be if you had to reset all of your settings
GRM.GuildNameChanged = function ( currentGuildName )
    local result = false;
    -- For each guild
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ][1] ~= currentGuildName then
            local numEntries = #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ] - 1;     -- Total number of entries, minus 1 since first index is guild name.
            local count = 0;
            -- for each member in that guild
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ] do
                for r = 1 , GRM.GetNumGuildies() do
                    local name = GetGuildRosterInfo ( r );
                    if name == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ][j][1] then
                        count = count + 1;
                        break;
                    end
                end

                if j == 10 and count == 0 then
                    break;
                end
            end
            if ( count / numEntries ) >= 0.5 then       -- Default threshold is > 50% matches. I would think it would be higher, but this keeps it so player can be 2 person guild, kick 1 person, change name, and it will stiill stay in threshold.
                -- Player is within the threshold
                result = true;
                local tempGuildName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ][1];

                -- Changing the name of the guild in the saved data to the new name.
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ][1] = currentGuildName;

                -- Need to change index name of the left player history too.
                for s = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ] do
                    if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][s][1] == tempGuildName then
                        GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][s][1] = currentGuildName;
                        break;
                    end
                end

                break;
            end
        end
    end
    return result;
end

-- Method:          GRM.BuildNewRoster()
-- What it does:    Rebuilds the roster to check against for any changes.
-- Purpose:         To track for guild changes of course!
GRM.BuildNewRoster = function()
    local roster = {};

    -- Checking if Guild Found or Not Found, to pre-check for Guild name tag.
    if GRM_AddonGlobals.faction == "Horde" then
        GRM_AddonGlobals.FID = 1;
    else
        GRM_AddonGlobals.FID = 2;
    end
    local guildNotFound = true;
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ] do
        if GRM_AddonGlobals.guildName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ][1] then
            guildNotFound = false;
            break;
        end
    end

    for i = 1 , GRM.GetNumGuildies() do
        local name , rank , rankInd , level , _ , zone , note , officerNote , online , status , class , achievementPoints , _ , isMobile , _ , rep = GetGuildRosterInfo ( i ); 
        roster[i] = {};
        roster[i][1] = name
        roster[i][2] = rank;
        roster[i][3] = rankInd;
        roster[i][4] = level;
        roster[i][5] = note;
        if CanViewOfficerNote() then -- Officer Note permission to view.
            roster[i][6] = officerNote;
        else
            roster[i][6] = nil; -- Set Officer note to nil if needed.
        end

        roster[i][7] = class;
        roster[i][8] = GRM.GetHoursSinceLastOnline ( i ); -- Time since they last logged in in hours.
        roster[i][9] = zone;
        roster[i][10] = achievementPoints;
        roster[i][11] = isMobile;
        roster[i][12] = rep;
        roster[i][13] = online;
        roster[i][14] = status;

        -- Items to check One time check on login
        -- Check players who have not been on a long time only on login or addon reload.
        if guildNotFound ~= true then
            GRM.ReportLastOnline ( name , GRM_AddonGlobals.guildName , i );
        end

    end
        -- Build Roster for the first time if guild not found.
    if #roster > 0 and GRM_AddonGlobals.guildName ~= nil and GRM_AddonGlobals.guildName ~= "" then
        if guildNotFound  then
            -- See if it is a Guild NameChange first!
            if GRM.GuildNameChanged ( GRM_AddonGlobals.guildName ) then
                local logEntry = "\n\n-------------------------------------------------------------\n" .. GRM.SlimName( GRM_AddonGlobals.addonPlayerName ) .. "'s Guild has Name-Changed to \n\"" .. GRM_AddonGlobals.guildName .. "\"\n-------------------------------------------------------------\n\n"
                GRM.PrintLog ( 15 , logEntry , false );   
                GRM.AddLog ( 15 , logEntry ); 
                -- ADD NEW GUILD VALUES
            else
                print ( "\nGUILD ROSTER MANAGER\nAnalyzing guild for the first time...\nBuilding Profiles on ALL \"" .. GRM_AddonGlobals.guildName .. "\" members.\n" );
                -- This reiterates over this, because sometimes it can have a delay. This ensures it is secure.
                if GRM_AddonGlobals.faction == "Horde" then
                    GRM_AddonGlobals.FID = 1;
                else
                    GRM_AddonGlobals.FID = 2;
                end
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ] , { GRM_AddonGlobals.guildName } );                        -- Creating a position in table for Guild Member Data
                table.insert ( GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ] , { GRM_AddonGlobals.guildName } );                    -- Creating a position in Left Player Table for Guild Member Data
                table.insert ( GRM_LogReport_Save[ GRM_AddonGlobals.FID ] , { GRM_AddonGlobals.guildName } );                                 -- Logreport, let's create an index
                table.insert ( GRM_CalendarAddQue_Save[ GRM_AddonGlobals.FID ] , { GRM_AddonGlobals.guildName } );                            -- AddQue, let's create an index for the guild
                table.insert ( GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ] , { GRM_AddonGlobals.guildName } );                          -- Adding index for the guild!

                -- SET THE INDEXES PROPERLY
                for i = 2 , #GRM_LogReport_Save[GRM_AddonGlobals.FID] do
                    if GRM_LogReport_Save[GRM_AddonGlobals.FID][i][1] ==  GRM_AddonGlobals.guildName then
                        GRM_AddonGlobals.logGID = i;
                        break;
                    end
                end
                for i = 2 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID] do
                    if GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.guildName then
                        GRM_AddonGlobals.saveGID = i;
                        break;
                    end
                end

                -- Adding properly to alts list for this guild...
                GRM_AddonGlobals.NeedsToAddSelfToList = true;

                for i = 1 , #roster do
                    -- Add last time logged in initial timestamp.
                    GRM.AddMemberRecord ( roster[i] , false , nil , GRM_AddonGlobals.guildName );
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][#GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ]][24] = roster[i][8];   -- Setting Timestamp for the first time only.
                end
            end
        else
            GRM.CheckPlayerChanges ( roster , GRM_AddonGlobals.guildName );
        end
    end
end


--------------------------------------
------ END OF METADATA LOGIC ---------
--------------------------------------



----------------------
-- EVENT TRACKING!!!!!
----------------------

-- Method:          GRM.GetEventYear ( string )
-- What it Does:    Returns the year of the given event from timestamp as a string
-- Purpose:         Keep code clutter down, put this block in reusable form.
GRM.GetEventYear = function ( timestamp )
    -- timestamp format = "Day month year hour min"
    local count = 0;
    local result = "";
    if timestamp ~= "" and timestamp ~= nil then
        for i = 1 , #timestamp do
            if string.sub ( timestamp , i , i ) == " " then
                count = count + 1;
            end
            if count == 2 then
                result = result .. "20" .. string.sub ( timestamp , i + 2 , i + 4 );
                break;
            end
        end
    end
    return result;
end

-- Method:          GRM.GetEventMonth ( string )
-- What it Does:    Returns the 3 letter string of the name of the month of the event.
-- Purpose:         Again, avoid code cludder. For event tracking, knowing exact date is essential.
GRM.GetEventMonth = function ( timestamp )
    if timestamp == "" or timestamp == nil then
        return "";
    else
        return string.sub ( timestamp , string.find ( timestamp , " " ) + 1 , string.find ( timestamp , " " ) + 3 );
    end
end

-- Method:          GRM.GetEventDay ( string )
-- What it Does:    Returns the number of the day, as a string, based on day of the month for given event timestamp
-- Purpose:         Important to know what day event should happen on.
GRM.GetEventDay = function ( timestamp )
    if timestamp == "" or timestamp == nil then
        return "";
    else
        return string.sub ( timestamp , 1 , string.find ( timestamp , " " ) - 1 );
    end
end

-- Method:          GRM.IsCalendarEventAlreadyAdded ( string , int , int , int )
-- What it Does:    Returns true if the event has already been added to the calendar 
-- Purpose:         If the player wipes his save history, it does not wipe what is added to in-game calendar. This just double-checks to avoid double adding.
GRM.IsCalendarEventAlreadyAdded = function ( eventName , year , month , day )
    eventName = GRM.SlimName( string.sub ( eventName , 0 , ( string.find ( eventName , " " ) - 1 ) ) ) .. string.sub ( eventName , string.find ( eventName , " " ) , #eventName );
    local result = false;
    local monthIndex = 0;
    local m , y;

    for i = 0 , 17 do                       -- Let's get to the right month on the calendar
        m , y = CalendarGetMonth ( i );
        if m == month and y == year then
            monthIndex = i;
            break;
        end
    end
    for i = 1 , CalendarGetNumDayEvents ( monthIndex , day ) do         -- Let's look at all the events on the day of the event
        if eventName == CalendarGetDayEvent ( monthIndex , day, i ) then
            result = true;
            break;
        end
    end
    return result;
end


-- Method:          GRM.IsOnAnnouncementList ( string , string )
-- What it Does:    returns true if the player is in the que to add to the calendar
-- Purpose:         Avoid double adding to que, and basic logic checking.
GRM.IsOnAnnouncementList = function ( name , eventName )
    local result = false;
    for i = 2 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] do
        if GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][1] == name and GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] == eventName then
            result = true;
            break; 
        end
    end
    return result;
end

-- Method:          GRM.RemoveFromCalendarQue ( string , string )
-- What it Does:    Removes the player/event from the global Calendar Add Que table
-- Purpose:         Keep the Que Clean
GRM.RemoveFromCalendarQue = function ( name , eventName )
    for i = 2 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] do
        if GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][1] == name and GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] == eventName then
            table.remove ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] , i );
            break;
        end
    end
end

-- Method:          GRM.CalendarQueCheck ()
-- What it Does:    It checks the Add Que list, if the event is already on the calendar, then it removes it from the addque list.
-- Purpose:         In case other players add items to the calendar, this keeps it clean.
GRM.CalendarQueCheck = function ()
    for i = 2 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] do             -- For each item on the que...3 = month , 4 = day , 5 = year
        if GRM.IsCalendarEventAlreadyAdded ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][2] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][5] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][3] , GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][4] ) then
            table.remove ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] , i );
            if #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] > 1 then
                GRM.CalendarQueCheck();                                                                 -- Recursively go through again!
            end
            break;
        end
    end
end

-- Method:          GRM.CheckPlayerEvents ( string )
-- What it Does:    Scans through all players'' "events" of the given guild and updates if any are pending
-- Purpose:         Event Management for Anniversaries, Birthdays, and Custom Events
GRM.CheckPlayerEvents = function ( guildName )
    -- including anniversary, birthday , and custom
    local _ , month , day , year = CalendarGetDate()
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        -- Player identified, now let's check his event info!
        for r = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22] do          -- Loop all events!
            local eventMonth = GRM.GetEventMonth ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][2] );
            local eventMonthIndex = monthEnum [ eventMonth ];
            local eventDay = tonumber ( GRM.GetEventDay ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][2] ) );
            local eventYear = tonumber ( GRM.GetEventYear ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][2] ) );
            local isLeapYear = GRM.IsLeapYear ( year );
            local logReport = "";
            --  Quick Leap Year Check
            if ( eventDay == 29 and eventMonthIndex == 2 ) and not isLeapYear then  -- If Event is Feb 29th Leap year, and reporting year is not, then put event in Mar 1st.
                eventMonthIndex = 3;
                eventDay = 1;
            end

            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][2] ~= nil and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][3] ~= true and ( month == eventMonthIndex or month + 1 == eventMonthIndex ) and not ( year == eventYear and month == eventMonthIndex and day == eventDay ) then        -- if it has already been reported, then we are good!
                local daysTil = eventDay - day;
                local daysLeftInMonth = daysInMonth [ tostring ( month ) ] - day;
                if month == 2 and GRM.IsLeapYear ( year ) then
                    daysLeftInMonth = daysLeftInMonth + 1;
                end
                            
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][12] and ( ( month == eventMonthIndex and daysTil >= 0 and daysTil <= GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][5] ) or 
                        ( month + 1 == eventMonthIndex and ( eventDay + daysLeftInMonth <= GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][5] ) ) ) then
                    -- SAME MONTH!
                    -- Let's see if player has it set to ONLY announce anniversary event on Calendar for a player's "main"
                    if not GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][17] or GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] then
                        -- Join Date Anniversary
                        if r == 1 then
                            local numYears = year - eventYear;
                            if numYears == 0 then
                                numYears = 1;
                            end
                            local eventDate;
                            if ( eventDay == 29 and eventMonthIndex == 2 ) and not isLeapYear then    -- If anniversary happened on leap year date, and the current year is NOT a leap year, then put it on 1 Mar.
                                eventDate = "1 Mar";
                            else
                                eventDate = string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][2] , 0 , string.find ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][2] , " " ) + 3 );
                            end
                            if numYears == 1 then
                                
                                logReport = ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][1][2] .. " : " .. GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] ) .. " will be celebrating " .. numYears .. " year in the Guild! ( " .. eventDate .. " )"  );
                            else
                                logReport = ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][1][2] .. " : " .. GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] ) .. " will be celebrating " .. numYears .. " years in the Guild! ( " .. eventDate .. " )"  );
                            end
                            table.insert ( GRM_AddonGlobals.TempEventReport , { 15 , logReport , false } );
                        
                        elseif r == 2 then
                        -- BIRTHDAY!

                        else
                        -- MISC EVENT!
                        
                        end
                        
                        -- Now, let's add it to the calendar!
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][8] and CanEditGuildEvent() then
                            local year = year;
                            if month == 12 and eventMonthIndex == 1 then
                                year = year + 1;
                            end 

                            -- 
                            local isAddedAlready = GRM.IsCalendarEventAlreadyAdded (  GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] , year , eventMonthIndex , eventDay  );
                            if not isAddedAlready and not GRM.IsOnAnnouncementList ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] ) then
                                table.insert ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] , eventMonthIndex , eventDay , year , string.sub ( logReport , 1 , #logReport - 11 ) } );
                            end
                        end
                        -- This has been reported, save it!
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][3] = true;
                    end
                end                  
                
            -- Resetting the event report to false if parameters meet
            elseif GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][3] then                                                   -- It is still true! Event has been reported! Let's check if time has passed sufficient to wipe it to false
                if ( month == eventMonthIndex and eventDay - day < 0 ) or ( month > eventMonthIndex  ) or ( eventMonthIndex - month > 1 ) then     -- Event is behind us now
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][3] = false;
                    if GRM.IsOnAnnouncementList ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] ) then
                        GRM.RemoveFromCalendarQue ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] );
                    end
                elseif month == eventMonthIndex and eventDay - day > GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][5] then      -- Setting back to false;
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][3] = false;
                    if GRM.IsOnAnnouncementList ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] ) then
                        GRM.RemoveFromCalendarQue ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] );
                    end
                elseif month + 1 == eventMonthIndex then
                    local daysLeftInMonth = daysInMonth [ tostring ( month ) ] - day;
                    if month == 2 and GRM.IsLeapYear ( year ) then
                        daysLeftInMonth = daysLeftInMonth + 1;
                    end
                    if eventDay + daysLeftInMonth > GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][5] then
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][3] = false;
                        if GRM.IsOnAnnouncementList ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] ) then
                            GRM.RemoveFromCalendarQue ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][1] );
                        end
                    end
                end
            end
        end
    end
end

-- Method:          AddAnnouncementToCalendar ( string , int , int , int , string , string )
-- What it Does:    Adds the announcement to the in-game calendar, if player has permissions to do so.
-- Purpose:         CalendarAddEvent() is a protected function thus it needs to be triggered by a player in-game action, so it will
--                  be linked to a button on the "GRM_AddEventFrame" window. Again, this cannot be activated, it WILL NOT WORK without 
--                  in-game action to remove protection on function
GRM.AddAnnouncementToCalendar = function ( name , title , eventMonthIndex , eventDay , year , description )
    CalendarCloseEvent();                           -- Just in case previous event was never closed, either by other addons or by player
    local _, month, day, year = CalendarGetDate()
    local hourServer , minServer = GetGameTime();
    local hour = 0;                                 -- 24hr scale, on when to add it...
    local min = 5;

    if eventMonthIndex == month and eventDay == day then      -- Add current time now!
        hour = hourServer;
        min = minServer;

        local tempMin = min;
        min = min - ( min % 5 ) + 5;    -- To get incrememnt by 5
        if min == 60 then
            if tempMin <= 55 then
                min = 55;
            else
                min = tempMin;
            end
        end
    end

    CalendarNewGuildAnnouncement();
    CalendarEventSetDate ( eventMonthIndex , eventDay , year );
    CalendarEventSetTitle ( title );
    CalendarEventSetDescription ( description ); -- No need to include the date at the end.
    CalendarEventSetTime ( hour , min );    
    CalendarEventSetType ( 5 );     -- 5 = announcement
    CalendarAddEvent();
    CalendarCloseEvent();
end

-- Method:          GRM.BuildLog()
-- What it Does:    Builds the guildLog frame details for the scrollframe
-- Purpose:         You aren't tracking all of that info for nothing!
GRM.BuildLog = function()
    -- SCRIPT LOGIC ON ADD EVENT SCROLLING FRAME
    local scrollHeight = 0;
    local scrollWidth = 220;
    local buffer = 7;

    GRM_RosterChangeLogScrollChildFrame.allFontStrings = GRM_RosterChangeLogScrollChildFrame.allFontStrings or {};  -- Create a table for the Buttons.
    -- populating the window correctly.
    local count = 1;
    for i = 1 , #GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] do
        -- if font string is not created, do so.
        local trueString = false;
        
        -- Check buttons
        local index = GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID][#GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] - i + 1][1];
        if index == 1 and GRM_RosterPromotionChangeCheckButton:GetChecked() then      -- Promotion 
            trueString = true;
        elseif index == 2 and GRM_RosterDemotionChangeCheckButton:GetChecked() then  -- Demotion
            trueString = true;
        elseif index == 3 and GRM_RosterLeveledChangeCheckButton:GetChecked() then  -- Leveled
            trueString = true;
        elseif index == 4 and GRM_RosterNoteChangeCheckButton:GetChecked() then  -- Note
            trueString = true;
        elseif index == 5 and GRM_RosterOfficerNoteChangeCheckButton:GetChecked() then  -- OfficerNote
            trueString = true;
        elseif index == 6 and GRM_RosterRankRenameCheckButton:GetChecked() then  -- OfficerNote
            trueString = true;
        elseif ( index == 7 or index == 8 ) and GRM_RosterJoinedCheckButton:GetChecked() then  -- Join/Rejoin
            trueString = true;
        elseif index == 10 and GRM_RosterLeftGuildCheckButton:GetChecked() then -- Left Guild
            trueString = true;
        elseif index == 11 and GRM_RosterNameChangeCheckButton:GetChecked() then -- NameChange
            trueString = true;
        elseif index == 14 and GRM_RosterInactiveReturnCheckButton:GetChecked() then -- Return from inactivity
            trueString = true;
        elseif index == 15 and GRM_RosterEventCheckButton:GetChecked() then -- Event Announcement
            trueString = true;
        elseif index == 16 and GRM_RosterRecommendationsButton:GetChecked() then -- Event Announcement
            trueString = true;
        elseif index == 17 and GRM_RosterBannedPlayersButton:GetChecked() then  -- ban info
            trueString = true;
        elseif index == 18 and GRM_RosterBannedPlayersButton:GetChecked() then
            trueString = true;
        elseif ( index == 9 or index == 12 or index == 13 ) and GRM_RosterJoinedCheckButton:GetChecked() then
            trueString = true;
        end

        if trueString then
            if not GRM_RosterChangeLogScrollChildFrame.allFontStrings[count] then
                GRM_RosterChangeLogScrollChildFrame.allFontStrings[count] = GRM_RosterChangeLogScrollChildFrame:CreateFontString ( "GRM_LogEntry_" .. count );
            end

            -- coloring
            local r , g , b = GRM.GetNMessageRGB ( GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID][#GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] - i + 1][1] );
            local logFontString = GRM_RosterChangeLogScrollChildFrame.allFontStrings[count];
            logFontString:SetPoint ( "TOP" , GRM_RosterChangeLogScrollChildFrame , 7 , -99 );
            logFontString:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );   
            logFontString:SetJustifyH ( "LEFT" );
            logFontString:SetSpacing ( buffer );
            logFontString:SetTextColor ( r , g , b , 1.0 );
            logFontString:SetText ( GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID][#GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] - i + 1][2] );
            logFontString:SetWidth ( 565 );
            logFontString:SetWordWrap ( true );
            local stringHeight = logFontString:GetStringHeight();

            -- Now let's pin it!
            if count == 1 then
                logFontString:SetPoint( "TOPLEFT" , 0 , - 5 );
                scrollHeight = scrollHeight + stringHeight;
            else
                logFontString:SetPoint( "TOPLEFT" , GRM_RosterChangeLogScrollChildFrame.allFontStrings[count - 1] , "BOTTOMLEFT" , 0 , - buffer );
                scrollHeight = scrollHeight + stringHeight + buffer;
            end
            count = count + 1;
            logFontString:Show();
        end
    end
            

    -- Hides all the additional buttons... if necessary
    for i = count , #GRM_RosterChangeLogScrollChildFrame.allFontStrings do
        GRM_RosterChangeLogScrollChildFrame.allFontStrings[i]:Hide();
    end 

    -- Update the size -- it either grows or it shrinks!
    GRM_RosterChangeLogScrollChildFrame:SetSize ( scrollWidth , scrollHeight );

    --Set Slider Parameters ( has to be done after the above details are placed )
    local scrollMax = ( scrollHeight - 397 ) +  ( buffer * .5 );  -- 18 comes from fontSize (11) + buffer (7);
    if scrollMax < 0 then
        scrollMax = 0;
    end
    GRM_RosterChangeLogScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
    -- Mousewheel Scrolling Logic
    GRM_RosterChangeLogScrollFrame:EnableMouseWheel( true );
    GRM_RosterChangeLogScrollFrame:SetScript( "OnMouseWheel" , function( self , delta )
        local current = GRM_RosterChangeLogScrollFrameSlider:GetValue();
        
        if IsShiftKeyDown() and delta > 0 then
            GRM_RosterChangeLogScrollFrameSlider:SetValue ( 0 );
        elseif IsShiftKeyDown() and delta < 0 then
            GRM_RosterChangeLogScrollFrameSlider:SetValue ( scrollMax );
        elseif delta < 0 and current < scrollMax then
            GRM_RosterChangeLogScrollFrameSlider:SetValue ( current + 20 );
        elseif delta > 0 and current > 1 then
            GRM_RosterChangeLogScrollFrameSlider:SetValue ( current - 20 );
        end
    end);
end


------------------------------------
---- BEGIN OF FRAME/UI LOGIC -------
---- General Framebuild Methods ----
------------------------------------


-- Method:          GRM.OnDropMenuClickDay()
-- What it Does:    Upon clicking any item in a drop down menu, this sets the ID of that item as defaulted choice
-- Purpose:         General use clicking logic for month based drop down menu.
GRM.OnDropMenuClickDay = function ()
    GRM_AddonGlobals.dayIndex = tonumber ( GRM_DayDropDownMenuSelected.DayText:GetText() );
    GRM.InitializeDropDownDay();
end

-- Method:          GRM.OnDropMenuClickMonth()
-- What it Does:    Recalculates the logic of number days to show.
-- Purpose:         General use clicking logic for month based drop down menu.
GRM.OnDropMenuClickMonth = function ()
    GRM_AddonGlobals.monthIndex = monthsFullnameEnum [ GRM_MonthDropDownMenuSelected.MonthText:GetText() ];
    GRM.InitializeDropDownDay();
end

-- Method:          GRM.OnDropMenuClickYear()
-- What it Does:    Upon clicking any item in a drop down menu, this sets the ID of that item as defaulted choice
-- Purpose:         General use clicking logic for year based drop down menu.
GRM.OnDropMenuClickYear = function ()
    GRM_AddonGlobals.yearIndex = tonumber ( GRM_YearDropDownMenuSelected.YearText:GetText() );
    GRM.InitializeDropDownDay();
end

-- Method:          GRM.InitializeDropDownDay ( self , int )
-- What it Does:    Initializes the Drop Down "Day" select window with values based on selected month
-- Purpose:         UI feature for easy date select.
GRM.InitializeDropDownDay = function ()
    local shortMonth = 30;
    local longMonth = 31;
    local febMonth = 28;
    local leapYear = 29;
    local yearDate = 0;

    yearDate = GRM_AddonGlobals.yearIndex;
    local isDateALeapyear = GRM.IsLeapYear(yearDate);
    local numDays;
    
    if GRM_AddonGlobals.monthIndex == 1 or GRM_AddonGlobals.monthIndex == 3 or GRM_AddonGlobals.monthIndex == 5 or GRM_AddonGlobals.monthIndex == 7 or GRM_AddonGlobals.monthIndex == 8 or GRM_AddonGlobals.monthIndex == 10 or GRM_AddonGlobals.monthIndex == 12 then
        numDays = longMonth;
    elseif GRM_AddonGlobals.monthIndex == 2 and isDateALeapyear then
        numDays = leapYear;
    elseif GRM_AddonGlobals.monthIndex == 2 then
        numDays = febMonth;
    else
        numDays = shortMonth;
    end
      
    -- populating the frames!
    local buffer = 3;
    local height = 0;
    GRM_DayDropDownMenu.Buttons = GRM_DayDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_DayDropDownMenu.Buttons do
        GRM_DayDropDownMenu.Buttons[i][1]:Hide();
    end
    
    for i = 1 , numDays do
        if not GRM_DayDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "DayOfTheMonth" .. i , GRM_DayDropDownMenu );
            GRM_DayDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "DayOfTheMonthText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local DayButtons = GRM_DayDropDownMenu.Buttons[i][1];
        local DayButtonsText = GRM_DayDropDownMenu.Buttons[i][2];
        DayButtons:SetWidth ( 24 );
        DayButtons:SetHeight ( 10 );
        DayButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        DayButtonsText:SetText ( i );
        DayButtonsText:SetWidth ( 25 );
        DayButtonsText:SetWordWrap ( false );
        DayButtonsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
        DayButtonsText:SetPoint ( "CENTER" , DayButtons );
        DayButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            DayButtons:SetPoint ( "TOP" , GRM_DayDropDownMenu , 0 , -7 );
            height = height + DayButtons:GetHeight();
        else
            DayButtons:SetPoint ( "TOP" , GRM_DayDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + DayButtons:GetHeight() + buffer;
        end

        DayButtons:SetScript ( "OnClick" , function( _ , button ) 
            if button == "LeftButton" then
                GRM_DayDropDownMenuSelected.DayText:SetText ( DayButtonsText:GetText() );
                GRM_DayDropDownMenu:Hide();
                GRM_DayDropDownMenuSelected:Show();
                GRM.OnDropMenuClickDay();
            end
        end); 

        DayButtons:Show();
    end
    GRM_DayDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.InitializeDropDownYear(self,level)
-- What it Does:    Initializes the year select drop-down OnDropMenuClick
-- Purpose:         Easy way to set when player joined the guild.         
GRM.InitializeDropDownYear = function ()
    -- Year Drop Down
    local _,_,_,currentYear = CalendarGetDate();
    local yearStamp = currentYear;

    -- populating the frames!
    local buffer = 2;
    local height = 0;
    GRM_YearDropDownMenu.Buttons = GRM_YearDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_YearDropDownMenu.Buttons do
        GRM_YearDropDownMenu.Buttons[i][1]:Hide();
    end
    
    for i = 1 , currentYear - 2003 do
        if not GRM_YearDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "YearIndexButton" .. i , GRM_YearDropDownMenu );
            GRM_YearDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "YearIndexButtonText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local YearButtons = GRM_YearDropDownMenu.Buttons[i][1];
        local YearButtonsText = GRM_YearDropDownMenu.Buttons[i][2];
        YearButtons:SetWidth ( 40 );
        YearButtons:SetHeight ( 10 );
        YearButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        YearButtonsText:SetText ( yearStamp );
        YearButtonsText:SetWidth ( 32 );
        YearButtonsText:SetWordWrap ( false );
        YearButtonsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
        YearButtonsText:SetPoint ( "CENTER" , YearButtons );
        YearButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            YearButtons:SetPoint ( "TOP" , GRM_YearDropDownMenu , 0 , -7 );
            height = height + YearButtons:GetHeight();
        else
            YearButtons:SetPoint ( "TOP" , GRM_YearDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + YearButtons:GetHeight() + buffer;
        end

        YearButtons:SetScript ( "OnClick" , function( _ , button ) 
            if button == "LeftButton" then
                GRM_YearDropDownMenuSelected.YearText:SetText ( YearButtonsText:GetText() );
                GRM_YearDropDownMenu:Hide();
                GRM_YearDropDownMenuSelected:Show();
                GRM.OnDropMenuClickYear();
            end
        end); 
        yearStamp = yearStamp - 1                       -- Descending the year by 1
        YearButtons:Show();
    end
    GRM_YearDropDownMenu:SetHeight ( height + 15 );

end

-- Method:          GRM.InitializeDropDownMonth(self,level)
-- What it Does:    Initializes month drop select menu
-- Purpose:         Date select for Officer Note "Join Date"
GRM.InitializeDropDownMonth = function ()
    -- Month Drop Down
    local months = { "January" , "February" , "March" , "April" , "May" , "June" , "July" , "August" , "September" , "October" , "November" , "December" };
    
    -- populating the frames!
    local buffer = 3;
    local height = 0;
    GRM_MonthDropDownMenu.Buttons = GRM_MonthDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_MonthDropDownMenu.Buttons do
        GRM_MonthDropDownMenu.Buttons[i][1]:Hide();
    end
    
    for i = 1 , #months do
        if not GRM_MonthDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "monthIndex" .. i , GRM_MonthDropDownMenu );
            GRM_MonthDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "monthIndexText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local MonthButtons = GRM_MonthDropDownMenu.Buttons[i][1];
        local MonthButtonsText = GRM_MonthDropDownMenu.Buttons[i][2];
        MonthButtons:SetWidth ( 83 );
        MonthButtons:SetHeight ( 10 );
        MonthButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        MonthButtonsText:SetText ( months[i] );
        MonthButtonsText:SetWidth ( 83 );
        MonthButtonsText:SetWordWrap ( false );
        MonthButtonsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
        MonthButtonsText:SetPoint ( "CENTER" , MonthButtons );
        MonthButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            MonthButtons:SetPoint ( "TOP" , GRM_MonthDropDownMenu , 0 , -7 );
            height = height + MonthButtons:GetHeight();
        else
            MonthButtons:SetPoint ( "TOP" , GRM_MonthDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + MonthButtons:GetHeight() + buffer;
        end

        MonthButtons:SetScript ( "OnClick" , function( _ , button ) 
            if button == "LeftButton" then
                GRM_MonthDropDownMenuSelected.MonthText:SetText ( MonthButtonsText:GetText() );
                GRM_MonthDropDownMenu:Hide();
                GRM_MonthDropDownMenuSelected:Show();
                GRM.OnDropMenuClickMonth();
            end
        end); 

        MonthButtons:Show();
    end
    GRM_MonthDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.SetJoinDate ( self , string )
-- What it Does:    Sets the player's join date properly, be it the first time, a modified time, or an edit.
-- Purpose:         For so many uses! Anniversary tracking, for editing the date, and so on...
GRM.SetJoinDate = function ( _ , button )
    local name = GRM_AddonGlobals.currentName;
    local dayJoined = tonumber ( GRM_DayDropDownMenuSelected.DayText:GetText() );
    local yearJoined = tonumber ( GRM_YearDropDownMenuSelected.YearText:GetText() );
    local IsLeapYearSelected = GRM.IsLeapYear ( yearJoined );
    local buttonText = GRM_DateSubmitButtonTxt:GetText();

    if GRM.IsValidSubmitDate ( dayJoined , monthsFullnameEnum [ GRM_MonthDropDownMenuSelected.MonthText:GetText() ] , yearJoined, IsLeapYearSelected ) then
        local rankButton = false;
        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == name then

                local joinDate = ( "Joined: " .. dayJoined .. " " ..  string.sub ( GRM_MonthDropDownMenuSelected.MonthText:GetText() , 1 , 3 ) .. " '" ..  string.sub ( GRM_YearDropDownMenuSelected.YearText:GetText() , 3 ) );
                local finalTStamp = ( string.sub ( joinDate , 9 ) .. " 12:01am" );
                local finalEpochStamp = GRM.TimeStampToEpoch ( joinDate );
                -- For metadata tracking
                if buttonText == "Edit Join Date" then
                    table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] );  -- Removing previous instance to replace
                    table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][21] , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][21] );
                end
                table.insert( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] , finalTStamp );      -- oldJoinDate
                table.insert( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][21] , finalEpochStamp ) ;    -- oldJoinDateMeta
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][2] = finalTStamp;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][3] = finalEpochStamp;

                -- For sync
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][35][1] = finalTStamp;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][35][2] = time();

                -- For UI
                GRM_JoinDateText:SetText ( string.sub ( joinDate , 9 ) );
                
                -- Update timestamp to officer note.
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] and CanEditOfficerNote() then
                    for h = 1 , GRM.GetNumGuildies() do
                        local guildieName ,_,_,_,_,_,_, oNote = GetGuildRosterInfo( h );
                        if guildieName == name and oNote == "" then
                            GuildRosterSetOfficerNote ( h , joinDate );
                            GRM_noteFontString2:SetText ( joinDate );
                            GRM_PlayerOfficerNoteEditBox:SetText ( joinDate );
                            break;
                        end
                    end
                end

                -- Gotta update the event tracker date too!
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][22][1][2] = string.sub ( joinDate , 9 ); -- Remember, position 1 of the events tracker for anniversary tracking is always position 1 of the array, with date being pos 1 of table too.
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][22][1][3] = false;  -- Gotta Reset the "reported already" boolean!
                GRM.RemoveFromCalendarQue ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][22][1][1] );
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] == nil then
                    rankButton = true;
                end

                -- Need player index to get this info.
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= nil then
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] );                                     -- Zone
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] ) );              -- Time Passed
                    end
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Show();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Show();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Show();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Show();
                end

                -- Let's send the changes out as well!
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_JD?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. name .. "?" .. joinDate .. "?" .. finalTStamp .. "?" .. finalEpochStamp .. "?" .. tostring ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][35][2] ) , "GUILD");
                end
                break;
            end
        end

        GRM_DayDropDownMenuSelected:Hide();
        GRM_MonthDropDownMenuSelected:Hide();
        GRM_YearDropDownMenuSelected:Hide();
        GRM_DateSubmitCancelButton:Hide();
        GRM_DateSubmitButton:Hide();
        GRM_JoinDateText:Show();
        if rankButton then
            GRM_SetPromoDateButton:Show();
        else
            GRM_MemberDetailRankDateTxt:Show();
        end
        GRM_AddonGlobals.pause = false;
    end
end

-- Method:          GRM.SetPromoDate ( self , string )
-- What it Does:    Set's the date the player was promoted to the current rank
-- Purpose:         Date tracking and control of rank promotions.
GRM.SetPromoDate = function ( _ , button )
    local name = GRM_AddonGlobals.currentName;
    local dayJoined = tonumber ( GRM_DayDropDownMenuSelected.DayText:GetText() );
    local yearJoined = tonumber ( GRM_YearDropDownMenuSelected.YearText:GetText() );
    local IsLeapYearSelected = GRM.IsLeapYear ( yearJoined );

    if GRM.IsValidSubmitDate ( dayJoined , monthsFullnameEnum [ GRM_MonthDropDownMenuSelected.MonthText:GetText() ] , yearJoined, IsLeapYearSelected ) then

        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == name then
                local promotionDate = ( "Joined: " .. dayJoined .. " " ..  string.sub ( GRM_MonthDropDownMenuSelected.MonthText:GetText() , 1 , 3 ) .. " '" ..  string.sub ( GRM_YearDropDownMenuSelected.YearText:GetText() , 3 ) );
                
                -- Promo Save Data
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] = string.sub ( promotionDate , 9 );
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25][#GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25]][2] = string.sub ( promotionDate , 9 );
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13] = GRM.TimeStampToEpoch ( promotionDate );
                
                -- For SYNC
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][1] = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12];
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][2] = time();
                
                GRM_MemberDetailRankDateTxt:SetText ( "Promoted: " .. GRM.Trim ( string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] , 1 , 10) ) );

                -- Need player index to get this info.
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= nil then
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] );                                     -- Zone
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] ) );              -- Time Passed
                    end
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Show();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Show();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Show();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Show();
                end

                -- Send the details out for others to pickup!
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_PD?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. name .. "?" .. promotionDate .. "?" .. tostring( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][2] ) , "GUILD");
                end

                break;
            end
        end

        GRM_DayDropDownMenuSelected:Hide();
        GRM_MonthDropDownMenuSelected:Hide();
        GRM_YearDropDownMenuSelected:Hide();
        GRM_DateSubmitCancelButton:Hide();
        GRM_DateSubmitButton:Hide();
        GRM_MemberDetailRankDateTxt:Show();
        GRM_AddonGlobals.pause = false;
    end
end

-- Method:          GRM.DateSubmitCancelResetLogic()
-- What it Does:    Resets the logic on what occurs with the cancel button, since it will have multiple uses.
-- Purpose:         Resource efficiency. No need to make new buttons for everything! This reuses the button, just resets the click logic in join date submit cancel event.
GRM.DateSubmitCancelResetLogic = function()
    GRM_DateSubmitCancelButton:SetScript ( "OnClick" , function ( _ , button )
        if button == "LeftButton" then
            local buttonText = GRM_DateSubmitButtonTxt:GetText();
            local joinDateText = "Set Join Date";
            local promoDateText = "Set Promo Date";
            local editDateText = "Edit Promo Date";
            local editJoinText = "Edit Join Date";
            local name = GRM_AddonGlobals.currentName;

            -- Determine which information needs to repopulate.
            if joinDateText == buttonText or editJoinText == buttonText then
                if buttonText == editJoinText then
                    GRM_JoinDateText:Show();
                else
                    GRM_MemberDetailJoinDateButton:Show();
                end
                --RANK PROMO DATE
                if GRM_AddonGlobals.rankDateSet == false then      --- Promotion has never been recorded!
                    GRM_MemberDetailRankDateTxt:Hide();                     
                    GRM_SetPromoDateButton:Show();
                else
                    GRM_MemberDetailRankDateTxt:Show();
                end
            elseif buttonText == promoDateText then
                GRM_SetPromoDateButton:Show();
            elseif buttonText == editDateText then
                GRM_MemberDetailRankDateTxt:Show();
            end
            GRM_AddonGlobals.pause = false;

            -- Need player index to get this info.
            for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == name then

                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= nil then
                            GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] );                                     -- Zone
                            GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] ) );              -- Time Passed
                        end
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Show();
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Show();
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Show();
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Show();
                    end
                    break;
                end
            end

            -- Close the rest
            GRM_MonthDropDownMenuSelected:Hide();
            GRM_YearDropDownMenuSelected:Hide();
            GRM_DayDropDownMenuSelected:Hide();
            GRM_DateSubmitButton:Hide();
            GRM_DateSubmitCancelButton:Hide();

        end
    end);
end

-- Method:          GRM.SetDateSelectFrame( string , frameObject, string )
-- What it Does:    On Clicking the "Set Join Date" button this logic presents itself
-- Purpose:         Handle the event to modify when a player joined the guild. This is useful for anniversary date tracking.
--                  It is also necessary because upon starting the addon, it is unknown a person's true join date. This allows the gleader to set a general join date.
GRM.SetDateSelectFrame = function ( fposition , frame , buttonName )
    local _ , month , day , currentYear = CalendarGetDate();
    local xPosMonth , yPosMonth , xPosDay , yPosDay , xPosYear , yPosYear , xPosSubmit , yPosSubmit , xPosCancel , yPosCancel = 0;        -- Default position.
    local months = { "January" , "February" , "March" , "April" , "May" , "June" , "July" , "August" , "September" , "October" , "November" , "December" };
    local joinDateText = "Set Join Date";
    local promoDateText = "Set Promo Date";

    -- Month
    GRM_MonthDropDownMenuSelected.MonthText:SetText ( months [ month ] );
    GRM_MonthDropDownMenuSelected.MonthText:SetPoint ( "CENTER" , GRM_MonthDropDownMenuSelected );
    GRM_MonthDropDownMenuSelected.MonthText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_MonthDropDownButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if GRM_MonthDropDownMenu:IsVisible() then
                GRM_MonthDropDownMenu:Hide();
            else
                GRM.InitializeDropDownMonth();
                GRM_MonthDropDownMenu:Show();
                GRM_DayDropDownMenu:Hide();
                GRM_YearDropDownMenu:Hide();
            end
        end
    end);
    GRM_AddonGlobals.monthIndex = month;
    
    -- Year
    GRM_YearDropDownMenuSelected.YearText:SetText ( currentYear );
    GRM_YearDropDownMenuSelected.YearText:SetPoint ( "CENTER" , GRM_YearDropDownMenuSelected );
    GRM_YearDropDownMenuSelected.YearText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_YearDropDownButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if GRM_YearDropDownMenu:IsVisible() then
                GRM_YearDropDownMenu:Hide();
            else
                GRM.InitializeDropDownYear();
                GRM_YearDropDownMenu:Show();
                GRM_MonthDropDownMenu:Hide();
                GRM_DayDropDownMenu:Hide();
            end
        end
    end);
    GRM_AddonGlobals.yearIndex = currentYear;
    
    -- Initialize the day choice now.
    GRM_DayDropDownMenuSelected.DayText:SetText ( day );
    GRM_DayDropDownMenuSelected.DayText:SetPoint ( "CENTER" , GRM_DayDropDownMenuSelected );
    GRM_DayDropDownMenuSelected.DayText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
    GRM_DayDropDownButton:SetScript ( "OnMouseDown" , function( _ , button ) 
        if button == "LeftButton" then
            if GRM_DayDropDownMenu:IsVisible() then
                GRM_DayDropDownMenu:Hide();
            else
                GRM.InitializeDropDownDay();
                GRM_DayDropDownMenu:Show();
                GRM_YearDropDownMenu:Hide();
                GRM_MonthDropDownMenu:Hide();
            end
        end
    end);
    GRM_AddonGlobals.dayIndex = day;
    
    GRM.DateSubmitCancelResetLogic(); 

    if buttonName == "PromoRank" then
        
        -- Change this button
        GRM_DateSubmitButtonTxt:SetText ( promoDateText );
        GRM_DateSubmitButton:SetScript("OnClick" , GRM.SetPromoDate );
        
        xPosDay = 10.5;
        yPosDay = -80;
        xPosMonth = -63.5;
        yPosMonth = -80;
        xPosYear = 69;
        yPosYear = -80
        xPosSubmit = -37;
        yPosSubmit = -106;
        xPosCancel = 37;
        yPosCancel = -106;

    elseif buttonName == "JoinDate" then

        GRM_DateSubmitButtonTxt:SetText ( joinDateText );
        GRM_DateSubmitButton:SetScript("OnClick" , GRM.SetJoinDate );
        
        xPosDay = 10.5;
        yPosDay = -80;
        xPosMonth = -63.5;
        yPosMonth = -80;
        xPosYear = 69;
        yPosYear = -80
        xPosSubmit = -37;
        yPosSubmit = -106;
        xPosCancel = 37;
        yPosCancel = -106;
    end

    GRM_MonthDropDownMenuSelected:SetPoint ( fposition , frame , xPosMonth , yPosMonth );
    GRM_YearDropDownMenuSelected:SetPoint ( fposition , frame , xPosYear , yPosYear );
    GRM_DayDropDownMenuSelected:SetPoint ( fposition , frame , xPosDay , yPosDay );
    GRM_DateSubmitButton:SetPoint ( fposition , frame , xPosSubmit , yPosSubmit );
    GRM_DateSubmitCancelButton:SetPoint ( fposition , frame , xPosCancel , yPosCancel );

    -- Show all Frames
    GRM_MonthDropDownMenuSelected:Show();
    GRM_YearDropDownMenuSelected:Show();
    GRM_DayDropDownMenuSelected:Show();
    GRM_DateSubmitButton:Show();
    GRM_DateSubmitCancelButton:Show();
end

-- Method:          GRM.GetRankIndex ( string , 2Darray )
-- What it Does:    Returns the index of the guild rank...
-- Purpose:         Flow control of drop down menus.
GRM.GetRankIndex = function ( rankName , button )
    GRM.BuildRankList();
    local index = -1;
    
    if button == nil then
        for i = 1 , #GuildRanks do
            if GuildRanks[i] == rankName then
                index = i - 1;
                break;
            end
        end
    else
        local buttonName = button:GetName();
        if tonumber ( string.sub ( buttonName , #buttonName - 1 ) ) == nil then
            index = tonumber ( string.sub ( buttonName , #buttonName ) ) - 1;
        else
            index = tonumber ( string.sub ( buttonName , #buttonName - 1 ) ) - 1;
        end
    end
    return index;
end

-- Method:          GRM.BuildRankList()
-- What it Does:    It builds into an array all of the dropdown buttons from the guild rank dropdown.
-- Purpose:         Needed to initialize dropdown logic...
GRM.BuildRankList = function()
    -- Let's put all of the buttons in an array, and let's set some rules.
    for i = 1 , GuildControlGetNumRanks() do
        GuildRanks[i] = GuildControlGetRankName( i );
    end
end


-- Method:          GRM.OnRankChange ( string , string  )
-- What it Does:    Logic on Rank Drop down select in main frame
-- Purpose:         UI feature and UX
GRM.OnRankChange = function ( formerRank , newRank )
    -- Build Buttons Profile
    local newRankIndex = GRM.GetRankIndex ( newRank , nil );
    local formerRankIndex = GRM.GetRankIndex ( formerRank , nil );

    if newRankIndex ~= formerRankIndex then
        local numRanks = GuildControlGetNumRanks();
        local numChoices = ( numRanks - GRM_AddonGlobals.playerIndex - 1 );

        -- Save the data!
        local timestamp = GRM.GetTimestamp();
        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == GRM_AddonGlobals.currentName then
                local formerRankName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4];                               -- For the reporting string!

                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] = newRank                                         -- rank name
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] = newRankIndex;                                           -- rank index!

                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] = string.sub ( timestamp , 1 , string.find ( timestamp , "'" ) + 2 ) -- Time stamping rank change
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13] = time();

                -- For SYNC
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][1] = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12];
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][2] = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13];
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25] , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13] } ); -- New rank, date, metatimestamp
                
                -- Let's update it on the fly!
                local simpleName = GRM.SlimName ( GRM_AddonGlobals.currentName );
                local logReport = "";
                -- Promotion Obtained
                if newRankIndex < formerRankIndex and CanGuildPromote() then
                    logReport = ( timestamp .. " : " .. GRM.SlimName ( GRM_AddonGlobals.addonPlayerName ) .. " PROMOTED " .. simpleName .. " from " .. formerRankName .. " to " .. newRank );

                    -- report the changes!
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] then
                        GRM.PrintLog ( 1 , logReport , false );
                    end
                    GRM.AddLog ( 1 , logReport );

                -- Demotion Obtained
                elseif newRankIndex > formerRankIndex and CanGuildDemote() then
                    logReport = ( timestamp .. " : " .. GRM.SlimName ( GRM_AddonGlobals.addonPlayerName ) .. " DEMOTED " .. simpleName .. " from " .. formerRankName .. " to " .. newRank );

                    -- reporting the changes!
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][5] then
                        GRM.PrintLog ( 2 , logReport , false );                          
                    end
                    GRM.AddLog ( 2 , logReport );
                end
                GRM:BuildLog();
                break;
            end
        end

        -- Update the player index if it is the player themselves that received the change in rank.
        if GRM_AddonGlobals.currentName == GRM_AddonGlobals.addonPlayerName then
            GRM_AddonGlobals.playerIndex = newRankIndex;
        end

        -- Now, let's make the changes immediate for the button date.
        if GRM_SetPromoDateButton:IsVisible() then
            GRM_SetPromoDateButton:Hide();
            GRM_MemberDetailRankDateTxt:SetText ( "Promoted: " .. GRM.Trim ( string.sub ( timestamp , 1 , 10 ) ) );
            GRM_MemberDetailRankDateTxt:Show();
        end
    end
    C_Timer.After ( 0.4 , function()
        GRM_AddonGlobals.CurrentRank = GuildMemberRankDropdownText:GetText();
    end);
end

-- Method:          GRM.CollectRosterButtons()
-- What it Does:    Puts the 14 roster buttons into an array
-- Purpose:         Ease of access of the buttons of course!!!
GRM.CollectRosterButtons = function()
    for i = 1 , 15 do
        GRM_AddonGlobals.RosterButtons[i] = GetClickFrame ( "GuildRosterContainerButton" .. i );
    end
end

-- Method:          GRM.RemoveRosterButtonHighlights()
-- What it Does:    Removes the button highlight from the click action
-- Purpose:         Purely aesthetics.
GRM.RemoveRosterButtonHighlights = function ( button )
    for i = 1 , #GRM_AddonGlobals.RosterButtons do
        if GRM_AddonGlobals.RosterButtons[i] ~= button then         -- It's ok if button == nil - It will just unlock ALL highlights.
            GRM_AddonGlobals.RosterButtons[i]:UnlockHighlight();
        end
    end
end

-- Method:          GRM.PopulateOptionsRankDropDown ()
-- What it Does:    Adds all the guild ranks to the drop down menu
-- Purpose:         UI Feature
GRM.PopulateOptionsRankDropDown = function ()
    -- populating the frames!
    local buffer = 3;
    local height = 0;
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons do
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i][1]:Hide();
    end
    
    local i = 1;
    for count = 1 , GuildControlGetNumRanks() do
        if not GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "rankIndex" .. i , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "rankIndexText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local RankButtons = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i][1];
        local RankButtonsText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i][2];
        RankButtons:SetWidth ( 110 );
        RankButtons:SetHeight ( 11 );
        RankButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        RankButtonsText:SetText ( GuildControlGetRankName ( count) );
        RankButtonsText:SetWidth ( 110 );
        RankButtonsText:SetWordWrap ( false );
        RankButtonsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
        RankButtonsText:SetPoint ( "CENTER" , RankButtons );
        RankButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            RankButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu , 0 , -7 );
            height = height + RankButtons:GetHeight();
        else
            RankButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + RankButtons:GetHeight() + buffer;
        end

        RankButtons:SetScript ( "OnClick" , function( self , button ) 
            if button == "LeftButton" then
                local formerRank = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText:GetText();
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText:SetText ( RankButtonsText:GetText() );
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:Hide();
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected:Show();
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] = GRM.GetRankIndex ( GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText:GetText() , self );

                --Let's re-initiate syncing!
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and not GRMsyncGlobals.currentlySyncing and GRM_AddonGlobals.HasAccessToGuildChat then
                    GRMsync.TriggerFullReset();
                    -- Now, let's add a brief delay, 3 seconds, to trigger sync again
                    C_Timer.After ( 3 , GRMsync.Initialize );
                end
                -- Determine if player has access to guild chat or is in restricted chat rank
                GRM_AddonGlobals.HasAccessToGuildChat = false;
                GRM_AddonGlobals.HasAccessToOfficerChat = false;
                GRM.RegisterGuildChatPermission();
                
            end
        end); 
        RankButtons:Show();
        i = i + 1;
    end
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.PopulateBanListOptionsDropDown ()
-- What it Does:    Adds all the guild ranks to the drop down menu for ban changes
-- Purpose:         UI Feature in options - greater control to keep sync of ban list to officers only, whilst allowing great sync with all guildies.
GRM.PopulateBanListOptionsDropDown = function ()
    -- populating the frames!
    local buffer = 3;
    local height = 0;
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu.Buttons = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu.Buttons do
        GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu.Buttons[i][1]:Hide();
    end
    
    local i = 1;
    for count = 1 , GuildControlGetNumRanks() do
        if not GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "rankIndex" .. i , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu );
            GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "rankIndexText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local RankButtons = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu.Buttons[i][1];
        local RankButtonsText = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu.Buttons[i][2];
        RankButtons:SetWidth ( 110 );
        RankButtons:SetHeight ( 11 );
        RankButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        RankButtonsText:SetText ( GuildControlGetRankName ( count) );
        RankButtonsText:SetWidth ( 110 );
        RankButtonsText:SetWordWrap ( false );
        RankButtonsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
        RankButtonsText:SetPoint ( "CENTER" , RankButtons );
        RankButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            RankButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu , 0 , -7 );
            height = height + RankButtons:GetHeight();
        else
            RankButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + RankButtons:GetHeight() + buffer;
        end

        RankButtons:SetScript ( "OnClick" , function( self , button ) 
            if button == "LeftButton" then
                local formerRank = GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelectedText:GetText();
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelectedText:SetText ( RankButtonsText:GetText() );
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu:Hide();
                GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelected:Show();
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][22] = GRM.GetRankIndex ( GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelectedText:GetText() , self );

                --Let's re-initiate syncing!
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][21] and not GRMsyncGlobals.currentlySyncing and GRM_AddonGlobals.HasAccessToGuildChat then
                    GRMsync.TriggerFullReset();
                    -- Now, let's add a brief delay, 3 seconds, to trigger sync again
                    C_Timer.After ( 3 , GRMsync.Initialize );
                end
            end
        end);
        RankButtons:Show();
        i = i + 1;
    end
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.PopulateClassDropDownMenu ()
-- What it Does:    Adds all the player CLASSES to the drop down menu
-- Purpose:         This is useful for player selection of the class when manually adding a player's info to the metadata, like adding someone to a ban list.
GRM.PopulateClassDropDownMenu = function()
    -- populating the frames!
    local buffer = 3;
    local height = 0;
    GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons = GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons do
        GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons[i][1]:Hide();
    end
    
    for i = 1 , #AllClasses do
        if not GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "ClassButton" .. i , GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownMenu );
            GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "ClassButtonText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local ClassButtons = GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons[i][1];
        local ClassButtonsText = GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons[i][2];
        ClassButtons:SetWidth ( 110 );
        ClassButtons:SetHeight ( 11 );
        ClassButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        ClassButtonsText:SetText ( GRM_Localize ( AllClasses[i] ) );
        local classCol = GRM.GetClassColorRGB ( AllClasses[i] );
        ClassButtonsText:SetTextColor ( classCol[1] , classCol[2] , classCol[3] , 1 );
        ClassButtonsText:SetWidth ( 110 );
        ClassButtonsText:SetWordWrap ( false );
        ClassButtonsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
        ClassButtonsText:SetPoint ( "CENTER" , ClassButtons );
        ClassButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            ClassButtons:SetPoint ( "TOP" , GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownMenu , 0 , -7 );
            height = height + ClassButtons:GetHeight();
        else
            ClassButtons:SetPoint ( "TOP" , GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + ClassButtons:GetHeight() + buffer;
        end

        ClassButtons:SetScript ( "OnClick" , function( self , button ) 
            if button == "LeftButton" then
                local parsedNumber = 0;
                local nameOfButton = ClassButtons:GetName();
                for j = 1 , #nameOfButton do
                    if tonumber ( string.sub ( nameOfButton , j , j ) ) ~= nil then
                        -- NUM FOUND! Let's pull that number from the buttons and we'll know what class it is!
                        parsedNumber = tonumber ( string.sub ( nameOfButton , j ) );
                        break
                    end
                end
                local classColors = GRM.GetClassColorRGB ( AllClasses[parsedNumber] );
                GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownClassSelectedText:SetText ( ClassButtonsText:GetText() );
                GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownClassSelectedText:SetTextColor ( classColors[1] , classColors[2] , classColors[3] , 1 );
                GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownMenu:Hide();
                GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownClassSelected:Show();
                GRM_UI.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetFocus();
                GRM_AddonGlobals.tempAddBanClass = AllClasses[parsedNumber];
            end
        end);
        ClassButtons:Show();
    end
    GRM_UI.GRM_AddBanFrame.GRM_AddBanDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.SetGroupInviteButton ( string )
-- What it Does:
-- Purpose:
GRM.SetGroupInviteButton = function ( handle )
    if GetNumGroupMembers() > 0  then                                                               -- If > 0 then player is in either a raid or a party. (1 will show if in an instance by oneself)
        local isGroupLeader = UnitIsGroupLeader ( "PLAYER" );                                       -- Party or Group
        local isInRaidWithAssist = UnitIsGroupAssistant ( "PLAYER" , LE_PARTY_CATEGORY_HOME );      -- Player Has Assist in Raid group

        if GRM.IsGuildieInSameGroup ( handle ) then
            -- Player is already in group!
            GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( "In Group" );
            GRM_GroupInviteButton:SetScript ("OnClick" , function ( _ , button , down )
                if button == "LeftButton" then
                    print ( GRM.SlimName ( handle ) .. " is Already in Your Group!" );
                end
            end);
        elseif isGroupLeader or isInRaidWithAssist then                                         -- Player has the ability to invite to group
            GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( "Group Invite" );
            GRM_GroupInviteButton:SetScript ( "OnClick" , function ( _ , button , down )
                if button == "LeftButton" then
                    if IsInRaid() and GetNumGroupMembers() == 40 then                               -- Helpful reporting to cleanup the raid in case players are offline and no room to invite.
                        local afkList = GRM.GetGroupUnitsOfflineOrAFK();
                        local report = ( "\nROSTER NOTIFICATION!!!\n40 players have already been invited to this Raid!" );
                        if #afkList[1] > 0 then
                            report = ( report .. "\nPlayers Offline: " );
                            for i = 1 , #afkList[1]  do
                                report = ( report .. "" .. afkList[1][i] );
                                if i ~= #afkList[1] then
                                    report = ( report .. ", ");
                                end
                            end
                        end

                        if #afkList[2] > 0 then
                            report = ( report .. "\nPlayers AFK:     " );
                            for i = 1 , #afkList[2]  do
                                report = ( report .. "" .. afkList[2][i] );
                                if i ~= #afkList[2] then
                                    report = ( report .. ", ");
                                end
                            end
                        end
                        print ( report );
                    else
                        InviteUnit ( handle );
                    end
                end
            end);
        else            -- Player is in a group but does not have invite privileges
            GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( "No Invite" );
            GRM_GroupInviteButton:SetScript ( "OnClick" , function ( _ , button , down )
                if button == "LeftButton" then
                    print ( "Player should try to obtain group invite privileges." );
                end
            end);
        end
    else
        -- Player is not in any group, thus inviting them will create new group.
        GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( "Group Invite" );
        GRM_GroupInviteButton:SetScript ( "OnClick" , function ( _ , button , down )
            if button == "LeftButton" then
                InviteUnit ( handle );
            end
        end);
    end
end

-- Method:          GRM.CreateOptionsRankDropDown()
-- What it Does:    Builds the final rank drop down product for options panel
-- Purpose:         UI Feature for options to be able to filter who you will accept shared data from.
GRM.CreateOptionsRankDropDown = function ()
    GRM.PopulateOptionsRankDropDown();
    GRM.PopulateBanListOptionsDropDown();
    local setRankName = GuildControlGetRankName ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] + 1 );
    local setRankNameBanList = GuildControlGetRankName ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][22] + 1 );
    
    if setRankName == nil or setRankName == "" then
        setRankName = GuildControlGetRankName ( 1 )     -- Default it to guild leader. This scenario could happen if the rank was removed or you change guild but still have old settings.
    end
    if setRankNameBanList == nil or setRankNameBanList == "" then
        setRankNameBanList = GuildControlGetRankName ( 1 )     -- Default it to guild leader. This scenario could happen if the rank was removed or you change guild but still have old settings.
    end

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelectedText:SetText( setRankName );
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelectedText:SetText ( setRankNameBanList );

    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterSyncRankDropDownSelected:Show();
    GRM_UI.GRM_RosterCheckBoxSideFrame.GRM_RosterBanListDropDownSelected:Show();
end

-- Method:              GRM.ClearPromoDateHistory ( string )
-- What it Does:        Purges history of promotions as if they had just joined the guild.
-- Purpose:             Editing ability in case of user error.
GRM.ClearPromoDateHistory = function ( name )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then        -- Player found!
            -- Ok, let's clear the history now!
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][12] = nil;
            GRM_AddonGlobals.rankDateSet = false;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] = nil;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] = {};
            table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][4] , string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][2] , 1 , string.find ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][2] , "'" ) + 2 ) , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][3] } );
           
            GRM_MemberDetailRankDateTxt:Hide();
            GRM_SetPromoDateButton:Show();
            GRM_altDropDownOptions:Hide();
            break;
        end
    end
end

-- Method:              GRM.ClearJoinDateHistory ( string )
-- What it Does:        Clears the player's history on when they joined/left/rejoined the guild to be as if they were  a new member
-- Purpose:             Micromanagement of toons metadata.
GRM.ClearJoinDateHistory = function ( name )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then        -- Player found!
            -- Ok, let's clear the history now!
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20] = nil;   -- oldJoinDate wiped!
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20] = {};
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][21] = nil;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][21] = {};
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][15] = nil;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][15] = {};
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][16] = nil;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][16] = {};
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][2] = GRM.GetTimestamp();
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][3] = time();
            GRM_JoinDateText:Hide();
            GRM_altDropDownOptions:Hide();
            GRM_MemberDetailJoinDateButton:Show();
            break;
        end
    end
end

-- Method:              GRM.ResetPlayerMetaData ( string , string )
-- What it Does:        Purges all metadata from an alt up to that point and resets them as if they were just added to the guild roster
-- Purpose:             Metadata player management. QoL feature if ever needed.
GRM.ResetPlayerMetaData = function ( playerName , guildName )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then
            GRM.Report ( GRM.SlimName ( playerName ) .. "'s saved data has been wiped!" );
            local memberInfo = { playerName , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][4] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][5] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][6] , 
                                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][7] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][8] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][9] , nil , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][28] , 
                                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][29] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][30] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][31] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][33] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][34] };

            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                GRM.RemoveAlt ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] , playerName , guildName , false , 0 );      -- Removing oneself from his alts list on clearing info so it clears him from them too.
            end
            table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] , j );         -- Remove the player!
            GRM.AddMemberRecord( memberInfo , false , nil , guildName )     -- Re-Add the player!
            GRM_MemberDetailMetaData:Hide();
            
            --Let's re-initiate syncing!
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and not GRMsyncGlobals.currentlySyncing and GRM_AddonGlobals.HasAccessToGuildChat then
                chat:AddMessage ( "Re-Syncing " .. GRM.SlimName ( playerName ) .. "'s Player Data... " , 1.0 , 0.84 , 0 );
                GRMsync.Initialize();
            end
            break;
        end
    end
end

-- Method:          GRM.ResetAllSavedData()
-- What it Does:    Purges literally ALL saved data, then rebuilds it from scratch as if addon was just installed.
-- Purpose:         Clear data for any purpose needed.
GRM.ResetAllSavedData = function()
    GRM.Report ( "Wiping all saved Roster data! Rebuilding from scratch..." );

    GRM_GuildMemberHistory_Save = nil;
    GRM_GuildMemberHistory_Save = {};
    table.insert ( GRM_GuildMemberHistory_Save , { "Horde" } );
    table.insert ( GRM_GuildMemberHistory_Save , { "Alliance" } );

    GRM_PlayersThatLeftHistory_Save = nil;
    GRM_PlayersThatLeftHistory_Save = {};
    table.insert ( GRM_PlayersThatLeftHistory_Save , { "Horde" } );
    table.insert ( GRM_PlayersThatLeftHistory_Save , { "Alliance" } );

    GRM_LogReport_Save = nil;
    GRM_LogReport_Save = {};
    table.insert ( GRM_LogReport_Save , { "Horde" } );
    table.insert ( GRM_LogReport_Save , { "Alliance" } );

    GRM_CalendarAddQue_Save = nil;
    GRM_CalendarAddQue_Save = {};
    table.insert ( GRM_CalendarAddQue_Save , { "Horde" } );
    table.insert ( GRM_CalendarAddQue_Save , { "Alliance" } );

    GRM_PlayerListOfAlts_Save = nil;
    GRM_PlayerListOfAlts_Save = {};
    table.insert ( GRM_PlayerListOfAlts_Save , { "Horde" } );
    table.insert ( GRM_PlayerListOfAlts_Save , { "Alliance" } );

    -- Hide the window frame so it can quickly be reloaded.
    GRM_MemberDetailMetaData:Hide();

    -- Reset the important guild indexes for data tracking.
    GRM_AddonGlobals.saveGID = 0;
    GRM_AddonGlobals.logGID = 0;

    -- Now, let's rebuild...
    if IsInGuild() then
        GRM.BuildNewRoster();
    end
    -- Update the logFrame if it was open at the time too
    if GRM_RosterChangeLogFrame:IsVisible() then
        GRM.BuildLog();
    end

    -- Update the ban list too!
    if GRM_CoreBanListFrame:IsVisible() then
        GRM.RefreshBanListFrames();
    end

    -- Trigger Sync
    --Let's re-initiate syncing!
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and not GRMsyncGlobals.currentlySyncing and GRM_AddonGlobals.HasAccessToGuildChat then
        GRMsync.TriggerFullReset();
        -- Now, let's add a brief delay, 3 seconds, to trigger sync again
        C_Timer.After ( 3 , GRMsync.Initialize );
    end
end

-- Method:          GRM.ResetLogReport()
-- What it Does:    Deletes the guild Log
-- Purpose:         In case player wishes to reset guild Log information.
GRM.ResetLogReport = function()
    if #GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] == 1 then
        GRM.Report ( "There are No Log Entries to Delete, silly " .. GRM.SlimName( GRM_AddonGlobals.addonPlayerName ) .. "!" );
    else
        GRM.Report ( "Guild Log has been RESET!" );
        -- Actually resetting log. Just remove, then add back empty
        table.remove ( GRM_LogReport_Save[GRM_AddonGlobals.FID] , GRM_AddonGlobals.logGID );
        table.insert ( GRM_LogReport_Save[GRM_AddonGlobals.FID] , { GRM_AddonGlobals.guildName } );
        -- Need to reset Guild Index Location
        for i = 2 , #GRM_LogReport_Save[GRM_AddonGlobals.FID] do
            if GRM_LogReport_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.guildName then
                GRM_AddonGlobals.logGID = i;
                break;
            end
        end
        if GRM_RosterChangeLogFrame:IsVisible() then    -- if frame is open, let's rebuild it!
            GRM.BuildLog();
        end
    end
end

GRM.KickPromoteOrJoinPlayer = function ( self , msg , text )
    if msg == "CHAT_MSG_SYSTEM" and GuildRosterFrame ~= nil and GuildRosterFrame:IsVisible() then
        local frameName = "";
        if GRM_AddonGlobals.currentName ~= nil then
            frameName = GRM_AddonGlobals.currentName;
        end
        if string.find ( text , GRM_Localize ( "has been kicked" ) ) ~= nil and string.find ( text , GRM.SlimName ( GRM_AddonGlobals.addonPlayerName ) ) ~= nil and string.find ( text , GRM.SlimName ( frameName ) ) ~= nil then
            GRM_AddonGlobals.changeHappenedExitScan = true;
            -- BAN the alts!
            if GRM_AddonGlobals.isChecked2 then
                GRM.KickAllAlts ( frameName , GRM_AddonGlobals.guildName );
            end
            
            if GRM_AddonGlobals.isChecked then          -- Box is checked, so YES player should be banned. -This boolean is useful because this is a reused Blizz default frame, since protected function.
                -- Popup edit box - BAN logic...
                for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == frameName then
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][1] = true;      -- This officially tags the player as BANNED!
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][2] = time();
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][3] = false;
                        local result = GRM_MemberDetailPopupEditBox:GetText();
                        if result ~= "Reason Banned?\nClick \"Yes\" When Done" and result ~= "" and result ~= nil then
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] = result;
                        else
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] = "";
                            result = "";
                        end

                        -- Add a log message too if it is a ban!
                        local logEntry = "";
                        
                        if GRM_AddonGlobals.isChecked2 then
                            logEntry = ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( GRM_AddonGlobals.addonPlayerName ) .. " has BANNED " .. GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] ) .. " and all linked alts from the guild!!!" );
                            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] ~= "" then
                                GRM.AddLog ( 18 , "Reason Banned:        " .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] );
                            end
                            GRM.AddLog ( 17 , logEntry );
                        else
                            logEntry = ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( GRM_AddonGlobals.addonPlayerName ) .. " has BANNED " .. GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] ) .. " from the guild!!!" );
                            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] ~= "" then
                                GRM.AddLog ( 18 , "Reason Banned:        " .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] );
                            end
                            GRM.AddLog ( 17 , logEntry );
                        end

                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] then
                            GRM.PrintLog ( 17 , logEntry , false );
                            GRM.PrintLog ( 18 , "Reason Banned:        " .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] , false );
                        end

                        -- Send the message out!
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][21] then
                            if result == "" then
                                result = "None Given";
                            end
                            GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_BAN?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][22] ) .. "?" .. frameName .. "?" .. tostring ( GRM_AddonGlobals.isChecked2 ) .. "?" .. result .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][9] , "GUILD" );
                        end

                        break;
                    end
                end
            end
            -- Remove player normally
            local logReport = GRM.RecordKickChanges ( frameName , GRM.SlimName ( frameName ) , GRM_AddonGlobals.guildName , true );
            -- report the changes!
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] and not GRM_AddonGlobals.isChecked then
                GRM.PrintLog ( 10 , logReport , false );
            end
            GRM.AddLog ( 10 , logReport );
            GRM_MemberDetailMetaData:Hide();
            GRM.BuildLog();

            GRM_AddonGlobals.pause = false;
        
        elseif ( string.find ( text , GRM_Localize ( "has promoted" ) ) ~= nil or string.find ( text , GRM_Localize ( "has demoted" ) ) ~= nil ) and string.sub ( text , 1 , string.find ( text , " " ) -1 ) == GRM.SlimName ( GRM_AddonGlobals.addonPlayerName ) then
            GRM_AddonGlobals.changeHappenedExitScan = true;
            C_Timer.After ( 0.5 , function()
                GRM.OnRankChange ( GRM_AddonGlobals.CurrentRank , GuildMemberRankDropdownText:GetText() );
            end);
        elseif string.find ( text , GRM_Localize ( "joined the guild." ) ) ~= nil then
            GRM_AddonGlobals.changeHappenedExitScan = false;
            GuildRoster();
            GRM_AddonGlobals.trackingTriggered = false;
            QueryGuildEventLog();
        end

    elseif msg == "CHAT_MSG_SYSTEM" and string.find ( text , GRM_Localize ( "joined the guild." ) ) ~= nil then
        GRM_AddonGlobals.changeHappenedExitScan = false;
        GuildRoster();
        GRM_AddonGlobals.trackingTriggered = false;
        QueryGuildEventLog();
        -- Adds player in case of long delay...
    end
end

-- Method:          GRM.RemoveBan( int , boolean , boolean , int )
-- What it Does:    Just what it says... it removes the ban from the player and wipes the data clean. No history of ban is stored
-- Purpose:         Necessary for forgiveness or accidental banning.
GRM.RemoveBan = function ( playerIndex , onPopulate )
    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][playerIndex][17] = nil;
    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][playerIndex][17] = { false , time() , true }
    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][playerIndex][18] = "";

    GRM_MemberDetailBannedText1:Hide();
    GRM_MemberDetailBannedIgnoreButton:Hide();

    -- On populate is referring to the check for when it is on mouseover... no need to check this if not.
    if onPopulate and GRM_UI.GRM_CoreBanListFrame:IsVisible() then
        -- Refresh the frames:
        GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:Hide();
        GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetText ( "Select\na Player" );
        if GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons ~= nil then
            for i = 1 , #GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons do
                GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[i][1]:UnlockHighlight();
            end
        end
        GRM.RefreshBanListFrames();
    end
end

-- Method:          GRM.UnBanLeftPlayer ( string )
-- What it Does:    Unbans a listed player in the ban list
-- Purpose:         To be able to control who is banned and not banned in the guild.
GRM.UnBanLeftPlayer = function ( name )
    local isFound = false;
    for j = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then
            isFound = true;
            GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17] = nil;
            GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17] = { false , time() , true };
            GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][18] = "";
            break;
        end
    end
    return isFound;
end

-- Method:          GRM.BanListUnban ( string , boolean , int )
-- What it Does:    Unbans the player selected on the core ban list frame upon button push
-- Purpose:         Good to control who is and isn't on the ban list...
GRM.BanListUnban = function ( name )
    -- Check the players that left first!
    -- if the player was not found in the left player's list, then we know he is currently in the guild but on ban list!!!
    if not GRM.UnBanLeftPlayer ( name ) then
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then
                GRM.RemoveBan ( j , false )
                break;
            end
        end
    end

    -- Refresh the frames:
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:Hide();
    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetText ( "Select\na Player" );
    if GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons ~= nil then
        for i = 1 , #GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons do
            GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[i][1]:UnlockHighlight();
        end
    end
    GRM.RefreshBanListFrames();
end

GRM.SyncRemoveCurrentPlayerBan = function ( name , timestamp )
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == name then
            if timestamp > GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17][2] then
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17] = nil;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17] = { false , timestamp , true }
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][18] = "";
                
                GRM_MemberDetailBannedText1:Hide();
                GRM_MemberDetailBannedIgnoreButton:Hide();
                break;
            end
        end
    end
end

GRM.SyncAddCurrentPlayerBan = function ( name , timestamp , reason )
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == name then
            if timestamp > GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17][2] then
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17] = nil;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17] = { true , timestamp , false }
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][18] = reason;
                break;
            end
        end
    end
end


---------------------------------
------ CLASS INFO ---------------
---------------------------------

-- Work in progress that I will eventually get to... getting player roles!
GRM.GetClassRoles = function( className )
    local result;
    
    if className == "DEATH KNIGHT" then
        result = { "Blood" , 135770 ,  "Frost" , 135773 , "Unholy" , 135775 };
    elseif className == "DEMON HUNTER" then
        result = { "Havoc" , 1247264 , "Vengeance" , 1247265 , nil , nil };
    elseif className == "DRUID" then
        result = { "Restoration" , 0 , "Guardian" , 0 , "Feral" , 132115 , "Balance" , 0 };
    elseif className == "HUNTER" then

    elseif className == "MAGE" then

    elseif className == "MONK" then

    elseif className == "PALADIN" then

    elseif className == "PRIEST" then

    elseif className == "ROGUE" then

    elseif className == "SHAMAN" then

    elseif className == "WARLOCK" then

    elseif className == "WARRIOR" then

    end
    
    -- return result;
end


-------------------------------
---- GUILD BANK LOG INFO ------
-------------------------------

-- Method:          GRM.SpeedQueryBankInfoTracking()
-- What it Does:    As soon as the guild bank window is opened, it immediately queries every tab.
-- Purpose:         Query can take a bit on the server callback. Might as well trigger it immediately.
GRM.SpeedQueryBankInfoTracking = function( )
    for i = 1 , GetNumGuildBankTabs() do
        QueryGuildBankLog ( i );
    end
end






-------------------------------
----- UI SCRIPTING LOGIC ------
----- ALL THINGS UX ARE HERE --
-------------------------------

-- Method:          GRM.GRM.PopulateMemberDetails ( string )
-- What it Does:    Builds the details for the core MemberInfoFrame
-- Purpose:         Iterate on each mouseover... Furthermore, this is being kept in "Local" for even the most infinitesimal cost-saving on resources
--                  by not indexing it in a table. Buried in it will be mostly non-compartmentalized logic, few function calls.
GRM.PopulateMemberDetails = function( handle )
    if handle ~= "" and handle ~= nil then              -- If the handle is failed to be returned, it is returned as an empty string. Just logic to not populate if on failure.
        GRM_AddonGlobals.rankDateSet = false;        -- resetting tracker

        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == handle then   --- Player Found in MetaData Logs
                -- Trigger Check for Any Changes
                GuildRoster();

                --- CLASS
                local classColors = GRM.GetClassColorRGB ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][9] );
                GRM_MemberDetailNameText:SetTextColor ( classColors[1] , classColors[2] , classColors[3] , 1.0 );
                
                -- PLAYER NAME
                -- Let's scale the name too!
                GRM_MemberDetailNameText:SetText ( GRM.SlimName ( handle ) );
                local nameHeight = 16;
                GRM_MemberDetailNameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + nameHeight );        -- Reset size back to 16 just in case previous fontstring was altered 
                while ( GRM_MemberDetailNameText:GetWidth() > 120 ) do
                    nameHeight = nameHeight - 0.1;
                    GRM_MemberDetailNameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + nameHeight );
                end

                -- IS MAIN
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][10] then
                    GRM_MemberDetailMainText:Show();
                else
                    GRM_MemberDetailMainText:Hide();
                end

                --- LEVEL
                if GRM_AddonGlobals.Region == "ruRU" or GRM_AddonGlobals.Region == "koKR" then
                    GRM_MemberDetailLevel:SetText (  tostring ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][6] ) .. GRM_Localize ( "Level: " ) );
                else
                    GRM_MemberDetailLevel:SetText ( GRM_Localize ( "Level: " ) .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][6] );
                end

                -- RANK
                GRM_AddonGlobals.rankIndex = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5];

                -- Possibly a player index issue...
                if GRM_AddonGlobals.playerIndex == -1 then
                    GRM_AddonGlobals.playerIndex = GRM.GetGuildMemberRankID ( GRM_AddonGlobals.addonPlayerName );
                end

                -- Rank Text Info...
                GRM_MemberDetailRankTxt:SetText ( "\"" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] .. "\"");
                GRM_MemberDetailRankTxt:Show();

                -- STATUS TEXT
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] or handle == GRM_AddonGlobals.addonPlayerName then
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][34] == 0 then
                        GRM_MemberDetailPlayerStatus:SetTextColor ( 0.12 , 1.0 , 0.0 , 1.0 );
                        GRM_MemberDetailPlayerStatus:SetText ( "( Active )" );
                    elseif GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][34] == 1 then
                        GRM_MemberDetailPlayerStatus:SetTextColor ( 1.0 , 0.96 , 0.41 , 1.0 );
                        GRM_MemberDetailPlayerStatus:SetText ( "( AFK )" );
                    else
                        GRM_MemberDetailPlayerStatus:SetTextColor ( 0.77 , 0.12 , 0.23 , 1.0 );
                        GRM_MemberDetailPlayerStatus:SetText ( "( Busy )" );
                    end
                    GRM_MemberDetailPlayerStatus:Show();
                elseif GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][30] then
                    GRM_MemberDetailPlayerStatus:SetTextColor ( 0.87 , 0.44 , 0.0 , 1.0 );
                    GRM_MemberDetailPlayerStatus:SetText ( "( Mobile )" );
                    GRM_MemberDetailPlayerStatus:Show();
                elseif not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                    GRM_MemberDetailPlayerStatus:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
                    GRM_MemberDetailPlayerStatus:SetText ( "( Offline )" );
                    GRM_MemberDetailPlayerStatus:Show();
                else
                    GRM_MemberDetailPlayerStatus:Hide();
                end

                -- ZONE INFORMATION
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= nil then
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] );                                     -- Zone
                        GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] ) );              -- Time Passed
                    end
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Show();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Show();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Show();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Show();
                else
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Hide();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Hide();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Hide();
                    GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Hide();
                end

                --RANK PROMO DATE
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] == nil then      --- Promotion has never been recorded!
                    GRM_MemberDetailRankDateTxt:Hide();
                    GRM_SetPromoDateButton:Show();
                else
                    GRM_SetPromoDateButton:Hide();
                    GRM_AddonGlobals.rankDateSet = true;
                    GRM_MemberDetailRankDateTxt:SetText ( "Promoted: " .. GRM.Trim ( string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] , 1 , 10) ) );
                    GRM_MemberDetailRankDateTxt:Show();
                end

                if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] == 0 then
                    GRM_JoinDateText:Hide();
                    GRM_MemberDetailJoinDateButton:Show();
                else
                    GRM_MemberDetailJoinDateButton:Hide();
                    GRM_JoinDateText:SetText ( string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20][#GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20]] , 1 , 10 ) );
                    GRM_JoinDateText:Show();
                end

                -- PLAYER NOTE AND OFFICER NOTE EDIT BOXES
                local finalNote = "Click here to set a Public Note";
                local finalONote = "Click here to set an Officer's Note";
                GRM_PlayerNoteEditBox:Hide();
                GRM_PlayerOfficerNoteEditBox:Hide();

                -- Set Public Note if is One
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][7] ~= nil and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][7] ~= "" then
                    finalNote = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][7];
                end
                GRM_noteFontString1:SetText ( finalNote );
                if CanEditPublicNote() then
                    if finalNote ~= "Click here to set a Public Note" then
                        GRM_PlayerNoteEditBox:SetText( finalNote );
                    else
                        GRM_PlayerNoteEditBox:SetText( "" );
                    end
                elseif finalNote == "Click here to set a Public Note" then
                    GRM_noteFontString1:SetText ( "Unable to Edit Public Note at Rank" );
                end

                -- Set O Note
                if CanViewOfficerNote() == true then
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8] ~= nil and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8] ~= "" then
                        finalONote = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8];
                    end
                    if finalONote == "Click here to set an Officer's Note" and CanEditOfficerNote() ~= true then
                        finalONote = "Unable to Add Officer Note at Rank";
                    end
                    GRM_noteFontString2:SetText ( finalONote );
                    if finalONote ~= "Click here to set an Officer's Note" then
                        GRM_PlayerOfficerNoteEditBox:SetText( finalONote );
                    else
                        GRM_PlayerOfficerNoteEditBox:SetText( "" );
                    end
                else
                    GRM_noteFontString2:SetText ( "Unable to View Officer Note at Rank" );
                end
                GRM_noteFontString2:Show();
                GRM_noteFontString1:Show();

                -- Last Online
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                    GRM_MemberDetailLastOnlineTxt:SetText ( "Online" );
                else
                    GRM_MemberDetailLastOnlineTxt:SetText ( GRM.HoursReport ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][24] ) );
                end

                -- Group Invite Button -- Setting script here
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] and handle ~= GRM_AddonGlobals.addonPlayerName then
                    GRM.SetGroupInviteButton ( handle );
                    GRM_GroupInviteButton:Show();
                else
                    GRM_GroupInviteButton:Hide();
                end

                -- IF PLAYER WAS PREVIOUSLY BANNED AND REJOINED
                -- Player was previous banned and rejoined logic! This will unban the player.
                local isGuildieBanned = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][1];
                if isGuildieBanned and handle ~= GRM_AddonGlobals.addonPlayerName and CanGuildRemove() then
                    GRM_MemberDetailBannedIgnoreButton:SetScript ( "OnClick" , function ( _ , button ) 
                        if button == "LeftButton" then
                            GRM.RemoveBan ( r , true );

                            -- Send the unban out for sync'd players
                            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][21] then
                                GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_UNBAN?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][22] ) .. "?" .. GRM_AddonGlobals.TempBanTarget .. "?" , "GUILD");
                            end
                            -- Message
                            if GRM_AddonGlobals.TempBanTarget ~= "" and GRM_AddonGlobals.TempBanTarget ~= nil then
                                chat:AddMessage ( GRM.SlimName ( GRM_AddonGlobals.TempBanTarget ) " has been Removed from the Ban List." , 1.0 , 0.84 , 0 );
                            end
                        end
                    end);
                    
                    GRM_MemberDetailBannedText1:Show();
                    GRM_MemberDetailBannedIgnoreButton:Show();
                else
                    GRM_MemberDetailBannedText1:Hide();
                    GRM_MemberDetailBannedIgnoreButton:Hide();
                end

                -- ALTS 
                GRM.PopulateAltFrames ( r );

                break;
            end
        end
    end
end

-- Method:          GRM.ClearAllFrames()
-- What it Does:    Ensures frames are properly reset upon frame reload...
-- Purpose:         Logic time-saver for minimal costs... why check status of them all when you can just disable and build anew on each reload?
GRM.ClearAllFrames = function()
    GRM_MemberDetailMetaData:Hide();
    GRM_MonthDropDownMenuSelected:Hide();
    GRM_YearDropDownMenuSelected:Hide();
    GRM_DayDropDownMenuSelected:Hide();
    GRM_DateSubmitButton:Hide();
    GRM_DateSubmitCancelButton:Hide();
    GRM_NoteCount:Hide();
    GRM_CoreAltFrame:Hide();
    GRM_altDropDownOptions:Hide();
    GRM_AddAltButton:Hide();
    GRM_AddAltEditFrame:Hide();

end

-- Method:          GRM.SubFrameCheck()
-- What it Does:    Checks the core main frames, if they are open... and hides them
-- Purpose:         Questionable at this time... I might rewrite it with just 4 lines... It serves its purpose now
GRM.SubFrameCheck = function()
    -- wipe the frames...
    if GRM_DateSubmitCancelButton:IsVisible() then
        GRM_DateSubmitCancelButton:Click();
    end
    if GRM_AddAltEditFrame:IsVisible() then
        GRM_AddAltEditFrame:Hide();
    end
    if GRM_NoteCount:IsVisible() then
        GRM_NoteCount:Hide();
    end
end


-- Method:              GR_RosterFrame()
-- What it Does:        In the main guild window, guild roster screen, rather than having to select a guild member to see the additional window pop update
--                      all the player needs to do is just mousover it.
-- Purpose:             This is for more efficient "glancing" at info for guild leader, with more details.
--                      NOTE: Also going to keep this as a local variable, not in a table, just for purposes of the faster response time, albeit minimally.
local function GR_RosterFrame ()
    -- Frame button logic for AddEvent
    
    -- For copying the name instead... Good for shift click.
    local nameCopy = false;
    if IsShiftKeyDown() and GetCurrentKeyBoardFocus() ~= nil and ( IsMouseButtonDown( 1 ) or GetCurrentKeyBoardFocus():GetName() == "GRM_AddAltEditBox" )then
        nameCopy = true;
    end

    if GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] ~= nil then
        if #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] > 1 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][8] and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][12] then
            GRM_AddEventLoadFrameButtonText:SetText ( "Calendar Que: " .. #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] - 1 );     -- First index will be nil.
            GRM_AddEventLoadFrameButton:Show();
        else
            GRM_AddEventLoadFrameButton:Hide();
        end
        -- control on whether to freeze the scanning.
        if not nameCopy and GRM_AddonGlobals.pause and not GRM_MemberDetailMetaData:IsVisible() and not GuildMemberDetailFrame:IsVisible() then
            GRM_AddonGlobals.pause = false;
        end

        -- Really need to localize the "Professions"
        if nameCopy or ( GRM_AddonGlobals.pause == false and not DropDownList1:IsVisible() and not GuildMemberDetailFrame:IsVisible() and ( GuildRosterViewDropdownText:IsVisible() and GuildRosterViewDropdownText:GetText() ~= "Professions" ) ) then
            if not nameCopy then
                GRM.SubFrameCheck();
            end
            local NotSameWindow = true;
            local mouseNotOver = true;
            local name = "";
            
            if ( GuildRosterContainerButton1:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                if 1 ~= GRM_AddonGlobals.position or nameCopy then
                    name = GRM.GetRosterName ( GuildRosterContainerButton1String2 , GuildRosterContainerButton1String1 , 1 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 1;
                        GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            GRM.GR_Roster_Click ( name );
                        end
                    else
                        NotSameWindow = false;
                    end
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif ( GuildRosterContainerButton2:IsVisible() and GuildRosterContainerButton2:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                if 2 ~= GRM_AddonGlobals.position or nameCopy then
                    name = GRM.GetRosterName ( GuildRosterContainerButton2String2 , GuildRosterContainerButton2String1 , 2 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 2;
                        GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            GRM.GR_Roster_Click ( name );
                        end
                    else
                        NotSameWindow = false;
                    end
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif ( GuildRosterContainerButton3:IsVisible() and GuildRosterContainerButton3:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                if 3 ~= GRM_AddonGlobals.position or nameCopy then
                    name = GRM.GetRosterName ( GuildRosterContainerButton3String2 , GuildRosterContainerButton3String1  , 3 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 3;
                        GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            GRM.GR_Roster_Click ( name );
                        end
                    else
                        NotSameWindow = false;
                    end
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif ( GuildRosterContainerButton4:IsVisible() and GuildRosterContainerButton4:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                if 4 ~= GRM_AddonGlobals.position or nameCopy then
                    name = GRM.GetRosterName ( GuildRosterContainerButton4String2 , GuildRosterContainerButton4String1 , 4 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 4;
                        GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            GRM.GR_Roster_Click ( name );
                        end
                    else
                        NotSameWindow = false;
                    end
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif ( GuildRosterContainerButton5:IsVisible() and GuildRosterContainerButton5:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                if 5 ~= GRM_AddonGlobals.position or nameCopy then
                    name = GRM.GetRosterName ( GuildRosterContainerButton5String2 , GuildRosterContainerButton5String1 , 5 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 5;
                        GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            GRM.GR_Roster_Click ( name );
                        end
                    else
                        NotSameWindow = false;
                    end
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif ( GuildRosterContainerButton6:IsVisible() and GuildRosterContainerButton6:IsMouseOver(1,-1,-1,1) ) then
                if 6 ~= GRM_AddonGlobals.position or nameCopy then
                    name = GRM.GetRosterName ( GuildRosterContainerButton6String2 , GuildRosterContainerButton6String1 , 6 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 6;
                        GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            GRM.GR_Roster_Click ( name );
                        end
                    else
                        NotSameWindow = false;
                    end
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif ( GuildRosterContainerButton7:IsVisible() and GuildRosterContainerButton7:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                if 7 ~= GRM_AddonGlobals.position or nameCopy then
                    name = GRM.GetRosterName ( GuildRosterContainerButton7String2 , GuildRosterContainerButton7String1 , 7 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 7;
                        GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            GRM.GR_Roster_Click ( name );
                        end
                    else
                        NotSameWindow = false;
                    end
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif ( GuildRosterContainerButton8:IsVisible() and GuildRosterContainerButton8:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                if 8 ~= GRM_AddonGlobals.position or nameCopy then
                    name = GRM.GetRosterName ( GuildRosterContainerButton8String2 , GuildRosterContainerButton8String1 , 8 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 8;
                        GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            GRM.GR_Roster_Click ( name );
                        end
                    else
                        NotSameWindow = false;
                    end
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif ( GuildRosterContainerButton9:IsVisible() and GuildRosterContainerButton9:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                if 9 ~= GRM_AddonGlobals.position or nameCopy then
                    name = GRM.GetRosterName ( GuildRosterContainerButton9String2 , GuildRosterContainerButton9String1 , 9 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 9;
                        GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            GRM.GR_Roster_Click ( name );
                        end
                    else
                        NotSameWindow = false;
                    end
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif ( GuildRosterContainerButton10:IsVisible() and GuildRosterContainerButton10:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                if 10 ~= GRM_AddonGlobals.position or nameCopy then
                    name = GRM.GetRosterName ( GuildRosterContainerButton10String2 , GuildRosterContainerButton10String1 , 10 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 10;
                        GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            GRM.GR_Roster_Click ( name );
                        end
                    else
                        NotSameWindow = false;
                    end
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif ( GuildRosterContainerButton11:IsVisible() and GuildRosterContainerButton11:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                if 11 ~= GRM_AddonGlobals.position or nameCopy then
                    name = GRM.GetRosterName ( GuildRosterContainerButton11String2 , GuildRosterContainerButton11String1 , 11 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 11;
                        GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            GRM.GR_Roster_Click ( name );
                        end
                    else
                        NotSameWindow = false;
                    end
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif ( GuildRosterContainerButton12:IsVisible() and GuildRosterContainerButton12:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                if 12 ~= GRM_AddonGlobals.position or nameCopy then
                    name = GRM.GetRosterName ( GuildRosterContainerButton12String2 , GuildRosterContainerButton12String1 , 12 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 12;
                        GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            GRM.GR_Roster_Click ( name );
                        end
                    else
                        NotSameWindow = false;
                    end
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif ( GuildRosterContainerButton13:IsVisible() and GuildRosterContainerButton13:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                if 13 ~= GRM_AddonGlobals.position or nameCopy then
                    name = GRM.GetRosterName ( GuildRosterContainerButton13String2 , GuildRosterContainerButton13String1 , 13 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 13;
                        GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            GRM.GR_Roster_Click ( name );
                        end
                    else
                        NotSameWindow = false;
                    end
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif ( GuildRosterContainerButton14:IsVisible() and GuildRosterContainerButton14:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                if 14 ~= GRM_AddonGlobals.position or nameCopy then
                    name = GRM.GetRosterName ( GuildRosterContainerButton14String2 , GuildRosterContainerButton14String1 , 14 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 14;
                        GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            GRM.GR_Roster_Click ( name );
                        end
                    else
                        NotSameWindow = false;
                    end
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            elseif ( GuildRosterContainerButton15:IsVisible() and GuildRosterContainerButton15:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                if 15 ~= GRM_AddonGlobals.position or nameCopy then
                    name = GRM.GetRosterName ( GuildRosterContainerButton15String2 , GuildRosterContainerButton15String1 , 15 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 15;
                        GRM_AddonGlobals.ScrollPosition = GuildRosterContainerScrollBar:GetValue();
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_MemberDetailMetaData:Show();
                            end
                            GRM_AddonGlobals.currentName = name;
                            GRM_AddonGlobals.pause = false;
                        else
                            GRM.GR_Roster_Click ( name );
                        end
                    else
                        NotSameWindow = false;
                    end
                else
                    NotSameWindow = false;
                end
                mouseNotOver = false;
            end
            -- Logic on when to make Member Detail window disappear.
            if mouseNotOver and NotSameWindow and GRM_AddonGlobals.pause == false then
                if ( GuildRosterFrame:IsMouseOver ( 2 , -2 , -2 , 2 ) ~= true and not DropDownList1Backdrop:IsMouseOver ( 2 , -2 , -2 , 2 ) and not StaticPopup1:IsMouseOver ( 2 , -2 , -2 , 2 ) and not GRM_MemberDetailMetaData:IsMouseOver ( 2 , -2 , -2 , 2 ) ) or 
                    ( GRM_MemberDetailMetaData:IsMouseOver ( 2 , -2 , -2 , 2 ) == true and GRM_MemberDetailMetaData:IsVisible() ~= true ) then  -- If player is moused over side window, it will not hide it!
                    GRM_AddonGlobals.position = 0;
                    
                    GRM.ClearAllFrames();
                end
            end
        end
    end

    if GuildRosterFrame:IsVisible() ~= true or ( GuildRosterViewDropdownText:IsVisible() and GuildRosterViewDropdownText:GetText() == "Professions" ) then
        GRM_AddonGlobals.position = 0;
        GRM.ClearAllFrames();
    end
end


-- Method:          GRM.SelectPlayerOnRoster ( string )
-- What it Does:    If the guild roster window is open, this will jump to the player anywhere in the roster, online or offline, and bring up their metadata window
-- Purpose:         Useful for when a player wants to click and alt rather than have to scan through the roster for them.
GRM.SelectPlayerOnRoster = function ( playerName )

    -- Ok, let's find the position the player is in right now...
    local position = -1;
    local isFoundOnline = false;
    local numGuildies = GRM.GetNumGuildies();
    -- if the action bars are showing ONLY the online players - determining if given player is online.

    -- If the player is ONLY looking at online players, let's do this scan slightly more efficiently
    -- You see, IF the selected player is online, the scan will be quicker! No need to parse the entire roster unnecessarily.
    if not GRM_AddonGlobals.ShowOfflineChecked then
        for i = 1 , numGuildies do
            local name , _ , _ , _ , _ , _ , _ , _ , isOnline = GetGuildRosterInfo ( i );
            if not isOnline then
                break;
                -- once it reaches the end of the onlines, it kills it...
            elseif name == playerName then
                position = i;
                isFoundOnline = true;
                break;
            end
        end
    end
    
    -- Omg, IF so, then we know 2 things... the players is first, only looking at online players and second, is currently online!
    -- if not isFoundOnline then
    --     -- Let's make sure we are looking at all players...
    --     GuildRosterShowOfflineButton:SetChecked( true );
    --     SetGuildRosterShowOffline ( true );

    --     -- Ok, now we need to find the player's position...
    --     for i = 1 , numGuildies do
    --         local name = GetGuildRosterInfo ( i );
            
    --         -- match the name!
    --         if name == playerName then
    --             position = i;
    --             break;
    --         end
    --     end
    -- end

    -- Ok, let's set the position!
    -- To do that, we need to figure out how to scale the guild
    -- We don't need to scroll if the guild has 14 members or less. We do if otherwise.
    -- if position <= 14 or numGuildies <= 14 then
    --     GuildRosterContainerScrollBar:SetValue ( 0 );
    -- else
    --     -- Now here is the fancy footwork. It is roughly +300 position length for every 14 players in the guild. So, let's see how many we need to go.
    --     --- THIS LINE CAUSES TAINT!!!!!!!
    --     -- GuildRosterContainerScrollBar:SetValue ( ( position / 14 ) * ( 300 + ( position / 127 ) ) ); -- After some testing on guilds size 15 to size 100, the magic number really is 127. At 125, the extra few pts, if the player is at position 999, puts them too far
    --     --- THIS LINE CAUSES TAINT!!!!!!!
    --     GuildRosterContainerScrollBarMiddle:Show();
    -- end
    
    -- local mobileFreeName = "";
    -- for i = 1 , 15 do
    --     -- Select the button!
    --     if i == 1 then
    --         mobileFreeName = GRM.GetRosterName ( GuildRosterContainerButton1String2 , GuildRosterContainerButton1String1 , 1 );
    --     elseif i == 2 then
    --         mobileFreeName = GRM.GetRosterName ( GuildRosterContainerButton2String2 , GuildRosterContainerButton2String1 , 2 );
    --     elseif i == 3 then
    --         mobileFreeName = GRM.GetRosterName ( GuildRosterContainerButton3String2 , GuildRosterContainerButton3String1 , 3 );
    --     elseif i == 4 then
    --         mobileFreeName = GRM.GetRosterName ( GuildRosterContainerButton4String2 , GuildRosterContainerButton4String1 , 4 );
    --     elseif i == 5 then
    --         mobileFreeName = GRM.GetRosterName ( GuildRosterContainerButton5String2 , GuildRosterContainerButton5String1 , 5 );
    --     elseif i == 6 then
    --         mobileFreeName = GRM.GetRosterName ( GuildRosterContainerButton6String2 , GuildRosterContainerButton6String1 , 6 );
    --     elseif i == 7 then
    --         mobileFreeName = GRM.GetRosterName ( GuildRosterContainerButton7String2 , GuildRosterContainerButton7String1 , 7 );
    --     elseif i == 8 then
    --         mobileFreeName = GRM.GetRosterName ( GuildRosterContainerButton8String2 , GuildRosterContainerButton8String1 , 8 );
    --     elseif i == 9 then
    --         mobileFreeName = GRM.GetRosterName ( GuildRosterContainerButton9String2 , GuildRosterContainerButton9String1 , 9 );
    --     elseif i == 10 then
    --         mobileFreeName = GRM.GetRosterName ( GuildRosterContainerButton10String2 , GuildRosterContainerButton10String1 , 10 );
    --     elseif i == 11 then
    --         mobileFreeName = GRM.GetRosterName ( GuildRosterContainerButton11String2 , GuildRosterContainerButton11String1 , 11 );
    --     elseif i == 12 then
    --         mobileFreeName = GRM.GetRosterName ( GuildRosterContainerButton12String2 , GuildRosterContainerButton12String1 , 12 );
    --     elseif i == 13 then
    --         mobileFreeName = GRM.GetRosterName ( GuildRosterContainerButton13String2 , GuildRosterContainerButton13String1 , 13 );
    --     elseif i == 14 then
    --         mobileFreeName = GRM.GetRosterName ( GuildRosterContainerButton14String2 , GuildRosterContainerButton14String1 , 14 );
    --     elseif i == 15 then
    --         mobileFreeName = GRM.GetRosterName ( GuildRosterContainerButton15String2 , GuildRosterContainerButton15String1 , 15 );
    --     end
        
    --     if mobileFreeName ~= "" and mobileFreeName ~= nil and mobileFreeName == playerName then
    --         -- Player is found!
    --         GRM_AddonGlobals.currentName = playerName;
    --         GRM_AddonGlobals.pause = false;
    --         GRM.PopulateMemberDetails ( playerName );

    --         -- Make sure we hide this frame if needed
    --         -- GRM_AddonGlobals.RosterButtons[i]:LockHighlight();
    --         -- GRM.RemoveRosterButtonHighlights ( GRM_AddonGlobals.RosterButtons[i] );
    --         GRM_AddonGlobals.pause = true;
    --         break;
    --     end
    -- end   
    GRM_AddonGlobals.currentName = playerName;
    GRM_AddonGlobals.pause = false;
    GRM.PopulateMemberDetails ( playerName );
    GRM_AddonGlobals.pause = true;
end

-- BANNING LOGIC AND METHODS


-- Method:          GRM.RefreshBanListFrames()
-- What it Does:    On loading the Ban List frames, it populates and prepares them for a scrollable window if necessary
-- purpose:         Quality of Life. Whilst the ban list is managed automatically behind the scenes, it is useful to have common information that syncs between users
--                  with the guild.
GRM.RefreshBanListFrames = function()

    -- SCRIPT LOGIC ON ADD EVENT SCROLLING FRAME
    local scrollHeight = 0;
    local scrollWidth = 220;
    local buffer = 20;

    GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons = GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons or {};  -- Create a table for the Buttons.

    
    -- populating the window correctly.
    local count = 0;
    -- Populating the window based on the Left PLayers
    for i = #GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] , 2 , -1 do
        -- if font string is not created, do so.
        if GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][17][1] then  -- If player is banned.
                
            count = count + 1;
            if not GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[count] then
                local tempButton = CreateFrame ( "Button" , "BannedPlayer" .. count , GRM_UI.GRM_CoreBanListScrollChildFrame ); -- Names each Button 1 increment up
                table.insert ( GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons , { tempButton , tempButton:CreateFontString ( "BannedPlayerNameText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "BannedPlayerRankText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "BannedPlayerDateText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "BannedPlayerReasonText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) } );
            end

            local BanButtons = GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][1];
            local BanNameText = GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][2];
            local BanRankText = GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][3];
            local BanDateText = GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][4];
            local BanReasonText = GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][5];
            local classColor = GRM.GetClassColorRGB ( GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][9] );

            BanButtons:SetPoint ( "TOP" , GRM_UI.GRM_CoreBanListScrollChildFrame , 7 , -99 );
            BanButtons:SetWidth ( 200 );
            BanButtons:SetHeight ( 19 );
            BanButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
            BanNameText:SetText ( GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][1] );
            BanNameText:SetTextColor ( classColor[1] , classColor[2] , classColor[3] , 1 );
            BanNameText:SetWidth ( 235 );
            BanNameText:SetWordWrap ( false );
            BanNameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            BanNameText:SetPoint ( "LEFT" , BanButtons );
            BanNameText:SetJustifyH ( "LEFT" );
            BanRankText:SetText ( GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][19] );
            BanRankText:SetWidth ( 150 );
            BanRankText:SetWordWrap ( false );
            BanRankText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            BanRankText:SetPoint ( "RIGHT" , BanButtons , 168 , 0 );
            BanRankText:SetJustifyH ( "CENTER" );
            BanRankText:SetTextColor ( 0.90 , 0.80 , 0.50 , 1.0 );
            BanDateText:SetText ( GRM.EpochToDateFormat ( GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][17][2] ) );
            BanDateText:SetWidth ( 162 );
            BanDateText:SetWordWrap ( false );
            BanDateText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            BanDateText:SetPoint ( "RIGHT" , BanButtons , 358 , 0 );
            BanDateText:SetJustifyH ( "LEFT" );
            -- Determine it's not an empty ban reason!
            local reason = "";
            if GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][18] == "" or GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][18] == nil then
                reason = "No Ban Reason Given";
            else
                reason = GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][18];
            end
            BanReasonText:SetText ( "Reason: " .. reason );
            BanReasonText:SetWidth ( 235 );
            BanReasonText:SetWordWrap ( true );
            BanReasonText:SetSpacing ( 1 );
            BanReasonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            BanReasonText:SetPoint ( "TOPLEFT" , BanButtons , "BOTTOMLEFT" , 0 , -1);
            BanReasonText:SetJustifyH ( "LEFT" );

            -- Logic
            BanButtons:SetScript ( "OnClick" , function ( self , button )
                if button == "LeftButton" then
                    -- For highlighting purposes
                    for j = 1 , #GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons do
                        if BanButtons ~= GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1] then
                            GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1]:UnlockHighlight();
                        else
                            GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1]:LockHighlight();
                        end
                    end
                    
                    local fullName = BanNameText:GetText();
                    GRM_AddonGlobals.TempBanTarget = fullName;
                    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:SetText ( GRM.SlimName ( fullName ) );
                    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetText ( "Player\nSelected" );
                    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:Show();
                    
                end
            end);
            
            -- Now let's pin it!
            
            if count == 1 then
                BanButtons:SetPoint( "TOPLEFT" , 0 , - 5 );
                scrollHeight = scrollHeight + BanButtons:GetHeight() + BanReasonText:GetHeight();
            else
                BanButtons:SetPoint( "TOPLEFT" , GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[count - 1][5] , "BOTTOMLEFT" , 0 , - buffer );
                scrollHeight = scrollHeight + BanButtons:GetHeight() + BanReasonText:GetHeight() + buffer;
            end
            BanButtons:Show();
        end
    end

    -- Populating the window based on the Current Players PLayers
    for i = #GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] , 2 , -1 do
        -- if font string is not created, do so.
        if GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][17][1] then  -- If player is banned.
                
            count = count + 1;
            if not GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[count] then
                local tempButton = CreateFrame ( "Button" , "BannedPlayer" .. count , GRM_UI.GRM_CoreBanListScrollChildFrame ); -- Names each Button 1 increment up
                table.insert ( GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons , { tempButton , tempButton:CreateFontString ( "BannedPlayerNameText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "BannedPlayerRankText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "BannedPlayerDateText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "BannedPlayerReasonText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) } );
            end

            local BanButtons = GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][1];
            local BanNameText = GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][2];
            local BanRankText = GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][3];
            local BanDateText = GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][4];
            local BanReasonText = GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][5];
            local classColor = GRM.GetClassColorRGB ( GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][9] );

            BanButtons:SetPoint ( "TOP" , GRM_UI.GRM_CoreBanListScrollChildFrame , 7 , -99 );
            BanButtons:SetWidth ( 200 );
            BanButtons:SetHeight ( 19 );
            BanButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
            BanNameText:SetText ( GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][1] .. "  |cff7fff00(Still in Guild)" );
            BanNameText:SetTextColor ( classColor[1] , classColor[2] , classColor[3] , 1 );
            BanNameText:SetWidth ( 235 );
            BanNameText:SetWordWrap ( false );
            BanNameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            BanNameText:SetPoint ( "LEFT" , BanButtons );
            BanNameText:SetJustifyH ( "LEFT" );
            BanRankText:SetText ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][4] );
            BanRankText:SetWidth ( 150 );
            BanRankText:SetWordWrap ( false );
            BanRankText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            BanRankText:SetPoint ( "RIGHT" , BanButtons , 168 , 0 );
            BanRankText:SetJustifyH ( "CENTER" );
            BanRankText:SetTextColor ( 0.90 , 0.80 , 0.50 , 1.0 );
            BanDateText:SetText ( GRM.EpochToDateFormat ( GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][17][2] ) );
            BanDateText:SetWidth ( 162 );
            BanDateText:SetWordWrap ( false );
            BanDateText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            BanDateText:SetPoint ( "RIGHT" , BanButtons , 358 , 0 );
            BanDateText:SetJustifyH ( "LEFT" );
            -- Determine it's not an empty ban reason!
            local reason = "";
            if GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][18] == "" or GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][18] == nil then
                reason = "No Ban Reason Given";
            else
                reason = GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][18];
            end
            BanReasonText:SetText ( "Reason: " .. reason );
            BanReasonText:SetWidth ( 235 );
            BanReasonText:SetWordWrap ( true );
            BanReasonText:SetSpacing ( 1 );
            BanReasonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            BanReasonText:SetPoint ( "TOPLEFT" , BanButtons , "BOTTOMLEFT" , 0 , -1);
            BanReasonText:SetJustifyH ( "LEFT" );

            -- Logic
            BanButtons:SetScript ( "OnClick" , function ( self , button )
                if button == "LeftButton" then
                    -- For highlighting purposes
                    for j = 1 , #GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons do
                        if BanButtons ~= GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1] then
                            GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1]:UnlockHighlight();
                        else
                            GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1]:LockHighlight();
                        end
                    end
                    local fullName = BanNameText:GetText();
                    GRM_AddonGlobals.TempBanTarget = string.sub ( fullName , 1 , string.find ( fullName , " " ) - 1 );  -- Need to parse out the "(Still in Guild)"
                    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:SetText ( GRM.SlimName ( fullName ) );
                    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetText ( "Player\nSelected" );
                    GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:Show();
                    
                end
            end);
            
            -- Now let's pin it!
            
            if count == 1 then
                BanButtons:SetPoint( "TOPLEFT" , 0 , - 5 );
                scrollHeight = scrollHeight + BanButtons:GetHeight() + BanReasonText:GetHeight();
            else
                BanButtons:SetPoint( "TOPLEFT" , GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[count - 1][5] , "BOTTOMLEFT" , 0 , - buffer );
                scrollHeight = scrollHeight + BanButtons:GetHeight() + BanReasonText:GetHeight() + buffer;
            end
            BanButtons:Show();
        end
    end

    -- Ok, let's add a count to how many banned
    if count > 0 then
        GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText:SetText( "(Total Banned: " .. count .. ")" );
        GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText:Show();
        GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:Show();
        GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:Hide();
    else
        GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText:Hide();
        GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:Hide();
        GRM_UI.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:Show();
    end

    -- Hides all the additional buttons... if necessary ( necessary because once initialized, the buttons are there. This avoids bloated code and too much purging and rebuilding and purging. Just hide for future use.
    for i = count + 1 , #GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons do
        GRM_UI.GRM_CoreBanListScrollChildFrame.allFrameButtons[i][1]:Hide();
    end 
    
    -- Update the size -- it either grows or it shrinks!
    GRM_UI.GRM_CoreBanListScrollChildFrame:SetSize ( scrollWidth , scrollHeight );

    --Set Slider Parameters ( has to be done after the above details are placed )
    local scrollMax = ( scrollHeight - 145 ) + ( buffer * .5 );
    if scrollMax < 0 then
        scrollMax = 0;
    end
    GRM_UI.GRM_CoreBanListScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
    -- Mousewheel Scrolling Logic
    GRM_UI.GRM_CoreBanListScrollFrame:EnableMouseWheel( true );
    GRM_UI.GRM_CoreBanListScrollFrame:SetScript( "OnMouseWheel" , function( self , delta )
        local current = GRM_UI.GRM_CoreBanListScrollFrameSlider:GetValue();
        
        if IsShiftKeyDown() and delta > 0 then
            GRM_UI.GRM_CoreBanListScrollFrameSlider:SetValue ( 0 );
        elseif IsShiftKeyDown() and delta < 0 then
            GRM_UI.GRM_CoreBanListScrollFrameSlider:SetValue ( scrollMax );
        elseif delta < 0 and current < scrollMax then
            GRM_UI.GRM_CoreBanListScrollFrameSlider:SetValue ( current + 20 );
        elseif delta > 0 and current > 1 then
            GRM_UI.GRM_CoreBanListScrollFrameSlider:SetValue ( current - 20 );
        end
    end);


end


--- FINALLY!!!!!
--- TOOLTIPS ---
----------------

-- Method:          GRM.MemberDetailToolTips ( self , float )
-- What it Does:    Populates the tooltips on the "OnUpdate" check for the core Member Detail frame
-- Purpose:         UI Feature
GRM.MemberDetailToolTips = function ( self , elapsed )
    GRM_AddonGlobals.timer2 = GRM_AddonGlobals.timer2 + elapsed;
    if GRM_AddonGlobals.timer2 >= 0.075 then
        local name = GRM_AddonGlobals.currentName;

        -- Rank Text
        -- Only populate and show tooltip if mouse is over text frame and it is not already visible.
        if GRM_MemberDetailRankToolTip:IsVisible() ~= true and not StaticPopup1:IsVisible() and not DropDownList1:IsVisible() and GRM_MemberDetailRankDateTxt:IsVisible() == true and GRM_altDropDownOptions:IsVisible() ~= true and GRM_MemberDetailRankDateTxt:IsMouseOver(1,-1,-1,1) == true then
            
            GRM_MemberDetailRankToolTip:SetOwner( GRM_MemberDetailRankDateTxt , "ANCHOR_BOTTOMRIGHT" );
            GRM_MemberDetailRankToolTip:AddLine( "|cFFFFFFFFRank History");

            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then   --- Player Found in MetaData Logs
                    -- Now, let's build the tooltip
                    for k = #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] , 1 , -1 do
                        if k == #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] then
                            local timeAtRank = GRM.GetTimePassedUsingStringStamp ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][12] );
                            GRM_MemberDetailRankToolTip:AddDoubleLine ( "|cFFFF0000Time at Rank: " , timeAtRank[4] );
                            GRM_MemberDetailRankToolTip:AddDoubleLine ( " " , " " );
                        end
                        GRM_MemberDetailRankToolTip:AddDoubleLine( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25][k][1] .. ":" , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25][k][2] , 0.38 , 0.67 , 1.0 );
                    end
                    break;
                end
            end

            GRM_MemberDetailRankToolTip:Show();
        elseif GRM_MemberDetailRankToolTip:IsVisible() == true and GRM_MemberDetailRankDateTxt:IsMouseOver(1,-1,-1,1) ~= true then
            GRM_MemberDetailRankToolTip:Hide();
            GRM_MemberDetailServerNameToolTip:Hide();
        end

        -- JOIN DATE TEXT
        if GRM_MemberDetailJoinDateToolTip:IsVisible() ~= true and not StaticPopup1:IsVisible() and GRM_JoinDateText:IsVisible() == true and GRM_altDropDownOptions:IsVisible() ~= true and GRM_JoinDateText:IsMouseOver(1,-1,-1,1) == true then
           
            GRM_MemberDetailJoinDateToolTip:SetOwner( GRM_JoinDateText , "ANCHOR_BOTTOMRIGHT" );
            GRM_MemberDetailJoinDateToolTip:AddLine( "|cFFFFFFFFMembership History");
            local joinedHeader;

            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then   --- Player Found in MetaData Logs
                    -- Ok, let's build the tooltip now.
                    for r = #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20] , 1 , -1 do                                       -- Starting with most recent join which will be at end of array.
                        if r > 1 then
                            joinedHeader = "Rejoined: ";
                        else
                            joinedHeader = "Joined: ";
                        end
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][15][r] ~= nil then
                            GRM_MemberDetailJoinDateToolTip:AddDoubleLine( "|CFFC41F3BLeft:    " ,  GRM.Trim ( string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][15][r] , 1 , 10 ) ) , 1 , 0 , 0 );
                        end
                        GRM_MemberDetailJoinDateToolTip:AddDoubleLine( joinedHeader , GRM.Trim ( string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20][r] , 1 , 10 ) ) , 0.38 , 0.67 , 1.0 );
                        -- If player once left, then this will add the line for it.
                    end
                break;
                end
            end

            GRM_MemberDetailJoinDateToolTip:Show();
        elseif GRM_JoinDateText:IsMouseOver(1,-1,-1,1) ~= true and ( GRM_MemberDetailJoinDateToolTip:IsVisible() or GRM_MemberDetailServerNameToolTip:IsVisible() ) then
            GRM_MemberDetailJoinDateToolTip:Hide();
            GRM_MemberDetailServerNameToolTip:Hide();
        end

        -- Mouseover name shows full server... useful on merged realms.
        if not GRM_altDropDownOptions:IsVisible() and not StaticPopup1:IsVisible() and GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
            -- Get Class Color
            local textR, textG, textB = GRM_MemberDetailNameText:GetTextColor();

            -- Build the tooltip
            GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_JoinDateText , "ANCHOR_CURSOR" );
            GRM_MemberDetailServerNameToolTip:AddLine ( name , textR , textG , textB );

            GRM_MemberDetailServerNameToolTip:Show();
        else
            GRM_MemberDetailServerNameToolTip:Hide();
        end

        -- Mouseover on Alt Names
        if GRM_AltName1:IsVisible() or ( GRM_AltAdded1 ~= nil and GRM_AltAdded1:IsVisible() ) and not StaticPopup1:IsVisible() and not GRM_altDropDownOptions:IsVisible() then
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then   --- Player Found in MetaData Logs
                    local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];

                        -- for regular frames
                        if #listOfAlts <= 12 then
                            local numAlt = 0;
                            if GRM_AltName1:IsVisible() and GRM_AltName1:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 1;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName1 , "ANCHOR_CURSOR" );
                            elseif GRM_AltName2:IsVisible() and GRM_AltName2:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 2;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName2 , "ANCHOR_CURSOR" );
                            elseif GRM_AltName3:IsVisible() and GRM_AltName3:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 3;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName3 , "ANCHOR_CURSOR" );
                            elseif GRM_AltName4:IsVisible() and GRM_AltName4:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 4;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName4 , "ANCHOR_CURSOR" );
                            elseif GRM_AltName5:IsVisible() and GRM_AltName5:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 5;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName5 , "ANCHOR_CURSOR" );
                            elseif GRM_AltName6:IsVisible() and GRM_AltName6:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 6;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName6 , "ANCHOR_CURSOR" );
                            elseif GRM_AltName7:IsVisible() and GRM_AltName7:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 7;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName7 , "ANCHOR_CURSOR" );
                            elseif GRM_AltName8:IsVisible() and GRM_AltName8:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 8;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName8 , "ANCHOR_CURSOR" );
                            elseif GRM_AltName9:IsVisible() and GRM_AltName9:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 9;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName9 , "ANCHOR_CURSOR" );
                            elseif GRM_AltName10:IsVisible() and GRM_AltName10:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 10;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName10 , "ANCHOR_CURSOR" );
                            elseif GRM_AltName11:IsVisible() and GRM_AltName11:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 11;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName11 , "ANCHOR_CURSOR" );
                            elseif GRM_AltName12:IsVisible() and GRM_AltName12:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 12;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_AltName12 , "ANCHOR_CURSOR" );
                            end

                            if numAlt > 0 then
                                GRM_AddonGlobals.tempAltName = listOfAlts[numAlt][1];
                                GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[numAlt][1] , listOfAlts[numAlt][2] , listOfAlts[numAlt][3] , listOfAlts[numAlt][4] );
                                GRM_MemberDetailServerNameToolTip:Show();
                            elseif not GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                GRM_MemberDetailServerNameToolTip:Hide();
                            end

                        else
                            local isOver = false;
                            for i = 1 , #GRM_CoreAltScrollChildFrame.allFrameButtons do
                                if GRM_CoreAltScrollChildFrame.allFrameButtons[i][1]:IsVisible() and GRM_CoreAltScrollChildFrame.allFrameButtons[i][1]:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    GRM_AddonGlobals.tempAltName = listOfAlts[i][1];
                                    GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_CoreAltScrollChildFrame.allFrameButtons[i][1] , "ANCHOR_CURSOR" );
                                    GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[i][1] , listOfAlts[i][2] , listOfAlts[i][3] , listOfAlts[i][4] );
                                    isOver = true;
                                    break;
                                end
                            end

                            if isOver and not GRM_altDropDownOptions:IsVisible() then
                                GRM_MemberDetailServerNameToolTip:Show();
                            elseif GRM_altDropDownOptions:IsVisible() and not GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                GRM_MemberDetailServerNameToolTip:Hide();
                            end
                        end

                    break;
                end
            end
        elseif not GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
            GRM_MemberDetailServerNameToolTip:Hide();
        end

        -- Player status notification to let people know they can edit it.
        if GRM_MemberDetailPlayerStatus:IsMouseOver ( 1 , -1 , -1 , 1 ) and not GRM_altDropDownOptions:IsVisible() then
            GRM_MemberDetailNotifyStatusChangeTooltip:SetOwner ( GRM_MemberDetailPlayerStatus , "ANCHOR_CURSOR" );
            GRM_MemberDetailNotifyStatusChangeTooltip:AddLine ( "|cFFFFFFFFRight-Click to Notify of Status Change");

            GRM_MemberDetailNotifyStatusChangeTooltip:Show();
        else
            GRM_MemberDetailNotifyStatusChangeTooltip:Hide();
        end

        GRM_AddonGlobals.timer2 = 0;
    end
end


----------------------
--- FRAME VALUES -----
--- AND PARAMETERS ---
----------------------

GRM.BackupFade = function()
    GRM_RosterChangeLogScrollFrame:SetAlpha ( GRM_RosterChangeLogScrollFrame:GetAlpha() - 0.01 );
    GRM_RosterChangeLogScrollBorderFrame:SetAlpha ( GRM_RosterChangeLogScrollBorderFrame:GetAlpha() - 0.01 );
    GRM_UI.GRM_RosterLoadOnLogonCheckButton:SetAlpha ( GRM_UI.GRM_RosterLoadOnLogonCheckButton:GetAlpha() + 0.025);
    if GRM_RosterChangeLogScrollFrame:GetAlpha() > 0 then           -- Hide the scroll frame fully one opening.
        C_Timer.After ( 0.025 , GRM.BackupFade );
    else
        GRM_UI.GRM_RosterLoadOnLogonCheckButton:SetAlpha ( 1 );
    end
end

-- Method:          GRM.LogOptionsFadeIn()
-- What it Does:    Fades in the Options frame and buttons on the guildRoster Log window
-- Purpose:         Really, just aesthetics for User Experience.
GRM.LogOptionsFadeIn = function()

    GRM_RosterChangeLogScrollFrame:SetAlpha ( GRM_RosterChangeLogScrollFrame:GetAlpha() - 0.01 );
    GRM_RosterChangeLogScrollBorderFrame:SetAlpha ( GRM_RosterChangeLogScrollBorderFrame:GetAlpha() - 0.01 );
    GRM_UI.GRM_RosterLoadOnLogonCheckButton:SetAlpha ( GRM_UI.GRM_RosterLoadOnLogonCheckButton:GetAlpha() + 0.025);

    if GRM_RosterChangeLogScrollFrame:GetAlpha() > 0 then           -- Hide the scroll frame fully one opening.
        GRM.BackupFade();
    end
end

-- Method:          GRM.LogOptionsFadeOut()
-- What it Does:    Fades OUT the Options frame and buttons on the guildRoster Log window
-- Purpose:         Really, just aesthetics for User Experience.
GRM.LogOptionsFadeOut = function()
    
    GRM_RosterChangeLogScrollFrame:SetAlpha ( GRM_RosterChangeLogScrollFrame:GetAlpha() + 0.025 );
    GRM_RosterChangeLogScrollBorderFrame:SetAlpha ( GRM_RosterChangeLogScrollBorderFrame:GetAlpha() + 0.025 );
    GRM_UI.GRM_RosterLoadOnLogonCheckButton:SetAlpha ( GRM_UI.GRM_RosterLoadOnLogonCheckButton:GetAlpha() - 0.025);

    if GRM_RosterChangeLogScrollFrame:GetAlpha() < 1 then
        C_Timer.After ( 0.01 , GRM.LogOptionsFadeOut );
    elseif GRM_RosterChangeLogScrollFrame:GetAlpha() >= 1 then           -- Hide the scroll frame fully one opening.
        GRM_RosterChangeLogScrollFrame:SetAlpha ( 1 );
        GRM_RosterChangeLogScrollBorderFrame:SetAlpha ( 1 );
        GRM_UI.GRM_RosterLoadOnLogonCheckButton:SetAlpha ( 0 );
    end
end

-- Method:          GRM.LogFrameTransformationOpen()
-- What it Does:    Transforms the frame to be larger, revealing the "options" details
-- Purpose:         Really, just aesthetics for User Experience, but also for a concise framework.
GRM.LogFrameTransformationOpen = function ()
    GRM_RosterChangeLogFrame:SetSize ( 600 , GRM_RosterChangeLogFrame:GetHeight() + 5.0  );          -- reset size, slightly increment it up!
    -- Determine if I need to loop through again.
    local fading = false;
    local height = 562;

    if math.floor ( GRM_RosterChangeLogFrame:GetHeight() ) < height then   
        if not fading and math.floor ( GRM_RosterChangeLogFrame:GetHeight() ) > 460 then        -- Trigger fade transition into already moving tile.
            GRM.LogOptionsFadeIn();
            fading = true;
        end
         C_Timer.After ( 0.01 , GRM.LogFrameTransformationOpen );
    else        -- Exit from Recursive Loop for transformation.
        GRM_RosterOptionsButton:Enable();
    end
end

-- Method:          GRM.LogFrameTransformationClose()
-- What it Does:    Transforms the frame back to normal side, hiding the "options" details
-- Purpose:         Really, just aesthetics for User Experience, but also for a concise framework.
GRM.LogFrameTransformationClose = function ()
    GRM_RosterChangeLogFrame:SetSize ( 600 , GRM_RosterChangeLogFrame:GetHeight() - 5.0 );          -- reset size, slightly increment it up!
    -- Determine if I need to loop through again.
    if math.floor ( GRM_RosterChangeLogFrame:GetHeight() ) > 440 then
         C_Timer.After ( 0.01 , GRM.LogFrameTransformationClose );
    else        -- Exit from Recursive Loop for transformation.
        GRM_UI.GRM_RosterLoadOnLogonCheckButton:Hide();
        GRM_RosterOptionsButton:Enable();
    end
end

-- Method:          GRM.LogFrameTransformationCloseMinor()
-- What it Does:    Transforms the frame back to hide 1 layer of options
-- Purpose:         Really, just aesthetics for User Experience, but also for a concise framework.
GRM.LogFrameTransformationCloseMinor = function ()
    GRM_RosterChangeLogFrame:SetSize ( 600 , GRM_RosterChangeLogFrame:GetHeight() - 5.0 );          -- reset size, slightly increment it up!
    -- Determine if I need to loop through again.
    if math.floor ( GRM_RosterChangeLogFrame:GetHeight() ) > 544 then
         C_Timer.After ( 0.01 , GRM.LogFrameTransformationCloseMinor );
    end
end

-- Method:          GRM.UpdateGuildMemberInRaidStatus()
-- What it Does:    Updates the text frame on number of guild members in a current raid group
-- Purpose:         Update, on the fly, every 3 seconds, number of guildies present.
GRM.UpdateGuildMemberInRaidStatus = function ()
    -- Only trigger once per 3 seconds.
    if IsInGroup() and RaidFrame:IsVisible() and not RaidFrameNotInRaid:IsVisible() then
        local numGuildies = GRM.GetNumGuildiesInGroup();
        if numGuildies > 0 then
            UI_Events.GRM_NumGuildiesText:SetText ( "Guildies: " .. numGuildies );
            UI_Events.GRM_NumGuildiesText:Show();
        else
            UI_Events.GRM_NumGuildiesText:Hide();
        end
        C_Timer.After ( 1 , GRM.UpdateGuildMemberInRaidStatus );              -- Check for updates recursively
    elseif IsInGroup() then
        UI_Events.GRM_NumGuildiesText:Hide();
        C_Timer.After ( 1 , GRM.UpdateGuildMemberInRaidStatus );
    else
        UI_Events.GRM_NumGuildiesText:Hide();
        GRM_AddonGlobals.RaidGCountBeingChecked = false;
    end
end

-- Method:          GRM.ReportGuildJoinApplicants()
-- What it Does:    Returns true if there is a current request to join the guild
-- Purpose:         To remind anyone with guild invite privileges to review if player has requested to join
GRM.ReportGuildJoinApplicants = function()
    if CanGuildInvite() then                    -- No point in checking this if you don't have invite privileges and you can't see the application!
        local numApps = GetNumGuildApplicants();
        if numApps > 0 and numApps > GRM_AddonGlobals.numPlayersRequestingGuildInv then
            GRM_AddonGlobals.numPlayersRequestingGuildInv = numApps;            
            chat:AddMessage ( "\n--------------------------------\n--------     GRM     ----------\n--- Guild Invite Request ---\n--------------------------------\n" , 1 , 1 , 1 , 1 );
            for i = 1 , numApps do
                local recruit , level , className , _,_,_,_,_,_,_,_,_,_, comment = GetGuildApplicantInfo ( i );
                if comment == nil or comment == "" then
                    comment = "<None Given>";
                end
                chat:AddMessage ( "Name:   " .. recruit , 0 , 0.77 , 0.95 , 1 );
                chat:AddMessage ( "Level:    " .. level , 0 , 0.77 , 0.95 , 1 );
                chat:AddMessage ( "Class:    " .. className , 0 , 0.77 , 0.95 , 1 );
                chat:AddMessage ( "Reason: " .. comment , 0 , 0.77 , 0.95 , 1 );
                print("\n");
            end
        end
    end
end




-- Method:              GRM.GR_Roster_Click ( self, string )
-- What it Does:        For logic on mouseover, instead of mouseover, it simulates a click on the item by bringing it to show.
--                      The "pause" is just a call to pause the hiding of the frame in the GR_RosterFrame() function until it finds a new window (to prevent wasteful clicking and resource hogging)
-- Purpose:             Smoother UI interface in the built-in Guild Roster in-game UI default window.
GRM.GR_Roster_Click = function ( name )

    local time = GetTime();
    local length = 84;
    if GRM_AddonGlobals.timer3 == 0 or time - GRM_AddonGlobals.timer3 > 0.05 then   -- 100ms
        -- We are going to be copying the name if the shift key is down!

        if IsShiftKeyDown() and GetCurrentKeyBoardFocus() ~= nil and not GRM_AddonGlobals.RecursiveStop then

            if GetCurrentKeyBoardFocus():GetName() ~= nil then
                if "GRM_AddAltEditBox" == GetCurrentKeyBoardFocus():GetName() then
                    GetCurrentKeyBoardFocus():SetText ( name );
                else
                    GetCurrentKeyBoardFocus():Insert ( GRM.SlimName ( name ) ); -- Adds it at the cursor position...
                end
            end

            GRM_AddonGlobals.RecursiveStop = true;

            if GetCurrentKeyBoardFocus() == nil then
                local errorMessagesGRM = { "Add-Alt Interface Trouble Loading... Try again!" , "Interface error, try shift-clicking Again Please!" , "Huh? Odd interface error... Try again!" , "Ya... Interface error on shift-click. No biggie, try again!" , "Interface might be loading data on back end... try again on shift-click!" };
                print ( errorMessagesGRM [ math.random ( #errorMessagesGRM ) ] );
            else
                if GetCurrentKeyBoardFocus():GetName() ~= nil and GetCurrentKeyBoardFocus():GetName() == "GRM_AddAltEditBox" then
                    GRM.AddAltAutoComplete();
                    GRM_AddonGlobals.pause = true
                end
            end
        end
        GRM_AddonGlobals.timer3 = time;
    end
    GRM_AddonGlobals.RecursiveStop = false;
end

-- Method:          GRM.TriggerTrackingCheck()
-- What it Does:    Helps regulate some resource and timed efficient server queries, 
-- Purpose:         to keep from spamming or double+ looping functions.
GRM.TriggerTrackingCheck = function()
    GRM_AddonGlobals.trackingTriggered = false;
    GuildRoster();
    QueryGuildEventLog();
end

---------------------------------------------
-------- SLASH COMMAND FUNCTIONS ------------
---------------------------------------------

-- Method:          GRM.SlashCommandScan()
-- What it Does:    Triggers a one-time scan of the guild for changes.
-- Purpose:         Mainly useful for people that wish to disable active scanning and just do a 1-time check on occasion.
GRM.SlashCommandScan = function()
    chat:AddMessage ( "GRM: Scanning for Guild Changes Now. One Moment..." , 1.0 , 0.84 , 0 );
    GRM_AddonGlobals.ManualScanEnabled = true;
    GuildRoster();
    C_Timer.After ( 5 , GRM.TriggerTrackingCheck );
end

-- Method:          GRM.SyncCommandScan()
-- What it Does:    Activates a one-time data sync with guildies
-- Purpose:         For people that want to sync data, but don't want it to be on all the time, just on occasion as they choose.
--                  Flexibility to the user!
GRM.SyncCommandScan = function()
    if GRM_AddonGlobals.HasAccessToGuildChat then
        -- Enable Temporary Syncing...
        if not GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] = true;
            GRM_AddonGlobals.TemporarySync = true;
            GRM_RosterSyncCheckButton:SetChecked ( true );
        end
        
        if GRMsyncGlobals.currentlySyncing then
            if GRMsyncGlobals.IsElectedLeader then
                print ( "Breaking current Sync with " .. GRM.SlimName ( GRMsyncGlobals.CurrentSyncPlayer ) .. "." );
            else
                print ( "Breaking current Sync with " .. GRM.SlimName ( GRMsyncGlobals.DesignatedLeader ) .. "." );
            end
        end
        chat:AddMessage ( "Initializing Sync Action. One Moment..." , 1.0 , 0.84 , 0 );
        GRMsync.TriggerFullReset();
        -- Now, let's add a brief delay, 3 seconds, to trigger sync again
        C_Timer.After ( 1 , function()
            GRMsync.Initialize();
            if #GRM_AddonGlobals.currentAddonUsers == 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                chat:AddMessage ( "GRM: No Players Currently Online to Sync With... "  , 1.0 , 0.84 , 0 );
            end
        end);
    else
        print ( "SYNC is currently not possible! Unable to Sync with guildies when guild chat is restricted.")
    end
end

-- Method:          GRM.SlashCommandCenter()
-- What it Does:    It Centers all of the windows, in case the player dragged them off the screen
-- Purpose:         Help keep frames organized. Just a necessary feature as someone is eventually going to say they tossed the frame off screen.
GRM.SlashCommandCenter = function()
    GRM_RosterChangeLogFrame:ClearAllPoints();
    GRM_RosterChangeLogFrame:SetPoint ( "CENTER" , UIParent );
    GRM_AddEventFrame:ClearAllPoints();
    GRM_AddEventFrame:SetPoint ( "CENTER" , UIParent );
    GRM_UI.GRM_AddonUsersCoreFrame:ClearAllPoints();
    GRM_UI.GRM_AddonUsersCoreFrame:SetPoint ( "CENTER" , UIParent );
    GRM_UI.GRM_CoreBanListFrame:ClearAllPoints();
    GRM_UI.GRM_CoreBanListFrame:SetPoint ( "CENTER" , UIParent );
    GRM_UI.GRM_AddBanFrame:ClearAllPoints();
    GRM_UI.GRM_AddBanFrame:SetPoint ( "CENTER" , UIPanel );
end

-- Method:          GRM.SlashCommandHelp()
-- What it Does:    Displays a list of all slash commands and what they do
-- Purpose:         To HELP the player with slash commands lol
GRM.SlashCommandHelp = function()
    print ( "\nGuild Roster Manager\nVer: " .. GRM_AddonGlobals.Version .. "\n\n/roster                     - Opens Guild Log Window\n/roster clearall          - Resets ALL saved data\n/roster reset            - Re-centers the Log window\n/roster sync             - Triggers manual re-sync if sync is enabled\n/roster scan             - Does a one-time manual scan for changes\n/roster ver               - Displays current Addon version\n/roster syncinfo:       - Sync info on all guildies using addon" );
end

-- Method:          GRM.SlashCommandClearAll()
-- What it Does:    
-- Purpose:         
GRM.SlashCommandClearAll = function()
    GRM_RosterChangeLogFrame:EnableMouse( false );
    GRM_RosterChangeLogFrame:SetMovable( false );
    GRM_RosterConfirmFrameText:SetText( "Really Clear ALL Saved Data?" );
    GRM_RosterConfirmYesButtonText:SetText ( "Yes!" );
    GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            GRM.ResetAllSavedData();      --Resetting!
            GRM_RosterConfirmFrame:Hide();
        end
    end);
    GRM_RosterConfirmFrame:Show();
end

-- Method:          GRM.SlashCommandVersion()
-- What it Does:    Displays the version of the addon (all viewable with /roster help)
-- Purpose:         General info if wanted.
GRM.SlashCommandVersion = function()
    print ( "\nGuild Roster Manager\nVer: " .. GRM_AddonGlobals.Version .. "\n" );
end

-- Method:          GRM.SlashCommandSyncInfo()
-- What it Does:    It displays the window showing all guildies with addon installed.
-- Purpose:         Useful info to addon user as window displays helpful info on why or why not you are sync ready with them.
GRM.SlashCommandSyncInfo = function()
    if GRM_UI.GRM_AddonUsersCoreFrame:IsVisible() then
        GRM_UI.GRM_AddonUsersCoreFrame:Hide();
    else
        GRM_UI.GRM_AddonUsersCoreFrame:Show();
    end
end

-- SLASH COMMAND LOGIC
SlashCmdList["GRM"] = function ( input )
    -- if input is invalid or is just a blank info... print details on addon.
    local command;
    local alreadyReported = false;
    local inGuild = IsInGuild();
    if input ~= nil and string.lower ( input ) ~= nil then
        command = string.lower ( input );
    end

    if input == nil or input:trim() == "" then
        if IsInGuild() and GRM_RosterChangeLogFrame ~= nil and not GRM_RosterChangeLogFrame:IsVisible() then
            GRM_RosterChangeLogFrame:Show();
        elseif GRM_RosterChangeLogFrame ~= nil and GRM_RosterChangeLogFrame:IsVisible() then
            GRM_RosterChangeLogFrame:Hide();
        elseif GRM_RosterChangeLogFrame == nil then
            print ( "Please try again momentarily... Updating the Guild Event Log as we speak!" );
        end
    -- Clears all saved data and resets to as if the addon was just installed. The only thing not reset is the default settings.
    elseif command == "clearall" then
        alreadyReported = true;
        GRM.SlashCommandClearAll();
   
    -- List of all the slash commands at player's disposal.
    elseif command == "help" then
        alreadyReported = true;
        GRM.SlashCommandHelp();

    -- Version
    elseif command == "version" or command == "ver" then
        alreadyReported = true;
        GRM.SlashCommandVersion();

    -- Resets the poisition of the window back to the center.
    elseif command == "reset" or command == "center" then
        alreadyReported = true;
        GRM.SlashCommandCenter();
    
    -- Re-triggering SYNC
    elseif command == "sync" then
        if inGuild then
            GRM.SyncCommandScan()
        end

    -- For manual scan trigger!
    elseif command == "scan" then
        if inGuild then
            GRM.SlashCommandScan();
        end

    -- For Opening the Player Sync Info window
    elseif command == "syncinfo" then
        if inGuild then
            GRM.SlashCommandSyncInfo();
        end

    -- FOR FUN!!!
    elseif command == "hail" then
        alreadyReported = true;
        print ( "SUBATOMIC PVP IS THE BEST GUILD OF ALL TIME!\nArkaan is SEXY! Mmmm Arkaan! Super, ridiculously hot addon dev!" );
    -- Invalid slash command.
    else
        alreadyReported = true;
        print ( "Invalid Command: Please type '/roster help' for More Info!" );
    end
    
    if not inGuild and not alreadyReported then
        print ( GRM.SlimName( GRM_AddonGlobals.addonPlayerName ) .. " is not currently in a guild. Unable to Proceed!" );
    end
end


-- Method:              GRM.InitiateMemberDetailFrame(self,event,msg)
-- What it Does:        Event Listener, it activates when the Guild Roster window is opened and interface is queried/triggered
--                      "GuildRoster()" needs to fire for this to activate as it creates the following 4 listeners this is looking for: GUILD_NEWS_UPDATE, GUILD_RANKS_UPDATE, GUILD_ROSTER_UPDATE, and GUILD_TRADESKILL_UPDATE
-- Purpose:             Create an Event Listener for the Guild Roster Frame in the guild window ('J' key)
GRM.InitiateMemberDetailFrame = function ()
    if not GRM_AddonGlobals.FramesInitialized and GuildFrame ~= nil then
        -- Member Detail Frame Info
        GRM_UI.GR_MetaDataInitializeUIFirst(); -- Initializing Frames
        GRM_UI.GR_MetaDataInitializeUISecond(); -- To avoid 60 upvalue Lua cap, place them in second list.
        GRM_UI.GR_MetaDataInitializeUIThird(); -- Also, to avoid another 60 upvalues!
        if not GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][2] then
            GRM_UI.MetaDataInitializeUIrosterLog1();   -- 60 more upvalues :D
            GRM_UI.MetaDataInitializeUIrosterLog2();   -- Wrapping up!
        end

        -- For determining mouseover on the frames.
        local GRM_CoreUpdateFrame = GRM_CoreUpdateFrame or CreateFrame ( "frame" );
        GRM_CoreUpdateFrame:SetScript ( "OnUpdate" , function ( self , elapsed )
            GRM_AddonGlobals.timer = GRM_AddonGlobals.timer + elapsed;
            if GuildRosterFrame:IsVisible() and GRM_AddonGlobals.timer >= 0.038 then
                GR_RosterFrame();
                GRM_AddonGlobals.timer = 0;
            end
        end);
        
        -- One time button placement ( rest will be determined on the OnUpdate for Roster Frame )
        GuildRosterFrame:HookScript ( "OnShow" , function( self )
            GRM_LoadLogButton:Show();
            GRM_AddonUsersButton:Show();
            GRM_UI.GRM_BanListButton:Show();
        end);

        -- Exit loop
        UI_Events:UnregisterEvent ( "GUILD_ROSTER_UPDATE" );
        UI_Events:UnregisterEvent ( "GUILD_RANKS_UPDATE" );
        UI_Events:UnregisterEvent ( "GUILD_NEWS_UPDATE" );
        UI_Events:UnregisterEvent ( "GUILD_TRADESKILL_UPDATE" );
        UI_Events:UnregisterEvent ( "UPDATE_INSTANCE_INFO" );
        GRM_AddonGlobals.FramesInitialized = true;
    end
end



------------------------------------------------
------------------------------------------------
----- INITIALIZATION AND LIVE TRACKING ---------
------------------------------------------------
------------------------------------------------


-- Method:          GRM.AllRemainingNonDelayFrameInitialization()
-- What it Does:    Initializes general important frames that are not in relations to the guild roster window.
-- Purpose:         By walling this off, it allows far greater resource control rather than needing to initialize entire UI.
GRM.AllRemainingNonDelayFrameInitialization = function()
    
    UI_Events.GRM_NumGuildiesText:SetPoint ( "TOP" , RaidFrame , 0 , -32 );
    UI_Events.GRM_NumGuildiesText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
    UI_Events.GRM_NumGuildiesText:SetTextColor ( 0.0 , 0.8 , 1.0 , 1.0 );
    UI_Events:SetFrameStrata ( "HIGH" );

    UI_Events:RegisterEvent ( "UPDATE_INSTANCE_INFO" );
    UI_Events:RegisterEvent ( "GROUP_ROSTER_UPDATE" );

    -- For live guild bank queries...
    GuildBankInfoTracking:RegisterEvent ( "GUILDBANKLOG_UPDATE" );
    GuildBankInfoTracking:RegisterEvent ( "GUILDBANKFRAME_OPENED" );
    GuildBankInfoTracking:SetScript ( "OnEvent" , function( self , event )
        if event == "GUILDBANKFRAME_OPENED" then
            GRM.SpeedQueryBankInfoTracking();
        elseif event == "GUILDBANKLOG_UPDATE" then
            -- print ( "Results Received From Bank!" );
            -- Function to be added for bank handling here.
        end
    end);

    -- UI_Events:RegisterEvent ( "UPDATE_INSTANCE_INFO" );
    UI_Events:HookScript ( "OnEvent" , function( self , event )
        if ( event == "UPDATE_INSTANCE_INFO" or event == "GROUP_ROSTER_UPDATE" ) and not GRM_AddonGlobals.RaidGCountBeingChecked then
            GRM_AddonGlobals.RaidGCountBeingChecked = true;
            GRM.UpdateGuildMemberInRaidStatus();
        end
    end);

    RaidFrame:HookScript ( "OnHide" , function()
        UI_Events.GRM_NumGuildiesText:Hide();
    end);
end

-- Method:          GRM.CheckIfNeedToAddAlt()
-- What it Does:    Lets you know if the player is already on the list of alts, and returns the position of the guild in the table as well.
-- Purpose:         For alt auto-tagging for the addon.
GRM.CheckIfNeedToAddAlt = function()
    local result = true;
    local guildIndex = -1;
    for i = 2 , #GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ] do
        if GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ][i][1] == GRM_AddonGlobals.guildName then
            guildIndex = i;
            for j = 2 , #GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ][i] do
                if GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ][i][j][1] == GRM_AddonGlobals.addonPlayerName then
                    result = false;
                    break;
                end
            end
            break;
        end
    end
    return result , guildIndex;
end


-- Method:          Tracking()
-- What it Does:    Checks the Roster once in a repeating time interval as long as player is in a guild
-- Purpose:         Constant checking for roster changes. Flexibility in timing changes. Default set to 10 now, could be 30 or 60.
--                  Keeping local
local function Tracking()
    if IsInGuild() and not GRM_AddonGlobals.trackingTriggered then
        GRM_AddonGlobals.trackingTriggered = true;
        local timeCallJustOnce = time();
        if GRM_AddonGlobals.timeDelayValue == 0 or (timeCallJustOnce - GRM_AddonGlobals.timeDelayValue ) > 5 then -- Initial scan is zero.
            GRM_AddonGlobals.currentlyTracking = true;
            GRM_AddonGlobals.guildName = GetGuildInfo ( "PLAYER" );
            GRM_AddonGlobals.timeDelayValue = timeCallJustOnce;

            -- Need to doublecheck Faction Index ID
            if GRM_AddonGlobals.faction == 0 then
                if GRM_AddonGlobals.faction == "Horde" then
                    GRM_AddonGlobals.FID = 1;
                elseif GRM_AddonGlobals.faction == "Alliance" then
                    GRM_AddonGlobals.FID = 2;
                end
            end

            -- Need to doublecheck guild Index ID
            if GRM_AddonGlobals.logGID == 0 then
                for i = 2 , #GRM_LogReport_Save[GRM_AddonGlobals.FID] do
                    if GRM_LogReport_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.guildName then
                        GRM_AddonGlobals.logGID = i;
                        break;
                    end
                end
            end

            -- Need to do the same for save index ID
            if GRM_AddonGlobals.saveGID == 0 then
                for i = 2 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID] do
                    if GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.guildName then
                        GRM_AddonGlobals.saveGID = i;
                        break;
                    end
                end
            end

            -- for Settings
            if GRM_AddonGlobals.setPID == 0 then
                for i = 2 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] do
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.addonPlayerName then
                        GRM_AddonGlobals.setPID = i;
                        break;
                    end
                end
            end

            -- If Scanning is Enabled!!!
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][18] or GRM_AddonGlobals.ManualScanEnabled then
                -- Checking Roster, tracking changes
                GRM.BuildNewRoster();

                -- Need to check if guild was established!
                local guildNotFound = true;
                for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ] do
                    if GRM_AddonGlobals.guildName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ i ][1] then
                        guildNotFound = false;
                        break;
                    end
                end

                if not guildNotFound then
                    -- if GRM_AddonGlobals.logGID ~= 0 and GRM_AddonGlobals.saveGID ~= 0 and 
                    -- Seeing if any upcoming notable events, like anniversaries/birthdays
                    GRM.CheckPlayerEvents( GRM_AddonGlobals.guildName );
                    -- Printing Report, and sending report to log.
                    GRM.FinalReport();
                end
                -- Disable manual scan if activated.
                if GRM_AddonGlobals.ManualScanEnabled then
                    GRM_AddonGlobals.ManualScanEnabled = false;
                    chat:AddMessage ( "GRM: Manual Scan Complete"  , 1.0 , 0.84 , 0 );
                end
            end

            -- Do a quick check on if players requesting to join the guild as well!
            GRM.ReportGuildJoinApplicants();
            -- Prevent from re-scanning changes
            -- On first load, bring up window.
            if GRM_AddonGlobals.OnFirstLoad then
                -- Then, initialize the frames.
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][2] then
                    GRM_UI.MetaDataInitializeUIrosterLog1();
                    GRM_UI.MetaDataInitializeUIrosterLog2();
                    GRM_RosterChangeLogFrame:Show();
                end
                
                -- Determine if player has access to guild chat or is in restricted chat rank
                GRM.RegisterGuildChatPermission();
               
                -- Let's quickly refresh the AddEventToCalendar Que, in case others have already added events to the calendar! Only need to check once as once online it live-syncs with other players after first retroactive sync.
                GRM.CalendarQueCheck();

                -- Determine if player is already listed as alt...
                local needsToAdd , guildIndex = GRM.CheckIfNeedToAddAlt();
                if needsToAdd and guildIndex ~= -1 then
                    GRM.AddPlayerToOwnAltList( guildIndex );
                end

                -- Establish Message Sharing as well!
                GRMsyncGlobals.SyncOK = true;
                
                C_Timer.After ( 10 , GRMsync.Initialize ); -- It needs to be minimum 10 seconds as it might take that long to process all changes and add player to database.

                GRM_AddonGlobals.OnFirstLoad = false;
                -- MISC frames to be loaded immediately, not on delay
                GRM.AllRemainingNonDelayFrameInitialization();
            end
        end
        GRM_AddonGlobals.currentlyTracking = false;
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][18] then
            GuildRoster();
            C_Timer.After( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][6] , GRM.TriggerTrackingCheck ); -- Recursive check every X seconds.
        end
    else
        GRM_AddonGlobals.currentlyTracking = false;
    end
end

-- Method:          GRM.GR_LoadAddon()
-- What it Does:    Enables tracking of when a player joins the guild or leaves the guild. Also fires upon login.
-- Purpose:         Manage tracking guild info. No need if player is not in guild, or to reactivate when player joins guild.
GRM.GR_LoadAddon = function()
    GeneralEventTracking:RegisterEvent ( "PLAYER_GUILD_UPDATE" ); -- If player leaves or joins a guild, this should fire.
    GeneralEventTracking:SetScript ( "OnEvent" , GRM.ManageGuildStatus );

    KickAndRankChecking:RegisterEvent ( "CHAT_MSG_SYSTEM" );
    KickAndRankChecking:SetScript ( "OnEvent" , GRM.KickPromoteOrJoinPlayer );

    -- Quick Version Check
    if not GRM_AddonGlobals.VersionCheckRegistered then
        GRM.RegisterVersionCheck();
        SendAddonMessage ( "GRMVER" , GRM_AddonGlobals.Version.. "?" .. tostring ( GRM_AddonGlobals.PatchDay ) , "GUILD" );
        GRM_AddonGlobals.VersionCheckRegistered = true;
    end

    -- Determine who is using the addon...
    -- 3 second dely to account for initialization of various variables. Safety cushion.
    C_Timer.After ( 3 , GRM.RegisterGuildAddonUsers );

    -- The following event registartion is purely for UI registeration and activation... General tracking does not need the UI, but guildFrame should be visible bnefore triggering
    -- Each of the following events might trigger on event update.
    UI_Events:RegisterEvent ( "GUILD_ROSTER_UPDATE" );
    UI_Events:RegisterEvent ( "GUILD_RANKS_UPDATE" );
    UI_Events:RegisterEvent ( "GUILD_NEWS_UPDATE" );
    UI_Events:RegisterEvent ( "GUILD_TRADESKILL_UPDATE" );
    UI_Events:RegisterEvent ( "GUILD_EVENT_LOG_UPDATE" );
    UI_Events:SetScript ( "OnEvent" , function ( self , event )
        if event == "GUILD_EVENT_LOG_UPDATE" then
            Tracking();
        elseif event ~= "UPDATE_INSTANCE_INFO" then
            if not GRM_AddonGlobals.FramesInitialized  then
                GRM.InitiateMemberDetailFrame();
            else
                UI_Events:UnregisterEvent ( "GUILD_ROSTER_UPDATE" );
                UI_Events:UnregisterEvent ( "GUILD_RANKS_UPDATE" );
                UI_Events:UnregisterEvent ( "GUILD_NEWS_UPDATE" );
                UI_Events:UnregisterEvent ( "GUILD_TRADESKILL_UPDATE" );
                UI_Events:UnregisterEvent ( "UPDATE_INSTANCE_INFO" );
            end
        end
    end);
    QueryGuildEventLog();
    GuildRoster();
end

-- Method:          GRM.ReactivateAddon ()
-- What it Does:    If addon no longer needs to be enabled due to player not being in a guild, or leaving a guild, this slimmer reactivation protocol
--                  is necessary because it doesn't need to re-register frames like it would on the first activation upon logging in.
-- Purpose:         Resource efficiency.
GRM.ReactivateAddon = function()
     if GRM_AddonGlobals.faction == nil then
        GRM_AddonGlobals.faction = UnitFactionGroup ( "PLAYER" );
    end

    if GRM_AddonGlobals.faction == "Horde" then
        GRM_AddonGlobals.FID = 1;
    else
        GRM_AddonGlobals.FID = 2;
    end

    -- Must get PID immediately after.
    if GRM_AddonGlobals.setPID == 0 then
        for i = 2 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] do
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.addonPlayerName then
                GRM_AddonGlobals.setPID = i;
                break;
            end
        end
    end

    for i = 2 , #GRM_LogReport_Save[GRM_AddonGlobals.FID] do
        if GRM_LogReport_Save[GRM_AddonGlobals.FID][i][1] == GetGuildInfo ( "PLAYER" ) then
            GRM_AddonGlobals.logGID = i;
            break;
        end
    end

    C_Timer.After ( 5 , GRM.RegisterGuildChatPermission );

    C_Timer.After ( 2 , GRM.GR_LoadAddon );

    -- C_Timer.After ( 10 , GRMsync.Initialize ); -- Gives it a moment to resync
    -- GRM.InitiateMemberDetailFrame();
end

-- Method           GRM.ManageGuildStatus()
-- What it Does:    If player leaves or joins the guild, it deactivates/reactivates tracking - as well as re-checks guild to see if rejoining or new guild.    
-- Purpose:         Efficiency in resource use to prevent unnecessary tracking of info if out of the guild.
GRM.ManageGuildStatus = function ( self , event )
    GeneralEventTracking:UnregisterEvent ( "PLAYER_GUILD_UPDATE" );
    if GRM_AddonGlobals.guildStatusChecked ~= true then
       GRM_AddonGlobals.timeDelayValue2 = time(); -- Prevents it from doing "IsInGuild()" too soon by resetting timer as server reaction is slow.
    end
    if GRM_AddonGlobals.timeDelayValue2 == 0 or ( time() - GRM_AddonGlobals.timeDelayValue2 ) >= 2 then -- Let's do a recheck on guild status to prevent unnecessary scanning.
        if IsInGuild() then
            if GRM_AddonGlobals.DelayedAtLeastOnce then
                GRM_AddonGlobals.guildName = GetGuildInfo ( "PLAYER" );
                if not GRM_AddonGlobals.currentlyTracking then                 
                    GRM.ReactivateAddon();
                end
            else
                GRM_AddonGlobals.DelayedAtLeastOnce = true;
                C_Timer.After ( 5 , GRM.ManageGuildStatus );
            end
        else
            -- Reset some values;
            GRMsyncGlobals.SyncOK = false;
            GRM_AddonGlobals.logGID = 0;
            GRM_AddonGlobals.saveGID = 0; 
            GRM_AddonGlobals.setPID = 0;  
            GRM_AddonGlobals.timeDelayValue = 0;
            GRM_AddonGlobals.OnFirstLoad = true;
            GRM_AddonGlobals.guildName = nil;
            GRM_AddonGlobals.trackingTriggered = false;
            GRM_AddonGlobals.DelayedAtLeastOnce = true;                     -- Keeping it true as there does not need to be a delay at this point.
            UI_Events:UnregisterEvent ( "GUILD_EVENT_LOG_UPDATE" );         -- This prevents it from doing an unnecessary tracking call if not in guild.
            if GRMsync.MessageTracking ~= nil then
                GRMsync.MessageTracking:UnregisterAllEvents();
            end
            GRMsync.ResetDefaultValuesOnSyncReEnable();                     -- Need to reset sync algorithm too!
            GRM_RosterChangeLogFrame:Hide();
        end
        GeneralEventTracking:RegisterEvent ( "PLAYER_GUILD_UPDATE" );
        GeneralEventTracking:SetScript ( "OnEvent" , GRM.ManageGuildStatus );
        GRM_AddonGlobals.guildStatusChecked = false;
    else
        GRM_AddonGlobals.guildStatusChecked = true;
        C_Timer.After ( 2 , GRM.ManageGuildStatus ); -- Recursively re-check on guild status trigger.
    end
end

-- Method:          ActivateAddon( self , string , string )
-- What it Does:    First, doesn't trigger to load until all variables of addon fully loaded.
--                  Then, it triggers to delay until player is fully in the world, in that order.
--                  Finally, it delays 5 seconds upon querying server as often initial Roster and Guild Event Log query takes a moment to return info.
-- Purpose:         To ensure the smooth handling and loading of the addon so all information is accurate before attempting to parse guild info.
GRM.ActivateAddon = function ( self , event , addon )
    if event == "ADDON_LOADED" then
    -- initiate addon once all variable are loaded.
        if addon == GRM_AddonGlobals.addonName then
            Initialization:RegisterEvent ( "PLAYER_ENTERING_WORLD" ); -- Ensures this check does not occur until after Addon is fully loaded. By registering, it acts recursively throug hthis method
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Initialize load settings! Don't need to be in a guild for this!
        -- Setting the index of the player's faction.
        if GRM_AddonGlobals.faction == nil then
            GRM_AddonGlobals.faction = UnitFactionGroup ( "PLAYER" );
        end

        if GRM_AddonGlobals.faction == "Horde" then
            GRM_AddonGlobals.FID = 1;
        else
            GRM_AddonGlobals.FID = 2;
        end

        -- Set correct faunt to use based on Locale.
        GRM_AddonGlobals.FontChoice = STANDARD_TEXT_FONT;
        if GRM_AddonGlobals.Region == "zhTW" then
            GRM_AddonGlobals.FontModifier = 2;
        elseif GRM_AddonGlobals.Region == "zhCN" then
            GRM_AddonGlobals.FontModifier = 0.5;
        end

        GRM.LoadSettings();
        
        -- Must get PID immediately after.
        if GRM_AddonGlobals.setPID == 0 then
            for i = 2 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] do
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.addonPlayerName then
                    GRM_AddonGlobals.setPID = i;
                    break;
                end
            end
        end

        -- MISC Quality of Life Settings...
        -- Addon Compatibility Detection
        -- EPGP uses officer notes and is an incredibly popular addon. This now ensures auto-adding officer notes does not occur.
        if GRM_AddonGlobals.setPID ~= 0 and IsAddOnLoaded("epgp") then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] = false;
        end

        if IsInGuild() then
            Initialization:UnregisterEvent ("PLAYER_ENTERING_WORLD");
            Initialization:UnregisterEvent ("ADDON_LOADED");     -- no need to keep scanning these after full loaded. 
            -- Setting the index of the player's guild         
            for i = 2 , #GRM_LogReport_Save[GRM_AddonGlobals.FID] do
                if GRM_LogReport_Save[GRM_AddonGlobals.FID][i][1] == GetGuildInfo ( "PLAYER" ) then
                    GRM_AddonGlobals.logGID = i;
                    break;
                end
            end
            GuildRoster();                                     -- Initial queries...
            QueryGuildEventLog();
            C_Timer.After ( 2 , GRM.GR_LoadAddon );                 -- Queries do not return info immediately, gives server a 5 second delay.
        else
            GRM.ManageGuildStatus();
        end
    end
end


-- Initialize the first frames as game is being loaded.
Initialization:RegisterEvent ( "ADDON_LOADED" );
Initialization:SetScript ( "OnEvent" , GRM.ActivateAddon );


    -------------------------------------   
    ----- FEATURES TO BE ADDED NEXT!! ---
    -------------------------------------
    -------------------------------------
    ----- POTENTIAL FEATURES ------------
    -------------------------------------

    -- Guild Officer Notepad... Communal notepad anyone can edit...

    -- Option to allow Ban list to be shared with other guildies using the addon.
    -- Sync ban list between all guilds?

    -- Groups! Create groups! Allow people to join RBG teams, Raid groups, Mythic groups, Arena teams, Custom... request info of those teams.
    -- Click on the team, it pops up all members of the team w/misc. stats of team.
    -- Options to invite all of that team into a group...

    -- Request to join a group: List all guild groups available in a display window... scrollable. Description of each group
    -- Create a guild group:    Required Title - Description
    -- They can remove it themselves, or guild leader can.
    -- If they leave the guild, and they were only member, guild group dissolves. If other members, admin with longest time in guild gets lead... so, need to track meta data on time player has been in the group
    -- If no admin, then it goes to person who has been in group the longest.

    -- Groups will have own custom window with text area for scheduling minor details.
    -- On inviting members, just use auto-complete logic too.
    -- Request to join list for admins... Deny w/reason

    -- On the guild news, let's start with Guild achievements!
    -- If more than one guildie in a zone it also mentions how many people in the guild are also in the zone ( with mouseover including names of those in zone too ).
    -- Drop down menu on the Log Frame allowing you to choose which log to view, from any character, any faction you have... just the log. (maybe I will include maybe not. Seems mostly useless for high time effort)
    -- Guild achievement and loot NEWS window could be parsed for interesting info
    
    -- Create powerful SYNC tool - only for GM. Ability to push all current data as most-current.

    -- Search of the News Window
    -- GUILD EVENT INFO -- Potential huge feature to add
            -- GUILD EVENT AND RAID GROUP INFO
            -- Mark attendance for all in raid +1
            -- Request Assist Button  -- Requests assist from raid leader auto with press of a button it messages them.
            -- Invite everyone online in guild to party/raid
            -- Add method that increments up by 1 a tracker on num events attended, the date, total events attended, for each person that is in the raid group.
    -- INTERESTING GUILD STATISTICS
        -- Like number of legendaries collected this week
        -- Notable achievements, like Prestige advancements, rare achievements, etc.
        -- If players have obtained recent impressive titles (100k or 250k kills, battlemaster)
        -- Total number of guild battlemasters
        -- Total number of guildies with certain achievements
        -- Is it possible to identify player's achievements without being close to them?
        -- Notable high ilvl notifications with adjustable threshold to trigger it, for editable updating for expansion update flexibility
        -- Analysis of close-to-get achievements?
    -- MAGIC TOOL BOX for guild leader ??
        -- useful tools only guild leader can see... Like gkick all, or something.
    -- Ability to export data to useful format.
    -- Ability to choose how you would like your timestamps to look.
    -- Sort guild roster by "Time in guild" - possible in built-in UI? - need to complete "Total time in the guild".

    -- 1) Custom note window - Notice how that bottom left area is a bit empty? It is because I wanted to expand further info there. I have decided a custom note window is to be added. 31 characters is just far too little. This note will be syncable, and it will have an option to restrict it to certain ranks only. Features of custom note:
    -- Player will be able to restrict sync of ALL custom notes to only ranks they choose
    -- Player will be able to put a check in the box to sync only the notes they wish to sync.
    -- Note will include who note edit originated from.
    -- 500 character count limit of custom note section, for now.


    
    -- 3) Custom Notifications/Reminders -  Basically, I want to build in a feature where the player types /roster remind, or something like that, which pops up a window to set a time and date for any kind of reminder the player wants, just type it out. I've written out a rough UI on how I wish this to look, and I think it is going to be killer useful. You could set reminder to minutes or hours from now, to days or months. Very useful for on-the-spot thoughts. 
    -- It will have a custom UI to quickly set a specific time and date, and note reminder
    -- Slash command will be advances as well. For example, instead of just /roster remind, you could type '/roster remind 30 Recheck AH for deals' Rather than popup the UI window, it will just automatically create a reminder 30 minutes from now that will notify you to "Recheck AH for deals" - Use the UI or use the slash command. UI might be necessary for things much further out, but for simple reminders in that game session... quite useful.
    -- Oh and, I will be adding a Birthday reminder, so guilds can enter player's RL bday, if they so choose.
    
    -- 4) Guild Notepad - Still hammering out the minor details, but generally the idea is I plan on creating an editable notepad that people can write on in the guild. I will likely have a general and an officer one. It of course will sync with general info on who and when edits were made. This might roll into its own addon as it is a sizable project. So many potential uses, however.

    -------------------------------------
    ----- KNOWN BUGS --------------------
    ------------------------------------

    -- Potential issue when comparing players that left and are returning... GuildControlGetNumRanks() - if they were a rank that is say 9, but there is only 7 ranks in the guild now, what happens?
    -- If a player goes from not being able to read officer note, to having access, it spams you. That should be known...
    -- Note change spam if you have curse words in note/officer notes and Profanity filter on. Just disable profanity filter for now until I get around to it.
    -- Is namechange working? Someone namechanged and it didn't register it...
    
    -------------------------------------
    ----- BUSY work ---------------
    -------------------------------------
    -- GRM.IsValidName -- get ASCII byte values for the other 4 regions.
    -- Add /roster ban
    -- add /roster banlist
    -- Build Font selection dropdown menu. Also add Language selection dropdown menu. Add Checkbox to manually
    -- Ability to add someone to ban list (good for retroactive banning if you have a list before you installed the addon)
    -- Ability to remove from ban list (you can do this now if they rejoin, you can ignore ban which removes it, but this will be a little better.
    -- Sync the history of promotions and demotions as well.
    -- Potentially have it say "currently syncing" next to player's name... on addon users window

    -- GetHoursSinceLastOnline() is not truly exact as it does not account for leap year and specific month counts depending on the day and so on. It just averages all months to be an avg of 730hrs each Mostly accurate, but if leap year it could be a day off.
    -- Upon changing format option -- addon scans a bunch of officer noters, determines formats are different... Asks player if they wish to change officer note format for all automatically.
    -- Add option to put join date in public OR Officer note.
    -- Modify Timestamp format ( only modify on the display of the timestamp )

    -- BIRTHDAYS
    -- Custom Reminders
    -- Set promotion date reminders?

    -- Build a list to show people who have addon installed.
    -- Notify when player (or any alt) comes online. If player has alts... notify when the alts come online too.
    -- Create custom restriction on the player leveled minimum to announce. That way you don't get a ton of low-lvl lvling spam.
    -- Create Viewable BAN window.
    -- Ban list needs to be created to be sync'd - OR, if a player is banned, and it is a player that was in the guild at a previous time in place, then they need to be added to left players list.
    -- Guild Namechange needs to be tested.

    -- If Mature language filter is on
    -- 4 letter word == !@#$ !@#$%^ or ^&*!  
  
--- Changelog
