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
GRM_GuildNotePad_Save = {};              -- This includes both the restricted Officer only notepad, as well as the guild-wide notepad.
GRM_DebugLog_Save = {};                  -- Character specific debug log for addon dev use submission.
GRM_Misc = {};                           -- This serves as a backup placeholder to hold important values if a player logs off in the middle of something, it can carry on where it left off by storing a marker.
-- Backups...
GRM_FullBackup_Save = {};
GRM_GuildDataBackup_Save = {};

-- slash commands
SLASH_GRM1 = '/roster';
SLASH_GRM2 = '/grm';

-- Table to hold localization dictionary
GRM_L = {};
-- Localaztion array for all language initialization functions.
GRML = {};

-- Useful Variables ( kept in table to keep low upvalues count )
GRM_G = {}; 

-- Addon Details:
GRM_G.Version = "7.3.5R1.20";
GRM_G.Update = 1                         -- With 1.20 release, updates going to be held as an int, to save on parsing.
GRM_G.PatchDay = 1528300705;             -- In Epoch Time
GRM_G.PatchDayString = "1528300705";     -- 2 Versions saves on conversion computational costs... just keep one stored in memory. Extremely minor gains, but very useful if syncing thousands of pieces of data in large guilds.
GRM_G.Patch = "7.3.5";
GRM_G.LvlCap = 110;

-- Initialization Useful Globals 
-- ADDON
GRM_G.addonName = "Guild_Roster_Manager";
-- Player Details
GRM_G.guildName = "";
GRM_G.realmName = string.gsub ( string.gsub ( GetRealmName() , "-" , "" ) , "%s+" , "" );       -- Remove the space since server return calls don't include space on multi-name servers, also removes a hyphen if server is hyphened.
GRM_G.addonPlayerName = ( GetUnitName ( "PLAYER" , false ) .. "-" .. GRM_G.realmName );
GRM_G.faction = UnitFactionGroup ( "PLAYER" );
GRM_G.rank = 1;
GRM_G.FID = 0;                  -- index for Horde = 1; Ally = 2
GRM_G.logGID = 0;               -- index of the guild, so no need for repeat lookups.
GRM_G.saveGID = 0;              -- Needs a separate GID "Guild Index ID" because it may not match the log index depending on if a log entry is cleared vs guild info, which can be separate.
GRM_G.setPID = 0;               -- Since settings are player unique, PID = Player ID
GRM_G.playerRankID = 0;         -- Player personal rank ID based on rank in the guild. The lowest, 0 , is the Guild Leader. This is only used for sync purposes and is configured on sync configuration.
GRM_G.miscID = 0;               -- Index of the player GRM_Misc[index] for quick reference.
GRM_G.clubID = 0;               -- The currently selected clubID
GRM_G.gClubID = 0;              -- The immutable guild clubID

-- To ensure frame initialization occurse just once... what a waste in resources otherwise.
GRM_G.timeDelayValue = 0;
GRM_G.timeDelayValue2 = 0;
GRM_G.FramesInitialized = false;
GRM_G.OnFirstLoad = true;
GRM_G.OnFirstLoadKick = true;
GRM_G.currentlyTracking = false;
GRM_G.trackingTriggered = false;

-- Guild Status holder for checkover.
GRM_G.guildStatusChecked = false;

-- UI Controls global for reset
GRM_G.UIIsLoaded = false;

-- Tempt Logs For FinalReport()
GRM_G.TempNewMember = {};
GRM_G.TempLogPromotion = {};
GRM_G.TempInactiveReturnedLog = {};
GRM_G.TempEventRecommendKickReport = {};
GRM_G.TempLogDemotion = {};
GRM_G.TempLogLeveled = {};
GRM_G.TempLogNote = {};
GRM_G.TempLogONote = {};
GRM_G.TempRankRename = {};
GRM_G.TempRejoin = {};
GRM_G.TempBannedRejoin = {};
GRM_G.TempLeftGuild = {};
GRM_G.TempLeftGuildPlaceholder = {};
GRM_G.TempNameChanged = {};
GRM_G.TempEventReport = {};

-- Useful Globals for Quick Use
GRM_G.rankIndex = 1;
GRM_G.playerIndex = -1;
GRM_G.monthIndex = 1;
GRM_G.yearIndex = 1;
GRM_G.dayIndex = 1;
GRM_G.PlayerFromGuildLog = "";
GRM_G.GuildLogDate = {};

-- Alt Helpers
GRM_G.selectedAlt = {};
GRM_G.selectedAltList = {};
GRM_G.currentHighlightIndex = 1;

-- Guildie info
GRM_G.listOfGuildies = {};
GRM_G.numAccounts = 0;
GRM_G.guildCreationDate = "";
GRM_G.DesignateMain = false;

-- MISC Globals for resource handling... generally to avoid wasteful checks based on timers, position, pause controls.
-- Some of this is just to prevent messy carryover by keeping 1 less argument to a method, by just keeping a global. 
-- Some are for frame/UI control, like "pause" to stop mouseover updates if you are adjusting an input or editing a date or something similar.
-- TIMERS FOR ONUPDATE CONTROL TO AVOID SPAMMY CHECKS
GRM_G.timer = 0;
GRM_G.timer2 = 0; 
GRM_G.timer3 = 0;
GRM_G.timer5 = 0;
GRM_G.timer6 = 0;                        -- For the alt grouping side window
GRM_G.SyncJDTimer = 0;                   -- Use to hide window frame if all alts with dates are removed.
GRM_G.eventTimer = 0;                    -- Use for OnUpdate Limiter for Event Tab on main window.
GRM_G.eventTimerTooltip = 0;             -- For the OnUpdate Limiter of the informative tooltip in roster window.
GRM_G.usersTimerTooltip = 0              -- For the OnUpdate Limiter on th AddonUsers window... 
GRM_G.ScanRosterTimer = 0;               -- keep track of how long since last scan.
GRM_G.buttonTimer1 = 0;                  -- Controlling the info for 
GRM_G.buttonTimer2 = 0;
GRM_G.backupTimer = 0;                   -- For updating the backup frames for tooltip logic.
GRM_G.requestToJoinTimer = 0;            -- For the recruitment window offline/online status updates...
GRM_G.requestToJoinTimeInterval = 15;    -- 30 seconds... only check every 30 seconds - Variable used for potential manual adjustment
GRM_G.requestToJoinTimer = 0;            -- tracking the time interval on re-checking request to join
GRM_G.RequestJoinTimer = 0;              -- to prevent multiple lookups at same time.
GRM_G.auditTimer = 0;                    -- For the tooltip on the auditframe
GRM_G.currentAuditFontstringIndex = 1;   -- For resource saving carrying over the index -- good for massive guilds.
GRM_G.logTimer = 0;                -- to prevent the filtering when you type from searching too fast... lest it will crash


-- MISC argument resource saving globals.
GRM_G.CurrentlyScanning = false;
GRM_G.CharCount = 0;
GRM_G.DelayedAtLeastOnce = false;
GRM_G.CalendarAddDelay = 0; -- Needs to be at least 5 seconds due to server restriction on adding to calendar no more than once per 5 sec. First time can be zero.
GRM_G.RaidGCountBeingChecked = false;
GRM_G.timerUIChange = 0;
GRM_G.ShowOfflineChecked = false;
GRM_G.pause = false;
GRM_G.rankDateSet = false;
GRM_G.editPromoDate = false;
GRM_G.editJoinDate = false;
GRM_G.editFocusPlayer = false;
GRM_G.editStatusNotify = false
GRM_G.editOnlineStatus = false;
GRM_G.numPlayersRequestingGuildInv = 0;
GRM_G.guildFinderReported = false;
GRM_G.changeHappenedExitScan = false;
GRM_G.currentName = "";
GRM_G.currentNameIndex = 2;
GRM_G.RecursiveStop = false;
GRM_G.isChecked = false;
GRM_G.isChecked2 = false;
GRM_G.ClickCount = 0;
GRM_G.HasAccessToGuildChat = false;
GRM_G.HasAccessToOfficerChat = false;
GRM_G.tempAltName = "";
GRM_G.firstTimeWarning = true;
GRM_G.tempAddBanClass = "";
GRM_G.isHyperlinkListenInitialized = false;
GRM_G.ChangesFoundOnLoad = false;
GRM_G.MsgFilterEnabled = false;
GRM_G.MsgFilterDelay = false;
GRM_G.MsgFilterDelay2 = false;
GRM_G.TooManyFriendsWarning = false;
GRM_G.IsOnLogonDelay = time();
GRM_G.LeftPlayersStillOnServer = {};
GRM_G.RequestToJoinPlayersCurrentlyOnline = {};
GRM_G.TempListNamesAdded = {};
GRM_G.TempListNamesAddedLeftPlayers = {};
GRM_G.OriginalEditBoxValue = "";             -- To hold in case player loses focus of editbox without changing anything.
GRM_G.previousNote = "-%";                   -- Gibberish not for comparison against on first load.
GRM_G.tempEventNoteHolder = "";
GRM_G.DropDownHighlightLockIndex = 1;
GRM_G.InitiatingBanEdit = false;
GRM_G.AltSideWindowFreeze = false;
GRM_G.AuditSortType = 1;

-- Calendar Globals
GRM_G.CalendarRegistered = false;
GRM_G.currentCalendarOffset = 1;
GRM_G.IsAltGrouping = false;
GRM_G.CurrentCalendarName = "";
GRM_G.CurrentCalendarHexCode = "";

-- Tooltip holdover.
GRM_G.toolTipScale = 1.0;

-- Backup Controls
GRM_G.selectedFID = 0;
GRM_G.BackupLoadedOnce = false;
GRM_G.BackupFrameSelectDetails = {};

-- Throttle controls
GRM_G.ThrottleControlNum = 1;
GRM_G.ThrottleControlNum2 = 2;
GRM_G.newPlayers = {};
GRM_G.leavingPlayers = {};

-- ColorPicker Controls
GRM_G.MainTagColor = false;
GRM_G.MainTagHexCode = "";

-- Current Addon users
GRM_G.currentAddonUsers = {};

-- Log Options Controls
GRM_G.LogNumbersColorUpdate = false;
GRM_G.FinalCountVisible = 0;

-- Dropdown logic helpers and Roster UI Logic
GRM_G.RosterButtons = {};
GRM_G.CurrentRank = "";

-- Version Control
GRM_G.VersionChecked = false;
GRM_G.VersionCheckRegistered = false;
GRM_G.VersionCheckedNames = {};
GRM_G.NeedsToAddSelfToList = false;
GRM_G.ActiveStatusQue = {};

-- For Temporary Slash Command Actions
GRM_G.TemporarySync = false;
GRM_G.ManualScanEnabled = false;

-- Banning players
GRM_G.TempBanTarget = {};

-- FOR LOCALIZATION
GRM_G.Region = GetLocale();
GRM_G.Localized = false;
GRM_G.LocalizedIndex = 1;
GRM_G.FontChoice = "";
GRM_G.FontModifier = 0;

-- Debugging
GRM_G.DebugLog = {};
GRM_G.DebugEnabled = false;

-- Useful Lookup Tables for date indexing.
local monthEnum = { Jan = 1 , Feb = 2 , Mar = 3 , Apr = 4 , May = 5 , Jun = 6 , Jul = 7 , Aug = 8 , Sep = 9 , Oct = 10 , Nov = 11 , Dec = 12 };
local monthEnum2 = { ['1'] = "Jan" , ['2'] = "Feb" , ['3'] = "Mar", ['4'] = "Apr" , ['5'] = "May" , ['6'] = "Jun" , ['7'] = "Jul" , ['8'] = "Aug" , ['9'] = "Sep" , ['10'] = "Oct" , ['11'] = "Nov" , ['12'] = "Dec" };
local monthsFullnameEnum = { January = 1 , February = 2 , March = 3 , April = 4 , May = 5 , June = 6 , July = 7 , August = 8 , September = 9 , October = 10 , November = 11 , December = 12 };
local daysBeforeMonthEnum = { ['1']=0 , ['2']=31 , ['3']=59 , ['4']=90 , ['5']=120 , ['6']=151 , ['7']=181 , ['8']=212 , ['9']=243 , ['10']=273 , ['11']=304 , ['12']=334 };
local daysInMonth = { ['1']=31 , ['2']=28 , ['3']=31 , ['4']=30 , ['5']=31 , ['6']=30 , ['7']=31 , ['8']=31 , ['9']=30 , ['10']=31 , ['11']=30 , ['12']=31 };
local AllClasses = { "Deathknight" , "Demonhunter" , "Druid" , "Hunter" , "Mage" , "Monk" , "Paladin" , "Priest" , "Rogue" , "Shaman" , "Warlock" , "Warrior" };

-- Which frame to send AddMessage
local chat = DEFAULT_CHAT_FRAME;

-- Let's global some of these useful frames into a table.
local GuildRanks = {};

-- Beta
local SendAddonMessage = C_ChatInfo and C_ChatInfo.SendAddonMessage or SendAddonMessage;
local RegisterAddonMessagePrefix = C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix or RegisterAddonMessagePrefix;

------------------------
------ FRAMES ----------
------------------------

-- Live Frames - Keep them separate for cleaner code, and to run in parallel
local Initialization = CreateFrame ( "Frame" );
local GeneralEventTracking = CreateFrame ( "Frame" );
local UI_Events = CreateFrame ( "Frame" );
local VersionCheck = CreateFrame ( "Frame" );
local KickAndRankChecking = CreateFrame ( "Frame" );
local GuildBankInfoTracking = CreateFrame ( "Frame" );  -- minimal features. This will hold the "OnEvent" script for guild bank info check upon login, so it doesn't take 10-20 seconds to load the bank tab logs when you first open.
local AddonUsersCheck = CreateFrame ( "Frame" );
local GRM_CoreUpdateFrame = CreateFrame ( "frame" );

--------------------------
--- FUNCTIONS ------------
--------------------------



--------------------------
--- DATABASE QUERY -------
--------------------------

-- Method:          GRM.PlayerQuery ( string )
-- What it does:    Returns the int index of an array for identifying the player in the database...
-- Purpose:         Clean the code.. saves a lot of nested loops, just query here, return the index, and avoid issues, like forgetting to break a loop. 
GRM.PlayerQuery = function ( name )
    local result = 0;
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == name then
            result = i;
            break;
        end
    end
    return result;
end

-- Method:          GRM.LeftPlayerQuery ( string )
-- What it does:    Returns the int index of an array for identifying the player in the database who was once in the guild but left...
-- Purpose:         Clean the code.. saves a lot of nested loops, just query here, return the index, and avoid issues, like forgetting to break a loop. 
GRM.LeftPlayerQuery = function ( name )
    local result = 0;
    for i = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == name then
            result = i;
            break;
        end
    end
    return result;
end

--------------------------
------- SETTINGS ---------
--------------------------


-- Method:          GRM.ClearPermData()
-- What it Does:    Resets all the saved data back to nothing... and does not rebuid it.
-- Purpose:         Mainly for use if ever there is a need to purge the data
GRM.ClearPermData = function()
    -- SPECIAL NOTE (if ever needed);

    GRM_GuildMemberHistory_Save = nil;
    GRM_GuildMemberHistory_Save = {};
    GRM_GuildMemberHistory_Save = { { "Horde" } , { "Alliance" } };

    GRM_PlayersThatLeftHistory_Save = nil;
    GRM_PlayersThatLeftHistory_Save = {};
    GRM_PlayersThatLeftHistory_Save = { { "Horde" } , { "Alliance" } };

    GRM_LogReport_Save = nil;
    GRM_LogReport_Save = {};
    GRM_LogReport_Save = { { "Horde" } , { "Alliance" } };

    GRM_CalendarAddQue_Save = nil;
    GRM_CalendarAddQue_Save = {};
    GRM_CalendarAddQue_Save = { { "Horde" } , { "Alliance" } };
    
    GRM_AddonSettings_Save = nil;
    GRM_AddonSettings_Save = {};
    GRM_AddonSettings_Save = { { "Horde" } , { "Alliance" } };

    GRM_PlayerListOfAlts_Save = nil;
    GRM_PlayerListOfAlts_Save = {};
    GRM_PlayerListOfAlts_Save = { { "Horde" } , { "Alliance" } };

    GRM_GuildNotePad_Save = nil;
    GRM_GuildNotePad_Save = {};
    GRM_GuildNotePad_Save = { { "Horde" } , { "Alliance" } };

    GRM_FullBackup_Save = nil;
    GRM_FullBackup_Save = {};

    GRM_GuildDataBackup_Save = nil;
    GRM_GuildDataBackup_Save = {};
    GRM_GuildDataBackup_Save = { { "Horde" } , { "Alliance" } };

    GRM_DebugLog_Save = nil;
    GRM_DebugLog_Save = {};

    GRM_Misc = nil;
    GRM_Misc = {};
    
end

-- /run local t=GRM_PlayerListOfAlts_Save; for i=1,#t do if i==1 then print("HORDE:") else print("ALLIANCE:") end; for j=2,#t[i] do print(t[i][j][1][1]) end end
-- Method:          GRM.ConfigureMiscForPlayer( string );
-- What it Does:    Builds a file for tracking active data that can be reference back to on a relog... so as to mark where to carry on from
-- Purpose:         In case a player logs out in the middle of critical things, both front and backend, it has a marker stored on where to restart from.
GRM.ConfigureMiscForPlayer = function( playerFullName )
    table.insert ( GRM_Misc , { 
        playerFullName,                                 -- 1) Name
        {},                                             -- 2) To hold the details on Added Friends that might need to be removed from recruit list (if added and player logged in that 1 second window)
        {},                                             -- 3) Same as above, except now in regards to the Players who left the guild check
        {},                                             -- 4) ""
        "",                                             -- 5) ""
        "",                                             -- 6) ""
        0                                               -- 7) ""
    } );
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
    for i = 2 , #GRM_AddonSettings_Save[GRM_G.FID] do
        if GRM_AddonSettings_Save[GRM_G.FID][i][1] == GRM_G.addonPlayerName then
            isFound = true;
            indexFound = i;
        end
    end

    -- Build settings for first time.
    if not isFound then
         -- Add new player
        table.insert ( GRM_AddonSettings_Save[GRM_G.FID] , { GRM_G.addonPlayerName } );
        GRM_G.setPID = #GRM_AddonSettings_Save[GRM_G.FID];                                -- We know what the ID is...
        GRM.Report ( "\n" .. GRM.L ( "Configuring Guild Roster Manager for {name} for the first time." , GetUnitName ( "PLAYER" , false ) ) );
        local rankRestrictedDefault;
        if IsInGuild() then
            rankRestrictedDefault = GuildControlGetNumRanks() - 1;
        else
            rankRestrictedDefault = 2;
        end

        local AllDefaultSettings = {

            GRM_G.Version,                                                                                          -- 1)  Version
            true,                                                                                                   -- 2)  View on Load
            { true , true , true , true , true , true , true , true , true , true , true , true , true , true },    -- 3)  All buttons are checked in the log window (13 so far)
            336,                                                                                                    -- 4)  Report inactive return of player coming back (2 weeks is default value)
            14,                                                                                                     -- 5)  Event Announce in Advance - Cannot be higher than 4 weeks ( 28 days ) ( 1 week is default);
            30,                                                                                                     -- 6)  How often to check for changes ( in seconds )
            false,                                                                                                  -- 7)  Add Timestamp on join to Officer Note
            true,                                                                                                   -- 8)  Use Calendar Announcements
            12,                                                                                                     -- 9)  Months Player Has Been Offline to Add Announcement To Kick
            false,                                                                                                  -- 10) Recommendations!
            true,                                                                                                   -- 11) Report Inactive Returns
            true,                                                                                                   -- 12) Announce Upcoming Events.
            { true , true , true , true , true , true , true , true , true , true , true , true , true , true },    -- 13) Checkbox for message frame announcing. Disable 
            true,                                                                                                   -- 14) Allow Data sharing between guildies
            rankRestrictedDefault,                                                                                  -- 15) Rank Player must be to accept sync updates from them.
            true,                                                                                                   -- 16) Receive Notifications if others in the guild send updates!
            false,                                                                                                  -- 17) Only announce the anniversary of players set as the "main"
            true,                                                                                                   -- 18) Scan for changes
            true,                                                                                                   -- 19) Sync only with players who have current version or higher.
            true,                                                                                                   -- 20) Add Join Date to Officer Note = true, Public Note = false
            true,                                                                                                   -- 21) Sync Ban List
            2,                                                                                                      -- 22) Rank player must be to send or receive Ban List sync updates!
            1,                                                                                                      -- 23) Only Report level increase greater than or equal to this.
            1,                                                                                                      -- 24)  100 % speed
            345,                                                                                                    -- 25) Minimap Position
            78,                                                                                                     -- 26) Minimap Radius
            true,                                                                                                   -- 27) Notify when player requests to join guild the recruitment window
            false,                                                                                                  -- 28) Only View on Load if Changes were found
            true,                                                                                                   -- 29) Show "main" name in guild/whispers if player speaking on their alt
            false,                                                                                                  -- 30) Only show those needing to input data on the audit window.
            false,                                                                                                  -- 31) Sync Settings of all alts in the same guild
            true,                                                                                                   -- 32) Show Minimap Button
            true,                                                                                                   -- 33) Audit Frame - Unknown Counts as complete
            true,                                                                                                   -- 34) Allow Autobackups
            true,                                                                                                   -- 35) Share data with ALL guildies, but only receive from your threshold rank
            true,                                                                                                   -- 36) Show Line Numbers in Log
            true,                                                                                                   -- 37) Enable Shift-Click Line removal of the log...
            true,                                                                                                   -- 38) Allow Custom Note Sync
            GRM.Use24HrBasedOnDefaultLanguage(),                                                                    -- 39) Use 24hr Scale
            true,                                                                                                   -- 40) Track Birthdays
            7,                                                                                                      -- 41) Auto Backup Interval in Days
            1,                                                                                                      -- 42) Main Tag format index
            GRM_G.LocalizedIndex,                                                                                   -- 43) Selected Language ( 1 default is English)
            1,                                                                                                      -- 44) Selected Font ( 1 is Default )
            0,                                                                                                      -- 45) Font Modifier Size
            { 1 , 0 , 0 },                                                                                          -- 46) RGB color selection on the "Main" tagging (Default is Red)
            {},                                                                                                     -- 47) ''
            {},                                                                                                     -- 48) ''
            2,                                                                                                      -- 49) Default rank for syncing Custom Note
            0.9,                                                                                                    -- 50) Default Tooltip Size
            1,                                                                                                      -- 51) Date Format  -- 1 = default  "1 Mar '18"
            true,                                                                                                   -- 52) Use "Fade" on tabbing
            false                                                                                                   -- 53) Avoid burst sync if on Reload...
        };
       
        -- Unique Settings added to the player.
        table.insert ( GRM_AddonSettings_Save[GRM_G.FID][ #GRM_AddonSettings_Save[GRM_G.FID] ] , AllDefaultSettings );
        GRM.SyncAddonSettingsOfNewToon();
        GRM.ConfigureMiscForPlayer( GRM_G.addonPlayerName );
        -- Forcing core log window/options frame to load on the first load ever as well
        GRM_G.ChangesFoundOnLoad = true;

    elseif GRM_AddonSettings_Save[GRM_G.FID][indexFound][2][1] ~= GRM_G.Version then
        -- numericV is used to compare older versions.
        local numericV = tonumber ( string.sub ( GRM_AddonSettings_Save[GRM_G.FID][indexFound][2][1] , string.find ( GRM_AddonSettings_Save[GRM_G.FID][indexFound][2][1] , "R" ) + 1 , # GRM_AddonSettings_Save[GRM_G.FID][indexFound][2][1] ) );

        -- Need to doublecheck Faction Index ID
        if GRM_G.faction == 0 then
            if GRM_G.faction == "Horde" then
                GRM_G.FID = 1;
                GRM_G.selectedFID = 1;
            elseif GRM_G.faction == "Alliance" then
                GRM_G.FID = 2;
                GRM_G.selectedFID = 2;
            end
        end

        -- for Settings
        if GRM_G.setPID == 0 then
            for i = 2 , #GRM_AddonSettings_Save[GRM_G.FID] do
                if GRM_AddonSettings_Save[GRM_G.FID][i][1] == GRM_G.addonPlayerName then
                    GRM_G.setPID = i;
                    break;
                end
            end
        end

        -------------------------------
        --- START PATCH FIXES ---------
        -------------------------------

        GRM_Patch.SettingsCheck ( numericV );
        
        -------------------------------
        -- END OF PATCH FIXES ---------
        -------------------------------

        -- Ok, let's update the version!
        GRM.Report ( GRM.L ( "GRM Updated:" ) .. " v" .. string.sub ( GRM_G.Version , 6 ) );

        -- Updating the version for ALL saved accoutns.
        for i = 1 , #GRM_AddonSettings_Save do
            for j = 2 , #GRM_AddonSettings_Save[i] do
                GRM_AddonSettings_Save[i][j][2][1] = GRM_G.Version;      -- Changing version for all indexes of all toons on this account
            end
        end
    end

    -- Need to doublecheck Faction Index ID
    if GRM_G.faction == 0 then
        if GRM_G.faction == "Horde" then
            GRM_G.FID = 1;
            GRM_G.selectedFID = 1;
        elseif GRM_G.faction == "Alliance" then
            GRM_G.FID = 2;
            GRM_G.selectedFID = 2;
        end
    end

    -- for Settings
    if GRM_G.setPID == 0 then
        for i = 2 , #GRM_AddonSettings_Save[GRM_G.FID] do
            if GRM_AddonSettings_Save[GRM_G.FID][i][1] == GRM_G.addonPlayerName then
                GRM_G.setPID = i;
                break;
            end
        end
    end

    GRM.MiscCleanupOnLogin();
    -- Let's load that minimap button now too...
    GRM_UI.GRM_MinimapButtonInit();
    GRM.RefreshMainTagHexCode();
    -- For sync...
    GRMsyncGlobals.timeAtLogin = time();
    GRMsyncGlobals.ThrottleCap = GRMsyncGlobals.ThrottleCap * GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][24];
end

-- Method:          GRM.ResetDefaultSettings()
-- What it Does:    Resets the OPTIONS to the default one for only the currently logged in player
-- Purpose:         Easy, quality of life for user in the options, for simple reset.
GRM.ResetDefaultSettings = function()
    
    -- Purge it from memory
    GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2] = nil;

    local rankRestrictedDefault;
    if IsInGuild() then
        rankRestrictedDefault = GuildControlGetNumRanks() - 1;
    else
        rankRestrictedDefault = 2;
    end
    
    -- Reset to default
    GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2] = {

        GRM_G.Version,                                                                                          -- 1)  Version
        true,                                                                                                   -- 2)  View on Load
        { true , true , true , true , true , true , true , true , true , true , true , true , true , true },    -- 3)  All buttons are checked in the log window (14 so far)
        336,                                                                                                    -- 4)  Report inactive return of player coming back (2 weeks is default value)
        14,                                                                                                     -- 5)  Event Announce in Advance - Cannot be higher than 4 weeks ( 28 days ) ( 1 week is default);
        30,                                                                                                     -- 6)  How often to check for changes ( in seconds )
        false,                                                                                                  -- 7)  Add Timestamp on join to Officer Note
        true,                                                                                                   -- 8)  Use Calendar Announcements
        12,                                                                                                     -- 9)  Months Player Has Been Offline to Add Announcement To Kick
        false,                                                                                                  -- 10) Recommendations!
        true,                                                                                                   -- 11) Report Inactive Returns
        true,                                                                                                   -- 12) Announce Upcoming Events.
        { true , true , true , true , true , true , true , true , true , true , true , true , true , true },    -- 13) Checkbox for message frame announcing. Disable 
        true,                                                                                                   -- 14) Allow Data sharing between guildies
        rankRestrictedDefault,                                                                                  -- 15) Rank Player must be to accept sync updates from them.
        true,                                                                                                   -- 16) Receive Notifications if others in the guild send updates!
        false,                                                                                                  -- 17) Only announce the anniversary of players set as the "main"
        true,                                                                                                   -- 18) Scan for changes
        true,                                                                                                   -- 19) Sync only with players who have current version or higher.
        true,                                                                                                   -- 20) Add Join Date to Officer Note = true, Public Note = false
        true,                                                                                                   -- 21) Sync Ban List
        2,                                                                                                      -- 22) Rank player must be to send or receive Ban List sync updates!
        1,                                                                                                      -- 23) Only Report level increase greater than or equal to this.
        1,                                                                                                      -- 24) 100 % speed
        345,                                                                                                    -- 25) Minimap Position
        78,                                                                                                     -- 26) Minimap Radius
        true,                                                                                                   -- 27) Notify when player requests to join guild the recruitment window
        false,                                                                                                  -- 28) Only View on Load if Changes were found
        true,                                                                                                   -- 29) Show "main" name in guild/whispers if player speaking on their alt
        false,                                                                                                  -- 30) Only show those needing to input data on the audit window.
        false,                                                                                                  -- 31) Sync Settings of all alts in the same guild
        true,                                                                                                   -- 32) Show Minimap Button
        true,                                                                                                   -- 33) Audit Frame - Unknown Counts as complete
        true,                                                                                                   -- 34) Allow Autobackups
        true,                                                                                                   -- 35) Share data with ALL guildies, but only receive from your threshold rank
        true,                                                                                                   -- 36) Show line numbers in log
        true,                                                                                                   -- 37) Enable Shift-Click Line removal of the log...
        true,                                                                                                   -- 38) Custom Note Sync allowed
        GRM.Use24HrBasedOnDefaultLanguage(),                                                                    -- 39) Use 24hr Scale
        true,                                                                                                   -- 40) Track Birthdays
        7,                                                                                                      -- 41) Auto Backup Interval in Days
        1,                                                                                                      -- 42) Main Tag format index
        GRM_G.LocalizedIndex,                                                                                   -- 43) Selected Language ( 1 default is English)
        1,                                                                                                      -- 44) Selected Font ( 1 is Default )
        0,                                                                                                      -- 45) Font Modifier Size
        { 1 , 0 , 0 },                                                                                          -- 46) RGB color selection on the "Main" tagging (Default is Red)
        {},                                                                                                     -- 47) ''
        {},                                                                                                     -- 48) ''
        2,                                                                                                      -- 49) Default rank for syncing Custom Note
        0.9,                                                                                                    -- 50) Default Tooltip Size
        1,                                                                                                      -- 51) Date Format  -- 1 = default  "1 Mar '18"
        true,                                                                                                   -- 52) Use "Fade" on tabbing
        false                                                                                                   -- 53) Avoid burst sync if on Reload...
    }

    -- If scan  was previously disabled, need to re-trigger it.
    if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButton:GetChecked() then
        GRM.Report ( GRM.L ( "Reactivating Auto SCAN for Guild Member Changes..." ) );

        GuildRoster();
        C_Timer.After ( 5 , GRM.TriggerTrackingCheck );     -- 5 sec delay necessary to trigger server call.
    end

    -- if sync was disabled
    if ( not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButton:GetChecked() or ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList:IsEnabled() and not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList:GetChecked() and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][21] ) ) and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] then
        if not GRMsyncGlobals.currentlySyncing and GRM_G.HasAccessToGuildChat then
            GRM.Report ( GRM.L ( "Reactivating Data Sync..." ) );
            GRMsync.TriggerFullReset();
            -- Now, let's add a brief delay, 3 seconds, to trigger sync again
            GRMsync.Initialize();
        end
    end

    GRML.SetNewLanguage( GRM_G.LocalizedIndex , false );

    if GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then
        GRM_UI.BuildLogFrames();
    end
end

-- Method:          GRM.SyncAddonSettings()
-- What it Does:    It syncs all of the addon settings of the current player with all of the other alts the player has within that guild
-- Purpose:         To have a "global" settings option.
GRM.SyncAddonSettings = function()
    for i = 2 , #GRM_PlayerListOfAlts_Save[GRM_G.FID] do
        if GRM_PlayerListOfAlts_Save[GRM_G.FID][i][1][1] == GRM_G.guildName then
            -- Now, let's sync the settings of all players
            for j = 2 , #GRM_PlayerListOfAlts_Save[GRM_G.FID][i] do
                if GRM_PlayerListOfAlts_Save[GRM_G.FID][i][j][1] ~= GRM_G.addonPlayerName then
                    -- Ok, guild found, and a player that is not the current logged in addon user found... need to sync settings with this player
                    for s = 2 , #GRM_AddonSettings_Save[GRM_G.FID] do
                        if GRM_AddonSettings_Save[GRM_G.FID][s][1] == GRM_PlayerListOfAlts_Save[GRM_G.FID][i][j][1] then
                            -- Preserve the Minimap button rules, however... both on if to show, and the position are preserved...
                            local tempMinimapHolder = GRM.DeepCopyArray ( { GRM_AddonSettings_Save[GRM_G.FID][s][2][32] , GRM_AddonSettings_Save[GRM_G.FID][s][2][25] , GRM_AddonSettings_Save[GRM_G.FID][s][2][26] } );
                            local tempTable = GRM.DeepCopyArray ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2] );                                                                         -- You need to set these values or else they won't carry over
                            GRM_AddonSettings_Save[GRM_G.FID][s][2] = tempTable;      -- overwrite each player's settings with the current
                            GRM_AddonSettings_Save[GRM_G.FID][s][2][32] = tempMinimapHolder[1];
                            GRM_AddonSettings_Save[GRM_G.FID][s][2][25] = tempMinimapHolder[2];
                            GRM_AddonSettings_Save[GRM_G.FID][s][2][26] = tempMinimapHolder[3];
                            break;
                        end
                    end
                end
            end
            break;
        end
    end
end

-- Method:          GRM.SyncAddonSettingsOfNewToon()
-- What it Does:    If a new player is joins the guild, and you already have a player in there, and one of the alts has it set to sync the settings in the guild,
--                  it loads the alt's settings.
-- Purpose:         Settings Sync feature...
GRM.SyncAddonSettingsOfNewToon = function()
    if GRM_G.guildName ~= nil then
        for i = 2 , #GRM_PlayerListOfAlts_Save[GRM_G.FID] do
            if GRM_PlayerListOfAlts_Save[GRM_G.FID][i][1][1] == GRM_G.guildName then
                -- Now, let's sync the settings of all players
                local isSynced = false;
                for j = 2 , #GRM_PlayerListOfAlts_Save[GRM_G.FID][i] do
                    if GRM_PlayerListOfAlts_Save[GRM_G.FID][i][j][1] ~= GRM_G.addonPlayerName then
                        for s = 2 , #GRM_AddonSettings_Save[GRM_G.FID] do
                            if GRM_AddonSettings_Save[GRM_G.FID][s][1] == GRM_PlayerListOfAlts_Save[GRM_G.FID][i][j][1] then
                                -- Now, player alt is identified... now I need to check if their settings is set to sync true, and if so, then absorb them as my own.
                                    if GRM_AddonSettings_Save[GRM_G.FID][s][2][31] then
                                        GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2] = GRM_AddonSettings_Save[GRM_G.FID][s][2];      -- Setting new toon to that toon's alt settings...
                                        isSynced = true;
                                    end
                                break;
                            end
                        end
                    end
                    if isSynced then
                        break;
                    end
                end
                break;
            end
        end
    end
end

-- Method:          GRM.SlimName(string)
-- What it Does:    Removes the server name after character name.
-- Purpose:         Server name is not important in a guild since all will be server name.
GRM.SlimName = function( name )
    if name ~= nil then
        if string.find ( name , "-" , 1 ) ~= nil then
            return string.sub ( name , 1 , string.find ( name ,"-" ) - 1 );
        else
            return name;
        end
    else
        return "";
    end
end

-- Method:          GRM.FormatNameWithPlayerServer ( string )
-- What it Does:    Adds the realmName to the end of a player short name, if it is missing.
-- Purpose:         If a person is on the same server, often the server is omitted. This resolves that by adding it, which makes it easier to match in the database
GRM.FormatNameWithPlayerServer = function ( name )
    if string.find ( name , "-" ) == nil then
        name = name .. "-" .. GRM_G.realmName;
    end
    return name;
end

-- Method:          GRM.Use24HrBasedOnDefaultLanguage()
-- What it Does:    Establishes if the language uses the 24hr timestamp
-- Purpose:         On configuring a new toon, it is useful to know what timestamp format is commonly used 24hr or 12hr
GRM.Use24HrBasedOnDefaultLanguage = function()
    local result = true;
    if GRM_G.LocalizedIndex == 1 or GRM_G.LocalizedIndex == 6 then
        result = false;
    end
    return result;
end

-- Method:          GRM.AppendPlayerRealm ( string )
-- What it Does:    If necessary, it appends the realm to the end of a truncated player name
-- Purpose:         Full name with server is easier to lookup in the database, especially with merged realms.
GRM.AppendPlayerRealm = function ( name )
    if name == nil or name == "" then
        name = "";
    else
        name = GRM.CleanedOfTagName ( name );                   -- First, clean the name...
        if string.find ( name , "-" ) == nil then
            name = name .. "-" .. GRM_G.realmName;              -- This means they are from my own server, thus need to append the server on.
        end
    end
    return name;
end

-- Method:          GRM.CleanedOfTagName ( string )
-- What it Does:    Removes the tag from the name because the name is re-pulled from the GetText()
-- PurposE:         Cleaning up for the tooltips...
GRM.CleanedOfTagName = function ( name )
    if string.find ( name , " " ) ~= nil then
        name = string.sub ( name , 1 , string.find ( name , " " ) - 1 );
    end
    return name;
end

-- Method:          GRM.GetNameWithMainTags( ( string , boolean , boolean )
-- What it Does:    On refresh or any changes on the CalenderInviteFrame it resets the main/alt tags
-- Purpose:         This needs to be handled and refreshed constantly because any changes, even with the slider, it overwrites all script handlers. So 
--                  tags needs to be reapplied.
GRM.GetNameWithMainTags = function( name , slimName , includeMainOnAlts )
    local hexCode = GRM_G.MainTagHexCode;
    local format = { "<" .. GRM.L ( "M" ) .. ">" , "(" .. GRM.L ( "M" ) .. ")" , "<" .. GRM.L ( "Main" ) .. ">" , "(" .. GRM.L ( "Main" ) .. ")" };
    local mainDisplay = format[GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][42]];
    local guildData = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    
    if guildData ~= nil then
        for j = 2, #guildData do
            if name == guildData[j][1] then
                -- Found in the guild database...
                if guildData[j][10] then
                    if slimName then
                        name = ( GRM.SlimName ( name ) .. " " .. hexCode .. mainDisplay .. "|r" );     -- This player is the main
                    else
                        name = ( name .. " " .. hexCode .. mainDisplay .. "|r" );
                    end
                    if #guildData[j][11] > 0 then
                        GRM_G.IsAltGrouping = true;
                    end
                elseif #guildData[j][11] > 0 then
                    GRM_G.IsAltGrouping = true;
                    local listOfAlts = guildData[j][11];
                    for r = 1 , #listOfAlts do
                        if listOfAlts[r][5] then
                            if slimName then
                                name = ( GRM.SlimName ( name ) .. " " .. hexCode .. GRM.L ( "<A>" ) .. "|r" );  -- This player is not the main, but is part of a grouping with a player who is main
                            else
                                name = ( name .. " " .. hexCode .. GRM.L ( "<A>" ) .. "|r" );
                            end
                            if includeMainOnAlts then
                                name = name .. " " .. GRM.GetClassifiedName ( listOfAlts[r][1] ) .. " " .. hexCode .. mainDisplay .. "|r" ;
                            end
                            break;
                        end
                    end
                else
                    if slimName then
                        name = GRM.SlimName ( name );
                    end
                end
                break;
            end
        end
    end
    return name;
end

-- Method:          GRM.RefreshMainTagHexCode()
-- What it Does:    Reconverts the RGB values, scales then, then converts to hexcode
-- Purpose:         So, this only needs to be configured one time on load, or when the player updates the settings.
GRM.RefreshMainTagHexCode = function()
    GRM_G.MainTagHexCode = GRM.rgbToHex ( { GRM.ConvertRGBScale ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][46][1] , true ) , GRM.ConvertRGBScale ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][46][2] , true ) , GRM.ConvertRGBScale ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][46][3] , true ) } );
end


--------------------------------------
------ LOCALIZATION LOGIC ------------
--------------------------------------

-- Method:          GRM.L ( string , string , int (or casted int to string) , string , string )
-- What it Does:    Returns the localized string based on the hash table using the key, or the key itself if the value is set to true (meaning no localization necessary or does not exist yet)
-- Purpose:         For ease of localization so people from any region can enjoy the addon in their native tongue!!!
GRM.L = function ( key , playerName , playerName2 , num , custom1 , custom2 )
    if key ~= nil and GRM_L[key] ~= nil then
        if GRM_L[key] == true then      -- If true it has not been localized, or it is English client
            if playerName then          -- It is not nil
                key = string.gsub ( key , "{name}" , playerName );    -- insert playerName where needed - this is because in localization, for example "Arkaan's bday" in Spanish would have name at end of statement
            end
            if playerName2 then          -- It is not nil
                key = string.gsub ( key , "{name2}" , playerName2 );    -- insert playerName where needed - this is because in localization, for example "Arkaan's bday" in Spanish would have name at end of statement
            end
            if num then
                key = string.gsub ( key , "{num}" , num );
            end
            if custom1 then
                key = string.gsub ( key , "{custom1}" , custom1 );
            end
            if custom2 then
                key = string.gsub ( key , "{custom2}" , custom2 );
            end
            return key;
        else
            local result = GRM_L[key];
            if playerName then          -- It is not nil
                result = string.gsub ( result , "{name}" , playerName );    -- insert playerName where needed - this is because in localization, for example "Arkaan's bday" in Spanish would have name at end of statement
            end
            if playerName2 then          -- It is not nil
                result = string.gsub ( result , "{name2}" , playerName2 );    -- insert playerName where needed - this is because in localization, for example "Arkaan's bday" in Spanish would have name at end of statement
            end
            if num then
                result = string.gsub ( result , "{num}" , num );
            end
            if custom1 then
                result = string.gsub ( result , "{custom1}" , custom1 );
            end
            if custom2 then
                result = string.gsub ( result , "{custom2}" , custom2 );
            end
            return result
        end
    else
        if key ~= nil then
            GRM.Report ("GRM WARNING!!! FAILURE TO LOAD THIS KEY: " .. key .. "\nPLEASE REPORT TO ADDON DEV! THANK YOU!" );  -- for debugging purposes.
        else
            error ( "Localization Key is nil" );
        end
        return key;
    end
end

-- Method:          GRM.OrigL ( string )
-- What it Does:    Takes a hash result and returns the key. It's essentially a dictionary lookup in reverse
-- Purpose:         Some of the code needs to be localized only on the front end, but the backend code is based on some English variables
--                  This allows the localized data to be presented to the user, but on the backend to cycle back to the hash key for parse analysis.
GRM.OrigL = function ( localizedString )
    local result = localizedString;
    -- if it is not nil, then we know we already have the OrigL
    if GRM_L[localizedString] == nil then
        for key , y in pairs ( GRM_L ) do
            if y == localizedString then
                result = key;
                break;
            end
        end
    end
    return result;
end

--------------------------------------
--- DATA BACKUP AND SAVE LOGIC -------
--------------------------------------

-- Method:          GRM.Round ( float , int )
-- What it Does:    Returns a given number with the given number of requested decimals places.
-- Purpose:         Clean reporting and aesthetics...
GRM.Round = function ( num , numDecimals )
    local modifier = 10 ^ ( numDecimals or 0 );
    return math.floor ( num * modifier + 0.5 ) / modifier;
end

-- Method:          GRM.DeepCopyArray(array)
-- What it Does:    Makes a Deep copy, including all children, recursively, so as to create a new memory reference of the array
-- Purpose:         In Lua, you cannot just copy a table. It copies the reference and changes made to new table and references the memory to being the same, even if they have different variable names
--                  So, to truly create a unique reference to an array, so if you edit one it doesn't edit both, you need to do a true copy. This basically creates a new empty array and imports each value
--                  to the table. Backups would not be possible without this code right here.
GRM.DeepCopyArray = function( tableToCopy )
    local copy;
    if type ( tableToCopy ) == 'table' then
        copy = {};
        for orig_key , orig_value in next , tableToCopy , nil do
            copy [ GRM.DeepCopyArray ( orig_key ) ] = GRM.DeepCopyArray ( orig_value );
        end
        setmetatable ( copy , GRM.DeepCopyArray ( getmetatable ( tableToCopy ) ) );
    else
        copy = tableToCopy;         -- Imported data was not a table... just return orig. value - error protection
    end
    return copy;
end

-- Methpd:          GRM.AddFullBackup()
-- What it Does:    It does an entire backup of the core database... of EVERYTHING, except other backups.
-- Purpose:         To do a full data restore in case anything breaks...
GRM.AddFullBackup = function()
    -- Don't want to store too much lest it gets too bloated...
    if #GRM_FullBackup_Save < 2 then
        table.insert ( GRM_FullBackup_Save , { GRM.GetTimestamp() , time() , GRM_GuildMemberHistory_Save , GRM_PlayersThatLeftHistory_Save , GRM_LogReport_Save, GRM_CalendarAddQue_Save , GRM_GuildNotePad_Save , GRM_PlayerListOfAlts_Save } );
    else
        GRM.Report ( GRM.L ( "To avoid storage bloat, a maximum of 2 save points is currently possible. Please remove one before Continuing." ) );
    end
end

-- Method:          GRM.RemoveFullBackup ( int )
-- What it Does:    Removes the full backup based on the corresponding epochstamp
-- Purpose:         Quality controls. Might need to remove a backup to make room for a new one...
GRM.RemoveFullBackup = function( epochStamp )
    for i = 1 , #GRM_FullBackup_Save do
        if GRM_FullBackup_Save[i][2] == epochStamp then
            table.remove ( GRM_FullBackup_Save , i );
            break;
        end
    end
end


-- Method:          GRM.AddGuildBackup ( string , string , int )
-- What it Does:    Adds a backup point of the given selected guild.
-- Purpose:         Save your database as needed.
GRM.AddGuildBackup = function( guildName , creationDate , factionInd )
    if creationDate ~= GRM.L ( "Unknown" ) then
        local index1;
        local index2;
        local index3;
        if string.find ( guildName , "-" ) ~= nil then
            for i = 2 , #GRM_GuildMemberHistory_Save[factionInd] do
                if GRM_GuildMemberHistory_Save[factionInd][i][1][1] == guildName then
                    index1 = i;
                    for j = 2 , #GRM_GuildDataBackup_Save[factionInd] do
                        if GRM_GuildDataBackup_Save[factionInd][j][1][1] == guildName then
                            index2 = j
                            for s = 2 , #GRM_LogReport_Save[factionInd] do
                                if GRM_LogReport_Save[factionInd][s][1][1] == guildName then
                                    index3 = s;
                                    break;
                                end
                            end
                            break;
                        end
                    end
                    break;
                end
            end
        else
            for i = 2 , #GRM_GuildMemberHistory_Save[factionInd] do
                if GRM_GuildMemberHistory_Save[factionInd][i][1][1] == guildName and GRM_GuildMemberHistory_Save[factionInd][i][1][2] == creationDate then
                    index1 = i;
                    for j = 2 , #GRM_GuildDataBackup_Save[factionInd] do
                        if GRM_GuildDataBackup_Save[factionInd][j][1][1] == guildName and GRM_GuildDataBackup_Save[factionInd][j][1][2] == creationDate then
                            index2 = j

                            for s = 2 , #GRM_LogReport_Save[factionInd] do
                                if GRM_LogReport_Save[factionInd][s][1][1] == guildName and GRM_LogReport_Save[factionInd][s][1][2] == creationDate then
                                    index3 = s;
                                    break;
                                end
                            end
                            break;
                        end
                    end
                    break;
                end
            end
        end

        -- Max 2 backup points of a guild...
        if index1 ~= nil and index2 ~= nil and index3 ~= nil then
            if #GRM_GuildDataBackup_Save[factionInd][index2] <= 4 then -- Saves start at index 2, so 3 saves cap = index 4. 3 and less is ok, meaning 2 saves
                -- Log will have a unique index, so quickly identify location of log..
                
                table.insert ( GRM_GuildDataBackup_Save[factionInd][index2] , { GRM.GetTimestamp() , time() , GRM.DeepCopyArray ( GRM_GuildMemberHistory_Save[factionInd][index1] ) , GRM.DeepCopyArray ( GRM_PlayersThatLeftHistory_Save[factionInd][index1] ) , GRM.DeepCopyArray ( GRM_LogReport_Save[factionInd][index3] ) , GRM.DeepCopyArray ( GRM_CalendarAddQue_Save[factionInd][index1] ) , GRM.DeepCopyArray ( GRM_GuildNotePad_Save[factionInd][index1] ) } );
                GRM.Report ( GRM.L ( "Backup Point Set for Guild \"{name}\"" , guildName ) );
            else
                GRM.Report ( GRM.L ( "To avoid storage bloat, a maximum of 2 guild save points is currently possible. Please remove one before continuing" ) );
                return
            end
        else
            GRM.Report ( GRM.L ( "Unable to properly locate guild for backup" ) );
        end
    else
        GRM.Report ( "GRM: Unable to Create Backup for a Guild With Unknown Creation Date! Log into that guild on any alt to update old database." );
    end
end

-- Method:          GRM.RemoveGuildBackup ( string , string , int , string , boolean )
-- What it Does:    Removes a Backup Point for the guild...
-- Purpose:         Database Backup Management
GRM.RemoveGuildBackup = function( guildName , creationDate , factionInd , backupPoint , reportChange )
    if GRM_G.DebugEnabled then
        GRM.AddDebugMessage ( time() .. "GRM.RemoveGuildBackup()?" .. guildName .. "?" .. creationDate .. "?" .. backupPoint );
    end
    if string.find ( guildName , "-" ) ~= nil then
        for i = 2 , #GRM_GuildDataBackup_Save[factionInd] do
            if type ( GRM_GuildDataBackup_Save[factionInd][i][1] ) == "table" then
                if GRM_GuildDataBackup_Save[factionInd][i][1][1] == guildName then
                    for j = 2 , #GRM_GuildDataBackup_Save[factionInd][i] do
                        if GRM_GuildDataBackup_Save[factionInd][i][j][1] ~= nil and GRM.FormatTimeStamp ( GRM_GuildDataBackup_Save[factionInd][i][j][1] , true ) == backupPoint then
                            if reportChange then
                                GRM.Report ( GRM.L ( "Backup Point Removed for Guild \"{name}\"" , guildName ) );
                            end
                            if string.find ( GRM_GuildDataBackup_Save[factionInd][i][j][1] , "AUTO_" ) ~= nil then
                                GRM_GuildDataBackup_Save[factionInd][i][j] = {};
                            else
                                table.remove ( GRM_GuildDataBackup_Save[factionInd][i] , j );
                            end
                            break;
                        end
                    end
                    break;
                end
            elseif type ( GRM_GuildDataBackup_Save[factionInd][i][1] ) == "string" then
                if GRM_GuildDataBackup_Save[factionInd][i][1] == guildName then
                    for j = 2 , #GRM_GuildDataBackup_Save[factionInd][i] do
                        if GRM_GuildDataBackup_Save[factionInd][i][j][1] ~= nil and GRM.FormatTimeStamp ( GRM_GuildDataBackup_Save[factionInd][i][j][1] , true ) == backupPoint then
                            if reportChange then
                                GRM.Report ( GRM.L ( "Backup Point Removed for Guild \"{name}\"" , guildName ) );
                            end
                            if string.find ( GRM_GuildDataBackup_Save[factionInd][i][j][1] , "AUTO_" ) ~= nil then
                                GRM_GuildDataBackup_Save[factionInd][i][j] = {};
                            else
                                table.remove ( GRM_GuildDataBackup_Save[factionInd][i] , j );
                            end
                            break;
                        end
                    end
                    break;
                end
            end
        end
    else
        for i = 2 , #GRM_GuildDataBackup_Save[factionInd] do
            if type ( GRM_GuildDataBackup_Save[factionInd][i][1] ) == "table" then
                if GRM_GuildDataBackup_Save[factionInd][i][1][1] == guildName and GRM_GuildDataBackup_Save[factionInd][i][1][2] == creationDate then
                    for j = 2 , #GRM_GuildDataBackup_Save[factionInd][i] do
                        if GRM_GuildDataBackup_Save[factionInd][i][j][1] ~= nil and GRM.FormatTimeStamp ( GRM_GuildDataBackup_Save[factionInd][i][j][1] , true ) == backupPoint then
                            if reportChange then
                                GRM.Report ( GRM.L ( "Backup Point Removed for Guild \"{name}\"" , guildName ) );
                            end
                            if string.find ( GRM_GuildDataBackup_Save[factionInd][i][j][1] , "AUTO_" ) ~= nil then
                                GRM_GuildDataBackup_Save[factionInd][i][j] = {};
                            else
                                table.remove ( GRM_GuildDataBackup_Save[factionInd][i] , j );
                            end
                            break;
                        end
                    end
                    break;
                end
            else
                if GRM_GuildDataBackup_Save[factionInd][i][1] == guildName then
                    for j = 2 , #GRM_GuildDataBackup_Save[factionInd][i] do
                        if GRM_GuildDataBackup_Save[factionInd][i][j][1] ~= nil and GRM.FormatTimeStamp ( GRM_GuildDataBackup_Save[factionInd][i][j][1] , true ) == backupPoint then
                            if reportChange then
                                GRM.Report ( GRM.L ( "Backup Point Removed for Guild \"{name}\"" , guildName ) );
                            end
                            if string.find ( GRM_GuildDataBackup_Save[factionInd][i][j][1] , "AUTO_" ) ~= nil then
                                GRM_GuildDataBackup_Save[factionInd][i][j] = {};
                            else
                                table.remove ( GRM_GuildDataBackup_Save[factionInd][i] , j );
                            end
                            break;
                        end
                    end
                    break;
                end
            end
        end
    end
end

-- Method:          GRM.LoadGuildBackup ( string , string , int , string)
-- What it Does:    Restores backup point of a guild
-- Purpose:         Database Backup Management
GRM.LoadGuildBackup = function( guildName , creationDate , factionInd , backupPoint )

    if GRM_G.DebugEnabled then
        GRM.AddDebugMessage ( time() .. "GRM.LoadGuildBackup()?" .. guildName .. "?" .. creationDate .. "?" .. backupPoint );
    end

    local index1;
    local index2;
    local index3;
    local index4;
    if string.find ( guildName , "-" ) ~= nil then
        for i = 2 , #GRM_GuildDataBackup_Save[factionInd] do
            if GRM_GuildDataBackup_Save[factionInd][i][1][1] == guildName then
                index1 = i;
                for j = 2 , #GRM_GuildDataBackup_Save[factionInd][i] do
                    if GRM_GuildDataBackup_Save[factionInd][i][j][1] ~= nil and GRM.FormatTimeStamp ( GRM_GuildDataBackup_Save[factionInd][i][j][1] , true ) == backupPoint then
                        index2 = j;
                        -- Now, let's find the database point to replace...
                        for s = 2 , #GRM_GuildMemberHistory_Save[factionInd] do
                            if GRM_GuildMemberHistory_Save[factionInd][s][1][1] == guildName then
                                index3 = s;
                            end
                        end
                        -- Also need to find guild Log database point as it will not match the index...
                        for k = 2 , #GRM_LogReport_Save[factionInd] do
                            if GRM_LogReport_Save[factionInd][k][1][1] == guildName then
                                index4 = k;
                                break;
                            end
                        end
                        break;
                    end
                end
                break;
            end
        end
    else
        for i = 2 , #GRM_GuildDataBackup_Save[factionInd] do
            if GRM_GuildDataBackup_Save[factionInd][i][1][1] == guildName and GRM_GuildDataBackup_Save[factionInd][i][1][2] == creationDate then
                index1 = i;
                for j = 2 , #GRM_GuildDataBackup_Save[factionInd][i] do
                    if GRM_GuildDataBackup_Save[factionInd][i][j][1] ~= nil and GRM.FormatTimeStamp ( GRM_GuildDataBackup_Save[factionInd][i][j][1] , true ) == backupPoint then
                        index2 = j;
                        -- Now, let's find the database point to replace...
                        for s = 2 , #GRM_GuildMemberHistory_Save[factionInd] do
                            if GRM_GuildMemberHistory_Save[factionInd][s][1][1] == guildName and GRM_GuildMemberHistory_Save[factionInd][s][1][2] == creationDate then
                                index3 = s;
                                break;
                            end
                        end
                        -- Also need to find guild Log database point as it will not match the index...
                        for k = 2 , #GRM_LogReport_Save[factionInd] do
                            if GRM_LogReport_Save[factionInd][k][1][1] == guildName and GRM_LogReport_Save[factionInd][k][1][2] == creationDate then
                                index4 = k;
                                break;
                            end
                        end
                        break;
                    end
                end
                break;
            end
        end
    end
    if index1 ~= nil and index2 ~= nil and index3 ~= nil and index4 ~= nil then
        -- Updating to save data...
        GRM_GuildMemberHistory_Save[factionInd][index3] = GRM.DeepCopyArray ( GRM_GuildDataBackup_Save[factionInd][index1][index2][3] );
        GRM_PlayersThatLeftHistory_Save[factionInd][index3] = GRM.DeepCopyArray ( GRM_GuildDataBackup_Save[factionInd][index1][index2][4] );
        GRM_CalendarAddQue_Save[factionInd][index3] = GRM.DeepCopyArray ( GRM_GuildDataBackup_Save[factionInd][index1][index2][6] );
        GRM_GuildNotePad_Save[factionInd][index3] = GRM.DeepCopyArray ( GRM_GuildDataBackup_Save[factionInd][index1][index2][7] );
        GRM_LogReport_Save[factionInd][index4] = GRM.DeepCopyArray ( GRM_GuildDataBackup_Save[factionInd][index1][index2][5] );

        GRM.Report ( GRM.L ( "Backup Point Restored for Guild \"{name}\"" , guildName ) );
        if GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
            if GRM_UI.GRM_MemberDetailMetaData.GRM_SetUnknownButton:IsVisible() or GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:IsVisible() or GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:IsVisible() then
                GRM.ClearAllFrames( false );
            end
            GRM.PopulateMemberDetails ( GRM_G.currentName );
        end

        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetText ( "" );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetText ( GRM.L ( "Search Filter" ) );  -- By clearing it and restoring it, it triggers the build log action
        
        GRM_G.changeHappenedExitScan = true;
    end
end

-- Method:          GRM.ResetAllBackups()
-- What it Does:    Wipes all backup data, but then reinitializes an index for each guild
-- Purpose:         For managing the database of guild backups
GRM.ResetAllBackups = function()
    -- Reset the backup data in case any player was messing around with it...
    GRM_GuildDataBackup_Save = nil;
    GRM_GuildDataBackup_Save = {};
    GRM_GuildDataBackup_Save = { { "Horde" } , { "Alliance" } };
    GRM_FullBackup_Save = nil;
    GRM_FullBackup_Save = {};
    -- Let's go through all the guilds!
    for i = 1 , #GRM_GuildMemberHistory_Save do
        for j = 2 , #GRM_GuildMemberHistory_Save[i] do
            table.insert ( GRM_GuildDataBackup_Save[i] , { GRM_GuildMemberHistory_Save[i][j][1] , {} , {} } );
        end
    end
end

-- Method:          GRM.GetNumGuildiesInGuild ( string , string )
-- What it Does:    Returns the number of current guildies there are
-- Purpose:         For accurate reporting on most recent current snapshot of a guild.
GRM.GetNumGuildiesInGuild = function ( name , creationDate )
    local result = 0;
    for i = 1 , #GRM_GuildMemberHistory_Save do
        for j = 2 , #GRM_GuildMemberHistory_Save[i] do
            if type ( GRM_GuildMemberHistory_Save[i][j][1] ) == "table" and string.find ( GRM_GuildMemberHistory_Save[i][j][1][1] , "-" ) ~= nil then
                if GRM_GuildMemberHistory_Save[i][j][1][1] == name then
                    result = #GRM_GuildMemberHistory_Save[i][j] - 1;  -- Minus 1 because index 1 is just the name/creation date array...
                    break;
                end
            else
                if creationDate ~= nil then
                    if GRM_GuildMemberHistory_Save[i][j][1][1] == name then
                        result = #GRM_GuildMemberHistory_Save[i][j] - 1;  -- Minus 1 because index 1 is just the name/creation date array...
                        break;
                    end
                else
                    if GRM_GuildMemberHistory_Save[i][j][1] == name then
                        result = #GRM_GuildMemberHistory_Save[i][j] - 1;  -- Minus 1 because index 1 is just the name/creation date array...
                        break;
                    end
                end
            end
        end
    end
    return result;
end


-- Method:          GRM.AutoSetBackup()
-- What it Does:    Checks every guild in the game you have saved and sets an Auto
-- Purpose:         To help the user protect their data, an autobackup point is set...
GRM.AutoSetBackup = function()
    local needsAutoBackup = false;
    -- Ability to Enable Auto-Save function...
    -- First, determine if backup has been auto-saved already by identifying last save point.
    for i = 1 , #GRM_GuildDataBackup_Save do    -- For each faction
        for j = 2 , #GRM_GuildDataBackup_Save[i] do
            needsAutoBackup = false;
            if #GRM_GuildDataBackup_Save[i][j][2] == 0 then
                -- No autoSave as of yet... Create Auto-Save
                needsAutoBackup = true;
            else
                -- There already is one backup, let's look at the most recent backup date...
                if time() - GRM_GuildDataBackup_Save[i][j][2][2] > ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][41] * 86400 ) then
                    -- Confirmed... need to set backup
                    needsAutoBackup = true;
                end

            end

            if needsAutoBackup then
                -- Now, let's save it...
                local index1 = -1;
                local index2 = -1
                for s = 2 , #GRM_GuildMemberHistory_Save[i] do
                    if type ( GRM_GuildDataBackup_Save[i][j][1] ) == "table" and string.find ( GRM_GuildDataBackup_Save[i][j][1][1] , "-" ) ~= nil then

                        if GRM_GuildMemberHistory_Save[i][s][1][1] == GRM_GuildDataBackup_Save[i][j][1][1] then
                            index1 = s;
                            -- Guild found...
                            for k = 2 , #GRM_LogReport_Save[i] do
                                if GRM_LogReport_Save[i][k][1][1] == GRM_GuildDataBackup_Save[i][j][1][1] then
                                    index2 = k;
                                    break;
                                end
                            end
                        end
                    else
                        if GRM_GuildMemberHistory_Save[i][s][1][1] == GRM_GuildDataBackup_Save[i][j][1][1] and GRM_GuildMemberHistory_Save[i][s][1][2] == GRM_GuildDataBackup_Save[i][j][1][2] then
                            index1 = s;
                            -- Guild found...
                            for k = 2 , #GRM_LogReport_Save[i] do
                                if GRM_LogReport_Save[i][k][1][1] == GRM_GuildDataBackup_Save[i][j][1][1] and GRM_LogReport_Save[i][k][1][2] == GRM_GuildDataBackup_Save[i][j][1][2] then
                                    index2 = k;
                                    break;
                                end
                            end
                        end
                    end

                    -- Move the data up, save over old info if necessary
                    if index1 > -1 and index2 > -1 then
                        GRM_GuildDataBackup_Save[i][j][3] = GRM_GuildDataBackup_Save[i][j][2];

                        -- Set the new info...
                        GRM_GuildDataBackup_Save[i][j][2] = { "AUTO_" .. GRM.GetTimestamp() , time() , GRM.DeepCopyArray ( GRM_GuildMemberHistory_Save[i][index1] ) , GRM.DeepCopyArray ( GRM_PlayersThatLeftHistory_Save[i][index1] ) , GRM.DeepCopyArray ( GRM_LogReport_Save[i][index2] ) , GRM.DeepCopyArray ( GRM_CalendarAddQue_Save[i][index1] ) , GRM.DeepCopyArray ( GRM_GuildNotePad_Save[i][index1] ) };
                        break;
                    end
                end
            end
        end
    end
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame:IsVisible() then
        GRM.BuildBackupScrollFrame( GRM_G.selectedFID );
    end
end


-- Method:          GRM.GetNumberOfProfilesInGuild ( string , string )
-- What it does:    Returns an array with 2 indexes, the first being the number of current players in the guild and how many profiles saved, and the second,
--                  the number of players profiles' saved that are no longer in the guild or were added to a ban list for the guild.
-- Purpose:         For backup and save data management, it is good to know.
GRM.GetNumberOfProfilesInGuild = function ( guildName , faction )
    local isFound = false;
    local fIndex = 1;
    if faction == "Alliance" then
        fIndex = 2;
    end
    local result = {};
    for j = 2 , #GRM_GuildMemberHistory_Save[fIndex] do
        if GRM_GuildMemberHistory_Save[fIndex][j][1][1] == guildName then
            table.insert ( result , #GRM_GuildMemberHistory_Save[fIndex][j] - 1 ) -- Minus 1 because no need to include the guild name... the coutn starts at 2.
            isFound = true;
            break;
        end
    end

    -- no need to look up other data if the first is not found...
    if isFound then
        for j = 2 , #GRM_PlayersThatLeftHistory_Save[fIndex] do
            if GRM_PlayersThatLeftHistory_Save[fIndex][j][1][1] == guildName then
                table.insert ( result , #GRM_PlayersThatLeftHistory_Save[fIndex][j] - 1 ) -- Minus 1 because no need to include the guild name... the coutn starts at 2.
                break;
            end
        end
    else
       GRM.Report ( GRM.L ( "Error: Guild Not Found..." ) );
    end
    return result;
end

-- Method:          GRM.GetTotalNumberOfSavedProfilesAccountWide()
-- What it Does:   Returns the total number of saved character profiles for all guilds account wide.
-- Purpose:         To give a rough context on how much data is being used...
GRM.GetTotalNumberOfSavedProfilesAccountWide = function ()
    local result = 0;
    for i = 1 , #GRM_GuildMemberHistory_Save do
        for j = 2 , #GRM_GuildMemberHistory_Save[i] do
            result = result + #GRM_GuildMemberHistory_Save[i][j] - 1;
        end
    end
    for i = 1 , #GRM_PlayersThatLeftHistory_Save do
        for j = 2 , #GRM_PlayersThatLeftHistory_Save[i] do
            result = result + #GRM_PlayersThatLeftHistory_Save[i][j] - 1;
        end
    end
    return result;
end


-- GRM.IsMoreThanOneGuildWithSameName = function()
--     local result = false;
--     for i = 1 , #GRM_GuildMemberHistory_Save do
--         -- Check individually for each faction

--     end
-- end

-- Method:          GRM.IsMergedRealmServer()
-- What it Does:    Returns true if the player is currently on a merged realm server
-- Purpose:         Useful to know in certain circumstances, like not relying on the guild name alone to identify guild home.
GRM.IsMergedRealmServer = function()
    QueryGuildEventLog();
    if GetNumGuildEvents() == 0 then
        return nil;
    end
    local result = false;
    for i = 1 , GetNumGuildEvents() do
        local _ , p1 = GetGuildEventInfo ( 1 );
        if p1 ~= nil and string.find ( p1 , "-" ) ~= nil then
            result = true;
            break;
        end
    end
    return result
end

-- Method:          GRM.PurgeGuildFromDatabase(string,string)
-- What it Does:    Completely purges a guild from the player database... that it is not currently logged into
-- Purpose:         Cleanup old guild data from a guild the player is no longer a part of.
GRM.PurgeGuildFromDatabase = function ( guildName , creationDate , faction )
    if guildName == GRM_G.guildName or guildName == GRM.SlimName ( GRM_G.guildName ) then
        GRM.Report ( "\n" .. GRM.L ( "Player Cannot Purge the Guild Data they are Currently In!!!" ) .. "\n" .. GRM.L( "To reset your current guild data type '/grm clearguild'" ) );
    else
        local isFound = false;
        local guildIndex = 0;
        local fIndex = 1;
        if faction == "Alliance" then
            fIndex = 2;
        end
        for j = 2 , #GRM_GuildMemberHistory_Save[fIndex] do
            if GRM.OrigL ( creationDate ) == "Unknown" and GRM_GuildMemberHistory_Save[fIndex][j][1] == guildName then
                guildIndex = j;
                isFound = true;
                break;
            elseif GRM_GuildMemberHistory_Save[fIndex][j][1][1] == guildName then
                guildIndex = j;
                isFound = true;
                break;
            end
        end
        if isFound then
            table.remove ( GRM_GuildMemberHistory_Save[fIndex] , guildIndex );
            table.remove ( GRM_PlayersThatLeftHistory_Save[fIndex] , guildIndex );
            table.remove ( GRM_CalendarAddQue_Save[fIndex] , guildIndex );
            table.remove ( GRM_GuildNotePad_Save[fIndex] , guildIndex );

            -- log may have a unique index for reasons ;)
            for i = 2 , #GRM_LogReport_Save[fIndex] do
                if GRM.OrigL ( creationDate ) == "Unknown" and GRM_LogReport_Save[fIndex][i][1] == guildName then
                    table.remove ( GRM_LogReport_Save[fIndex] , i );
                    break;
                elseif GRM_LogReport_Save[fIndex][i][1][1] == guildName then
                    table.remove ( GRM_LogReport_Save[fIndex] , i );
                    break;
                end
            end

            -- remove the saved data if any exists as well
            for i = 2 , #GRM_GuildDataBackup_Save[fIndex] do
                if GRM.OrigL ( creationDate ) == "Unknown" and GRM_GuildDataBackup_Save[fIndex][i][1] == guildName then
                    table.remove ( GRM_GuildDataBackup_Save[fIndex] , i );
                    break;
                elseif GRM_GuildDataBackup_Save[fIndex][i][1][1] == guildName then
                    table.remove ( GRM_GuildDataBackup_Save[fIndex] , i );
                    break;
                end
            end
            GRM.Report ( GRM.L ( "{name} has been removed from the database." , guildName ) );

        else
            local removed = false;
            -- remove the saved data if any exists as well
            -- Do a purge of the guild regardless, if it's showing up here, it means it's get lingering bad data.
            for i = 2 , #GRM_GuildDataBackup_Save[fIndex] do
                if GRM.OrigL ( creationDate ) == "Unknown" and GRM_GuildDataBackup_Save[fIndex][i][1] == guildName then
                    table.remove ( GRM_GuildDataBackup_Save[fIndex] , i );
                    removed = true;
                    break;
                elseif GRM_GuildDataBackup_Save[fIndex][i][1][1] == guildName then
                    table.remove ( GRM_GuildDataBackup_Save[fIndex] , i );
                    removed = true;
                    break;
                end
            end
            
            if not removed then
                GRM.Report ( GRM.L ( "Error: Guild Not Found..." ) );
            else
                GRM.Report ( GRM.L ( "{name} has been removed from the database." , guildName ) );
            end
        end
    end
end

-- Method:          GRM.GetClickedStringFromBackupFrameDetails()
-- What it Does:    Returns the text string of the guild name and creation date of the given mouseover frame on the backup window.
-- Purpose:         Useful for mouseover options as well as the rightClick option.
GRM.GetClickedStringFromBackupFrameDetails = function ()
    local frameList = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons;
    if frameList ~= nil then
        local guildName = "";
        local creationDate = "";
        local frameIndex = -1
        for i = 1 , #frameList do
            if frameList[i][1]:IsMouseOver ( 2 , -2 , -2 , 2 ) or frameList[i][2]:IsMouseOver ( 2 , -2 , -2 , 2 ) or frameList[i][3]:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                guildName = string.gsub ( frameList[i][1]:GetText() , "\"" , "" );
                creationDate = frameList[i][2]:GetText();
                frameIndex = i;
                break;
            end
        end

        if guildName ~= "" then
            GRM_G.BackupFrameSelectDetails = { frameIndex , guildName , creationDate };
            return true;
        else
            return false;
        end
    else
        return false;
    end
end

-- Method:          GRM.BuildBackupFrameTooltip( frame , int )
-- What it Does:    Based on the mouseover position of the backup window frame, builds a tooltip based on what it is currently over
-- Purpose:         Quality of life UX experience, as well as a helpful piece of information for the player to know they can right click to purge the guild from the database
GRM.BuildBackupFrameTooltip = function( _ , elapsed )
    GRM_G.backupTimer = GRM_G.backupTimer + elapsed;
    if GRM_G.backupTimer > 0.1 then
        if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption:IsVisible() then
            if GRM.GetClickedStringFromBackupFrameDetails() then
                if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption:IsVisible() then
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_GuildNameTooltip:SetOwner( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[GRM_G.BackupFrameSelectDetails[1]][1] , "ANCHOR_CURSOR" );
                    if GRM_G.selectedFID == 1 then
                        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_GuildNameTooltip:AddLine ( GRM_G.BackupFrameSelectDetails[2] , 0.61 , 0.14 , 0.137 );
                    elseif GRM_G.selectedFID == 2 then
                        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_GuildNameTooltip:AddLine ( GRM_G.BackupFrameSelectDetails[2] , 0.078 , 0.34 , 0.73 );
                    end
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_GuildNameTooltip:AddLine ( GRM.L ( "Right-Click for options to remove this guild from the addon database completely" ) , 1 , 0.84 , 0 , true );
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_GuildNameTooltip:Show();
                end
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_GuildNameTooltip:Hide();
            end
        else
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_GuildNameTooltip:Hide();
        end
        GRM_G.backupTimer = 0;
    end
end


--------------------------------------
-------- DEBUGGING -------------------
--------------------------------------

-- Method:          GRM.DebugLog ( int )
-- What it Does:    Prints out the Debug Log the last X number of items that occurred before logging off or disconnecting.
-- Purpose:         Occasionally disconnects happen. This will let me know what happened!
GRM.DebugLog = function ( numToShow )
    local index;
    if numToShow < 0 or #GRM_G.DebugLog - numToShow < 0 then
        index = 0;
        numToShow = #GRM_G.DebugLog;
    else
        index = #GRM_G.DebugLog - numToShow;
    end

    GRM.Report ( string.upper ( GRM.L ( "Debugger Start" )  .. ": " .. numToShow .. "/" .. #GRM_G.DebugLog ) );
    for i = index + 1 , #GRM_G.DebugLog do
        GRM.Report( GRM_G.DebugLog[i] );
    end
end

-- Method:          GRM.AddDebugMessage ( string )
-- What it Does:    Addes messages of recent events to debug log...
-- Purpose:         Debugging tracking
GRM.AddDebugMessage = function ( msg )
    -- To prevent too large of a debug log...
    if msg == "" then
        msg = "Empty Msg";
    end
    if #GRM_G.DebugLog < 250 then
        table.insert ( GRM_G.DebugLog , time() .. ": " .. msg );
    else
        local tempLog = {};
        for i = #GRM_G.DebugLog - 50 , #GRM_G.DebugLog do
            table.insert ( tempLog , time() .. ": " .. GRM_G.DebugLog[i] );
        end
        GRM_G.DebugLog = tempLog;
        table.insert ( GRM_G.DebugLog , msg );
    end
end

--------------------------------------
------ GROUP METHODS AND LOGIC -------
--------------------------------------

-- Method:          GRM.GetClubEpochJoinTime ( int )
-- What it Does:    Returns the epoch stamp of when a player joined a guild or community
-- Prupose:         Useful to know exact date...
GRM.GetClubEpochJoinTime = function ( clubID )
    local info = C_Club.GetClubInfo ( clubID );
    local result = -1;
    if info then
        result = tonumber ( string.gsub ( string.sub ( tostring ( info.joinTime ) , 1 , 10 ) , "%." , "" ) .. "1" );
    end
    return result;
end

-- Method:          GRM.GetSelectedClubID()
-- What it Does:    
GRM.GetSelectedClubID = function()
    return CommunitiesFrame:GetSelectedClubId();
end

-- Method:          GRM.GetFullNameClubMember ( guid(as string) )
-- What it Does:    Appends the server to the end of the player name properly...
-- Purpose:         To append the full player name properly since it is not given by default
GRM.GetFullNameClubMember = function( memberGUID )
    local name = select ( 6 , GetPlayerInfoByGUID ( memberGUID ) ) ;
    local realm = select ( 7 , GetPlayerInfoByGUID ( memberGUID ) ) ;
    local result = "";
    if name ~= nil then
        if realm == "" then
            result = name .. "-" .. GRM_G.realmName;
        else
            result = name .. "-" .. realm;
        end
    end
    return result;
end

-- Method:          GRM.GetNumGuildies()
-- What it Does:    Returns the int number of total toons within the guild, including main/alts
-- Purpose:         For book-keeping and tracking total guild membership.
--                  Overall, this is mostly redundant as a simple GetNumGuildMembers() call is the same thing, however, this is just a tech Demo
--                  as a coding example of how to pull info and return it in your own function.
--                  A simple "GetNumGuildMembers()" would result in the same result in less steps. This is just more explicit to keep it within the style of the functions of the addon.
GRM.GetNumGuildies = function()
    return GetNumGuildMembers();
end

-- Method:          GRM.GetNumMains()
-- What it Does:    Returns the total number of players designated as "Main" in the guild
-- Purpose:         Mainly for audit log stat reporting.  
GRM.GetNumMains = function()
    local count = 0;
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][10] then
            count = count + 1;
        end
    end
    return count;
end

-- Method:          GRM.SetSystemMessageFilter ( self , string , string )
-- What it Does:    Starts tracking the system messages for filtering. This is only triggered on the audit frame initialization or if a player has left the guild
-- Purpose:         To control system message spam when doing server inquiries
GRM.SetSystemMessageFilter = function ( _ , _ , msg )
    local result = false;
    if time() - GRM_G.IsOnLogonDelay > 1 then
        -- GUILD INFO FILTER (GuildInfo())
        if ( GRM_G.MsgFilterDelay and ( string.find ( msg , GRM.L ( "Guild: " ) ) ~= nil or string.find ( msg , GRM.L ( "Guild created " ) ) ~= nil ) ) then       -- These may need to be localized. I have not yet tested if other regions return same info. It IS system info.
            if string.find ( msg , GRM.L ( "Guild created " ) ) ~= nil then
                -- Determine number of Unique Accounts
                local tempString = "";
                if GRM_G.Region == "ruRU" then
                    tempString = string.sub ( msg , string.find ( msg , ":" , -10 ) + 2 , #msg );
                elseif GRM_G.Region == "zhTW" or GRM_G.Region == "zhCN" then
                    tempString = string.sub ( msg , string.find ( msg , "，" , -15 ) + 1 , #msg );
                else
                    tempString = string.sub ( msg , string.find ( msg , "," , -20 ) + 2 , #msg );         -- to keep the code more readable I am keeping this initial parse separate.
                end
                -- Cleans up a little for localization
                while tonumber ( string.sub ( tempString , 1 , 1 ) ) == nil do
                    tempString = string.sub ( tempString , 2 );
                end
                for i = 1 , #tempString do
                    if tonumber ( string.sub ( tempString , i , i ) ) == nil then
                        local numUniqueAccounts = tonumber ( string.sub ( tempString , 1 , i - 1 ) );
                        -- For auto-main tagging... detect the change here!
                        if numUniqueAccounts > GRM_G.numAccounts and GRM_G.numAccounts ~= 0 then
                            GRM_G.DesignateMain = true;
                            C_Timer.After ( 12 , function()
                                GRM_G.DesignateMain = false;
                            end);
                        end
                        GRM_G.numAccounts = numUniqueAccounts;
                        break;
                    end
                end
                -- Determine Guild Creation Date
                local count = 0;
                local index = 0;
                local index2 = 0;
                local tempDate = "";
                -- This just saves on resources than re-parsing each pass
                for i = 1 , #msg do
                    if string.sub ( msg , i , i ) == "-" or string.sub ( msg , i , i ) == "." then
                        count = count + 1;
                        if count == 1 then
                            index = i;
                        end
                    end
                    if count == 2 then
                        index2 = i;
                        break;
                    end
                end
                if string.find ( msg , "-" ) ~= nil then
                    if GRM_G.Region == "enUS" or GRM_G.Region == "enGB" or GRM_G.Region == "itIT" or GRM_G.Region == "ptBR" or GRM_G.Region == "ruRU" then
                        -- Let's fix the English formatting
                        tempDate = string.sub ( msg , index + 1 , index2 - 1 ) .. "-" .. GRM.Trim ( string.sub ( msg , index - 2 , index - 1 ) ) .. "-" .. string.sub ( msg , index2 + 1 , index2 + 4 );
                    else
                        tempDate = GRM.Trim ( string.sub ( msg , index - 2 , index2 + 4 ) );
                    end
                elseif string.find ( msg , "%." ) ~= nil then
                    
                    -- Now, let's reformat it to reflect all other 10 clients...
                    tempDate = string.gsub ( GRM.Trim ( string.sub ( msg , index - 2 , index2 + 4 ) ) , "%." , "-" );
                end
                if GRM_G.guildCreationDate ~= "" and tempDate ~= GRM_G.guildCreationDate then
                    -- This means the wrong date was set and this is re-changing it.
                    GRM_G.changeHappenedExitScan = true;
                end
                GRM_G.guildCreationDate = tempDate;
            end
            result = true;
        -- Player Not Found when trying to add to friends list message
        elseif ( GRM_G.MsgFilterDelay or GRM_G.MsgFilterDelay2 ) and ( msg == GRM.L ( "Player not found." ) or string.find ( msg , GRM.L ( "added to friends" ) ) ~= nil or string.find ( msg , GRM.L ( "is already your friend" ) ) ~= nil ) then
            result = true;
        else
            result = false;
        end
    else
        result = true;
    end
    return result;
end

-- Method:          GRM.SetGuildInfoDetails()
-- Purpose:         Calls the server info on the guild and parses out the number of exact unique accounts are in the guild. It also filters the chat msg to avoid chat spam, then unfilters it immediately after
--                  as a Quality of Life feature so the user can manually continue to call as needed.
-- Purpose:         It is useful information to know how many unique acocunts are in the guild. This particularly is useful when comparing how many "mains" there 
--                  are on the audit window...
GRM.SetGuildInfoDetails = function()
    GRM_G.MsgFilterDelay = true;         -- Resets the 1 second timer upon calling this method for the chat spam blocking. This ensures player manual calls are visual, but code calls are filtered.
    if not GRM_G.MsgFilterEnabled then   -- Gate to ensure this only is registered one time. This is also controlled here so as to not waste resources by being called needlessly if player never checks audit window
        GRM_G.MsgFilterEnabled = true;   -- Establishing boolean gate so it is only registered once.
        ChatFrame_AddMessageEventFilter ( "CHAT_MSG_SYSTEM" , GRM.SetSystemMessageFilter );
    end
    GuildInfo();
    -- This should only be blocked momentarily.
    C_Timer.After ( 1 , function()
        GRM_G.MsgFilterDelay = false;
    end);
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
    if not CommunitiesFrame or not CommunitiesFrame:IsVisible() then
        GuildRoster();
    end
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

-- Method:          GRM.GetAllGuildiesInOrder ( boolean )
-- What it Does:    Returns a sorted string array of all guildies
-- Purpose:         Useful to have an alphabetized list of guildies :)
GRM.GetAllGuildiesInOrder = function( fullNameNeeded , fromAtoZ )
    if not CommunitiesFrame or not CommunitiesFrame:IsVisible() then
        GuildRoster();
    end
    local listOfGuildies = {};
    for i = 1 , GRM.GetNumGuildies() do
        local name = GetGuildRosterInfo ( i );
        if not fullNameNeeded then
            table.insert ( listOfGuildies , GRM.SlimName ( name) );
        else
            table.insert ( listOfGuildies , name );
        end
    end
    sort( listOfGuildies );
    if not fromAtoZ then
        local tempList = {};
        for i = #listOfGuildies , 1 , -1 do
            table.insert ( tempList , listOfGuildies[i] );
        end
        listOfGuildies = tempList;
    end
    return listOfGuildies;
end

-- Method:          GRM.GetAllGuildiesInJoinDateOrder ( boolean , boolean )
-- What it Does:    Returns a sorted string array of all guildies in either ascending or descending order of when they joined the guild.
-- Purpose:         For sorting the audit window and keeping track of guildies...
GRM.GetAllGuildiesInJoinDateOrder = function ( fullNameNeeded , newFirst )
    if not CommunitiesFrame or not CommunitiesFrame:IsVisible() then
        GuildRoster();
    end
    local result = {};
    local listOfGuildiesWithDates = {};
    local listOfGuildiesWithUnknownDates = {};

    local tempGuild = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    for i = 2 , #tempGuild do
        if #tempGuild[i][20] > 0 then
            -- find a proper place to sort
            if #listOfGuildiesWithDates == 0 then                               -- the first one can be a straight insert
                table.insert ( listOfGuildiesWithDates , { tempGuild[i][1] , tempGuild[i][21][#tempGuild[i][21]] } );
            else
                -- parse through the dates, new First... (number will be larger)
                local j = 1;
                while j <= #listOfGuildiesWithDates and tempGuild[i][21][#tempGuild[i][21]] < listOfGuildiesWithDates[j][2] do
                    j = j + 1;
                end
                if j == #listOfGuildiesWithDates + 1 then
                    table.insert ( listOfGuildiesWithDates , { tempGuild[i][1] , tempGuild[i][21][#tempGuild[i][21]] } );
                else
                    table.insert ( listOfGuildiesWithDates , j , { tempGuild[i][1] , tempGuild[i][21][#tempGuild[i][21]] } );
                end
            end
        else
            table.insert ( listOfGuildiesWithUnknownDates , tempGuild[i][1] );
        end
    end

    -- Sort the unknowns to be added at the end
    sort ( listOfGuildiesWithUnknownDates );

    if not newFirst then
        -- need to reverse
        for i = #listOfGuildiesWithDates , 1 , -1 do
            if fullNameNeeded then
                table.insert ( result , listOfGuildiesWithDates[i][1] );
            else
                table.insert ( result , GRM.SlimName ( listOfGuildiesWithDates[i][1] ) );
            end
        end
    else
        for i = 1 , #listOfGuildiesWithDates do
            if fullNameNeeded then
                table.insert ( result , listOfGuildiesWithDates[i][1] );
            else
                table.insert ( result , GRM.SlimName ( listOfGuildiesWithDates[i][1] ) );
            end
        end
    end
    
    -- let's add the sorted unknowns to the end now as well.
    for i = 1 , #listOfGuildiesWithUnknownDates do
        if fullNameNeeded then
            table.insert ( result , listOfGuildiesWithUnknownDates[i] );
        else
            table.insert ( result , GRM.SlimName ( listOfGuildiesWithUnknownDates[i] ) );
        end
    end
    return result;
end

-- Method:          GRM.GetAllGuildiesInPromoDateOrder ( boolean , boolean )
-- What it Does:    Returns a sorted string array of all guildies in either ascending or descending order of when they were promoted last in the guild.
-- Purpose:         For sorting the audit window and keeping track of guildies...
GRM.GetAllGuildiesInPromoDateOrder = function ( fullNameNeeded , newFirst )
    if not CommunitiesFrame or not CommunitiesFrame:IsVisible() then
        GuildRoster();
    end
    local result = {};
    local listOfGuildiesWithDates = {};
    local listOfGuildiesWithUnknownDates = {};

    local tempGuild = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    for i = 2 , #tempGuild do
        if tempGuild[i][12] ~= nil then
            -- find a proper place to sort
            if #listOfGuildiesWithDates == 0 then                               -- the first one can be a straight insert
                table.insert ( listOfGuildiesWithDates , { tempGuild[i][1] , tempGuild[i][25][#tempGuild[i][25]][3] } );
            else
                -- parse through the dates, new First... (number will be larger)
                local j = 1;
                while j <= #listOfGuildiesWithDates and tempGuild[i][25][#tempGuild[i][25]][3] < listOfGuildiesWithDates[j][2] do
                    j = j + 1;
                end
                if j == #listOfGuildiesWithDates + 1 then
                    table.insert ( listOfGuildiesWithDates , { tempGuild[i][1] , tempGuild[i][25][#tempGuild[i][25]][3] } );
                else
                    table.insert ( listOfGuildiesWithDates , j , { tempGuild[i][1] , tempGuild[i][25][#tempGuild[i][25]][3] } );
                end
            end
        else
            table.insert ( listOfGuildiesWithUnknownDates , tempGuild[i][1] );
        end
    end

    -- Sort the unknowns to be added at the end
    sort ( listOfGuildiesWithUnknownDates );

    if not newFirst then
        -- need to reverse
        for i = #listOfGuildiesWithDates , 1 , -1 do
            if fullNameNeeded then
                table.insert ( result , listOfGuildiesWithDates[i][1] );
            else
                table.insert ( result , GRM.SlimName ( listOfGuildiesWithDates[i][1] ) );
            end
        end
    else
        for i = 1 , #listOfGuildiesWithDates do
            if fullNameNeeded then
                table.insert ( result , listOfGuildiesWithDates[i][1] );
            else
                table.insert ( result , GRM.SlimName ( listOfGuildiesWithDates[i][1] ) );
            end
        end
    end
    
    -- let's add the sorted unknowns to the end now as well.
    for i = 1 , #listOfGuildiesWithUnknownDates do
        if fullNameNeeded then
            table.insert ( result , listOfGuildiesWithUnknownDates[i] );
        else
            table.insert ( result , GRM.SlimName ( listOfGuildiesWithUnknownDates[i] ) );
        end
    end
    return result;
end

-- Method:          GRM.GetAllMainsAndAltsInOrder ( boolean , boolean )
-- What it Does:    Returns the guild roster sorted with either mains first or alts alphebatized, then alphabetizes the rest.
-- Purpose:         Auditing the roster and sorting!
GRM.GetAllMainsAndAltsInOrder = function ( fullNameNeeded , mainsFirst )
    if not CommunitiesFrame or not CommunitiesFrame:IsVisible() then
        GuildRoster();
    end
    local result = {};
    local listOfMains = {};
    local listOfAlts = {};
    local listOfNeither = {};

    local tempGuild = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];

    for i = 2 , #tempGuild do
        if tempGuild[i][10] then
            table.insert ( listOfMains , tempGuild[i][1] );     -- Can just add if main.
        elseif #tempGuild[i][11] > 0 then                       -- if not main, but you do have alts, scan through the alts to see if they are a main.
            local mainFound = false;
            for j = 1 , #tempGuild[i][11] do
                if tempGuild[i][11][j][5] then
                    mainFound = true;
                    break;
                end
            end
            if mainFound then
                table.insert ( listOfAlts , tempGuild[i][1] );
            else
                table.insert ( listOfNeither , tempGuild[i][1] );
            end
        else
            table.insert ( listOfNeither , tempGuild[i][1] );
        end
    end

    sort ( listOfMains );
    sort ( listOfAlts );
    sort ( listOfNeither );

    -- Combine the tables...
    if mainsFirst then
        result = listOfMains;
        for i = 1 , #listOfAlts do
            table.insert ( result , listOfAlts[i] );
        end
    else
        result = listOfAlts;
        for i = 1 , #listOfMains do
            table.insert ( result , listOfMains[i] );
        end
    end

    for i = 1 , #listOfNeither do
        table.insert ( result , listOfNeither[i] );
    end
    return result;
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
    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] ~= nil then
        for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == name then
                result = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][5];
                break;
            end
        end
    end
    return result;
end


-- DEPRACATED PATCH 7.3 - NO LONGER USEFUL
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
-- What it Does:    Initiates attempt to determine player has access to proper channel
-- Purpose:         If guild chat channel is restricted then sync cannot be enabled either...
GRM.RegisterGuildChatPermission = function()
    GRMsync.SendMessage ( "GRM_GCHAT" , "" , "SLASH_CMD_GUILD" );
    GRMsync.SendMessage ( "GRM_GCHAT" , "" , "SLASH_CMD_OFFICER");
end


-- Method:          GRM.AddPlayerOnlineStatusCheck ( string )
-- What it Does:    Adds a player to the status check, to notify when they come Online!
-- Purpose:         Active tracking of changes within the guild on player status. Easy to notify you when someone comes online!
GRM.AddPlayerStatusCheck = function ( name , checkIndex )
    local isFound = false;
    local tempRosterList = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    for i = 1 , #GRM_G.ActiveStatusQue do
        if name == GRM_G.ActiveStatusQue[i][1] and checkIndex == GRM_G.ActiveStatusQue[i][3] then
            isFound = true;
            break;
        end
    end

    -- Good, the notification has not already been set...
    if not isFound then
        for i = 2 , #tempRosterList do
            if tempRosterList[i][1] == name then
                table.insert ( GRM_G.ActiveStatusQue , { name , tempRosterList[i][33] , checkIndex } );
                -- Return from AFK
                if checkIndex == 1 then
                    chat:AddMessage ( "|cffff0000" .. GRM.L ( "Notification Set:" ) .. " |r" .. GRM.L ( "Report When {name} is ACTIVE Again!" , GRM.SlimName ( name ) ) );
                -- Return from Offline
                elseif checkIndex == 2 then
                    chat:AddMessage ( "|cffff0000" .. GRM.L ( "Notification Set:" ) .. " |r" .. GRM.L ( "Report When {name} Comes Online!" , GRM.SlimName ( name ) ) );
                -- Goes Offline
                elseif checkIndex == 3 then
                    chat:AddMessage ( "|cffff0000" .. GRM.L ( "Notification Set:" ) .. " |r" .. GRM.L ( "Report When {name} Goes Offline!" , GRM.SlimName ( name ) ) );            
                end
                break;
            end
        end
    else
        GRM.Report ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "Notification Has Already Been Arranged..." ) );
    end
end

-- Method:          GRM.IsGuildieOnline( string )
-- What it Does:    Lets you know if a guildie is currently online by returning true
-- Purpose:         It is useful to save resources and for knowledge to know if a player is currently online or not. No need to scan certain things wastefully if they are offline.
GRM.IsGuildieOnline = function ( name )
    if not CommunitiesFrame or not CommunitiesFrame:IsVisible() then
        GuildRoster();
    end
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

-- Method:          GRM.ResetGuildNameEverywhere()
-- What it Does:    Changes the guildname to include the full server name it was created on as well
-- Purpose:         This is who the guild will be differentiated from server to server if you encounter guilds of the same name.
GRM.ResetGuildNameEverywhere = function( newGuildName )
    -- Establish the logGID
    if newGuildName ~= nil and newGuildName ~= "" then

        for i = 2 , #GRM_LogReport_Save[GRM_G.FID] do
            if GRM_LogReport_Save[GRM_G.FID][i][1][1] == GRM.SlimName ( newGuildName ) or GRM_LogReport_Save[GRM_G.FID][i][1][1] == newGuildName then
                GRM_G.logGID = i;
                break;
            end
        end

        GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID][1][1] = newGuildName;
        GRM_PlayersThatLeftHistory_Save[GRM_G.FID][GRM_G.saveGID][1][1] = newGuildName;
        GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][1][1] = newGuildName;
        GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][1][1] = newGuildName;
        GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID][1][1] = newGuildName;

        -- Now the backups
        for i = 2 , #GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID] do
            if #GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i] > 0 then
                if GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][3][1] ~= nil then
                    if type ( GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][3][1] ) == "table" then
                        GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][3][1][1] = newGuildName;
                    elseif type ( GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][3][1] ) == "string" then
                        GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][3] = { { GRM_G.guildName , GRM_G.guildCreationDate } };
                    end
                else
                    GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][3] = { { GRM_G.guildName , GRM_G.guildCreationDate } };
                end
                if GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][4][1] ~= nil then
                    if type ( GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][4][1] ) == "table" then
                        GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][4][1][1] = newGuildName;
                    elseif type ( GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][4][1] ) == "string" then
                        GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][4] = { { GRM_G.guildName , GRM_G.guildCreationDate } };
                    end
                else
                    GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][4] = { { GRM_G.guildName , GRM_G.guildCreationDate } };
                end
                if GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][5][1] ~= nil then
                    if type ( GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][5][1] ) == "table" then
                        GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][5][1][1] = newGuildName;
                    elseif type ( GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][5][1] ) == "string" then
                        GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][5] = { { GRM_G.guildName , GRM_G.guildCreationDate } };
                    end
                else
                    GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][5] = { { GRM_G.guildName , GRM_G.guildCreationDate } };
                end
                if GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][6][1] ~= nil then
                    if type ( GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][6][1] ) == "table" then
                        GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][6][1][1] = newGuildName;
                    elseif type ( GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][6][1] ) == "string" then
                        GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][6] = { { GRM_G.guildName , GRM_G.guildCreationDate } };
                    end
                else
                    GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][6] = { { GRM_G.guildName , GRM_G.guildCreationDate } };
                end
                if GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][7][1] ~= nil then
                    if type ( GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][7][1] ) == "table" then
                        GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][7][1][1] = newGuildName;
                    elseif type ( GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][7][1] ) == "string" then
                        GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][7] = { { GRM_G.guildName , GRM_G.guildCreationDate } };
                    end
                else
                    GRM_GuildDataBackup_Save[GRM_G.FID][GRM_G.saveGID][i][7] = { { GRM_G.guildName , GRM_G.guildCreationDate } };
                end
            end
        end
        GRM_GuildNotePad_Save[GRM_G.FID][GRM_G.saveGID][1][1] = newGuildName;
    end
end

----------------------------------
----- SOCIAL API -----------------
----------------------------------

-- Method:          GRM.IsOnFriendsList ( string )
-- What it Does:    Returns true if the given player is on your friends list (not battle.net friends, just WOW only)
-- Purpose:         Useful to know as if a player leaves the guild, you can add them to a friends list, and if the player does not exist, it will say
--                  "Player Not Found" thus revealing that the player that left the guild either left the server too, or namechanged after leaving.
GRM.IsOnFriendsList = function ( fullName )
    local result = { false , false };
    for i = 1 , GetNumFriends() do
        local name , _ , _ , _ , isOnline = GetFriendInfo ( i );
        if name == fullName or name == GRM.SlimName ( fullName ) then
            result[1] = true;           -- They are on FriendsList
            result[2] = isOnline;       -- if that player happens to be online
            break;
        end
    end
    return result;
end

-- Method:          GRM.SetLeftPlayersStillOnServer ( string )
-- What it Does:    Builds the list of players that have left the guild but are still on the server...
-- Purpose:         A workaround since you cannot scan the server for the player, can relatively determine if they
--                  are at least still on the server.
GRM.SetLeftPlayersStillOnServer = function( playerNames )
    GRM_G.LeftPlayersStillOnServer = {};
    -- First, let's add him to friend's list
    if not GRM_G.MsgFilterEnabled then   -- Gate to ensure this only is registered one time. This is also controlled here so as to not waste resources by being called needlessly if player never checks audit window
        GRM_G.MsgFilterEnabled = true;   -- Establishing boolean gate so it is only registered once.
        ChatFrame_AddMessageEventFilter ( "CHAT_MSG_SYSTEM" , GRM.SetSystemMessageFilter );
    end

    if GetNumFriends() < 100 then
        local isFound = {};
        GRM_G.TempListNamesAddedLeftPlayers = {};           -- This list will be used to determine who to remove from friend's list.
        if #playerNames > 0 then
            GRM_Misc[GRM_G.miscID][3] = { true , {} };
            local toAddNumber = #playerNames;
            if GetNumFriends() + #playerNames > 100 then
                if not GRM_G.TooManyFriendsWarning then
                    GRM_G.TooManyFriendsWarning = true;
                    GRM.Report ( GRM.L (  "There are {num} players requesting to join your guild. You only have room for {custom1} more friends. Please consider cleaning up your friend and recruitment lists." , nil , nil , #playerNames , 100 - GetNumFriends() ) );
                end
                toAddNumber = 100 - GetNumFriends()
            end
            for i = 1 , toAddNumber do  
                isFound = GRM.IsOnFriendsList ( playerNames[i] );

                if not isFound[1] and GetNumFriends() < 100 then
                    GRM_G.MsgFilterDelay = true;
                    AddFriend ( playerNames[i] );
                    table.insert ( GRM_G.TempListNamesAddedLeftPlayers , playerNames[i] );
                end
            end
            GRM_Misc[GRM_G.miscID][3][2] = GRM_G.TempListNamesAddedLeftPlayers;
        end

        -- The delay needs to be here...
        C_Timer.After ( 1 , function()
            for i = 1 , #playerNames do
                isFound = GRM.IsOnFriendsList ( playerNames[i] );
        
                if isFound[1] then
                    table.insert ( GRM_G.LeftPlayersStillOnServer , { playerNames[i] , isFound[2] } );

                    for j = 1 , #GRM_G.TempListNamesAddedLeftPlayers do
                        if GRM_G.TempListNamesAddedLeftPlayers[j] == playerNames[i] then
                            GRM_G.MsgFilterDelay = true;
                            RemoveFriend ( playerNames[i] );
                            RemoveFriend ( GRM.SlimName ( playerNames[i] ) );   -- Non merged realm will not have the server name, so this avoids the "Player not found" error
                            break;
                        end
                    end
                end
            end
            GRM_Misc[GRM_G.miscID][3] = { false , {} };      -- Reset since it is complete...
            GRM_G.MsgFilterDelay = false;
        end);
    else
        GRM_G.MsgFilterDelay = false;
        if not GRM_G.TooManyFriendsWarning then
            GRM_G.TooManyFriendsWarning = true;
            GRM.Report ( GRM.L ( "You currently are at {num} non-Battletag friends. To fully take advantage of all of GRM features, please consider clearing some room." , nil , nil , 100 ) );
        end
    end
end

-- Method:          GRM.CheckRequestPlayersIfOnline ( array )
-- What it does:    Checks all the people who are requesting to join the guild, their Online status...
-- Purpose:         Quality of life... informs you when someone requesting to join the guild logs online.
GRM.CheckRequestPlayersIfOnline = function ( playerNames )
    if time() - GRM_G.RequestJoinTimer > 3 then
        GRM_G.MsgFilterDelay2 = true;
        C_Timer.After ( 1 , function()
            GRM_G.RequestJoinTimer = time();
            if not GRM_G.MsgFilterEnabled then   -- Gate to ensure this only is registered one time. This is also controlled here so as to not waste resources by being called needlessly if player never checks audit window
                GRM_G.MsgFilterEnabled = true;   -- Establishing boolean gate so it is only registered once.
                ChatFrame_AddMessageEventFilter ( "CHAT_MSG_SYSTEM" , GRM.SetSystemMessageFilter );
            end

            if GetNumFriends() < 100 then
                
                -- First, let's cleanup the list of names that need to be removed as they are no longer on the list.
                local needsToDelete;
                local i = 1;
                while i <= #GRM_G.RequestToJoinPlayersCurrentlyOnline do
                    needsToDelete = true;
                    for j = 1 , #playerNames do
                        if GRM_G.RequestToJoinPlayersCurrentlyOnline[i][1] == playerNames[j][1] then
                            needsToDelete = false;
                            break;
                        end
                    end
                    -- player was never found...
                    if needsToDelete then
                        table.remove ( GRM_G.RequestToJoinPlayersCurrentlyOnline , i );
                    else
                        i = i + 1;
                    end
                end
                -- Now, we use the friends list by cheating the server to get around the /who slow callback.
                local isFound = {};
                GRM_G.TempListNamesAdded = {};           -- This list will be used to determine who to remove from friend's list.
                if #playerNames > 0 then
                    GRM_Misc[GRM_G.miscID][2] = { true , {} };      -- for backup incase player logs off in the middle of adding names...
                    local toAddNumber = #playerNames;
                    if GetNumFriends() + #playerNames > 100 then 
                        if not GRM_G.TooManyFriendsWarning then
                            GRM_G.TooManyFriendsWarning = true;
                            GRM.Report ( GRM.L (  "There are {num} players requesting to join your guild. You only have room for {custom1} more friends. Please consider cleaning up your friend and recruitment lists." , nil , nil , #playerNames , 100 - GetNumFriends() ) );
                        end
                        toAddNumber = 100 - GetNumFriends();
                    end
                    for i = 1 , toAddNumber do
                        isFound = GRM.IsOnFriendsList ( playerNames[i][1] );

                        if not isFound[1] and GetNumFriends() < 100 then
                            GRM_G.MsgFilterDelay2 = true;                            
                            AddFriend ( playerNames[i][1] );
                            table.insert ( GRM_G.TempListNamesAdded , playerNames[i][1] );
                        end
                    end
                    GRM_Misc[GRM_G.miscID][2][2] = GRM_G.TempListNamesAdded;
                end

                -- The delay needs to be here... as client doesn't update the friends list instantly.
                C_Timer.After ( 1.5 , function()
                    local isFound;
                    for i = 1 , #playerNames do
                        isFound = GRM.IsOnFriendsList ( playerNames[i][1] );
    
                        if isFound[1] then
                            local found = false;
                            for j = 1 , #GRM_G.RequestToJoinPlayersCurrentlyOnline do
                                if GRM_G.RequestToJoinPlayersCurrentlyOnline[j][1] == playerNames[i][1] then
                                    GRM_G.RequestToJoinPlayersCurrentlyOnline[j][2] = isFound[2];
                                    if not GRM_G.RequestToJoinPlayersCurrentlyOnline[j][2] then
                                        GRM_G.RequestToJoinPlayersCurrentlyOnline[j][3] = false;         -- Reset the reporting in case they relog.
                                    end
                                    found = true;
                                    break;
                                end
                            end
                            if not found then
                                table.insert ( GRM_G.RequestToJoinPlayersCurrentlyOnline , { playerNames[i][1] , isFound[2] , false , playerNames[i][2] } );   -- Name , onlineStatus, StatusReportedToPlayerInChat
                            end
                            GRM_G.MsgFilterDelay2 = true;
                            RemoveFriend ( playerNames[i][1] );
                            RemoveFriend ( GRM.SlimName ( playerNames[i][1] ) );   -- Non merged realm will not have the server name, so this avoids the "Player not found" error]
                        end
                    end
                    GRM_Misc[GRM_G.miscID][2] = { false , {} };
                    -- GRM_G.MsgFilterDelay2 = false;
                end);
            else
                -- GRM_G.MsgFilterDelay2 = false;
                if not GRM_G.TooManyFriendsWarning then
                    GRM_G.TooManyFriendsWarning = true;
                    GRM.Report ( GRM.L ( "You currently are at {num} non-Battletag friends. To fully take advantage of all of GRM features, please consider clearing some room." , nil , nil , 100 ) );
                end
            end
        end);
    end
end

-- Method:          GRM.FriendsListCapTest()
-- What it Does:    Adds 100 players to the friends list
-- Purpose:         Testing and debugging. Also, it only works on guilds with more than 100 players
GRM.FriendsListCapTest = function()
    for i = 1 , 101 do
        local name = GetGuildRosterInfo ( i );
        if name ~= GRM_G.addonPlayerName then
            AddFriend ( name );
        end
    end
end

-- Method:          GRM.ClearFriendsList()
-- What it Does:    Clears the entire server side, non-battletag friends list completely to zero
-- Purpose:         For debugging cleanup
GRM.ClearFriendsList = function()
    for i = GetNumFriends() , 1 , -1 do
        local name = GetFriendInfo ( i );
        RemoveFriend ( name );
    end
end

-- Method:          GRM.MiscCleanupOnLogin()
-- What it Does:    On player reload, it basically does a quick cleanup of any unfinished business
-- Purpose:         To fix actions that might have been unfinished or interrupted, but saved, so they can be cleaned up and restarted 
--                  without residual messes.
GRM.MiscCleanupOnLogin = function()
    if not GRM_G.MsgFilterEnabled then
        GRM_G.MsgFilterEnabled = true;   -- Establishing boolean gate so it is only registered once.
        ChatFrame_AddMessageEventFilter ( "CHAT_MSG_SYSTEM" , GRM.SetSystemMessageFilter );
    end

    -- Friends list actions...
    GRM_G.MsgFilterDelay = true
    local isFound = false;
    for i = 1 , #GRM_Misc do
        if GRM_Misc[i][1] == GRM_G.addonPlayerName then
            isFound = true;
            GRM_G.miscID = i;
        end
    end
    if not isFound then
        GRM.ConfigureMiscForPlayer( GRM_G.addonPlayerName );
        GRM_G.miscID = #GRM_Misc;
    end
    
    for i = 2 , 3 do
        if GRM_Misc[GRM_G.miscID][i][1] then
            for j = 1 , #GRM_Misc[GRM_G.miscID][i][2] do
                GRM_G.MsgFilterDelay = true
                GRM_G.MsgFilterDelay2 = true;
                RemoveFriend ( GRM_Misc[GRM_G.miscID][i][2][j] );
            end
            GRM_Misc[GRM_G.miscID][i] = { false , {} };
        end
    end
    GRM_G.MsgFilterDelay = false;
    -- GRM_G.MsgFilterDelay2 = false;
    -- End Friends list check.
end


-- WORK IN PROGRESS
-- Method:          GRM.CleanupAltList()
-- What it Does:    Checks for discrepancies in player alt lists and reports/fixes them
-- Purpose:         To cleanup any flaws in the alt lists that could occure like in a crash in the middle of a modification.
GRM.CleanupAltList = function()
    local tempGuild = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    for i = 2 , #tempGuild do                                       -- Cycle through the guild
        local altList = tempGuild[i][11];                           -- Establish the alt list
        local leftAltList = tempGuild[i][37];
        if #altList > 0 then                                        -- Only do work if there are alts
            for r = 1 , #altList do                                 -- Ok, now let's cycle through each alt
                for j = 2 , #tempGuild do                           -- lets now go through the guild to match the alt
                    if altList[r][1] == tempGuild[j][1] then        -- Guild match found to an alt
                        -- Now that we have identified the match, we can check the integrity of the alt lists...
                        -- So, now we go through the alt List and compare
                        local found = false;
                        for k = 1 , #tempGuild[j][11] do                                                                                -- Cycle through the alts of the original
                            found = false;
                            for m = 1 , #altList do                                                                                     -- Cycle through all the matched alts
                                if tempGuild[j][11][k][1] == altList[m][1] or tempGuild[j][11][k][1] == tempGuild[i][1] then            -- Match is found (or player is match) - we are good...
                                    found = true;
                                    break;
                                end
                            end
                            -- Check if descrepancies!
                            if not found then                                                           -- No match found - DISCREPANCY IN ALT LISTS!!!
                                -- Check if player removed
                                for s = 1 , #leftAltList do
                                    if leftAltList[s][1] == tempGuild[j][11][k][1] then                 -- Player was found removed
                                        found = true;
                                        if leftAltList[s][6] < tempGuild[j][11][k][6] then                    -- Compare timestamps
                                            print ( leftAltList[s] .. " needs to be added to " .. tempGuild[j][1] .. "'s alt list!" );
                                        end
                                        break;
                                    end
                                end
                                if not found then
                                    print("Player was added but not not found on all... not found in left either.")
                                end
                            end
                        end
                        break;
                    end
                end
            end
        end
    end
end

-- Method:          GRM.RemoveAllNonBannedLeftPlayers()
-- What it Does:    Deletes any player in the left player list that is not banned
-- Purpose:         To cleanup the left players list and only leave the banned players.
GRM.RemoveAllNonBannedLeftPlayers = function()
    local leftPlayers = GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    local c = 0;
    for i = #leftPlayers , 2 , -1 do
        if not leftPlayers[i][17] then
            table.remove ( leftPlayers , i );
            c = c + 1;
        end
    end

    print ( c .. " players purged from database" );

end

-- Method:          GRM.UpdateRecruitmentPlayerStatus()
-- What it Does:    On a time interval, it recursively re-checks the recruitment window if any players have logged on and notifies the player if they have.
-- Purpose:         For reporting to the player when someone logs in.
GRM.UpdateRecruitmentPlayerStatus = function()
    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][27] and IsInGuild() and time() - GRM_G.requestToJoinTimer > GRM_G.requestToJoinTimeInterval then
        GRM_G.requestToJoinTimer = time();
        if CommunitiesGuildRecruitmentFrameApplicants ~= nil and CommunitiesGuildRecruitmentFrameApplicants:IsVisible() then
            GRM_G.requestToJoinTimeInterval = 15;
        else
            GRM_G.requestToJoinTimeInterval = 60;            -- Resets to default 60
        end
        GRM.CheckRequestPlayersIfOnline ( GRM.GetGuildApplicantNames() );

        local needsLink = false;
        for i = 1 , #GRM_G.RequestToJoinPlayersCurrentlyOnline do
            if GRM_G.RequestToJoinPlayersCurrentlyOnline[i][2] and not GRM_G.RequestToJoinPlayersCurrentlyOnline[i][3] then
                GRM_G.RequestToJoinPlayersCurrentlyOnline[i][3] = true;          -- Player has reported this player as being online!
                needsLink = true;
                chat:AddMessage ( GRM.L ( "{name} has requested to join the guild and is currently ONLINE!" , GRM.GetClassColorRGB ( GRM_G.RequestToJoinPlayersCurrentlyOnline[i][4] , true ) .. GRM_G.RequestToJoinPlayersCurrentlyOnline[i][1] .. "|r" )  , 0 , 0.77 , 0.95 , 1 );
            end
        end
        -- add a link, but only for 1 at the bottom of the list.
        if needsLink then
            chat:AddMessage ( GRM.L ( "Click Link to Open Recruiting Window:" ) .. "\124cffffff00\124Hquest:0:0\124h[" .. GRM.L ( "Guild Recruits" ) .. "]\124h\124r\n" , 0 , 0.77 , 0.95 , 1 );
        end
        C_Timer.After ( GRM_G.requestToJoinTimeInterval + 1 , GRM.UpdateRecruitmentPlayerStatus );
    else
        return
    end
end

-- Method:          GRM.IsRequestToJoinPlayerCurrentlyOnline ( string )
-- What it Does:    Returns true if the given name is requesting to join the guild and is currently online
-- Purpose:         UI feature for those requesting to join the guild to see and know when they are online...
GRM.IsRequestToJoinPlayerCurrentlyOnline = function ( name )
    name = GRM.FormatNameWithPlayerServer ( name );
    local result = false;
    local isFound = false;
    for i = 1 , #GRM_G.RequestToJoinPlayersCurrentlyOnline do
        if GRM_G.RequestToJoinPlayersCurrentlyOnline[i][1] == name then
            isFound = true;
            if GRM_G.RequestToJoinPlayersCurrentlyOnline[i][2] then
                result = true;
            end
            break;
        end
    end
    return { isFound , result };
end

-- Method:          GRM.GetGuildApplicantNames()
-- What it does:    Returns an array of strings with the names of each person applying to the guild
-- Purpose:         To find out information on the people requesting to join.
GRM.GetGuildApplicantNames = function()
    RequestGuildApplicantsList();                   -- needs to be triggered to the server to update guild info.
    local result = {};
    for i = 1 , GetNumGuildApplicants() do
       local name , _ , class = GetGuildApplicantInfo ( i );
       if string.find ( name , "-" ) == nil then
            name = name .. "-" .. GRM_G.realmName;
       end
       table.insert ( result , { name , class } );
    end
    return result;
end


local channelEnum = {
    ["CHAT_MSG_GUILD"] = "Guild",
    ["CHAT_MSG_OFFICER"] = "Officer",
    ["CHAT_MSG_PARTY"] = "Party",
    ["CHAT_MSG_PARTY_LEADER"] = "Party Leader",
    ["CHAT_MSG_RAID"] = "Raid",
    ["CHAT_MSG_RAID_LEADER"] = "Raid Leader",
    ["CHAT_MSG_INSTANCE_CHAT"] = "Instance",
    ["CHAT_MSG_INSTANCE_CHAT_LEADER"] = "Instance Leader",
    ["CHAT_MSG_ACHIEVEMENT"] = "Achievement"
}

-- Method:          GRM.GetChannelType ( string )
-- What it Does:    Returns the type of channel, be it guild, be it anniversary, be it whatever. This returns all social chat channel types
-- Purpose:         A helper to identify new events in relation to chat monitoring.
GRM.GetChannelType = function ( channelName )
    local result = "";
    for key, y in pairs ( channelEnum ) do
        if y == channelName then
            result = key;
            result = string.gsub ( result , "CHAT_MSG_" , "" ); -- Parses out the CHAT_MSG_ and leaves the title.
            break;
        end
    end
    return result;
end

-- Method:          GRM.GetChatRGB ( string )
-- What it Does:    Returns the RGB color code for the given chat channel
-- Purpose:         Being able to create custom channels and match them to the player's settings is extremely useful for downstream plans.
GRM.GetChatRGB = function ( channel )
    local result = {};
    if ChatTypeInfo[ channel ] ~= nil then
        result = { ChatTypeInfo[channel].r , ChatTypeInfo[channel].g , ChatTypeInfo[channel].b , ChatTypeInfo[channel].colorNameByClass };
    end
    return result;
end

-- Method:          GRM.ShowCustomColorPicker ( float , float , float , float , function )
-- What it Does:    Established some default values for the colorpicker frame, and then shows it
-- Purpose:         One, to configure the color picker frames, and two, to create a universally recyclable function for all potential future colorpicker options as well.
GRM.ShowCustomColorPicker = function ( r , g , b , a , callback )
    GRM_G.MainTagColor = true;
    ColorPickerFrame:SetColorRGB ( r , g , b );
    ColorPickerFrame.previousValues = { r , g , b , a };
    ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = callback, callback, callback;
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu:Hide();
    ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
    ColorPickerFrame:Show();
end

-- Method:          GRM.ColorSelectMainName()
-- What it Does:    When on the ColorPickerWindow from the Options, this is the logic that updates on the fly and saves the colors as you go.
-- Purpose:         To establish the proper RGB coloring of the text in the General options tab
GRM.ColorSelectMainName = function()
    local r , g , b = ColorPickerFrame:GetColorRGB();
    -- Texture Box
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame:IsVisible() and GRM_G.MainTagColor then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorSelectOptionsFrame.GRM_OptionsTexture:SetColorTexture ( r , g , b , 1 );
        -- Update the dropdown window color too
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected.GRM_TagText:SetTextColor ( r , g , b , 1 );
    end
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:IsVisible() then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:SetText ( math.floor ( r * 255 ) );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerR:Show();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:SetText ( math.floor ( g * 255 ) );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerG:Show();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:SetText ( math.floor ( b * 255 ) );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ColorPickerB:Show();
    end
end

-- Method:          GRM.RemoveStringColoring(string)
-- What it Does:    Removes the HexTag Blizz uses to identify and color the text. Anything that starts with |cffxxxxxx
-- Purpose:         Clean up the texts for export so it is just plain text.
GRM.RemoveStringColoring = function( text )
    while ( string.find ( string.lower ( text ) , "|cff" ) ~= nil ) do
        local index = string.find ( string.lower ( text ) , "|cff" );
        text = string.sub ( text , 1 , index -1 ) .. string.sub ( text , index + 10 );
    end
    return text;
end

-- Method:          GRM.AddMainToChat ( ... )
-- What it Does:    It adds either a Main tag to the player, or if they are on an alt, includes the name of the main.
-- Purpose:         Easy to see player name in guild chat, for achievments and so on...
GRM.AddMainToChat = function( _ , event , msg , sender , ... )
    sender = GRM.GetSenderNameWithServer ( sender );            -- Adding the server to the sender, properly.
    local result = false;
    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][29] and sender ~= GRM_G.addonPlayerName then
        local guildData = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
        local channelName = channelEnum [ event ];
        -- local colorCode = GRM.GetChatRGB ( GRM.GetChannelType ( channelName ) );
        local format = { "<" .. GRM.L ( "M" ) .. ">" , "(" .. GRM.L ( "M" ) .. ")" , "<" .. GRM.L ( "Main" ) .. ">" , "(" .. GRM.L ( "Main" ) .. ")" };
        local mainDisplay = format[GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][42]];
        -- Find the player in the guild!
        if guildData ~= nil then
            for i = 2 , #guildData do
                if guildData[i][1] == sender then
                    -- Let's see if they are the main. If they are, no need to do anything...
                    if not guildData[i][10] then
                        if #guildData[i][11] > 0 then
                            for j = 1 , #guildData[i][11] do
                                if guildData[i][11][j][5] then
                                    if channelName ~= "Achievement" then
                                        -- if colorCode[4] then
                                        --     sender = GRM.GetClassifiedName ( sender , true );
                                        -- end
                                        -- chat:AddMessage ( "[" .. GRM.L ( channelName ) .. "] |cffff0000" .. GRM.L ( "<M>" ) .. "|r(" .. GRM.SlimName ( guildData[i][11][j][1] ) .. ") " .. "[" .. GRM.SlimName ( sender ) .. "]: " .. msg , colorCode[1] , colorCode[2] , colorCode[3] , 1 );
                                        msg = GRM_G.MainTagHexCode .. mainDisplay .. "|r(" .. GRM.SlimName ( guildData[i][11][j][1] ) .. "): " .. msg;
                                    else
                                        msg = GRM_G.MainTagHexCode .. mainDisplay .. "|r(" .. GRM.SlimName ( guildData[i][11][j][1] ) .. "): " .. msg;
                                    end
                                    break;
                                end
                            end
                        end
                    end
                    break;
                end
            end
        end
    end
    return result, msg, sender, ... 
end

-- Method:          GRM.GetSenderNameWithServer ( string )
-- What it Does:    Returns the player's sender name with the proper full string after finding it in the roster. It paarses by knowing that players with a server tag are your own.
-- Purpose:         For main/alt tagging in chat
GRM.GetSenderNameWithServer = function( name )
    local result = name;
    -- it is assumed the player is currently online...
    if string.find ( name , "-" ) == nil then
        result = name .. "-" .. GRM_G.realmName;
    end
    return result;
end

-- FOR CHAT FILTERING FOR INFO AND LISTENING... No need to parse it now, but possibly for the future...
-- ChatHistory_GetAccessID("CHAT_MSG_GUILD")
-- ChatFrame1:GetNumMessages(34)
-- /dump ChatFrame1:GetMessageInfo(1,34)
-- /run for i=1,ChatFrame1:GetNumMessages(34) do local t,aID,id,ex=ChatFrame1:GetMessageInfo(i);print(ex);end
-- /dump ChatFrame1:GetNumLinesDisplayed()

-----------------------------------
-------- PROFESSIONS --------------
-----------------------------------

GRM.GetProfessionsInfo = function()
    local skillID, isCollapsed, iconTexture, headerName, numOnline, numVisible, numPlayers, playerName, playerNameWithRealm, class, online, zone, skill, classFileName, isMobile, isAway = GetGuildTradeSkillInfo ( 1 );
    local result = { skillID , isCollapsed, iconTexture, headerName, numOnline, numVisible, numPlayers, playerName, playerNameWithRealm, class, online, zone, skill, classFileName, isMobile, isAway };
    

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
    if version ~= GRM_G.Version then
        if not GRM_G.VersionChecked and time > GRM_G.PatchDay then
            -- Let's report the need to update to the player!
            chat:AddMessage ( "|cff00c8ff" .. GRM.L ( "GRM:" ) .. " |cffffffff" .. GRM.L ( "A new version of Guild Roster Manager is Available!" ) .. " |cffff0044" .. GRM.L ( "Please Upgrade!" ) );
            -- No need to send comm because he has the update, not you!

        elseif time < GRM_G.PatchDay then
            -- Your version is more up to date! Send comms out!
            SendAddonMessage ( "GRMVER" , GRM_G.Version .. "?" .. GRM_G.PatchDayString , "SLASH_CMD_GUILD" ); -- Remember, patch day is an int in epoch time, so needs to be converted to string for comms
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
    VersionCheck:SetScript ( "OnEvent" , function ( _ , event , prefix , msg , channel , sender )
        if event == "CHAT_MSG_ADDON" and prefix == "GRMVER" and channel == "SLASH_CMD_GUILD" then
                -- Gotta filter my own messages out too!
            if sender ~= GRM_G.addonPlayerName then

                -- Just to ensure it only does a check one time from each player with the addon installed.
                local isFound = false;
                for i = 1 , #GRM_G.VersionCheckedNames do
                    if GRM_G.VersionCheckedNames[i] == sender then
                        isFound = true;
                        break;
                    end
                end

                -- Player has never commed on version with you. Add their name, then do a version check!
                if not isFound then
                    table.insert ( GRM_G.VersionCheckedNames , sender );
                    GRM.VersionCheck ( msg );
                end
            end
        end
    end);
end

-- Method:          RegisterGuildAddonUsersRefresh ()
-- What it Does:    Two uses. One, it checks to see if all the people on the list of users with addon installed are still online, and if not, purges them
--                  and two, requests data from the players again to be updated. This is useful because players may change their settings.
-- Purpose:         To keep the UI up to date. It is necessary to refresh the info occasionally rather than just on login.
GRM.RegisterGuildAddonUsersRefresh = function ()              -- LoadRefresh is just OnShow() for the window, no need to have 10 sec delay as we are not oging to send requests, just purge the offlines.
    -- Purge the players that are no longer online...
    local listOfNames = GRM.GetAllGuildiesOnline( true );
    local notFound = true;

    for i = 1 , #GRM_G.currentAddonUsers do
        notFound = true;
        for j = 1 , #listOfNames do
            if GRM_G.currentAddonUsers[i] ~= nil and listOfNames[j] ~= nil then
                if listOfNames[j] == GRM_G.currentAddonUsers[i][1] then
                    notFound = false;
                    break;
                end
            end
        end
        
        -- if notfound, purge em. They're no longer online...
        if notFound then
            table.remove ( GRM_G.currentAddonUsers , i );
        end
    end
    -- Request the updated info!
    SendAddonMessage ( "GRMUSER" , "REQ?_" , "SLASH_CMD_GUILD" );
    GRM_G.refreshAddonUserDelay = time();

    -- Updating the frames. Giving 2 seconds to receive responses!
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:IsVisible() then
        C_Timer.After ( 2 , function()
            GRM.BuildAddonUserScrollFrame();
        end);
    end
end

-- Method:          GRM.AddonUserRegister ( string , string )
-- What it Does:    Analyzes to see if the addon user communicating with you is capable of syncing with you, as you could filter them or they could filter you.
-- Purpose:         Having a UI showing who has the addon, what version, if you can sync is just useful information. Not necessary for addon functionality, but is good for Quality of Life.
GRM.AddonUserRegister = function( sender , msg )
    local rankOfSender = GRM.GetGuildMemberRankID ( sender );
    local playerRankID = GRM.GetGuildMemberRankID ( GRM_G.addonPlayerName )

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
        if rankOfSender > GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] or senderRankRequirement < playerRankID then
            -- Ranks do not sync, let's get it right.
            -- For messaging the reason why.
            if rankOfSender > GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] then
                result = "Their Rank too Low";
            else
                result = "Your Rank too Low";
            end
        -- Check if versions are outdated as well.
        elseif syncOnlyCurrent == "true" or GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][19] then
            -- If versions are different. Just filtering out unnecessary computations if verisons are the same.
            if epochTimeVersion ~= GRM_G.PatchDay then
                -- If their version is older than yours...
                if epochTimeVersion < GRM_G.PatchDay and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][19] then
                    result = "Outdated Version";
                elseif GRM_G.PatchDay < epochTimeVersion and syncOnlyCurrent == "true" then
                    result = "You Need Updated Version";
                end
            end
        end 
    else
        result = "Player Sync Disabled";
    end
    
    -- Now, let's see if they are already in the table.
    local isFound = false;
    for i = 1 , #GRM_G.currentAddonUsers do
        if GRM_G.currentAddonUsers[i][1] == sender then
            GRM_G.currentAddonUsers[i][2] = result;
            GRM_G.currentAddonUsers[i][3] = version;
            isFound = true;
            break;
        end
    end

    if not isFound then
        table.insert ( GRM_G.currentAddonUsers , { sender , result , version } );
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
    AddonUsersCheck:SetScript ( "OnEvent" , function ( _ , event , prefix , msg , channel , sender )
        if event == "CHAT_MSG_ADDON" and prefix == "GRMUSER" and channel == "SLASH_CMD_GUILD" and sender ~= GRM_G.addonPlayerName then
            -- parse out the header
            local header = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
            msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
            if header == "INIT" then
                GRM.AddonUserRegister ( sender , msg );
            elseif header == "REQ" then
                -- player is requesting info again. Sending update!
                SendAddonMessage ( "GRMUSER" , "INIT?" .. GRM_G.Version .. "?" .. GRM_G.PatchDayString .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][19] ) .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] ) .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] ) , "SLASH_CMD_GUILD" );
            end
        end
    end);

    -- Send out initial comms
    -- Name Version , epochTimestamp of update , string version of boolean if player restricts sync only to those with latest version of addon or higher.
    SendAddonMessage ( "GRMUSER" , "INIT?" .. GRM_G.Version .. "?" .. GRM_G.PatchDayString .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][19] ) .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] ) .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] ) , "SLASH_CMD_GUILD" );
    -- Request for their data.
    SendAddonMessage ( "GRMUSER" , "REQ?_" , "SLASH_CMD_GUILD" );
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

-- Method:          GRM.GetASCII ( string )
-- What it Does:    Prints out the byte values of each char in a string.
-- Purpose:         Good to filter unnacceptable strings at times.
GRM.GetASCII = function ( inputString )
    local chars = {};
    for i = 1 , #inputString do
        table.insert ( chars , string.sub ( inputString , i , i ) ); -- Breaks the string apart into chars.
    end

    for i = 1 , #chars do
        if string.gmatch ( chars[i] , "[%z\1-\127\194-\244][\128-\191]*" ) ~= nil then
            -- print ( string.byte ( chars[i]) );
        end
    end
end

-- STILL NEED TO COMPLETE OTHER REGIONS' FONTS!!!!!!!!!!
-- Method:          GRM.IsValidName(string)
-- What it Does:    Returns true if the name only contains valid characters in it... based on ASCII numeric values
-- Purpose:         When player is manually adding someone to the player data, we need ot ensure only proper characters are allowed.
GRM.IsValidName = function ( name )
    local result = true;
    name = GRM.Trim ( name ); -- In case any whitespace before or after...
    for i = 1, #name do
        -- As a stopgap until I scan for all fonts, let's check this.
        local char = string.sub ( name , i , i );
        -- local byteValue = string.byte ( char );
        if tonumber ( char ) ~= nil or char == " " or char == "\\" or char == "\n" or char == ":" or char == "(" or char == "$" or char == "%" then
            return false;
        end
        -- Real ASCII limitations for the fonts
        if GRM_G.FontChoice == "Fonts\\FRIZQT__.TTF" then
            -- if byteValue ~= 127 and ( ( byteValue > 64 and byteValue < 91 ) or 
            -- ( byteValue > 96 and byteValue < 123 ) or 
            -- ( byteValue > 127 and byteValue < 166 ) or 
            -- ( byteValue > 180 and byteValue < 184 ) or 
            -- ( byteValue > 197 and byteValue < 200 ) or 
            -- ( byteValue > 207 and byteValue < 217 ) or 
            -- ( byteValue > 223 and byteValue < 238 ) ) then
            --     -- We're good!
            -- else
            --     result = false;
            --     break;
            -- end
        elseif GRM_G.FontChoice == "Fonts\\FRIZQT___CYR.TTF" then        -- Cyrilic
        
        elseif GRM_G.FontChoice == "FONTS\\2002.TTF" then                -- Korean

        elseif GRM_G.FontChoice == "Fonts\\ARKai_T.TTF" then             -- Mandarin Chinese

        elseif GRM_G.FontChoice == "FONTS\\blei00d.TTF" then             -- Mandarin Taiwanese

        elseif GRM_G.FontChoice == "FONTS\\PT_Sans_Narrow.ttf" then      -- ElvUI Default Font

        end
    end
    return result;
end

-- Method:          GRM.CapitalizeFirst ( string )
-- What it Does:    Formats the string properly to have the first letter of the word/name capitalized
-- Purpose:         Cleanup formatting of a name to prevent human error protection.
GRM.CapitalizeFirst = function( text )
    local count = 1;
    local byteCount = text:byte ( 1 );
    if byteCount == 195 or byteCount == 165 then                -- Special cahracters some can be 2 bytes in length and they are given a value of 195 or 165 in Lua return
        count = 2;
    end

    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][43] < 9 then
        text = string.upper ( string.sub ( text , 1 , count ) ) .. string.sub ( text , count + 1 );
    end
    return text;
end

-- Method:          GRM.FormatInputName ( string )
-- What it Does:    Formats the name to proper pronoun form, but only if a non Asian character language
-- Purpose:         Huaman error protection on player input.
GRM.FormatInputName = function ( name )
    name = GRM.CapitalizeFirst( name );
    local byteCount = name:byte ( 1 );
    local count = 1;
    if byteCount == 195 or byteCount == 165 then                -- Special cahracters some can be 2 bytes in length and they are given a value of 195 or 165 in Lua return
        count = 2;
    end
    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][43] < 9 then
        name = string.sub ( name , 1 , count ) .. string.lower ( string.sub ( name , count + 1 ) );
    end
    return name;
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
    GRM_G.TempNewMember = {};
    GRM_G.TempInactiveReturnedLog = {};
    GRM_G.TempLogPromotion = {};
    GRM_G.TempLogDemotion = {};
    GRM_G.TempLogLeveled = {};
    GRM_G.TempLogNote = {};
    GRM_G.TempLogONote = {};
    GRM_G.TempRankRename = {};
    GRM_G.TempRejoin = {};
    GRM_G.TempBannedRejoin = {};
    GRM_G.TempLeftGuild = {};
    GRM_G.TempLeftGuildPlaceholder = {};
    GRM_G.TempNameChanged = {};
    GRM_G.TempEventReport = {};
    GRM_G.TempEventRecommendKickReport = {};
end

------------------------------------
------ TIME TRACKING TOOLS ---------
--- TIMESTAMPS , TIMEPASSED, ETC. --
------------------------------------

GRM.CalendarGetDate = function()
    -- live:
    -- local weekday, month, day, year = GRM.CalendarGetDate();
    -- beta: 
	local calendarTime = C_Calendar.GetDate();
	local weekday = calendarTime.weekday;
	local month = calendarTime.month;
	local day = calendarTime.monthDay;
	local year = calendarTime.year;
	
    return weekday, month, day, year;
end


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
GRM.GetHoursSinceLastOnline = function ( index , isOnline )
    local years , months, days, hours = GetGuildRosterLastOnline ( index );
    local invalidData = false;
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
        if isOnline then
            hours = 0.5;    -- This can be any value less than 1, but must be between 0 and 1, to just make the point that total number of hrs since last login is < 1
        else
            invalidData = true;
        end
    end
    if not invalidData then
        return math.floor ( ( years * 8766 ) + ( months * 730 ) + ( days * 24 ) + hours );
    else
        return 0;
    end
end

-- Method:          GRM.IsValidSubmitDate ( int , int , boolean )
-- What it Does:    Returns true if the submission date is valid (not an untrue day or in the future)
-- Purpose:         Check to ensure the wrong date is not submitted on accident.
GRM.IsValidSubmitDate = function ( daySelected , monthSelected , yearSelected , IsLeapYearSelected )
    local closeButtons = true;
    local _ , month , day , year = GRM.CalendarGetDate()  
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
            GRM.Report ( GRM.L ( "Player Does Not Have a Time Machine!" ) );
            closeButtons = false;
        end
    end

    if closeButtons == false then
        GRM.Report ( GRM.L ( "Please choose a valid DAY" ) );
    end
    return closeButtons;
end

-- Method:          GRM.TimeStampToEpoch(timestamp)
-- What it Does:    Converts a given timestamp: "22 Mar '17" into Epoch Seconds time (UTC timezone)
-- Purpose:         On adding notes, epoch time is considered when calculating how much time has passed, for exactness and custom dates need to include it.
GRM.TimeStampToEpoch = function ( timestamp , IsStartOfDay )
    -- Parsing Timestamp to useful data.
    timestamp = string.sub ( timestamp , 1 , string.find ( timestamp , "'" )  + 2 );                        -- remove the timestamp...
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
    local hour , minute , seconds;
    if IsStartOfDay then
        hour = 0;
        minute = 1;
        seconds = 0;
    else
        hour , minute = GetGameTime();
        local tempTime = date ( '*t' );
        seconds = tempTime.sec;
    end

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
    local _, month, day, year = GRM.CalendarGetDate();
    local stampMonth = months [ month ];
    local time = "";
    year = string.sub ( tostring ( year ) , 3 );
    
    -- Establishing proper format
    time = ( day .. " " .. stampMonth .. " '" .. year .. " " .. GRM.GetFormatTime ( hour , minutes ) );
    
    return time;
end

-- Method:          GRM.GetTimePassed ( oldTimestamp )
-- What it Does:    Reports back the elapsed, in English, since the previous given timestamp, based on the 1970 seconds count.
-- Purpose:         Time tracking to keep track of elapsed time since previous action.
GRM.GetTimePassed = function ( oldTimestamp )
-- /run GRM.GetTimePassed(1515659119)
    -- Need to consider Leap year, but for now, no biggie. 24hr differentiation only in 4 years.
    local totalSeconds = time() - oldTimestamp;
    local year = math.floor ( totalSeconds / 31536000 ); -- seconds in a year
    local yearTag = GRM.L ( "Year" );
    totalSeconds = totalSeconds % 31536000
    local month = math.floor ( ( totalSeconds % 31536000 ) / 2592000 ); -- etc. 
    local monthTag = GRM.L ( "Month" );
    local days = math.floor ( ( totalSeconds % 2592000) / 86400 );
    local dayTag = GRM.L ( "Day" );
    local hours = math.floor ( ( totalSeconds % 86400 ) / 3600 );
    local hoursTag = GRM.L ( "Hour" );
    local minutes = math.floor ( ( totalSeconds % 3600 ) / 60 );
    local minutesTag = GRM.L ( "Minute" );
    local seconds = math.floor ( ( totalSeconds % 60) );
    local secondsTag = GRM.L ( "Second" );
    
    local timestamp = "";
    if year > 1 then
        yearTag = GRM.L ( "Years" );
    end
    if month > 1 then
        monthTag = GRM.L ( "Months" );
    end
    if days > 1 then
        dayTag = GRM.L ( "Days" );
    end
    if hours > 1 then
        hoursTag = GRM.L ( "Hours" );
    end
    if minutes > 1 then
        minutesTag = GRM.L ( "Minutes" );
    end
    if seconds > 1 then
        secondsTag = GRM.L ( "Seconds" );
    end

    if year > 0 or month > 0 or days > 0 then
        if year > 0 then
            timestamp = ( GRM.L ( "{num} {custom1}" , nil , nil , year , yearTag ) );
        end
        if month > 0 then
            timestamp = ( timestamp .. " " .. GRM.L ( "{num} {custom1}" , nil , nil , month , monthTag ) );
        end
        if days > 0 then
            timestamp = ( timestamp .. " " .. GRM.L ( "{num} {custom1}" , nil , nil , days , dayTag ) );
        else
            timestamp = ( timestamp .. " " .. GRM.L ( "{num} {custom1}" , nil , nil , days , GRM.L ( "days" ) ) ); -- exception to put zero days since it seems smoother, aesthetically.
        end
    else
        if hours > 0 or minutes > 0 then
            if hours > 0 then
                timestamp = ( timestamp .. " " .. GRM.L ( "{num} {custom1}" , nil , nil , hours , hoursTag ) );
            end
            if minutes > 0 then
                timestamp = ( timestamp .. " " .. GRM.L ( "{num} {custom1}" , nil , nil , minutes , minutesTag ) );
            end
        else
            timestamp = ( GRM.L ( "{num} {custom1}" , nil , nil , seconds , secondsTag ) );
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
    local startYear = tonumber ( string.sub ( timestamp , string.find ( timestamp , "'" )  + 1 , string.find ( timestamp , "'" )  + 2 ) ) + 2000;
    local index = string.find ( timestamp , " " );
    local monthName = string.sub ( timestamp , index + 1 , index + 3 );
    local startMonth = monthEnum [ monthName ];
    local startDay = tonumber ( string.sub ( timestamp , 0 , index - 1 ) );
    local _ , month , day , year = GRM.CalendarGetDate();
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
            
            result[4] = result[4] .. GRM.L ( "{num} year" , nil , nil , result[1] ) .. " ";
        else
            result[4] =  result[4] .. GRM.L ( "{num} years" , nil , nil , result[1] ) .. " ";
        end
    end
    if result[2] > 0 then
        if result[2] == 1 then
            result[4] = result[4] .. GRM.L ( "{num} month" , nil , nil , result[2] ) .. " ";
        else
            result[4] = result[4] .. GRM.L ( "{num} months" , nil , nil , result[2] ) .. " ";
        end
    end
    if result[3] > 0 and result[1] == 0 then            -- To avoid including days if you have more than 1 year just need year and months
        if result[3] == 1 then
            result[4] = result[4] .. GRM.L ( "{num} day" , nil , nil , result[3] ) .. " ";
        else
            result[4] = result[4] .. GRM.L ( "{num} days" , nil , nil , result[3] ) .. " ";
        end
    end
    -- Clear off any white space.
    if result[1] == 0 and result[2] == 0 and result[3] == 0 then
        result[4] = GRM.L ( "< 1 day" );
    else
        result[4] = GRM.Trim ( result[4] );
    end
    return result;
end

-- Method:          GRM.GetTimePlayerHasBeenMember ( string )
-- What it does:    Parses the string of the player date they joined the guild the most recent, and then obtains how long they have been a member.
-- Purpose:         To display useful info on how long the player has been a member of the guild.
GRM.GetTimePlayerHasBeenMember = function ( name )
    local tempGuild = GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID];
    local result = "";
    for i = 2 , #tempGuild do
        if tempGuild[i][1] == name then
            if #tempGuild[i][20] ~= 0 then
                result = GRM.GetTimePassedUsingStringStamp ( string.sub ( tempGuild[i][20][#tempGuild[i][20]] , 1 , string.find ( tempGuild[i][20][#tempGuild[i][20]] , "'" ) + 2 ) );
                result = result[4];
            end
            break;
        end
    end
    return result;
end

-- Method:          GRM.HoursReport(int)
-- What it Does:    Reports as a string the time passed since player last logged on.
-- Purpose:         Cleaner reporting to the log, and it just reports the lesser info, no seconds and so on.
GRM.HoursReport = function ( hours )
    local result = "";
    local years = math.floor ( hours / 8766 );
    local months = math.floor ( ( hours % 8766 ) / 730 );
    local days = math.floor ( ( hours % 730 ) / 24 );

    -- Continue calculations.
    local hours = math.floor ( ( ( hours % 8760 ) % 730 ) % 24 );
    
    if years >= 1 then
        if years > 1 then
            result = result .. "" .. GRM.L ( "{num} yrs" , nil , nil , years ) .. " ";
        else
            result = result .. "" .. GRM.L ( "{num} yr" , nil , nil , years ) .. " ";
        end
    end

    if months >= 1 then
        if years > 0 then
            result = GRM.Trim ( result ) .. ", ";
        end
        if months > 1 then
            result = result .. "" .. GRM.L ( "{num} mos" , nil , nil , months ) .. " ";
        else
            result = result .. "" .. GRM.L ( "{num} mo" , nil , nil , months ) .. " ";
        end
    end

    if days >= 1 then
        if months > 0 then
            result = GRM.Trim ( result ) .. ", ";
        end
        if days > 1 then
            result = result .. "" .. GRM.L ( "{num} days" , nil , nil , days ) .. " ";
        else
            result = result .. "" .. GRM.L ( "{num} day" , nil , nil , days ) .. " ";
        end
    end

    if hours >= 1 and years < 1 and months < 1 then  -- No need to give exact hours on anything over than a month, just the day is good enough.
        if days > 0 then
            result = GRM.Trim ( result ) .. ", ";
        end
        if hours > 1 then
            result = result .. "" .. GRM.L ( "{num} hrs" , nil , nil , hours ) .. " ";
        else
            result = result .. "" .. GRM.L ( "{num} hr" , nil , nil , hours ) .. " ";
        end
    end

    if result == "" or result == nil then
        result = GRM.L ( "< 1 hour" );
    end
    return result;
end

-- Method:          GRM.GetNumHoursTilRecommend(int)
-- What it Does:    Returns the number of hours need to match the given numMonths time passed
-- Purpose:         Useful for checking if the player has been, for example, offline X number of months, if the time has passed, since the server gives time in hours since last online.
GRM.GetNumHoursTilRecommend = function( numMonths )
    local _ , month , day , year = GRM.CalendarGetDate();
    local hours = 0;
    local totalDays = 0;
    local numYears = math.floor ( numMonths / 12 );
    numMonths = numMonths % 12;
    local monthReference = month - numMonths;

    -- ok let's calculate the month index
    if monthReference < 1 then
        monthReference = 12 - ( numMonths - 4 );
    end

    -- Add up the total days...
    if numMonths > 0 then
        totalDays = day;               -- This sets the initial number, which is this month.
        if numMonths >= month then
            totalDays = totalDays + daysBeforeMonthEnum[ tostring ( month ) ];                                      -- Counts all the days of this year
            totalDays = totalDays + ( 365 - daysBeforeMonthEnum[ tostring ( monthReference ) ] ) - day;             -- Counts all of the days from the reference month X months ago til end of the year

            -- Check Leap Year
            if month > 2 and GRM.IsLeapYear ( year ) and numYears == 0 then -- Adding 1 for the leap year   -- If the year > 1 then the end of this function will tally it auto for each year, if not it is calculated here.
                totalDays = totalDays + 1;
            end

        else                                                                                                        -- Ex: if today is May, 11 months ago, reference month is June last year
            totalDays = totalDays + ( daysBeforeMonthEnum[ tostring ( month ) ] - daysBeforeMonthEnum[ tostring ( monthReference ) ] ) - day;
            if monthReference <= 2 and month > 2 and GRM.IsLeapYear ( year ) and numYears == 0  then
                totalDays = totalDays + 1;
            end
        end
    end
    for i = 0 , numYears - 1 do
        if GRM.IsLeapYear ( year - i ) then
            totalDays = totalDays + 1;
        end
    end
    return ( totalDays + ( 365 * numYears ) ) * 24
end

-- Method:          GRM.GetTimestampBasedOnTimePassed ( array )
-- What it Does:    Returns an array that contains a string timestamp of the date based on the timepassed, as well as the epochstamp corresponding to that date
-- Purpose:         Incredibly necessary for join date and promo date tagging with proper dates for display and for sync.
GRM.GetTimestampBasedOnTimePassed = function ( dateInfo )
    local stampYear = dateInfo[1];
    local stampMonth = dateInfo[2];
    local stampDay = dateInfo[3];
    local stampHour = dateInfo[4];
    local hour, minutes = GetGameTime();
    local _ , month , day , year = GRM.CalendarGetDate();
    local LeapYear = GRM.IsLeapYear ( year );
    local time = "";                     -- Generic stamp placeholder
    if not GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][39] then
        time = "12:01am";
    else
        time = "00:01" .. GRM.L ( "24HR_Notation" );
    end
    
    -- Adjust the year back for how many years passed
    year = year - stampYear - 2000;
    
    -- The month now... Must be a number for 1-12 for corresponding month index
    if month - stampMonth > 0 then
        month = month - stampMonth;
    else
        month = 12 - ( stampMonth - month );
        year = year - 1;
    end

    -- Day
    if day - stampDay > 0 then
        day = day - stampDay;
    else
        local daysInSelectedMonth = daysInMonth[ tostring ( month ) ];
        if LeapYear and month == 2 then
            daysInSelectedMonth = daysInSelectedMonth + 1;
        end
        day = daysInSelectedMonth - ( stampDay - day );
        month = month - 1;
        if month == 0 then
            month = 12;
            year = year - 1;
        end
    end

    -- Hour
    if hour - stampHour > 0 then
        hour = hour - stampHour;
    else
        hour = 24 - ( stampHour - hour );
        day = day - 1;
        if day == 0 then
            -- First, need to determine month now.
            month = month - 1;
            if month == 0 then
                month = 12;
                year = year - 1;
            end
            local dim = daysInMonth[ tostring ( month ) ];      -- Days In Month = dim
            if LeapYear and month == 2 then
                dim = dim + 1;
            end
            day = dim - ( stampDay - day );
        end
    end

    -- We know that it is within hours now.
    if ( stampYear == 0 and stampMonth == 0 and stampDay == 0 ) then
        -- It's the same day! Use current timestamp!!!!

        time = GRM.GetFormatTime ( hour , minutes );
    end
    
    local timestamp = day .. " " .. monthEnum2[ tostring ( month ) ] .. " '" .. year;
    return { timestamp .. " " .. time , GRM.TimeStampToEpoch ( " " .. timestamp , true ) };
end


-- Method:          GRM.FormatTimeStamp( string , int )
-- What it Does:    Returns the timestamp in a format designated by the player
-- purpose:         Give player proper timestamp format options.
GRM.FormatTimeStamp = function ( timestamp , includeHour )
    -- Default format = 12 Mar '18
    local day = string.sub ( timestamp , 1 , string.find ( timestamp , " " ) - 1 );
    local type = GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][51];
    if #day == 1 then
        day = "0" .. day;
    end
    local month = string.sub ( timestamp , string.find ( timestamp , " " ) + 1 , string.find ( timestamp , "'" ) -2 );
    local monthNum = tostring ( monthEnum[month] )
    if #monthNum == 1 then
        monthNum = "0" .. monthNum;
    end
    local year = string.sub ( timestamp , string.find ( timestamp , "'" ) + 1 , string.find ( timestamp , "'" ) + 2 );
    local result = "";  

    if type == 1 then                               -- 12 Mar '18
        result = day .. " " .. GRM.L ( month ) .. " '" .. year;
    elseif type == 2 then                           -- 12 Mar 18
        result = day .. " " .. GRM.L ( month ) .. " " .. year; 
    elseif type == 3 then                           -- 12-Mar-2018
        result = day .. "-" .. GRM.L ( month ) .. "-20" .. year;
    elseif type == 4 then                          -- 03-12-18
        result = day .. "-" .. monthNum .. "-" .. year;
    elseif type == 5 then                          -- 03/12/18
        result = day .. "/" .. monthNum .. "/" .. year;
    elseif type == 6 then                          -- 03.12.18
        result = day .. "." .. monthNum .. "." .. year;
    elseif type == 7 then                          -- 03.12.2018
        result = day .. "." .. monthNum .. ".20" .. year;
    elseif type == 8 then                           -- Mar 12 '18
        result = GRM.L ( month ) .. " " .. day .. " '" .. year;
    elseif type == 9 then                           -- Mar 12 18
        result = GRM.L ( month ) .. " " .. day .. " " .. year;
    elseif type == 10 then                          -- Mar-12-2018
        result = GRM.L ( month ) .. "-" .. day .. "-20" .. year;
    elseif type == 11 then                           -- 12-03-18
        result = monthNum .. "-" .. day .. "-" .. year;
    elseif type == 12 then                           -- 12/03/18
        result = monthNum .. "/" .. day .. "/" .. year;
    elseif type == 13 then                           -- 12.3.18
        result = monthNum .. "." .. day .. "." .. year;
    elseif type == 14 then                           -- 12.3.2018
        result = monthNum .. "." .. day .. ".20" .. year;
    elseif type == 15 then                           -- 2018-03-12
        result = "20" .. year .. "-" .. monthNum .. "-" .. day;    
    end

    if includeHour then
        result = result .. " " .. string.sub ( timestamp , string.find ( timestamp , "'" ) + 4 );
    end
    return result;
end

-- Method:          GRM.GetFormatTime ( string , string )
-- What it Does:    Returns the time of day in the proper 24hr or 12hr format
-- Purpose:         To give players the option for time display formatting, but also to ensure 24hr/12hr standards are there as typically in the EU people often use the 24hr clock, whilst in the US it is the 12hr clock.
GRM.GetFormatTime = function ( hour , min )
    local morning = true;
    local amOrpm = GRM.L ( "pm" );

    -- Swap from military time if set to 12hr
    if not GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][39] then
        if hour > 12 then
            hour = hour - 12;
            morning = false;
        elseif hour == 12 then
            morning = false;
        elseif hour == 0 then
            hour = 12;
        end

        if morning then
            amOrpm = GRM.L ("am" );
        end 
    else
        amOrpm = GRM.L ( "24HR_Notation" );
    end

    -- Formatting...
    if min < 10 then
        min = ( "0" .. min ); -- Example, if it was 6:09, the minutes would only be "9" not "09" - so this looks better.
    end 
    if hour < 10 then
        hour = ( "0" .. hour );
    end

    return hour .. GRM.L ( "HourBreak" ) .. min .. amOrpm;
end

------------------------------------
------ END OF TIME METHODS ---------
------------------------------------

------------------------------------
------ UI FORMATTING HELPERS -------
------------------------------------

-- Method:          GRM.AllignTwoColumns ( array , int )
-- What it Does:    Takes the array of strings and then alligns them by fontsize and width...
-- Purpose:         For UI aesthetics and allignment purposes
GRM.AllignTwoColumns = function ( listOfStrings , spacing )
    -- First, determine longest string width of headers
    local result = "\n";
    GRM_UI.GRM_GroupInfo.InvisFontStringWidthCheck:SetText( listOfStrings[1][1] );         -- need to set string to measurable value
    local longestW = GRM_UI.GRM_GroupInfo.InvisFontStringWidthCheck:GetWidth();
    for i = 2 , #listOfStrings do
        GRM_UI.GRM_GroupInfo.InvisFontStringWidthCheck:SetText( listOfStrings[i][1] );
        local tempW = GRM_UI.GRM_GroupInfo.InvisFontStringWidthCheck:GetWidth();
        if tempW > longestW then
            longestW = tempW;
        end
    end

    -- Now, establish the total necessary width - We are setting spacing at 5.
    longestW = longestW + spacing;
    for i = 1 , #listOfStrings do
        GRM_UI.GRM_GroupInfo.InvisFontStringWidthCheck:SetText( listOfStrings[i][1] );
        while GRM_UI.GRM_GroupInfo.InvisFontStringWidthCheck:GetWidth() < longestW do
            GRM_UI.GRM_GroupInfo.InvisFontStringWidthCheck:SetText ( GRM_UI.GRM_GroupInfo.InvisFontStringWidthCheck:GetText() .. " " );       -- Keep adding spaces until it matches
        end
        result = result .. GRM_UI.GRM_GroupInfo.InvisFontStringWidthCheck:GetText() .. listOfStrings[i][2];
        if i ~= #listOfStrings then
            result = result .. "\n";
        end
    end
    return result;
end


------------------------------------
------ END OF FORMATTING HELPERS ---
------------------------------------


------------------------------------
---- ALT MANAGEMENT METHODS --------
------------------------------------

-- Method:          GRM.GetPlayerClassFromTooltip()
-- What it Does:    Parses the class from the tooltip
-- Purpose:         To determine the mouseover class for matching the player properly
GRM.GetPlayerClassFromTooltip = function()
    local result = "";
    if GameTooltip:IsVisible() then
        -- Go through all the classes, see what we find.
        local toolTipString = GameTooltipTextLeft3:GetText();
        for i = 1 , #AllClasses do
            if string.find ( toolTipString , GRM.L ( "R_" .. AllClasses[i] ) ) ~= nil then          -- "The R_ appended to the front is to signify it is a system region bound, not language
                result = string.upper ( AllClasses[i] );
                break;
            end
        end
    end
    return result;
end

-- Method:          GRM.GetPlayerLevelFromTooltip()
-- What it Does:    Parses the Level from the tooltip
-- Purpose:         To determine the mouseover level for matching the player properly
GRM.GetPlayerLevelFromTooltip = function()
    local result = -1;
    if GameTooltip:IsVisible() then
        local toolTipString = GameTooltipTextLeft3:GetText();

        for i = 1 , #toolTipString do
            if tonumber ( string.sub ( toolTipString , i , i ) ) ~= nil then
                -- number found!
                local j = i;
                while tonumber ( string.sub ( toolTipString , j , j ) ) ~= nil and j <= #toolTipString do
                    j = j + 1;
                end
                result = tonumber ( string.sub ( toolTipString , i , j ) );
                break;
            end
        end
    end
    return result;
end

-- Method:          GRM.GetRosterName ( button , boolean )
-- Method:          To return the current mouseover name of the given button, with the server appended.
-- Purpose:         Need the full name-server, untruncated, to be able to correctly identify the player in database, in case 2 players with same name, but diff. servers
GRM.GetRosterName = function ( button , isMouseClick )
    local name = "";
    if not GRM_G.pause or isMouseClick then
        local memberInfo = button.memberInfo;
        name = memberInfo.name;
        local serverName = select ( 7 , GetPlayerInfoByGUID ( memberInfo.guid ) );
        if serverName ~= nil then
            if serverName == "" then
                name = name .. "-" .. GRM_G.realmName;
            else
                name = name .. "-" .. serverName;
            end
        end
    end
    return name;
end

-- Method:          GRM.InitializeRosterButtons()
-- What it Does:    Initializes, one time, the script handlers for the roster frames
-- Purpose:         So main player popup window appears properly 
GRM.InitializeRosterButtons = function()
    local memberFrame = CommunitiesFrame.MemberList;
    local buttons = memberFrame.ListScrollFrame.buttons;
    for i = 1 , #buttons do
        buttons[i]:HookScript ( "OnEnter" , function ()
            local name = GRM.GetRosterName ( buttons[i] , false  );
            if name ~= "" then
                GRM_G.currentName = name;
                GRM.SubFrameCheck();
                GRM.PopulateMemberDetails ( GRM_G.currentName );
                if not GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
                    GRM_UI.GRM_MemberDetailMetaData:Show();
                end
            end
        end);

        buttons[i]:HookScript ( "OnClick" , function ( self , button )
            if button == "LeftButton" then
                local nameCopy = false;
                if IsShiftKeyDown() then
                    nameCopy = true;
                end

                local name = GRM.GetRosterName ( buttons[i] , true  );
                if name ~= "" then
                    if not nameCopy then
                        GRM_G.currentName = name;
                        GRM.SubFrameCheck();
                        GRM.PopulateMemberDetails ( GRM_G.currentName );
                        if not GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
                            GRM_UI.GRM_MemberDetailMetaData:Show();
                        end
                    else
                        GRM.GR_Roster_Click ( name );
                    end
                end
            end
        end);
    end
end

-- Method:              GRM.RosterFrame()
-- What it Does:        Acts as the OnUpdate handler for hiding the frame when necessary and keeping the player presence status and time in zone up to date.
-- Purpose:             Quality of Life UI controls!
GRM.RosterFrame = function()
    local cFrame = CommunitiesFrame;
    local guildData = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];

    if GRM_G.pause and not GRM_UI.GRM_MemberDetailMetaData:IsVisible() and not CommunitiesFrame.GuildMemberDetailFrame:IsVisible() then
        GRM_G.pause = false;
    end

    if not cFrame.MemberList.ListScrollFrame:IsMouseOver ( 4 , -20 , -4 , 30 ) and not GRM_G.pause then
        if ( not cFrame.MemberList.ListScrollFrame:IsMouseOver ( 4 , -20 , -4 , 30 ) and not DropDownList1MenuBackdrop:IsMouseOver ( 2 , -2 , -2 , 2 ) and not StaticPopup1:IsMouseOver ( 2 , -2 , -2 , 2 ) and not GRM_UI.GRM_MemberDetailMetaData:IsMouseOver ( 1 , -1 , -30 , 1 ) ) or 
            ( not GRM_UI.GRM_MemberDetailMetaData:IsVisible() ) then  -- If player is moused over side window, it will not hide it!
            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
                GRM.ClearAllFrames( true );
            end
        end
    end

    -- Keep this data onUpdate handled...
    if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:IsVisible() then
        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( guildData[GRM_G.currentNameIndex][32] ) );
    end

    if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:IsVisible() then
        if guildData[GRM_G.currentNameIndex][33] or name == GRM_G.addonPlayerName then
            if guildData[GRM_G.currentNameIndex][34] == 0 then
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetTextColor ( 0.12 , 1.0 , 0.0 , 1.0 );
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetText ( GRM.L ( "( Active )" ) );
            elseif guildData[GRM_G.currentNameIndex][34] == 1 then
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetTextColor ( 1.0 , 0.96 , 0.41 , 1.0 );
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetText ( GRM.L ( "( AFK )" ) );
            else
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetTextColor ( 0.77 , 0.12 , 0.23 , 1.0 );
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetText ( GRM.L ( "( Busy )" ) );
            end
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:Show();
        elseif guildData[GRM_G.currentNameIndex][30] then
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetTextColor ( 0.87 , 0.44 , 0.0 , 1.0 );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetText ( GRM.L ( "( Mobile )" ) );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:Show();
        elseif not guildData[GRM_G.currentNameIndex][33] then
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetText ( GRM.L ( "( Offline )" ) );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:Show();
        else
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:Hide();
        end
    end

    if not cFrame:IsVisible() or ( cFrame:IsVisible() and cFrame.MemberList:IsDisplayingProfessions() ) then
        GRM.ClearAllFrames( true );         -- Reset frames and hide metadata frame...
    end

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
        result = { -32 , -120 };
    end
    return result;
end

-- Method:          GRM.PopulateAltFrames(string, int , int )
-- What it Does:    This generates the alt frames in the main addon metadata detail frame
-- Purpose:         Clean formatting of the alt frames.
GRM.PopulateAltFrames = function ( index1 )
    -- let's start by prepping the frames.
    local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index1][11];
    local numAlts = #listOfAlts

    if numAlts < 13 then
        local butPos = GRM.AltButtonPos ( numAlts );
        GRM_UI.GRM_AddAltButton:SetPoint ( "TOP" , GRM_UI.GRM_CoreAltFrame , butPos[1] , butPos[2] );
        GRM_UI.GRM_AddAltButton:Show();
        GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrame:Hide();
        -- now, let's populate them
        if numAlts > 0 then
            local result = GRM.SlimName ( listOfAlts[1][1] );
            if listOfAlts[1][5] == true then  --- this person is the main!
                result = result .. "\n|cffff0000" .. GRM.L ( "(main)" );
            end
            GRM_UI.GRM_CoreAltFrame.GRM_AltName1:SetText ( result );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName1:SetTextColor ( listOfAlts[1][2] , listOfAlts[1][3] , listOfAlts[1][4] , 1.0 );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName1:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AltName1:Hide();
        end
        if numAlts > 1 then
            GRM_UI.GRM_CoreAltFrame.GRM_AltName2:SetText ( GRM.SlimName ( listOfAlts[2][1] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName2:SetTextColor ( listOfAlts[2][2] , listOfAlts[2][3] , listOfAlts[2][4] , 1.0 );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName2:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AltName2:Hide();
        end
        if numAlts > 2 then
            GRM_UI.GRM_CoreAltFrame.GRM_AltName3:SetText ( GRM.SlimName ( listOfAlts[3][1] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName3:SetTextColor ( listOfAlts[3][2] , listOfAlts[3][3] , listOfAlts[3][4] , 1.0 );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName3:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AltName3:Hide();
        end
        if numAlts > 3 then
            GRM_UI.GRM_CoreAltFrame.GRM_AltName4:SetText ( GRM.SlimName ( listOfAlts[4][1] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName4:SetTextColor ( listOfAlts[4][2] , listOfAlts[4][3] , listOfAlts[4][4] , 1.0 );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName4:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AltName4:Hide();
        end
        if numAlts > 4 then
            GRM_UI.GRM_CoreAltFrame.GRM_AltName5:SetText ( GRM.SlimName ( listOfAlts[5][1] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName5:SetTextColor ( listOfAlts[5][2] , listOfAlts[5][3] , listOfAlts[5][4] , 1.0 );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName5:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AltName5:Hide();
        end
        if numAlts > 5 then
            GRM_UI.GRM_CoreAltFrame.GRM_AltName6:SetText ( GRM.SlimName ( listOfAlts[6][1] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName6:SetTextColor ( listOfAlts[6][2] , listOfAlts[6][3] , listOfAlts[6][4] , 1.0 );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName6:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AltName6:Hide();
        end
        if numAlts > 6 then
            GRM_UI.GRM_CoreAltFrame.GRM_AltName7:SetText ( GRM.SlimName ( listOfAlts[7][1] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName7:SetTextColor ( listOfAlts[7][2] , listOfAlts[7][3] , listOfAlts[7][4] , 1.0 );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName7:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AltName7:Hide();
        end
        if numAlts > 7 then
            GRM_UI.GRM_CoreAltFrame.GRM_AltName8:SetText ( GRM.SlimName ( listOfAlts[8][1] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName8:SetTextColor ( listOfAlts[8][2] , listOfAlts[8][3] , listOfAlts[8][4] , 1.0 );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName8:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AltName8:Hide();
        end
        if numAlts > 8 then
            GRM_UI.GRM_CoreAltFrame.GRM_AltName9:SetText ( GRM.SlimName ( listOfAlts[9][1] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName9:SetTextColor ( listOfAlts[9][2] , listOfAlts[9][3] , listOfAlts[9][4] , 1.0 );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName9:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AltName9:Hide();
        end
        if numAlts > 9 then
            GRM_UI.GRM_CoreAltFrame.GRM_AltName10:SetText ( GRM.SlimName ( listOfAlts[10][1] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName10:SetTextColor ( listOfAlts[10][2] , listOfAlts[10][3] , listOfAlts[10][4] , 1.0 );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName10:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AltName10:Hide();
        end
        if numAlts > 10 then
            GRM_UI.GRM_CoreAltFrame.GRM_AltName11:SetText ( GRM.SlimName ( listOfAlts[11][1] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName11:SetTextColor ( listOfAlts[11][2] , listOfAlts[11][3] , listOfAlts[11][4] , 1.0 );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName11:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AltName11:Hide();
        end
        if numAlts > 11 then
            GRM_UI.GRM_CoreAltFrame.GRM_AltName12:SetText ( GRM.SlimName ( listOfAlts[12][1] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName12:SetTextColor ( listOfAlts[12][2] , listOfAlts[12][3] , listOfAlts[12][4] , 1.0 );
            GRM_UI.GRM_CoreAltFrame.GRM_AltName12:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AltName12:Hide();
        end
    
    else

        --- ALT SCROLL FRAME IF PLAYER HAS MORE THAN 12 ALTS!!!
        GRM_UI.GRM_AddAltButton:Hide();
        GRM_UI.GRM_CoreAltFrame.GRM_AltName1:Hide();GRM_UI.GRM_CoreAltFrame.GRM_AltName2:Hide();GRM_UI.GRM_CoreAltFrame.GRM_AltName3:Hide();GRM_UI.GRM_CoreAltFrame.GRM_AltName4:Hide();GRM_UI.GRM_CoreAltFrame.GRM_AltName5:Hide();GRM_UI.GRM_CoreAltFrame.GRM_AltName6:Hide();GRM_UI.GRM_CoreAltFrame.GRM_AltName7:Hide();
        GRM_UI.GRM_CoreAltFrame.GRM_AltName8:Hide();GRM_UI.GRM_CoreAltFrame.GRM_AltName9:Hide();GRM_UI.GRM_CoreAltFrame.GRM_AltName10:Hide();GRM_UI.GRM_CoreAltFrame.GRM_AltName11:Hide();GRM_UI.GRM_CoreAltFrame.GRM_AltName12:Hide();
        GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrame:Show();
        GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame:Show();
        local scrollHeight = 0;
        local scrollWidth = 128;
        local buffer = 1;

        GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons = GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons or {};  -- Create a table for the Buttons.
        -- populating the window correctly.
        for i = 1 , numAlts do
            --GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index1][11]
            -- if font string is not created, do so.
            if not GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons[i] then
                local tempButton = CreateFrame ( "Button" , "GRM_AltAdded" .. i , GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame ); -- Names each Button 1 increment up
                GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons[i] = { tempButton , tempButton:CreateFontString ( "GRM_AltAddedText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) };
            end

            if i == numAlts and #GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons > numAlts then
                for j = numAlts + 1 , #GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons do
                    GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons[j][1]:Hide();
                end
            end

            local AltButtons = GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons[i][1];
            local AltButtonsText = GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons[i][2];
            AltButtons:SetWidth ( 65 );
            AltButtons:SetHeight ( 15 );
            AltButtons:RegisterForClicks( "RightButtonDown" , "LeftButtonDown" );

            -- Check if main
            local result = GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][ index1 ][11][i][1] );
            if i == 1 then
                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][ index1 ][11][i][5] == true then  --- this person is the main!
                    result = result .. "\n|cffff0000" .. GRM.L ( "(main)" );
                    AltButtonsText:SetWordWrap ( true );
                end
            else
                AltButtonsText:SetWordWrap ( false );
            end
            AltButtonsText:SetText ( result );
            AltButtonsText:SetTextColor ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][ index1 ][11][i][2] , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][ index1 ][11][i][3] , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][ index1 ][11][i][4] , 1.0 );
            AltButtonsText:SetWidth ( 63 );
            
            AltButtonsText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 7.5 );
            AltButtonsText:SetPoint ( "CENTER" , AltButtons );
            AltButtonsText:SetJustifyH ( "CENTER" );

            -- Logic
            AltButtons:SetScript ( "OnClick" , function ( self , button )
                if button == "RightButton" then
                    -- Parse the button number, so the alt position can be identified...
                    local altNum;
                    local isMain = false;
                    if tonumber ( string.sub ( self:GetName() , #self:GetName() - 1 ) ) ~= nil then
                        altNum = tonumber ( string.sub ( self:GetName() , #self:GetName() - 1 ) );
                    else
                        altNum = tonumber ( string.sub ( self:GetName() , #self:GetName() ) );
                    end

                    -- Ok, populate the buttons properly...
                    GRM_G.pause = true;
                    local cursorX , cursorY = GetCursorPosition();
                    GRM_UI.GRM_altDropDownOptions:ClearAllPoints();
                    GRM_UI.GRM_altDropDownOptions:SetPoint( "TOPLEFT" , UIParent , "BOTTOMLEFT" , cursorX , cursorY );

                    if string.find ( AltButtonsText:GetText() , GRM.L ( "(main)" ) ) == nil then
                        GRM_UI.GRM_altSetMainButtonText:SetText ( GRM.L ( "Set as Main" ) );
                        GRM_UI.GRM_altOptionsText:SetText ( AltButtonsText:GetText() );
                    else -- player IS the main... place option to Demote From Main rahter than set as main.
                        GRM_UI.GRM_altSetMainButtonText:SetText ( GRM.L ( "Set as Alt" ) );
                        isMain = true;
                        GRM_UI.GRM_altOptionsText:SetText ( string.sub ( AltButtonsText:GetText() , 1 , string.find ( AltButtonsText:GetText() , "\n" ) - 1 ) );
                    end

                    
                    local width = 70;
                    if GRM_UI.GRM_altOptionsText:GetStringWidth() + 15 > width then       -- For scaling the frame based on size of player name.
                        width = GRM_UI.GRM_altOptionsText:GetStringWidth() + 15;
                    end
                    if GRM_UI.GRM_altSetMainButtonText:GetStringWidth() + 15 > width then
                        width = GRM_UI.GRM_altSetMainButtonText:GetStringWidth() + 15;
                    end
                    if GRM_UI.GRM_altRemoveButtonText:GetStringWidth() + 15 > width then
                        width = GRM_UI.GRM_altRemoveButtonText:GetStringWidth() + 15;
                    end
                    if GRM_UI.GRM_altFrameCancelButtonText:GetStringWidth() + 15 > width then
                        width = GRM_UI.GRM_altFrameCancelButtonText:GetStringWidth() + 15;
                    end
                    GRM_UI.GRM_altDropDownOptions:SetSize ( width , 92 );
                    GRM_UI.GRM_altDropDownOptions:Show();

                    GRM_UI.GRM_altRemoveButtonText:SetText ( GRM.L ( "Remove" ) );

                    -- Set the Global info now!
                    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == GRM_G.currentName then
                            GRM_G.selectedAlt = { GRM_G.currentName , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11][altNum][1] , GRM_G.guildName , isMain };
                            break;
                        end
                    end
                elseif button == "LeftButton" then
                    if not IsShiftKeyDown() then
                        if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:IsVisible() and not GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                            -- This makes the main window the alt that was clicked on! TempAltName is saved when mouseover action occurs.
                            if GRM_G.tempAltName ~= "" then
                                GRM.SelectPlayerOnRoster ( GRM_G.tempAltName );
                            end
                        end
                    else
                        if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:IsMouseOver ( 2 , -2 , -2 , 2 ) then
                            GRM_G.tempAltName = GRM_G.currentName;
                        end
                        if GRM_G.tempAltName ~= "" then
                            GRM.GR_Roster_Click ( GRM_G.tempAltName );
                            GRM_G.tempAltName = "";
                        end
                    end
                end
            end);
            
            -- Now let's pin it!
            if i == 1 then
                AltButtons:SetPoint( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame , 0 , - 1 );
                scrollHeight = scrollHeight + AltButtons:GetHeight();
            elseif i == 2 then
                AltButtons:SetPoint( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons[i - 1][1] , "TOPRIGHT" , 1 , 0 );
            else
                AltButtons:SetPoint( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons[i - 2][1] , "BOTTOMLEFT" , 0 , - buffer );
                if i % 2 ~= 0 then
                    scrollHeight = scrollHeight + AltButtons:GetHeight() + buffer;
                end
            end
            -- Ok, let's place the button now!
            if i == numAlts then
                GRM_UI.GRM_AddAltButton2:SetPoint( "TOPLEFT" , GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons[numAlts - 1][1] , "BOTTOMLEFT" , 0 , - buffer );
                if numAlts % 2 == 0 then
                    scrollHeight = scrollHeight + AltButtons:GetHeight() + buffer;
                end
                GRM_UI.GRM_AddAltButton2:Show();
            end
            AltButtons:Show();
        end

        

        -- Update the size -- it either grows or it shrinks!
        GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame:SetSize ( scrollWidth , scrollHeight );

        --Set Slider Parameters ( has to be done after the above details are placed )
        local scrollMax = ( scrollHeight - 90 ) + ( buffer * .5 );
        if scrollMax < 0 then
            scrollMax = 0;
        end
        
        GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
        -- Mousewheel Scrolling Logic
        GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrame:EnableMouseWheel( true );
        GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrame:SetScript( "OnMouseWheel" , function( _ , delta )
            local current = GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrameSlider:GetValue();
            
            if IsShiftKeyDown() and delta > 0 then
                GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrameSlider:SetValue ( 0 );
            elseif IsShiftKeyDown() and delta < 0 then
                GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrameSlider:SetValue ( scrollMax );
            elseif delta < 0 and current < scrollMax then
                GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrameSlider:SetValue ( current + 20 );
            elseif delta > 0 and current > 1 then
                GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrameSlider:SetValue ( current - 20 );
            end
        end);

        
    end
    GRM_UI.GRM_CoreAltFrame:Show();
end

-- Method:          GRM.GetPlayerClass ( string )
-- What it Does:    Returns the string name of the class that is also region compatible
-- Purpose:         Useful in UI design to pull the class so you can pull the class RGB colors, but there can be other uses too.
GRM.GetPlayerClass = function ( playerName )
    local class = "";
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do      
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == playerName then
            class = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][9];
            break;
        end
    end
    if class == "" then
        for i = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do      
            if GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == playerName then
                class = GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][9];
                break;
            end
        end
    end
    return class;
end

-- Method:          GRM.GetClassColorRGB ( string )
-- What it Does:    Returns the 0-1 RGB color scale for the player class
-- Purpose:         Easy class color tagging for UI feature.
GRM.GetClassColorRGB = function ( className , getHex )
    -- Defaults to color white if unable to identify.
    local result = { 1 , 1 , 1 };
    className = string.upper ( string.gsub ( className , " " , "" ) ); -- just to ensure formatitng properly
    if className == "DEATHKNIGHT" then
        if getHex then
            result = "|CFFC41F3B";
        else
            result = { 0.77 , 0.12 , 0.23 };
        end
    elseif className == "DEMONHUNTER" then
        if getHex then
            result = "|CFFA330C9";
        else
            result = { 0.64 , 0.19 , 0.79 };
        end
    elseif className == "DRUID" then
        if getHex then
            result = "|CFFFF7D0A";
        else
            result = { 1.00 , 0.49 , 0.04 };
        end
    elseif className == "HUNTER" then
        if getHex then
            result = "|CFFABD473";
        else
            result = { 0.67 , 0.83 , 0.45 };
        end
    elseif className == "MAGE" then
        if getHex then
            result = "|CFF69CCF0";
        else
            result = { 0.41 , 0.80 , 0.94 };
        end
    elseif className == "MONK" then
        if getHex then
            result = "|CFF00FF96";
        else
            result = { 0.00 , 1.00 , 0.59 };
        end
    elseif className == "PALADIN" then
        if getHex then
            result = "|CFFF58CBA";
        else
            result = { 0.96 , 0.55 , 0.73 };
        end
    elseif className == "PRIEST" then
        if getHex then
            result = "|CFFFFFFFF";
        else
            result = { 1.00 , 1.00 , 1.00 };
        end
    elseif className == "ROGUE" then
        if getHex then
            result = "|CFFFFF569";
        else
            result = { 1.00 , 0.96 , 0.41 };
        end
    elseif className == "SHAMAN" then
        if getHex then
            result = "|CFF0070DE";
        else
            result = { 0.00 , 0.44 , 0.87 };
        end
    elseif className == "WARLOCK" then
        if getHex then
            result = "|CFF9482C9";
        else
            result = { 0.58 , 0.51 , 0.79 };
        end
    elseif className == "WARRIOR" then
        if getHex then
            result = "|CFFC79C6E";
        else
            result = { 0.78 , 0.61 , 0.43 };
        end
    end
    return result;
end

-- Method:          GRM.GetClassByRGB ( table )
-- What it Does:    Returns the string name of a class based on their RGB colors.
-- Purpose:         Useful when mousing over a string to determine its class.
GRM.GetClassByRGB = function ( r , g , b )
    local result = "";
    if r == 0.77 and g == 0.12 and b == 0.23 then
        result = "DEATHKNIGHT";
    elseif r == 0.64 and g == 0.19 and b == 0.79 then
        result = "DEMONHUNTER";
    elseif r == 1.00 and g == 0.49 and b == 0.04 then
        result = "DRUID";
    elseif r == 0.67 and g == 0.83 and b == 0.45 then
        result = "HUNTER";
    elseif r == 0.41 and g == 0.80 and b == 0.94 then
        result = "MAGE";
    elseif r == 0.00 and g == 1.00 and b == 0.59 then
        result = "MONK";
    elseif r == 0.96 and g == 0.55 and b == 0.73 then
        result = "PALADIN";
    elseif r == 1.00 and g == 1.00 and b == 1.00 then
        result = "PRIEST";
    elseif r == 1.00 and g == 0.96 and b == 0.41 then
        result = "ROGUE";
    elseif r == 0.00 and g == 0.44 and b == 0.87 then
        result = "SHAMAN";
    elseif r == 0.58 and g == 0.51 and b == 0.79 then
        result = "WARLOCK";
    elseif r == 0.78 and g == 0.61 and b == 0.43 then
        result = "WARRIOR";
    elseif r == 0.50 and g == 0.50 and b == 0.50 then
        result = "OFFLINE";
    end
    return result
end

-- Method:          GRM.GetStringClassColorByName ( string )
-- What it Does:    Returns the RGB Hex code of the given class of the player named
-- Purpose:         Useful for carrying over class name with tagged colors into a string, without needing to change the hwole string's color
GRM.GetStringClassColorByName = function ( name , notCurrentlyInGuild )
    local tempDatabase;
    if notCurrentlyInGuild ~= nil and notCurrentlyInGuild then
        tempDatabase = GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    else
        tempDatabase = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];           -- This helps avoid issues that could cause stutter by more than 1 thing accessing database at same time.
    end
    local result = "";
    local serverNameFound = false;
    -- If it is found, then you are on a merged realm server. If it is not found, you are NOT on a merged realm server.
    if string.find ( name , "-" ) ~= nil then
        serverNameFound = true;
    end
    -- let's concatenate the server on there for NON merged realm guilds
    if not serverNameFound then
        name = name .. "-" .. GRM_G.realmName;
    end
    for j = 2 , #tempDatabase do  -- Scanning through all entries
        if name == tempDatabase[j][1] then -- Matching member leaving to guild saved entry
            local className = tempDatabase[j][9];
            if className == "DEATHKNIGHT" then
                result = "|CFFC41F3B";
            elseif className == "DEMONHUNTER" then
                result = "|CFFA330C9";
            elseif className == "DRUID" then
                result = "|CFFFF7D0A";
            elseif className == "HUNTER" then
                result = "|CFFABD473";
            elseif className == "MAGE" then
                result = "|CFF69CCF0";
            elseif className == "MONK" then
                result = "|CFF00FF96";
            elseif className == "PALADIN" then
                result = "|CFFF58CBA";
            elseif className == "PRIEST" then
                result = "|CFFFFFFFF";
            elseif className == "ROGUE" then
                result = "|CFFFFF569";
            elseif className == "SHAMAN" then
                result = "|CFF0070DE";
            elseif className == "WARLOCK" then
                result = "|CFF9482C9";
            elseif className == "WARRIOR" then
                result = "|CFFC79C6E";
            end
            break
        end
    end
    return result;
end

-- Method:          GRM.GetClassifiedName ( string , boolean )
-- What it Does:    Returns the player's name as a string, with the proper class coloring
-- Purpose:         Nice, simple UI feature for ease of knowing person's class by name color.
GRM.GetClassifiedName = function ( playerFullName , serverFree )
    local result = GRM.GetStringClassColorByName ( playerFullName );
    if result == "" then
        if serverFree then 
            result = GRM.SlimName ( playerFullName );
        else
            result = playerFullName;
        end
    else
        if serverFree then
            result = result .. GRM.SlimName ( playerFullName ) .. "|r";
        else
            result = result .. playerFullName .. "|r";
        end
    end
    return result
end

-- Method:          GRM.rgbToHex ( array )
-- What it Does:    Returns the hexadecimal code in modified string format for WOW addons to display the string that given rgb color
-- Purpose:         UI feature for easy fontstring coloring management.
GRM.rgbToHex = function ( rgbTable )
    local hexadec = ""
	for i = 1 , #rgbTable do
		local hex = "";

        -- Hexadecimal algorithm
		while ( rgbTable[i] > 0 ) do
			local index = math.fmod ( rgbTable[i] , 16 ) + 1;
			rgbTable[i] = math.floor ( rgbTable[i] / 16);
			hex = string.sub ( "0123456789ABCDEF" , index , index ) .. hex;	
		end

		if #hex == 0 then
			hex = "00";
        elseif #hex == 1 then
			hex = "0" .. hex;
		end

		hexadec = hexadec .. hex
    end
    -- add the |CFF so the warcraft game knows to acknowledge the hex code
    return "|CFF" .. hexadec;
end

-- Method:          ConvertRGBScale ( float , boolean )
-- What it Does:    Converts any RGB values on 1.0 scale to 255 scale, or the other way around
-- Purpose:         255 is standard RGB scaling, which I am personally comfortable with, but Blizz's internal system uses 1.0 scale. This is just QoL
GRM.ConvertRGBScale = function ( value , to255 )
    -- 1.0 scale to 255 scale
    if to255 then
        value = math.floor ( ( value * 255 ) + 0.5 );
    else
        value = value / 255;
    end
    return value
end

-- Method:          GRM.PlayerHasAltsOrIsMain ( string )
-- What it Does:    Returns true if the player has at least 1 alt
-- Purpose:         Useful to save resources to know if a person has alts. No need to do unnecessary alt maintenance or checks otherwise.
GRM.PlayerHasAltsOrIsMain = function ( playerName )
    local result = false
    local roster = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    for j = 2 , #roster do  -- Scanning through all entries
        if roster[j][1] == playerName then
                if roster[j][10] or #roster[j][11] > 0 then
                    result = true;
                end
            break;
        end
    end
    return result;
end

-- Method:          GRM.RemoveAlt(string , string , boolean , int , boolean )
-- What it Does:    Detags the given altName to that set of toons.
-- Purpose:         Alt management, so whoever has addon installed can tag player.
GRM.RemoveAlt = function ( playerName , altName , isSync , syncTimeStamp , errorProtection )

    -- To protect the data if someone is sending you corrupted, broken, or nefarious alt info...
    if errorProtection then
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do      
            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == playerName then
                for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11] do
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11][i][1] == altName then
                        table.remove ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11] , i );
                        break;
                    end
                end
                break;
            end
        end
        return
    end

    local isRemoveMain = false;
    local epochTime;
    if isSync then
        epochTime = syncTimeStamp;
    else
        epochTime = time();
    end

    if playerName ~= altName then
        local index1 = -1;
        local altIndex1 = -1;
        local count = 0;

        -- This block is mainly for resource efficiency, to prevent the blocks from getting too nested, and to store index location for quick access.
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
            if index1 == -1 and GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == playerName then        -- Identify position of player
                count = count + 1;
                index1 = j;
            end
            if altIndex1 == -1 and GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == altName then           -- Pull altName to attach class on Color
                count = count + 1;
                altIndex1 = j;
                -- Need to preserve the list, in the case of syncing to live update the frames if they are on the alt of the alt.
                if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11] > 0 then
                    GRM_G.selectedAltList = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11];
                end
                if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11] > 1 and GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][10] then -- No need to report if the person is removing the last alt. No need to set oneself as main.
                    isRemoveMain = true;
                end
            end
            if count == 2 then
                break;
            end
        end
        if index1 == -1 then
            -- Erroenous data, abort...
            GRM.RemoveAlt ( altName , playerName , isSync , syncTimeStamp , errorProtection );
            return
        end
        -- For protections, in case the player is trying to send you bad data... 
        if altIndex1 == -1 then
            local syncRankFilter = GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15];
            if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][35] then
                syncRankFilter = GuildControlGetNumRanks() - 1;
            end
            GRMsync.SendMessage ( "GRM_SYNC" , GRM_G.PatchDayString .. "?GRM_RMVERR?" .. syncRankFilter .. "?" .. playerName .. "?" .. altName , "SLASH_CMD_GUILD");
            return
        end
        
        -- Removing the alt from all of the player's alts.'
        local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index1][11];
        if #listOfAlts > 0 then                                                                                                     -- There is more than 1 alt for new alt to be added to
            for i = 1 , #listOfAlts do  
                if listOfAlts[i][1] ~= altName then                                                                                 -- Cycle through previously known alt names to add new on each, one by one.
                    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do                                                             -- Need to now cycle through all toons in the guild to set the alt
                        if listOfAlts[i][1] == GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] then                                       -- name on current focus altList found in the metadata and is not the alt to be removed.
                            -- Now, we have the list!
                            for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11] do
                                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11][m][1] == altName then
                                    table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][37] , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11][m] ) -- Adding the alt to removed alts list
                                    GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][37][ #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][37] ][6] = epochTime;
                                    table.remove ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11] , m );     -- removing the alt
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
        for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index1][11] do
            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index1][11][i][1] == altName then
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index1][37] , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index1][11][i] ) -- Adding the alt to removed alts list
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index1][37][ #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index1][37] ][6] = epochTime;
                table.remove ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index1][11] , i );
                break;
            end
        end
        -- Resetting the alt's list
        if isRemoveMain then 
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex1][10] = false;
        end
        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex1][11] = nil;
        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex1][11] = {};
        -- Insta update the frames!
        if GRM_UI.GRM_MemberDetailMetaData ~= nil and GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
            local altFound = false;
            if #GRM_G.selectedAltList > 0 then
                for m = 1 , #GRM_G.selectedAltList do
                    if GRM_G.selectedAltList[m][1] == GRM_G.currentName then
                        -- Alt is found! Let's update the alt frames!
                        altFound = true;
                        for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == GRM_G.selectedAltList[m][1] then
                                -- woot! Now have the index of the alt and can successfully populate the alt frames.
                                GRM.PopulateAltFrames ( i );
                            end
                        end
                        break;
                    end
                end
            end
            -- If it is just the player's same frame, then update it!
            if not altFound and playerName == GRM_G.currentName then
                GRM.PopulateAltFrames ( index1 );
            end
        end       
    end
end

-- Method:          GRM.RemovePlayerFromRemovedAltTable( string )
-- What it Does:    When a player removes an alt, it stores that removal in a special table for syncing purposes.
--                  If the alt is re-added, it removes the player from the removed list
-- Purpose:         Syncing data needs timestamps and thus needs good table management of the metadata of add/remove alts lists.
GRM.RemovePlayerFromRemovedAltTable = function ( name , index )
    if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index][37] > 0 then
        for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index][37] do
            if name == GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index][37][i][1] then
                table.remove ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index][37] , i );
                break;
            end
        end
    end
end
    
-- Method:          GRM.AddAlt (string,string,boolean,int)
-- What it Does:    Tags toon to a player's set of alts. It will tag them not just to the given player, but reverse tag itself to all of the alts.
-- Purpose:         Organizing a player and their alts.
GRM.AddAlt = function ( playerName , altName , isSync , syncTimeStamp )

    if playerName ~= altName then
        -- First, let's identify player index, then identify the classColor of the alt
        local index2 = -1;
        local altIndex2;
        local count = 0;
        local classAlt = "";
        local classMain = "";
        local classColorsAlt , classColorsMain , classColorsTemp;
        local isMain = false;
        local timeEpochAdd;
        local altIsFound = false;
        if isSync then
            timeEpochAdd = syncTimeStamp;
        else
            timeEpochAdd = time();
        end

        -- This block is mainly for resource efficiency, to prevent the blocks from getting too nested, and to store index location for quick access.
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do      
            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == playerName then        -- Identify position of player
                count = count + 1;
                index2 = j;
                classMain = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][9];
            end
            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == altName then           -- Pull altName to attach class on Color
                count = count + 1;
                altIndex2 = j;
                altIsFound = true;
                -- Need to preserve the list, in the case of syncing to live update the frames if they are on the alt of the alt.
                if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11] > 0 then
                    GRM_G.selectedAltList = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11];
                end
                classAlt = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][9];
            end
            if count == 2 then
                break;
            end
        end
        -- For protections, in case the player is trying to send you bad data... 
        if not altIsFound then
            local syncRankFilter = GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15];
            if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][35] then
                syncRankFilter = GuildControlGetNumRanks() - 1;
            end
            GRMsync.SendMessage ( "GRM_SYNC" , GRM_G.PatchDayString .. "?GRM_RMVERR?" .. syncRankFilter .. "?" .. playerName .. "?" .. altName , "SLASH_CMD_GUILD");
            return
        end
        if index2 == -1 then
            GRM.Report ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "Failed to add alt for unknown reason. Try closing Roster window and retrying!" ) );
            return
        end
        
        -- NEED TO VERIFY IT IS NOT AN ALT FIRST!!! it is removing and re-adding if it is same person.
        local isFound = false;
        if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][11] > 0 then
            local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][11];
            
            for m = 1 , #listOfAlts do                                              -- Let's quickly verify that this is not a repeat alt add.
                if listOfAlts[m][1] == playerName then
                    GRM.Report ( GRM.L ( "{name} is Already Listed as an Alt." , GRM.SlimName ( altName ) ) );
                    isFound = true;
                    break;
                end
            end
        end
        -- If player is trying to add this toon to a list that is already on a list then it adds it in reverse
        if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][11] > 0 and #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11] > 0 and not isFound then  -- Oh my! Both players have current lists!!! Remove the alt from his list, add to this new one.
            GRM.RemoveAlt ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][11][1][1] , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][1] , isSync , syncTimeStamp , false );
        end

        -- Main Status check
        isMain = false;
        if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11] > 0 then
            
            for s = 1 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11] do
                if s == 1 then
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] then
                        isMain = true;
                    end
                end
                if not isMain then
                    for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] == GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11][s][1] then
                            -- Ok, let's see if the alt is main...
                            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][10] then
                                isMain = true;
                            end
                            break;
                        end
                    end
                end
                if isMain then
                    GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][10] = false;
                    break;
                end
            end
        end

        -- if the alt has a list... then reverse
        if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][11] > 0 then

            if not isFound then
                -- if the player is main, but the alt has a grouping, let's check if any alts on the list are main. If they are, demote oneself to alt as the group takes priority...
                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] then
                    isMain = false;
                    for s = 1 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][11] do
                        if s == 1 then
                            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][10] then
                                isMain = true;
                            end
                        end
                        if not isMain then
                            for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] == GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][11][s][1] then
                                    -- Ok, let's see if the alt is main...
                                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][10] then
                                        isMain = true;
                                    end
                                    break;
                                end
                            end
                        end
                        if isMain then
                            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] = false;
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:Hide();
                            break;
                        end
                    end
                end
                -- Just in case, let's remove MAIN status if needed.
                GRM.AddAlt ( altName , playerName , isSync , syncTimeStamp );
            end
            
        else
            -- add altName to each of the previously
            local isFound2 = false;
            classColorsAlt = GRM.GetClassColorRGB ( classAlt );
            local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11];
            if #listOfAlts > 0 then                                                                 -- There is more than 1 alt for new alt to be added to
                for i = 1 , #listOfAlts do                                                          -- Cycle through previously known alt names to add new on each, one by one.
                    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do                             -- Need to now cycle through all toons in the guild to set the alt
                        if listOfAlts[i][1] == GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] then       -- name on current focus altList found in the metadata!
                            -- Now, make sure it is not a repeat add!
                            
                            for m = 1 , #listOfAlts do                                              -- Let's quickly verify that this is not a repeat alt add.
                                if listOfAlts[m][1] == altName then
                                    GRM.Report ( GRM.L ( "{name} is Already Listed as an Alt." , GRM.SlimName ( altName ) ) );
                                    isFound2 = true;
                                    break;
                                end
                            end
                            if not isFound2 then
                                classColorsTemp = GRM.GetClassColorRGB ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][9] );
                                table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11] , { altName , classColorsAlt[1] , classColorsAlt[2] , classColorsAlt[3] , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][10] , timeEpochAdd } ); -- altName is added to a currentFocus previously added alt.
                                GRM.RemovePlayerFromRemovedAltTable ( altName , j );
                                table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][11] , { GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] , classColorsTemp[1] , classColorsTemp[2] , classColorsTemp[3] , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][10] , timeEpochAdd } );
                                GRM.RemovePlayerFromRemovedAltTable ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] , altIndex2 );
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
                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] then
                    table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][11] , 1 , { playerName , classColorsMain[1] , classColorsMain[2] , classColorsMain[3] , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] , timeEpochAdd } );
                else
                    table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][11] , { playerName , classColorsMain[1] , classColorsMain[2] , classColorsMain[3] , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] , timeEpochAdd } );
                end
                GRM.RemovePlayerFromRemovedAltTable ( playerName , altIndex2 );
                -- Finally, let's add the alt to the player's currentFocus.
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11] , { altName , classColorsAlt[1] , classColorsAlt[2] , classColorsAlt[3] , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][10] , timeEpochAdd } );
                GRM.RemovePlayerFromRemovedAltTable ( altName , index2 );
            end
            -- Insta update the frames!
            if GRM_UI.GRM_MemberDetailMetaData ~= nil and GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
                -- For use with syncing UI LIVE
                local altFound = false;
                if #GRM_G.selectedAltList > 0 then
                    for m = 1 , #GRM_G.selectedAltList do
                        if GRM_G.selectedAltList[m][1] == GRM_G.currentName then
                            -- Alt is found! Let's update the alt frames!
                            altFound = true;
                            for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == GRM_G.selectedAltList[m][1] then
                                    -- woot! Now have the index of the alt and can successfully populate the alt frames.
                                    GRM.PopulateAltFrames ( i );
                                end
                            end
                            if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11] > 0 and GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][10] then
                                GRM.SetMain ( GRM_G.currentName , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][1] , false , 0 );
                            end
                            break;
                        end
                    end
                end

                if not altFound then
                    local frameName = GRM_G.currentName;
                    if playerName == frameName then
                        GRM.PopulateAltFrames ( index2 );
                    elseif altName == frameName then
                        GRM.PopulateAltFrames ( altIndex2 );
                    end
                    if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11] > 0 and GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][10] then
                        GRM.SetMain ( GRM_G.currentName , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][1] , false , 0 );
                    end
                end
            end
        end
    else
        GRM.Report ( GRM.L ( "{name} cannot become their own alt!" , GRM.SlimName ( playerName ) ) );
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
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == GRM_G.addonPlayerName then
        playerIsFound = true;
            -- Ok, adding the player!
            table.insert ( GRM_PlayerListOfAlts_Save[ GRM_G.FID ][guildIndex] , { GRM_G.addonPlayerName , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][10] , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][9] } );

            -- if the player already is on a list, let's not add them automatically.
            if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][11] == 0 then
                -- Ok, good, let's check the alt list!
                -- Don't want to add them if they are already on a list...
                for j = 2 , #GRM_PlayerListOfAlts_Save[ GRM_G.FID ] do
                    if GRM_PlayerListOfAlts_Save[GRM_G.FID][j][1][1] == GRM_G.guildName then
                        if #GRM_PlayerListOfAlts_Save[ GRM_G.FID ][j] > 2 then                   -- No need if it is just myself... Count of alts is # minus due to index position starting at 2.\
                            local isAdded = false;
                            for r = 2 , #GRM_PlayerListOfAlts_Save[ GRM_G.FID ][j] do
                                -- Make sure it is not the player.
                                if GRM_PlayerListOfAlts_Save[ GRM_G.FID ][j][r][1] ~= GRM_G.addonPlayerName then
                                    if GRM_PlayerListOfAlts_Save[ GRM_G.FID ][j][r][2] then -- if maim
                                        -- ADD ALT HERE!!!!!!
                                        GRM.AddAlt ( GRM_PlayerListOfAlts_Save[ GRM_G.FID ][j][r][1] , GRM_G.addonPlayerName , false , 0 );
                                        isAdded = true;
                                        break;
                                    end
                                end
                            end
                            -- if it was not added, then add it here! No alt was set as main.
                            if not isAdded then
                                -- ADD ALT, just use index 2
                                GRM.AddAlt ( GRM_G.addonPlayerName , GRM_PlayerListOfAlts_Save[ GRM_G.FID ][j][2][1] , false , 0 );
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


-- Method:              GRM.SortMainToTop (int)
-- What it Does:        Sorts the alts list and sets the main to the top.
-- Purpose:             To keep the main as the first name in the list of alts.
GRM.SortMainToTop = function ( index2 )
    local tempList;
    -- Ok, now, let's grab the list and do some sorting!
    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] ~= true then                               -- no need to attempt sorting if they are all alts, none are the main.
        for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11] do                           -- scanning through the list of alts
            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11][i][5] then                         -- if one of them equals the main!
                tempList = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11][i];                    -- Saving main's info to temp holder
                table.remove ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11] , i );             -- removing
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11] , 1 , tempList );  -- Re-adding it to the front and done!
                break
            end
        end
    end
end

-- Method:              GRM.SetMain ( string , string , boolean , int )
-- What it Does:        Sets the player as main, as well as updates that status among the alt grouping.
-- Purpose:             Main/alt management control.
GRM.SetMain = function ( playerName , mainName , isSync , syncTimeStamp )
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
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do      
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == playerName then        -- Identify position of player
            index2 = j;
            -- Establishing list of alts...
            if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11] > 0 then
                GRM_G.selectedAltList = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11];
            end
            if playerName == mainName then                               -- no need to identify an alt if there is none.
                break;
            else
                count = count + 1;
            end
        end
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == mainName then           -- Pull mainName to attach class on Color
            count = count + 1;
            altIndex2 = j;
        end
        if count == 2 then
            break;
        end
    end

    local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11];
    if #listOfAlts > 0 then
        -- Need to tag each alt's list with who is the main.
        for i = 1 , #listOfAlts do
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do                                  -- Cycling through the guild names to find the alt match
                if listOfAlts[i][1] == GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] then            -- Alt location identified!
                    -- Now need to find the name of the alt to tag it.
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == mainName then                -- this alt is the main!
                        if not GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][10] then
                            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][10] = true;                       -- Setting toon as main!
                            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][39] = timeEpochMain;                  -- Setting timeStampOfChange!
                        end
                        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11] do               -- making sure all their alts are listed as notMain
                            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11][m][5] = false;
                        end
                    else
                        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][10] then
                            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][10] = false;                      -- ensure alt is not listed as main
                            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][39] = timeEpochMain;
                        end
                        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11] do               -- identifying who is to be tagged as main
                            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11][m][1] == mainName then
                                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11][m][5] = true;
                            else
                                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11][m][5] = false;        -- tagging everyone not the main as false
                            end
                        end
                    end

                    -- Now, let's sort
                    GRM.SortMainToTop ( j );
                    break
                end
            end            
        end
        -- Do one last pass to set your own alts list proper.
        for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11] do
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11][i][5] = false;
        end
    end

    -- Let's ensure the main is the main!
    if playerName ~= mainName then
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] then
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] = false;
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][39] = timeEpochMain;
        end
        if not GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][10] then
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][10] = true;
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][39] = timeEpochMain;
        end
        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11] do               -- identifying who is to be tagged as main
            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11][m][1] == mainName then
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11][m][5] = true;
            else
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11][m][5] = false;        -- tagging everyone not the main as false
            end
        end
        GRM.SortMainToTop ( index2 );
    else
        if not GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] then
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] = true;
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][39] = timeEpochMain;
        end
    end
    -- Insta update the frames!
    if GRM_UI.GRM_MemberDetailMetaData ~= nil and GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
        local altFound = false;
        if #GRM_G.selectedAltList > 0 then
            for m = 1 , #GRM_G.selectedAltList do
                if GRM_G.selectedAltList[m][1] == GRM_G.currentName then
                    -- Alt is found! Let's update the alt frames!
                    altFound = true;
                    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == GRM_G.selectedAltList[m][1] then
                            -- woot! Now have the index of the alt and can successfully populate the alt frames.
                            GRM.PopulateAltFrames ( i );
                        end
                    end
                    break;
                end
            end
        end
        
        if not altFound then
            local frameName = GRM_G.currentName;
            if playerName == frameName then
                GRM.PopulateAltFrames ( index2 );
            elseif mainName == frameName then
                GRM.PopulateAltFrames ( altIndex2 );
            end
        end
    end
end

-- Method:          GRM.PlayerHasMain( int )
-- What it Does:    Returns true if either the player has a main or is a main themselves
-- Purpose:         Better alt management logic.
GRM.PlayerHasMain = function ( index2 )
    local hasMain = false;

    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] then
        hasMain = true;
    else
        for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11] do
            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11][i][5] then
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
    local focusName = GRM_G.currentName;
    local isMain = false;
    local isAlt1 = false;
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == focusName then
    
            if GRM_UI.GRM_CoreAltFrame.GRM_AltName1:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName1:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][11][1][1];
                isAlt1 = true;
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName2:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName2:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][11][2][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName3:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName3:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][11][3][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName4:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName4:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][11][4][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName5:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName5:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][11][5][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName6:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName6:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][11][6][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName7:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName7:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][11][7][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName8:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName8:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][11][8][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName9:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName9:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][11][9][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName10:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName10:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][11][10][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName11:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName11:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][11][11][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName12:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName12:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][11][12][1];
            elseif ( GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:IsVisible() and GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:IsMouseOver ( 2 , -2 , -2 , 2 ) ) or ( GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:IsVisible() and GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:IsMouseOver ( 2 , -2 , -2 , 2 ) ) or ( GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:IsVisible() and GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:IsMouseOver ( 2 , -2 , -2 , 2 ) ) or GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:IsMouseOver ( 2 , -2 , -2 , 2 ) or GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailDateJoinedTitleTxt:IsMouseOver ( 2 , -2 , -2 , 2 ) then -- Covers both promo date and join date focus.
                altName = focusName;
            else
                -- MOUSE WAS NOT OVER, EVEN ON A RIGHT CLICK OF THE FRAME!!!
                focusName = nil;
                altName = nil;
            end
            break;
        end
    end
    if ( isAlt1 and altName ~= nil and string.find ( GRM_UI.GRM_CoreAltFrame.GRM_AltName1:GetText() , GRM.L ( "(main)" ) ) ~= nil ) then        -- This is the main! Let's parse main out of the name!
        isMain = true;
    elseif altName == focusName and GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:IsVisible() then
        isMain = true;
    end
    return { focusName , altName , isMain };
end


-- Method:              GRM.DemoteFromMain ( string , string , string )
-- What it Does:        If the player is "main" then it removes the main tag to false
-- Purpose:             User Experience (UX) and alt management!
GRM.DemoteFromMain = function ( playerName , mainName , isSync , syncTimeStamp )
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
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do      
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == playerName then   -- Identify position of player
            index2 = j;
            if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11] > 0 then
                GRM_G.selectedAltList = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11];
            end
            if playerName == mainName then                                                                          -- no need to identify an alt if there is none.
                break;
            else
                count = count + 1;
            end
        end
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == mainName then     -- Pull mainName to attach class on Color
            count = count + 1;
            altIndex2 = j;
        end
        if count == 2 then
            break;
        end
    end

    local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11];
    if #listOfAlts > 0 then
        -- Need to tag each alt's list with who is the main.
        for i = 1 , #listOfAlts do
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do                                  -- Cycling through the guild names to find the alt match
                if listOfAlts[i][1] == GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] then            -- Alt location identified!
                    -- Now need to find the name of the alt to tag it.
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == mainName then                -- this alt is the main!
                        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][10] then
                            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][10] = false;                       -- Demoting the toon from main!
                            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][39] = RMVtimeEpochMain;
                        end
                        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11] do               -- making sure all their alts are listed as notMain
                            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11][m][5] = false;
                        end
                    else
                        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11] do               -- identifying who is to be tagged as main
                            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11][m][1] == mainName then
                                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11][m][5] = false;
                            else
                                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11][m][5] = false;        -- tagging everyone not the main as false
                            end
                        end
                    end

                    -- Now, let's sort
                    GRM.SortMainToTop ( j );
                    break
                end
            end            
        end
    end

    -- Let's ensure the main is the main!
    if playerName ~= mainName then
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] then
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] = false;
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][39] = RMVtimeEpochMain;
        end
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][10] then
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][10] = false;
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][altIndex2][39] = RMVtimeEpochMain;
        end
        for m = 1 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11] do               -- identifying who is to be tagged as main
            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11][m][1] == mainName then
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11][m][5] = false;
            else
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][11][m][5] = false;        -- tagging everyone not the main as false
            end
        end
        GRM.SortMainToTop ( index2 );
    else
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] then
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][10] = false;
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][index2][39] = RMVtimeEpochMain;
        end
    end
    -- Insta update the LIVE frames for sync, if player is on a diff. frame.
    if GRM_UI.GRM_MemberDetailMetaData ~= nil and GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
        local altFound = false;
        if #GRM_G.selectedAltList > 0 then
            for m = 1 , #GRM_G.selectedAltList do
                if GRM_G.selectedAltList[m][1] == GRM_G.currentName then
                    -- Alt is found! Let's update the alt frames!
                    altFound = true;
                    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == GRM_G.selectedAltList[m][1] then
                            -- woot! Now have the index of the alt and can successfully populate the alt frames.
                            GRM.PopulateAltFrames ( i );
                        end
                    end
                    break;
                end
            end
        end

        if not altFound then
            local frameName = GRM_G.currentName;
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
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:LockHighlight();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:UnlockHighlight();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:UnlockHighlight();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:UnlockHighlight();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:UnlockHighlight();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:UnlockHighlight();
    GRM_G.currentHighlightIndex = 1;
end

-- Method:          GRM.GetAltTag ( int )
-- What it Does:    Returns the hex value/colored string with the alt or main tag
-- Purpose:         For taggin the autocomplete names to make it easier to see who is and isn't and alt/main
GRM.GetAltTag = function ( value )
    local result = "";
    if value == 1 then
        result = "|cffab0000 " .. GRM.L ( "<M>" );
    elseif value == 2 then
        result = "|cffab0000 " .. GRM.L ( "<A>" );
    end
    return result;
end

-- Method:          GRM.AddAltAutoComplete()
-- What it Does:    Takes the entire list of guildies, then sorts them as player types to be added to alts list
-- Purpose:         Eliminates the possibility of a person entering a fake name of a player no longer in the guild.
GRM.AddAltAutoComplete = function()
    local partName = GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltEditBox:GetText();
    GRM_G.listOfGuildies = nil;
    GRM_G.listOfGuildies = {};
    local guildRoster = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];

    for i = 2 , #guildRoster do
        if guildRoster[i][1] ~= GRM_G.currentName then   -- no need to go through player's own window
            -- Determine alt/main tag
            local tag = 0;
            -- 0 = no tag, 1 = main, 2 = alt
            if guildRoster[i][10] then
                tag = 1;
            else
                for j = 1 , #guildRoster[i][11] do
                    if guildRoster[i][11][j][5] then
                        tag = 2;
                        break;
                    end
                end
            end
            table.insert ( GRM_G.listOfGuildies , { guildRoster[i][1] , guildRoster[i][9] , tag } );
        end
    end
    -- Need to sort "Complex" table
    sort ( GRM_G.listOfGuildies , function ( a , b ) return a[1] < b[1] end );    -- Alphabetizing it for easier parsing for buttontext updating. - This sorts the first index of the 2D array
    
    -- Now, let's identify the names that match
    local count = 0;
    local matchingList = {};
    local found = false;
    local innerFound = false;
    for i = 1 , #GRM_G.listOfGuildies do
        innerFound = false;
        if string.lower ( partName ) == string.lower ( string.sub ( GRM_G.listOfGuildies[i][1] , 1 , #partName ) ) then
            innerFound = true;
            found = true;
            count = count + 1;
            table.insert ( matchingList , GRM_G.listOfGuildies[i] );
        end
        if count > 6 then
            break;
        end
        if innerFound ~= true and found then    -- resource saving
            break;
        end
    end

    -- If No alphabetical matches, try partial
    count = 0;
    if #matchingList == 0 then
        for i = 1 , #GRM_G.listOfGuildies do
            if string.find ( string.lower ( GRM_G.listOfGuildies[i][1] ) , string.lower ( partName ) ) ~= nil then
                count = count + 1;
                table.insert ( matchingList , GRM_G.listOfGuildies[i] );
            end
            if count > 6 then
                break;
            end
        end
    end
    
    -- Populate the buttons now...
    if partName ~= nil and partName ~= "" then
        local resultCount = #matchingList;
        local classColor;
        GRM.ResetAltButtonHighlights();
        if resultCount > 0 then
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText:Hide();
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText2:Hide();
            classColor = GRM.GetClassColorRGB ( matchingList[1][2] , false );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1Text:SetTextColor ( classColor[1] , classColor[2] , classColor[3] );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1Text:SetText ( matchingList[1][1] .. GRM.GetAltTag ( matchingList[1][3] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:Enable();
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:Show();
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameTextBottom:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText:Show();
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText2:Show();
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:Hide();
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameTextBottom:Hide();
            if string.lower ( GRM_G.currentName ) == string.lower ( partName ) then
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText:SetText ( GRM.L ( "Player Cannot Add Themselves as an Alt" ) );
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText2:Hide();
            else
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText:SetText ( GRM.L ( "Player Not Found" ) );
            end
        end

        -- Gotta Get Class Color!!
        if resultCount > 1 then
            classColor = GRM.GetClassColorRGB ( matchingList[2][2] , false );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2Text:SetTextColor ( classColor[1] , classColor[2] , classColor[3] );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2Text:SetText ( matchingList[2][1] .. GRM.GetAltTag ( matchingList[2][3] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:Enable();
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:Hide();
        end
        if resultCount > 2 then
            classColor = GRM.GetClassColorRGB ( matchingList[3][2] , false );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3Text:SetTextColor ( classColor[1] , classColor[2] , classColor[3] );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3Text:SetText ( matchingList[3][1] .. GRM.GetAltTag ( matchingList[3][3] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:Enable();
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:Hide();
        end
        if resultCount > 3 then
            classColor = GRM.GetClassColorRGB ( matchingList[4][2] , false );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4Text:SetTextColor ( classColor[1] , classColor[2] , classColor[3] );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4Text:SetText ( matchingList[4][1] .. GRM.GetAltTag ( matchingList[4][3] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:Enable();
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:Hide();
        end
        if resultCount > 4 then
            classColor = GRM.GetClassColorRGB ( matchingList[5][2] , false );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5Text:SetTextColor ( classColor[1] , classColor[2] , classColor[3] );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5Text:SetText ( matchingList[5][1] .. GRM.GetAltTag ( matchingList[5][3] ) );
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:Enable();
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:Hide();
        end
        if resultCount > 5 then
            if resultCount == 6 then
                classColor = GRM.GetClassColorRGB ( matchingList[6][2] , false );
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6Text:SetTextColor ( classColor[1] , classColor[2] , classColor[3] );
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6Text:SetText ( matchingList[6][1] .. GRM.GetAltTag ( matchingList[6][3] ) );
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:Enable();
            else
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6Text:SetTextColor ( 1 , 1 , 1 );
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6Text:SetText ( "..." );
                GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:Disable();
            end
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:Show();
        else
            GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:Hide();
        end
    else
        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:Hide();
        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:Hide();
        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:Hide();
        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:Hide();
        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:Hide();
        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:Hide();
        GRM.ResetAltButtonHighlights();
        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameTextBottom:Hide();
        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText:SetText ( GRM.L ( "Please Type the Name of the alt" ) );
        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText:Show();
        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrameHelpText2:Show();
    end
end

-- Method:              GRM.KickAllAlts ( string )
-- What it Does:        Bans all listed alts of the player as well and adds them to the ban list. Of note, addons cannot kick players anymore, so this only adds to ban list.
-- Purpose:             QoL. Option to ban players' alts as well if they are getting banned.
GRM.KickAllAlts = function ( playerName )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do      
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == playerName then        -- Identify position of player
        -- Ok, let's parse the player's data!
            local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11];
            if #listOfAlts > 0 then                                  -- There is at least 1 alt
                for m = 1 , #listOfAlts do                           -- Cycling through the alts
                    if GRM_UI.GRM_PopupWindowCheckButton1:GetChecked() or GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_BanAllAltsCheckbox:GetChecked() then     -- Player wants to BAN the alts confirmed!
                        for s = 1 , #listOfAlts do
                            for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] == listOfAlts[s][1] and GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] ~= GRM_G.addonPlayerName then        -- Logic to avoid kicking oneself ( or at least to avoid getting error notification )
                                    -- Set the banned info.
                                    GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][17][1] = true;
                                    GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][17][2] = time();
                                    GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][17][3] = false;
                                    local instructionNote = GRM.L ( "Reason Banned?" ) .. "\n" .. GRM.L ( "Click \"YES\" When Done" );
                                    local result = "";

                                    if GRM_UI.GRM_MemberDetailPopupEditBox:IsVisible() then
                                        result = GRM_UI.GRM_MemberDetailPopupEditBox:GetText();
                                    elseif GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:IsVisible() then
                                        result = GRM.Trim ( GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:GetText() );
                                    end 

                                    if result ~= nil and result ~= instructionNote and result ~= GRM.L ( "Reason Banned?" ) and result ~= "" then
                                        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][18] = result;
                                    elseif result == nil or result == GRM.L ( "Reason Banned?" ) then
                                        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][18] = "";
                                    else
                                        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][18] = result;
                                    end
                                    break;
                                end
                            end
                        end
                        break;
                    else
                        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11][m][1] ~= GRM_G.addonPlayerName then
                        end                       
                    end
                end
            end
            break;
        end
    end
end

-- Method:          GRM.BanSpecificPlayer ( string , boolean )
-- What it Does:    Bans just a specific player, either in the guild database, or the left player database
-- purpose:         To maintain exact function of banning a player without doing other tasks.
GRM.BanSpecificPlayer = function ( playerName , isAlt )
    -- Ok, let's check if this player is already currently in the guild.
    local isFoundInLeft = false;
    local isFoundInGuild = false;
    local indexFound = 0;
    for i = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == playerName then
            isFoundInLeft = true;
            indexFound = i;
            GRM_G.tempAddBanClass = GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][9];
            break;
        end
    end

    if not isFoundInLeft then
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == playerName then
                isFoundInGuild = true;
                indexFound = j;
                GRM_G.tempAddBanClass = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][9];
                break;
            end
        end
    end

    if isFoundInLeft then
        if GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][indexFound][17][1] then
            -- Player was previously banned! This is just an update!
            if not isAlt then
                GRM.Report ( GRM.L ( "{name}'s Ban Info has Been Updated!" , GRM.GetStringClassColorByName ( playerName , true ) .. playerName .. "|r" ) );
            end
        else
            GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][indexFound][17][1] = true;
            GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][indexFound][17][2] = time();
        end
        GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][indexFound][17][3] = false;
        GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][indexFound][18] = banReason;
    
    elseif isFoundInGuild then

        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][indexFound][17][1] then
            -- Player was previously banned! This is just an update!
            if not isAlt then
                GRM.Report ( GRM.L ( "{name}'s Ban Info has Been Updated!" , GRM.GetClassifiedName ( playerName , false ) ) );
            end
        else
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][indexFound][17][1] = true;
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][indexFound][17][2] = time();
        end
        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][indexFound][17][3] = false;
        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][indexFound][18] = banReason;
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
GRM.AddMemberRecord = function ( memberInfo , isReturningMember , oldMemberInfo )

    -- First things first... ensure the player is not already added...
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == memberInfo[1] then
            return
        end
    end
    -- Metadata to track on all players.
    -- Basic Info
    local timeSeconds = time();
    local name = memberInfo[1];
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
    local eventTrackers = { { nil , false , "" } , { nil , false , "" } };  -- Position 1 = anniversary , Position 2 = birthday , 3 = anniversary For Each = { title, date , needsToNotify , SpecialNotes }
    local customNote = { true , 0 , "" , GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][49] , false , "" }; -- { syncEnabled , epochStampOfEdit , "NameOfPlayerWhoEdited" , rankFilterIndex , rankModifiedAtleastOnce , "customNoteString" }

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
    local GUID = memberInfo[15];                -- GUID available as of patch 8.0
    local joinDateIsUnknown = false;
    local promoDateIsUnknown = false;

    -- FOR SYNC PURPOSES!!!
    local joinDateTimestamp = { "" , 0 };
    local promoDateTimestamp = { "" , 0 };
    local listOfRemovedAlts = {};
    local mainStatusChangeTimestamp = {};
    local timeMainStatusAltered = 0;

    -- Returning member info to be carried over.
    if isReturningMember then
        if not oldMemberInfo[19] ~= "< " .. GRM.L ( "Unknown" ) .. " >" then
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
            eventTrackers = oldMemberInfo[22];
            customNote = oldMemberInfo[23];
            rankHistory = oldMemberInfo[25];
            playerLevelOnJoining = oldMemberInfo[26];
            joinDateTimestamp[1] = joinDate;
            joinDateTimestamp[2] = timeSeconds;
        else
            bannedFromGuild = oldMemberInfo[17];
            reasonBanned = oldMemberInfo[18];
        end
    end

    -- For both returning players and new adds
    table.insert ( rankHistory , { rank , string.sub ( joinDate , 1 , string.find ( joinDate , "'" ) + 2 ) , joinDateMeta } );

    table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] , { name , joinDate , joinDateMeta , rank , rankInd , currentLevel , note , officerNote , class , isMainToon ,
        listOfAltsInGuild , dateOfLastPromotion , dateOfLastPromotionMeta , birthday , leftGuildDate , leftGuildDateMeta , bannedFromGuild , reasonBanned , oldRank ,
            oldJoinDate , oldJoinDateMeta , eventTrackers , customNote , lastOnline , rankHistory , playerLevelOnJoining , recommendToKickReported , zone , achievementPoints ,
                isMobile , rep , timePlayerEnteredZone , isOnline , currentStatus , joinDateTimestamp , promoDateTimestamp , listOfRemovedAlts , mainStatusChangeTimestamp , timeMainStatusAltered , joinDateIsUnknown , promoDateIsUnknown , GUID } );  -- 42 so far. (35-39 = sync stamps)
end

-- Method:          GRM.AddMemberToLeftPlayers ( array , string , int , string , int )
-- What it does:    First, it adds a new player to the saved list. This basically builds a metadata profile. Then, we add that player to players that left, then remove it from current guildies list.
-- Purpose:         If a player installs the addon AFTER people have left the guild, for example, you need to know their details to have them on the ban list. This builds a profile if another sync'd player has them banned
--                  as you cannot just add the name as banned, you literally have to build a full metadata file for them for it to work properly in the case that they return to the guild.
GRM.AddMemberToLeftPlayers = function ( memberInfo , leftGuildDate , leftGuildMeta , oldJoinDate , oldJoinDateMeta )
    -- First things first, add them!
    GRM.AddMemberRecord( memberInfo , false , nil );
    -- Ok, now that it is added, what we need to do now is REMOVE the player from the GRM_GuildMemberHistory_Save and then add it to the end of the left player history.
    -- Some updates must be had, however.
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == memberInfo[1] then
            table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][15], leftGuildDate );                                                                 -- leftGuildDate
            table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][16], leftGuildMeta );                                                                 -- leftGuildDateMeta
            table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][25] , { "|cFFC41F3BLeft Guild" , GRM.Trim ( string.sub ( leftGuildDate , 1 , 10 ) ) , leftGuildMeta } );
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][19] = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][4];         -- old Rank on leaving.
            table.insert( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][20] , oldJoinDate );                                                                   -- oldJoinDate
            table.insert( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][21] , oldJoinDateMeta );                                                               -- oldJoinDateMeta

            -- If not banned, then let's ensure we reset his data.
            if not GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][17][1] then
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][17][1] = false;
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][17][2] = 0;
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][17][3] = false;
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][18] = "";
            end
            -- Adding to LeftGuild Player history library
            table.insert ( GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][GRM_G.saveGID] , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j] );
            break;
        end
    end

    -- Now need to remove it from the end position. But should still cycle through just in case over overlapping parallel actions.
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == memberInfo[1] then
            table.remove ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] );
            break;
        end
    end
    
end

-- Method:          GRM.GetMessageRGB( int )
-- What it Does:    Returns the 3 RGB colors colors based on the given index on a 1.0 scale
-- Purpose:         Save on code when need color call. I also did this as a 3 argument return, rather than a single array, just as a proof of concept
--                  since this whole project was also a bit of a Lua learning moment.
GRM.GetMessageRGB = function ( index )
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
    elseif index == 19 then  -- Custom Note
        r = 0.24;
        g = 0.69;
        b = 0.49;
    end

    return r , g , b;
end

-- Method:          GRM.AddLog(int , string)
-- What it Does:    Adds a simple array to the Logreport that includes the indexcode for color, and the included changes as a string
-- Purpose:         For ease in adding to the core log.
GRM.AddLog = function ( indexCode , logEntry )
    table.insert ( GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID] , { indexCode , logEntry } );
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
    elseif ( index == 19 ) then -- For Custom Note
        if LoggingIt then

        else
            chat:AddMessage ( logReport , 0.24 , 0.69 , 0.49 );          -- needs to be updated to unique color.
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

-----------------------------------
--------- SCROLL FRAME LOGIC ------
-----------------------------------

-- Method:          InfiniteScrollNeeeded ( object )
-- What it Does:    Determines if the player has reached the >= 90% of the scrollframe and expands if necessary.
-- Purpose:         Infinite scrolling algorithm... so you smartly load only what is visible and necessary at first.
GRM.InfiniteScrollNeeeded = function ( scrollFrameSlider )
    local _ , maxValue = scrollFrameSlider:GetMinMaxValues();
    local needsRefresh = false;
    if maxValue > scrollFrameSlider.MaxValue and ( scrollFrameSlider:GetValue() / maxValue ) > 0.9 then
        scrollFrameSlider.MaxValue = maxValue;
        scrollFrameSlider.ScrollCount = scrollFrameSlider.ScrollCount + 50;
        needsRefresh = true;
    end
    return needsRefresh
end

-- Method:          GRM.TriggerRefreshAuditReset()
-- What it Does:    Refreshes the audit frames after hiding the tooltip
-- Purpose:         Prevent code bloat for something with repeated use.
GRM.TriggerRefreshAuditReset = function()
    GRM_G.currentAuditFontstringIndex = 0;
    GRM_UI.RestoreTooltipScale();
    GameTooltip:Hide();
    GRM.RefreshAuditFrames( GRM_G.AuditSortType );
end

-- Method:          GRM.BuildEventCalendarManagerScrollFrame()
-- What it Does:    This populates properly the event ScrollFrame
-- Purpose:         Scroll Frame management for smoother User Experience
GRM.BuildEventCalendarManagerScrollFrame = function()
    -- SCRIPT LOGIC ON ADD EVENT SCROLLING FRAME
    local scrollHeight = 0;
    local scrollWidth = 561;
    local buffer = 15;

    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons or {};  -- Create a table for the Buttons.
    -- populating the window correctly.
    local tempHeight = 0;
    for i = 1 , #GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID] - 1 do
        -- if font string is not created, do so.
        if not GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i] then
            local tempButton = CreateFrame ( "Button" , "PlayerToAdd" .. i , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame ); -- Names each Button 1 increment up
            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i] = { tempButton , tempButton:CreateFontString ( "PlayerToAddText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "PlayerToAddTitleText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "PlayerToAddDescriptionText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) };
        end
        local EventButtons = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i][1];
        local EventButtonsText = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i][2];
        local EventButtonsText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i][3];
        local EventButtonsText3 = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i][4];
        local classColorRGB = GRM.GetClassColorRGB ( GRM.GetPlayerClass ( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i + 1][1] ) , false );

        -- Set the values..
        EventButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame , 7 , -99 );
        EventButtons:SetWidth ( 558 );
        EventButtons:SetHeight ( 19 );
        EventButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        EventButtonsText:SetText ( GRM.SlimName ( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i + 1][1] ) );
        EventButtonsText:SetTextColor ( classColorRGB[1] , classColorRGB[2] , classColorRGB[3] , 1 );
        EventButtonsText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 11 );
        EventButtonsText:SetPoint ( "LEFT" , EventButtons );
        EventButtonsText:SetJustifyH ( "LEFT" );
        local name = GRM.SlimName ( string.sub ( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i + 1][2] , 0 , ( string.find ( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i + 1][2] , " " ) - 1 ) - 2 ) );
        local eventName = string.sub ( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i + 1][2] , string.find ( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i + 1][2] , " " ) , #GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i + 1][2] );
        local result = "";
        -- For localization of final display fontstring
        if string.find ( eventName , "Anniversary!" ) ~= nil then
            result = GRM.L ( "{name}'s Anniversary!" , name );
        elseif string.find ( eventName , "Birthday!" ) ~= nil then
            result = GRM.L ( "{name}'s Birthday!" , name );
        else
            result = GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i + 1][2];
        end
        EventButtonsText2:SetText ( result );
        EventButtonsText2:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 11 );
        EventButtonsText2:SetJustifyH ( "LEFT" );
        EventButtonsText2:SetWidth ( 171 )
        EventButtonsText3:SetText ( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i + 1][6] );
        EventButtonsText3:SetWidth ( 275 );
        EventButtonsText3:SetWordWrap ( false );
        EventButtonsText3:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 11 );
        EventButtonsText3:SetPoint ( "LEFT" , EventButtons );
        EventButtonsText3:SetJustifyH ( "LEFT" );

        EventButtons:SetScript ( "OnEnter" , function()
            GRM_UI.SetTooltipScale();
            GameTooltip:SetOwner ( EventButtons  , "ANCHOR_CURSOR" );
            GameTooltip:AddLine ( GRM.GetClassifiedName ( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i+1][1] , false ) );
            GameTooltip:AddLine ( GRM.L ( "|CFFE6CC7FClick|r to select player event" ) );
            GameTooltip:Show();
            GRM_G.tempEventNoteHolder = GRM.L ( "|CFFE6CC7FClick|r to select player event" );
        end);
        EventButtons:SetScript ( "OnLeave" , function()
            GRM_UI.RestoreTooltipScale();
            GameTooltip:Hide();
        end);

        local timer = 0;
        EventButtons:SetScript ( "OnUpdate" , function( self , elapsed )
            timer = timer + elapsed;
            if timer > 0.05 then
                if self:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                    if EventButtonsText3:IsMouseOver( 9 , -9 , -9 , 9 ) then            -- Since the button is large, the text needs to compensate.
                        GameTooltip:Hide();
                        GameTooltip:SetOwner( self , "ANCHOR_CURSOR"  );
                        GameTooltip:AddLine( "|cFFFFFFFF" .. string.upper ( GRM.L ( "Full Description:" ) ) );
                        GameTooltip:AddLine( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i + 1][6] , 1.0 , 0.84 , 0 , true );
                        GameTooltip:Show();
                    else
                        GameTooltip:SetOwner ( EventButtons  , "ANCHOR_CURSOR" );
                        GameTooltip:AddLine ( GRM.GetClassifiedName ( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i+1][1] , false ) );
                        GameTooltip:AddLine ( GRM_G.tempEventNoteHolder );
                        GameTooltip:Show();
                    end
                end
                timer = 0;
            end
        end);
        -- Logic
        EventButtons:SetScript ( "OnClick" , function ( self , button )
            if button == "LeftButton" then
                -- For highlighting purposes

                for j = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons do
                    if EventButtons ~= GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[j][1] then
                        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[j][1]:UnlockHighlight();
                    else
                        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[j][1]:LockHighlight();
                    end
                end
                -- parse out the button number, which will correlate with addonque frame...
                local buttonName = self:GetName();
                local index = tonumber ( string.sub ( buttonName , #buttonName ) ) + 1; -- It has to be incremented up by one as the stored data begins at index 2, not 1, as that references the guild.
                 
                if ( GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:GetText() == nil ) or ( GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:GetText() ~= nil and ( GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:GetText() ~= EventButtonsText2:GetText() or not GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:IsVisible() ) ) then
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:SetText ( EventButtonsText2:GetText() );
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddTitleText:SetText ( EventButtonsText: GetText() );
                    
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:SetText(  GRM.FormatTimeStamp ( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][index][4] .. " " .. monthEnum2 [ '' .. GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][index][3] .. '' ] .. " '" .. tostring ( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][index][5] - 2000 ) ) );

                    if GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:IsVisible() then
                        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:Hide();
                        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:Show();
                        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:Show();
                    end

                    local eventButtonTooltip = function ()
                        GRM_UI.SetTooltipScale();
                        GameTooltip:SetOwner ( self , "ANCHOR_CURSOR" );
                        GameTooltip:AddLine ( GRM.GetClassifiedName ( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][index][1] , false ) );
                        GameTooltip:AddLine ( GRM.L ( "|CFFE6CC7FClick Again|r to open Player Window" ) );
                        GameTooltip:Show();
                        GRM_G.tempEventNoteHolder = GRM.L ( "|CFFE6CC7FClick Again|r to open Player Window" );
                    end
                    -- Set proper tooltip
                    GameTooltip:Hide();
                    eventButtonTooltip();
                    self:SetScript ( "OnEnter" , eventButtonTooltip );

                    -- establishes and also resets the tooltips
                    for j = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons do
                        if j ~= i then
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[j][1]:SetScript ( "OnEnter" , function( self )
                                local bName = self:GetName();
                                local ind = tonumber ( string.sub ( bName , #bName ) ) + 1;
                                GameTooltip:SetOwner ( self , "ANCHOR_CURSOR" );
                                GameTooltip:AddLine ( GRM.GetClassifiedName ( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][ind][1] , false ) );
                                GameTooltip:AddLine ( GRM.L ( "|CFFE6CC7FClick|r to select player event" ) );
                                GameTooltip:Show();
                                GRM_G.tempEventNoteHolder = GRM.L ( "|CFFE6CC7FClick|r to select player event" );
                            end);
                        end
                    end
                else

                    if CommunitiesFrame == nil or ( CommunitiesFrame ~= nil and not CommunitiesFrame:IsVisible() ) then
                        GuildMicroButton:Click();
                        CommunitiesFrame:Show();
                    end   
                    if not CommunitiesFrame:IsVisible() then
                        CommunitiesFrameTab2:Click();
                    end
                    GRM_G.currentName = GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][index][1];
                    GRM_G.pause = false;
                    GRM.ClearAllFrames( true );
                    GRM.PopulateMemberDetails ( GRM_G.currentName );
                    GRM_UI.GRM_MemberDetailMetaData:Show();
                    CommunitiesFrame.GuildMemberDetailFrame:Hide();
                    GRM_G.pause = true;
                end

                self:SetScript ( "OnLeave" , function()
                    GRM_UI.RestoreTooltipScale();
                    GameTooltip:Hide();
                end);
            end

        end);
        
        -- Now let's pin it!
        if i == 1 then
            EventButtons:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame , "TOPLEFT" , 3 , -12 );
            EventButtonsText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame , "TOPLEFT" , 3 , -12 );
            EventButtonsText2:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame , -89 , -12 );
            EventButtonsText3:SetPoint ( "LEFT" , EventButtonsText2 , "RIGHT" , 3 , 0 );
            scrollHeight = scrollHeight + EventButtons:GetHeight();
        else
            EventButtons:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i - 1][1] , "BOTTOMLEFT" , 0 , - buffer );
            EventButtonsText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i - 1][2] , "BOTTOMLEFT" , 0 , - ( buffer + tempHeight ) );
            EventButtonsText2:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i - 1][3] , "BOTTOMLEFT" , 0 , - ( buffer + tempHeight ) );
            EventButtonsText3:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i - 1][4] , "BOTTOMLEFT" , 0 , - ( buffer + tempHeight ) );
            scrollHeight = scrollHeight + EventButtons:GetHeight() + buffer;
        end
        EventButtons:Show();
        tempHeight = ( EventButtons:GetHeight() - EventButtonsText2:GetHeight() );
    end
    -- Update the size -- it either grows or it shrinks!
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame:SetSize ( scrollWidth , scrollHeight );

    --Set Slider Parameters ( has to be done after the above details are placed )
    local scrollMax = ( scrollHeight - 348 ) + ( buffer * 1.5 );
    if scrollMax < 0 then
        scrollMax = 0;
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
    -- Mousewheel Scrolling Logic
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrame:EnableMouseWheel( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrame:SetScript( "OnMouseWheel" , function( _ , delta )
        local current = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider:GetValue();
        
        if IsShiftKeyDown() and delta > 0 then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider:SetValue ( 0 );
        elseif IsShiftKeyDown() and delta < 0 then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider:SetValue ( scrollMax );
        elseif delta < 0 and current < scrollMax then
            if IsControlKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider:SetValue ( current + 60 );
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider:SetValue ( current + 20 );
            end
        elseif delta > 0 and current > 1 then
            if IsControlKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider:SetValue ( current - 60 );
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrameSlider:SetValue ( current - 20 );
            end
        end
    end);
end


-- Method:          GRM.BuildAddonUserScrollFrame()
-- What it Does:    Builds the potential scroll frame to house the entire list of all guildies who have addon installed and enabled
-- Purpose:         Much better and cleaner UI to have a scroll window, imo.
GRM.BuildAddonUserScrollFrame = function()
    local scrollHeight = 0;
    local scrollWidth = 561;
    local buffer = 15;

    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings = GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings or {};  -- Create a table for the Buttons.
    -- Building all the fontstrings.
    for i = 1 , #GRM_G.currentAddonUsers do
        -- We know there is at least one, so let's hide the warning string...
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.GRM_AddonUsersCoreFrameTitleText2:Hide();
        -- if font string is not created, do so.
        if not GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i] then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i] = { GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame:CreateFontString ( "GRM_AddonUserNameText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame:CreateFontString ( "GRM_AddonUserSyncText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame:CreateFontString ( "GRM_AddonUserVersionText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) };
        end

        local AddonUserText1 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][1];
        local AddonUserText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][2];
        local AddonUserText3 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][3];
        local classColorRGB = GRM.GetClassColorRGB ( GRM.GetPlayerClass ( GRM_G.currentAddonUsers[i][1] ) );
        AddonUserText1:SetText ( GRM.SlimName ( GRM_G.currentAddonUsers[i][1] ) );
        if classColorRGB ~= nil then
            AddonUserText1:SetTextColor ( classColorRGB[1] , classColorRGB[2] , classColorRGB[3] );
        end
        AddonUserText1:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 13 );
        AddonUserText1:SetJustifyH ( "LEFT" );

        -- Get the right RGB coloring for the text.
        local r , g , b;
        if GRM_G.currentAddonUsers[i][2] == "Ok!" then
            r = 0;
            g = 0.77;
            b = 0.063;
        else
            r = 0.64;
            g = 0.102;
            b = 0.102;
        end
        AddonUserText2:SetTextColor ( r , g , b , 1.0 ); 
        AddonUserText2:SetText ( GRM.L ( GRM_G.currentAddonUsers[i][2] ) );
        AddonUserText2:SetWidth ( 200 );
        AddonUserText2:SetWordWrap ( false );
        AddonUserText2:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 13 );
        AddonUserText2:SetJustifyH ( "CENTER" );
        AddonUserText3:SetText ( string.sub ( GRM_G.currentAddonUsers[i][3] , string.find ( GRM_G.currentAddonUsers[i][3] , "R" , -8 ) , #GRM_G.currentAddonUsers[i][3] ) );
        AddonUserText3:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 13 );
        AddonUserText3:SetJustifyH ( "CENTER" );
        AddonUserText3:SetWidth ( 125 );

        local stringHeight = AddonUserText1:GetStringHeight();

        -- Now let's pin it!
        if i == 1 then
            AddonUserText1:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame , "TOPLEFT" , 5 , - 15 );
            AddonUserText2:SetPoint( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame , "TOP" , -6 , - 15 );
            AddonUserText3:SetPoint( "TOPRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame , "TOPRIGHT" , -2 , - 15 );
            scrollHeight = scrollHeight + stringHeight;
        else
            AddonUserText1:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i - 1][1] , "BOTTOMLEFT" , 0 , - buffer );
            AddonUserText2:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i - 1][2] , "BOTTOMLEFT" , 0 , - buffer );
            AddonUserText3:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i - 1][3] , "BOTTOMLEFT" , 0 , - buffer );
            scrollHeight = scrollHeight + stringHeight + buffer;
        end
        AddonUserText1:Show();
        AddonUserText2:Show();
        AddonUserText3:Show();
    end
            
    -- Hides all the additional strings... if necessary ( necessary because some people may have logged off thus you need to hide those frames)
    for i = #GRM_G.currentAddonUsers + 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings do
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][1]:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][2]:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][3]:Hide();
    end 

    -- Update the size -- it either grows or it shrinks!
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame:SetSize ( scrollWidth , scrollHeight );

    --Set Slider Parameters ( has to be done after the above details are placed )
    local scrollMax = ( scrollHeight - 391 ) + ( buffer * .5 );  -- 18 comes from fontSize (11) + buffer (7);
    if scrollMax < 0 then
        scrollMax = 0;
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
    -- Mousewheel Scrolling Logic
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrame:EnableMouseWheel( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrame:SetScript( "OnMouseWheel" , function( _ , delta )
        local current = GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider:GetValue();
        
        if IsShiftKeyDown() and delta > 0 then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider:SetValue ( 0 );
        elseif IsShiftKeyDown() and delta < 0 then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider:SetValue ( scrollMax );
        elseif delta < 0 and current < scrollMax then
            if IsControlKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider:SetValue ( current + 60 );
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider:SetValue ( current + 20 );
            end
        elseif delta > 0 and current > 1 then
            if IsControlKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider:SetValue ( current - 60 );
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrameSlider:SetValue ( current - 20 );
            end
        end
    end);

    -- Statement on who is using the addon!
    if #GRM_G.currentAddonUsers == 0 then
        local numGuildiesOnline = GRM.GetNumGuildiesOnline( false ) - 1; -- Don't include yourself!
        local result = GRM.L ( "No Guildie Online With Addon." );
        if numGuildiesOnline == 1 then
            result = result .. "\n" .. GRM.L ( "ONE Person is Online. Recommend It!" );
        elseif numGuildiesOnline > 1 then
            result = result .. "\n" .. GRM.L ( "{num} others are Online! Recommend It!" , nil , nil , numGuildiesOnline );
        end
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.GRM_AddonUsersCoreFrameTitleText2:SetText ( result );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.GRM_AddonUsersCoreFrameTitleText2:Show();
    end
end

-- Method:          GRM.GetSortedAltNamesWithDetails ( string , boolean )
-- What it Does:    Returns the alt grouping of the player, with their own name, the player details, as well as main sorted as index 1.
-- Purpose:         Mainly for use with the alt groupings window on mouseover of the player alts on core popup window.
GRM.GetSortedAltNamesWithDetails = function ( playerName , setMainFirst )
    local tempGuild = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    local finalList = {};
    local listOfNames = {};
    local isMainFound = false;

    for i = 2 , #tempGuild do
        if tempGuild[i][1] == playerName then

            -- Build selected player details
            table.insert ( listOfNames , tempGuild[i][1] );

            -- Build the list of alts.
            if #tempGuild[i][11] > 0 then
                for j = 1 , #tempGuild[i][11] do
                    table.insert ( listOfNames , tempGuild[i][11][j][1] )
                end

                -- Sort the list of alts.
                sort ( listOfNames );

                -- let's build the proper tables now.
                for k = 1 , #listOfNames do
                    for s = 2 , #tempGuild do
                        if tempGuild[s][1] == listOfNames[k] then
                            local playerDetails = { tempGuild[s][1] , tempGuild[s][6] , tempGuild[s][9] , tempGuild[s][4] , tempGuild[s][10] , tempGuild[s][24] , tempGuild[s][20][#tempGuild[s][20]] , tempGuild[s][25][#tempGuild[s][25]][2] , tempGuild[s][33] };

                            if setMainFirst and not isMainFound and tempGuild[s][10] then
                                table.insert ( finalList , 1 , playerDetails );
                                isMainFound = true;
                            else
                                table.insert ( finalList , playerDetails );
                            end
                            break;
                        end
                    end
                end
            end
            break;
        end
    end
    return finalList;
end

-- Method:          GRM.BuildAltGroupingScrollFrame()
-- What it Does:    It builds the alt groupings info on mouseover with shift pressed
-- Purpose:         For quick look at the alt info...
GRM.BuildAltGroupingScrollFrame = function()
    local scrollHeight = 0;
    local scrollWidth = 315;
    local buffer = 9;

    GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings = GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings or {};  -- Create a table for the Buttons.
    -- Building all the fontstrings.
    GRM_UI.GRM_AltGroupingScrollBorderFrameTitle:SetText ( GRM_G.CurrentCalendarHexCode .. GRM.L ( "{name}'s Alts" , GRM.SlimName ( GRM_G.currentName ) ) );
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == GRM_G.currentName then

            -- Collect all the alt names and sort them.
            local listOfAlts = GRM.GetSortedAltNamesWithDetails ( GRM_G.currentName , true );

            for i = 1 , #listOfAlts do  -- The +1 is for the player so they can count themselves too...
                -- if font string is not created, do so.
                if not GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings[i] then
                    GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings[i] = { GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame:CreateFontString ( "GRM_AltName" .. i , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame:CreateFontString ( "GRM_AltLevel" .. i , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame:CreateFontString ( "GRM_AltRank" .. i , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame:CreateFontString ( "GRM_AltLastOnline" .. i , "OVERLAY" , "GameFontWhiteTiny" ) };
                end
        
                local AltName = GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings[i][1];
                local AltLvl = GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings[i][2];
                local AltRank = GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings[i][3];
                local AltLastOnline = GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings[i][4];
                
                local altClassRGB = GRM.GetClassColorRGB ( listOfAlts[i][3] , false );

                AltName:SetText ( GRM.SlimName ( listOfAlts[i][1] ) );
                AltName:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 9 );
                AltName:SetJustifyH ( "LEFT" );
                AltName:SetTextColor ( altClassRGB[1] , altClassRGB[2] , altClassRGB[3] , 1 );
        
                AltLvl:SetText ( listOfAlts[i][2] );
                AltLvl:SetWidth ( 75 );
                AltLvl:SetWordWrap ( false );
                AltLvl:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 9 );
                AltLvl:SetJustifyH ( "CENTER" );

                AltRank:SetText ( listOfAlts[i][4] );
                AltRank:SetWidth ( 75 );
                AltRank:SetWordWrap ( false );
                AltRank:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 9 );
                AltRank:SetJustifyH ( "CENTER" );

                AltLastOnline:SetWidth ( 100 );
                AltLastOnline:SetWordWrap ( false );
                AltLastOnline:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 9 );

                -- Last Online
                if listOfAlts[i][9] then
                    AltLastOnline:SetText ( GRM.L ( "Online" ) );
                    AltLastOnline:SetTextColor ( 0.12 , 1.0 , 0.0 , 1.0 );
                else
                    AltLastOnline:SetText ( GRM.HoursReport ( listOfAlts[i][6] ) );
                    AltLastOnline:SetTextColor ( 1 , 1 , 1 , 1.0 );
                end
       
                local stringHeight = AltLastOnline:GetStringHeight();
        
                -- Now let's pin it!
                if i == 1 then
                    AltName:SetPoint( "TOPLEFT" , GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame , "TOPLEFT" , 17 , -5 );
                    AltLvl:SetPoint( "TOP" , GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame , "TOP" , -40 , -5 );
                    AltRank:SetPoint( "TOP" , GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame , "TOP" , 28 , -5 );
                    AltLastOnline:SetPoint( "TOP" , GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame , "TOP" , 108 , -5 );

                    -- Main tag
                    if listOfAlts[i][5] then
                        GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.GRM_MainTag:SetPoint ( "TOP" , AltName , "BOTTOM" , 0 , 0.5 );
                        GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.GRM_MainTag:Show();
                    else
                        GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.GRM_MainTag:Hide();
                    end
                    scrollHeight = scrollHeight + stringHeight;
                else
                    AltName:SetPoint( "TOPLEFT" , GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings[i - 1][1] , "BOTTOMLEFT" , 0 , - buffer );
                    AltLvl:SetPoint( "TOP" , GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings[i - 1][2] , "BOTTOM" , 0 , - buffer );
                    AltRank:SetPoint( "TOP" , GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings[i - 1][3] , "BOTTOM" , 0 , - buffer );
                    AltLastOnline:SetPoint( "TOP" , GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings[i - 1][4] , "BOTTOM" , 0 , - buffer );
                    scrollHeight = scrollHeight + stringHeight + buffer;
                end
                AltName:Show();
                AltLvl:Show();
                AltRank:Show();
                AltLastOnline:Show();
            end
                    
            -- Hides all the additional strings... if necessary
            for i = #listOfAlts + 1 , #GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings do
                GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings[i][1]:Hide();
                GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings[i][2]:Hide();
                GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings[i][3]:Hide();
                GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.AllFrameFontstrings[i][4]:Hide();
            end 
        
            -- Update the size -- it either grows or it shrinks!
            GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame:SetSize ( scrollWidth , scrollHeight );
        
            --Set Slider Parameters ( has to be done after the above details are placed )
            local scrollMax = ( scrollHeight - 110 ) + ( buffer ); 
            if scrollMax < 0 then
                scrollMax = 0;
                GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.GRM_AltGroupingScrollFrameSlider:Hide();
                GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollFrame:EnableMouseWheel( false );
            else
                GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.GRM_AltGroupingScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
                -- Mousewheel Scrolling Logic
                GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollFrame:EnableMouseWheel( true );
                GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollFrame:SetScript( "OnMouseWheel" , function( _ , delta )
                    local current = GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.GRM_AltGroupingScrollFrameSlider:GetValue();
                    
                    if delta < 0 and current < scrollMax then
                        if IsControlKeyDown() then
                            GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.GRM_AltGroupingScrollFrameSlider:SetValue ( current + 60 );
                        else
                            GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.GRM_AltGroupingScrollFrameSlider:SetValue ( current + 20 );
                        end
                    elseif delta > 0 and current > 1 then
                        if IsControlKeyDown() then
                            GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.GRM_AltGroupingScrollFrameSlider:SetValue ( current - 60 );
                        else
                            GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.GRM_AltGroupingScrollFrameSlider:SetValue ( current - 20 );
                        end
                    end
                end);
                GRM_UI.GRM_AltGroupingScrollBorderFrame.GRM_AltGroupingScrollChildFrame.GRM_AltGroupingScrollFrameSlider:Show();
            end
            break;
        end
    end   
end

-- Method:          GRM.BuildBackupScrollFrame ( int )
-- What it Does:    Builds the scrollframe with details on all of the guilds and their backup data...
-- Purpose:         Be able to manage guild backups nice and neatly...
GRM.BuildBackupScrollFrame = function ( factionID )
    local scrollHeight = 0;
    local scrollWidth = 561;
    local buffer = 15;
    local count = 1;
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons or {};  -- Create a table for the Buttons.
    
    -- Establish the memory use...
    UpdateAddOnMemoryUsage();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_MemoryUsageText:SetText ( GRM.L ( "Memory Usage: {num} MB" , nil , nil , GRM.Round ( GetAddOnMemoryUsage ( GRM_G.addonName ) / 1000 , 2 ) ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupTimeOverlayNoteText:SetText ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][41] );
    -- AutoBackupSettings
    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][41] > 1 then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText2:SetText ( GRM.L ( "Days" ) );
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.DaysOnAutoBackupText2:SetText ( GRM.L ( "Day" ) );
    end

    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][34] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupCheckBox:SetChecked( true );
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_AutoBackupCheckBox:SetChecked( false );
    end

    -- Hide any popups
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption:Hide();

    local i = 2;
    local myGuildFound = false;
    while i <= #GRM_GuildDataBackup_Save[factionID] do
        local tempGuildName = "";
        local tempGuildCreationDate = "";
        if type ( GRM_GuildDataBackup_Save[factionID][i][1] ) == "string" then
            tempGuildName = GRM_GuildDataBackup_Save[factionID][i][1];
            tempGuildCreationDate = "Unknown";
        else
            tempGuildName = GRM_GuildDataBackup_Save[factionID][i][1][1];
            tempGuildCreationDate = GRM_GuildDataBackup_Save[factionID][i][1][2];
        end
        if ( count == 1 and GRM_G.selectedFID == GRM_G.FID ) or tempGuildName ~= GRM_G.guildName then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count] then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count] = { GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame:CreateFontString ( "GuildString1_" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame:CreateFontString ( "GuildString2_" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame:CreateFontString ( "GuildString3_" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame:CreateFontString ( "GuildString4_" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame:CreateFontString ( "GuildString5_" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame:CreateFontString ( "GuildString6_" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame:CreateFontString ( "GuildString7_" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame:CreateFontString ( "GuildString8_" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame:CreateFontString ( "GuildString9_" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame:CreateFontString ( "GuildString10_" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame:CreateFontString ( "GuildString11_" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , CreateFrame ( "Button" , "GuildBackup1_" .. count , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame , "UIPanelButtonTemplate" ) , CreateFrame ( "Button" , "GuildBackup2_" .. count , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame , "UIPanelButtonTemplate" ) , CreateFrame ( "Button" , "GuildBackup3_" .. count , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame , "UIPanelButtonTemplate" ) , CreateFrame ( "Button" , "GuildBackup4_" .. count , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame , "UIPanelButtonTemplate" ) , CreateFrame ( "Button" , "GuildBackup5_" .. count , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame , "UIPanelButtonTemplate" ) , CreateFrame ( "Button" , "GuildBackup6_" .. count , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame , "UIPanelButtonTemplate" ) , CreateFrame ( "Button" , "GuildBackup7_" .. count , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame , "UIPanelButtonTemplate" ) , CreateFrame ( "Button" , "GuildBackup8_" .. count , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame , "UIPanelButtonTemplate" ) };
            end
            local GuildButtonText1 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][1];
            local GuildButtonText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][2];
            local GuildButtonText3 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][3];
            local GuildButtonText4 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][4];
            local GuildButtonText5 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][5];
            local GuildButtonText6 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][6];
            local GuildButtonText7 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][7];
            local GuildButtonText8 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][8];
            local GuildButtonText9 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][9];
            local GuildButtonText10 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][10];
            local GuildButtonText11 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][11];
            local GuildButton1 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][12];
            local GuildButton2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][13];
            local GuildButton3 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][14];
            local GuildButton4 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][15];
            local GuildButton5 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][16];
            local GuildButton6 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][17];
            local GuildButton7 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][18];
            local GuildButton8 = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count][19];

            local saveFound = { false , false , false , false };
            if count == 1 and GRM_G.selectedFID == GRM_G.FID then
                -- Find my guild I am in first!
                for j = 2 , #GRM_GuildDataBackup_Save[factionID] do
                    if type ( GRM_GuildDataBackup_Save[factionID][j][1] ) == "string" then
                        tempGuildName = GRM_GuildDataBackup_Save[factionID][j][1];
                        tempGuildCreationDate = "Unknown";
                    else
                        tempGuildName = GRM_GuildDataBackup_Save[factionID][j][1][1];
                        tempGuildCreationDate = GRM_GuildDataBackup_Save[factionID][j][1][2];
                    end
                    
                    if tempGuildName == GRM_G.guildName then
                        myGuildFound = true;
                        
                        -- Guild found!
                        GuildButtonText1:SetText ( "\"" .. tempGuildName .. "\"" );
                        GuildButtonText1:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 16 );
                        GuildButtonText1:SetWidth ( 278 );
                        GuildButtonText1:SetWordWrap ( false )
                        GuildButtonText1:SetJustifyH ( "LEFT" );
                        if factionID == 1 then
                            GuildButtonText1:SetTextColor ( 0.61 , 0.14 , 0.137 );
                        elseif factionID == 2 then
                            GuildButtonText1:SetTextColor ( 0.078 , 0.34 , 0.73 );
                        end
                        GuildButtonText2:SetText ( tempGuildCreationDate );
                        GuildButtonText2:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 16 );
                        GuildButtonText2:SetWidth ( 150 );
                        GuildButtonText2:SetJustifyH ( "CENTER" );
                        GuildButtonText3:SetText ( GRM.GetNumGuildiesInGuild ( GRM_G.guildName , GRM_G.guildCreationDate ) );
                        GuildButtonText3:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 16 );
                        GuildButtonText3:SetWidth ( 150 );
                        GuildButtonText3:SetJustifyH ( "CENTER" );
                        GuildButtonText4:SetText ( GRM.L ( "Backup {num}:" , nil , nil , 1 ) );
                        GuildButtonText4:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                        GuildButtonText4:SetJustifyH ( "LEFT" );
                        GuildButtonText5:SetText ( GRM.L ( "Backup {num}:" , nil , nil , 2 ) );
                        GuildButtonText5:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                        GuildButtonText5:SetJustifyH ( "LEFT" );
                        GuildButtonText6:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                        GuildButtonText6:SetJustifyH ( "CENTER" );
                        GuildButtonText6:SetWordWrap ( false );
                        GuildButtonText6:SetWidth ( 150 );
                        GuildButtonText7:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                        GuildButtonText7:SetJustifyH ( "CENTER" );
                        GuildButtonText7:SetWordWrap ( false );
                        GuildButtonText7:SetWidth ( 150 );
                        GuildButtonText8:SetText ( GRM.L ( "Auto {num}:" , nil , nil , 1 ) );
                        GuildButtonText8:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                        GuildButtonText8:SetJustifyH ( "LEFT" );
                        GuildButtonText9:SetText ( GRM.L ( "Auto {num}:" , nil , nil , 2 ) )
                        GuildButtonText9:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                        GuildButtonText9:SetJustifyH ( "LEFT" );
                        GuildButtonText10:SetWidth ( 150 );
                        GuildButtonText10:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                        GuildButtonText10:SetJustifyH ( "CENTER" );
                        GuildButtonText10:SetWordWrap ( false );
                        GuildButtonText11:SetWidth ( 150 );
                        GuildButtonText11:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                        GuildButtonText11:SetJustifyH ( "CENTER" );
                        GuildButtonText11:SetWordWrap ( false );
                        GuildButton1:SetSize ( 115 , 21 );
                        GuildButton2:SetSize ( 115 , 21 );
                        GuildButton3:SetSize ( 115 , 21 );
                        GuildButton4:SetSize ( 115 , 21 );
                        GuildButton5:SetSize ( 115 , 21 );
                        GuildButton6:SetSize ( 115 , 21 );
                        GuildButton7:SetSize ( 115 , 21 );
                        GuildButton8:SetSize ( 115 , 21 );
                        
                        -- Ok, First Backup
                        if GRM_GuildDataBackup_Save[factionID][j][4] ~= nil then
                            saveFound[1] = true;
                            GuildButtonText6:SetText ( GRM.FormatTimeStamp ( GRM_GuildDataBackup_Save[factionID][j][4][1] , true ) );
                            GuildButton1:SetText ( GRM.L ( "Restore" ) );
                            GuildButton2:SetText ( GRM.L ( "Remove" ) );
                            GuildButton1:SetScript ( "OnClick" , function( _ , button )
                                if button == "LeftButton" then
                                    GRM_UI.GRM_RosterChangeLogFrame:EnableMouse( false );
                                    GRM_UI.GRM_RosterChangeLogFrame:SetMovable( false );
                                    GRM_UI.GRM_RosterConfirmFrameText:SetText( GRM.L ( "Really restore {name} Backup Point?" , GuildButtonText1:GetText() ) );
                                    GRM_UI.GRM_RosterConfirmYesButtonText:SetText ( GRM.L ( "Yes!" ) );
                                    GRM_UI.GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( _ , button )
                                        if button == "LeftButton" then
                                            GRM.LoadGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , GuildButtonText6:GetText() );
                                            GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                                            GRM_UI.GRM_RosterConfirmFrame:Hide();
                                        end
                                    end);
                                    GRM_UI.GRM_RosterConfirmFrame:Show();
                                end
                            end)
                        else
                            GuildButtonText6:SetText ( " < " .. GRM.L ( "None" ) .. " > " );
                            GuildButton1:SetText ( GRM.L ( "Set Backup" ) );
                            GuildButton1:SetScript ( "OnClick" , function( _ , button )
                                if button == "LeftButton" then
                                    GRM.AddGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID );
                                    GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                                end
                            end)
                        end

                        -- Second Backup
                        if GRM_GuildDataBackup_Save[factionID][j][5] ~= nil then
                            saveFound[2] = true;
                            GuildButtonText7:SetText ( GRM.FormatTimeStamp ( GRM_GuildDataBackup_Save[factionID][j][5][1] , true ) );
                            GuildButton3:SetText ( GRM.L ( "Restore" ) );
                            GuildButton4:SetText ( GRM.L ( "Remove" ) );
                            GuildButton3:SetScript ( "OnClick" , function( _ , button )
                                if button == "LeftButton" then
                                    GRM_UI.GRM_RosterChangeLogFrame:EnableMouse( false );
                                    GRM_UI.GRM_RosterChangeLogFrame:SetMovable( false );
                                    GRM_UI.GRM_RosterConfirmFrameText:SetText( GRM.L ( "Really restore {name} Backup Point?" , GuildButtonText1:GetText() ) );
                                    GRM_UI.GRM_RosterConfirmYesButtonText:SetText ( GRM.L ( "Yes!" ) );
                                    GRM_UI.GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( _ , button )
                                        if button == "LeftButton" then
                                            GRM.LoadGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , GuildButtonText7:GetText() );
                                            GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                                            GRM_UI.GRM_RosterConfirmFrame:Hide();
                                        end
                                    end);
                                    GRM_UI.GRM_RosterConfirmFrame:Show();
                                end
                            end)
                        else
                            GuildButtonText7:SetText ( " < " .. GRM.L ( "None" ) .. " > " );
                            GuildButton3:SetText ( GRM.L ( "Set Backup" ) );
                            GuildButton3:SetScript ( "OnClick" , function( _ , button )
                                if button == "LeftButton" then
                                    GRM.AddGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID );
                                    GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                                end
                            end)
                        end

                        -- Auto Backup 1
                        if #GRM_GuildDataBackup_Save[factionID][j][2] ~= 0 then
                            saveFound[3] = true;
                            GuildButtonText10:SetText ( string.gsub ( GRM.FormatTimeStamp ( GRM_GuildDataBackup_Save[factionID][j][2][1] , true ) , "AUTO_" , "" ) );
                            GuildButton5:SetText ( GRM.L ( "Restore" ) );
                            GuildButton6:SetText ( GRM.L ( "Remove" ) );
                            GuildButton5:SetScript ( "OnClick" , function( _ , button )
                                if button == "LeftButton" then
                                    GRM_UI.GRM_RosterChangeLogFrame:EnableMouse( false );
                                    GRM_UI.GRM_RosterChangeLogFrame:SetMovable( false );
                                    GRM_UI.GRM_RosterConfirmFrameText:SetText( GRM.L ( "Really restore {name} Backup Point?" , GuildButtonText1:GetText() ) );
                                    GRM_UI.GRM_RosterConfirmYesButtonText:SetText ( GRM.L ( "Yes!" ) );
                                    GRM_UI.GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( _ , button )
                                        if button == "LeftButton" then
                                            GRM.LoadGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , "AUTO_" .. GuildButtonText10:GetText() );
                                            GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                                            GRM_UI.GRM_RosterConfirmFrame:Hide();
                                        end
                                    end);
                                    GRM_UI.GRM_RosterConfirmFrame:Show();
                                end
                            end)
                        else
                            GuildButtonText10:SetText ( " < " .. GRM.L ( "None" ) .. " > " );
                        end

                        -- Auto Backup 2
                        if #GRM_GuildDataBackup_Save[factionID][j][3] ~= 0 then
                            saveFound[4] = true;
                            GuildButtonText11:SetText ( string.gsub ( GRM.FormatTimeStamp ( GRM_GuildDataBackup_Save[factionID][j][3][1] , true ) , "AUTO_" , "" ) );
                            GuildButton7:SetText ( GRM.L ( "Restore" ) );
                            GuildButton8:SetText ( GRM.L ( "Remove" ) );
                            GuildButton7:SetScript ( "OnClick" , function( _ , button )
                                if button == "LeftButton" then
                                    GRM_UI.GRM_RosterChangeLogFrame:EnableMouse( false );
                                    GRM_UI.GRM_RosterChangeLogFrame:SetMovable( false );
                                    GRM_UI.GRM_RosterConfirmFrameText:SetText( GRM.L ( "Really restore {name} Backup Point?" , GuildButtonText1:GetText() ) );
                                    GRM_UI.GRM_RosterConfirmYesButtonText:SetText ( GRM.L ( "Yes!" ) );
                                    GRM_UI.GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( _ , button )
                                        if button == "LeftButton" then
                                            GRM.LoadGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , "AUTO_" .. GuildButtonText11:GetText() );
                                            GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                                            GRM_UI.GRM_RosterConfirmFrame:Hide();
                                        end
                                    end);
                                    GRM_UI.GRM_RosterConfirmFrame:Show();
                                end
                            end)
                        else
                            GuildButtonText11:SetText ( " < " .. GRM.L ( "None" ) .. " > " );
                        end

                        -- Only need to initialize button 2 and 4 one time... ("Remove")
                        GuildButton2:SetScript ( "OnClick" , function( _ , button )
                            if button == "LeftButton" then
                                GRM.RemoveGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , GuildButtonText6:GetText() , true );
                                GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                            end
                        end)
                        -- Only need to initialize button 2 and 4 one time...
                        GuildButton4:SetScript ( "OnClick" , function( _ , button )
                            if button == "LeftButton" then
                                GRM.RemoveGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , GuildButtonText7:GetText() , true );
                                GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                            end
                        end)
                        GuildButton6:SetScript ( "OnClick" , function( _ , button )
                            if button == "LeftButton" then
                                GRM.RemoveGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , "AUTO_" .. GuildButtonText10:GetText() , true );
                                GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                            end
                        end)
                        GuildButton8:SetScript ( "OnClick" , function( _ , button )
                            if button == "LeftButton" then
                                GRM.RemoveGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , "AUTO_" .. GuildButtonText11:GetText() , true );
                                GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                            end
                        end)
                        break;
                    end
                end
            elseif GRM_GuildDataBackup_Save[factionID][i][1][1] ~= GRM_G.guildName then
                GuildButtonText1:SetText ( "\"" .. tempGuildName .. "\"" );
                GuildButtonText1:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 18 );
                GuildButtonText1:SetWidth ( 278 );
                GuildButtonText1:SetJustifyH ( "LEFT" );
                GuildButtonText1:SetWordWrap ( false );
                if factionID == 1 then
                    GuildButtonText1:SetTextColor ( 0.61 , 0.14 , 0.137 );
                elseif factionID == 2 then
                    GuildButtonText1:SetTextColor ( 0.078 , 0.34 , 0.73 );
                end
                GuildButtonText2:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 18 );
                GuildButtonText2:SetWidth ( 150 );
                GuildButtonText2:SetJustifyH ( "CENTER" );
                if tempGuildCreationDate ~= "Unknown" then
                    GuildButtonText2:SetText ( GRM_GuildDataBackup_Save[factionID][i][1][2] );
                    GuildButtonText3:SetText ( GRM.GetNumGuildiesInGuild ( GRM_GuildDataBackup_Save[factionID][i][1][1] , GRM_GuildDataBackup_Save[factionID][i][1][2] ) );
                else
                    GuildButtonText2:SetText ( GRM.L ( "Unknown" ) );
                    GuildButtonText3:SetText ( GRM.GetNumGuildiesInGuild ( tempGuildName , nil ) );
                end
                GuildButtonText3:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 18 );
                GuildButtonText3:SetWidth ( 150 );
                GuildButtonText3:SetJustifyH ( "CENTER" );
                GuildButtonText4:SetText ( GRM.L ( "Backup {num}:" , nil , nil , 1 ) );
                GuildButtonText4:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                GuildButtonText4:SetJustifyH ( "LEFT" );
                GuildButtonText5:SetText ( GRM.L ( "Backup {num}:" , nil , nil , 2 ) );
                GuildButtonText5:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                GuildButtonText5:SetJustifyH ( "LEFT" );
                GuildButtonText6:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                GuildButtonText6:SetJustifyH ( "CENTER" );
                GuildButtonText6:SetWordWrap ( false );
                GuildButtonText6:SetWidth ( 150 );
                GuildButtonText7:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                GuildButtonText7:SetJustifyH ( "CENTER" );
                GuildButtonText7:SetWordWrap ( false );
                GuildButtonText7:SetWidth ( 150 );
                GuildButtonText8:SetText ( GRM.L ( "Auto {num}:" , nil , nil , 1 ) );
                GuildButtonText8:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                GuildButtonText8:SetJustifyH ( "LEFT" );
                GuildButtonText9:SetText ( GRM.L ( "Auto {num}:" , nil , nil , 2 ) )
                GuildButtonText9:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                GuildButtonText9:SetJustifyH ( "LEFT" );
                GuildButtonText10:SetWidth ( 150 );
                GuildButtonText10:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                GuildButtonText10:SetJustifyH ( "CENTER" );
                GuildButtonText10:SetWordWrap ( false );
                GuildButtonText11:SetWidth ( 150 );
                GuildButtonText11:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 14 );
                GuildButtonText11:SetJustifyH ( "CENTER" );
                GuildButtonText11:SetWordWrap ( false );
                GuildButton1:SetSize ( 115 , 21 );
                GuildButton2:SetSize ( 115 , 21 );
                GuildButton3:SetSize ( 115 , 21 );
                GuildButton4:SetSize ( 115 , 21 );
                GuildButton5:SetSize ( 115 , 21 );
                GuildButton6:SetSize ( 115 , 21 );
                GuildButton7:SetSize ( 115 , 21 );
                GuildButton8:SetSize ( 115 , 21 );

                -- Ok, First Backup
                if GRM_GuildDataBackup_Save[factionID][i][4] ~= nil then
                    saveFound[1] = true;
                    GuildButtonText6:SetText ( GRM.FormatTimeStamp ( GRM_GuildDataBackup_Save[factionID][i][4][1] , true ) );
                    GuildButton1:SetText ( GRM.L ( "Restore" ) );
                    GuildButton2:SetText ( GRM.L ( "Remove" ) );
                    GuildButton1:SetScript ( "OnClick" , function( _ , button )
                        if button == "LeftButton" then
                            GRM_UI.GRM_RosterChangeLogFrame:EnableMouse( false );
                            GRM_UI.GRM_RosterChangeLogFrame:SetMovable( false );
                            GRM_UI.GRM_RosterConfirmFrameText:SetText( GRM.L ( "Really restore {name} Backup Point?" , GuildButtonText1:GetText() ) );
                            GRM_UI.GRM_RosterConfirmYesButtonText:SetText ( GRM.L ( "Yes!" ) );
                            GRM_UI.GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( _ , button )
                                if button == "LeftButton" then
                                    GRM.LoadGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , GuildButtonText6:GetText() );
                                    GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                                    GRM_UI.GRM_RosterConfirmFrame:Hide();
                                end
                            end);
                            GRM_UI.GRM_RosterConfirmFrame:Show();
                        end
                    end)
                else
                    GuildButtonText6:SetText ( " < " .. GRM.L ( "None" ) .. " > " );
                    GuildButton1:SetText ( GRM.L ( "Set Backup" ) );
                    GuildButton1:SetScript ( "OnClick" , function( _ , button )
                        if button == "LeftButton" then
                            GRM.AddGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID );
                            GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                        end
                    end)
                end

                -- Second Backup
                if GRM_GuildDataBackup_Save[factionID][i][5] ~= nil then
                    saveFound[2] = true;
                    GuildButtonText7:SetText ( GRM.FormatTimeStamp ( GRM_GuildDataBackup_Save[factionID][i][5][1] , true ) );
                    GuildButton3:SetText ( GRM.L ( "Restore" ) );
                    GuildButton4:SetText ( GRM.L ( "Remove" ) );
                    GuildButton3:SetScript ( "OnClick" , function( _ , button )
                        if button == "LeftButton" then
                            GRM_UI.GRM_RosterChangeLogFrame:EnableMouse( false );
                            GRM_UI.GRM_RosterChangeLogFrame:SetMovable( false );
                            GRM_UI.GRM_RosterConfirmFrameText:SetText( GRM.L ( "Really restore {name} Backup Point?" , GuildButtonText1:GetText() ) );
                            GRM_UI.GRM_RosterConfirmYesButtonText:SetText ( GRM.L ( "Yes!" ) );
                            GRM_UI.GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( _ , button )
                                if button == "LeftButton" then
                                    GRM.LoadGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , GuildButtonText7:GetText() );
                                    GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                                    GRM_UI.GRM_RosterConfirmFrame:Hide();
                                end
                            end);
                            GRM_UI.GRM_RosterConfirmFrame:Show();
                        end
                    end)
                else
                    GuildButtonText7:SetText ( " < " .. GRM.L ( "None" ) .. " > " );
                    GuildButton3:SetText ( GRM.L ( "Set Backup" ) );
                    GuildButton3:SetScript ( "OnClick" , function( _ , button )
                        if button == "LeftButton" then
                            GRM.AddGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID );
                            GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                        end
                    end)
                end

                -- Auto Backup 1
                if #GRM_GuildDataBackup_Save[factionID][i][2] ~= 0 then
                    saveFound[3] = true;
                    GuildButtonText10:SetText ( string.gsub ( GRM.FormatTimeStamp ( GRM_GuildDataBackup_Save[factionID][i][2][1] , true ) , "AUTO_" , "" ) );
                    GuildButton5:SetText ( GRM.L ( "Restore" ) );
                    GuildButton6:SetText ( GRM.L ( "Remove" ) );
                    GuildButton5:SetScript ( "OnClick" , function( _ , button )
                        if button == "LeftButton" then
                            GRM_UI.GRM_RosterChangeLogFrame:EnableMouse( false );
                            GRM_UI.GRM_RosterChangeLogFrame:SetMovable( false );
                            GRM_UI.GRM_RosterConfirmFrameText:SetText( GRM.L ( "Really restore {name} Backup Point?" , GuildButtonText1:GetText() ) );
                            GRM_UI.GRM_RosterConfirmYesButtonText:SetText ( GRM.L ( "Yes!" ) );
                            GRM_UI.GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( _ , button )
                                if button == "LeftButton" then
                                    GRM.LoadGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , "AUTO_" .. GuildButtonText10:GetText() );
                                    GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                                    GRM_UI.GRM_RosterConfirmFrame:Hide();
                                end
                            end);
                            GRM_UI.GRM_RosterConfirmFrame:Show();
                        end
                    end)
                else
                    GuildButtonText10:SetText ( " < " .. GRM.L ( "None" ) .. " > " );
                end

                -- Auto Backup 2
                if #GRM_GuildDataBackup_Save[factionID][i][3] ~= 0 then
                    saveFound[4] = true;
                    GuildButtonText11:SetText ( string.gsub ( GRM.FormatTimeStamp ( GRM_GuildDataBackup_Save[factionID][i][3][1] , true ) , "AUTO_" , "" ) );
                    GuildButton7:SetText ( GRM.L ( "Restore" ) );
                    GuildButton8:SetText ( GRM.L ( "Remove" ) );
                    GuildButton7:SetScript ( "OnClick" , function( _ , button )
                        if button == "LeftButton" then
                            GRM_UI.GRM_RosterChangeLogFrame:EnableMouse( false );
                            GRM_UI.GRM_RosterChangeLogFrame:SetMovable( false );
                            GRM_UI.GRM_RosterConfirmFrameText:SetText( GRM.L ( "Really restore {name} Backup Point?" , GuildButtonText1:GetText() ) );
                            GRM_UI.GRM_RosterConfirmYesButtonText:SetText ( GRM.L ( "Yes!" ) );
                            GRM_UI.GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( _ , button )
                                if button == "LeftButton" then
                                    GRM.LoadGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , "AUTO_" .. GuildButtonText11:GetText() );
                                    GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                                    GRM_UI.GRM_RosterConfirmFrame:Hide();
                                end
                            end);
                            GRM_UI.GRM_RosterConfirmFrame:Show();
                        end
                    end)
                else
                    GuildButtonText11:SetText ( " < " .. GRM.L ( "None" ) .. " > " );
                end

                -- Only need to initialize button 2 and 4 one time... ("Remove")
                GuildButton2:SetScript ( "OnClick" , function( _ , button )
                    if button == "LeftButton" then
                        GRM.RemoveGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , GuildButtonText6:GetText() , true );
                        GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                    end
                end)
                -- Only need to initialize button 2 and 4 one time...
                GuildButton4:SetScript ( "OnClick" , function( _ , button )
                    if button == "LeftButton" then
                        GRM.RemoveGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , GuildButtonText7:GetText() , true );
                        GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                    end
                end)
                GuildButton6:SetScript ( "OnClick" , function( _ , button )
                    if button == "LeftButton" then
                        GRM.RemoveGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , "AUTO_" .. GuildButtonText10:GetText() , true );
                        GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                    end
                end)
                GuildButton8:SetScript ( "OnClick" , function( _ , button )
                    if button == "LeftButton" then
                        GRM.RemoveGuildBackup ( string.gsub ( GuildButtonText1:GetText() , "\"" , "" ) , GuildButtonText2:GetText() , GRM_G.selectedFID , "AUTO_" .. GuildButtonText11:GetText() , true );
                        GRM.BuildBackupScrollFrame ( GRM_G.selectedFID );
                    end
                end)
                myGuildFound = false;
            end

            -- Now let's pin it!
            local stringHeight = GuildButtonText1:GetStringHeight() + ( GuildButtonText4:GetStringHeight() * 4 ) + ( buffer * 4 );
            if count == 1 then
                GuildButtonText1:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame , "TOPLEFT" , 20 , - 10 );
                GuildButtonText2:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame , "TOP" , 70 , - 10 );
                GuildButtonText3:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame , "TOPRIGHT" , 22 , - 10 );
                scrollHeight = scrollHeight + stringHeight;
            else
                local adjust = ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count - 1][4]:GetHeight() * 4 ) + ( buffer * 5 );
                GuildButtonText1:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count - 1][1] , "BOTTOMLEFT" , 0 , - adjust );
                GuildButtonText2:SetPoint( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count - 1][2] , "BOTTOM" , 0 , - adjust );
                GuildButtonText3:SetPoint( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[count - 1][3] , "BOTTOM" , 0 , - adjust );
                scrollHeight = scrollHeight + stringHeight + buffer;
            end
            -- Pin the remaining items!
            GuildButtonText4:SetPoint ( "TOPLEFT" , GuildButtonText1 , "BOTTOMLEFT" , 10 , - buffer );
            GuildButtonText5:SetPoint ( "TOPLEFT" , GuildButtonText4 , "BOTTOMLEFT" , 0 , - buffer );
            GuildButtonText6:SetPoint ( "LEFT" , GuildButtonText4 , "RIGHT" , 25 , 0 );
            GuildButtonText7:SetPoint ( "TOP" , GuildButtonText6 , "BOTTOM" , 0 , - buffer );
            GuildButtonText8:SetPoint ( "TOPLEFT" , GuildButtonText5 , "BOTTOMLEFT" , 0 , - buffer );
            GuildButtonText9:SetPoint ( "TOPLEFT" , GuildButtonText8 , "BOTTOMLEFT" , 0 , - buffer );
            GuildButtonText10:SetPoint ( "TOP" , GuildButtonText7 , "BOTTOM" , 0 , - buffer );
            GuildButtonText11:SetPoint ( "TOP" , GuildButtonText10 , "BOTTOM" , 0 , - buffer );
            GuildButton1:SetPoint ( "TOP" , GuildButtonText2 , "BOTTOM" , 0 , - buffer + 2 );
            GuildButton2:SetPoint ( "TOP" , GuildButtonText3 , "BOTTOM" , 0 , - buffer + 2 );
            GuildButton3:SetPoint ( "TOP" , GuildButton1 , "BOTTOM" , 0 , - buffer/2 );
            GuildButton4:SetPoint ( "TOP" , GuildButton2 , "BOTTOM" , 0 , - buffer/2 );
            GuildButton5:SetPoint ( "TOP" , GuildButton3 , "BOTTOM" , 0 , - buffer/2 );
            GuildButton6:SetPoint ( "TOP" , GuildButton4 , "BOTTOM" , 0 , - buffer/2 );
            GuildButton7:SetPoint ( "TOP" , GuildButton5 , "BOTTOM" , 0 , - buffer/2 );
            GuildButton8:SetPoint ( "TOP" , GuildButton6 , "BOTTOM" , 0 , - buffer/2 );

            -- Appearance logic...
            GuildButtonText1:Show();
            GuildButtonText2:Show();
            GuildButtonText3:Show();
            GuildButtonText4:Show();
            GuildButtonText5:Show();
            GuildButtonText6:Show();
            GuildButtonText7:Show();
            GuildButtonText8:Show();
            GuildButtonText9:Show();
            GuildButtonText10:Show();
            GuildButtonText11:Show();
            GuildButton1:Show();
            GuildButton3:Show();
            -- Only need 1 button if no save
            if saveFound[1] then
                GuildButton2:Show();
            else
                GuildButton2:Hide();
            end
            if saveFound[2] then
                GuildButton4:Show();
            else
                GuildButton4:Hide();
            end
            if saveFound[3] then
                GuildButton5:Show();
                GuildButton6:Show();
            else
                GuildButton5:Hide();
                GuildButton6:Hide();
            end
            if saveFound[4] then
                GuildButton7:Show();
                GuildButton8:Show();
            else
                GuildButton7:Hide();
                GuildButton8:Hide();
            end

            count = count + 1;
            if not myGuildFound then
                i = i + 1;
            end
        else
            i = i + 1;
        end
    end
        -- Need to determine if guild is Horde or Alliance...
    for i = count , #GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons do
        for j = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[i] do
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame.AllBackupButtons[i][j]:Hide();
        end
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollChildFrame:SetSize ( scrollWidth , scrollHeight );
     --Set Slider Parameters ( has to be done after the above details are placed )
     local scrollMax = ( scrollHeight - 319 ) + buffer; 
     if scrollMax < 0 then
         scrollMax = 0;
     end
     GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
     -- Mousewheel Scrolling Logic
     GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrame:EnableMouseWheel( true );
     GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrame:SetScript( "OnMouseWheel" , function( _ , delta )
         local current = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider:GetValue();
         GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_BackupPurgeGuildOption:Hide();
         if IsShiftKeyDown() and delta > 0 then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider:SetValue ( 0 );
         elseif IsShiftKeyDown() and delta < 0 then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider:SetValue ( scrollMax );
         elseif delta < 0 and current < scrollMax then
             if IsControlKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider:SetValue ( current + 60 );
             else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider:SetValue ( current + 20 );
             end
         elseif delta > 0 and current > 1 then
             if IsControlKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider:SetValue ( current - 60 );
             else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame.GRM_CoreBackupScrollFrameSlider:SetValue ( current - 20 );
             end
         end
     end);
end


-- Method:          GRM.RefreshAuditFrames()
-- What it Does:    Updates the audit frames when called
-- Purpose:         Audit frames are useful so the leader or player can do an easy visual check of the entire guild on what is needed.
GRM.RefreshAuditFrames = function( typeOfSort )
    local scrollHeight = 0;
    local scrollWidth = 561;
    local buffer = 10;
    local ok = { 0 , 0.77 , 0.063 };
    local notOk = { 0.64 , 0.102 , 0.102 };
    local unknown = { 1.0 , 0.647 , 0 };
    local count = 1;
    local count2 = 0;
    local numJoinUnknown = 0;
    local numJoinNoDate = 0;
    local numPromoUnknown = 0;
    local numPromoNoDate = 0;
    local isComplete = true;
    local tempGuild = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    local guildList = {};
    -- Type of sort;
    if typeOfSort == nil or typeOfSort == 1 then
        guildList = GRM.GetAllGuildiesInOrder ( true , true );
    elseif typeOfSort == 2 then
        guildList = GRM.GetAllGuildiesInOrder ( true , false );
    elseif typeOfSort == 3 then
        guildList = GRM.GetAllGuildiesInJoinDateOrder ( true , true );
    elseif typeOfSort == 4 then
        guildList = GRM.GetAllGuildiesInJoinDateOrder ( true , false );
    elseif typeOfSort == 5 then
        guildList = GRM.GetAllGuildiesInPromoDateOrder ( true , true );
    elseif typeOfSort == 6 then
        guildList = GRM.GetAllGuildiesInPromoDateOrder ( true , false );
    elseif typeOfSort == 7 then
        guildList = GRM.GetAllMainsAndAltsInOrder ( true , true );
    elseif typeOfSort == 8 then
        guildList = GRM.GetAllMainsAndAltsInOrder ( true , false );
    end
    
    -- Infinite scroll setup.
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider.ScrollCount > #tempGuild then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider.ScrollCount = #tempGuild;
    elseif GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider.ScrollCount < 51 then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider.ScrollCount = 51;
    end

    -- Building all the fontstrings.
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings or {};  -- Create a table for the Buttons.
    

    for i = 1 , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider.ScrollCount do
        isComplete = true;
        for j = 2 , #tempGuild do
            if tempGuild[j][1] == guildList[i] then
            -- We know there is at least one, so let's hide the warning string...
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText5:Hide();
                -- if font string is not created, do so.
                if not GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings[i] then
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings[i] = { GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame:CreateFontString ( "GRM_Guildie" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame:CreateFontString ( "GRM_GuildieJoinDate" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame:CreateFontString ( "GRM_GuildiePromoDate" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame:CreateFontString ( "GRM_GuildieMainAlt" .. count , "OVERLAY" , "GameFontWhiteTiny" ) };
                end

                local AddonUserText1 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings[count][1];
                local AddonUserText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings[count][2];
                local AddonUserText3 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings[count][3];
                local AddonUserText4 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings[count][4];
                local classColorRGB = GRM.GetClassColorRGB ( tempGuild[j][9] );
                -- name
                AddonUserText1:SetText ( guildList[i] );
                AddonUserText1:SetTextColor ( classColorRGB[1] , classColorRGB[2] , classColorRGB[3] );
                AddonUserText1:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 12 );
                AddonUserText1:SetJustifyH ( "LEFT" );
                AddonUserText1:SetWidth ( 190 );
                AddonUserText1:SetWordWrap ( false );

                -- Join Date
                AddonUserText2:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 12 );
                AddonUserText2:SetWidth ( 125 );
                AddonUserText2:SetWordWrap ( false );
                AddonUserText2:SetJustifyH ( "CENTER" );
                if #tempGuild[j][20] == 0 then
                    if tempGuild[j][40] then
                        AddonUserText2:SetText ( GRM.L ( "Unknown" ) );
                        AddonUserText2:SetTextColor ( unknown[1] , unknown[2] , unknown[3] , 1.0 );
                        numJoinUnknown = numJoinUnknown + 1;
                        if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][33] then
                            isComplete = false;
                        end
                    else
                        AddonUserText2:SetText ( GRM.L ( "No Date Set" ) );
                        AddonUserText2:SetTextColor ( notOk[1] , notOk[2] , notOk[3] , 1.0 );
                        numJoinNoDate = numJoinNoDate + 1;
                        isComplete = false;
                    end
                else
                    AddonUserText2:SetText ( GRM.FormatTimeStamp ( tempGuild[j][20][#tempGuild[j][20]] ) );
                    AddonUserText2:SetTextColor ( ok[1] , ok[2] , ok[3] , 1.0 ); 
                end

                -- Promo Date
                AddonUserText3:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 12 );
                AddonUserText3:SetJustifyH ( "CENTER" );
                AddonUserText3:SetWidth ( 125 );
                if tempGuild[j][12] == nil then
                    if tempGuild[j][41] then
                        AddonUserText3:SetText ( GRM.L ( "Unknown" ) );
                        AddonUserText3:SetTextColor ( unknown[1] , unknown[2] , unknown[3] , 1.0 );
                        numPromoUnknown = numPromoUnknown + 1;
                        if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][33] then
                            isComplete = false;
                        end
                    else
                        AddonUserText3:SetText ( GRM.L ( "No Date Set" ) );
                        AddonUserText3:SetTextColor ( notOk[1] , notOk[2] , notOk[3] , 1.0 );
                        numPromoNoDate = numPromoNoDate + 1;
                        isComplete = false;
                    end
                else
                    AddonUserText3:SetText ( GRM.FormatTimeStamp ( tempGuild[j][25][#tempGuild[j][25]][2] ) );
                    AddonUserText3:SetTextColor ( ok[1] , ok[2] , ok[3] , 1.0 ); 
                end

                -- Main or Alt
                AddonUserText4:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 12 );
                AddonUserText4:SetJustifyH ( "CENTER" );
                AddonUserText4:SetWidth ( 125 );
                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][10] then
                    AddonUserText4:SetText ( GRM.L ( "Main" ) );
                    AddonUserText4:SetTextColor ( ok[1] , ok[2] , ok[3] , 1.0 );
                else
                    -- Ok, they are not the main... do they have alts? If they have alts, we should see if one of them is listed as main.
                    if #tempGuild[j][11] > 0 then
                        local mainIsFound = false;
                        for m = 1 , #tempGuild[j][11] do
                            if tempGuild[j][11][m][5] then
                                mainIsFound = true;
                                break;
                            end
                        end
                        -- No one is listed as "main" in alt grouping.
                        if not mainIsFound then
                            AddonUserText4:SetText ( GRM.L ( "Main or Alt?" ) );
                            AddonUserText4:SetTextColor ( notOk[1] , notOk[2] , notOk[3] , 1.0 )
                            isComplete = false;
                        else
                            AddonUserText4:SetText ( GRM.L ( "Alt" ) );
                            AddonUserText4:SetTextColor ( ok[1] , ok[2] , ok[3] , 1.0 );
                        end
                    else
                        AddonUserText4:SetText ( GRM.L ( "Main or Alt?" ) );
                        AddonUserText4:SetTextColor ( notOk[1] , notOk[2] , notOk[3] , 1.0 );
                        isComplete = false;
                    end
                end
                if not isComplete or not GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][30] then
                    -- Variable to hold height to know how much more to add to scrollframe.
                    local stringHeight = AddonUserText1:GetStringHeight();
                    
                    -- Now let's pin it!
                    if count == 1 then
                        AddonUserText1:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame , "TOPLEFT" , 5 , - 10 );
                        AddonUserText2:SetPoint( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame , "TOP" , -35 , - 10 );
                        AddonUserText3:SetPoint( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame , "TOP" , 95 , - 10 );
                        AddonUserText4:SetPoint( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame , "TOPRIGHT" , -60 , - 10 );
                        scrollHeight = scrollHeight + stringHeight;
                    else
                        AddonUserText1:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings[count - 1][1] , "BOTTOMLEFT" , 0 , - buffer );
                        AddonUserText2:SetPoint( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings[count - 1][2] , "BOTTOM" , 0 , - buffer );
                        AddonUserText3:SetPoint( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings[count - 1][3] , "BOTTOM" , 0 , - buffer );
                        AddonUserText4:SetPoint( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings[count - 1][4] , "BOTTOM" , 0 , - buffer );
                        scrollHeight = scrollHeight + stringHeight + buffer;
                    end
                    AddonUserText1:Show();
                    AddonUserText2:Show();
                    AddonUserText3:Show();
                    AddonUserText4:Show();
                    count = count + 1;
                    if not isComplete then
                        count2 = count2 + 1;
                    end
                end
                break;
            end
        end
    end

    -- Hides all the additional strings... if necessary ( necessary because of filtering and some might have quit guild since )
    for i = count , #GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings do
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings[i][1]:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings[i][2]:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings[i][3]:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings[i][4]:Hide();
    end 

    -- Update the size -- it either grows or it shrinks!
    -- This size check is important as if the scroll frame is too small
    -- if scrollHeight < GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrame:GetHeight() then
    --     GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrame = scrollHeight;
    -- end 
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame:SetSize ( scrollWidth , scrollHeight + ( buffer * 2 ) );

    --Set Slider Parameters ( has to be done after the above details are placed )
    local scrollMax = ( scrollHeight - 349 ) + ( buffer );  -- 18 comes from fontSize (11) + buffer (7);
    if scrollMax < 0 then
        scrollMax = 0;
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
    -- Mousewheel Scrolling Logic
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrame:EnableMouseWheel( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrame:SetScript( "OnMouseWheel" , function( _ , delta )
        local current = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider:GetValue();
        
        if IsShiftKeyDown() and delta > 0 then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider:SetValue ( 0 );
        elseif IsShiftKeyDown() and delta < 0 then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider:SetValue ( scrollMax );
        elseif delta < 0 and current < scrollMax then
            if IsControlKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider:SetValue ( current + 60 );
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider:SetValue ( current + 20 );
            end
        elseif delta > 0 and current > 1 then
            if IsControlKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider:SetValue ( current - 60 );
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider:SetValue ( current - 20 );
            end
        end
    end);

    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText5:SetText ( GRM.L ( "Total Incomplete: {num} / {custom1}" , nil , nil , count2 , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrameSlider.ScrollCount - 1 ) );
    GRM_UI.ScaleFontStringToObjectSize ( true , 190 , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText5 , 2 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText5:Show();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText8:SetText ( GRM.L ( "Mains: {num}" , nil , nil , GRM.GetNumMains() ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText8:Show();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText7:SetText ( GRM.L ( "Unique Accounts: {num}" , nil , nil , GRM_G.numAccounts ) );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText7:Show();
    if ( numJoinUnknown + numJoinNoDate ) == 0 then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:SetText ( GRM.L ( "All Complete" ) );
    elseif numJoinNoDate > 0 then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:SetText ( GRM.L ( "Set Incomplete to Unknown" ) );
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:SetText ( GRM.L ( "Clear All Unknown" ) );
    end

    if ( numPromoUnknown + numPromoNoDate ) == 0 then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:SetText ( GRM.L ( "All Complete" ) );
    elseif numPromoNoDate > 0 then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:SetText ( GRM.L ( "Set Incomplete to Unknown" ) );
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:SetText ( GRM.L ( "Clear All Unknown" ) );
    end
end

-- Method:          RefreshAddonUserFrames()
-- What it Does:    It Initializes and rebuilds the frames to see who you are syncing with in the guild and if not, why not.
-- Purpose:         Purely quality of life information.
GRM.RefreshAddonUserFrames = function()
    -- To prevent double spam...
    GRM_G.timer5 = 0;

    -- Notification that player has sync disabled themselves.
    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersSyncEnabledText:Hide();
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersSyncEnabledText:Show();
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
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons ~= nil then
        for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons do
            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i][1]:Hide();
            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i][1]:UnlockHighlight();
        end
    end
    -- Status Notification logic
    -- remember, position 1 is the guild name, so players start at index 2
    if #GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID] > 1 then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:SetText ( GRM.L ( "Please Select Event to Add to Calendar" ) );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:Show();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:Hide();
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:SetText ( GRM.L ( "No Calendar Events to Add" ) );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:Show();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:Hide();
    end

    if CanEditGuildEvent() then
        if not GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][8] then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText2:SetText ( GRM.L ( "You Currently Have Disabled Adding Events to Calendar" ) );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText2:Show();
        else
            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText2:Hide();
        end
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText2:SetText ( GRM.L ( "You Do Not Have Permission to Add Events to Calendar" ) );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText2:Show();
    end
    -- Ok Building Frame!
    GRM.BuildEventCalendarManagerScrollFrame();
end

-- Method:          GRM.FinalReport()
-- What it Does:    Organizes flow of final report and send it to chat frame and to the logReport.
-- Purpose:         Clean organization for presentation.
GRM.FinalReport = function()
    if GRM_G.changeHappenedExitScan then
        GRM.ResetTempLogs();
        GRM_G.changeHappenedExitScan = false;
        GRM_G.CurrentlyScanning = false;
        return;
    end
    local needToReport = false;

    -- For extra tracking info to display if the left player is on the server anymore...
    if #GRM_G.TempLeftGuild > 0 then
        -- need to build the names of those leaving for insert...
        
        local names = {};
        for i = 1 , #GRM_G.leavingPlayers do
            table.insert ( names , GRM_G.leavingPlayers[i][1] );
        end
        -- Establishing the players that left but are still on the server
        GRM.SetLeftPlayersStillOnServer ( names );
    end

    -- Cleanup the notes for reporting
    -- Join Dates Cleaned up First
    if #GRM_G.TempNewMember > 0 then
        local tempTable = {};
        for i = 1 , #GRM_G.TempNewMember do
            if string.find ( GRM_G.TempNewMember[i][2] , GRM.L ( "Invited By:" ) ) ~= nil then
                table.insert ( tempTable , 1 , GRM_G.TempNewMember[i] );
            else
                table.insert ( tempTable , GRM_G.TempNewMember[i] );
            end
        end
        GRM_G.TempNewMember = tempTable;
    end

    -- No need to spam the chat window when logging in.
    if not GRM_G.OnFirstLoad then

        if #GRM_G.TempBannedRejoin > 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][1] then
            
            for i = 1 , #GRM_G.TempBannedRejoin do
                GRM.PrintLog ( GRM_G.TempBannedRejoin[i][1] , GRM_G.TempBannedRejoin[i][2] , GRM_G.TempBannedRejoin[i][3] );
                GRM.PrintLog ( GRM_G.TempBannedRejoin[i][4] , GRM_G.TempBannedRejoin[i][5] , GRM_G.TempBannedRejoin[i][3] );
            end
        end
    
        if #GRM_G.TempRejoin > 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][1] then
            
            for i = 1 , #GRM_G.TempRejoin do
                GRM.PrintLog ( GRM_G.TempRejoin[i][1] , GRM_G.TempRejoin[i][2] , GRM_G.TempRejoin[i][3] );            -- Same Comments on down
                GRM.PrintLog ( GRM_G.TempRejoin[i][4] , GRM_G.TempRejoin[i][5] , GRM_G.TempRejoin[i][3] );
            end
        end

        if #GRM_G.TempNewMember > 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][1] then
            
            for i = 1 , #GRM_G.TempNewMember do
                GRM.PrintLog ( GRM_G.TempNewMember[i][1] , GRM_G.TempNewMember[i][2] , GRM_G.TempNewMember[i][3] );   -- Send to print to chat window
            end
        end

        if #GRM_G.TempNameChanged > 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][8] then
            
            for i = 1 , #GRM_G.TempNameChanged do
                GRM.PrintLog ( GRM_G.TempNameChanged[i][1] , GRM_G.TempNameChanged[i][2] , GRM_G.TempNameChanged[i][3] );
            end
        end

        if #GRM_G.TempLogPromotion > 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][4] then
            
            for i = 1 , #GRM_G.TempLogPromotion do
                GRM.PrintLog ( GRM_G.TempLogPromotion[i][1] , GRM_G.TempLogPromotion[i][2] , GRM_G.TempLogPromotion[i][3] );
            end
        end

        if #GRM_G.TempLogDemotion > 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][5] then
            
            for i = 1 , #GRM_G.TempLogDemotion do
                GRM.PrintLog ( GRM_G.TempLogDemotion[i][1] , GRM_G.TempLogDemotion[i][2] , GRM_G.TempLogDemotion[i][3] );                          
            end
        end

        if #GRM_G.TempInactiveReturnedLog > 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][3] then
            
            for i = 1 , #GRM_G.TempInactiveReturnedLog do
                GRM.PrintLog ( GRM_G.TempInactiveReturnedLog[i][1] , GRM_G.TempInactiveReturnedLog[i][2] , GRM_G.TempInactiveReturnedLog[i][3] );
            end
        end

        if #GRM_G.TempRankRename > 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][9] then
            
            for i = 1 , #GRM_G.TempRankRename do
                GRM.PrintLog ( GRM_G.TempRankRename[i][1] , GRM_G.TempRankRename[i][2] , GRM_G.TempRankRename[i][3] );
            end
        end

        if #GRM_G.TempLogLeveled > 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][2] then
            
            for i = 1 , #GRM_G.TempLogLeveled do
                GRM.PrintLog ( GRM_G.TempLogLeveled[i][1] , GRM_G.TempLogLeveled[i][2] , GRM_G.TempLogLeveled[i][3] );                  
            end
        end

        if #GRM_G.TempLogNote > 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][6] then
            
            for i = 1 , #GRM_G.TempLogNote do
                GRM.PrintLog ( GRM_G.TempLogNote[i][1] , GRM_G.TempLogNote[i][2] , GRM_G.TempLogNote[i][3] );         
            end
        end

        if #GRM_G.TempLogONote > 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][7] then
            
            for i = 1 , #GRM_G.TempLogONote do
                GRM.PrintLog ( GRM_G.TempLogONote[i][1] , GRM_G.TempLogONote[i][2] , GRM_G.TempLogONote[i][3] );  
            end
        end

        if #GRM_G.TempEventReport > 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][10] then
            
            for i = 1 , #GRM_G.TempEventReport do
                GRM.PrintLog ( GRM_G.TempEventReport[i][1] , GRM_G.TempEventReport[i][2] , GRM_G.TempEventReport[i][3] );
            end
        end

        if #GRM_G.TempEventRecommendKickReport > 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][12] then
            
            for i = 1 , #GRM_G.TempEventRecommendKickReport do
                GRM.PrintLog ( GRM_G.TempEventRecommendKickReport[i][1] , GRM_G.TempEventRecommendKickReport[i][2] , GRM_G.TempEventRecommendKickReport[i][3]); 
            end
        end
    end

    -- OK, NOW LET'S REPORT TO LOG FRAME IN REVERSE ORDER!!!

    if #GRM_G.TempEventRecommendKickReport > 0 then
        needToReport = true;
        if GRM_G.OnFirstLoad then
            GRM_G.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_G.TempEventRecommendKickReport do
            GRM.AddLog ( GRM_G.TempEventRecommendKickReport[i][1] , GRM_G.TempEventRecommendKickReport[i][2]);                    
        end
    end

    if #GRM_G.TempEventReport > 0 then
        needToReport = true;
        if GRM_G.OnFirstLoad then
            GRM_G.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_G.TempEventReport do
            GRM.AddLog( GRM_G.TempEventReport[i][1] , GRM_G.TempEventReport[i][2] );
        end
    end

    if #GRM_G.TempLogONote > 0 then
        needToReport = true;
        if GRM_G.OnFirstLoad then
            GRM_G.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_G.TempLogONote do
            GRM.AddLog ( GRM_G.TempLogONote[i][1] , GRM_G.TempLogONote[i][2] );                    
        end
    end
 
    if #GRM_G.TempLogNote > 0 then
        needToReport = true;
        if GRM_G.OnFirstLoad then
            GRM_G.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_G.TempLogNote do
            GRM.AddLog ( GRM_G.TempLogNote[i][1] , GRM_G.TempLogNote[i][2] );                    
        end
    end

    if #GRM_G.TempLogLeveled > 0 then
        needToReport = true;
        if GRM_G.OnFirstLoad then
            GRM_G.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_G.TempLogLeveled do
            GRM.AddLog ( GRM_G.TempLogLeveled[i][1] , GRM_G.TempLogLeveled[i][2] );                    
        end
    end

    if #GRM_G.TempRankRename > 0 then
        needToReport = true;
        if GRM_G.OnFirstLoad then
            GRM_G.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_G.TempRankRename do
            GRM.AddLog ( GRM_G.TempRankRename[i][1] , GRM_G.TempRankRename[i][2] );
        end
    end

    if #GRM_G.TempLogDemotion > 0 then
        needToReport = true;
        if GRM_G.OnFirstLoad then
            GRM_G.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_G.TempLogDemotion do
            GRM.AddLog ( GRM_G.TempLogDemotion[i][1] , GRM_G.TempLogDemotion[i][2] );                           
        end
    end

    if #GRM_G.TempLogPromotion > 0 then
        needToReport = true;
        if GRM_G.OnFirstLoad then
            GRM_G.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_G.TempLogPromotion do
            GRM.AddLog ( GRM_G.TempLogPromotion[i][1] , GRM_G.TempLogPromotion[i][2] );
        end
    end

    if #GRM_G.TempNameChanged > 0 then
        needToReport = true;
        if GRM_G.OnFirstLoad then
            GRM_G.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_G.TempNameChanged do
            GRM.AddLog ( GRM_G.TempNameChanged[i][1] , GRM_G.TempNameChanged[i][2] );
        end
    end

    if #GRM_G.TempInactiveReturnedLog > 0 then
        needToReport = true;
        if GRM_G.OnFirstLoad then
            GRM_G.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_G.TempInactiveReturnedLog do
            GRM.AddLog ( GRM_G.TempInactiveReturnedLog[i][1] , GRM_G.TempInactiveReturnedLog[i][2] );
        end
    end

    if #GRM_G.TempBannedRejoin > 0 then
        needToReport = true;
        if GRM_G.OnFirstLoad then
            GRM_G.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_G.TempBannedRejoin do
            GRM.AddLog ( GRM_G.TempBannedRejoin[i][4] , GRM_G.TempBannedRejoin[i][5] );
            GRM.AddLog ( GRM_G.TempBannedRejoin[i][1] , GRM_G.TempBannedRejoin[i][2] );
        end
    end

    if #GRM_G.TempRejoin > 0 then
        needToReport = true;
        if GRM_G.OnFirstLoad then
            GRM_G.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_G.TempRejoin do
            GRM.AddLog ( GRM_G.TempRejoin[i][4] , GRM_G.TempRejoin[i][5] );
            GRM.AddLog ( GRM_G.TempRejoin[i][1] , GRM_G.TempRejoin[i][2] );
        end
    end

    if #GRM_G.TempNewMember > 0 then
        needToReport = true;
        if GRM_G.OnFirstLoad then
            GRM_G.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_G.TempNewMember do
            GRM.AddLog ( GRM_G.TempNewMember[i][1] , GRM_G.TempNewMember[i][2] );                                           -- Adding to the Log of Events
        end
    end
    -- 1.1 to set it immediately after the other 1 second delay for server to register added friends.
    local time = 1.1;
    if #GRM_G.TempLeftGuild == 0 then
        time = 0;
    end

    -- Delay function so players can be determined if they are online or not.
    C_Timer.After ( time , function()
        if GRM_G.changeHappenedExitScan then
            GRM.ResetTempLogs();
            GRM_G.changeHappenedExitScan = false;
            GRM_G.CurrentlyScanning = false;
            return;
        end

        if #GRM_G.TempLeftGuild > 0 then
            needToReport = true;
            if GRM_G.OnFirstLoad then
                GRM_G.ChangesFoundOnLoad = true;
            end
            -- Let's compare our left players now...
            local isMatched = false;
            for i = 1 , #GRM_G.leavingPlayers do
                isMatched = false;
                for j = 1 , #GRM_G.LeftPlayersStillOnServer do
                    if GRM_G.leavingPlayers[i][1] == GRM_G.LeftPlayersStillOnServer[j][1] then
                        isMatched = true;
                        -- now let's match it to propper tempLeft table
                        break;
                    end
                end
                local timePassed = GRM.GetTimePlayerHasBeenMember ( GRM_G.leavingPlayers[i][1] );
                if timePassed ~= "" then
                    timePassed = ( "|cFFFFFFFF" .. GRM.L ( "Time as Member:" ) .. " " .. timePassed .. "|r" );
                end
                -- if not isMatched then (player not on friends list... this means that the player has left the server or namechanged)
                if not isMatched then
                    for m = 1 , #GRM_G.TempLeftGuild do
                        if string.find ( GRM_G.TempLeftGuild[m][2] , GRM.L ( "has Left the guild" ) ) ~= nil and string.find ( GRM_G.TempLeftGuild[m][2] , GRM.SlimName ( GRM_G.leavingPlayers[i][1] ) ) ~= nil then
                            if string.find ( GRM_G.TempLeftGuild[m][2] , GRM.L ( "ALTS IN GUILD:" ) ) ~= nil then
                                local _ , index2 = string.find ( GRM_G.TempLeftGuild[m][2] , "\n" );
                                if timePassed ~= "" then
                                    GRM_G.TempLeftGuild[m][2] = string.sub ( GRM_G.TempLeftGuild[m][2] , 1 , index2 - 1 ) .. " |CFFFF0000(" .. GRM.L ( "Player no longer on Server" ) .. ")|CFF808080" .. string.sub ( GRM_G.TempLeftGuild[m][2] , index2 ) .. "\n" .. timePassed;
                                else
                                    GRM_G.TempLeftGuild[m][2] = string.sub ( GRM_G.TempLeftGuild[m][2] , 1 , index2 - 1 ) .. " |CFFFF0000(" .. GRM.L ( "Player no longer on Server" ) .. ")|CFF808080" .. string.sub ( GRM_G.TempLeftGuild[m][2] , index2 );
                                end
                                
                            else
                                if timePassed ~= "" then
                                    GRM_G.TempLeftGuild[m][2] = GRM_G.TempLeftGuild[m][2] .. " |CFFFF0000(" .. GRM.L ( "Player no longer on Server" ) .. ")\n" .. timePassed;
                                else
                                    GRM_G.TempLeftGuild[m][2] = GRM_G.TempLeftGuild[m][2] .. " |CFFFF0000(" .. GRM.L ( "Player no longer on Server" ) .. ")";
                                end
                            end
                            break;
                        end
                    end
                else
                    -- Player is still on the server, just no longer in the guild
                    for m = 1 , #GRM_G.TempLeftGuild do
                        if string.find ( GRM_G.TempLeftGuild[m][2] , GRM.L ( "has Left the guild" ) ) ~= nil and string.find ( GRM_G.TempLeftGuild[m][2] , GRM.SlimName ( GRM_G.leavingPlayers[i][1] ) ) ~= nil then
                            if timePassed ~= "" then
                                GRM_G.TempLeftGuild[m][2] = GRM_G.TempLeftGuild[m][2] .. " (" .. timePassed .. ")";
                            else
                                GRM_G.TempLeftGuild[m][2] = GRM_G.TempLeftGuild[m][2];
                            end
                            break;
                        end
                    end

                    for m = 1 , #GRM_G.TempLeftGuild do
                        if string.find ( GRM_G.TempLeftGuild[m][2] , GRM.L ( "kicked" ) ) ~= nil and string.find ( GRM_G.TempLeftGuild[m][2] , GRM.SlimName ( GRM_G.leavingPlayers[i][1] ) ) ~= nil then
                            if timePassed ~= "" then
                                GRM_G.TempLeftGuild[m][2] = GRM_G.TempLeftGuild[m][2] .. " (" .. timePassed .. ")";
                            else
                                GRM_G.TempLeftGuild[m][2] = GRM_G.TempLeftGuild[m][2];
                            end
                            break;
                        end
                    end
                end
            end
            -- Ok, sending to chat
            if not GRM_G.OnFirstLoadKick then
                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][11] then
                    for i = 1 , #GRM_G.TempLeftGuild do
                        GRM.PrintLog ( GRM_G.TempLeftGuild[i][1] , GRM_G.TempLeftGuild[i][2] , GRM_G.TempLeftGuild[i][3] );
                    end
                end
            end
            -- sending to log
            for i = 1 , #GRM_G.TempLeftGuild do
                if GRM_G.OnFirstLoad then
                    GRM_G.ChangesFoundOnLoad = true;
                end
                GRM.AddLog ( GRM_G.TempLeftGuild[i][1] , GRM_G.TempLeftGuild[i][2] );
            end

        end

        -- Update the Add Event Window
        if #GRM_G.TempEventReport > 0 and GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:IsVisible() then
            GRM.RefreshAddEventFrame();
        end
        -- Clear the changes.
        GRM.ResetTempLogs();

        if GRM_G.OnFirstLoad and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][2] then
            if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][28] and GRM_G.ChangesFoundOnLoad then
                GRM_UI.GRM_RosterChangeLogFrame:Show();
            end
        end
        -- Let's update the frames!
        if needToReport and GRM_UI.GRM_RosterChangeLogFrame ~= nil and GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then
            GRM.BuildLogComplete();
        end

        if GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
            GRM.PopulateMemberDetails ( GRM_G.currentName );
        end
        if GRM_G.OnFirstLoad then
            C_Timer.After ( 5 , GRM.UpdateRecruitmentPlayerStatus );
        end
        GRM_G.OnFirstLoad = false;
        GRM_G.changeHappenedExitScan = false;
        GRM_G.CurrentlyScanning = false;
    end);
end

-- Method:          GRM.GetGuildEventString ( int , string , string )
-- What it Does:    Gets more exact info from the actual Guild Event Log ( can only be queried once per 10 seconds) as a string
-- Purpose:         This parses more exact info, like "who" did the kicking, or "who" invited who, and so on.
GRM.GetGuildEventString = function ( index , playerName , initRank , FinRank )
    -- index 1 = demote , 2 = promote , 3 = remove/quit , 4 = invite/join
    local result = "";
    local eventType = { "demote" , "promote" , "invite" , "join" , "quit" , "remove" };
    -- local classColorCode = GRM.GetStringClassColorByName ( playerName );
    QueryGuildEventLog();

    if index == 1 or index == 2 then
        for i = GetNumGuildEvents() , 1 , -1 do
            local type , p1, p2 , _ , year , month , day , hour = GetGuildEventInfo ( i );
            if p1 ~= nil then                                                 ---or eventType [ 2 ] == type ) and ( p2 ~= nil and p2 == playerName ) and p1 ~= nil then
                if index == 1 and eventType [ 1 ] == type and p2 ~= nil and ( p2 == playerName or p2 == GRM.SlimName ( playerName ) ) then
                    p1 = GRM.GetStringClassColorByName ( p1 ) .. GRM.SlimName ( p1 ) .. "|r";
                    p2 = GRM.GetStringClassColorByName ( p2 ) .. GRM.SlimName ( p2 ) .. "|r";
                    result = GRM.L ( "{name} DEMOTED {name2} from {custom1} to {custom2}" , p1 , p2 , nil , initRank , FinRank );
                    GRM_G.PlayerFromGuildLog = p1;
                    GRM_G.GuildLogDate = { year , month , day , hour };
                    break;
                elseif index == 2 and eventType [ 2 ] == type and p2 ~= nil and ( p2 == playerName or p2 == GRM.SlimName ( playerName ) ) then
                    p1 = GRM.GetStringClassColorByName ( p1 ) .. GRM.SlimName ( p1 ) .. "|r";
                    p2 = GRM.GetStringClassColorByName ( p2 ) .. GRM.SlimName ( p2 ) .. "|r";
                    result = GRM.L ( "{name} PROMOTED {name2} from {custom1} to {custom2}" , p1 , p2 , nil , initRank , FinRank );
                    GRM_G.PlayerFromGuildLog = p1;
                    GRM_G.GuildLogDate = { year , month , day , hour };
                    break;
                end
            end
        end
   elseif index == 3 then
        local notFound = true;
        for i = GetNumGuildEvents() , 1 , -1 do 
            local type , p1, p2 , _ , year , month , day , hour = GetGuildEventInfo ( i );
            if p1 ~= nil then 
                if eventType [ 5 ] == type or eventType [ 6 ] == type then   -- Quit or Remove
                    if eventType [ 6 ] == type and p2 ~= nil and ( p2 == playerName or p2 == GRM.SlimName ( playerName ) ) then
                        p1 = GRM.GetStringClassColorByName ( p1 ) .. GRM.SlimName ( p1 ) .. "|r";
                        p2 = GRM.GetStringClassColorByName ( p2 ) .. GRM.SlimName ( p2 ).. "|r";
                        result = GRM.L ( "{name} KICKED {name2} from the Guild!" , p1 , p2 );
                        GRM_G.PlayerFromGuildLog = p1;
                        GRM_G.GuildLogDate = { year , month , day , hour };
                        notFound = false;
                    elseif eventType [ 5 ] == type and ( p1 == playerName or p1 == GRM.SlimName ( playerName ) ) then
                        -- FOUND!
                        p1 = GRM.GetStringClassColorByName ( playerName ) .. GRM.SlimName ( playerName ) .. "|r";
                        result = ( GRM.L ( "{name} has Left the guild" , p1 ) );
                        GRM_G.GuildLogDate = { year , month , day , hour };
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
            local type , p1, p2 , _ , year , month , day , hour = GetGuildEventInfo ( i );
            if eventType [ 3 ] == type and p1 ~= nil and p2 ~= nil and ( p2 == playerName or p2 == GRM.SlimName ( playerName ) ) then  -- invite
                p1 = GRM.GetStringClassColorByName ( p1 ) .. GRM.SlimName ( p1 ) .. "|r";
                p2 = GRM.GetStringClassColorByName ( p2 ) .. GRM.SlimName ( p2 ) .. "|r";
                GRM_G.PlayerFromGuildLog = p1;
                GRM_G.GuildLogDate = { year , month , day , hour };
                result = GRM.L ( "{name} INVITED {name2} to the guild." , p1 , p2 );
                break;
            end
        end
    end
    return result;
end

-- Method:          GRM.RecordKickChanges ( string , boolean )
-- What it Does:    Records and logs the changes for when a guildie either is KICKED or leaves the guild
-- Purpose:         Having its own function saves on repeating a lot of code here.
GRM.RecordKickChanges = function ( unitName , playerKicked )
    local timestamp = GRM.GetTimestamp();
    local timeEpoch = time();

    local tempGuildDatabase = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    local logReport = "";
    local tempStringRemove = "";
    local classColorCode = GRM.GetStringClassColorByName ( unitName );
    local timePassed = GRM.GetTimePlayerHasBeenMember ( unitName );
    if timePassed ~= "" then
        timePassed = ( "\n|cFFFFFFFF" .. GRM.L ( "Time as Member:" ) .. " " .. timePassed .. "|r" );
    end

    if not playerKicked then
        tempStringRemove = GRM.GetGuildEventString ( 3 , unitName ); -- Kicked from the guild.
        if tempStringRemove ~= nil and tempStringRemove ~= "" then
            local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_G.GuildLogDate );
            timestamp = tempData[1];
            timeEpoch = tempData[2];
            logReport = ( GRM.FormatTimeStamp ( timestamp , true ) .. " : " .. tempStringRemove );
        else
            logReport = ( GRM.FormatTimeStamp ( timestamp , true ) .. " : " ..  GRM.L ( "{name} has Left the guild" , classColorCode .. unitName .. "|CFF808080" ) );
        end
    else
        -- The player kicked them right now LIVE!
        logReport = ( GRM.FormatTimeStamp ( timestamp , true ) .. " : " .. GRM.L ( "{name} KICKED {name2} from the Guild!" , GRM.GetStringClassColorByName ( GRM_G.addonPlayerName ) .. GRM.SlimName ( GRM_G.addonPlayerName ) .. "|r" , classColorCode .. unitName .. "|r" ) );
    end
    
    -- Finding Player's record for removal of current guild and adding to the Left Guild table.
    for j = 2 , #tempGuildDatabase do  -- Scanning through all entries
        if unitName == tempGuildDatabase[j][1] then -- Matching member leaving to guild saved entry
            -- Found!
            table.insert ( tempGuildDatabase[j][15], timestamp );                                       -- leftGuildDate
            table.insert ( tempGuildDatabase[j][16], timeEpoch );                                       -- leftGuildDateMeta
            table.insert ( tempGuildDatabase[j][25] , { "|cFFC41F3BLeft Guild" , GRM.Trim ( string.sub ( timestamp , 1 , 10 ) ) } );      -- Translate on show only, not here.
            tempGuildDatabase[j][19] = tempGuildDatabase[j][4];         -- old Rank on leaving.
            if #tempGuildDatabase[j][20] == 0 then                                                 -- Let it default to date addon was installed if date joined was never given
                table.insert( tempGuildDatabase[j][20] , tempGuildDatabase[j][2] );   -- oldJoinDate
                table.insert( tempGuildDatabase[j][21] , tempGuildDatabase[j][3] );   -- oldJoinDateMeta
            end

            -- If not banned, then let's ensure we reset his data.
            if not tempGuildDatabase[j][17][1] then
                tempGuildDatabase[j][17][1] = false;
                tempGuildDatabase[j][17][2] = 0;
                tempGuildDatabase[j][17][3] = false;
                tempGuildDatabase[j][18] = "";
            end
            -- Adding to LeftGuild Player history library
            table.insert ( GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][GRM_G.saveGID] , tempGuildDatabase[j] );

            -- Removing it from the alt list
            if #tempGuildDatabase[j][11] > 0 then

                -- Let's add them to the end of the report
                local countAlts = #tempGuildDatabase[j][11];
                local altClassColorCode;
                local count = 0;
                local isFound = false;
                for m = 1 , countAlts do
                    isFound = false;
                    -- Verify the alt is not on the kick list already;
                    for r = 1 , #GRM_G.TempLeftGuildPlaceholder do
                        if GRM_G.TempLeftGuildPlaceholder[r][1] == tempGuildDatabase[j][11][m][1] then
                            isFound = true;
                            break;
                        end
                    end
                    
                    if not isFound then
                        count = count + 1;
                        if count == 1 then
                            altClassColorCode = GRM.GetStringClassColorByName ( tempGuildDatabase[j][11][m][1] );
                            logReport = logReport .. "\n " .. GRM.L ( "ALTS IN GUILD:" ) .. " " .. altClassColorCode .. GRM.SlimName ( tempGuildDatabase[j][11][m][1] .. "|r" );
                        else
                            altClassColorCode = GRM.GetStringClassColorByName ( tempGuildDatabase[j][11][m][1] );
                            logReport = logReport .. GRM.L ( "," ) .. " " .. altClassColorCode .. GRM.SlimName ( tempGuildDatabase[j][11][m][1] .. "|r" );
                        end
                    end

                    -- Just show limited number of alts...
                    if count == 5 and count < countAlts then
                        local count2 = 0;
                        -- This is to ensure the count is proper.
                        for s = m + 1 , countAlts do
                            for t = 1 , #GRM_G.TempLeftGuildPlaceholder do
                                if GRM_G.TempLeftGuildPlaceholder[t][1] == tempGuildDatabase[j][11][s][1] then
                                    count2 = count2 + 1;
                                    break;
                                end
                            end
                        end
                        local result = ( countAlts - count - count2 );
                        if result > 0 then
                            logReport = logReport .. GRM.L ( "(+ {num} More)" , nil , nil , result );
                        end
                        break;
                    end
                end
                
                -- Let's overwrite the listOfALts
                local tempListOfAlts = GRM.DeepCopyArray ( tempGuildDatabase[j][11] );
                GRM.RemoveAlt ( tempGuildDatabase[j][11][1][1] , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] , false , 0 , false );                 -- removes from the current guild alt list...
                GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][GRM_G.saveGID][#GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][GRM_G.saveGID]][11] = tempListOfAlts;         -- Stores the alt list in the left player databse. It will wipe on rejoin, but good to know...
            end
            -- removing from active member library
            table.remove ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] , j );
            
            break;
        end
    end
    -- Update the live frames too!
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:IsVisible() then
        GRM.RefreshBanListFrames();
    end

    if timePassed ~= "" then
        logReport = logReport .. timePassed;
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
    local month;
    -- Use default dates, since these are auto-tagged, you don't want your data to overwrite any others, so set it as OLD...
    local tempTimeStamp = "1 Jan '01 12:01am";
    local timeEpoch = 978375660;

    local tempStringInv = GRM.GetGuildEventString ( 4 , memberInfo[1] ); -- For determining who did the invite.
    -- Pulling the exact join/rejoin date from the official in-game log.
    if tempStringInv ~= nil and tempStringInv ~= "" then
        local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_G.GuildLogDate );
        tempTimeStamp = tempData[1];
        timeEpoch = tempData[2];
    end
    local tempGuildData = GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][GRM_G.saveGID];
    
    for j = 2 , #tempGuildData do -- Number of players that have left the guild.
        if memberInfo[1] == tempGuildData[j][1] or memberInfo[15] == tempGuildData[j][42] then
            -- Player is returning, but is also a namechange?
            local isNameChange = false;
            local nameChangeReport = "";
            
            if memberInfo[15] == tempGuildData[j][42] and memberInfo[1] ~= tempGuildData[j][1] then
                isNameChange = true;
                local classColorString = GRM.GetStringClassColorByName ( tempGuildData[j][1] , true );
                nameChangeReport = "\n" .. GRM.L ( "{name} has Name-Changed to {name2}" , classColorString .. GRM.SlimName ( tempGuildData[j][1] ) .. "|r" , classColorString .. simpleName .. "|r" )
                -- Update the banned player's name
                tempGuildData[j][1] = memberInfo[1];
            end
            -- MATCH FOUND - Player is RETURNING to the guild!
            -- Now, let's see if the player was banned before!
            local numTimesInGuild = #tempGuildData[j][20];
            local numTimesString = "";
            if numTimesInGuild > 1 then
                numTimesString = GRM.L ( "{name} has Been in the Guild {num} Times Before" , simpleName , nil , numTimesInGuild );
                
            else
                numTimesString = GRM.L ( "{name} is Returning for the First Time." , simpleName );
            end
            local timeStamp;
            if tempTimeStamp ~= "1 Jan '01 12:01am" then
                timeStamp = tempTimeStamp;
            else
                timeStamp = GRM.GetTimestamp();
            end
            if tempGuildData[j][17][1] then
                -- Player was banned! WARNING!!!
                local reasonBanned = tempGuildData[j][18];
                if reasonBanned == nil or reasonBanned == "" then
                    reasonBanned = GRM.L ( "None Given" );
                end
                local warning = ( GRM.FormatTimeStamp ( timeStamp , true ) .. " : " .. GRM.L ( "WARNING!" ) .. "\n" .. GRM.L ( "{name} REJOINED the guild but was previously BANNED!" , simpleName ) );
                if tempStringInv ~= nil and tempStringInv ~= "" then
                    warning = warning  .. GRM.L ( "(Invited by: {name})" , GRM_G.PlayerFromGuildLog );
                end
                
                local information = { { "|CFF66B5E6" .. GRM.L ( "Date of Ban:" ) .. "|r" , tempGuildData[j][15][#tempGuildData[j][15]] .. " " .. GRM.L ( "({num} ago)" , nil , nil , GRM.GetTimePassed ( tempGuildData[j][16][#tempGuildData[j][16]] ) ) } , { "|CFF66B5E6" .. GRM.L ( "Date Originally Joined:" ) .. "|r" , tempGuildData[j][20][1] } , { "|CFF66B5E6" .. GRM.L ( "Old Guild Rank:" ) .. "|r" , tempGuildData[j][19] } , { "|CFF66B5E6" .. GRM.L ( "Reason:" ) .. "|r" , reasonBanned } };
                -- Add an extra piece of info
                if tempGuildData[j][23][6] ~= "" then
                    table.insert ( information , { "|CFF66B5E6" .. GRM.L ( "Additional Notes:" ) .. "|r" , tempGuildData[j][23][6] } )
                end
                -- Add to the log, alligned
                table.insert ( GRM_G.TempBannedRejoin , { 9 , warning , false , 12 , numTimesString .. GRM.AllignTwoColumns ( information , 20 ) .. nameChangeReport } );
            else
                -- No Ban found, player just returning!
                if tempStringInv ~= nil and tempStringInv ~= "" then
                    logReport = ( GRM.FormatTimeStamp ( timeStamp , true ) .. " : " .. GRM.L ( "{name} has REINVITED {name2} to the guild" , GRM_G.PlayerFromGuildLog , simpleName ) .. " " .. GRM.L ( "(LVL: {num})" , nil , nil , memberInfo[4] ) );
                else
                    logReport = ( GRM.FormatTimeStamp ( timeStamp , true ) .. " : " .. GRM.L ( "{name} has REJOINED the guild" , simpleName ) .. " " .. GRM.L ( "(LVL: {num})" , nil , nil , memberInfo[4] ) );
                end

                local information = { { "|CFF66B5E6" .. GRM.L ( "Date Left:" ) .. "|r" , tempGuildData[j][15][#tempGuildData[j][15]] .. " " .. GRM.L ( "({num} ago)" , nil , nil , GRM.GetTimePassed ( tempGuildData[j][16][#tempGuildData[j][16]] ) ) } , { "|CFF66B5E6" .. GRM.L ( "Date Originally Joined:" ) .. "|r" , tempGuildData[j][20][1] } , { "|CFF66B5E6" .. GRM.L ( "Old Guild Rank:" ) .. "|r" , tempGuildData[j][19] } };
                -- Add an extra piece of info
                if tempGuildData[j][23][6] ~= "" then
                    table.insert ( information , { "|CFF66B5E6" .. GRM.L ( "Additional Notes:" ) .. "|r" , tempGuildData[j][23][6] } )
                end

                local toReport = { 7 , logReport , false , 12 , numTimesString .. GRM.AllignTwoColumns ( information , 20 ) .. nameChangeReport };

                table.insert ( GRM_G.TempRejoin , toReport );
            end
            rejoin = true;
            -- AddPlayerTo MemberHistory

            -- Adding timestamp to new Player.
            if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][7] and ( CanEditOfficerNote() or CanEditPublicNote() ) then
                for h = 1 , GRM.GetNumGuildies() do
                    local name ,_,_,_,_,_, note , oNote = GetGuildRosterInfo( h );
                    if name == memberInfo[1] then
                        local t;
                        if tempStringInv == nil or tempStringInv == "" then
                            t = GRM.GetTimestamp();
                            t = string.sub ( t , 1 , string.find ( t , "'" ) + 2 );
                        else
                            t = string.sub ( timeStamp , 1 , string.find ( timeStamp , "'" ) + 2 );
                        end
                        t = GRM.FormatTimeStamp ( t , false );
                        local noteToSet = ( GRM.L ( "Rejoined:" ) .. " " .. t );
                        if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][20] and CanEditOfficerNote() and ( oNote == "" or oNote == nil ) then
                            GuildRosterSetOfficerNote( h , noteToSet );
                        elseif not GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][20] and CanEditPublicNote() and ( note == "" or note == nil ) then
                            GuildRosterSetPublicNote ( h , noteToSet );
                        end
                        break;
                    end
                end
            end
            -- Make sure to include the officer and public notes if necessary as well for new players
            -- Public note
            if memberInfo[5] ~= "" and memberInfo[5] ~= nil and string.find ( memberInfo[5] , GRM.OrigL ( "Joined:" ) ) == nil then
                -- Add the public note!
                table.insert ( GRM_G.TempLogNote , { 4 , ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name}'s PUBLIC Note: \"{custom1}\" was Added" , GRM.GetStringClassColorByName ( memberInfo[1] , true ) .. GRM.SlimName ( memberInfo[1] ) .. "|r" , nil , nil , memberInfo[5] ) ) , false } )
                GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][GRM_G.saveGID][j][7] = memberInfo[5];
            end

            -- Officer Note
            if memberInfo[6] ~= "" and memberInfo[6] ~= nil and string.find ( memberInfo[6] , GRM.OrigL ( "Joined:" ) ) == nil then
                -- Add the Officer note!
                table.insert ( GRM_G.TempLogONote , { 5 , ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name}'s OFFICER Note: \"{custom1}\" was Added" , GRM.GetStringClassColorByName ( memberInfo[1] , true ) .. GRM.SlimName ( memberInfo[1] ) .. "|r" , nil , nil , memberInfo[6] ) ) , false } )
                GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][GRM_G.saveGID][j][8] = memberInfo[6];
            end

            -- Make sure the namechange is adjusted in the database or you will get a double report

            GRM.AddMemberRecord( memberInfo , true , GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][GRM_G.saveGID][j] );
            
            -- Removing Player from LeftGuild History (Yes, they will be re-added upon leaving the guild.)
            table.remove ( GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][GRM_G.saveGID] , j );

            -- It must be done AFTER the record has been added
            -- Promotion Info
            if memberInfo[3] < ( GuildControlGetNumRanks() - 1 ) then
                -- Promotion Obtained since joining!
                local tempString = "";
                local timestamp2 = GRM.GetTimestamp();
                local epochTime = time();
                local isFoundInLog = false;
                local nameOfBaseRank = GuildControlGetRankName( GuildControlGetNumRanks() );
                local logReport = "";
                
                -- I don't want to have an instance where I have the promotion date in the log but the join date is too old os it has fallen off,
                -- Thus, if the exact join date cannot be determined, it will set the promotion date to be no different.
                if tempTimeStamp ~= "1 Jan '01 12:01am" then
                    tempString = GRM.GetGuildEventString ( 2 , memberInfo[1] , nameOfBaseRank , memberInfo[2] );
                    if tempString ~= nil and tempString ~= "" then
                        local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_G.GuildLogDate );
                        timestamp2 = tempData[1];
                        epochTime = tempData[2];
                        isFoundInLog = true;
                        logReport = ( GRM.FormatTimeStamp ( timestamp2 , true ) .. " : " .. tempString );
                    else
                        logReport = ( GRM.FormatTimeStamp ( timestamp2 , true ) .. " : " .. GRM.L ( "{name} has been PROMOTED from {custom1} to {custom2}" , simpleName , nil , nil , nameOfBaseRank , memberInfo[2] ) );
                    end

                    tempGuildData[j][12] = string.sub ( timestamp2 , 1 , string.find ( timestamp2 , "'" ) + 2 ); -- Time stamping rank change
                    tempGuildData[j][13] = epochTime;

                    -- For SYNC
                    if not isFoundInLog then
                        -- Use old stamps so as not to override other player data...
                        timestamp2 = "1 Jan '01 12:01am";
                        epochTime = 978375660;
                    end

                    tempGuildData[j][36][1] = timestamp2;
                    tempGuildData[j][36][2] = epochTime;
                end

                tempGuildData[j][4] = memberInfo[2]; -- Saving new rank Info
                tempGuildData[j][5] = memberInfo[3]; -- Saving new rank Index Info

                table.insert ( tempGuildData[j][25] , { tempGuildData[j][4] , tempGuildData[j][12] , tempGuildData[j][13] } ); -- New rank, date, metatimestamp

                -- Ok data is saved! Now let's report it to the log...
                local tempString = GRM.GetGuildEventString ( 2 , memberInfo[1] , nameOfBaseRank , memberInfo[2] );
                if tempString ~= nil and tempString ~= "" then
                    local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_G.GuildLogDate );
                    logReport = ( GRM.FormatTimeStamp ( tempData[1] , true ) .. " : " .. tempString );
                else
                    logReport = GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} has been PROMOTED from {custom1} to {custom2}" , memberInfo[1] , nil , nil , nameOfBaseRank , memberInfo[2] );
                end
                table.insert ( GRM_G.TempLogPromotion , { 1 , logReport , false } );
            end            
            break;
        end
    end
            
    if rejoin ~= true then
        -- New Guildie. NOT a rejoin!
        local t;
        local timeStamp;
        if tempTimeStamp ~= "1 Jan '01 12:01am" then
            timeStamp = tempTimeStamp;
        else
            timeStamp = GRM.GetTimestamp();
        end
        logReport = ( GRM.FormatTimeStamp ( timeStamp , true ) .. " : " .. GRM.L ( "{name} has JOINED the guild!" , simpleName ) .. " " .. GRM.L ( "(LVL: {num})" , nil , nil , memberInfo[4] ) );
        if tempStringInv == nil or tempStringInv == "" then
            t = GRM.GetTimestamp();
            t = string.sub ( t , 1 , string.find ( t , "'" ) + 2 );
        else
            logReport = logReport .. " - " .. GRM.L ( "Invited By: {name}" , GRM_G.PlayerFromGuildLog );
            t = string.sub ( timeStamp , 1 , string.find ( timeStamp , "'" ) + 2 );
        end
        t = GRM.FormatTimeStamp ( t , false );
        local finalTStamp = ( GRM.L ( "Joined:" ) .. " " .. t );
        
        -- Adding timestamp to new Player.
        local currentOfficerNote = memberInfo[6];
        local currentPublicNote = memberInfo[5];
        if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][7] and ( CanEditOfficerNote() or CanEditPublicNote() ) then
            for s = 1 , GRM.GetNumGuildies() do
                local name ,_,_,_,_,_, note , oNote = GetGuildRosterInfo ( s );
                if name == memberInfo[1] then
                    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][20] and CanEditOfficerNote() and ( oNote == "" or oNote == nil ) then
                        GuildRosterSetOfficerNote( s , finalTStamp );
                    elseif not GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][20] and CanEditPublicNote() and ( note == "" or note == nil ) then
                        GuildRosterSetPublicNote ( s , finalTStamp );
                    end
                    break;
                end
            end
        end

        -- Adding to global saved array, adding to report 
        GRM.AddMemberRecord ( memberInfo , false , nil );
        table.insert ( GRM_G.TempNewMember , { 8 , logReport , false } );

        local tempGuildData = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
        -- adding join date to history and rank date.
        for j = 2 , #tempGuildData do                     -- Number of players that have left the guild.
            if memberInfo[1] == tempGuildData[j][1] then
                -- Add the tempTimeStamp to officer note... this avoids report spam
                -- Promo Date stamp
                if tempTimeStamp ~= "1 Jan '01 12:01am" then

                    tempGuildData[j][12] = string.sub ( timeStamp , 1 , string.find ( timeStamp , "'" ) + 2 );  -- Date of Last Promotion - cuts of the date...
                    tempGuildData[j][13] = timeEpoch;                                                                   -- Date of Last Promotion Epoch time.
                    -- Join Date stamp
                    -- No need to check size of table, it will be the first index as the player data was just added.
                    table.insert ( tempGuildData[j][20] , timeStamp );
                    table.insert ( tempGuildData[j][21] , timeEpoch );
                    -- For Event tracking!
                    tempGuildData[j][22][1][1] = string.sub ( timeStamp , 1 , string.find ( timeStamp , "'" ) + 2 );
                end
                -- For SYNC
                -- Join Date
                tempGuildData[j][35][1] = tempTimeStamp;
                tempGuildData[j][35][2] = timeEpoch;
                -- Promo Date
                tempGuildData[j][36][1] = tempTimeStamp;
                tempGuildData[j][36][2] = timeEpoch;


                if currentOfficerNote == nil or currentOfficerNote == "" then
                    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][7] and ( CanEditOfficerNote() or CanEditPublicNote() ) then
                        if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][20] and CanEditOfficerNote() and ( tempGuildData[j][8] == "" or tempGuildData[j][8] == nil ) then
                            tempGuildData[j][8] = finalTStamp;
                        elseif not GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][20] and CanEditPublicNote() and ( tempGuildData[j][7] == "" or tempGuildData[j][7] == nil ) then
                            tempGuildData[j][7] = finalTStamp;
                        end
                    end

                elseif currentOfficerNote ~= nil and currentOfficerNote ~= "" then
                    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][7] and ( CanEditOfficerNote() or CanEditPublicNote() ) then
                        if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][20] and CanEditOfficerNote() and ( tempGuildData[j][8] == "" or tempGuildData[j][8] == nil ) then
                            tempGuildData[j][8] = currentOfficerNote;
                        elseif not GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][20] and CanEditPublicNote() and ( tempGuildData[j][7] == "" or tempGuildData[j][7] == nil ) then
                            tempGuildData[j][7] = currentPublicNote;
                        end
                    end
                end

                -- Let's check the public notes
                if memberInfo[5] ~= "" and memberInfo[5] ~= nil and string.find ( memberInfo[5] , GRM.OrigL ( "Joined:" ) ) == nil then
                    -- Add the public note!
                    table.insert ( GRM_G.TempLogNote , { 4 , ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name}'s PUBLIC Note: \"{custom1}\" was Added" , GRM.GetClassifiedName ( memberInfo[1] , false ) , nil , nil , memberInfo[5] ) ) , false } )
                end

                -- Officer Note
                if memberInfo[6] ~= "" and memberInfo[6] ~= nil and string.find ( memberInfo[6] , GRM.OrigL ( "Joined:" ) ) == nil then
                    -- Add the Officer note!
                    table.insert ( GRM_G.TempLogONote , { 5 , ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name}'s OFFICER Note: \"{custom1}\" was Added" , GRM.GetClassifiedName ( memberInfo[1] , false ) , nil , nil , memberInfo[6] ) ) , false } )
                end

                -- Promotion Info
                if memberInfo[3] < ( GuildControlGetNumRanks() - 1 ) then
                    -- Promotion Obtained since joining!
                    local tempString = "";
                    local timestamp2 = GRM.GetTimestamp();
                    local epochTime = time();
                    local isFoundInLog = false;
                    local nameOfBaseRank = GuildControlGetRankName( GuildControlGetNumRanks() );
                    local logReport = "";
                    
                    -- I don't want to have an instance where I have the promotion date in the log but the join date is too old os it has fallen off,
                    -- Thus, if the exact join date cannot be determined, it will set the promotion date to be no different.
                    if tempTimeStamp ~= "1 Jan '01 12:01am" then
                        tempString = GRM.GetGuildEventString ( 2 , memberInfo[1] , nameOfBaseRank , memberInfo[2] );
                        if tempString ~= nil and tempString ~= "" then
                            local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_G.GuildLogDate );
                            timestamp2 = tempData[1];
                            epochTime = tempData[2];
                            isFoundInLog = true;
                            logReport = ( GRM.FormatTimeStamp ( timestamp2 , true ) .. " : " .. tempString );
                        else
                            logReport = ( GRM.FormatTimeStamp ( timestamp2 , true ) .. " : " .. GRM.L ( "{name} has been PROMOTED from {custom1} to {custom2}" , simpleName , nil , nil , nameOfBaseRank , memberInfo[2] ) );
                        end

                        tempGuildData[j][12] = string.sub ( timestamp2 , 1 , string.find ( timestamp2 , "'" ) + 2 ); -- Time stamping rank change
                        tempGuildData[j][13] = epochTime;

                        -- For SYNC
                        if not isFoundInLog then
                            -- Use old stamps so as not to override other player data...
                            timestamp2 = "1 Jan '01 12:01am";
                            epochTime = 978375660;
                        end

                        tempGuildData[j][36][1] = timestamp2;
                        tempGuildData[j][36][2] = epochTime;
                    end

                    tempGuildData[j][4] = memberInfo[2]; -- Saving new rank Info
                    tempGuildData[j][5] = memberInfo[3]; -- Saving new rank Index Info

                    table.insert ( tempGuildData[j][25] , { tempGuildData[j][4] , tempGuildData[j][12] , tempGuildData[j][13] } ); -- New rank, date, metatimestamp

                    -- Ok data is saved! Now let's report it to the log...
                    local tempString = GRM.GetGuildEventString ( 2 , memberInfo[1] , nameOfBaseRank , memberInfo[2] );
                    if tempString ~= nil and tempString ~= "" then
                        local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_G.GuildLogDate );
                        logReport = ( GRM.FormatTimeStamp ( tempData[1] , true ) .. " : " .. tempString );
                    else
                        logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} has been PROMOTED from {custom1} to {custom2}" , memberInfo[1] , nil , nil , nameOfBaseRank , memberInfo[2] ) );
                    end
                    table.insert ( GRM_G.TempLogPromotion , { 1 , logReport , false } );
                end
                break;
            end
        end
        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] = tempGuildData;
    end
end

-- Method:          GRM.RecordCustomNoteChanges ( string , string , string , boolean )
-- What it Does:    Reports the Custom note changes to the Guild Log
-- Purpose:         For ease of reporting to the log, as a UI feature.
GRM.RecordCustomNoteChanges = function( newNote , oldNote , editorName , editedName , rebuildLog )
    -- Remove the linebreaks in the log reporting or it will be spammy. Replace with a dash
    newNote = string.gsub ( newNote , "\n" , "-" );
    oldNote = string.gsub ( oldNote , "\n" , "-" );
    local logReport = "";
    if oldNote == "" then
        logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} modified {name2}'s CUSTOM Note: \"{custom1}\" was Added" , GRM.GetClassifiedName ( editorName , true ) , GRM.GetClassifiedName ( editedName , true ) , nil , newNote ) );
    elseif newNote == "" then
        logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} modified {name2}'s CUSTOM Note: \"{custom1}\" was Removed" , GRM.GetClassifiedName ( editorName , true ) , GRM.GetClassifiedName ( editedName , true ) , nil , oldNote ) );
    else
        logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} modified {name2}'s CUSTOM Note: \"{custom1}\" to \"{custom2}\"" , GRM.GetClassifiedName ( editorName , true ) , GRM.GetClassifiedName ( editedName , true ) , nil , oldNote , newNote ) );
    end

    -- Ok that to the log...
    if rebuildLog and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][14] then
        GRM.PrintLog ( 19 , logReport , false );
    end

    GRM.AddLog ( 19 , logReport );
    if rebuildLog and GRM_UI.GRM_RosterChangeLogFrame:IsVisible() and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterCustomNoteChangeCheckButton:GetChecked() then
        GRM_G.LogNumbersColorUpdate = true;
        GRM.BuildLogComplete();
    end
end

-- Method:          GRM.SetCustomNote();
-- What it Does:    Modifies the custom note to new one, if necessary and sends proper updates and comms
-- Purpose:         Reduce a bit of code bloat. Make the UI functions of the editbox more readable.
GRM.SetCustomNote = function()
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == GRM_G.currentName then
            -- The trim is so that just a white space doesn't somehow count as a new note.
            if GRM.Trim ( GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteEditBox:GetText() ) ~= GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][6] then
                local oldNote = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][6];
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][2] = time();
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][3] = GRM_G.addonPlayerName;
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][6] = GRM.Trim ( GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteEditBox:GetText() );
                GRM_G.OriginalEditBoxValue = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][6];  -- This needs to be set to handle the OnEditFocusLost logic..
                
                -- Handle Log reporting logic here... 
                GRM.RecordCustomNoteChanges ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][6] , oldNote , GRM_G.addonPlayerName , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] , true )

                -- Handle live sync SendMessage here...
                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][38] and GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][1] then

                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_G.PatchDayString .. "?GRM_CNOTE?" .. GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][4] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] .. "?" .. tostring ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][2] ) .. "?" .. GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][6] , "SLASH_CMD_GUILD" );
                end
            end

            if GRM.Trim ( GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteEditBox:GetText() ) == "" then
                GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteEditBox:SetText ( GRM.L ( "Click here to set Custom Notes" ) );
                GRM_G.OriginalEditBoxValue = GRM.L ( "Click here to set Custom Notes" );
            else
                GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteEditBox:SetText ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][6] );
            end
            break;
        end
    end
    GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteEditBox:ClearFocus();
end

-- Method           GRM.RecordChanges( int , table , table )
-- What it does:    Builds all the changes, sorts them, then adds them to change report
-- Purpose:         Consolidation of data for final output report.
GRM.RecordChanges = function ( indexOfInfo , memberInfo , memberOldInfo )
    if GRM_G.changeHappenedExitScan then
        GRM.ResetTempLogs();
        GRM_G.changeHappenedExitScan = false;
        GRM_G.CurrentlyScanning = false;
        return;
    end
    local logReport = "";
    local simpleName = "";
    if memberInfo[1] == nil then
        simpleName = GRM.GetStringClassColorByName ( memberInfo ) .. GRM.SlimName ( memberInfo ) .. "|r";
    elseif indexOfInfo ~= 10 then
        simpleName = GRM.GetStringClassColorByName ( memberInfo[1] ) .. GRM.SlimName ( memberInfo[1] ) .. "|r";
    else
        simpleName = GRM.GetClassColorRGB ( memberInfo[7] , true ) .. GRM.SlimName ( memberInfo[1] ) .. "|r";
    end

    -- 2 = Guild Rank Promotion
    if indexOfInfo == 2 then
        local tempString = GRM.GetGuildEventString ( 2 , memberInfo[1] , memberOldInfo[4] , memberInfo[2] );
        if tempString ~= nil and tempString ~= "" then
            local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_G.GuildLogDate );
            logReport = ( tempData[1] .. " : " .. tempString );
        else
            logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} has been PROMOTED from {custom1} to {custom2}" , simpleName , nil , nil , memberOldInfo[4] , memberInfo[2] ) );
        end
        table.insert ( GRM_G.TempLogPromotion , { 1 , logReport , false } );
    -- 9 = Guild Rank Demotion
    elseif indexOfInfo == 9 then
        local tempString = GRM.GetGuildEventString ( 1 , memberInfo[1] , memberOldInfo[4] , memberInfo[2] );
        if tempString ~= nil and tempString ~= "" then
            local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_G.GuildLogDate );
            logReport = ( tempData[1] .. " : " .. tempString );
        else
            logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} has been DEMOTED from {custom1} to {custom2}" , simpleName , nil , nil , memberOldInfo[4] , memberInfo[2] ) );
        end
        table.insert ( GRM_G.TempLogDemotion , { 2 , logReport , false } );
    -- 4 = level
    elseif indexOfInfo == 4 then
        local numGained = memberInfo[4] - memberOldInfo[6];
        logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} has Leveled to {num}" , simpleName , nil , memberInfo[4] ) .. " " );
        if numGained > 1 then
            logReport = logReport .. GRM.L ( "(+{num} levels)" , nil , nil , numGained );
        else
            logReport = logReport .. GRM.L ( "(+{num} level)" , nil , nil , numGained );
        end
        table.insert ( GRM_G.TempLogLeveled , { 3 , logReport , false } );
    -- 5 = note
    elseif indexOfInfo == 5 then
        if memberOldInfo[7] == "" then
            logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name}'s PUBLIC Note: \"{custom1}\" was Added" , simpleName , nil , nil , memberInfo[5] ) );
        elseif memberInfo[5] == "" then
            logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name}'s PUBLIC Note: \"{custom1}\" was Removed" , simpleName , nil , nil , memberOldInfo[7] ) );
        else
            logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name}'s PUBLIC Note: \"{custom1}\" to \"{custom2}\"" , simpleName , nil , nil , memberOldInfo[7] , memberInfo[5] ) );
        end
        table.insert ( GRM_G.TempLogNote , { 4 , logReport , false } );
    -- 6 = officerNote
    elseif indexOfInfo == 6 then
        if memberOldInfo[8] == "" then
            logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name}'s OFFICER Note: \"{custom1}\" was Added" , simpleName , nil , nil , memberInfo[6] ) );
        elseif memberInfo[6] == "" or memberInfo[6] == nil then
            logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name}'s OFFICER Note: \"{custom1}\" was Removed" , simpleName , nil , nil , memberOldInfo[8] ) );
        else
            logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name}'s OFFICER Note: \"{custom1}\" to \"{custom2}\"" , simpleName , nil , nil , memberOldInfo[8] , memberInfo[6] ) );
        end
        table.insert ( GRM_G.TempLogONote , { 5 , logReport , false } );
    -- 8 = Guild Rank Name Changed to something else
    elseif indexOfInfo == 8 then
        logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "Guild Rank Renamed from {custom1} to {custom2}" , nil , nil , nil , memberOldInfo[4] , memberInfo[2] ) );
        table.insert ( GRM_G.TempRankRename , { 6 , logReport , false } );
    -- 10 = New Player
    elseif indexOfInfo == 10 then
        -- Check against old member list first to see if returning player!
        GRM.RecordJoinChanges ( memberInfo , simpleName );
    -- 11 = Player Left  
    elseif indexOfInfo == 11 then
        table.insert ( GRM_G.TempLeftGuildPlaceholder , { memberInfo[1] , simpleName , false } );
    -- 12 = NameChanged
    elseif indexOfInfo == 12 then
        local classColorString = GRM.GetStringClassColorByName ( memberOldInfo[1] );
        logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} has Name-Changed to {name2}" , classColorString .. GRM.SlimName ( memberOldInfo[1] ) .. "|r" , classColorString .. simpleName .. "|r" ) );
        table.insert ( GRM_G.TempNameChanged , { 11 , logReport , false } );
    -- 13 = Inactive Members Return!
    elseif indexOfInfo == 13 then
        logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} has Come ONLINE after being INACTIVE for {num}" , simpleName , nil , GRM.HoursReport ( memberOldInfo ) ) );
        table.insert( GRM_G.TempInactiveReturnedLog , { 14 , logReport , false } );
    end
end

-- Method:          GRM.CheckPlayerChanges ( array , string , boolean )
-- What it Does:    Scans through guild roster and re-checks for any  (Will only fire if guild is found!)
-- Purpose:         Keep whoever uses the addon in the know instantly of what is going and changing in the guild.
GRM.CheckPlayerChanges = function ( metaData , guildName , guildNotFound )
    GRM_G.CurrentlyScanning = true;
    if GRM_G.changeHappenedExitScan or GRM_G.saveGID == 0 then    -- This provides an escape if the player quits the guild in the middle of the scan process, or on first joining, to avoid lua error then
        GRM.ResetTempLogs();
        GRM_G.changeHappenedExitScan = false;
        GRM_G.CurrentlyScanning = false;
        return;
    end
    local newPlayerFound;
    local guildRankIndexIfChanged = -1; -- Rank index must start below zero, as zero is Guild Leader.

    local tempRosterCopy = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];

    for j = GRM_G.ThrottleControlNum , #metaData do
        newPlayerFound = true;
        for r = 2 , #tempRosterCopy do -- Number of members in guild (Position 1 = guild name, so we skip)
            if metaData[j][1] == tempRosterCopy[r][1] then
                newPlayerFound = false;
                -- Only scan for changes here based on player scan timer settings.
                if ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][18] or GRM_G.ManualScanEnabled ) and ( time() - GRM_G.ScanRosterTimer > GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][6] ) then
                    for k = 2 , 8 do
                        
                        if k < 7 and metaData[j][k] ~= tempRosterCopy[r][k + 2] then -- CHANGE FOUND! New info and old info are not equal!
                            -- Ranks
                            if k == 3 and metaData[j][3] ~= tempRosterCopy[r][5] then -- This checks to see if guild just changed the name of a rank.
                                local tempString = "";
                                local timestamp = GRM.GetTimestamp();
                                local epochTime = time();
                                local isFoundInLog = false;
                                -- Promotion Obtained                                
                                if metaData[j][3] < tempRosterCopy[r][5] then
                                    tempString = GRM.GetGuildEventString ( 2 , metaData[j][1] , tempRosterCopy[r][4] , metaData[j][2] );
                                    if tempString ~= nil and tempString ~= "" then
                                        local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_G.GuildLogDate );
                                        timestamp = tempData[1];
                                        epochTime = tempData[2];
                                        isFoundInLog = true;
                                    end
                                    GRM.RecordChanges ( 2 , metaData[j] , tempRosterCopy[r] );
                                -- Demotion Obtained
                                elseif metaData[j][3] > tempRosterCopy[r][5] then
                                    tempString = GRM.GetGuildEventString ( 1 ,  metaData[j][1] , tempRosterCopy[r][4] , metaData[j][2] );
                                    if tempString ~= nil and tempString ~= "" then
                                        local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_G.GuildLogDate );
                                        timestamp = tempData[1];
                                        epochTime = tempData[2];
                                        isFoundInLog = true;
                                    end
                                    GRM.RecordChanges ( 9 , metaData[j] , tempRosterCopy[r] );
                                end
                                
                                tempRosterCopy[r][4] = metaData[j][2]; -- Saving new rank Info
                                tempRosterCopy[r][5] = metaData[j][3]; -- Saving new rank Index Info
                                tempRosterCopy[r][12] = string.sub ( timestamp , 1 , string.find ( timestamp , "'" ) + 2 ); -- Time stamping rank change
                                tempRosterCopy[r][13] = epochTime;

                                -- For SYNC
                                if not isFoundInLog then
                                    -- Use old stamps so as not to override other player data...
                                    timestamp = "1 Jan '01 12:01am";
                                    epochTime = 978375660;
                                end
                                tempRosterCopy[r][36][1] = timestamp;
                                tempRosterCopy[r][36][2] = epochTime;

                                table.insert ( tempRosterCopy[r][25] , { tempRosterCopy[r][4] , tempRosterCopy[r][12] , tempRosterCopy[r][13] } ); -- New rank, date, metatimestamp
                                
                                -- Update the player index if it is the player themselves that received the change in rank.
                                if metaData[j][1] == GRM_G.addonPlayerName then
                                    GRM_G.playerIndex = metaData[j][3];
                                    GRM_G.playerRankID = GRM.GetGuildMemberRankID ( GRM_G.addonPlayerName );

                                    -- Let's do a resync check as well... If permissions have changed, we should resync check em.
                                    -- First, RESET all..
                                    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] and not GRMsyncGlobals.currentlySyncing and GRM_G.HasAccessToGuildChat and not GRM_G.OnFirstLoad then
                                        GRMsync.TriggerFullReset();
                                        -- Now, let's add a brief delay, 3 seconds, to trigger sync again
                                        C_Timer.After ( 3 , GRMsync.Initialize );
                                    end

                                    GRM_UI.BuildLogFrames();
                                    
                                    -- Determine if player has access to guild chat or is in restricted chat rank - need to recheck with rank change.
                                    GRM_G.HasAccessToGuildChat = false;
                                    GRM_G.HasAccessToOfficerChat = false;
                                    GRM.RegisterGuildChatPermission();
                                end
                            elseif k == 2 and metaData[j][2] ~= tempRosterCopy[r][4] and metaData[j][3] == tempRosterCopy[r][5] then
                                -- RANK RENAMED!
                                if guildRankIndexIfChanged ~= metaData[j][3] then -- If alrady been reported, no need to report it again.
                                    GRM.RecordChanges ( 8 , metaData[j] , tempRosterCopy[r] );
                                    guildRankIndexIfChanged = metaData[j][3]; -- Avoid repeat reporting for each member of that rank upon a namechange.
                                end
                                tempRosterCopy[r][4] = metaData[j][2]; -- Saving new Info
                                tempRosterCopy[r][25][#tempRosterCopy[r][25]][1] = metaData[j][2];   -- Adjusting the historical name if guild rank changes.
                            -- Level
                            elseif k == 4 then
                                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][23] <= metaData[j][4] then
                                    GRM.RecordChanges ( k , metaData[j] , tempRosterCopy[r] );
                                end
                                tempRosterCopy[r][6] = metaData[j][4]; -- Saving new Info
                            -- Note
                            elseif k == 5 then
                                GRM.RecordChanges ( k , metaData[j] , tempRosterCopy[r] );
                                tempRosterCopy[r][7] = metaData[j][5];
                                -- Update metaframe
                                if GRM_UI.GRM_MemberDetailMetaData ~= nil and GRM_UI.GRM_MemberDetailMetaData:IsVisible() and GRM_G.currentName == metaData[j][1] then
                                    if metaData[j][5] == "" then
                                        if CanEditPublicNote() then
                                            GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:SetText ( GRM.L ( "Click here to set a Public Note" ) );
                                        else
                                            GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:SetText ( GRM.L ( "Unable to Edit Public Note at Rank" ) );
                                        end
                                    else
                                        GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:SetText ( metaData[j][5] );
                                    end
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetText ( metaData[j][5] );
                                end
                            -- Officer Note
                            elseif k == 6 and CanViewOfficerNote() then
                                if metaData[j][k] == nil or tempRosterCopy[r][8] == nil then
                                    tempRosterCopy[r][8] = metaData[j][6];
                                else
                                    GRM.RecordChanges ( k , metaData[j] , tempRosterCopy[r] );
                                    tempRosterCopy[r][8] = metaData[j][6];
                                end
                                if GRM_UI.GRM_MemberDetailMetaData ~= nil and GRM_UI.GRM_MemberDetailMetaData:IsVisible() and GRM_G.currentName == metaData[j][1] then
                                    if metaData[j][6] == "" then
                                        if CanEditOfficerNote() then
                                            GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:SetText ( GRM.L ( "Click here to set an Officer's Note" ) );
                                        else
                                            GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:SetText ( GRM.L ( "Unable to Edit Officer Note at Rank" ) );
                                        end
                                    else
                                        GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:SetText ( metaData[j][6] );
                                    end
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetText (  metaData[j][6] );
                                end
                            end
                        elseif k == 8 and not guildNotFound then
                            if metaData[j][8] ~= -1 then
                                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][11] and tempRosterCopy[r][24] > GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][4] and metaData[j][8] < GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][4] and tempRosterCopy[r][24] > metaData[j][8] then  -- Player has logged in after having been inactive for greater than given time
                                    GRM.RecordChanges ( 13 , metaData[j][1] , ( tempRosterCopy[r][24] - metaData[j][8] ) );   -- Recording the change in hours to log
                                end
                
                                -- Recommend to kick offline if player has the power to!
                                if CanGuildRemove() then
                                    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][10] and not tempRosterCopy[r][27] and GRM.GetNumHoursTilRecommend ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][9] ) <= metaData[j][8] then
                                        -- Player has been offline for longer than the given time... REPORT RECOMMENDATION TO KICK!!!
                                        table.insert ( GRM_G.TempEventRecommendKickReport , { 16 , ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} has been OFFLINE for {num}. Kick Recommended!" , GRM.GetStringClassColorByName ( metaData[j][1] ) .. GRM.SlimName ( metaData[j][1] ) .. "|r" , nil , GRM.HoursReport ( metaData[j][8] ) ) ) , false } );
                                        tempRosterCopy[r][27] = true;    -- No need to report more than once.
                                    elseif tempRosterCopy[r][27] and ( 30 * 24 * GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][9] ) > metaData[j][8]  then
                                        tempRosterCopy[r][27] = false;
                                    end
                                end
                                tempRosterCopy[r][24] = metaData[j][8];                   -- Set new hours since last login.
                            end
                        end
                    end
                end

                -- Just straight update these everytime... No need for change check
                if ( metaData[j][13] and tempRosterCopy[r][28] ~= metaData[j][9] ) or GRM_G.OnFirstLoad then     
                    tempRosterCopy[r][32] = time();   -- Resetting the time on hitting this zone.
                end
                tempRosterCopy[r][28] = metaData[j][9];    -- zone
                tempRosterCopy[r][29] = metaData[j][10];   -- Achievement pts
                tempRosterCopy[r][30] = metaData[j][11];   -- isMobile
                tempRosterCopy[r][31] = metaData[j][12];   -- Guild Reputation
                tempRosterCopy[r][33] = metaData[j][13];   -- online Status
                tempRosterCopy[r][34] = metaData[j][14];   -- Active Status
                tempRosterCopy[r][42] = metaData[j][15];   -- GUID
                break;
            end
        end
        -- NEW PLAYER FOUND! (Maybe)
        if newPlayerFound then
            table.insert ( GRM_G.newPlayers , metaData[j] );
        end

        -- Throttle Controls on the scan!!!
        if not GRM_G.OnFirstLoad then
            if j % 250 == 0 then
                GRM_G.ThrottleControlNum = j + 1;
                C_Timer.After ( 1 , function() 
                    GRM.CheckPlayerChanges ( metaData , guildName , guildNotFound );
                end);
                return
            end
        end
    end
    -- Checking if any players left the guild
    C_Timer.After ( 1 , function()
        if GRM_G.changeHappenedExitScan then
            GRM.ResetTempLogs();
            GRM_G.changeHappenedExitScan = false;
            GRM_G.CurrentlyScanning = false;
            return;
        end
        local playerLeftGuild;
        for j = 2 , #tempRosterCopy do
            playerLeftGuild = true;
            for k = 1 , #metaData do
                if tempRosterCopy[j][1] == metaData[k][1] then
                    playerLeftGuild = false;
                    break;
                end
            end
            -- PLAYER LEFT! (maybe)
            if playerLeftGuild then
                table.insert ( GRM_G.leavingPlayers , tempRosterCopy[j] );
            end
        end
        -- Spread out the scans to avoid stutter...
        C_Timer.After ( 2 , function()
            if GRM_G.changeHappenedExitScan then
                GRM.ResetTempLogs();
                GRM_G.changeHappenedExitScan = false;
                GRM_G.CurrentlyScanning = false;
                return;
            end
            -- Final check on players that left the guild to see if they are namechanges.CanViewOfficerNote
            local playerNotMatched = true;
            local hasBeenReportedToLog = false;
            if #GRM_G.leavingPlayers > 0 and #GRM_G.newPlayers > 0 then
                for k = 1 , #GRM_G.leavingPlayers do
                    playerNotMatched = true;
                    for j = 1 , #GRM_G.newPlayers do
                        if ( GRM_G.leavingPlayers[k] ~= nil and GRM_G.newPlayers[j] ~= nil ) and GRM_G.leavingPlayers[k][42] == GRM_G.newPlayers[j][15] then   -- COMPARING GUID
                            playerNotMatched = false;   -- In other words, player was found, but it's a namechange!!!!!
                            -- Match Found!!!
                            GRM.RecordChanges ( 12 , GRM_G.newPlayers[j] , GRM_G.leavingPlayers[k] );
                            local tempGuild = tempRosterCopy;
                            for r = 2 , #tempGuild do
                                if GRM_G.leavingPlayers[k][42] == tempGuild[r][42] then -- Mathching the Leaving player to historical index so it can be identified and new name stored.
                                    -- Need to remove him from list of alts IF he has a lot of alts...
                                    if #tempGuild[r][11] > 0 then
                                        local listOfAlts = tempGuild[r][11];
                                        for m = 1 , #listOfAlts do
                                            for r = 2 , #tempGuild do
                                                if tempGuild[r][1] == listOfAlts[m][1] then
                                                    for t = 1 , #tempGuild[r][11] do
                                                        if tempGuild[r][11][t][1] == GRM_G.leavingPlayers[k][1] then
                                                            tempGuild[r][11][t][1] = GRM_G.newPlayers[j][1];
                                                            break;
                                                        end
                                                    end
                                                    break;
                                                end
                                            end
                                        end
                                    end
                                    tempGuild[r][1] = GRM_G.newPlayers[j][1]; -- Changing the name!
                                    break
                                end
                            end
                            -- since namechange identified, also need to remove name from GRM_G.newPlayers array now.
                            if #GRM_G.newPlayers == 1 then
                                GRM_G.newPlayers = {}; -- Clears the array of the one name.
                            else
                                local tempArray = {};
                                local count = 1;
                                for r = 1 , #GRM_G.newPlayers do -- removing the namechange from GRM_G.newPlayers list.
                                    if r ~= k then  -- j = the position of the nameChanged player, so I am SKIPPING the nameChange player when adding to new array.
                                        tempArray[count] = {};
                                        tempArray[count] = GRM_G.newPlayers[r];
                                        count = count + 1;
                                    end
                                end
                                GRM_G.newPlayers = {};
                                GRM_G.newPlayers = tempArray;
                            end
                            break;
                        end
                    end
                    
                    -- Player not matched! For sure this player has left the guild!
                    if playerNotMatched then
                        GRM.RecordChanges ( 11 , GRM_G.leavingPlayers[k] , GRM_G.leavingPlayers[k] );
                    end
                end
            elseif #GRM_G.leavingPlayers > 0 then
                for k = 1 , #GRM_G.leavingPlayers do
                    GRM.RecordChanges ( 11 , GRM_G.leavingPlayers[k] , GRM_G.leavingPlayers[k] );
                end
            end
            if #GRM_G.newPlayers > 0 then
                for k = 1 , #GRM_G.newPlayers do
                    GRM.RecordChanges ( 10 , GRM_G.newPlayers[k] , GRM_G.newPlayers[k] );
                end
            end

            -- Now that we have collected all the players to be kicked... Let's not spam the log with alt info by parsing it properly.
            if #GRM_G.TempLeftGuildPlaceholder > 0 then
                for k = 1 , #GRM_G.TempLeftGuildPlaceholder do
                    table.insert ( GRM_G.TempLeftGuild , { 10 , GRM.RecordKickChanges ( GRM_G.TempLeftGuildPlaceholder[k][1] , GRM_G.TempLeftGuildPlaceholder[k][3] ) , false } );
                end
            end

            -- OK, let's close this out!!!!!
            C_Timer.After ( 1 , function()
                if not guildNotFound then
                    if ( time() - GRM_G.ScanRosterTimer - 4 > GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][6] ) then
                        -- Seeing if any upcoming notable events, like anniversaries/birthdays
                        GRM.CheckPlayerEvents( GRM_G.guildName );
                        -- Do a quick check on if players requesting to join the guild as well!
                        if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][27] then
                            GRM.ReportGuildJoinApplicants();
                        end

                        GRM_G.ScanRosterTimer = time();          -- Setting the time since the last scan finished.
                    end
                    -- Printing Report, and sending report to log.
                    GRM.FinalReport();
                    
                    -- Disable manual scan if activated.
                    if GRM_G.ManualScanEnabled then
                        GRM_G.ManualScanEnabled = false;
                        chat:AddMessage ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "Manual Scan Complete" ) , 1.0 , 0.84 , 0 );
                    end
                end
            end);
        end);
    end);
end

-- Method:          GRM.GuildNameChanged()
-- What it Does:    Returns true if the player's guild is the same, it just changed its name
-- Purpose:         Good to know... what a pain it would be if you had to reset all of your settings
GRM.GuildNameChanged = function ( currentGuildName )
    local result = false;
    -- For each guild
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][i][1][1] ~= currentGuildName then
            local numEntries = #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ i ] - 1;     -- Total number of entries, minus 1 since first index is guild name.
            local count = 0;
            -- for each member in that guild
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ i ] do
                for r = 1 , GRM.GetNumGuildies() do
                    local name = GetGuildRosterInfo ( r );
                    if name == GRM_GuildMemberHistory_Save[ GRM_G.FID ][ i ][j][1] then
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
                local tempGuildName = GRM_GuildMemberHistory_Save[ GRM_G.FID ][i][1][1];

                -- Changing the name of the guild in the saved data to the new name.
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][i][1][1] = currentGuildName;

                -- Need to change index name of the left player history too.
                for s = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ] do
                    if GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][s][1][1] == tempGuildName then
                        GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][s][1][1] = currentGuildName;
                        GRM_CalendarAddQue_Save[ GRM_G.FID ][s][1][1] = currentGuildName;
                        GRM_GuildNotePad_Save[ GRM_G.FID ][s][1][1] = currentGuildName;
                        GRM_PlayerListOfAlts_Save[ GRM_G.FID ][s][1][1] = currentGuildName;
                         break;
                    end
                end

                -- Sometimes the log might be in a different situation...
                for s = 2 , #GRM_LogReport_Save[GRM_G.FID] do
                    if GRM_LogReport_Save[GRM_G.FID][s][1][1] == tempGuildName then
                        GRM_LogReport_Save[GRM_G.FID][s][1][1] = currentGuildName;
                        break;
                    end
                end

                -- Also need to change the guild's name in the saved database...
                for i = 2 , #GRM_GuildDataBackup_Save[GRM_G.FID] do
                    if GRM_GuildDataBackup_Save[GRM_G.FID][i][1][1] == tempGuildName then
                        GRM_GuildDataBackup_Save[GRM_G.FID][i][1][1] = currentGuildName;

                        for s = 2 , #GRM_GuildDataBackup_Save[GRM_G.FID][i] do
                            GRM_GuildDataBackup_Save[GRM_G.FID][i][s][3][1][1] = currentGuildName;
                            GRM_GuildDataBackup_Save[GRM_G.FID][i][s][4][1][1] = currentGuildName;
                            GRM_GuildDataBackup_Save[GRM_G.FID][i][s][5][1][1] = currentGuildName;
                            GRM_GuildDataBackup_Save[GRM_G.FID][i][s][6][1][1] = currentGuildName;
                            GRM_GuildDataBackup_Save[GRM_G.FID][i][s][7][1][1] = currentGuildName;
                        end
                        break;
                    end
                end

                break;
            end
        end
    end
    return result;
end

-- Method:          GRM.GetNumMembersInSavedRank ( int )
-- What it Does:    Returns the number of guildies in the saved database of a certain rank
-- Purpose:         For use in comparison of mass rank modifications, to carry them over, if rank changes occur live.
GRM.GetNumMembersInSavedRank = function( rankIndex )
    local result = 0;
    local tempGuild = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    for i = 2 , #tempGuild do
        if tempGuild[i][5] == rankIndex then
            result = result + 1;
        end
    end
    return result;
end

-- Method:          GRM.CheckGuildRanks()
-- What it Does:    Checks for any changes in the guild rank structure of the guild and reports on them
-- Purpose:         Just extra info, especially to help make it more clear to the player why they might get spammed in their log for mass demote/promotions
GRM.CheckGuildRanks = function()
    -- If the ranks are set, let's check if they do not match now.
    local numRanks = GuildControlGetNumRanks();
    if numRanks ~= GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][1][3] then
        -- Ok, we have a discrepancy, we need to check what happened now.
        -- If player added a rank it means some ranks have moved down. Need to determine where.
        
        local logReport = "";
        local rankNum = numRanks - GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][1][3];
        if rankNum > 0 then
            if rankNum == 1 then
                logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "A new rank has been added to the guild!" ) );
            else
                logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{num} new ranks have been added to the guild!" , nil , nil , rankNum ) );
            end
            table.insert ( GRM_G.TempRankRename , { 6 , logReport , false } );
        else
            if rankNum == -1 then
                logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "The guild has removed a rank!" ) );
            else
                logReport = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{num} guild ranks have been removed!" , nil , nil , ( rankNum * -1 ) ) );
            end
            table.insert ( GRM_G.TempRankRename , { 6 , logReport , false } );
        end
        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][1][3] = numRanks;
    end
end

-- Method:          GRM.BuildNewRoster()
-- What it does:    Rebuilds the roster to check against for any changes.
-- Purpose:         To track for guild changes of course!
GRM.BuildNewRoster = function()

    local roster = {};
    -- Checking if Guild Found or Not Found, to pre-check for Guild name tag.
    
    local guildNotFound = true;
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ] do
        if GRM_G.guildName == GRM_GuildMemberHistory_Save[GRM_G.FID][i][1][1] then
            guildNotFound = false;
            break;
        end
    end

    for i = 1 , GRM.GetNumGuildies() do
        -- For guild info
        local name , rank , rankInd , level , _ , zone , note , officerNote , online , status , class , achievementPoints , _ , isMobile , _ , rep , GUID = GetGuildRosterInfo ( i );

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
        roster[i][8] = GRM.GetHoursSinceLastOnline ( i , online ); -- Time since they last logged in in hours.
        roster[i][9] = zone;
        roster[i][10] = achievementPoints;
        roster[i][11] = isMobile;
        roster[i][12] = rep;
        roster[i][13] = online;
        roster[i][14] = status;
        roster[i][15] = GUID;
    end
        -- Build Roster for the first time if guild not found.
    if #roster > 0 and GRM_G.guildName ~= nil and GRM_G.guildName ~= "" then
        if guildNotFound then
            -- See if it is a Guild NameChange first!
            if GRM.GuildNameChanged ( GRM_G.guildName ) then
                local logEntry = GRM.L ( "{name}'s Guild has Name-Changed to \"{name2}\"" , GRM.GetStringClassColorByName( GRM_G.addonPlayerName ) .. GRM.SlimName( GRM_G.addonPlayerName ) .. "|r" , GRM.SlimName ( GRM_G.guildName ) );
                GRM.PrintLog ( 15 , logEntry , false );   
                GRM.AddLog ( 15 , logEntry ); 
            else
                GRM.Report ( "\n" .. GRM.L ( "Guild Roster Manager" ) .. "\n" .. GRM.L ( "Analyzing guild for the first time..." ) .. "\n" .. GRM.L ( "Building Profiles on ALL \"{name}\" members" , GRM.SlimName ( GRM_G.guildName ) ) .. "\n" );
                -- This reiterates over this, because sometimes it can have a delay. This ensures it is secure.
                if GRM_G.faction == "Horde" then
                    GRM_G.FID = 1;
                else
                    GRM_G.FID = 2;
                end
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ] , { { GRM_G.guildName , GRM_G.guildCreationDate } } );             -- Creating a position in table for Guild Member Data
                table.insert ( GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ] , { { GRM_G.guildName , GRM_G.guildCreationDate } } );         -- Creating a position in Left Player Table for Guild Member Data
                table.insert ( GRM_LogReport_Save[ GRM_G.FID ] , { { GRM_G.guildName , GRM_G.guildCreationDate } } );                      -- Logreport, let's create an index
                table.insert ( GRM_CalendarAddQue_Save[ GRM_G.FID ] , { { GRM_G.guildName , GRM_G.guildCreationDate } } );                 -- AddQue, let's create an index for the guild
                table.insert ( GRM_GuildNotePad_Save[ GRM_G.FID ] , { { GRM_G.guildName , GRM_G.guildCreationDate } } );                   -- Notepad, let's create an index as well!
                table.insert ( GRM_GuildDataBackup_Save[ GRM_G.FID ] , { { GRM_G.guildName , GRM_G.guildCreationDate } , {} , {} } );                -- Creates a backup index for this guild

                -- Make sure guild is not already added.
                local guildIsFound = false;
                for i = 2 , #GRM_PlayerListOfAlts_Save[ GRM_G.FID ] do
                    if GRM_PlayerListOfAlts_Save[GRM_G.FID][i][1][1] == GRM_G.guildName then
                        guildIsFound = true;
                        break;
                    end
                end
                if not guildIsFound then
                    table.insert ( GRM_PlayerListOfAlts_Save[ GRM_G.FID ] , { { GRM_G.guildName , GRM_G.guildCreationDate } } );           -- Adding index for the guild!
                end
                
                -- SET THE INDEXES PROPERLY
                GRM_G.logGID = #GRM_LogReport_Save[GRM_G.FID];        -- The last position, since it was just added...
                GRM_G.saveGID = #GRM_GuildMemberHistory_Save[GRM_G.FID];  -- Also the last position

                -- Adding properly to alts list for this guild...
                GRM_G.NeedsToAddSelfToList = true;

                for i = 1 , #roster do
                    -- Add last time logged in initial timestamp.
                    GRM.AddMemberRecord ( roster[i] , false , nil );
                    GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][#GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ]][24] = roster[i][8];   -- Setting Timestamp for the first time only.
                end
            end
        else
            -- Do a notification check real fast...
            GRM.NotificationCheck ( roster );

            -- This is critical to do in case the guild has added or removed ranks...
            GRM.CheckGuildRanks();

            if not GRM_G.OnFirstLoad then
                C_Timer.After ( 2 , function()
                    GRM_G.ThrottleControlNum = 1;
                    -- new member and leaving members arrays to check at the end - need to reset it here.
                    GRM_G.newPlayers = {};
                    GRM_G.leavingPlayers = {};
                    GRM.CheckPlayerChanges ( roster , GRM_G.guildName , guildNotFound );
                end);
            else
                GRM_G.ThrottleControlNum = 1;
                -- new member and leaving members arrays to check at the end - need to reset it here.
                GRM_G.newPlayers = {};
                GRM_G.leavingPlayers = {};
                GRM.CheckPlayerChanges ( roster , GRM_G.guildName , guildNotFound );
            end
        end
    end
end


--------------------------------------
------ END OF METADATA LOGIC ---------
--------------------------------------



-----------------------------
--- NOTIFICATION TRACKING ---
-----------------------------


-- Method:          GRM.NotificationCheck()
-- What it Does:    Checks if you have any notifications you are tracking, and if so, reports the status change
-- Purpose:         Since some may wish to throttle the speed at which they scan for changes, or disable it altogether, this status check system needs to be an independent
--                  check. It also would be unwise to set a notification to tell you a player came back from being AFK, but your scan for changes was set to once per 10 minutes. Useless!
--                  This ensures and independenet check occurs on demand, every 10 seconds, whilst you are looking for changes in notification.
GRM.NotificationCheck = function( metaData )
    for i = 1 , #GRM_G.ActiveStatusQue do
        for j = 1 , #metaData do
            if metaData[j][1] == GRM_G.ActiveStatusQue[i][1] then
                if GRM_G.ActiveStatusQue[i][3] == 2 or GRM_G.ActiveStatusQue[i][3] == 3 then
                    if GRM_G.ActiveStatusQue[i][2] ~= metaData[j][13] then
                        if metaData[j][13] then
                            chat:AddMessage ( "\n|cffff0000" .. GRM.L ( "NOTIFICATION:" ) .. "|r " .. GRM.L ( "{name} is now ONLINE!" , GRM.GetStringClassColorByName ( GRM_G.ActiveStatusQue[i][1] ) .. GRM.SlimName ( GRM_G.ActiveStatusQue[i][1] ) .. "|r" ) .. "\n" , 1 , 1 , 1 );
                        else
                            chat:AddMessage ( "\n|cffff0000" .. GRM.L ( "NOTIFICATION:" ) .. "|r " .. GRM.L ( "{name} is now OFFLINE!" , GRM.GetStringClassColorByName ( GRM_G.ActiveStatusQue[i][1] ) .. GRM.SlimName ( GRM_G.ActiveStatusQue[i][1] ) .. "|r" ) .. "\n" , 1 , 1 , 1 );
                        end
                        table.remove ( GRM_G.ActiveStatusQue , i );
                    end
                else
                    -- GRM_G.ActiveStatusQue[i][3] == 1; Meaning it is an AFK check
                    if metaData[j][14] == 0 then
                        if metaData[j][13] then
                            chat:AddMessage ( "\n|cffff0000" .. GRM.L ( "NOTIFICATION:" ) .. "|r " .. GRM.L ( "{name} is No Longer AFK or Busy!" , GRM.GetStringClassColorByName ( GRM_G.ActiveStatusQue[i][1] ) .. GRM.SlimName ( GRM_G.ActiveStatusQue[i][1] ) .. "|r" ) .. "\n" , 1 , 1 , 1 );
                        else
                            chat:AddMessage ( "\n|cffff0000" .. GRM.L ( "NOTIFICATION:" ) .. "|r " .. GRM.L ( "{name} is No Longer AFK or Busy, but they Went OFFLINE!" , GRM.GetStringClassColorByName ( GRM_G.ActiveStatusQue[i][1] ) .. GRM.SlimName ( GRM_G.ActiveStatusQue[i][1] ) .. "|r" )  .. "\n" , 1 , 1 , 1 );
                        end
                        table.remove ( GRM_G.ActiveStatusQue , i );
                    end
                end
                break;
            end
        end
    end
end

----------------------
-- EVENT TRACKING!!!!!
----------------------

-- Method:          GRM.SetBirthday ( string , string , string )
-- What it Does:    Sets the player's birthday
-- Purpose:         To take advantage of the player birthdate feature!
GRM.SetBirthday = function ( name , date , description , timeStamp )
    local i = GRM.PlayerQuery ( name );
    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][22][2][1] ~= date and GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][22][2][4] < timeStamp then
        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][22][2][1] = date;
        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][22][2][2] = false;
        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][22][2][3] = description;
        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][22][2][4] = timeStamp;
    end
end

-- Method:          GRM.GetEventYear ( string )
-- What it Does:    Returns the year of the given event from timestamp
-- Purpose:         Keep code clutter down, put this block in reusable form.
GRM.GetEventYear = function ( timestamp )
    -- timestamp format = "Day month year hour min"
    local result = 0;
    if timestamp ~= "" and timestamp ~= nil then
        timestamp = string.sub ( timestamp , string.find ( timestamp , "'" ) + 1 , string.find ( timestamp , "'" ) + 2 );
        result = 2000 + tonumber ( timestamp );
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
    eventName = GRM.SlimName( string.sub ( eventName , 1 , ( string.find ( eventName , " " ) - 1 ) ) ) .. string.sub ( eventName , string.find ( eventName , " " ) , #eventName ); -- necessary for x-realm compatibility to get slimname
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
    for i = 2 , #GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID] do
        if GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i][1] == name and GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i][2] == eventName then
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
    for i = 2 , #GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID] do
        if GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i][1] == name and GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID][i][2] == eventName then
            table.remove ( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID] , i );
            break;
        end
    end
end

-- Method:          GRM.CalendarQueCheck ()
-- What it Does:    It checks the Add Que list, if the event is already on the calendar, then it removes it from the addque list.
-- Purpose:         In case other players add items to the calendar, this keeps it clean.
GRM.CalendarQueCheck = function ()
    local tempQue = GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID];
    local count = 2;

    while count <= #tempQue do
        if GRM.IsCalendarEventAlreadyAdded ( tempQue[count][2] , tempQue[count][5] , tempQue[count][3] , tempQue[count][4] ) then
            table.remove ( tempQue , count );
        else
            count = count + 1;
        end
    end
    GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID] = tempQue;
end

-- Method:          GRM.GetAnniversaryLogReport( string , int , string )
-- What it Does:    Returns the proper string of the annivesary events, both formats. One for UI display, and one for readabilty
-- Purpose:         For the addon feature of reporting and adding the anniversary to the calendar.
GRM.GetAnniversaryLogReport = function ( name , numYears , eventDate )
    local result , result2;
    if numYears == 1 then
        result = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} will be celebrating {num} year in the Guild! ( {custom1} )" , GRM.GetClassifiedName ( name , true ) , nil , numYears , eventDate  ) );
        result2 = GRM.L ( "{name} will be celebrating {num} year in the Guild! ( {custom1} )" , GRM.SlimName ( name ) , nil , numYears , eventDate  );
    else
        result = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} will be celebrating {num} years in the Guild! ( {custom1} )" , GRM.GetClassifiedName ( name , true ) , nil , numYears , eventDate  ) );
        result2 = GRM.L ( "{name} will be celebrating {num} years in the Guild! ( {custom1} )" , GRM.SlimName ( name ) , nil , numYears , eventDate  );
    end
    return result , result2;
end

-- Method:          GRM.GetBirthdayLogReport( string , int , string )
-- What it Does:    Returns the proper string of the birthday events, both formats. One for UI display, and one for readabilty
-- Purpose:         For the addon feature of reporting and adding the anniversary to the calendar.
GRM.GetBirthdayLogReport = function ( name , numYears , eventDate )
    local result , result2;
    local timeInGuild = "";
    -- It's worth mentioning how long they have been in the guild.
    if numYears > 0 then
        if numYear == 1 then
            timeInGuild = "\n" .. GRM.L ( "Guild member for over {num} year" , nil , nil , numYears );
        else
            timeInGuild = "\n" .. GRM.L ( "Guild member for over {num} years" , nil , nil , numYears );
        end
    end
    result = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "It's almost time to celebrate {name}'s Birthday! ( {custom1} )" , GRM.GetClassifiedName ( name , true ) , nil , numYears , eventDate  ) .. timeInGuild )
    result2 = GRM.L ( "It's almost time to celebrate {name}'s Birthday! ( {custom1} )" , GRM.SlimName ( name ) , nil , numYears , eventDate  ) .. timeInGuild;
    return result , result2;
end

-- Method:          GRM.GetCustomEventReport( string , int , string )
-- What it Does:    Returns the proper string of the custom events, both formats. One for UI display, and one for readabilty
-- Purpose:         For the addon feature of reporting and adding the anniversary to the calendar.
-- GRM.GetCustomEventReport = function ( name , numYears , eventDate )
--     local result , result2;

--     return result , result2;
-- end

-- Method:          GRM.ResetPlayerEvent ( string , string )
-- What it Does:    It checks if the event is on the eventsLog announcecment, and then if so, removes it.
-- Purpose:         Events log needs to be adjusted as the player adjusts the settings. This is used for many conditions, so it keeps it in one reusable function.
GRM.ResetPlayerEvent = function ( name , eventName )
    if GRM.IsOnAnnouncementList ( name , eventName ) then
        GRM.RemoveFromCalendarQue ( name , eventName );
    end
end

-- Method:          GRM.CheckPlayerEvents ()
-- What it Does:    Scans through all players'' "events" of the given guild and updates if any are pending
-- Purpose:         Event Management for Anniversaries, Birthdays, and Custom Events
GRM.CheckPlayerEvents = function ()
    -- including anniversary, birthday , and custom
    local _ , month , day , year = GRM.CalendarGetDate()
    local tempGuildRoster = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    local eventMonth , eventMonthIndex , eventDay , eventYear , anniversaryYear , isLeapYear , logReport , logReport2;
    for j = 2 , #tempGuildRoster do
        local playerSlimName = GRM.SlimName ( tempGuildRoster[j][1] );
        -- Player identified, now let's check his event info!
        for r = 1 , #tempGuildRoster[j][22] do          -- Loop all events!
            eventMonth = GRM.GetEventMonth ( tempGuildRoster[j][22][r][1] );
            eventMonthIndex = monthEnum [ eventMonth ];
            eventDay = tonumber ( GRM.GetEventDay ( tempGuildRoster[j][22][r][1] ) );
            anniversaryYear = GRM.GetEventYear ( tempGuildRoster[j][22][1][1] );
            isLeapYear = GRM.IsLeapYear ( year );

            -- Don't need the year for a birthday, which is index 2
            if r ~= 2 then
                eventYear = GRM.GetEventYear ( tempGuildRoster[j][22][1][1] );
            else
                eventYear = year - 1; -- This exists because normally it would filter this out if it's same year in the operator arguments. Just set it to previous year. It won't report it
            end

            logReport = "";
            logReport2 = "";            -- Clean of the string fluff, for just adding details into the event description.
            --  Quick Leap Year Check
            if ( eventDay == 29 and eventMonthIndex == 2 ) and not isLeapYear then  -- If Event is Feb 29th Leap year, and reporting year is not, then put event in Mar 1st.
                eventMonthIndex = 3;
                eventDay = 1;
            end
             -- Check status - another player might have already added it to the list.
            -- indexOfEvent: 1 = anniversary , 2 = birthday , 3 = custom 
            local title = "";
            if r == 1 then
                title = GRM.L ( "{name}'s Anniversary!" , playerSlimName );
            elseif r == 2 then
                title = GRM.L ( "{name}'s Birthday!" , playerSlimName );
            elseif r == 3 then
                title = tempGuildRoster[j][22][r][4];
            end
            
            if tempGuildRoster[j][22][r][1] ~= nil and tempGuildRoster[j][22][r][2] ~= true and ( month == eventMonthIndex or month + 1 == eventMonthIndex ) and not ( year == eventYear and month == eventMonthIndex and day == eventDay ) then        -- if it has already been reported, then we are good!
                
                local daysTil = eventDay - day;
                local daysLeftInMonth = daysInMonth [ tostring ( month ) ] - day;
                if month == 2 and GRM.IsLeapYear ( year ) then
                    daysLeftInMonth = daysLeftInMonth + 1;
                end
                
                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][12] and ( ( month == eventMonthIndex and daysTil >= 0 and daysTil <= GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][5] ) or ( month + 1 == eventMonthIndex and ( eventDay + daysLeftInMonth <= GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][5] ) ) ) then
                    
                    -- Configure some of the dates
                    local numYears = year - anniversaryYear;
                    if r == 1 and numYears == 0 then
                        numYears = 1;
                    end
                    local eventDate;
                    if ( eventDay == 29 and eventMonthIndex == 2 ) and not isLeapYear then    -- If anniversary happened on leap year date, and the current year is NOT a leap year, then put it on 1 Mar.
                        eventDay = 1;
                        eventDate = GRM.L ( "1 Mar" );
                    else
                        eventDate = eventDay .. " " .. GRM.L ( string.sub ( tempGuildRoster[j][22][r][1] , string.find ( tempGuildRoster[j][22][r][1] , " " ) + 1 , string.find ( tempGuildRoster[j][22][r][1] , " " ) + 3 ) );
                    end
                    -- /run GRM.SetBirthday ( "Arkaan-Zul'jin" , "29 Apr" , "Arkaan is having a birthday!!!" , time() )
                    -- /run GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID][283][22][2][2] = false
                    -- Join Date Anniversary -- Let's see if player has it set to ONLY announce anniversary event on Calendar for a player's "main"
                    if r == 1 and ( not GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][17] or tempGuildRoster[j][10] ) then
                        
                        logReport , logReport2 = GRM.GetAnniversaryLogReport ( tempGuildRoster[j][1] , numYears , eventDate );
                        table.insert ( GRM_G.TempEventReport , { 15 , logReport , false } );
                    
                    elseif r == 2 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][40] then
                    -- RL BIRTHDAY!
                        logReport , logReport2 = GRM.GetBirthdayLogReport ( tempGuildRoster[j][1] , numYears , eventDate );
                        table.insert ( GRM_G.TempEventReport , { 15 , logReport , false } );
                    elseif r == 3 then
                    -- CUSTOM EVENT!
                        logReport , logReport2 = GRM.GetCustomEventReport ( tempGuildRoster[j][1] , numYears , eventDate );
                    
                    end
                    
                    -- Now, let's add it to the calendar!!!
                    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][8] and logReport2 ~= "" and CanEditGuildEvent() then
                        if month == 12 and eventMonthIndex == 1 then
                            year = year + 1;
                        end 

                        local isAddedAlready = GRM.IsCalendarEventAlreadyAdded (  title , year , eventMonthIndex , eventDay  );
                        if not isAddedAlready and not GRM.IsOnAnnouncementList ( tempGuildRoster[j][1] , title ) then
                            -- { playerName , EventTitle , monthIndex , day , year , Description, indexOfEvent } 
                            if string.find ( logReport2 , "%(" ) ~= nil then
                                logReport2 = string.sub ( logReport2 , 1 , string.find ( logReport2 , "%(" ) -2 );
                            end
                            table.insert ( GRM_CalendarAddQue_Save[GRM_G.FID][GRM_G.saveGID] , { tempGuildRoster[j][1] , title , eventMonthIndex , eventDay , year , logReport2 , r } );
                        end
                    end
                    -- This has been reported, save it!
                    tempGuildRoster[j][22][r][2] = true;
                end                  
                
            -- Resetting the event report to false if parameters meet
            elseif tempGuildRoster[j][22][r][2] then                                                   -- It is still true! Event has been reported! Let's check if time has passed sufficient to wipe it to false
                if ( month == eventMonthIndex and eventDay - day < 0 ) or ( month > eventMonthIndex  ) or ( eventMonthIndex - month > 1 ) then     -- Event is behind us now
                    tempGuildRoster[j][22][r][2] = false;
                    GRM.ResetPlayerEvent ( tempGuildRoster[j][1] , title );
                elseif month == eventMonthIndex and eventDay - day > GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][5] then      -- Setting back to false;
                    tempGuildRoster[j][22][r][2] = false;
                    GRM.ResetPlayerEvent ( tempGuildRoster[j][1] , title );
                elseif GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][17] and not tempGuildRoster[j][10] then
                    tempGuildRoster[j][22][r][2] = false;
                    GRM.ResetPlayerEvent ( tempGuildRoster[j][1] , title );

                -- Cleanup
                elseif month + 1 == eventMonthIndex then
                    local daysLeftInMonth = daysInMonth [ tostring ( month ) ] - day;
                    if month == 2 and GRM.IsLeapYear ( year ) then
                        daysLeftInMonth = daysLeftInMonth + 1;
                    end
                    if eventDay + daysLeftInMonth > GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][5] then
                        tempGuildRoster[j][22][r][2] = false;
                        GRM.ResetPlayerEvent ( tempGuildRoster[j][1] , title );
                    end
                end
            end
        end
    end
    GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] = tempGuildRoster;
end

-- Method:          AddAnnouncementToCalendar ( string , int , int , int , string )
-- What it Does:    Adds the announcement to the in-game calendar, if player has permissions to do so.
-- Purpose:         CalendarAddEvent() is a protected function thus it needs to be triggered by a player in-game action, so it will
--                  be linked to a button on the "GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame" window. Again, this cannot be activated, it WILL NOT WORK without 
--                  in-game action to remove protection on function
GRM.AddAnnouncementToCalendar = function ( title , eventMonthIndex , eventDay , year , description )
    CalendarCloseEvent();                           -- Just in case previous event was never closed, either by other addons or by player
    local _, month, day = GRM.CalendarGetDate()
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

--------------------------------
-------- LOG CONTROLS ----------
--------------------------------

-- Method:          GRM.RemoveItemFromLog ( string )
-- What it Does:    Finds the matching string in the log, and removes it
-- Purpose:         For quick log cleanup.
GRM.RemoveItemFromLog = function ( stringToRemove , buildLog )
    for i = 2 , #GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID] do
        if GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID][i][2] == stringToRemove then
            table.remove ( GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID] , i );
            break;
        end
    end
    if buildLog and GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame:IsVisible() then
        GRM_G.LogNumbersColorUpdate = true;
        GRM.BuildLogComplete()
    end
end

-- Method:          ClearVisibleLogLinesWithinRange ( int , int )
-- What it Does:    Parse through all of the fontstrings visible, then matches them to the log and purges them
-- Purpose:         For log cleanup and UI features for the user
GRM.ClearVisibleLogLinesWithinRange = function ( start , stop )
    if start == 0 then
        start = 1;
    end
    for i = start , stop do
        if GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings[i][1]:IsVisible() then
            GRM.RemoveItemFromLog ( GRM.Trim ( GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings[i][1]:GetText() ) , false );  -- The trim removes the white space before it, if the player has visible line numbering checked.
        end
    end
end

-- Method:          GRM.RemoveAllMatchesFromLog ( string )
-- What it Does:    Searches, case sensitive, through the log of the current guild for any matches of the given string. If it finds them, it purges that log entry
-- Purpose:         To give the user the power to cleanup the log
GRM.RemoveAllMatchesFromLog = function ( match )
    local logEntry = GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID];
    local i=2;
    while i <= #logEntry do
        if string.find ( logEntry[i][2] , match ) ~= nil then 
            table.remove ( logEntry , i );
        else
            i = i + 1;
        end;
    end;
    GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID] = logEntry;
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame:IsVisible() then
        GRM.BuildLogComplete()
    end
end

-- Method:          GRM.ResetLogReport()
-- What it Does:    Deletes the guild Log
-- Purpose:         In case player wishes to reset guild Log information.
GRM.ResetLogReport = function( guildName )
    if #GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID] == 1 then
        GRM.Report ( GRM.L ( "There are No Log Entries to Delete, silly {name}!" , GRM.GetClassifiedName ( GRM_G.addonPlayerName , true ) ) );
    else
        GRM.Report ( GRM.L ( "Guild Log has been RESET!" ) );
        -- Actually resetting log. Just remove, then add back empty
        if guildName == nil then
            table.remove ( GRM_LogReport_Save[GRM_G.FID] , GRM_G.logGID );
            table.insert ( GRM_LogReport_Save[GRM_G.FID] , GRM_G.logGID , { { GRM_G.guildName , GRM_G.guildCreationDate } } );
        else
            -- Find the guild to reset it...
        end
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetText( GRM.L ( "Search Filter" ) );
        if GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then    -- if frame is open, let's rebuild it!
            GRM.BuildLog();
        end
    end
end

-- Method:          GRM.BuildLogComplete()
-- What it Does:    Checks the editbox and sees whether to build the log normal, or to auto-rebuild the log based on the custom text filter.
-- Purpose:         The Call to rebuild the log is done about 50 times. This cleans up the code bloat.
GRM.BuildLogComplete = function()
    if GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then
        local number = tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:GetText() );
        local number2 = tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:GetText() );
        if not ( number == 0 and number == number2 ) and number <= number2 then
            GRM_G.LogNumbersColorUpdate = true;
        end
        if GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:GetText() ~= "" and GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:GetText() ~= GRM.L ( "Search Filter" ) then
            GRM.BuildLog ( GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:GetText() );
        else
            GRM.BuildLog();
        end
    end
end

-- Method:          GRM.BuildLog( string )
-- What it Does:    Builds the guildLog frame details for the scrollframe
-- Purpose:         You aren't tracking all of that info for nothing!
GRM.BuildLog = function ( searchString )
    -- SCRIPT LOGIC ON ADD EVENT SCROLLING FRAME
    local scrollHeight = 0;
    local scrollWidth = 561;
    local buffer = 7;
    local txtWidth = 555;
    local isSearch = false;
    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][36] then
        txtWidth = 520;
    end
    if type ( searchString ) == "string" then
        searchString = string.lower ( searchString ); -- Remove case sensitivity
        isSearch = true;
    end

    -- Infinite scroll setup.
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider.ScrollCount > #GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider.ScrollCount = #GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID];
    elseif GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider.ScrollCount < 50 then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider.ScrollCount = 50;
    end

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings or {};  -- Create a table for the Buttons.

    -- Error protection
    if GRM_G.logGID == 0 then
        for i = 2 , #GRM_LogReport_Save[GRM_G.FID] do
            if GRM_LogReport_Save[GRM_G.FID][i][1][1] == GRM_G.guildName then
                GRM_G.logGID = i;
                break;
            end
        end
    end

    -- populating the window correctly.
    local count = 1;
    local i = 1;
    while i <= #GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID] and count <= GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider.ScrollCount do
        local arrayIndex = #GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID] - i + 1
        if arrayIndex == 1 then
            break;
        end
        -- if font string is not created, do so.
        local trueString = false;
        
        -- Check buttons
        local index = GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID][arrayIndex][1];
        local logTxt = GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID][arrayIndex][2];
        if type( searchString ) == "string" then
            if string.find ( string.lower ( logTxt ) , searchString ) ~= nil then           -- Comparing 2 non-case-sensitive strings
                trueString = true;
            end
        elseif index == 1 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButton:GetChecked() then      -- Promotion 
            trueString = true;
        elseif index == 2 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButton:GetChecked() then  -- Demotion
            trueString = true;
        elseif index == 3 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButton:GetChecked() then  -- Leveled

            -- Need to parse out the level, then compare. Only show the string if they are matching level
            -- This is importance because it includes pre-localization efforts...
            -- ENSURE LOCALIZATION IS COMPATIBLE WITH THIS LOGIC!!!
            local level = "";
            local isStarted = false;
            local startParse = string.find ( logTxt , "%(" ) - 1;
            for i = startParse , 1 , -1 do
                if not isStarted and tonumber ( string.sub ( logTxt , i , i ) ) ~= nil then
                    level = tonumber ( string.sub ( logTxt , i , i ) );
                    isStarted = true;
                elseif isStarted and tonumber ( string.sub ( logTxt , i , i ) ) ~= nil then
                    level = tonumber ( string.sub ( logTxt , i , i ) ) .. level;      -- places it in the front since we are building backwards.
                elseif isStarted and tonumber ( string.sub ( logTxt , i , i ) ) == nil then
                    break;
                end
            end           
            if tonumber ( level ) >= GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][23] then
                trueString = true;
            end
        elseif index == 4 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButton:GetChecked() then  -- Note
            trueString = true;
        elseif index == 5 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButton:GetChecked() then  -- OfficerNote
            trueString = true;
        elseif index == 6 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButton:GetChecked() then  -- OfficerNote
            trueString = true;
        elseif ( index == 7 or index == 8 ) and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButton:GetChecked() then  -- Join/Rejoin
            trueString = true;
        elseif index == 10 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButton:GetChecked() then -- Left Guild
            trueString = true;
        elseif index == 11 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButton:GetChecked() then -- NameChange
            trueString = true;
        elseif index == 14 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButton:GetChecked() then -- Return from inactivity
            trueString = true;
        elseif index == 15 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButton:GetChecked() then -- Event Announcement
            trueString = true;
        elseif index == 16 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButton:GetChecked() then -- Event Announcement
            trueString = true;
        elseif ( index == 17 or index == 18 ) and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButton:GetChecked() then  -- ban info
            trueString = true;
        elseif ( index == 9 or index == 12 or index == 13 ) and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButton:GetChecked() then
            trueString = true;
        elseif index == 19 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterCustomNoteChangeCheckButton:GetChecked() then
            trueString = true;
        end

        if trueString then
            local color = { 1 , 1 , 1 };
            if GRM_G.LogNumbersColorUpdate and count >= tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox1:GetText() ) and count <= tonumber ( GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogExtraOptionsFrame.GRM_LogExtraEditBox2:GetText() ) then
                color = { 1 , 0 , 0 };
            end
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings[count] then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings[count] = { GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame:CreateFontString ( "GRM_LogEntry_" .. count ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame:CreateFontString ( "GRM_LogCount_" .. count , "OVERLAY" , "GameFontWhiteTiny" ) };
            end

            -- coloring
            local r , g , b = GRM.GetMessageRGB ( GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID][#GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID] - i + 1][1] );
            local logFontString = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings[count][1];
            local logCount = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings[count][2];
            logFontString:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame , 7 , -99 );
            if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][36] then
                logFontString:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 9.5 );
            else
                logFontString:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 11 );
            end
            logFontString:SetJustifyH ( "LEFT" );
            logFontString:SetSpacing ( buffer );
            logFontString:SetTextColor ( r , g , b , 1.0 );
            logFontString:SetText ( logTxt );
            logFontString:SetWidth ( txtWidth );
            logFontString:SetWordWrap ( true );
            logCount:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 9.5 );   
            logCount:SetJustifyH ( "LEFT" );
            logCount:SetText ( count .. ")" );
            logCount:SetWidth ( 35 );
            logCount:SetTextColor ( color[1] , color[2] , color[3] );
            local stringHeight = logFontString:GetStringHeight();

            -- Now let's pin it!
            if count == 1 then
                logFontString:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame , 0 , - 5 );
                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][36] then
                    logFontString:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame , 35 , - 5 );
                    logCount:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame , 0 , -5 );
                end
                scrollHeight = scrollHeight + stringHeight;
            else
                logFontString:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings[count - 1][1] , "BOTTOMLEFT" , 0 , - buffer );
                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][36] then
                    logCount:SetPoint ( "TOPRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings[count][1] , "TOPLEFT" , 0 , 0 );
                end
                scrollHeight = scrollHeight + stringHeight + buffer;
            end
            count = count + 1;
            logFontString:Show();
            if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][36] then
                logCount:Show();
            else
                logCount:Hide();
            end
        end
        i = i + 1;
    end

    -- Hides all the additional buttons... if necessary
    for i = count , #GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings do
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings[i][1]:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings[i][2]:Hide();
    end 

    -- Update the size -- it either grows or it shrinks!
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame:SetSize ( scrollWidth , scrollHeight );

    --Set Slider Parameters ( has to be done after the above details are placed )
    local scrollMax = ( scrollHeight - 419 ) + ( buffer * 0.25 );  -- 
    if scrollMax < 0 then
        scrollMax = 0;
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
    -- Mousewheel Scrolling Logic
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrame:EnableMouseWheel( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrame:SetScript( "OnMouseWheel" , function( _ , delta )
        local current = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider:GetValue();
        
        if IsShiftKeyDown() and delta > 0 then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider:SetValue ( 0 );
        elseif IsShiftKeyDown() and delta < 0 then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider:SetValue ( scrollMax );
        elseif delta < 0 and current < scrollMax then
            if IsControlKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider:SetValue ( current + 60 );
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider:SetValue ( current + 20 );
            end
        elseif delta > 0 and current > 1 then
            if IsControlKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider:SetValue ( current - 60 );
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrameSlider:SetValue ( current - 20 );
            end
        end
    end);

    -- update the count
    GRM_G.LogNumbersColorUpdate = false;
    GRM_G.FinalCountVisible = count - 1;
    if isSearch then
        count = GRM_G.FinalCountVisible;
    else
        count = #GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID] - 1;
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogFrameNumEntriesText:SetText ( GRM.L ( "Total Entries: {num}" , nil , nil , count ) );
end

-- Method:          GRM.BuildExportLogFrame(string,int,int)
-- What it Does:    Exactly as named... adds the entire guild log from the given guild, parses out the coloring, and makes it easy to copy and paste it
-- Purpose:         To allow players the ability to export their logs to a file somewhere to keep their system from getting too clutters.
GRM.BuildExportLogFrame = function( guildName , lineStart , lineEnd , searchString )
    local scrollHeight = 0;
    local scrollWidth = 430;
    local completeString = "";
    local trueString = false;
    local index = 1;
    local logTxt = "";
    local count = 0;

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:Hide();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_ExportLoadingText:Hide();
    for i = 1 , #GRM_LogReport_Save do
        for j = 2 , #GRM_LogReport_Save[i] do
            local isFound;
            if type ( GRM_LogReport_Save[i][j][1] ) == "table" then
                if GRM_LogReport_Save[i][j][1][1] == guildName then
                    isFound = true;
                end
            else
                if GRM_LogReport_Save[i][j][1] == guildName then
                    isFound = true;
                    break;
                end
            end
            if isFound then
                if #GRM_LogReport_Save[i][j] > 1 then
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_ExportLoadingText:SetText ( GRM.L ( "Building Log for Export..." ) );
                    -- Establish start and stop points...

                    if lineStart < 2 then
                        lineStart = 2;
                    end
                    if lineEnd == -1 or lineEnd > #GRM_LogReport_Save[i][j] then
                        lineEnd = #GRM_LogReport_Save[i][j];
                    end
                    for r = lineEnd , lineStart , -1 do
                        index = GRM_LogReport_Save[i][j][r][1];
                        logTxt = string.lower ( GRM_LogReport_Save[i][j][r][2] );
                        trueString = false;

                        if searchString ~= nil and type( searchString ) == "string" then
                            if string.find ( logTxt , string.lower ( searchString ) ) ~= nil then           -- Comparing 2 non-case-sensitive strings
                                trueString = true;
                            end
                        elseif index == 1 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButton:GetChecked() then      -- Promotion 
                            trueString = true;
                        elseif index == 2 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButton:GetChecked() then  -- Demotion
                            trueString = true;
                        elseif index == 3 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButton:GetChecked() then  -- Leveled
                            -- Need to parse out the level, then compare. Only show the string if they are matching level
                            -- This is importance because it includes pre-localization efforts...
                            -- ENSURE LOCALIZATION IS COMPATIBLE WITH THIS LOGIC!!!
                            local level = "";
                            local isStarted = false;
                            local startParse = string.find ( logTxt , "%(" ) - 1;
                            for i = startParse , 1 , -1 do
                                if not isStarted and tonumber ( string.sub ( logTxt , i , i ) ) ~= nil then
                                    level = tonumber ( string.sub ( logTxt , i , i ) );
                                    isStarted = true;
                                elseif isStarted and tonumber ( string.sub ( logTxt , i , i ) ) ~= nil then
                                    level = tonumber ( string.sub ( logTxt , i , i ) ) .. level;      -- places it in the front since we are building backwards.
                                elseif isStarted and tonumber ( string.sub ( logTxt , i , i ) ) == nil then
                                    break;
                                end
                            end           
                            if tonumber ( level ) >= GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][23] then
                                trueString = true;
                            end
                        elseif index == 4 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNoteChangeCheckButton:GetChecked() then  -- Note
                            trueString = true;
                        elseif index == 5 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterOfficerNoteChangeCheckButton:GetChecked() then  -- OfficerNote
                            trueString = true;
                        elseif index == 6 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRankRenameCheckButton:GetChecked() then  -- OfficerNote
                            trueString = true;
                        elseif ( index == 7 or index == 8 ) and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButton:GetChecked() then  -- Join/Rejoin
                            trueString = true;
                        elseif index == 10 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeftGuildCheckButton:GetChecked() then -- Left Guild
                            trueString = true;
                        elseif index == 11 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterNameChangeCheckButton:GetChecked() then -- NameChange
                            trueString = true;
                        elseif index == 14 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterInactiveReturnCheckButton:GetChecked() then -- Return from inactivity
                            trueString = true;
                        elseif index == 15 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterEventCheckButton:GetChecked() then -- Event Announcement
                            trueString = true;
                        elseif index == 16 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterRecommendationsButton:GetChecked() then -- Event Announcement
                            trueString = true;
                        elseif ( index == 17 or index == 18 ) and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterBannedPlayersButton:GetChecked() then  -- ban info
                            trueString = true;
                        elseif ( index == 9 or index == 12 or index == 13 ) and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterJoinedCheckButton:GetChecked() then
                            trueString = true;
                        elseif index == 19 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterCustomNoteChangeCheckButton:GetChecked() then
                            trueString = true;
                        end
                        if trueString then
                            count = count + 1;
                            if r == lineEnd then
                                completeString = GRM.RemoveStringColoring ( GRM_LogReport_Save[i][j][r][2] );
                            else
                                completeString = completeString .. "\n" .. GRM.RemoveStringColoring ( GRM_LogReport_Save[i][j][r][2] );
                            end
                        end
                    end
                end
                if count == 0 then
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_ExportLoadingText:SetText ( GRM.L ( "The Log is Currently Empty for This Guild" ) );
                end
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_ExportLoadingText:Show();
                break;
            end
        end
        if completeString ~= "" then
            break;
        end
    end

    if completeString ~= "" then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:SetText ( completeString );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:HighlightText ( 0 );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:Show();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogBorderFrame.GRM_ExportLoadingText:Hide();
        C_Timer.After ( 2 , function()
            GRM.ExportScrollSliderConfigure( scrollWidth , scrollHeight );
        end);
    end
end

-- Method:          GRM.ExportScrollSliderConfigure ( int , float , float )
-- What it Does:    Used in the building of the xport frame for the log. This sets the slider values.
-- Purpose:         Kept seperate so it can run recrusively on re-checking if necessary.
GRM.ExportScrollSliderConfigure = function ( scrollWidth , scrollHeight )
    scrollHeight = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:GetHeight();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogFrameEditBox:SetSize ( scrollWidth , scrollHeight + 10 );

    local scrollMax = ( scrollHeight - 428 ) + GRM_G.FontModifier + 12;
    if scrollMax < 0 then
        scrollMax = 0;
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
    -- Mousewheel Scrolling Logic
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrame:EnableMouseWheel( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrame:SetScript( "OnMouseWheel" , function( _ , delta )
        local current = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider:GetValue();
        
        if IsShiftKeyDown() and delta > 0 then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider:SetValue ( 0 );
        elseif IsShiftKeyDown() and delta < 0 then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider:SetValue ( scrollMax );
        elseif delta < 0 and current < scrollMax then
            if IsControlKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider:SetValue ( current + 60 );
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider:SetValue ( current + 20 );
            end
        elseif delta > 0 and current > 1 then
            if IsControlKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider:SetValue ( current - 60 );
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_ExportLogScrollFrameSlider:SetValue ( current - 20 );
            end
        end
    end);
end


-- Method:          GRM.BuildCustomNoteScrollFrame ( string )
-- What it Does:    Builds the custom note scroll frame
-- Purpose:         To have a customizable scrollable scrollframe!!!
GRM.BuildCustomNoteScrollFrame = function( customNote )
    if GRM_G.previousNote ~= customNote then
        GRM_G.previousNote = customNote;
        local scrollHeight = 0;
        local scrollWidth = 123;

        if customNote == "" and not GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteEditBox:HasFocus() then
            customNote = GRM.L ( "Click here to set Custom Notes" );
        end
        GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteEditBox:SetText ( customNote );

        -- Slight delay needed before you can do a GetHeight()
        C_Timer.After ( 0.05 , function()
            scrollHeight = GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteEditBox:GetHeight();
            GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteEditBox:SetSize ( scrollWidth , scrollHeight + 10 );

            local scrollMax = ( scrollHeight - 80 ) + GRM_G.FontModifier + 5;
            if scrollMax < 0 then
                scrollMax = 0;
                GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteScrollFrameSlider:Hide();
            else
                GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteScrollFrameSlider:Show();
                GRM_CustomNoteScrollFrameSliderThumbTexture:Show()
            end
            GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
            -- Mousewheel Scrolling Logic
            GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteScrollFrame:EnableMouseWheel( true );
            GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteScrollFrame:SetScript( "OnMouseWheel" , function( _ , delta )
                local current = GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteScrollFrameSlider:GetValue();
                
                if IsShiftKeyDown() and delta > 0 then
                    GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteScrollFrameSlider:SetValue ( 0 );
                elseif IsShiftKeyDown() and delta < 0 then
                    GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteScrollFrameSlider:SetValue ( scrollMax );
                elseif delta < 0 and current < scrollMax then
                    if IsControlKeyDown() then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteScrollFrameSlider:SetValue ( current + 60 );
                    else
                        GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteScrollFrameSlider:SetValue ( current + 20 );
                    end
                elseif delta > 0 and current > 1 then
                    if IsControlKeyDown() then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteScrollFrameSlider:SetValue ( current - 60 );
                    else
                        GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteScrollFrameSlider:SetValue ( current - 20 );
                    end
                end
            end);
        end);
    end
end

-- Method:          GRM.ClearCustomNoteMatches ( string )
-- What it Does:    Parses through every single custom note of the current guild and clears matches
-- Purpose:         Due to a previous error that causes the note to transfer to ALL players, this clears that up.
GRM.ClearCustomNoteMatches = function ( stringMatch )
    local count = 0;
    local timeStamp = time();
    if stringMatch ~= "" and stringMatch ~= nil then
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
            if string.find ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][23][6] , stringMatch ) ~= nil then
                count = count + 1;
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][23][2] = timeStamp
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][23][3] = "";
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][23][6] = "";
            end
        end

        for j = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
            if string.find ( GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][23][6] , stringMatch ) ~= nil then
                count = count + 1;
                GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][23][2] = timeStamp;
                GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][23][3] = "";
                GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][23][6] = "";
            end
        end
        local note = GRM.L ( "notes" ); 
        if count == 1 then
            note = string.lower ( GRM.L ( "Note" ) );
        end
        local report = GRM.L ( "{num} custom {custom1} removed that matched text:" , nil , nil , count , note ) ..  " \"" .. stringMatch .. "\"";
        GRM.Report ( report );
        table.insert ( GRM_LogReport_Save[GRM_G.FID][GRM_G.logGID] , { 19 , report } )
    else
        GRM.Report ( GRM.L ( "Please add specific text, in quotations, to match" ) );
    end
end

------------------------------------
---- BEGIN OF FRAME/UI LOGIC -------
---- General Framebuild Methods ----
------------------------------------


-- Method:          GRM.OnDropMenuClickDay()
-- What it Does:    Upon clicking any item in a drop down menu, this sets the ID of that item as defaulted choice
-- Purpose:         General use clicking logic for month based drop down menu.
GRM.OnDropMenuClickDay = function ()
    GRM_G.dayIndex = tonumber ( GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected.GRM_DayText:GetText() );
    GRM.InitializeDropDownDay();
end

-- Method:          GRM.OnDropMenuClickMonth()
-- What it Does:    Recalculates the logic of number days to show.
-- Purpose:         General use clicking logic for month based drop down menu.
GRM.OnDropMenuClickMonth = function ()
    GRM_G.monthIndex = monthsFullnameEnum [ GRM.OrigL ( GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:GetText() ) ];
    GRM.InitializeDropDownDay();
end

-- Method:          GRM.OnDropMenuClickYear()
-- What it Does:    Upon clicking any item in a drop down menu, this sets the ID of that item as defaulted choice
-- Purpose:         General use clicking logic for year based drop down menu.
GRM.OnDropMenuClickYear = function ()
    GRM_G.yearIndex = tonumber ( GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected.GRM_YearText:GetText() );
    GRM.InitializeDropDownDay();
end

-- Method:          GRM.InitializeDropDownDay ()
-- What it Does:    Initializes the Drop Down "Day" select window with values based on selected month
-- Purpose:         UI feature for easy date select.
GRM.InitializeDropDownDay = function ()
    local shortMonth = 30;
    local longMonth = 31;
    local febMonth = 28;
    local leapYear = 29;
    local yearDate = 0;

    yearDate = GRM_G.yearIndex;
    local isDateALeapyear = GRM.IsLeapYear(yearDate);
    local numDays;
    
    if GRM_G.monthIndex == 1 or GRM_G.monthIndex == 3 or GRM_G.monthIndex == 5 or GRM_G.monthIndex == 7 or GRM_G.monthIndex == 8 or GRM_G.monthIndex == 10 or GRM_G.monthIndex == 12 then
        numDays = longMonth;
    elseif GRM_G.monthIndex == 2 and isDateALeapyear then
        numDays = leapYear;
    elseif GRM_G.monthIndex == 2 then
        numDays = febMonth;
    else
        numDays = shortMonth;
    end
      
    -- populating the frames!
    local buffer = 3;
    local height = 0;
    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu.Buttons = GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu.Buttons do
        GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu.Buttons[i][1]:Hide();
    end
    
    for i = 1 , numDays do
        if not GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "DayOfTheMonth" .. i , GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu );
            GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "DayOfTheGRM_MonthText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local DayButtons = GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu.Buttons[i][1];
        local DayButtonsText = GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu.Buttons[i][2];
        DayButtons:SetWidth ( 24 );
        DayButtons:SetHeight ( 10 );
        DayButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        DayButtonsText:SetText ( i );
        DayButtonsText:SetWidth ( 25 );
        DayButtonsText:SetWordWrap ( false );
        DayButtonsText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 9 );
        DayButtonsText:SetPoint ( "CENTER" , DayButtons );
        DayButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            DayButtons:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu , 0 , -7 );
            height = height + DayButtons:GetHeight();
        else
            DayButtons:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + DayButtons:GetHeight() + buffer;
        end

        DayButtons:SetScript ( "OnClick" , function( _ , button ) 
            if button == "LeftButton" then
                GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected.GRM_DayText:SetText ( DayButtonsText:GetText() );
                GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:Hide();
                GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected:Show();
                GRM.OnDropMenuClickDay();
            end
        end); 

        DayButtons:Show();
    end
    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.InitializeDropDownYear()
-- What it Does:    Initializes the year select drop-down OnDropMenuClick
-- Purpose:         Easy way to set when player joined the guild.         
GRM.InitializeDropDownYear = function ()
    -- Year Drop Down
    local _,_,_,currentYear = GRM.CalendarGetDate();
    local yearStamp = currentYear;

    -- populating the frames!
    local buffer = 2;
    local height = 0;
    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu.Buttons = GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu.Buttons do
        GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu.Buttons[i][1]:Hide();
    end
    
    -- Game wasn't released until early 2004
    for i = 1 , currentYear - 2003 do
        if not GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "YearIndexButton" .. i , GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu );
            GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "YearIndexButtonText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local YearButtons = GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu.Buttons[i][1];
        local YearButtonsText = GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu.Buttons[i][2];
        YearButtons:SetWidth ( 40 );
        YearButtons:SetHeight ( 10 );
        YearButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        YearButtonsText:SetText ( yearStamp );
        YearButtonsText:SetWidth ( 32 );
        YearButtonsText:SetWordWrap ( false );
        YearButtonsText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 9 );
        YearButtonsText:SetPoint ( "CENTER" , YearButtons );
        YearButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            YearButtons:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu , 0 , -7 );
            height = height + YearButtons:GetHeight();
        else
            YearButtons:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + YearButtons:GetHeight() + buffer;
        end

        YearButtons:SetScript ( "OnClick" , function( _ , button ) 
            if button == "LeftButton" then
                GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected.GRM_YearText:SetText ( YearButtonsText:GetText() );
                GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:Hide();
                GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected:Show();
                GRM.OnDropMenuClickYear();
            end
        end); 
        yearStamp = yearStamp - 1                       -- Descending the year by 1
        YearButtons:Show();
    end
    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenu:SetHeight ( height + 15 );

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
    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu.Buttons = GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu.Buttons do
        GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu.Buttons[i][1]:Hide();
    end
    
    for i = 1 , #months do
        if not GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "monthIndex" .. i , GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "monthIndexText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local MonthButtons = GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu.Buttons[i][1];
        local MonthButtonsText = GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu.Buttons[i][2];
        MonthButtons:SetWidth ( 83 );
        MonthButtons:SetHeight ( 10 );
        MonthButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        MonthButtonsText:SetText ( GRM.L ( months[i] ) );
        MonthButtonsText:SetWidth ( 83 );
        MonthButtonsText:SetWordWrap ( false );
        MonthButtonsText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 9 );
        MonthButtonsText:SetPoint ( "CENTER" , MonthButtons );
        MonthButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            MonthButtons:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu , 0 , -7 );
            height = height + MonthButtons:GetHeight();
        else
            MonthButtons:SetPoint ( "TOP" , GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + MonthButtons:GetHeight() + buffer;
        end

        MonthButtons:SetScript ( "OnClick" , function( _ , button ) 
            if button == "LeftButton" then
                GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:SetText ( MonthButtonsText:GetText() );
                GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:Hide();
                GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected:Show();
                GRM.OnDropMenuClickMonth();
            end
        end); 

        MonthButtons:Show();
    end
    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.SetJoinDate ()
-- What it Does:    Sets the player's join date properly, be it the first time, a modified time, or an edit.
-- Purpose:         For so many uses! Anniversary tracking, for editing the date, and so on...
GRM.SetJoinDate = function ()
    local name = GRM_G.currentName;
    local dayJoined = tonumber ( GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected.GRM_DayText:GetText() );
    local yearJoined = tonumber ( GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected.GRM_YearText:GetText() );
    local IsLeapYearSelected = GRM.IsLeapYear ( yearJoined );
    local buttonText = GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButtonTxt:GetText();

    if GRM.IsValidSubmitDate ( dayJoined , monthsFullnameEnum [ GRM.OrigL ( GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:GetText() ) ] , yearJoined, IsLeapYearSelected ) then
        local rankButton = false;
        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] == name then

                local joinDate = ( "Joined: " .. dayJoined .. " " .. string.sub ( GRM.OrigL ( GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:GetText() ) , 1 , 3 ) .. " '" ..  string.sub ( yearJoined , 3 ) );
                local finalTStamp = ( string.sub ( joinDate , 9 ) .. " 12:01am" );
                local finalEpochStamp = GRM.TimeStampToEpoch ( joinDate , true );
                -- For metadata tracking
                if buttonText == GRM.L ( "Edit Join Date" ) then
                    table.remove ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][20] , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][20] );  -- Removing previous instance to replace
                    table.remove ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][21] , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][21] );
                end
                table.insert( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][20] , finalTStamp );      -- oldJoinDate
                table.insert( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][21] , finalEpochStamp ) ;    -- oldJoinDateMeta
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][2] = finalTStamp;
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][3] = finalEpochStamp;

                -- For sync
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][35][1] = finalTStamp;
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][35][2] = time();

                -- If it was unKnown before
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][40] = false;

                -- For UI
                GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:SetText ( GRM.FormatTimeStamp ( dayJoined .. " " .. GRM.L ( string.sub ( GRM.OrigL ( GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:GetText() ) , 1 , 3 ) ) .. " '" ..  string.sub ( yearJoined , 3 ) ) );
                
                -- Update timestamp to officer note.
                local noteDestination = "none";
                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][7] and ( CanEditOfficerNote() or CanEditPublicNote() ) then
                    for h = 1 , GRM.GetNumGuildies() do
                        local guildieName ,_,_,_,_,_, note , oNote = GetGuildRosterInfo( h );
                        if name == guildieName then
                            local noteDate = ( GRM.L ( "Joined:" ) .. " " .. GRM.FormatTimeStamp ( finalTStamp , false ) );
                            if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][20] and CanEditOfficerNote() and ( oNote == "" or oNote == nil ) then
                                noteDestination = "officer";
                                GuildRosterSetOfficerNote( h , noteDate );
                                GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:SetText ( noteDate );
                                GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetText ( noteDate );
                            elseif not GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][20] and CanEditPublicNote() and ( note == "" or note == nil ) then
                                noteDestination = "public";
                                GuildRosterSetPublicNote ( h , noteDate );
                                GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:SetText ( noteDate );
                                GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetText ( noteDate );
                            end                            
                            break;
                        end
                    end
                end

                -- Gotta update the event tracker date too!
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][22][1][1] = string.sub ( joinDate , 9 ); -- Remember, position 1 of the events tracker for anniversary tracking is always position 1 of the array, with date being pos 1 of table too.
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][22][1][2] = false;  -- Gotta Reset the "reported already" boolean!
                GRM.RemoveFromCalendarQue ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] , GRM.L ( "{name}'s Anniversary!" , GRM.SlimName ( name ) ) );
                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][12] == nil and not GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][41] then
                    rankButton = true;
                end

                -- Need player index to get this info.
                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][33] then
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][28] ~= nil then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][28] );                                     -- Zone
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][32] ) );              -- Time Passed
                    end
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Show();
                end

                -- Let's send the changes out as well!
                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] then
                    local syncRankFilter = GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15];
                    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][35] then
                        syncRankFilter = GuildControlGetNumRanks() - 1;
                    end
                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_G.PatchDayString .. "?GRM_JD?" .. syncRankFilter .. "?" .. name .. "?" .. joinDate .. "?" .. finalTStamp .. "?" .. finalEpochStamp .. "?" .. tostring ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][35][2] ) .. "?" .. noteDestination , "SLASH_CMD_GUILD");
                end
                break;
            end
        end

        GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButton:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:Show();
        if rankButton then
            GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Show();
        else
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Show();
        end
        GRM_G.pause = false;
        -- Update the Audit Frames!
        if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
            GRM.RefreshAuditFrames( GRM_G.AuditSortType );
        end
    end
end

-- Method:          GRM.SyncJoinDatesOnAllAlts()
-- What it Does:    Tales the player name and makes ALL of their alts share the same timestamp on joining.
-- Purpose:         Ease for the addon user to be able to sync the join dates among all alts rather than have to manually do them 1 at a time.6
GRM.SyncJoinDatesOnAllAlts = function ( playerName )
    local roster = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    for i = 2 , #roster do
        if roster[i][1] == playerName then
            -- now, let's check the alt info.
            local finalTStamp = roster[i][2];
            local finalTStampEpoch = roster[i][3];
            local syncEpochStamp = time();
            local joinDate = "Joined: " .. string.sub ( finalTStamp , 1 , string.find ( finalTStamp , "'" ) + 2 );

            -- Let's cycle through the alts now.
            for j = 1 , #roster[i][11] do
                -- Now, need to match the alt to the real database
                for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                    -- Alt is found!
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] == roster[i][11][j][1] then

                        -- 
                        
                        -- Let's match the values now...
                        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][20][ #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][20] ] ~= nil or #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][20] > 0 then
                            -- Removing old date
                            table.remove ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][20] , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][20] );
                            table.remove ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][21] , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][21] );
                        end
                        -- Adding the new stamps
                        table.insert( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][20] , finalTStamp );      -- oldJoinDate
                        table.insert( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][21] , finalTStampEpoch ) ;    -- oldJoinDateMeta
                        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][2] = finalTStamp;
                        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][3] = finalTStampEpoch;

                        -- For sync timestamp checking...
                        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][35][1] = finalTStamp;
                        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][35][2] = syncEpochStamp;

                        -- If it was unKnown before
                        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][40] = false;

                        -- Let's set those officer/public notes as well!
                        local noteDestination = "none";
                        if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][7] and ( CanEditOfficerNote() or CanEditPublicNote() ) then
                            for h = 1 , GRM.GetNumGuildies() do
                                local guildieName ,_,_,_,_,_, note , oNote = GetGuildRosterInfo( h );
                                if roster[i][11][j][1] == guildieName then
                                    local noteDate = ( GRM.L ( "Joined:" ) .. " " .. GRM.FormatTimeStamp ( finalTStamp , false ) );
                                    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][20] and CanEditOfficerNote() and ( oNote == "" or oNote == nil ) then
                                        noteDestination = "officer";
                                        GuildRosterSetOfficerNote( h , noteDate );
                                    elseif not GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][20] and CanEditPublicNote() and ( note == "" or note == nil ) then
                                        noteDestination = "public";
                                        GuildRosterSetPublicNote ( h , noteDate );
                                    end                            
                                    break;
                                end
                            end
                        end
                        
                        -- Gotta update the event tracker date too!
                        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][22][1][1] = string.sub ( joinDate , 9 ); -- Remember, position 1 of the events tracker for anniversary tracking is always position 1 of the array, with date being pos 1 of table too.
                        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][22][1][2] = false;  -- Gotta Reset the "reported already" boolean!
                        -- Update the Calendar Que since anniversary dates might be changed as a result
                        GRM.RemoveFromCalendarQue ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] , GRM.L ( "{name}'s Anniversary!" , GRM.SlimName ( playerName ) ) );

                        -- To Avoid the spam, we are going to treat this like a SYNC message
                        -- Let's send the changes out as well!
                        
                        if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] then
                            local syncRankFilter = GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15];
                            if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][35] then
                                syncRankFilter = GuildControlGetNumRanks() - 1;
                            end
                            GRMsync.SendMessage ( "GRM_SYNC" , GRM_G.PatchDayString .. "?GRM_JDSYNCUP?" .. GRM_G.addonPlayerName .. "?" .. syncRankFilter .. "?" .. roster[i][11][j][1] .. "?" .. joinDate .. "?" .. finalTStamp .. "?" .. finalTStampEpoch .. "?" .. tostring ( syncEpochStamp ) .. "?" .. noteDestination , "SLASH_CMD_GUILD");
                        end
                        break;

                    end
                end
            end
            break;        
        end
    end

    GRM_G.pause = false;
    -- Update the Audit Frames!
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
        GRM.RefreshAuditFrames( GRM_G.AuditSortType );
    end

end

-- Method:          GRM.SyncJoinDateUsingEarliest()
-- What it Does:    Syncs the join date of the grouping of alts to all be the same as the alt with the earliest join date
-- Purpose:         For join date syncing and time-saving for the player
GRM.SyncJoinDateUsingEarliest = function()
    GRM.SyncJoinDatesOnAllAlts ( GRM.GetAltWithOldestJoinDate ( GRM_G.currentName )[1] );
end

-- Method:          GRM.SyncJoinDateUsingMain()
-- What it Does:    Syncs the join date of the grouping of alts to all be the same as the alt with the player's main
-- Purpose:         For join date syncing and time-saving for the player
GRM.SyncJoinDateUsingMain = function()
    GRM.SyncJoinDatesOnAllAlts ( GRM.GetPlayerMain ( GRM_G.currentName ) );
end

-- Method:          GRM.SyncJoinDateUsingMain()
-- What it Does:    Syncs the join date of the grouping of alts to all be the same as the alt with the currently selected player on the roster
-- Purpose:         For join date syncing and time-saving for the player
GRM.SyncJoinDateUsingCurrentSelected = function()
    GRM.SyncJoinDatesOnAllAlts ( GRM_G.currentName );
end

-- Method:          GRM.GetPlayerMain ( string )
-- What it Does:    Returns the full player of the toon's main, or himself if he is main, or nil if no main.
-- Purpose:         Useful lookup for many purposes...
GRM.GetPlayerMain = function ( playerName )
    local roster = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    local result = playerName;
    for i = 2 , #roster do
        if roster[i][1] == playerName then
            -- if isMain or the player has no alts
            if roster[i][10] then
                break;
            elseif #roster[i][11] == 0 then
                result = nil;
                break;
            elseif #roster[i][11] > 0 then
                local isFound = false
                for j = 1 , #roster[i][11] do
                    if roster[i][11][j][5] then
                        result = roster[i][11][j][1];
                        isFound = true;
                        break;
                    end
                end
                if not isFound then
                    result = nil;
                end
            end
            break;
        end
    end
    return result;
end

-- Method:          GRM.GetAltWithOldestJoinDate ( string )
-- What it Does:    Returns the name of the player with the oldest join date in his grouping of main/alts
-- Purpose:         When syncing join dates among a grouping of alts, it would be nice to have an option to sync to the oldest join date.
GRM.GetAltWithOldestJoinDate = function ( playerName )
    local roster = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    local oldestPlayer = { playerName , 0 };
    local oldestJoinDateString = "";
    for i = 2 , #roster do
        if roster[i][1] == playerName then
            oldestPlayer[2] = roster[i][3];
            oldestJoinDateString = roster[i][2];
            -- if isMain or the player has no alts
            if #roster[i][11] == 0 then
                break;
            else
                -- Cycle through each alt...
                for j = 1 , #roster[i][11] do
                    for r = 2 , #roster do
                        if roster[i][11][j][1] == roster[r][1] then
                            if roster[r][3] < oldestPlayer[2] then
                                oldestPlayer = { roster[r][1] , roster[r][3] };
                                oldestJoinDateString = roster[r][2];
                            end
                            break;
                        end
                    end
                end
            end
            break;
        end
    end
    oldestPlayer[2] = oldestJoinDateString;
    return oldestPlayer;
end

-- Method:          GRM.IsAltJoinDatesSynced()
-- What it Does:    Returns true if the player has already sync'd all of the alt data.
-- Purpose:         Quality of Life... no need to ask the player to sync alt data if already sync'd
GRM.IsAltJoinDatesSynced = function ( playerName )
    local roster = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    local result = false;
    for i = 2 , #roster do
        if roster[i][1] == playerName then
            -- if isMain or the player has no alts
            if #roster[i][11] == 0 or #roster[i][20] == 0 then
                break;
            else
                -- Cycle through each alt...
                local isNotSync = false;
                for j = 1 , #roster[i][11] do
                    for r = 2 , #roster do
                        if roster[i][11][j][1] == roster[r][1] then
                            if #roster[r][20] == 0 or ( #roster[r][20] > 0 and roster[r][2] ~= roster[i][2] ) then
                                isNotSync = true;
                            end
                            break;
                        end
                    end
                    if isNotSync then
                        break;
                    end
                end
                if not isNotSync then
                    result = true;
                end
            end
            break;
        end
    end
    return result;
end

-- Method:          GRM.PlayerOrAltHasJD ( string )
-- What it Does:    Returns true if the player or any of his alts has the join date set... unknown counts as NOT set
-- Purpose:         On the mouseover of the join date, it would not be useful to give the option to sync join dates if not at least 1 alt in the group has the JD set
--                  In other words, it is about a good user experience and not giving them options that are unnecessary and useless...
-- NOTE:            Note, if the player has NO alts... it will return as false.
GRM.PlayerOrAltHasJD = function ( playerName )
    local result = false
    local roster = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    for j = 2 , #roster do  -- Scanning through all entries
        if roster[j][1] == playerName then
            if #roster[j][11] > 0 then     -- The player needs to have at least one alt.
                if #roster[j][20] > 0 then       -- Player Has a join date!
                    result = true;
                else
                    -- player does not have a JD... let's check if any of the alts do.
                    for i = 1 , #roster[j][11] do       -- cycle through the alts
                        for r = 2 , #roster do          -- cycle through the roster to match the alts.
                            if roster[r][1] == roster[j][11][i][1] then
                                if #roster[r][20] > 0 then
                                    result = true;
                                end
                                break;
                            end
                            if result then
                                break;
                            end
                        end
                    end
                end
            end
            break;
        end
    end
    return result;
end

-- Method:          GRM.PlayerHasJoinDate ( string )
-- What it Does:    Returns true if the current selected player has a listed Join Date, with the given JoinDate
-- Purpose:         For the Join Date selection, this will let us know if an option to sync to the selected player's join date should be given.
GRM.PlayerHasJoinDate = function ( playerName )
    local result = { false , "" };
    local roster = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ];
    for j = 2 , #roster do  -- Scanning through all entries
        if roster[j][1] == playerName then
            if #roster[j][20] > 0 then       -- Player Has a join date!
                result = { true , roster[j][2] };
            end
            break;
        end
    end
    return result;
end

-- Method:          GRM.SetPromoDate()
-- What it Does:    Set's the date the player was promoted to the current rank
-- Purpose:         Date tracking and control of rank promotions.
GRM.SetPromoDate = function ()
    local name = GRM_G.currentName;
    local dayJoined = tonumber ( GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected.GRM_DayText:GetText() );
    local yearJoined = tonumber ( GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected.GRM_YearText:GetText() );
    local IsLeapYearSelected = GRM.IsLeapYear ( yearJoined );

    if GRM.IsValidSubmitDate ( dayJoined , monthsFullnameEnum [ GRM.OrigL ( GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:GetText() ) ] , yearJoined, IsLeapYearSelected ) then

        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] == name then
                local promotionDate = ( "Promoted: " .. dayJoined .. " " ..  string.sub ( GRM.OrigL ( GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:GetText() ) , 1 , 3 ) .. " '" ..  string.sub ( yearJoined , 3 ) );
                -- Promo Save Data
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][12] = string.sub ( promotionDate , 11 );
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][25][#GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][25]][2] = string.sub ( promotionDate , 11 );
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][13] = GRM.TimeStampToEpoch ( promotionDate , true );
                
                -- For SYNC
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][36][1] = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][12];
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][36][2] = time();
                
                -- If player had it set to "unknown before"
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][41] = false;
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:SetText ( GRM.L ( "Promoted:" ) .. " " .. GRM.FormatTimeStamp ( dayJoined .. " " .. GRM.L ( string.sub ( GRM.OrigL ( GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:GetText() ) , 1 , 3 ) ) .. " '" .. string.sub ( yearJoined , 3 ) ) );

                -- Need player index to get this info.
                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][33] then
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][28] ~= nil then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][28] );                                     -- Zone
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][32] ) );              -- Time Passed
                    end
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Show();
                end

                -- Send the details out for others to pickup!
                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] then
                    local syncRankFilter = GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15];
                    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][35] then
                        syncRankFilter = GuildControlGetNumRanks() - 1;
                    end
                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_G.PatchDayString .. "?GRM_PD?" .. syncRankFilter .. "?" .. name .. "?" .. promotionDate .. "?" .. tostring( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][36][2] ) , "SLASH_CMD_GUILD");
                end

                break;
            end
        end

        GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButton:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:Hide();
        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Show();
        GRM_G.pause = false;
        -- Update Audit Frames.
        if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
            GRM.RefreshAuditFrames( GRM_G.AuditSortType );
        end
    end
end

-- Method:          GRM.SetAllIncompleteJoinUnknown()
-- What it Does:    Sets the join date of every player in the guild who does not have it yet set as "unknown"
-- Purpose:         More just quality of life information and UI feature. Useful than manually going to them all to set as unknown...
GRM.SetAllIncompleteJoinUnknown = function()
    if not ( GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:GetText() == GRM.L ( "All Complete" ) ) then
        if time() - GRM_G.buttonTimer1 >= 2 then
            if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:GetText() == GRM.L ( "Set Incomplete to Unknown" ) then
                -- Ok, let's go through ALL guildies and clear it!
                for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                    -- if not "unknown" already, and if it doesn't have an established join date
                    if not GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][40] and #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][20] == 0 then
                        GRM.ClearJoinDateHistory ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] , true );
                        GRM.DateSubmitCancelResetLogic( true , "join" , true , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] );
                    elseif GRM_UI.GRM_MemberDetailMetaData:IsVisible() and GRM_G.currentName == GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] then
                        GRM_G.pause = false;
                        GRM.ClearAllFrames( true );
                        GRM.PopulateMemberDetails ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] );
                        GRM_UI.GRM_MemberDetailMetaData:Show();
                        CommunitiesFrame.GuildMemberDetailFrame:Hide();
                        GRM_G.pause = true;
                    end
                end
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:SetText ( GRM.L ( "Clear All Unknown" ) );
            else
                for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                    -- if not "unknown" already, and if it doesn't have an established join date
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][40] then
                        GRM.ClearJoinDateHistory ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] , false );
                        GRM.DateSubmitCancelResetLogic( false , "join" , true , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] );
                    elseif GRM_UI.GRM_MemberDetailMetaData:IsVisible() and GRM_G.currentName == GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] then
                        GRM_G.pause = false;
                        GRM.ClearAllFrames( true );
                        GRM.PopulateMemberDetails ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] );
                        GRM_UI.GRM_MemberDetailMetaData:Show();
                        CommunitiesFrame.GuildMemberDetailFrame:Hide();
                        GRM_G.pause = true;
                    end
                end
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:SetText ( GRM.L ( "Set Incomplete to Unknown" ) );
            end
            GRM.RefreshAuditFrames( GRM_G.AuditSortType );
            GRM_G.buttonTimer1 = time();
        else
            GRM.Report ( GRM.L ( "Please Wait {num} more Seconds" , nil , nil , math.floor ( 2 - ( time()-GRM_G.buttonTimer1 ) ) ) );
        end
    end
end

-- Method:          GRM.SetAllIncompletePromoUnknown()
-- What it Does:    Sets the promo date of every player in the guild who does not have it yet set to an unknown value
-- Purpose:         More just quality of life information and UI feature. Useful than manually going to them all...
GRM.SetAllIncompletePromoUnknown = function()
    if not ( GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:GetText() == GRM.L ( "All Complete" ) ) then
        if time() - GRM_G.buttonTimer2 >= 2 then
            if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:GetText() == GRM.L ( "Set Incomplete to Unknown" ) then
                for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                    -- if not "unknown" already, and if it doesn't have an established join date
                    if not GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][41] and GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][12] == nil then
                        GRM.ClearPromoDateHistory ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] , true );
                        GRM.DateSubmitCancelResetLogic( true , "promo" , true , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] );
                    end
                end
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:SetText ( GRM.L ( "Clear All Unknown" ) );
            else
                for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][41] then
                        GRM.ClearPromoDateHistory ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] , false );
                        GRM.DateSubmitCancelResetLogic( false , "promo" , true , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] );
                    end
                end
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:SetText ( GRM.L ( "Set Incomplete to Unknown" ) );
            end
            GRM.RefreshAuditFrames( GRM_G.AuditSortType );
            GRM_G.buttonTimer2 = time();
        else
            GRM.Report ( GRM.L ( "Please Wait {num} more Seconds" , nil , nil , math.floor ( 2 - ( time()-GRM_G.buttonTimer2 ) ) ) );
        end
    end
end

-- Method:          GRM.DateSubmitCancelResetLogic( boolean , string , boolean , string )
-- What it Does:    Resets the logic on what occurs with the cancel button, since it will have multiple uses.
-- Purpose:         Resource efficiency. No need to make new buttons for everything! This reuses the button, just resets the click logic in join date submit cancel event.
GRM.DateSubmitCancelResetLogic = function( isUnknown , date , isAudit , playerName )
    local buttonText = GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButtonTxt:GetText();
    local joinDateText = GRM.L ( "Set Join Date" );
    local promoDateText = GRM.L ( "Set Promo Date" );
    local editDateText = GRM.L ( "Edit Promo Date" );
    local editJoinText = GRM.L ( "Edit Join Date" );
    local name = GRM_G.currentName;
    local showJoinText = false;

    -- For the audit
    if isAudit then
        if date == "join" then
            buttonText = joinDateText;
        elseif date == "promo" then
            buttonText = promoDateText;
        end
    end

    -- To save values properly.
    if isAudit and playerName ~= nil then
        name = playerName;
    end
    
    -- Need player index to get this info.
    for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] == name then

            if name == GRM_G.currentName then
                if ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][41] or GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][12] ~= nil ) then
                    GRM_G.rankDateSet = true;
                end
                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][40] or #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][20] ~= 0 then
                    showJoinText = true;
                end
            end
                
            if isUnknown then
                if date == "join" then
                    GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][40] = true;
                elseif date == "promo" then
                    GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][41] = true
                    if name == GRM_G.currentName then
                        GRM_G.rankDateSet = true;
                    end
                end
            end

            if not isAudit or ( GRM_UI.GRM_MemberDetailMetaData:IsVisible() and GRM_G.currentName == playerName ) then
                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][33] then
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][28] ~= nil then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][28] );                                     -- Zone
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][32] ) );              -- Time Passed
                    end
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Show();
                end
            end
            break;
        end
    end

    -- Determine which information needs to repopulate.
    if GRM_UI.GRM_MemberDetailMetaData:IsVisible() and name == GRM_G.currentName then
        if joinDateText == buttonText or editJoinText == buttonText then
            if isUnknown and date == "join" then
                GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:SetText( GRM.L ( "Unknown" ) );
                GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:Show();
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton:Hide();
            else
                if buttonText == editJoinText then
                    GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:Show();
                else
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton:Show();
                end
            end
            
        elseif buttonText == promoDateText then
            if not isUnknown then
                GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Show();
            elseif date == "promo" then
                GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Hide();
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:SetText ( GRM.L ( "Promoted:" ) .. " " .. GRM.L ( "Unknown" ) );
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Show();
            end

            if name == GRM_G.currentName then
                if showJoinText then
                    GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:Show();
                else
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton:Show();
                end
            end
            
        elseif buttonText == editDateText then
            if isUnknown and date == "promo" then
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:SetText ( GRM.L ( "Promoted:" ) .. " " .. GRM.L ( "Unknown" ) );
            end
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Show();
        end

        --RANK PROMO DATE
        
        if not GRM_G.rankDateSet then      --- Promotion has never been recorded!
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Hide();
            GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Show();
        else
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Show();
        end

        if not isAudit then
            GRM_G.pause = false;
        end
    end

    -- Close the rest
    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButton:Hide();
end

-- Method:          GRM.SetDateSelectFrame( string , frameObject, string )
-- What it Does:    On Clicking the "Set Join Date" button this logic presents itself
-- Purpose:         Handle the event to modify when a player joined the guild. This is useful for anniversary date tracking.
--                  It is also necessary because upon starting the addon, it is unknown a person's true join date. This allows the gleader to set a general join date.
GRM.SetDateSelectFrame = function ( buttonName )
    local _ , month , day , currentYear = GRM.CalendarGetDate();
    local months = { "January" , "February" , "March" , "April" , "May" , "June" , "July" , "August" , "September" , "October" , "November" , "December" };
    local joinDateText = GRM.L ( "Set Join Date" );
    local promoDateText = GRM.L ( "Set Promo Date" );

    -- Month
    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:SetText ( GRM.L ( months [ month ] ) );
    GRM_G.monthIndex = month;
    
    -- Year
    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected.GRM_YearText:SetText ( currentYear );
    GRM_G.yearIndex = currentYear;
    
    -- Initialize the day choice now.
    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected.GRM_DayText:SetText ( day );
    GRM_G.dayIndex = day;
    
    if buttonName == "PromoRank" then
        GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButtonTxt:SetText ( promoDateText );
        GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:SetScript("OnClick" , function( _ , button )
            if button == "LeftButton" and not GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenu:IsVisible() then
                GRM.SetPromoDate();
            end
        end);
    elseif buttonName == "JoinDate" then
        GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButtonTxt:SetText ( joinDateText );
        GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:SetScript("OnClick" , function( _ , button )
            if button == "LeftButton" then
                GRM.SetJoinDate();
            end
        end);
    end

    -- Show all Frames
    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected:Show();
    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected:Show();
    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected:Show();
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:Show();
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButton:Show();
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
        -- Save the data!
        local timestamp = GRM.GetTimestamp();
        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] == GRM_G.currentName then
                local formerRankName = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][4];                               -- For the reporting string!

                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][4] = newRank                                         -- rank name
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][5] = newRankIndex;                                           -- rank index!

                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][12] = string.sub ( timestamp , 1 , string.find ( timestamp , "'" ) + 2 ) -- Time stamping rank change
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][13] = time();

                -- For SYNC
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][36][1] = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][12];
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][36][2] = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][13];
                table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][25] , { GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][4] , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][12] , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][13] } ); -- New rank, date, metatimestamp
                
                -- Let's update it on the fly!
                local simpleName = GRM.GetStringClassColorByName ( GRM_G.currentName ) .. GRM.SlimName ( GRM_G.currentName ) .. "|r";
                local playerSimpleName = GRM.GetStringClassColorByName ( GRM_G.addonPlayerName ) .. GRM.SlimName ( GRM_G.addonPlayerName ) .. "|r";
                local logReport = "";
                -- Promotion Obtained
                if newRankIndex < formerRankIndex and CanGuildPromote() then
                    logReport =  GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} PROMOTED {name2} from {custom1} to {custom2}" , playerSimpleName , simpleName , nil , formerRankName , newRank );
                    -- Cleans up reporting
                    GRM.LiveChangesCheck ( 1 , logReport );
                    -- report the changes!
                    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][4] then
                        GRM.PrintLog ( 1 , logReport , false );
                    end
                    GRM.AddLog ( 1 , logReport );

                    -- And one more check in case of the 1ms chance this occurse.
                    GRM.LiveChangesCheck ( 1 , logReport );

                -- Demotion Obtained
                elseif newRankIndex > formerRankIndex and CanGuildDemote() then
                    logReport = GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} DEMOTED {name2} from {custom1} to {custom2}" , playerSimpleName , simpleName , nil , formerRankName , newRank );

                    -- Live cleanup of the scan
                    GRM.LiveChangesCheck ( 2 , logReport );
                    -- reporting the changes!
                    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][5] then
                        GRM.PrintLog ( 2 , logReport , false );                          
                    end
                    GRM.AddLog ( 2 , logReport );

                    -- And one more check in case of the 1ms chance this occurse.
                    GRM.LiveChangesCheck ( 2 , logReport );
                end
                if GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
                    GRM.PopulateMemberDetails ( GRM_G.currentName );
                end
                GRM.BuildLogComplete()
                break;
            end
        end

        -- Update the player index if it is the player themselves that received the change in rank.
        if GRM_G.currentName == GRM_G.addonPlayerName then
            GRM_G.playerIndex = newRankIndex;
        end

        -- Now, let's make the changes immediate for the button date.
        if GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:IsVisible() then
            GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Hide();
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:SetText ( GRM.L ( "Promoted:" ) .. " " .. GRM.Trim ( string.sub ( timestamp , 1 , 10 ) ) );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Show();
        end
    end
    C_Timer.After ( 0.4 , function()
        GRM_G.CurrentRank = GuildMemberRankDropdownText:GetText();
    end);
end

-- Method:          GRM.RemoveRosterButtonHighlights()
-- What it Does:    Removes the button highlight from the click action
-- Purpose:         Purely aesthetics.
GRM.RemoveRosterButtonHighlights = function ( button )
    for i = 1 , #GRM_G.RosterButtons do
        if GRM_G.RosterButtons[i] ~= button then         -- It's ok if button == nil - It will just unlock ALL highlights.
            GRM_G.RosterButtons[i]:UnlockHighlight();
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
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu.Buttons = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu.Buttons do
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i][1]:Hide();
    end
    
    local i = 1;
    for count = 1 , GuildControlGetNumRanks() do
        if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "rankIndex" .. i , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "rankIndexText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local RankButtons = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i][1];
        local RankButtonsText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i][2];
        RankButtons:SetWidth ( 110 );
        RankButtons:SetHeight ( 11 );
        RankButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        RankButtonsText:SetText ( GuildControlGetRankName ( count ) );
        RankButtonsText:SetWidth ( 110 );
        RankButtonsText:SetWordWrap ( false );
        RankButtonsText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 12 );
        RankButtonsText:SetPoint ( "CENTER" , RankButtons );
        RankButtonsText:SetJustifyH ( "CENTER" );
        RankButtonsText:SetTextColor ( 0 , 0.8 , 1 , 1 );

        if i == 1 then
            RankButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu , 0 , -7 );
            height = height + RankButtons:GetHeight();
        else
            RankButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + RankButtons:GetHeight() + buffer;
        end

        RankButtons:SetScript ( "OnClick" , function( self , button ) 
            if button == "LeftButton" then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelectedText:SetText ( RankButtonsText:GetText() );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelected:Show();
                GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] = GRM.GetRankIndex ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelectedText:GetText() , self );

                local banListTooLow = false;
                -- ban list check
                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] < GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][22] then
                    banListTooLow = true;
                    GRM.Report ( GRM.L ( "Warning! Ban List rank threshold is below the overall sync rank. Changing from \"{name}\" to \"{name2}\"" , GuildControlGetRankName ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][22] + 1 ) ,  RankButtonsText:GetText() ) );

                    -- Saving the data
                    GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][22] = GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15];
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelectedText:SetText ( RankButtonsText:GetText() );
                end

                -- Custom note check too
                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] < GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][49] then
                    if banListTooLow then
                        GRM.Report ( GRM.L ( "Custom Note Default Rank is Also Being Set to \"{name}\"" , RankButtonsText:GetText() ) );
                    else
                        GRM.Report ( GRM.L ( "Warning! Custom Note rank threshold is below the overall sync rank. Changing default from \"{name}\" to \"{name2}\"" , GuildControlGetRankName ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][49] + 1 ) ,  RankButtonsText:GetText() ) );
                    end

                    -- Saving the data
                    GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][49] = GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15];
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomSelectedText:SetText ( RankButtonsText:GetText() );

                    GRM.ResetAllUnmodifiedDefaulCustomNoteFilters();

                    if GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
                        for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == GRM_G.currentName then
                                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][4] ~= GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][49] then 
                                    -- if the player has configured this, then ignore it, let it stand, otherwise, update it to match.
                                    if not GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][5] then
                                        GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteRankDropDownSelected.GRM_CustomDropDownSelectedText:SetText ( GuildControlGetRankName ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][49] + 1 ) );
                                    end
                                end
                                break;
                            end
                        end
                    end
                end
                
                -- Retrigger active addon users... Very important to know permissions
                if not GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:IsVisible() then
                    GRM.RegisterGuildAddonUsersRefresh();
                end

                --Let's re-initiate syncing!
                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] and not GRMsyncGlobals.currentlySyncing and GRM_G.HasAccessToGuildChat then
                    GRMsync.TriggerFullReset();
                    -- Now, let's add a brief delay, 3 seconds, to trigger sync again
                    C_Timer.After ( 3 , GRMsync.Initialize );
                end
                -- Determine if player has access to guild chat or is in restricted chat rank
                GRM_G.HasAccessToGuildChat = false;
                GRM_G.HasAccessToOfficerChat = false;
                GRM.RegisterGuildChatPermission();
                
            end
        end); 
        RankButtons:Show();
        i = i + 1;
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.PopulateBanListOptionsDropDown ()
-- What it Does:    Adds all the guild ranks to the drop down menu for ban changes
-- Purpose:         UI Feature in options - greater control to keep sync of ban list to officers only, whilst allowing great sync with all guildies.
GRM.PopulateBanListOptionsDropDown = function ()
    -- populating the frames!
    local buffer = 3;
    local height = 0;
    local color1 = { 1 , 0 , 0 };
    local color2 = { 0 , 0.8 , 1 };

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu.Buttons = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu.Buttons do
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu.Buttons[i][1]:Hide();
    end
    
    local i = 1;
    for count = 1 , GuildControlGetNumRanks() do
        if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "rankIndex" .. i , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "rankIndexText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local RankButtons = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu.Buttons[i][1];
        local RankButtonsText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu.Buttons[i][2];
        RankButtons:SetWidth ( 110 );
        RankButtons:SetHeight ( 11 );
        RankButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        RankButtonsText:SetText ( GuildControlGetRankName ( count ) );
        RankButtonsText:SetWidth ( 110 );
        RankButtonsText:SetWordWrap ( false );
        RankButtonsText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 12 );
        RankButtonsText:SetPoint ( "CENTER" , RankButtons );
        RankButtonsText:SetJustifyH ( "CENTER" );
        if i - 1 <= GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] then
            RankButtonsText:SetTextColor ( color2[1] , color2[2] , color2[3] , 1 );
        else
            RankButtonsText:SetTextColor ( color1[1] , color1[2] , color1[3] , 1 );
        end

        if i == 1 then
            RankButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu , 0 , -7 );
            height = height + RankButtons:GetHeight();
        else
            RankButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + RankButtons:GetHeight() + buffer;
        end

        RankButtons:SetScript ( "OnClick" , function( self , button ) 
            if button == "LeftButton" then
                
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected:Show();
                local rankIndex = GRM.GetRankIndex ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelectedText:GetText() , self );

                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] < rankIndex then
                    GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][22] = GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15];
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelectedText:SetText ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelectedText:GetText() );
                    GRM.Report ( GRM.L ( "Warning! Unable to select a Ban List rank below \"{name}\"" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelectedText:GetText() )  .. "\n" .. GRM.L ( "Setting to match core filter rank" ) );
                else
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelectedText:SetText ( RankButtonsText:GetText() );
                    GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][22] = rankIndex;
                end

                -- Re-trigger addon users permissions
                if not GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:IsVisible() then
                    GRM.RegisterGuildAddonUsersRefresh();
                end

                --Let's re-initiate syncing!
                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][21] and not GRMsyncGlobals.currentlySyncing and GRM_G.HasAccessToGuildChat then
                    GRMsync.TriggerFullReset();
                    -- Now, let's add a brief delay, 3 seconds, to trigger sync again
                    C_Timer.After ( 3 , GRMsync.Initialize );
                end
            end
        end);
        RankButtons:Show();
        i = i + 1;
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.PopulateDefaultDropDownRankMenu()
-- What it Does:    Adds all the guild ranks to the drop down menu for custom default
-- Purpose:         UI Feature in options - greater control to keep custom note sync display on each character neat.
GRM.PopulateDefaultDropDownRankMenu = function ()
    -- populating the frames!
    local buffer = 3;
    local height = 0;
    local color1 = { 1 , 0 , 0 };
    local color2 = { 0 , 0.8 , 1 };
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomRankDropDownMenu.Buttons = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomRankDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomRankDropDownMenu.Buttons do
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomRankDropDownMenu.Buttons[i][1]:Hide();
    end
    
    local i = 1;
    for count = 1 , GuildControlGetNumRanks() do
        if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomRankDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "rankIndex" .. i , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomRankDropDownMenu );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomRankDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "rankIndexText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local RankButtons = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomRankDropDownMenu.Buttons[i][1];
        local RankButtonsText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomRankDropDownMenu.Buttons[i][2];
        RankButtons:SetWidth ( 110 );
        RankButtons:SetHeight ( 11 );
        RankButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        RankButtonsText:SetText ( GuildControlGetRankName ( count ) );
        RankButtonsText:SetWidth ( 110 );
        RankButtonsText:SetWordWrap ( false );
        RankButtonsText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 12 );
        RankButtonsText:SetPoint ( "CENTER" , RankButtons );
        RankButtonsText:SetJustifyH ( "CENTER" );
        if i - 1 <= GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] then
            RankButtonsText:SetTextColor ( color2[1] , color2[2] , color2[3] , 1 );
        else
            RankButtonsText:SetTextColor ( color1[1] , color1[2] , color1[3] , 1 );
        end

        if i == 1 then
            RankButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomRankDropDownMenu , 0 , -7 );
            height = height + RankButtons:GetHeight();
        else
            RankButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomRankDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + RankButtons:GetHeight() + buffer;
        end

        RankButtons:SetScript ( "OnClick" , function( self , button ) 
            if button == "LeftButton" then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomRankDropDownMenu:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomSelected:Show();
                local rankIndex = GRM.GetRankIndex ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomSelectedText:GetText() , self );

                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] < rankIndex then
                    GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][49] = GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15];
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomSelectedText:SetText ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelectedText:GetText() );
                    GRM.Report ( GRM.L ( "Warning! Custom Note rank filter must be below \"{name}\"" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelectedText:GetText() )  .. "\n" .. GRM.L ( "Setting to match core filter rank" ) );
                else
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomSelectedText:SetText ( RankButtonsText:GetText() );
                    GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][49] = rankIndex;
                end

                GRM.ResetAllUnmodifiedDefaulCustomNoteFilters();

                if GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
                    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == GRM_G.currentName then
                            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][4] ~= GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][49] then 
                                -- if the player has configured this, then ignore it, let it stand, otherwise, update it to match.
                                if not GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][5] then
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteRankDropDownSelected.GRM_CustomDropDownSelectedText:SetText ( GuildControlGetRankName ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][49] + 1 ) );
                                end
                            end
                            break;
                        end
                    end
                end
            end
        end);
        RankButtons:Show();
        i = i + 1;
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomRankDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.ResetAllUnmodifiedDefaulCustomNoteFilters()
-- What it Does:    Checks if the filter has ever been modified, and if it hasn't, then resets it to the default
-- Purpose:         Quality of life controls over the filters!
GRM.ResetAllUnmodifiedDefaulCustomNoteFilters = function ()
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if not GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][5] then
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][23][4] = GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][49];
        end
    end
end

-- Method:          GRM.CreateRankDropDownMenu ( frame , fontstring , frame , int , int , function() )
-- What it Does:    It creates a dropdown menu that has all of the current guild ranks, with highest rank in guild on top
-- Purpose:         To create a generic, reusable dropdown menu for rank creation
GRM.CreateRankDropDownMenu = function ( SelectedFrame , Menu , fontSize , buttonHeight , logic )
    -- populating the frames!
    local buffer = 3;
    local height = 0;
    Menu.Buttons = Menu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #Menu.Buttons do
        Menu.Buttons[i][1]:Hide();
    end
    
    local i = 1;
    for count = 1 , GuildControlGetNumRanks() do
        if not Menu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , Menu:GetName() .. "RankIndex_" .. i , Menu );
            Menu.Buttons[i] = { tempButton , tempButton:CreateFontString ( Menu:GetName() .. "RankIndexText_" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local RankButtons = Menu.Buttons[i][1];
        local RankButtonsText = Menu.Buttons[i][2];
        RankButtons:SetWidth ( SelectedFrame:GetWidth() - 20 );
        RankButtons:SetHeight ( buttonHeight );
        RankButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        RankButtonsText:SetText ( GuildControlGetRankName ( count ) );
        RankButtonsText:SetWidth ( SelectedFrame:GetWidth() - 20 );
        RankButtonsText:SetWordWrap ( false );
        RankButtonsText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + fontSize );
        RankButtonsText:SetPoint ( "CENTER" , RankButtons );
        RankButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            RankButtons:SetPoint ( "TOP" , Menu , 0 , -7 );
            height = height + RankButtons:GetHeight();
        else
            RankButtons:SetPoint ( "TOP" , Menu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + RankButtons:GetHeight() + buffer;
        end

        RankButtons:SetScript ( "OnClick" , function( self , button ) 
            if button == "LeftButton" then
                logic( self , RankButtonsText );
            end
        end);
        RankButtons:Show();
        i = i + 1;
    end
    Menu:SetHeight ( height + 15 );
end

-- Method:          GRM.PopulateClassDropDownMenu ()
-- What it Does:    Adds all the player CLASSES to the drop down menu
-- Purpose:         This is useful for player selection of the class when manually adding a player's info to the metadata, like adding someone to a ban list.
GRM.PopulateClassDropDownMenu = function()
    -- populating the frames!
    local buffer = 3;
    local height = 0;
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons or {};

    -- Resetting the buttons!
    for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons do
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons[i][1]:Hide();
    end
    
    for i = 1 , #AllClasses do
        if not GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "ClassButton" .. i , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "ClassButtonText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local ClassButtons = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons[i][1];
        local ClassButtonsText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons[i][2];
        ClassButtons:SetWidth ( 110 );
        ClassButtons:SetHeight ( 11 );
        ClassButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        ClassButtonsText:SetText ( GRM.L ( AllClasses[i] ) );
        local classCol = GRM.GetClassColorRGB ( string.upper ( AllClasses[i] ) );
        ClassButtonsText:SetTextColor ( classCol[1] , classCol[2] , classCol[3] , 1 );
        ClassButtonsText:SetWidth ( 110 );
        ClassButtonsText:SetWordWrap ( false );
        ClassButtonsText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 10 );
        ClassButtonsText:SetPoint ( "CENTER" , ClassButtons );
        ClassButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            ClassButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu , 0 , -7 );
            height = height + ClassButtons:GetHeight();
        else
            ClassButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + ClassButtons:GetHeight() + buffer;
        end

        ClassButtons:SetScript ( "OnClick" , function( self , button ) 
            if button == "LeftButton" then
                local parsedNumber = 0;
                local nameOfButton = self:GetName();
                for j = 1 , #nameOfButton do
                    if tonumber ( string.sub ( nameOfButton , j , j ) ) ~= nil then
                        -- NUM FOUND! Let's pull that number from the buttons and we'll know what class it is!
                        parsedNumber = tonumber ( string.sub ( nameOfButton , j ) );
                        break
                    end
                end
                local classColors = GRM.GetClassColorRGB ( string.upper ( AllClasses[parsedNumber] ) );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelectedText:SetText ( ClassButtonsText:GetText() );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelectedText:SetTextColor ( classColors[1] , classColors[2] , classColors[3] , 1 );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownClassSelected:Show();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanReasonEditBox:SetFocus();
                GRM_G.tempAddBanClass = string.upper ( AllClasses[parsedNumber] );
            end
        end);
        ClassButtons:Show();
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:SetHeight ( height + 15 );
end


-- Method:          GRM.PopulateMainTagDropdown()
-- What it Does:    Creates a dropdown menu including options to choose from for main tag formatting in guild chat
-- Purpose:         Options, options, options! Customization to make it pleasing for all players in the formatting.
GRM.PopulateMainTagDropdown = function()
    local buffer = 3;
    local height = 0;
    local tagChoices = { "<" .. GRM.L ( "M" ) .. ">" , "(" .. GRM.L ( "M" ) .. ")" , "<" .. GRM.L ( "Main" ) .. ">" , "(" .. GRM.L ( "Main" ) .. ")" };
    -- Initiate the buttons holder
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu.Buttons = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu.Buttons or {};

    for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu.Buttons do
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu.Buttons[i][1]:Hide();
    end

    for i = 1 , #tagChoices do
        if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "MainTagOption" .. i , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "MainTagText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local TagButton = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu.Buttons[i][1];
        local TagButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu.Buttons[i][2];
        TagButton:SetWidth ( 85 );
        TagButton:SetHeight ( 11 );
        TagButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        TagButtonText:SetText ( tagChoices[i] );
        TagButtonText:SetTextColor ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][46][1] , GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][46][2] , GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][46][3] , 1 );
        TagButtonText:SetWidth ( 85 );
        TagButtonText:SetWordWrap ( false );
        TagButtonText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 10 );
        TagButtonText:SetPoint ( "CENTER" , TagButton );
        TagButtonText:SetJustifyH ( "CENTER" );

        if i == 1 then
            TagButton:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu , 0 , -7 );
            height = height + TagButton:GetHeight();
        else
            TagButton:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + TagButton:GetHeight() + buffer;
        end

        TagButton:SetScript ( "OnClick" , function( self , button ) 
            if button == "LeftButton" then
                local parsedNumber = 0;
                local nameOfButton = self:GetName();
                for j = 1 , #nameOfButton do
                    if tonumber ( string.sub ( nameOfButton , j , j ) ) ~= nil then
                        -- NUM FOUND! Let's pull that number from the buttons and we'll know what class it is!
                        parsedNumber = tonumber ( string.sub ( nameOfButton , j ) );
                        break
                    end
                end
                GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][42] = parsedNumber;
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected.GRM_TagText:SetText ( TagButtonText:GetText() );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected.GRM_TagText:SetTextColor ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][46][1] , GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][46][2] , GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][46][3] , 1 );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected:Show();
            end
        end);
        TagButton:Show();
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatMenu:SetHeight ( height + 15 );
end


-- Method:          GRM.PopulateLanguageDropdown()
-- What it Does:    Populates a dropdown select menu with all of the available languages to choose from...
-- Purpose:         To give the player the option to manually select and change which language the addon is using.
GRM.PopulateLanguageDropdown = function()
    local buffer = 3;
    local height = 0;
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu.Buttons = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu.Buttons or {};

    for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu.Buttons do
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu.Buttons[i][1]:Hide();
    end

    for i = 1 , #GRML.Languages do
        if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "GRM_Language_" .. i , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "GRM_LanguageButtonText_" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local LangButton = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu.Buttons[i][1];
        local LangButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu.Buttons[i][2];
        LangButton:SetWidth ( 110 );
        LangButton:SetHeight ( 11 );
        LangButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        LangButtonText:SetText ( GRML.Languages[i] );
        LangButtonText:SetWidth ( 105 );
        LangButtonText:SetWordWrap ( false );
        LangButtonText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 10 );
        LangButtonText:SetPoint ( "CENTER" , LangButton );
        LangButtonText:SetJustifyH ( "CENTER" );

        if i == 1 then
            LangButton:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu , 0 , -7 );
            height = height + LangButton:GetHeight();
        else
            LangButton:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + LangButton:GetHeight() + buffer;
        end

        LangButton:SetScript ( "OnClick" , function( self , button ) 
            if button == "LeftButton" then
                local parsedNumber = 1;
                local nameOfButton = self:GetName();
                for j = 1 , #nameOfButton do
                    if tonumber ( string.sub ( nameOfButton , j , j ) ) ~= nil then
                        -- NUM FOUND! Let's pull that number from the buttons and we'll know what class it is!
                        parsedNumber = tonumber ( string.sub ( nameOfButton , j ) );
                        break
                    end
                end
                GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][43] = parsedNumber;
                GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][44] = GRML.GetFontChoiceIndex ( parsedNumber );
                GRML.SetNewLanguage( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][43] , false );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected.GRM_LanguageSelectedText:SetText ( LangButtonText:GetText() );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected.GRM_FontSelectedText:SetText ( GRML.FontNames[GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][44]] );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected.GRM_FontSelectedText:SetFont ( GRML.listOfFonts[GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][44]] , GRM_G.FontModifier + 11 );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected:Show();
                GRM_UI.ElvUIReset = true;
                GRM_UI.ElvUIReset2 = true;
                -- Check the language count!
                local count = GRML.GetNumberUntranslatedLines ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][43] );
                if GRM_G.Region == "enUS" then
                    count = count - 10;
                end
                if count > 0 and not GRML.TranslationStatusEnum[ GRML.Languages [ GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][43] ] ] then
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageCountText:SetText ( GRM.L ( "{num} phrases still need translation to {name}" , GRML.Languages[GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][43]] , nil , count ) );
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageCountText:Show();
                else
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageCountText:Hide();
                end

                if IsAddOnLoaded ( "AddOnSkins" ) then
                    GRM_UI.GRM_RosterChangeLogFrame:Hide();
                    GRM_UI.GRM_RosterChangeLogFrame:Show();
                    if GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
                        GRM_UI.GRM_MemberDetailMetaData:Hide();
                        GRM_G.pause = true;
                        GRM_UI.GRM_MemberDetailMetaData:Show();
                    end
                end

                GRM.Report ( GRM.L ( "Font has been Reset to DEFAULT." ) );
            end
        end);
        LangButton:Show();
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.PopulateFontDropdown()
-- What it Does:    Builds the font dropdown box
-- Purpose:         Give the user more customizability over the addon.
GRM.PopulateFontDropdown = function()
    local buffer = 3;
    local height = 0;
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu.Buttons = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu.Buttons or {};

    for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu.Buttons do
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu.Buttons[i][1]:Hide();
    end

    for i = 1 , #GRML.FontNames do
        if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "GRM_Font" .. i , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "GRM_FontButtonText_" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end

        local FontButton = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu.Buttons[i][1];
        local FontButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu.Buttons[i][2];
        local additionalModifier = 0;
        if i == 4 then                             -- China
            additionalModifier = 0.5;
        elseif i == 5 then                         -- Taiwan
            additionalModifier = 2;
        elseif i == 6 then                         -- Action Man
            additionalModifier = 1;
        elseif i == 7 then                         -- Ancient
            additionalModifier = 2;
        elseif i == 9 then                         -- Cardinal
            additionalModifier = 2;
        elseif i == 10 then                        -- Continuum
            additionalModifier = 1;
        elseif i == 11 then                        -- Espressway
            additionalModifier = 1;
        elseif i == 13 then                        -- PT Sans
            additionalModifier = 2;
        elseif i == 14 then                        -- Roboto
            additionalModifier = 1;
        end
        FontButton:SetWidth ( 110 );
        FontButton:SetHeight ( 11 );
        FontButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        FontButtonText:SetText ( GRML.FontNames[i] );
        FontButtonText:SetWidth ( 105 );
        FontButtonText:SetWordWrap ( false );
        FontButtonText:SetFont ( GRML.listOfFonts[i] , GRM_G.FontModifier + additionalModifier + 10 );
        FontButtonText:SetPoint ( "CENTER" , FontButton );
        FontButtonText:SetJustifyH ( "CENTER" );

        if i == 1 then
            FontButton:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu , 0 , -7 );
            height = height + FontButton:GetHeight();
        else
            FontButton:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + FontButton:GetHeight() + buffer;
        end

        FontButton:SetScript ( "OnClick" , function( self , button ) 
            if button == "LeftButton" then
                local parsedNumber = 1;
                local nameOfButton = self:GetName();
                for j = 1 , #nameOfButton do
                    if tonumber ( string.sub ( nameOfButton , j , j ) ) ~= nil then
                        -- NUM FOUND! Let's pull that number from the buttons and we'll know what class it is!
                        parsedNumber = tonumber ( string.sub ( nameOfButton , j ) );
                        break
                    end
                end
                GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][44] = parsedNumber;
                GRML.SetNewFont ( parsedNumber );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected.GRM_FontSelectedText:SetText ( FontButtonText:GetText() );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected.GRM_FontSelectedText:SetFont ( GRML.listOfFonts[parsedNumber] , GRM_G.FontModifier + 11 );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected:Show();

                -- Additional frame check...
                GRM_UI.ElvUIReset = true;
                GRM_UI.ElvUIReset2 = true;
                if IsAddOnLoaded ( "AddOnSkins" ) then
                    GRM_UI.GRM_RosterChangeLogFrame:Hide();
                    GRM_UI.GRM_RosterChangeLogFrame:Show();
                    if GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
                        GRM_UI.GRM_MemberDetailMetaData:Hide();
                        GRM_G.pause = true;
                        GRM_UI.GRM_MemberDetailMetaData:Show();
                    end
                end
            end
        end);
        FontButton:Show();
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.PopulateTimestampFormatDropDown()
-- What it Does:    Builds a dropdown menu displaying the various format options
-- Purpose:         To give the player the ability to adjust timestamp formats
GRM.PopulateTimestampFormatDropDown = function()
    local buffer = 4;
    local height = 0;
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelectedDropDownMenu.Buttons = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelectedDropDownMenu.Buttons or {};

    for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelectedDropDownMenu.Buttons do
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelectedDropDownMenu.Buttons[i][1]:Hide();
    end

    local _ , month , day , year = GRM.CalendarGetDate();
    local timestamp = day .. " " .. monthEnum2 [ tostring ( month ) ] .. " '" .. ( year - 2000 );
    local tempTimestampHolder = GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][51];

    for i = 1 , 15 do
        if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelectedDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "GRM_timeStampButton" .. i , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelectedDropDownMenu );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelectedDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "GRM_GRM_timeStampButton_Text" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end
        GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][51] = i;
        local timeStampButton = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelectedDropDownMenu.Buttons[i][1];
        local timeStampButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelectedDropDownMenu.Buttons[i][2];
        timeStampButton:SetWidth ( 110 );
        timeStampButton:SetHeight ( 11 );
        timeStampButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        timeStampButtonText:SetText ( GRM.FormatTimeStamp ( timestamp , false ) );
        timeStampButtonText:SetWidth ( 105 );
        timeStampButtonText:SetWordWrap ( false );
        timeStampButtonText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 11 );
        timeStampButtonText:SetPoint ( "CENTER" , timeStampButton , 5 , 0 );
        timeStampButtonText:SetJustifyH ( "LEFT" );

        if i == 1 then
            timeStampButton:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelectedDropDownMenu , 0 , -7 );
            height = height + timeStampButton:GetHeight();
        else
            timeStampButton:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelectedDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + timeStampButton:GetHeight() + buffer;
        end

        timeStampButton:SetScript ( "OnClick" , function( self , button ) 
            if button == "LeftButton" then
                local parsedNumber = 1;
                local nameOfButton = self:GetName();
                for j = 1 , #nameOfButton do
                    if tonumber ( string.sub ( nameOfButton , j , j ) ) ~= nil then
                        -- NUM FOUND! Let's pull that number from the buttons and we'll know what class it is!
                        parsedNumber = tonumber ( string.sub ( nameOfButton , j ) );
                        break
                    end
                end
                GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][51] = parsedNumber;
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelected.GRM_TimestampSelectedText:SetText ( timeStampButtonText:GetText() );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelectedDropDownMenu:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelected:Show();
            end
        end);
        timeStampButton:Show();
    end
    GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][51] = tempTimestampHolder;
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelectedDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.Populate24HrDropDown()
-- What it Does:    Builds the 2 options in 24 hr timescale vs 12 hr
-- Purpose:         To give the player the option to set it to a 12hr scale or 24hr scale.
GRM.Populate24HrDropDown = function()
    local buffer = 4;
    local height = 0;
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelectedDropDownMenu.Buttons = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelectedDropDownMenu.Buttons or {};

    for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelectedDropDownMenu.Buttons do
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelectedDropDownMenu.Buttons[i][1]:Hide();
    end

    local HourFormat = { GRM.L ( "24 Hour" ) , GRM.L ( "12 Hour (am/pm)" ) };

    for i = 1 , 2 do
        if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelectedDropDownMenu.Buttons[i] then
            local tempButton = CreateFrame ( "Button" , "GRM_HrButton" .. i , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelectedDropDownMenu );
            GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelectedDropDownMenu.Buttons[i] = { tempButton , tempButton:CreateFontString ( "GRM_HrButton_Txt" .. i , "OVERLAY" , "GameFontWhiteTiny" ) }
        end
        local HrButton = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelectedDropDownMenu.Buttons[i][1];
        local HrButtonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelectedDropDownMenu.Buttons[i][2];
        HrButton:SetWidth ( 110 );
        HrButton:SetHeight ( 11 );
        HrButton:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        HrButtonText:SetText ( HourFormat[i] );
        HrButtonText:SetWidth ( 105 );
        HrButtonText:SetWordWrap ( false );
        HrButtonText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 11 );
        HrButtonText:SetPoint ( "CENTER" , HrButton );
        HrButtonText:SetJustifyH ( "CENTER" );

        if i == 1 then
            HrButton:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelectedDropDownMenu , 0 , -7 );
            height = height + HrButton:GetHeight();
        else
            HrButton:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelectedDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + HrButton:GetHeight() + buffer;
        end

        HrButton:SetScript ( "OnClick" , function( self , button ) 
            if button == "LeftButton" then
                local parsedNumber = 1;
                local nameOfButton = self:GetName();
                for j = 1 , #nameOfButton do
                    if tonumber ( string.sub ( nameOfButton , j , j ) ) ~= nil then
                        -- NUM FOUND! Let's pull that number from the buttons and we'll know what class it is!
                        parsedNumber = tonumber ( string.sub ( nameOfButton , j ) );
                        break
                    end
                end
                if parsedNumber == 1 then
                    GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][39] = true;
                else
                    GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][39] = false;
                end
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelected.GRM_24HrSelectedText:SetText ( HrButtonText:GetText() );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelectedDropDownMenu:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelected:Show();
            end
        end);
        HrButton:Show();
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelectedDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.SetGroupInviteButton ( string )
-- What it Does:    Invites a selected guildie to your group
-- Purpose:         Continuity on previous Blizz default frames to these
GRM.SetGroupInviteButton = function ( handle )
    if GetNumGroupMembers() > 0  then                                                               -- If > 0 then player is in either a raid or a party. (1 will show if in an instance by oneself)
        local isGroupLeader = UnitIsGroupLeader ( "PLAYER" );                                       -- Party or Group
        local isInRaidWithAssist = UnitIsGroupAssistant ( "PLAYER" , LE_PARTY_CATEGORY_HOME );      -- Player Has Assist in Raid group

        if GRM.IsGuildieInSameGroup ( handle ) then
            -- Player is already in group!
            GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( GRM.L ( "In Group" ) );
            GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:SetScript ("OnClick" , function ( _ , button )
                if button == "LeftButton" then
                    GRM.Report (  GRM.L ( "{name} is Already in Your Group!" , GRM.GetStringClassColorByName ( handle ) .. GRM.SlimName ( handle ) .. "|r" ) );
                end
            end);
        elseif isGroupLeader or isInRaidWithAssist then                                         -- Player has the ability to invite to group
            GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( GRM.L ( "Group Invite" ) );
            GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:SetScript ( "OnClick" , function ( _ , button )
                if button == "LeftButton" then
                    if IsInRaid() and GetNumGroupMembers() == 40 then                               -- Helpful reporting to cleanup the raid in case players are offline and no room to invite.
                        local afkList = GRM.GetGroupUnitsOfflineOrAFK();
                        local report = ( "\n|cffff0000" .. GRM.L ( "GROUP NOTIFICATION:" ) .. " |cffffffff" .. GRM.L ( "40 players have already been invited to this Raid!" ) );
                        if #afkList[1] > 0 then
                            report = ( report .. "\n|cffff0000" .. GRM.L ( "Players Offline:" ) .. " |cffffffff" );
                            for i = 1 , #afkList[1]  do
                                report = ( report .. "" .. afkList[1][i] );
                                if i ~= #afkList[1] then
                                    report = ( report .. GRM.L ( "," ) .. " " );
                                end
                            end
                        end

                        if #afkList[2] > 0 then
                            report = ( report .. "\n|cffff0000" .. GRM.L ( "Players AFK:" ) .. " |cffffffff" );
                            for i = 1 , #afkList[2]  do
                                report = ( report .. "" .. afkList[2][i] );
                                if i ~= #afkList[2] then
                                    report = ( report .. GRM.L ( "," ) .. " " );
                                end
                            end
                        end
                        GRM.Report ( report );
                    else
                        InviteUnit ( handle );
                    end
                end
            end);
        else            -- Player is in a group but does not have invite privileges
            GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( GRM.L ( "No Invite" ) );
            GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:SetScript ( "OnClick" , function ( _ , button )
                if button == "LeftButton" then
                    GRM.Report ( GRM.L ( "Player should try to obtain group invite privileges." ) );
                end
            end);
        end
    else
        -- Player is not in any group, thus inviting them will create new group.
        GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( GRM.L ( "Group Invite" ) );
        GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:SetScript ( "OnClick" , function ( _ , button )
            if button == "LeftButton" then
                InviteUnit ( handle );
            end
        end);
    end

    if GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton.GRM_GroupInviteButtonText:GetText() ~= nil then
        GRM_UI.ScaleFontStringToObjectSize ( true , GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:GetWidth() , GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton.GRM_GroupInviteButtonText , 4 );
    end
end

-- Method:          GRM.CreateOptionsRankDropDown()
-- What it Does:    Builds the final rank drop down product for options panel
-- Purpose:         UI Feature for options to be able to filter who you will accept shared data from.
GRM.CreateOptionsRankDropDown = function ()
    GRM.PopulateOptionsRankDropDown();
    GRM.PopulateBanListOptionsDropDown();
    GRM.PopulateDefaultDropDownRankMenu();

    local numRanks = GuildControlGetNumRanks() - 1;
    local HourFormat = { GRM.L ( "24 Hour" ) , GRM.L ( "12 Hour (am/pm)" ) };
    
    -- General sync restriction
    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] > numRanks then       -- There's been a change since the player last logged in...
        GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] = numRanks;
    end
    -- Ban List Sync restriction
    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][22] > numRanks then       -- There's been a change since the player last logged in...
        GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][22] = numRanks;
    end
    -- Custom Note Sync Restriction
    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][49] > numRanks then       -- There's been a change since the player last logged in...
        GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][49] = numRanks;
    end

    local setRankName = GuildControlGetRankName ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] + 1 );
    local setRankNameBanList = GuildControlGetRankName ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][22] + 1 );
    local setCustomDefaultName = GuildControlGetRankName ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][49] + 1 );
    local setTagFormat = { "<" .. GRM.L ( "M" ) .. ">" , "(" .. GRM.L ( "M" ) .. ")" , "<" .. GRM.L ( "Main" ) .. ">" , "(" .. GRM.L ( "Main" ) .. ")" };
    
    if setRankName == nil or setRankName == "" then
        setRankName = GuildControlGetRankName ( 1 )     -- Default it to guild leader. This scenario could happen if the rank was removed or you change guild but still have old settings.
    end
    if setRankNameBanList == nil or setRankNameBanList == "" then
        setRankNameBanList = GuildControlGetRankName ( 1 )     -- Default it to guild leader. This scenario could happen if the rank was removed or you change guild but still have old settings.
    end

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelectedText:SetText( setRankName );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelectedText:SetText ( setRankNameBanList );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_DefaultCustomSelectedText:SetText ( setCustomDefaultName );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected.GRM_TagText:SetText ( setTagFormat[GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][42]] );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected.GRM_TagText:SetTextColor ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][46][1] , GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][46][2] , GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][46][3] , 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected.GRM_LanguageSelectedText:SetText ( GRML.Languages[GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][43]] );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_ColorSelectOptionsFrame.GRM_OptionsTexture:SetColorTexture ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][46][1] , GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][46][2] , GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][46][3] , 1 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected.GRM_FontSelectedText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 11 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected.GRM_FontSelectedText:SetText ( GRML.FontNames[ GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][44] ] );
    local _ , month , day , year = GRM.CalendarGetDate();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelected.GRM_TimestampSelectedText:SetText( GRM.FormatTimeStamp ( day .. " " .. monthEnum2 [ tostring ( month ) ] .. " '" .. ( year - 2000 ) , false ) );
    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][39] then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelected.GRM_24HrSelectedText:SetText ( HourFormat[1] );
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelected.GRM_24HrSelectedText:SetText ( HourFormat[2] );
    end

    -- Now that initial values set, let's display them!
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelected:Show();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected:Show();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_MainTagFormatSelected:Show();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_LanguageSelected:Show();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_FontSelected:Show();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_TimestampSelected:Show();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame.GRM_24HrSelected:Show();
end

-- Method:              GRM.ClearPromoDateHistory ( string )
-- What it Does:        Purges history of promotions as if they had just joined the guild.
-- Purpose:             Editing ability in case of user error.
GRM.ClearPromoDateHistory = function ( name , isUnknown )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == name then        -- Player found!
            -- Ok, let's clear the history now!
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][12] = nil;
            if not isUnknown then
                GRM_G.rankDateSet = false;
            end
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][25] = nil;
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][25] = {};
            table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][25] , { GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][4] , string.sub ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][2] , 1 , string.find ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][2] , "'" ) + 2 ) , GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][3] } );
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][41] = false;
            if name == GRM_G.currentName and GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
                GRM_UI.GRM_altDropDownOptions:Hide();
                if not isUnknown then
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Hide();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Show();
                end
            end
            break;
        end
    end
end

-- Method:              GRM.ClearJoinDateHistory ( string )
-- What it Does:        Clears the player's history on when they joined/left/rejoined the guild to be as if they were  a new member
-- Purpose:             Micromanagement of toons metadata.
GRM.ClearJoinDateHistory = function ( name , isUnknown )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == name then        -- Player found!
            -- Ok, let's clear the history now!
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][40] = false;
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][20] = nil;   -- oldJoinDate wiped!
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][20] = {};
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][21] = nil;
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][21] = {};
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][15] = nil;
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][15] = {};
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][16] = nil;
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][16] = {};
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][2] = GRM.GetTimestamp();
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][3] = time();
            if name == GRM_G.currentName and GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
                GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:Hide();
                GRM_UI.GRM_altDropDownOptions:Hide();
                if not isUnknown then
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton:Show();
                end
            end
            break;
        end
    end
end

-- Method:              GRM.ResetPlayerMetaData ( string , string )
-- What it Does:        Purges all metadata from an alt up to that point and resets them as if they were just added to the guild roster
-- Purpose:             Metadata player management. QoL feature if ever needed.
GRM.ResetPlayerMetaData = function ( playerName )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == playerName then
            local classedName = GRM.GetStringClassColorByName ( playerName ) .. GRM.SlimName ( playerName ) .. "|r";
            GRM.Report ( GRM.L ( "{name}'s saved data has been wiped!" , classedName ) );
            if not CommunitiesFrame or not CommunitiesFrame:IsVisible() then
                GuildRoster();
            end

            local roster = {};
            for i = 1 , GRM.GetNumGuildies() do
                local name , rank , rankInd , level , _ , zone , _ , _ , online , status , class , achievementPoints , _ , isMobile , _ , rep = GetGuildRosterInfo ( i );
                if name == playerName then
                    roster[1] = name
                    roster[2] = rank;
                    roster[3] = rankInd;
                    roster[4] = level;
                    roster[5] = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][7];
                    roster[6] = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][8];
                    roster[7] = class;
                    roster[8] = GRM.GetHoursSinceLastOnline ( i , online ); -- Time since they last logged in in hours.
                    roster[9] = zone;
                    roster[10] = achievementPoints;
                    roster[11] = isMobile;
                    roster[12] = rep;
                    roster[13] = online;
                    roster[14] = status;
                    break;
                end
            end

            if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11] > 0 then
                GRM.RemoveAlt ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11][1][1] , playerName , false , 0 , false );      -- Removing oneself from his alts list on clearing info so it clears him from them too.
            end
            table.remove ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] , j );         -- Remove the player!
            GRM.AddMemberRecord( roster , false , nil )     -- Re-Add the player!
            GRM_UI.GRM_MemberDetailMetaData:Hide();
            
            --Let's re-initiate syncing!
            if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] and not GRMsyncGlobals.currentlySyncing and GRM_G.HasAccessToGuildChat then
                GRM.Report ( GRM.L ( "Re-Syncing {name}'s Guild Data..." , classedName ) );
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
    GRM.Report ( GRM.L ( "Wiping all Saved Roster Data Account Wide! Rebuilding from Scratch..." ) );

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

    GRM_FullBackup_Save = nil;
    GRM_FullBackup_Save = {};

    GRM_GuildDataBackup_Save = nil;
    GRM_GuildDataBackup_Save = {};
    GRM_GuildDataBackup_Save = { { "Horde" } , { "Alliance" } };

    GRM_DebugLog_Save = nil;
    GRM_DebugLog_Save = {};

    GRM_Misc = nil;
    GRM_Misc = {};

    -- Hide the window frame so it can quickly be reloaded.
    GRM_UI.GRM_MemberDetailMetaData:Hide();

    -- Reset the important guild indexes for data tracking.
    GRM_G.saveGID = 0;
    GRM_G.logGID = 0;

    -- Now, let's rebuild...
    if IsInGuild() then
        GRM.BuildNewRoster();
    end
    -- Update the logFrame if it was open at the time too
    if GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetText ( GRM.L ( "Search Filter" ) );
        GRM.BuildLog();
    end

    -- Update the ban list too!
    if GRM_CoreBanListFrame:IsVisible() then
        GRM.RefreshBanListFrames();
    end

    if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
        GRM.RefreshAuditFrames( GRM_G.AuditSortType );
    end

    -- To avoid Lua error if player tries to trigger this immediately after loading
    if GRM_G.setPID == 0 then
        for i = 2 , #GRM_AddonSettings_Save[GRM_G.FID] do
            if GRM_AddonSettings_Save[GRM_G.FID][i][1] == GRM_G.addonPlayerName then
                GRM_G.setPID = i;
                break;
            end
        end
    end

    -- Trigger Sync
    --Let's re-initiate syncing!
    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] and not GRMsyncGlobals.currentlySyncing and GRM_G.HasAccessToGuildChat then
        GRMsync.TriggerFullReset();
        -- Now, let's add a brief delay, 3 seconds, to trigger sync again
        C_Timer.After ( 3 , GRMsync.Initialize );
    end
end

-- Method:          GRM.ResetGuildSavedData()
-- What it Does:    Purges all saved data from the guild and only the guild...
-- Purpose:         Sometimes you don't want to reset everything... just the guild.
GRM.ResetGuildSavedData = function ( guildName )
    GRM.Report ( GRM.L ( "Wiping all saved Guild data! Rebuilding from scratch..." ) );
    -- removing Player Saved metadata of the guild
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][i][1][1] == guildName then
            table.remove ( GRM_GuildMemberHistory_Save[ GRM_G.FID ] , i );
            break;
        end
    end

    -- Removing Players that left saved metadata
    for i = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ] do
        if GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][i][1][1] == guildName then
            table.remove ( GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ] , i );
            break;
        end
    end

    -- Clearing the Guild Log...
    for i = 2 , #GRM_LogReport_Save[ GRM_G.FID ] do
        if GRM_LogReport_Save[ GRM_G.FID ][i][1][1] == guildName then
            table.remove ( GRM_LogReport_Save[ GRM_G.FID ] , i );
            break;
        end
    end

    -- Clearing the Guild Log...Resetting the add to calendar que
    for i = 2 , #GRM_CalendarAddQue_Save[ GRM_G.FID ] do
        if GRM_CalendarAddQue_Save[ GRM_G.FID ][i][1][1] == guildName then
            table.remove ( GRM_CalendarAddQue_Save[ GRM_G.FID ] , i );
            break;
        end
    end

    -- Clearing the Guild Notepads
    for i = 2 , #GRM_GuildNotePad_Save[ GRM_G.FID ] do
        if GRM_GuildNotePad_Save[ GRM_G.FID ][i][1][1] == guildName then
            table.remove ( GRM_GuildNotePad_Save[ GRM_G.FID ] , i );
            break;
        end
    end

    -- Hide the window frame so it can quickly be reloaded.
    GRM_UI.GRM_MemberDetailMetaData:Hide();
    
    -- Reset the important guild indexes for data tracking.
    GRM_G.saveGID = 0;
    GRM_G.logGID = 0;

    -- Now, let's rebuild...
    if IsInGuild() then
        GRM.BuildNewRoster();
    end

    C_Timer.After ( 3 , function()
        -- Update the logFrame if it was open at the time too
        if GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_LogEditBox:SetText ( GRM.L ( "Search Filter" ) );
            GRM.BuildLog();
        end

        -- Update the ban list too!
        if GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:IsVisible() then
            GRM.RefreshBanListFrames();
        end

        if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
            GRM.RefreshAuditFrames( GRM_G.AuditSortType );
        end

        -- Trigger Sync
        -- To avoid Lua error if player tries to trigger this immediately after loading
        if GRM_G.setPID == 0 then
            for i = 2 , #GRM_AddonSettings_Save[GRM_G.FID] do
                if GRM_AddonSettings_Save[GRM_G.FID][i][1] == GRM_G.addonPlayerName then
                    GRM_G.setPID = i;
                    break;
                end
            end
        end
        
        --Let's re-initiate syncing!
        if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] and not GRMsyncGlobals.currentlySyncing and GRM_G.HasAccessToGuildChat then
            GRMsync.TriggerFullReset();
            -- Now, let's add a brief delay, 3 seconds, to trigger sync again
            C_Timer.After ( 3 , GRMsync.Initialize );
        end
    end);
end

-- Method:          GRM.LiveChangesCheck ( int , string )
-- What it DoeS:    It removes repeat log instances of changes that happen live
-- Purpose:         To prevent double log reporting of live changes. A single scan may take several seconds, especially in large guilds as it splits the scan up to prevent any momentary stutter.
--                  Well, what if a change is live detected during this scan? This updates the logs to remove the changes if so.
GRM.LiveChangesCheck = function ( indexOfAction , logEntry )
    -- 1 = Promotions
    if indexOfAction == 1 then
        for i = 1 , #GRM_G.TempLogPromotion do
            if GRM_G.TempLogPromotion[i][2] == logEntry then
                table.remove ( GRM_G.TempLogPromotion , i );
                break;
            end
        end
    -- 2 = Demotion
    elseif indexOfAction == 2 then
        for i = 1 , #GRM_G.TempLogDemotion do
            if GRM_G.TempLogDemotion[i][2] == logEntry then
                table.remove ( GRM_G.TempLogDemotion , i );
                break;
            end
        end
    -- 3 = Left Guild
    elseif indexOfAction == 3 then
        for i = 1 , #GRM_G.TempLeftGuild do
            if GRM_G.TempLeftGuild[i][2] == logEntry then
                table.remove ( GRM_G.TempLeftGuild , i );
                break;
            end
        end
    -- 4 = joined/rejoined guild
    elseif indexOfAction == 4 then
        for i = 1 , #GRM_G.TempNewMember do
            if GRM_G.TempNewMember[i][2] == logEntry then
                table.remove ( GRM_G.TempNewMember , i );
                break;
            end
        end
        for i = 1 , #GRM_G.TempRejoin do
            if GRM_G.TempRejoin[i][2] == logEntry then
                table.remove ( GRM_G.TempRejoin , i );
                break;
            end
        end
        for i = 1 , #GRM_G.TempBannedRejoin do
            if GRM_G.TempBannedRejoin[i][2] == logEntry then
                table.remove ( GRM_G.TempBannedRejoin , i );
                break;
            end
        end
    end
end

-- Method:          GRM.CheckForNewPlayer ( string )
-- What it Does:    First parses the system message, then quickly determines if there is a new player that just joined the guild and then builds their profile
-- Purpose:         For instant join data for the log, rather than having to wait up to 10 seconds.
GRM.CheckForNewPlayer = function( text )
    local memberList = CommunitiesUtil.GetMemberInfo ( GRM_G.gClubID , C_Club.GetClubMembers ( GRM_G.gClubID ) );
    local result = false;

    if #memberList == #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] and not GRM_G.CurrentlyScanning then           -- This means it shows successfully 1 found player...
        local name = GRM.GetParsedNameFromInviteAnnouncmenet ( text );
        local slimName = GRM.SlimName ( name );
        -- Verify player is not in the middle of a scan...
        local indexes = {};
        for i = 1 , #memberList do
            if memberList[i].name == "" or memberList[i].name == nil then
                C_Timer.After ( 1 , function()              -- reload as the stream wasn't ready...
                    GRM_G.changeHappenedExitScan = true;
                    GRM.CheckForNewPlayer ( text );
                end);
                return true;                                -- Returning true because I don't want to trigger a tracking check...
            end
            if memberList[i].name == slimName then
                table.insert ( indexes , i );
                -- Let's add the new player!!!
                break;
            end
        end

        local memberInfo;
        if #indexes > 1 then
            -- Player with same names but different servers...
            for i = 1 , #indexes do
                if GRM.GetFullNameClubMember ( memberList[indexes[i]].guid ) == name then
                    memberInfo = memberList[indexes[i]];
                    break;
                end
            end
        else
            memberInfo = memberList[indexes[1]];
        end

        if memberInfo ~= nil then
            result = true;
            local ONote;
            if CanViewOfficerNote() then -- Officer Note permission to view.
                ONote = "";
            end
            local isOnline = false;
            if memberInfo.presence == 1 then
                isOnline = true;
            end
            local classFile = C_CreatureInfo.GetClassInfo ( memberInfo.classID ).classFile;

            local memberData = {
                name,
                GuildControlGetRankName ( GuildControlGetNumRanks() ),
                GuildControlGetNumRanks() - 1,
                memberInfo.level,
                "",
                ONote,
                classFile,
                0,
                memberInfo.zone,
                memberInfo.achievementPoints,
                false,
                8,
                isOnline,
                0,
                memberInfo.guid              
            };
            GRM_G.changeHappenedExitScan = true;
            -- Printing Report, and sending report to log.
            -- Check Main Auto tagging...
            if not CommunitiesFrame or not CommunitiesFrame:IsVisible() or CommunitiesGuildRecruitmentFrame:IsVisible() then
                GRM.SetGuildInfoDetails();
            end
            C_Timer.After ( 10 , function()
                GRM.RecordJoinChanges ( memberData , GRM.GetClassColorRGB ( classFile , true ) .. slimName .. "|r" );
                GRM.FinalReport();
                if GRM_G.DesignateMain then
                    GRM.SetMain ( name , name , false , 0 );
    
                    if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
                        GRM.RefreshAuditFrames( GRM_G.AuditSortType );
                    end
                end
            end)
        end
    end
    return result;
end

-- Method:          GRM.GetParsedNameFromInviteAnnouncmenet ( string )
-- What it Does:    Parses out the player name-server from the system message about a player joining the guild
-- Purpose:         Useful for players joining the guild.
GRM.GetParsedNameFromInviteAnnouncmenet = function( text )
    local tempParse = string.sub ( text , 1 , string.find ( text , "-" ) )
    local ind = string.find ( text , "-" );
    if string.find ( string.sub ( text , ind ) , " " ) ~= nil then  -- We know that there is a space at the end of it... Let's parse that off.
        for i = ind , #text do
            if string.sub ( text , i , i ) == " " then
                text = string.sub ( text , 1 , i - 1 );
                break;
            end
        end
        -- text = string.sub ( text , 1 , ind + string.find ( string.sub ( text , ind ) , " " ) - 1 );
    end
    if string.find ( text , " " ) ~= nil then
        for i = ind , 1 , -1 do
            if string.sub ( text , i , i ) == " " then
                text = string.sub ( text , i + 1 );
                break;
            end
        end
    end
    return text;
end

-- Method:          GRM.KickPromoteOrJoinPlayer ( object , string , string )
-- What it Does:    Acts as an active event listener and handler for when a player is kicked, joined, demoted or promoted in the guild
-- Purpose:         For instantaneous log reporting rather than waiting for the next scan to update the data.
GRM.KickPromoteOrJoinPlayer = function ( _ , msg , text )
    if msg == "CHAT_MSG_SYSTEM" and CommunitiesFrame ~= nil and CommunitiesFrame:IsVisible() then
        local frameName = "";
        if GRM_G.currentName ~= nil then
            frameName = GRM_G.currentName;
        end
        if string.find ( text , GRM.L ( "has been kicked" ) ) ~= nil and string.find ( text , GRM.SlimName ( GRM_G.addonPlayerName ) ) ~= nil and string.find ( text , GRM.SlimName ( frameName ) ) ~= nil then
            GRM_G.changeHappenedExitScan = true;
            -- BAN the alts!
            if GRM_G.isChecked2 then
                GRM.KickAllAlts ( frameName );
            end
            
            if GRM_G.isChecked then          -- Box is checked, so YES player should be banned. -This boolean is useful because this is a reused Blizz default frame, since protected function.
                -- Popup edit box - BAN logic...
                for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] == frameName then
                        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][17][1] = true;      -- This officially tags the player as BANNED!
                        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][17][2] = time();
                        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][17][3] = false;
                        local result = GRM_UI.GRM_MemberDetailPopupEditBox:GetText();
                        if result ~= GRM.L ( "Reason Banned?" ) .. "\n" .. GRM.L ( "Click \"YES\" When Done" ) and result ~= "" and result ~= nil then
                            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][18] = result;
                        else
                            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][18] = "";
                            result = "";
                        end

                        -- Add a log message too if it is a ban!
                        local logEntry = "";
                        
                        if GRM_G.isChecked2 then
                            logEntry = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} has BANNED {name2} and all linked alts from the guild!" , GRM.GetClassifiedName ( GRM_G.addonPlayerName , true ) , GRM.GetClassifiedName ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] , true ) ) );
                            
                            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][18] ~= "" then
                                GRM.AddLog ( 18 , GRM.L ( "Reason Banned:" ) .. " " .. GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][18] );
                            end
                            GRM.AddLog ( 17 , logEntry );
                        else
                            logEntry = ( GRM.FormatTimeStamp ( GRM.GetTimestamp() , true ) .. " : " .. GRM.L ( "{name} has BANNED {name2} from the guild!" , GRM.GetClassifiedName ( GRM_G.addonPlayerName , true ) , GRM.GetClassifiedName ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] , true ) ) );
                            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][18] ~= "" then
                                GRM.AddLog ( 18 , GRM.L ( "Reason Banned:" ) .. " " .. GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][18] );
                            end
                            GRM.AddLog ( 17 , logEntry );
                        end

                        if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][4] then
                            GRM.PrintLog ( 17 , logEntry , false );
                            GRM.PrintLog ( 18 , GRM.L ( "Reason Banned:" ) .. " " .. GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][18] , false );
                        end

                        -- Send the message out!
                        if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][21] then
                            if result == "" then
                                result = GRM.L ( "None Given" );
                            end
                            GRMsync.SendMessage ( "GRM_SYNC" , GRM_G.PatchDayString .. "?GRM_BAN?" .. GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][22] ) .. "?" .. frameName .. "?" .. tostring ( GRM_G.isChecked2 ) .. "?" .. result .. "?" .. GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][9] , "SLASH_CMD_GUILD" );
                        end

                        break;
                    end
                end
            end
            -- Remove player normally
            local logReport = GRM.RecordKickChanges ( frameName , true );
            -- report the changes!
            if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][13][4] and not GRM_G.isChecked then
                GRM.PrintLog ( 10 , logReport , false );
            end
            GRM.AddLog ( 10 , logReport );
            GRM_UI.GRM_MemberDetailMetaData:Hide();
            GRM.BuildLogComplete()

            GRM_G.pause = false;
            if GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:IsVisible() then
                GRM.RefreshBanListFrames();
            end
        
        elseif ( string.find ( text , GRM.L ( "has promoted" ) ) ~= nil or string.find ( text , GRM.L ( "has demoted" ) ) ~= nil ) and string.find ( text , GRM.SlimName ( GRM_G.addonPlayerName ) ) ~= nil then
            C_Timer.After ( 0.5 , function()
                if GuildMemberRankDropdownText ~= nil and GuildMemberRankDropdownText:IsVisible() then
                    GRM_G.changeHappenedExitScan = true;
                    GRM.OnRankChange ( GRM_G.CurrentRank , GuildMemberRankDropdownText:GetText() );
                end
            end);
        elseif string.find ( text , GRM.L ( "joined the guild." ) ) ~= nil then
            local memberList = CommunitiesUtil.GetMemberInfo ( GRM_G.gClubID , C_Club.GetClubMembers ( GRM_G.gClubID ) );  -- Might seem odd, but this triggers the list to load so I can get it back from server next method...
            C_Timer.After ( 1 , function() 
                if not GRM.CheckForNewPlayer ( text ) then
                    GRM_G.changeHappenedExitScan = false;
                    if not CommunitiesFrame or not CommunitiesFrame:IsVisible() then
                        GuildRoster();
                    end
                    GRM_G.trackingTriggered = false;
                    QueryGuildEventLog();
                end
                if GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:IsVisible() then
                    GRM.RefreshBanListFrames();
                end
            end);
        end

    elseif msg == "CHAT_MSG_SYSTEM" and string.find ( text , GRM.L ( "joined the guild." ) ) ~= nil then
        local memberList = CommunitiesUtil.GetMemberInfo ( GRM_G.gClubID , C_Club.GetClubMembers ( GRM_G.gClubID ) );  -- Might seem odd, but this triggers the list to load so I can get it back from server next method...
        C_Timer.After ( 1 , function() 
            if not GRM.CheckForNewPlayer ( text ) then
                GRM_G.changeHappenedExitScan = false;
                if not CommunitiesFrame or not CommunitiesFrame:IsVisible() then
                    GuildRoster();
                end
                GRM_G.trackingTriggered = false;
                QueryGuildEventLog();
            end
            if GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:IsVisible() then
                GRM.RefreshBanListFrames();
            end
        end);
    end
end

-- Method:          GRM.RemoveBan( int , boolean , boolean , int )
-- What it Does:    Just what it says... it removes the ban from the player and wipes the data clean. No history of ban is stored
-- Purpose:         Necessary for forgiveness or accidental banning.
GRM.RemoveBan = function ( playerIndex , onPopulate )
    GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][playerIndex][17] = nil;
    GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][playerIndex][17] = { false , time() , true }
    GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][playerIndex][18] = "";

    GRM_UI.GRM_MemberDetailBannedText1:Hide();
    GRM_UI.GRM_MemberDetailBannedIgnoreButton:Hide();

    -- On populate is referring to the check for when it is on mouseover... no need to check this if not.
    if onPopulate and GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:IsVisible() then
        -- Refresh the frames:
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetText ( GRM.L ( "Select a Player" ) );
        if GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons ~= nil then
            for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons do
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[i][1]:UnlockHighlight();
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
    for j = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == name then
            isFound = true;
            GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][17] = nil;
            GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][17] = { false , time() , true };
            GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][18] = "";
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
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == name then
                GRM.RemoveBan ( j , false )
                break;
            end
        end
    end

    -- Refresh the frames:
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:Hide();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetText ( GRM.L ( "Select a Player" ) );
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons ~= nil then
        for i = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons do
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[i][1]:UnlockHighlight();
        end
    end
    GRM.RefreshBanListFrames();
end


GRM.SyncRemoveCurrentPlayerBan = function ( name , timestamp )
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == name then
            if timestamp > GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][17][2] then
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][17] = nil;
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][17] = { false , timestamp , true }
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][18] = "";
                
                GRM_UI.GRM_MemberDetailBannedText1:Hide();
                GRM_UI.GRM_MemberDetailBannedIgnoreButton:Hide();
                break;
            end
        end
    end
end

GRM.SyncAddCurrentPlayerBan = function ( name , timestamp , reason )
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == name then
            if timestamp > GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][17][2] then
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][17] = nil;
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][17] = { true , timestamp , false }
                GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][18] = reason;
                break;
            end
        end
    end
end

GRM.ChangeCurrentPlayerBanReason = function ( name , reason )
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][1] == name then
            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][18] = reason;
            break
        end
    end
end

---------------------------------
------ CLASS INFO ---------------
---------------------------------

-- Work in progress that I will eventually get to... getting player roles!
GRM.GetClassRoles = function( className )
    local result;
    
    if className == "DEATHKNIGHT" then
        result = { "Blood" , 135770 ,  "Frost" , 135773 , "Unholy" , 135775 };
    elseif className == "DEMONHUNTER" then
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
    
    return result;
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
---- GUILD SHARED NOTEPAD -----
-------------------------------

-- Method
-- GRM.AddNote = function( destination , editor , timestamp )

-- end

-- GRM.EditNote = function ( note , editor , timestamp )

-- end

-- GRM.RemoveNote = function ( note , editor , timestamp )

-- end

    -------------------------------
----- UI SCRIPTING LOGIC ------
----- ALL THINGS UX ARE HERE --
-------------------------------

-- Method:          GRM.GRM.PopulateMemberDetails ( string )
-- What it Does:    Builds the details for the core MemberInfoFrame
-- Purpose:         Iterate on each mouseover... Furthermore, this is being kept in "Local" for even the most infinitesimal cost-saving on resources
--                  by not indexing it in a table. Buried in it will be mostly non-compartmentalized logic, few function calls.
GRM.PopulateMemberDetails = function( handle )
    if handle ~= "" and handle ~= nil and GRM_G.saveGID ~= 0 then              -- If the handle is failed to be returned, it is returned as an empty string. Just logic to not populate if on failure.
        GRM_G.rankDateSet = false;        -- resetting tracker

        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] == handle then   --- Player Found in MetaData Logs
                GRM_G.currentNameIndex = r;

                for i = 1 , GRM.GetNumGuildies() do
                    local fullName, _, _, _, _, zone, _, _, isOnline = GetGuildRosterInfo ( i );
                    if fullName == handle then
                        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][33] = isOnline;
                        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][28] ~= zone then
                            GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][32] = time();    -- Resets the time
                        end
                        GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][28] = zone;
                        break;
                    end                    
                end
                
                --- CLASS
                local classColors = GRM.GetClassColorRGB ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][9] );
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:SetTextColor ( classColors[1] , classColors[2] , classColors[3] , 1.0 );
                
                -- PLAYER NAME
                -- Let's scale the name too!
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:SetText ( GRM.SlimName ( handle ) );
                local nameHeight = 16;
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + nameHeight );        -- Reset size back to 16 just in case previous fontstring was altered 
                while ( GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:GetWidth() > 120 ) do
                    nameHeight = nameHeight - 0.1;
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + nameHeight );
                end

                -- IS MAIN
                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][10] then
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:Show();
                else
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:Hide();
                end

                --- LEVEL
                if GRM_G.Region == "ruRU" or GRM_G.Region == "koKR" then
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLevel:SetText (  tostring ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][6] ) .. GRM.L ( "Level: " ) );
                else
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLevel:SetText ( GRM.L ( "Level: " ) .. GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][6] );
                end

                -- RANK
                GRM_G.rankIndex = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][5];

                -- Possibly a player index issue...
                if GRM_G.playerIndex == -1 then
                    GRM_G.playerIndex = GRM.GetGuildMemberRankID ( GRM_G.addonPlayerName );
                end

                -- Rank Text Info...
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankTxt:SetText ( "\"" .. GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][4] .. "\"");
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankTxt:Show();

                -- ZONE INFORMATION
                if not GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:IsVisible() then
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][33] then
                        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][28] ~= nil then
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][28] );                                     -- Zone
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][32] ) );              -- Time Passed
                        end
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Show();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Show();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Show();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Show();
                    else
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Hide();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Hide();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Hide();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Hide();
                    end


                    --RANK PROMO DATE
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][41] then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:SetText ( GRM.L ( "Promoted:" ) .. " " .. GRM.L ( "Unknown" ) );
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Show();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Hide();
                        GRM_G.rankDateSet = true;
                    else
                        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][12] == nil then      --- Promotion has never been recorded!
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Hide();
                            GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Show();
                        else
                            GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Hide();
                            GRM_G.rankDateSet = true;
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:SetText ( GRM.L ( "Promoted:" ) .. " " .. GRM.FormatTimeStamp ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][12] , false ) );
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Show();
                        end
                    end

                    -- JOIN DATE
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][40] then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton:Hide();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:SetText ( GRM.L ( "Unknown" ) );
                        GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:Show();
                    else
                        if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][20] == 0 then
                            GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:Hide();
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton:Show();
                        else
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton:Hide();
                            GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:SetText ( GRM.FormatTimeStamp ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][20][#GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][20]] , false ) );
                            GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:Show();
                        end
                    end
                end

                -- PLAYER NOTE AND OFFICER NOTE EDIT BOXES
                if not GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:HasFocus() and not GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:HasFocus() and not GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteEditBox:HasFocus() then
                    local finalNote = GRM.L ( "Click here to set a Public Note" );
                    local finalONote = GRM.L ( "Click here to set an Officer's Note" );
                    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:Hide();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:Hide();

                    -- Set Public Note if is One
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][7] ~= nil and GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][7] ~= "" then
                        finalNote = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][7];
                    end
                    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:SetText ( finalNote );
                    if CanEditPublicNote() then
                        if finalNote ~= GRM.L ( "Click here to set a Public Note" ) then
                            GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetText( finalNote );
                        else
                            GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:SetText( "" );
                        end
                    elseif finalNote == GRM.L ( "Click here to set a Public Note" ) then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:SetText ( GRM.L ( "Unable to Edit Public Note at Rank" ) );
                    end

                    -- Set O Note
                    if CanViewOfficerNote() == true then
                        if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][8] ~= nil and GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][8] ~= "" then
                            finalONote = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][8];
                        end
                        if finalONote == GRM.L ( "Click here to set an Officer's Note" ) and CanEditOfficerNote() ~= true then
                            finalONote = GRM.L ( "Unable to Edit Officer Note at Rank" );
                        end
                        GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:SetText ( finalONote );
                        if finalONote ~= GRM.L ( "Click here to set an Officer's Note" ) then
                            GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetText( finalONote );
                        else
                            GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetText( "" );
                        end
                    else
                        GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:SetText ( GRM.L ( "Unable to View Officer Note at Rank" ) );
                    end

                    -- Custom Note CheckBox
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][23][1] then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteSyncMetaCheckBox:SetChecked( true );
                    else
                        GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteSyncMetaCheckBox:SetChecked( false );
                    end
                    -- Activate Checkbox or disable
                    if not GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][38] then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteSyncMetaCheckBox:Disable();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteSyncMetaCheckBox.GRM_CustomNoteMetaCheckBoxText:SetTextColor ( 0.5 , 0.5 , 0.5 , 1 );
                    else
                        GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteSyncMetaCheckBox:SetScript ( "OnEnter" , nil );
                        GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteSyncMetaCheckBox:Enable();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteSyncMetaCheckBox.GRM_CustomNoteMetaCheckBoxText:SetTextColor ( 1.0 , 0.82 , 0.0 , 1.0 );
                    end
                    -- Set Custom Note details
                    GRM.BuildCustomNoteScrollFrame ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][23][6] );
                    
                    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:Show();

                end
                
                -- Custom Note dropbox
                GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteRankDropDownMenu:Hide();
                GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteRankDropDownSelected:Show();
                GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteRankDropDownSelected.GRM_CustomDropDownSelectedText:SetText ( GuildControlGetRankName ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][23][4] + 1 ) );

                -- Last Online
                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][33] then
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLastOnlineTxt:SetText ( GRM.L ( "Online" ) );
                else
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLastOnlineTxt:SetText ( GRM.HoursReport ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][24] ) );
                end

                -- Group Invite Button -- Setting script here
                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][33] and handle ~= GRM_G.addonPlayerName and not GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteEditBox:HasFocus() then
                    GRM.SetGroupInviteButton ( handle );
                    GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:Show();
                else
                    GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:Hide();
                end

                -- IF PLAYER WAS PREVIOUSLY BANNED AND REJOINED
                -- Player was previous banned and rejoined logic! This will unban the player.
                local isGuildieBanned = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][17][1];
                if isGuildieBanned and handle ~= GRM_G.addonPlayerName then
                    GRM_UI.GRM_MemberDetailBannedIgnoreButton:SetScript ( "OnClick" , function ( _ , button ) 
                        if button == "LeftButton" then
                            GRM.RemoveBan ( r , true );

                            -- Send the unban out for sync'd players
                            if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][21] then
                                GRMsync.SendMessage ( "GRM_SYNC" , GRM_G.PatchDayString .. "?GRM_UNBAN?" .. GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][15] .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][22] ) .. "?" .. GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] .. "?" , "SLASH_CMD_GUILD");
                            end
                            -- Message
                            local classColorHex = GRM.GetClassColorRGB ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][9] , true )
                            GRM.Report ( GRM.L ( "{name} has been Removed from the Ban List." ,  classColorHex .. GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][r][1] .. "|r" ) );
                        end
                    end);
                    
                    GRM_UI.GRM_MemberDetailBannedText1:Show();
                    GRM_UI.GRM_MemberDetailBannedIgnoreButton:Show();
                else
                    GRM_UI.GRM_MemberDetailBannedText1:Hide();
                    GRM_UI.GRM_MemberDetailBannedIgnoreButton:Hide();
                end

                -- ALTS 
                GRM.PopulateAltFrames ( r );

                break;
            end
        end
    end
end

-- Method:          GRM.ClearAllFrames( boolean )
-- What it Does:    Ensures frames are properly reset upon frame reload...
-- Purpose:         Logic time-saver for minimal costs... why check status of them all when you can just disable and build anew on each reload?
GRM.ClearAllFrames = function( includingMeta )
    if includingMeta then
        GRM_UI.GRM_MemberDetailMetaData:Hide();
    end
    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteRankDropDownSelected:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButton:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:Hide();
    GRM_UI.GRM_CoreAltFrame:Hide();
    GRM_UI.GRM_altDropDownOptions:Hide();
    GRM_UI.GRM_AddAltButton:Hide();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_ConfirmCustomNoteButton:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_CancelCustomNoteButton:Hide();
    GRM_UI.GRM_AltGroupingScrollBorderFrame:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteEditBox:ClearFocus()
end

-- Method:          GRM.ClearResetFramesOnTabChange()
-- What it Does:    Resets the frames when you are tabbing back and forth
-- Purpose:         Cleaner UI transition experience. Also, no need to keep player name up when the roster screen is gone.
GRM.ClearResetFramesOnTabChange = function()
    if GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
        GRM_UI.GRM_MemberDetailMetaData:Hide() -- this will also trigger to clear all frames GRM.ClearAllFrames()
    end

    if CommunitiesFrame.GuildMemberDetailFrame:IsVisible() then
        CommunitiesFrame.GuildMemberDetailFrame:Hide();
    end
end

-- Method:          GRM.SubFrameCheck()
-- What it Does:    Checks the core main frames, if they are open... and hides them
-- Purpose:         Questionable at this time... I might rewrite it with just 4 lines... It serves its purpose now
GRM.SubFrameCheck = function()
    -- wipe the frames...
    if GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButton:IsVisible() then
        GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButton:Click();
    end
    if GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:IsVisible() then
        GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:Hide();
    end
    if GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:IsVisible() then
        GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:Hide();
    end
    GRM_UI.GRM_AltGroupingScrollBorderFrame:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteEditBox:ClearFocus()
end

-- Method:          GRM.SelectPlayerOnRoster ( string )
-- What it Does:    If the guild roster window is open, this will jump to the player anywhere in the roster, online or offline, and bring up their metadata window
-- Purpose:         Useful for when a player wants to click and alt rather than have to scan through the roster for them.
GRM.SelectPlayerOnRoster = function ( playerName )
    if CommunitiesFrame.GuildMemberDetailFrame:IsVisible() then
        CommunitiesFrame.GuildMemberDetailFrame:Hide();
    end
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:ClearFocus();
    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:ClearFocus();
    GRM_UI.GRM_MemberDetailMetaData.GRM_CustomNoteEditBoxFrame.GRM_CustomNoteEditBox:ClearFocus();
    GRM_G.currentName = playerName;
    GRM_G.pause = false;
    GRM.ClearAllFrames( false );
    GRM.PopulateMemberDetails ( playerName );
    GRM_G.pause = true;
end

-------------------------------
-- BANNING LOGIC AND METHODS --
-------------------------------

-- Method:          GRM.RefreshBanListFrames()
-- What it Does:    On loading the Ban List frames, it populates and prepares them for a scrollable window if necessary
-- purpose:         Quality of Life. Whilst the ban list is managed automatically behind the scenes, it is useful to have common information that syncs between users
--                  with the guild.
GRM.RefreshBanListFrames = function()

    -- SCRIPT LOGIC ON ADD EVENT SCROLLING FRAME
    local scrollHeight = 0;
    local scrollWidth = 561;
    local buffer = 20;

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons or {};  -- Create a table for the Buttons.

    -- populating the window correctly.
    local count = 0;
    local tempHeight = 0;

    -- Populating the window based on the Current Players PLayers
    for i = #GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID] , 2 , -1 do
        -- if font string is not created, do so.
        if GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID][i][17][1] then  -- If player is banned.
                
            count = count + 1;
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count] then
                local tempButton = CreateFrame ( "Button" , "BannedPlayer" .. count , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame ); -- Names each Button 1 increment up
                table.insert ( GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons , { tempButton , tempButton:CreateFontString ( "BannedPlayerNameText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "BannedPlayerRankText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "BannedPlayerDateText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "BannedPlayerReasonText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) } );
            end

            local BanButtons = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][1];
            local BanNameText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][2];
            local BanRankText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][3];
            local BanDateText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][4];
            local BanReasonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][5];
            local classColor = GRM.GetClassColorRGB ( GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID][i][9] );

            BanButtons:SetWidth ( 555 );
            BanButtons:SetHeight ( 19 );
            BanButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
            BanNameText:SetText ( GRM.L ( "{name}(Still in Guild)" , GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID][i][1] .. "  |cff7fff00" ) );
            BanNameText:SetTextColor ( classColor[1] , classColor[2] , classColor[3] , 1 );
            BanNameText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 12 );
            BanNameText:SetJustifyH ( "LEFT" );
            BanRankText:SetText ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][4] );
            BanRankText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 12 );
            BanRankText:SetJustifyH ( "CENTER" );
            BanRankText:SetWidth ( 100 );
            BanRankText:SetTextColor ( 0.90 , 0.80 , 0.50 , 1.0 );
            BanDateText:SetText ( GRM.FormatTimeStamp ( GRM.EpochToDateFormat ( GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID][i][17][2] ) , false ) );
            BanDateText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 12 );
            BanDateText:SetJustifyH ( "CENTER" );
            BanDateText:SetWidth ( 100 );
            -- Determine it's not an empty ban reason!
            local reason = "";
            if GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID][i][18] == "" or GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID][i][18] == nil then
                reason = GRM.L ( "No Ban Reason Given" );
            else
                reason = GRM_GuildMemberHistory_Save[GRM_G.FID][GRM_G.saveGID][i][18];
            end
            BanReasonText:SetText ( "|CFFFF0000" .. GRM.L ( "Reason:" ) .. " |CFFFFFFFF" .. reason );
            BanReasonText:SetWidth ( 245 );
            BanReasonText:SetWordWrap ( true );
            BanReasonText:SetSpacing ( 1 );
            BanReasonText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 12 );
            BanReasonText:SetPoint ( "TOPLEFT" , BanButtons , "BOTTOMLEFT" , 0 , -1);
            BanReasonText:SetJustifyH ( "LEFT" );

            -- Logic
            BanButtons:SetScript ( "OnClick" , function ( self , button )
                if button == "LeftButton" then
                    -- For highlighting purposes
                    for j = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons do
                        if self ~= GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1] then
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1]:UnlockHighlight();
                        else
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1]:LockHighlight();
                        end
                    end
                    local fullName = BanNameText:GetText();
                    local R,G,B = BanNameText:GetTextColor();

                    GRM_G.TempBanTarget = { string.sub ( fullName , 1 , string.find ( fullName , " " ) - 1 ) , { GRM.ConvertRGBScale ( R , true ) , GRM.ConvertRGBScale ( G , true ) , GRM.ConvertRGBScale ( B , true ) } }; -- Need to parse out the "(Still in Guild)"
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:SetText ( GRM.SlimName ( fullName ) );
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetText ( GRM.L ( "Player Selected" ) );
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:Show();
                    
                end
            end);
            
            -- Now let's pin it!
            
            if count == 1 then
                BanButtons:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame , "TOPLEFT" , 5 , -12 );
                BanNameText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame , "TOPLEFT" , 5 , -12 );
                BanRankText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame , "TOP" , 64 , -12 );
                BanDateText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame , "TOP" , 211 , -12 );
                scrollHeight = scrollHeight + BanButtons:GetHeight() + BanReasonText:GetHeight();
            else
                BanButtons:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count - 1][5] , "BOTTOMLEFT" , 0 , - buffer );
                BanNameText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count - 1][5] , "BOTTOMLEFT" , 0 , - buffer );
                BanRankText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count - 1][3] , "BOTTOM" , 0 , - ( tempHeight + buffer ) );
                BanDateText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count - 1][4] , "BOTTOM" , 0 , - ( tempHeight + buffer ) );
                scrollHeight = scrollHeight + BanButtons:GetHeight() + BanReasonText:GetHeight() + buffer;
            end
            BanButtons:Show();
            tempHeight = BanReasonText:GetHeight() + ( BanButtons:GetHeight() - BanNameText:GetHeight() ) + 1;
        end
    end

    -- Populating the window based on the Left PLayers
    for i = #GRM_PlayersThatLeftHistory_Save[GRM_G.FID][GRM_G.saveGID] , 2 , -1 do
        -- if font string is not created, do so.
        if GRM_PlayersThatLeftHistory_Save[GRM_G.FID][GRM_G.saveGID][i][17][1] then  -- If player is banned.
                
            count = count + 1;
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count] then
                local tempButton = CreateFrame ( "Button" , "BannedPlayer" .. count , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame ); -- Names each Button 1 increment up
                table.insert ( GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons , { tempButton , tempButton:CreateFontString ( "BannedPlayerNameText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "BannedPlayerRankText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "BannedPlayerDateText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "BannedPlayerReasonText" .. count , "OVERLAY" , "GameFontWhiteTiny" ) } );
            end

            local BanButtons = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][1];
            local BanNameText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][2];
            local BanRankText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][3];
            local BanDateText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][4];
            local BanReasonText = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count][5];
            local classColor = GRM.GetClassColorRGB ( GRM_PlayersThatLeftHistory_Save[GRM_G.FID][GRM_G.saveGID][i][9] );

            BanButtons:SetWidth ( 555 );
            BanButtons:SetHeight ( 19 );
            BanButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
            BanNameText:SetText ( GRM_PlayersThatLeftHistory_Save[GRM_G.FID][GRM_G.saveGID][i][1] );
            BanNameText:SetTextColor ( classColor[1] , classColor[2] , classColor[3] , 1 );
            BanNameText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 12 );
            BanNameText:SetJustifyH ( "LEFT" );
            BanRankText:SetText ( GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][i][19] );
            BanRankText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 12 );
            BanRankText:SetJustifyH ( "CENTER" );
            BanRankText:SetTextColor ( 0.90 , 0.80 , 0.50 , 1.0 );
            BanDateText:SetText ( GRM.FormatTimeStamp ( GRM.EpochToDateFormat ( GRM_PlayersThatLeftHistory_Save[GRM_G.FID][GRM_G.saveGID][i][17][2] ) , false ) );
            BanDateText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 12 );
            -- Determine it's not an empty ban reason!
            local reason = "";
            if GRM_PlayersThatLeftHistory_Save[GRM_G.FID][GRM_G.saveGID][i][18] == "" or GRM_PlayersThatLeftHistory_Save[GRM_G.FID][GRM_G.saveGID][i][18] == nil then
                reason = GRM.L ( "No Ban Reason Given" );
            else
                reason = GRM_PlayersThatLeftHistory_Save[GRM_G.FID][GRM_G.saveGID][i][18];
            end
            BanReasonText:SetText ( "|CFFFF0000" .. GRM.L ( "Reason:" ) .. " |CFFFFFFFF" .. reason );
            BanReasonText:SetWidth ( 245 );
            BanReasonText:SetWordWrap ( true );
            BanReasonText:SetSpacing ( 1 );
            BanReasonText:SetFont ( GRM_G.FontChoice , GRM_G.FontModifier + 12 );
            BanReasonText:SetPoint ( "TOPLEFT" , BanButtons , "BOTTOMLEFT" , 0 , -1);
            BanReasonText:SetJustifyH ( "LEFT" );

            -- Logic
            BanButtons:SetScript ( "OnClick" , function ( self , button )
                if button == "LeftButton" then
                    -- For highlighting purposes
                    for j = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons do
                        if self ~= GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1] then
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1]:UnlockHighlight();
                        else
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1]:LockHighlight();
                        end
                    end
                    
                    local fullName = BanNameText:GetText();
                    local R,G,B = BanNameText:GetTextColor();
                    GRM_G.TempBanTarget = { fullName , { GRM.ConvertRGBScale ( R , true ) , GRM.ConvertRGBScale ( G , true ) , GRM.ConvertRGBScale ( B , true ) } };
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:SetText ( GRM.SlimName ( fullName ) );
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetText ( GRM.L ( "Player Selected" ) );
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:Show();
                    
                end
            end);
            
            -- Now let's pin it!
            
            if count == 1 then
                BanButtons:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame , "TOPLEFT" , 5 , -12 );
                BanNameText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame , "TOPLEFT" , 5 , -12 );
                BanRankText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame , "TOP" , 62 , -12 );
                BanDateText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame , "TOP" , 210 , -12 );
                scrollHeight = scrollHeight + BanButtons:GetHeight() + BanReasonText:GetHeight();
            else
                BanButtons:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count - 1][5] , "BOTTOMLEFT" , 0 , - buffer );
                BanNameText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count - 1][5] , "BOTTOMLEFT" , 0 , - buffer );
                BanRankText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count - 1][3] , "BOTTOM" , 0 , - ( tempHeight + buffer ) );
                BanDateText:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[count - 1][4] , "BOTTOM" , 0 , - ( tempHeight + buffer ) );
                scrollHeight = scrollHeight + BanButtons:GetHeight() + BanReasonText:GetHeight() + buffer;
            end
            BanButtons:Show();
            tempHeight = BanReasonText:GetHeight() + ( BanButtons:GetHeight() - BanNameText:GetHeight() ) + 1;
        end
    end


    -- Ok, let's add a count to how many banned
    if count > 0 then
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText:SetText( "(" .. GRM.L ( "Total Banned:" ) .. " " .. count .. ")" );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText:Show();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:Show();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:Hide();
    else
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameNumBannedText:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:Hide();
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameAllOfflineText:Show();
    end

    -- Hides all the additional buttons... if necessary ( necessary because once initialized, the buttons are there. This avoids bloated code and too much purging and rebuilding and purging. Just hide for future use.
    for i = count + 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons do
        GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[i][1]:Hide();
    end 
    
    -- Update the size -- it either grows or it shrinks!
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame:SetSize ( scrollWidth , scrollHeight );

    --Set Slider Parameters ( has to be done after the above details are placed )
    local scrollMax = ( scrollHeight - 348 ) + ( buffer * .5 ) + tempHeight;
    if scrollMax < 0 then
        scrollMax = 0;
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:SetMinMaxValues ( 0 , scrollMax );
    -- Mousewheel Scrolling Logic
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrame:EnableMouseWheel( true );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrame:SetScript( "OnMouseWheel" , function( _ , delta )
        local current = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:GetValue();
        
        if IsShiftKeyDown() and delta > 0 then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:SetValue ( 0 );
        elseif IsShiftKeyDown() and delta < 0 then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:SetValue ( scrollMax );
        elseif delta < 0 and current < scrollMax then
            if IsControlKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:SetValue ( current + 60 );
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:SetValue ( current + 20 );
            end
        elseif delta > 0 and current > 1 then
            if IsControlKeyDown() then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:SetValue ( current - 60 );
            else
                GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrameSlider:SetValue ( current - 20 );
            end
        end
    end);
end


--- FINALLY!!!!!
--- TOOLTIPS ---
----------------

-- Method:          GRM.MemberDetailToolTips ( self , float )
-- What it Does:    Populates the tooltips on the "OnUpdate" check for the core Member Detail frame
-- Purpose:         UI Feature  
-- Note:            self = GRM_UI.GRM_MemberDetailMetaData
GRM.MemberDetailToolTips = function ( self , elapsed )
    GRM_G.timer2 = GRM_G.timer2 + elapsed;
    if GRM_G.timer2 >= 0.075 then
        local name = GRM_G.currentName;

        -- Rank Text
        -- Only populate and show tooltip if mouse is over text frame and it is not already visible.
        if self.GRM_MemberDetailRankToolTip:IsVisible() ~= true and not StaticPopup1:IsVisible() and not DropDownList1:IsVisible() and self.GRM_MemberDetailRankDateTxt:IsVisible() == true and GRM_UI.GRM_altDropDownOptions:IsVisible() ~= true and self.GRM_MemberDetailRankDateTxt:IsMouseOver(1,-1,-1,1) == true then
            
            self.GRM_MemberDetailRankToolTip:SetOwner( self.GRM_MemberDetailRankDateTxt , "ANCHOR_BOTTOMRIGHT" );
            self.GRM_MemberDetailRankToolTip:AddLine( "|cFFFFFFFF" .. GRM.L ( "Rank History" ) );

            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == name then   --- Player Found in MetaData Logs
                    -- Now, let's build the tooltip
                    if self.GRM_MemberDetailRankDateTxt:GetText() == GRM.L ( "Promoted:" ) .. " " .. GRM.L ( "Unknown" ) then
                        self.GRM_MemberDetailRankToolTip:AddDoubleLine ( "|cFFFF0000" .. GRM.L ( "Time at Rank:" ) , GRM.L ( "Unknown" ) );
                        self.GRM_MemberDetailRankToolTip:AddDoubleLine ( " " , " " );
                        self.GRM_MemberDetailRankToolTip:AddLine ( GRM.L ( "Right-Click to Edit" ) );
                    else
                        for k = #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][25] , 1 , -1 do
                            if k == #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][25] then
                                local timeAtRank = GRM.GetTimePassedUsingStringStamp ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][12] );
                                self.GRM_MemberDetailRankToolTip:AddDoubleLine ( "|cFFFF0000" .. GRM.L ( "Time at Rank:" ) , timeAtRank[4] );
                                self.GRM_MemberDetailRankToolTip:AddDoubleLine ( " " , " " );
                            end
                            self.GRM_MemberDetailRankToolTip:AddDoubleLine(  string.gsub ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][25][k][1] , "Left Guild" , GRM.L ( "Left Guild" ) ) .. ":" , GRM.FormatTimeStamp ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][25][k][2] , false ) , 0.38 , 0.67 , 1.0 );
                        end
                    end
                    break;
                end
            end

            self.GRM_MemberDetailRankToolTip:Show();
        elseif self.GRM_MemberDetailRankToolTip:IsVisible() == true and self.GRM_MemberDetailRankDateTxt:IsMouseOver(1,-1,-1,1) ~= true then
            self.GRM_MemberDetailRankToolTip:Hide();
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:Hide();
        end

        -- JOIN DATE TEXT
        if self.GRM_MemberDetailJoinDateToolTip:IsVisible() ~= true and not StaticPopup1:IsVisible() and self.GRM_JoinDateText:IsVisible() == true and GRM_UI.GRM_altDropDownOptions:IsVisible() ~= true and self.GRM_JoinDateText:IsMouseOver(1,-1,-1,1) == true then
           
            self.GRM_MemberDetailJoinDateToolTip:SetOwner( self.GRM_JoinDateText , "ANCHOR_BOTTOMRIGHT" );
            self.GRM_MemberDetailJoinDateToolTip:AddLine( "|cFFFFFFFF" .. GRM.L ( "Membership History" ) );
            local joinedHeader;

            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == name then   --- Player Found in MetaData Logs
                    -- Ok, let's build the tooltip now.
                    if self.GRM_JoinDateText:GetText() == GRM.L ( "Unknown" ) then
                        self.GRM_MemberDetailJoinDateToolTip:AddDoubleLine ( GRM.L ( "Joined:" ) , GRM.L ( "Unknown" ) );
                        self.GRM_MemberDetailJoinDateToolTip:AddDoubleLine ( " " , " " );
                        self.GRM_MemberDetailJoinDateToolTip:AddLine ( GRM.L ( "Right-Click to Edit" ) );
                    else
                        for r = #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][20] , 1 , -1 do                                       -- Starting with most recent join which will be at end of array.
                            if r == #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][20] then
                                self.GRM_MemberDetailJoinDateToolTip:AddDoubleLine ( "|cFFFF0000" .. GRM.L ( "Time as Member:" ) , GRM.GetTimePlayerHasBeenMember ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] ) );
                                self.GRM_MemberDetailJoinDateToolTip:AddDoubleLine ( " " , " " );
                            end
                            if r > 1 then
                                joinedHeader = GRM.L ( "Rejoined:" );
                            else
                                joinedHeader = GRM.L ( "Joined:" );
                            end
                            if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][15][r] ~= nil then
                                self.GRM_MemberDetailJoinDateToolTip:AddDoubleLine( "|CFFC41F3B" .. GRM.L ( "Left:" ) ,  GRM.FormatTimeStamp ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][15][r] , false ) , 1 , 0 , 0 );
                            end
                            self.GRM_MemberDetailJoinDateToolTip:AddDoubleLine( joinedHeader , GRM.FormatTimeStamp ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][20][r] , false ) , 0.38 , 0.67 , 1.0 );
                            -- If player once left, then this will add the line for it.
                        end
                    end
                break;
                end
            end

            self.GRM_MemberDetailJoinDateToolTip:Show();
        elseif self.GRM_JoinDateText:IsMouseOver(1,-1,-1,1) ~= true and ( self.GRM_MemberDetailJoinDateToolTip:IsVisible() or GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:IsVisible() ) then
            self.GRM_MemberDetailJoinDateToolTip:Hide();
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:Hide();
        end

        -- Mouseover name shows full server... useful on merged realms.
        if not GRM_UI.GRM_altDropDownOptions:IsVisible() and not StaticPopup1:IsVisible() and self.GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
            -- Get Class Color
            local textR, textG, textB = self.GRM_MemberDetailNameText:GetTextColor();

            -- Build the tooltip
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:SetOwner ( self.GRM_JoinDateText , "ANCHOR_CURSOR" );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:AddLine ( name , textR , textG , textB );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:Show();
        else
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:Hide();
        end

        if not self.GRM_DateSubmitButton:IsVisible() and not self.GRM_MemberDetailNJDSyncTooltip:IsVisible() and not self.GRM_SyncJoinDateSideFrame:IsVisible() and self.GRM_MemberDetailDateJoinedTitleTxt:IsMouseOver ( 1 , -1 , -1 , 1 ) and GRM.PlayerOrAltHasJD ( name ) then
            self.GRM_MemberDetailNJDSyncTooltip:SetOwner ( self.GRM_MemberDetailDateJoinedTitleTxt , "ANCHOR_CURSOR" );
            if GRM.IsAltJoinDatesSynced ( name ) then
                self.GRM_MemberDetailNJDSyncTooltip:AddLine( GRM.L ( "Join Date of All Alts is Currently Synced" ) );
            else
                self.GRM_MemberDetailNJDSyncTooltip:AddLine( GRM.L ( "|CFFE6CC7FRight-Click|r to Sync Join Date with Alts" ) );
            end
            self.GRM_MemberDetailNJDSyncTooltip:Show();
        elseif not self.GRM_MemberDetailDateJoinedTitleTxt:IsMouseOver ( 1 , -1 , -1 , 1 ) and self.GRM_MemberDetailNJDSyncTooltip:IsVisible() then
            self.GRM_MemberDetailNJDSyncTooltip:Hide();
        end

        -- Mouseover on Alt Names
        if ( GRM_UI.GRM_CoreAltFrame.GRM_AltName1:IsVisible() or ( GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons ~= nil and GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons[1][1]:IsVisible() ) ) and not StaticPopup1:IsVisible() and not GRM_UI.GRM_altDropDownOptions:IsVisible() then
            
            if GRM_UI.GRM_altFrameTitleText:IsMouseOver( 1 , -1 , -1 , 1 ) then

                if not IsShiftKeyDown() and not GRM_UI.GRM_AltGroupingScrollBorderFrame:IsVisible() then
                    -- Build the tooltip
                    GRM_UI.GRM_MemberDetailMetaData.GRM_AltGroupingTooltip:SetOwner ( GRM_UI.GRM_altFrameTitleText , "ANCHOR_CURSOR" );
                    GRM_UI.GRM_MemberDetailMetaData.GRM_AltGroupingTooltip:AddLine ( GRM.L ( "|CFFE6CC7FHold Shift|r to view more alt details." ) );
                    GRM_UI.GRM_MemberDetailMetaData.GRM_AltGroupingTooltip:AddLine( GRM.L ( "|CFFE6CC7FShift-Click|r to keep alt details open." ) );
                    GRM_UI.GRM_MemberDetailMetaData.GRM_AltGroupingTooltip:Show();
                elseif IsShiftKeyDown() and not GRM_UI.GRM_AltGroupingScrollBorderFrame:IsVisible() then
                    GRM_UI.GRM_AltGroupingScrollBorderFrame:Show();        -- The OnShow will have the trigger action...
                    GRM_G.pause = true;
                end
            else
                GRM_G.tempAltName = "";
                for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ] do
                    if GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][1] == name then   --- Player Found in MetaData Logs
                        local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][j][11];

                            -- for regular frames
                            if #listOfAlts <= 12 then
                                local numAlt = 0;
                                if GRM_UI.GRM_CoreAltFrame.GRM_AltName1:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName1:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    numAlt = numAlt + 1;
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName1 , "ANCHOR_CURSOR" );
                                elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName2:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName2:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    numAlt = numAlt + 2;
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName2 , "ANCHOR_CURSOR" );
                                elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName3:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName3:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    numAlt = numAlt + 3;
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName3 , "ANCHOR_CURSOR" );
                                elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName4:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName4:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    numAlt = numAlt + 4;
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName4 , "ANCHOR_CURSOR" );
                                elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName5:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName5:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    numAlt = numAlt + 5;
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName5 , "ANCHOR_CURSOR" );
                                elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName6:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName6:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    numAlt = numAlt + 6;
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName6 , "ANCHOR_CURSOR" );
                                elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName7:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName7:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    numAlt = numAlt + 7;
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName7 , "ANCHOR_CURSOR" );
                                elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName8:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName8:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    numAlt = numAlt + 8;
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName8 , "ANCHOR_CURSOR" );
                                elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName9:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName9:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    numAlt = numAlt + 9;
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName9 , "ANCHOR_CURSOR" );
                                elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName10:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName10:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    numAlt = numAlt + 10;
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName10 , "ANCHOR_CURSOR" );
                                elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName11:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName11:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    numAlt = numAlt + 11;
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName11 , "ANCHOR_CURSOR" );
                                elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName12:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName12:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    numAlt = numAlt + 12;
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName12 , "ANCHOR_CURSOR" );
                                end

                                if numAlt > 0 then
                                    GRM_G.tempAltName = listOfAlts[numAlt][1];
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[numAlt][1] , listOfAlts[numAlt][2] , listOfAlts[numAlt][3] , listOfAlts[numAlt][4] );
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:Show();
                                elseif not self.GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:Hide();
                                end

                            else
                                local isOver = false;
                                if GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons ~= nil then
                                    for i = 1 , #GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons do
                                        if GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons[i][1]:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons[i][1]:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                            GRM_G.tempAltName = listOfAlts[i][1];
                                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons[i][1] , "ANCHOR_CURSOR" );
                                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[i][1] , listOfAlts[i][2] , listOfAlts[i][3] , listOfAlts[i][4] );
                                            isOver = true;
                                            break;
                                        end
                                    end
                                end

                                if isOver and not GRM_UI.GRM_altDropDownOptions:IsVisible() then
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:Show();
                                elseif GRM_UI.GRM_altDropDownOptions:IsVisible() and not self.GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:Hide();
                                end
                            end

                        break;
                    end
                end
            end
        elseif not self.GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailServerNameToolTip:Hide();
        end

        -- Player status notification to let people know they can edit it.
        if self.GRM_MemberDetailPlayerStatus:IsMouseOver ( 1 , -1 , -1 , 1 ) and not GRM_UI.GRM_altDropDownOptions:IsVisible() then
            self.GRM_MemberDetailNotifyStatusChangeTooltip:SetOwner ( self.GRM_MemberDetailPlayerStatus , "ANCHOR_CURSOR" );
            self.GRM_MemberDetailNotifyStatusChangeTooltip:AddLine ( "|cFFFFFFFF" .. GRM.L ( "|CFFE6CC7FRight-Click|r to Set Notification of Status Change" ) );

            self.GRM_MemberDetailNotifyStatusChangeTooltip:Show();
        else
            self.GRM_MemberDetailNotifyStatusChangeTooltip:Hide();
        end

        -- Logic for when to hide the Alt groupings optional side frame
        if GRM_UI.GRM_AltGroupingScrollBorderFrame:IsVisible() and not GRM_G.AltSideWindowFreeze then
            if ( not GRM_UI.GRM_altFrameTitleText:IsMouseOver( 1 , -1 , -1 , 1 ) and not GRM_UI.GRM_AltGroupingScrollBorderFrame:IsMouseOver ( 10 , -2 , -135 , 20 ) ) or ( ( GRM_UI.GRM_altFrameTitleText:IsMouseOver( 1 , -1 , -1 , 1 ) or GRM_UI.GRM_AltGroupingScrollBorderFrame:IsMouseOver( 10 , -2 , -135 , 20 ) ) and not IsShiftKeyDown() ) then
                GRM_UI.GRM_AltGroupingScrollBorderFrame:Hide();
                GRM_G.pause = false;
            end
        end

        -- Cleanup of this alt grouping tooltip
        if GRM_UI.GRM_MemberDetailMetaData.GRM_AltGroupingTooltip:IsVisible() and not GRM_UI.GRM_altFrameTitleText:IsMouseOver( 1 , -1 , -1 , 1 ) then
            GRM_UI.GRM_MemberDetailMetaData.GRM_AltGroupingTooltip:Hide();
        end

        GRM_G.timer2 = 0;
    end
end


----------------------
--- FRAME VALUES -----
--- AND PARAMETERS ---
----------------------

-- Method:          GRM.GetTransitionFrameToFade()
-- What it Does:    Gets the frame that is currently visible. The tab the player is currently looking at.
-- Purpose:         To save on resources, rather than reuse this code over and over. I could potentially just make a global holder, but I want it to be flixible.
GRM.GetTransitionFrameToFade = function()
    local fadeFrame;
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame:GetAlpha() == 1 then
        fadeFrame = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame;
    elseif GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame:GetAlpha() == 1 then
        fadeFrame = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame;
    elseif GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:GetAlpha() == 1 then
        fadeFrame = GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame;
    elseif GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:GetAlpha() == 1 then
        fadeFrame = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame;
    elseif GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:GetAlpha() == 1 then
        fadeFrame = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame;
    elseif GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:GetAlpha() == 1 then
        fadeFrame = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame;
    end
    return fadeFrame;
end

-- Method:          GRM.FrameTransition()
-- What it Does:    Fades frame to frame on tab check...
-- Purpose:         Really, just aesthetics for User Experience. This also is built to be flexible, to account for any given tab.
GRM.FrameTransition = function( fadeInName , fadeOutName , isOptionsTab , isOptionsSubTab )
    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][52] then 
        if fadeInName ~= nil then
            fadeInName:Show();
            fadeInName:SetAlpha( fadeInName:GetAlpha() + 0.04 );
        end
        if fadeOutName ~= nil then
            fadeOutName:SetAlpha( fadeOutName:GetAlpha() - 0.04 );
        end

        if ( fadeInName ~= nil and fadeInName:GetAlpha() < 1 ) or ( fadeInName == nil and fadeOutName:GetAlpha() > 0 ) then
            C_Timer.After ( 0.01 , function()
                GRM.FrameTransition ( fadeInName , fadeOutName , isOptionsTab , isOptionsSubTab );
            end);
        else
            if fadeOutName ~= nil then
                fadeOutName:SetAlpha ( 0 );
                fadeOutName:Hide();
            end
            if fadeInName ~= nil then
                fadeInName:SetAlpha ( 1 );
            end
            if isOptionsTab then
                GRM.DisableTabButtons ( false );
            elseif isOptionsSubTab then
                GRM.DisableSubTabButtons ( false );
            end
        end
    else
        if fadeInName ~= nil then
            fadeInName:SetAlpha ( 1 );
            fadeInName:Show();
        end
        if fadeOutName ~= nil then
            fadeOutName:SetAlpha ( 0 );
            fadeOutName:Hide();
        end
        if isOptionsTab then
            GRM.DisableTabButtons ( false );
        elseif isOptionsSubTab then
            GRM.DisableSubTabButtons ( false );
        end
    end
end

-- Method:          GRM.OptionTabFrameControl ( buttonWidget )
-- What it Does:    It Locks the highlight of the current tab and it unlocks the others, as well as showing the correct frame, whilst hiding the others
-- Purpose:         Options are plentiful. Need sub-tabs to keep it clean. This helps control UI display logic on the tabs.
GRM.OptionTabFrameControl = function ( tabNotToUnlock )
    GRM.DisableSubTabButtons ( true );
    local tabs = { GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralTab , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanTab , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncTab , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpTab , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UITab , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerTab };
    local frames = { GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralOptionsFrame , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpOptionsFrame , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UIOptionsFrame , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerOptionsFrame };
    local fadeFrame;
    local fadeInFrame; 
            
    for i = 1 , #tabs do
        if tabs[i] ~= tabNotToUnlock then
            -- Lock highlight
            tabs[i]:UnlockHighlight();
        else
            -- Corresponding tab frame should now be shown whilst hiding the rest. Index will match
            fadeInFrame = frames[i];                
        end
    end

    for j = 1 , #frames do
        if frames[j]:GetAlpha() == 1 then
            fadeFrame = frames[j];
            break;
        end
    end
    -- Ok, let's do the work!
    GRM.FrameTransition ( fadeInFrame , fadeFrame , false , true );
end

-- Method:          GRM.DisableTabButtons()
-- What it Does:    Temporarily disables the buttons. Don't want to allow player to trigger click spam the button on transition.
-- Purpose:         Clicking button too fast will be error prone.
local tempTabScript = {};
GRM.DisableTabButtons = function( toDisable )
    if toDisable then
        -- Storing the scripts
        tempTabScript = { GRM_UI.GRM_RosterChangeLogFrame.GRM_LogTab:GetScript ( "OnClick" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsTab:GetScript ( "OnClick" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersTab:GetScript ( "OnClick" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddEventTab:GetScript ( "OnClick" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_BanListTab:GetScript ( "OnClick" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_GuildAuditTab:GetScript ( "OnClick" ) };

        -- removing the script
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogTab:SetScript ( "OnClick" , nil );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsTab:SetScript ( "OnClick" , nil );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersTab:SetScript ( "OnClick" , nil );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AddEventTab:SetScript ( "OnClick" , nil );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_BanListTab:SetScript ( "OnClick" , nil );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_GuildAuditTab:SetScript ( "OnClick" , nil );
    else
        -- restoring the script
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogTab:SetScript ( "OnClick" , tempTabScript[1] );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsTab:SetScript ( "OnClick" , tempTabScript[2] );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersTab:SetScript ( "OnClick" , tempTabScript[3] );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AddEventTab:SetScript ( "OnClick" , tempTabScript[4] );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_BanListTab:SetScript ( "OnClick" , tempTabScript[5] );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_GuildAuditTab:SetScript ( "OnClick" , tempTabScript[6] );
    end
end

-- Method:          GRM.DisableSubTabButtons()
-- What it Does:    Temporarily disables the Options sub tab buttons. Don't want to allow player to trigger click spam the button on transition.
-- Purpose:         Clicking button too fast will be error prone. This prevents that.
local tempTabScript2 = {};
GRM.DisableSubTabButtons = function( toDisable )
    if toDisable then
        -- Storing the scripts
        tempTabScript2 = { GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralTab:GetScript ( "OnClick" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanTab:GetScript ( "OnClick" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncTab:GetScript ( "OnClick" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpTab:GetScript ( "OnClick" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UITab:GetScript ( "OnClick" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerTab:GetScript ( "OnClick" ) };

        -- removing the script
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralTab:SetScript ( "OnClick" , nil );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanTab:SetScript ( "OnClick" , nil );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncTab:SetScript ( "OnClick" , nil );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpTab:SetScript ( "OnClick" , nil );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UITab:SetScript ( "OnClick" , nil );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerTab:SetScript ( "OnClick" , nil );
    else
        -- restoring the script
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_GeneralTab:SetScript ( "OnClick" , tempTabScript2[1] );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanTab:SetScript ( "OnClick" , tempTabScript2[2] );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncTab:SetScript ( "OnClick" , tempTabScript2[3] );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_HelpTab:SetScript ( "OnClick" , tempTabScript2[4] );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_UITab:SetScript ( "OnClick" , tempTabScript2[5] );
        GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_OfficerTab:SetScript ( "OnClick" , tempTabScript2[6] );
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
            GRM_UI.GRM_GroupInfo.GRM_NumGuildiesText:SetText ( "Guildies: " .. numGuildies );
            GRM_UI.GRM_GroupInfo.GRM_NumGuildiesText:Show();
        else
            GRM_UI.GRM_GroupInfo.GRM_NumGuildiesText:Hide();
        end
        C_Timer.After ( 1 , GRM.UpdateGuildMemberInRaidStatus );              -- Check for updates recursively
    elseif IsInGroup() then
        GRM_UI.GRM_GroupInfo.GRM_NumGuildiesText:Hide();
        C_Timer.After ( 1 , GRM.UpdateGuildMemberInRaidStatus );
    else
        GRM_UI.GRM_GroupInfo.GRM_NumGuildiesText:Hide();
        GRM_G.RaidGCountBeingChecked = false;
    end
end

-- Method:          GRM.GetPlayersOnRecruitListCurrentlyOnline()
-- What it Does:    Returns the string list of names of all players currently online who are requesting to join the guild
-- Purpose:         For auto-Scroll tracking...
GRM.GetPlayersOnRecruitListCurrentlyOnline = function()
    local names = {};
    local tempList = GRM_G.RequestToJoinPlayersCurrentlyOnline;
    for i = 1 , #tempList do 
        if tempList[i][2] then
            table.insert ( names , tempList[i] );
        end
    end
    return names;
end

-- Method:          GRM.GoToNextOnline ( boolean , boolean )
-- What it Does:    Determines the position in the hybridscrollframe to go to of the next person online in the chain, either forward or backwards in the list of recruits
-- Purpose:         Quality of life UI controls. Bounce right to the person online to invite!
GRM.GoToNextOnline = function( isForward , isHyperlinkClick )
    local namesOnline = GRM.GetPlayersOnRecruitListCurrentlyOnline(); -- No need to do all this other work if at the end of this no players are online requesting to join.

    if #namesOnline > 0 then
        if isHyperlinkClick then
            CommunitiesGuildRecruitmentFrameApplicantsContainer.scrollBar:SetValue(0);
        end
        local numApps = GetNumGuildApplicants();
        local jumpPerButton = 84;
        local maxScroll = select ( 2 , CommunitiesGuildRecruitmentFrameApplicantsContainer.scrollBar:GetMinMaxValues() )
        local currentOffset = HybridScrollFrame_GetOffset ( CommunitiesGuildRecruitmentFrameApplicantsContainer );
        local buttons = CommunitiesGuildRecruitmentFrameApplicantsContainer.buttons;   

        -- These values will control the for loops by setting them to either travel forward or backwards without having to write multiple functions...
        local firstValue = currentOffset + 1;
        local second , increment, firstOutside , secondOutside , ousideIncrement;
        if isForward then
            firstOutside = 1;
            secondOutside = #namesOnline;
            ousideIncrement = 1;
            second = numApps;
            increment = 1;
        else
            firstOutside = #namesOnline;
            secondOutside = 1;
            ousideIncrement = -1
            second = 1;
            increment = -1;
        end

        -- For loop capable of traveling forward and backwards based on the context.
        local result = {};
        for i = firstOutside , secondOutside , ousideIncrement do
            for j = firstValue , second , increment do
                local name = GetGuildApplicantInfo ( j );
                if string.find ( name , "-" ) == nil then
                    name = name .. "-" .. GRM_G.realmName;              -- Appending the name
                end
                
                if name == namesOnline[i][1] then
                    print("Name: " .. name .. " - Position: " .. j );
                    result = {i,j};
                    break;
                end
            end
        end
    end    
end

-- Method:          GRM.SlashCommandRecruitWindow()
-- What it Does:    It opens up the roster menu to the recruit window.
-- Purpose:         Easy access to recruit window really is all...
GRM.SlashCommandRecruitWindow = function()
    if CanGuildInvite() then
        RequestGuildApplicantsList();
        local numApps = GetNumGuildApplicants();
        if numApps > 0 then
            if CommunitiesFrame == nil or ( CommunitiesFrame ~= nil and not CommunitiesFrame:IsVisible() ) then
                GuildMicroButton:Click();
                CommunitiesFrame:Show();
            end           
            CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton:Click();
            CommunitiesGuildRecruitmentFrameTab2:Click();
        else
            chat:AddMessage ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "There are No Current Applicants Requesting to Join the Guild." ) );
        end
    else
        chat:AddMessage ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "The Applicant List is Unavailable Without Having Invite Privileges." ) );
    end
end

-- Method:          GRM.ReportGuildJoinApplicants()
-- What it Does:    Returns true if there is a current request to join the guild
-- Purpose:         To remind anyone with guild invite privileges to review if player has requested to join
GRM.ReportGuildJoinApplicants = function()
    if CanGuildInvite() then                    -- No point in checking this if you don't have invite privileges and you can't see the application!
        RequestGuildApplicantsList();
        
        local numApps = GetNumGuildApplicants();
        if numApps > 0 and numApps ~= GRM_G.numPlayersRequestingGuildInv then
            GRM_G.numPlayersRequestingGuildInv = numApps;
            -- Initialize listening (placed here as not all players need listening)
            if not GRM_G.isHyperlinkListenInitialized then
                GRM_G.isHyperlinkListenInitialized = true;
                chat:HookScript ( "OnHyperlinkClick" , function( _ , _ , link , button )
                    if button == "LeftButton" then
                        if string.find ( link , GRM.L ( "Guild Recruits" ) ) ~= nil then
                            GRM.SlashCommandRecruitWindow();
                        end
                    end                
                end);
            end
            if CommunitiesGuildRecruitmentFrameApplicantsContainer == nil or ( CommunitiesGuildRecruitmentFrameApplicantsContainer ~= nil and not CommunitiesGuildRecruitmentFrameApplicantsContainer:IsVisible() ) then
                if numApps > 1 then
                    chat:AddMessage ( "\n" .. GRM.L ( "GRM:" ) .. " " .. GRM.L ( "{num} Players Have Requested to Join the Guild." , nil , nil , numApps ) .. "\n" .. GRM.L ( "Click Link to Open Recruiting Window:" ) .. "\124cffffff00\124Hquest:0:0\124h[" .. GRM.L ( "Guild Recruits" ) .. "]\124h\124r\n" , 0 , 0.77 , 0.95 , 1 );
                else
                    chat:AddMessage ( "\n" .. GRM.L ( "GRM:" ) .. " " .. GRM.L ( "A Player Has Requested to Join the Guild." ) .. "\n" .. GRM.L ( "Click Link to Open Recruiting Window:" ) .. "\124cffffff00\124Hquest:0:0\124h[" .. GRM.L ( "Guild Recruits" ) .. "]\124h\124r\n" , 0 , 0.77 , 0.95 , 1 );
                end
            end
        end
    end
end


-- Method:              GRM.GR_Roster_Click ( string )
-- What it Does:        For logic on mouseover, instead of mouseover, it simulates a click on the item by bringing it to show.
--                      The "pause" is just a call to pause the hiding of the frame in the GRM_RosterFrame() function until it finds a new window (to prevent wasteful clicking and resource hogging)
-- Purpose:             Smoother UI interface in the built-in Guild Roster in-game UI default window.
GRM.GR_Roster_Click = function ( name )
    local time = GetTime();
    if GRM_G.timer3 == 0 or time - GRM_G.timer3 > 0.5 then   -- 500ms
        -- We are going to be copying the name if the shift key is down!

        if IsShiftKeyDown() and not GRM_G.RecursiveStop then

            if GetCurrentKeyBoardFocus() ~= nil then
                if GetCurrentKeyBoardFocus():GetName() ~= nil then
                    if "GRM_AddAltEditBox" == GetCurrentKeyBoardFocus():GetName() then
                        GetCurrentKeyBoardFocus():SetText ( name );
                    else
                        GetCurrentKeyBoardFocus():Insert ( GRM.SlimName ( name ) ); -- Adds it at the cursor position...
                    end
                end

                GRM_G.RecursiveStop = true;

                if GetCurrentKeyBoardFocus() ~= nil then
                    if GetCurrentKeyBoardFocus():GetName() ~= nil and GetCurrentKeyBoardFocus():GetName() == "GRM_AddAltEditBox" then
                        GRM.AddAltAutoComplete();
                        GRM_G.pause = true;
                    end
                end
            else
                -- Since player doesn't have keyboard focus, let's just default it to main chat window
                ChatFrame1EditBox:SetFocus()
                ChatFrame1EditBox:Insert ( GRM.SlimName ( name ) );
            end
        end
        GRM_G.timer3 = time;
    end
    GRM_G.RecursiveStop = false;
end

-- Method:          GRM.TriggerTrackingCheck()
-- What it Does:    Helps regulate some resource and timed efficient server queries, 
-- Purpose:         to keep from spamming or double+ looping functions.
GRM.TriggerTrackingCheck = function()
    if ( CalendarCreateEventDescriptionEdit and CalendarCreateEventDescriptionEdit:HasFocus() ) or ( CalendarMassInviteFrame and CalendarMassInviteFrame:IsVisible() ) then
        C_Timer.After ( 5 , GRM.TriggerTrackingCheck );                                             -- Check again in 5 seconds.
    else
        GRM_G.trackingTriggered = false;
        if not CommunitiesFrame or not CommunitiesFrame:IsVisible() then
            GuildRoster();
        end
        QueryGuildEventLog();
    end
end

---------------------------------------------
-------- SLASH COMMAND FUNCTIONS ------------
---------------------------------------------

-- Method:          GRM.SlashCommandScan()
-- What it Does:    Triggers a one-time scan of the guild for changes.
-- Purpose:         Mainly useful for people that wish to disable active scanning and just do a 1-time check on occasion.
GRM.SlashCommandScan = function()
    chat:AddMessage ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "Scanning for Guild Changes Now. One Moment..." ) , 1.0 , 0.84 , 0 );
    GRM_G.ManualScanEnabled = true;
    C_Timer.After ( 5 , GRM.TriggerTrackingCheck );
end

-- Method:          GRM.SyncCommandScan()
-- What it Does:    Activates a one-time data sync with guildies
-- Purpose:         For people that want to sync data, but don't want it to be on all the time, just on occasion as they choose.
--                  Flexibility to the user!
GRM.SyncCommandScan = function()
    if GRM_G.HasAccessToGuildChat then
        -- Enable Temporary Syncing...
        if not GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] then
            GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] = true;
            GRM_G.TemporarySync = true;
            GRM_RosterSyncCheckButton:SetChecked ( true );
        end
        
        if GRMsyncGlobals.currentlySyncing and GRMsync.IsPlayerDataSyncCompatibleWithAnyOnline() then
            if GRMsyncGlobals.IsElectedLeader then
                if GRMsync.IsPlayerDataSyncCompatible ( GRMsyncGlobals.CurrentSyncPlayer ) then
                    GRM.Report ( GRM.L ( "Breaking current Sync with {name}." , GRM.SlimName ( GRMsyncGlobals.CurrentSyncPlayer ) ) );
                else
                    GRM.Report ( GRM.L ( "Breaking current Sync with the Guild..." ) ); 
                end
            else
                if GRMsync.IsPlayerDataSyncCompatible ( GRMsyncGlobals.DesignatedLeader ) then
                    GRM.Report ( GRM.L ( "Breaking current Sync with {name}." , GRM.SlimName ( GRMsyncGlobals.DesignatedLeader ) ) );
                else
                    GRM.Report ( GRM.L ( "Breaking current Sync with the Guild..." ) ); 
                end
            end
        end
        chat:AddMessage ( GRM.L ( "Initializing Sync Action. One Moment..." ) , 1.0 , 0.84 , 0 );
        if not GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:IsVisible() then
            GRM.RegisterGuildAddonUsersRefresh();
        end
        GRMsync.TriggerFullReset();
        -- Now, let's add a brief delay, 3 seconds, to trigger sync again
        C_Timer.After ( 2 , function()
            GRMsync.Initialize();
            if #GRM_G.currentAddonUsers == 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] then
                chat:AddMessage ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "No Players Currently Online to Sync With..." ) , 1.0 , 0.84 , 0 );
            elseif not GRMsync.IsPlayerDataSyncCompatibleWithAnyOnline() then
                if not GRMsyncGlobals.firstMessageReceived then
                    GRMsyncGlobals.firstMessageReceived = true;
                    chat:AddMessage ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "No Addon Users Currently Compatible for FULL Sync." ) .. "\n" .. GRM.L ( "Check the \"Sync Users\" tab to find out why!" )  , 1.0 , 0.84 , 0 );
                    if #GRM_G.currentAddonUsers > 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][35] then
                        GRM.Report ( "     " .. GRM.L ( "You will still share some outgoing data with the guild" ) );
                    end
                end
            end
        end);
    else
        GRM.Report ( GRM.L ( "SYNC is currently not possible! Unable to Sync with guildies when guild chat is restricted." ) );
    end
end

-- Method:          GRM.SlashCommandCenter()
-- What it Does:    It Centers all of the windows, in case the player dragged them off the screen
-- Purpose:         Help keep frames organized. Just a necessary feature as someone is eventually going to say they tossed the frame off screen.
GRM.SlashCommandCenter = function()
    GRM_UI.GRM_RosterChangeLogFrame:ClearAllPoints();
    GRM_UI.GRM_RosterChangeLogFrame:SetPoint ( "CENTER" , UIParent );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:ClearAllPoints();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame:SetPoint ( "CENTER" , UIPanel );
end

-- Method:          GRM.SlashCommandHelp()
-- What it Does:    Displays a list of all slash commands and what they do
-- Purpose:         To HELP the player with slash commands lol
GRM.SlashCommandHelp = function()
    
    GRM.Report ( "\n" .. GRM.L ( "Guild Roster Manager" ) .. " " .. GRM.L ( "(Ver:" ) .. " " .. GRM_G.Version .. ")\n\n/grm                     - " .. GRM.L ( "Opens Guild Log Window" ) .. "\n/grm clearall         - " .. GRM.L ( "Resets ALL saved data" ) .. "\n/grm clearguild      - " .. GRM.L ( "Resets saved data only for current guild" ) .. "\n/grm center          - " .. GRM.L ( "Re-centers the Log window" ) .. "\n/grm sync             - " .. GRM.L ( "Triggers manual re-sync if sync is enabled" ) .. "\n/grm scan             - " .. GRM.L ( "Does a one-time manual scan for changes" ) .. "\n/grm ver               - " .. GRM.L ( "Displays current Addon version" ) .. "\n/grm recruit          - " .. GRM.L ( "Opens Guild Recruitment Window" ) .. "\n/grm hardreset     - " .. GRM.L ( "WARNING! complete hard wipe, including settings, as if addon was just installed." ) );
end

-- Method:          GRM.SlashCommandClearAll()
-- What it Does:    Resets all data account wide, as if the addon was just installed, on the click of the button.
-- Purpose:         Useful to purge data in case of corruption or trolling or other misc. reasons.
GRM.SlashCommandClearAll = function()
    GRM_UI.GRM_RosterChangeLogFrame:EnableMouse( false );
    GRM_UI.GRM_RosterChangeLogFrame:SetMovable( false );
    GRM_UI.GRM_RosterConfirmFrameText:SetText( GRM.L ( "Really Clear All Account-Wide Saved Data?" ) );
    GRM_UI.GRM_RosterConfirmYesButtonText:SetText ( GRM.L ( "Yes!" ) );
    GRM_UI.GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( _ , button )
        if button == "LeftButton" then
            GRM.ResetAllSavedData();      --Resetting!
            GRM_UI.GRM_RosterConfirmFrame:Hide();
        end
    end);
    GRM_UI.GRM_RosterConfirmFrame:Show();
end

-- Method:          GRM.SlashCommandClearGuild()
-- What it Does:    Resets all data guild wide, as if the guild is brand new or newly joined.
-- Purpose:         Useful to purge the data if someone trolled the guild and made a mess of the data, 
-- or if there is a major error corrupting the data, but you don't want to wipe all account wide
GRM.SlashCommandClearGuild = function()
    GRM_UI.GRM_RosterChangeLogFrame:EnableMouse( false );
    GRM_UI.GRM_RosterChangeLogFrame:SetMovable( false );
    GRM_UI.GRM_RosterConfirmFrameText:SetText( GRM.L ( "Really Clear All Guild Saved Data?" ) );
    GRM_UI.GRM_RosterConfirmYesButtonText:SetText ( GRM.L ( "Yes!" ) );
    GRM_UI.GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( _ , button )
        if button == "LeftButton" then
            GRM.ResetGuildSavedData( GRM_G.guildName );      --Resetting!
            GRM_UI.GRM_RosterConfirmFrame:Hide();
        end
    end);
    GRM_UI.GRM_RosterConfirmFrame:Show();
end

-- Method:          GRM.HardReset()
-- What it Does:    It deletes player addon settings, thus the addon detects that and assumes 
--                  this is the first time any toon has logged in with addon installed and 
--                  triggers full reset and initialization.
-- Purpose:         To bypass all UI features and do a full hard reset, if the player needs
--                  This has no warning, so it is mainly for emergency resets, just in case
GRM.HardReset = function()
    -- Wipe the player settings
    GRM_AddonSettings_Save = {};
    -- reload UI
    ReloadUI();
end

-- Method:          GRM.SlashCommandVersion()
-- What it Does:    Displays the version of the addon (all viewable with /roster help)
-- Purpose:         General info if wanted.
GRM.SlashCommandVersion = function()
    GRM.Report ( "\n" .. GRM.L ( "Guild Roster Manager" ) .. "\nVer: " .. GRM_G.Version .. "\n" );
end

-- Method:          GRM.DebugConfig( string )
-- What it Does:    Enables debugging logging
-- Purpose:         To help debug issues of course, by logging them.
GRM.DebugConfig = function( command )
    if GRM_G.DebugEnabled and not string.find ( command , " " ) then
        GRM_G.DebugEnabled = false;
        GRM.Report ( GRM.L ( "GRM Debugging Disabled." ) );
    else
        if GRM_G.DebugEnabled then
            local number = GRM.Trim ( string.sub ( command , string.find ( command , " " ) + 1 ) );
            if string.find ( command, " " ) ~= nil and tonumber ( number ) ~= nil then
                GRM.DebugLog ( tonumber ( number ) );
            else
                GRM.Report ( GRM.L ( "Error: Debug Command not recognized." ) .. "\n" .. GRM.L ( "Format: \"/grm debug 10\"" ) );
            end
        else
            GRM_G.DebugEnabled = true;
            GRM.Report ( GRM.L ( "GRM Debugging Enabled." ) .. "\n" .. GRM.L ( "Please type \"/grm debug 10\" to report 10 events (or any number)" ) );
            if #GRM_G.currentAddonUsers> 0 and GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][14] then
                GRM.Report ( GRM.L ( "You may want to temporarily disable SYNC in the options if you are debugging another feature." ) );
            end
        end
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
        if IsInGuild() and GRM_UI.GRM_RosterChangeLogFrame ~= nil and not GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then
            GRM_UI.GRM_RosterChangeLogFrame:Show();
        elseif GRM_UI.GRM_RosterChangeLogFrame ~= nil and GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then
            GRM_UI.GRM_RosterChangeLogFrame:Hide();
        elseif GRM_UI.GRM_RosterChangeLogFrame == nil then
            GRM.Report ( GRM.L ( "Please try again momentarily... Updating the Guild Event Log as we speak!" ) );
        end
    -- Clears all saved data and resets to as if the addon was just installed. The only thing not reset is the default settings.
    elseif command == "clearall" or command == "resetall" or command == GRM.L ( "clearall" ) then
        alreadyReported = true;
        GRM.SlashCommandClearAll();
    
    -- Clears all saved data specific to the guild...
    elseif command == "clearguild" or command == "resetguild" or command == GRM.L ( "clearguild" ) then
        if inGuild then
            GRM.SlashCommandClearGuild();
        end

    -- Does a hard reset of the entire database...
    elseif command == "hardreset" or command == GRM.L ( "hardreset" ) then
        GRM.HardReset();
    -- List of all the slash commands at player's disposal.
    elseif command == "help" or command == GRM.L ( "help" ) then
        alreadyReported = true;
        GRM.SlashCommandHelp();

    -- Version
    elseif command == "version" or command == "ver" or command == GRM.L ( "version" ) then
        alreadyReported = true;
        GRM.SlashCommandVersion();

    -- Resets the poisition of the window back to the center.
    elseif command == "reset" or command == "center" or command == GRM.L ( "center" ) then
        alreadyReported = true;
        GRM.SlashCommandCenter();
    
    -- Re-triggering SYNC
    elseif command == "sync" or command == GRM.L ( "sync" ) then
        if inGuild then
            GRM.SyncCommandScan()
        end

    -- For manual scan trigger!
    elseif command == "scan" or command == GRM.L ( "scan" ) then
        if inGuild then
            GRM.SlashCommandScan();
        end
    
    -- For opening the recruiting window
    elseif command == "recruit" or command == "recruits" or command == GRM.L ( "recruit" ) then
        if inGuild then
            GRM.SlashCommandRecruitWindow();
        end

    -- FOR FUN!!!
    elseif command == "hail" then
        alreadyReported = true;
        GRM.Report ( "SUBATOMIC PVP IS THE BEST GUILD OF ALL TIME!\nArkaan is SEXY! Mmmm Arkaan! Super, ridiculously hot addon dev!" );
    -- Invalid slash command.
    elseif string.find ( command , "debug" ) ~= nil then
        GRM.DebugConfig( command );
    else
        alreadyReported = true;
        GRM.Report ( GRM.L ( "Invalid Command: Please type '/grm help' for More Info!" ) );
    end
    
    if not inGuild and not alreadyReported then
        GRM.Report ( GRM.L ( "{name} is not currently in a guild. Unable to Proceed!" , GRM.SlimName( GRM_G.addonPlayerName ) ) );
    end
end


-- Method:              GRM.InitiateMemberDetailFrame()
-- What it Does:        Event Listener, it activates when the Guild Roster window is opened and interface is queried/triggered
--                      "GuildRoster()" needs to fire for this to activate as it creates the following 4 listeners this is looking for: GUILD_NEWS_UPDATE, GUILD_RANKS_UPDATE, GUILD_ROSTER_UPDATE, and GUILD_TRADESKILL_UPDATE
-- Purpose:             Create an Event Listener for the Guild Roster Frame in the guild window ('J' key)
GRM.InitiateMemberDetailFrame = function ()
    if not GRM_G.FramesInitialized and CommunitiesFrame ~= nil then
        -- Member Detail Frame Info
        GRM_UI.GR_MetaDataInitializeUIFirst( false ); -- Initializing Frames
        GRM_UI.GR_MetaDataInitializeUISecond( false ); -- To avoid 60 upvalue Lua cap, place them in second list.
        GRM_UI.GR_MetaDataInitializeUIThird( false ); -- Also, to avoid another 60 upvalues!
        
        GRM_G.UIIsLoaded = true;
        
        -- For determining mouseover on the frames.
        GRM_CoreUpdateFrame:SetScript ( "OnUpdate" , function ( _ , elapsed )
            GRM_G.timer = GRM_G.timer + elapsed;
            if GRM_G.timer >= 0.05 and CommunitiesFrame:IsVisible() then
                local cFrame = CommunitiesFrame;
                GRM_G.clubID = cFrame:GetSelectedClubId();
                if GRM_G.clubID ~= GRM_G.gClubID then
                    if GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
                        GRM.ClearAllFrames ( true );
                    end
                else
                    GRM.RosterFrame();
                end
                GRM_G.timer = 0;
            end
        end);
        
        if CommunitiesFrame:IsVisible() then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButton:Show();
        end
        
        GRM.InitializeRosterButtons();
        -- Exit loop
        UI_Events:UnregisterEvent ( "GUILD_ROSTER_UPDATE" );
        UI_Events:UnregisterEvent ( "GUILD_RANKS_UPDATE" );
        UI_Events:UnregisterEvent ( "GUILD_NEWS_UPDATE" );
        UI_Events:UnregisterEvent ( "GUILD_TRADESKILL_UPDATE" );
        UI_Events:UnregisterEvent ( "UPDATE_INSTANCE_INFO" );
        GRM_G.FramesInitialized = true;
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
    
    UI_Events:RegisterEvent ( "UPDATE_INSTANCE_INFO" );
    UI_Events:RegisterEvent ( "GROUP_ROSTER_UPDATE" );
    UI_Events:RegisterEvent ( "PLAYER_LOGOUT" );

    -- For live guild bank queries...
    GuildBankInfoTracking:RegisterEvent ( "GUILDBANKLOG_UPDATE" );
    GuildBankInfoTracking:RegisterEvent ( "GUILDBANKFRAME_OPENED" );
    GuildBankInfoTracking:SetScript ( "OnEvent" , function( _ , event )
        if event == "GUILDBANKFRAME_OPENED" then
            GRM.SpeedQueryBankInfoTracking();
        elseif event == "GUILDBANKLOG_UPDATE" then
            -- print ( "Results Received From Bank!" );
            -- Function to be added for bank handling here.
        end
    end);
    
    -- UI_Events:RegisterEvent ( "UPDATE_INSTANCE_INFO" );
    UI_Events:HookScript ( "OnEvent" , function( _ , event )
        if ( event == "UPDATE_INSTANCE_INFO" or event == "GROUP_ROSTER_UPDATE" ) and not GRM_G.RaidGCountBeingChecked then
            GRM_G.RaidGCountBeingChecked = true;
            GRM.UpdateGuildMemberInRaidStatus();
        -- Sync the addon settings on logout!!!
        elseif event == "PLAYER_LOGOUT" then
            -- Save debugging log, up to 250 instances
            GRM_DebugLog_Save = GRM_G.DebugLog;

            if not GRMsyncGlobals.reloadControl then
                GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][53] = false;
            end

            -- Sync Addon Settings...
            if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][31] then
                GRM.SyncAddonSettings();
            end

            -- Backup Guild data!
            if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][34] then
                GRM.AutoSetBackup();
            end
        end
    end);

    RaidFrame:HookScript ( "OnHide" , function()
        GRM_UI.GRM_GroupInfo.GRM_NumGuildiesText:Hide();
    end);
end

-- Method:          GRM.CheckIfNeedToAddAlt()
-- What it Does:    Lets you know if the player is already on the list of alts, and returns the position of the guild in the table as well.
-- Purpose:         For alt auto-tagging for the addon.
GRM.CheckIfNeedToAddAlt = function()
    local result = true;
    local guildIndex = -1;
    for i = 2 , #GRM_PlayerListOfAlts_Save[ GRM_G.FID ] do
        if GRM_PlayerListOfAlts_Save[ GRM_G.FID ][i][1][1] == GRM_G.guildName then
            guildIndex = i;
            break;
        end
    end

    -- Fix the guild index and sync settings...
    if guildIndex == -1 and GRM_G.saveGID ~= -1 then

        -- Let's determine if this guild already exists without the server name, and if not removes the old index...
        for i = 2 , #GRM_PlayerListOfAlts_Save[ GRM_G.FID ] do
            if type ( GRM_PlayerListOfAlts_Save[ GRM_G.FID ][i][1] ) == "table" then
                if GRM_PlayerListOfAlts_Save[ GRM_G.FID ][i][1][1] == GRM.SlimName ( GRM_G.guildName ) then 
                    table.remove ( GRM_PlayerListOfAlts_Save[ GRM_G.FID ] , i );
                    break;
                end
            elseif type ( GRM_PlayerListOfAlts_Save[ GRM_G.FID ][i][1] ) == "string" then
                if GRM_PlayerListOfAlts_Save[ GRM_G.FID ][i][1] == GRM.SlimName ( GRM_G.guildName ) then 
                    table.remove ( GRM_PlayerListOfAlts_Save[ GRM_G.FID ] , i );
                    break;
                end
            end
        end
        table.insert ( GRM_PlayerListOfAlts_Save[ GRM_G.FID ] , GRM_G.saveGID , { { GRM_G.guildName , GRM_G.guildCreationDate } } );           -- Adding index for the guild!
        guildIndex = GRM_G.saveGID;
    end

    -- Check if player needs to be added.
    if guildIndex ~= -1 then
        for j = 2 , #GRM_PlayerListOfAlts_Save[ GRM_G.FID ][guildIndex] do
            if GRM_PlayerListOfAlts_Save[ GRM_G.FID ][guildIndex][j][1] == GRM_G.addonPlayerName then
                result = false;
                break;
            end
        end
    end
    return result , guildIndex;
end

-- Method:          GRM.SetSaveGID()
-- What it Does:    It establishes the go-to Guild Index, and iut also performs a smart check if using the old system, and updates it with the proper guildCreationDate tag in an array
--                  This also takes it a step further to fix all the databases if any of the others are broken as well.
-- Purpose:         Why cycle through the guilds over and over again to find the position, when you can store the index of the database in the array with a simple global variable? Massive resource save!
GRM.SetSaveGID = function()

    -- Configure the guild
    local guildName , _ , _ , server = GetGuildInfo ( "PLAYER" );

    if server ~= nil then
        GRM_G.guildName = guildName .. "-" .. string.gsub ( string.gsub ( server , "-" , "" ) , "%s+" , "" );
    else
        GRM_G.guildName = guildName .. "-" .. GRM_G.realmName;
    end

    ----------
    --- FOR OLD DATABASES
    ----------

    local count = 0;
    local index = {};
    for i = 2 , #GRM_GuildMemberHistory_Save[GRM_G.FID] do
        if ( type ( GRM_GuildMemberHistory_Save[GRM_G.FID][i][1] ) == "string" and GRM_GuildMemberHistory_Save[GRM_G.FID][i][1] == GRM.SlimName ( GRM_G.guildName ) ) then
            -- Fix the old system
            if GRM_GuildMemberHistory_Save[GRM_G.FID][i][1] == GRM.SlimName ( GRM_G.guildName ) or GRM_GuildMemberHistory_Save[GRM_G.FID][i][1][1] == GRM.SlimName ( GRM_G.guildName ) then
                GRM_Patch.AddGuildCreationDate( i );
                count = count + 1;
                table.insert ( index , i );
            end

        elseif GRM_GuildMemberHistory_Save[GRM_G.FID][i][1][1] == GRM.SlimName ( GRM_G.guildName ) then
                count = count + 1;
                table.insert ( index , i );

        elseif type ( GRM_GuildMemberHistory_Save[GRM_G.FID][i][1] ) == "string" and GRM_GuildMemberHistory_Save[GRM_G.FID][i][1] == "" then
            -- Scan through the guild database to find a match...
            for j = 2 , #GRM_GuildMemberHistory_Save[GRM_G.FID][i] do
                if GRM_GuildMemberHistory_Save[GRM_G.FID][i][j][1] == GRM_G.addonPlayerName then
                    -- Guild found!
                    GRM_GuildMemberHistory_Save[GRM_G.FID][i][1] = GRM.SlimName ( GRM_G.guildName );
                    GRM_Patch.AddGuildCreationDate( i );
                    count = count + 1;
                    table.insert ( index , i );
                    break;
                end
            end
        end
    end
    if count == 1 then
        GRM_G.saveGID = index[1];
    elseif count > 1 then
        -- Oh my! More than one guild with more than one Creation Date...
        -- Let's check if it is a x-realm guild. If it is not a x-relam guild, then we can just compare server names
        local isMergeRealm = GRM.IsMergedRealmServer();
        for i = 1 , #index do
            -- For cleaner code, parsing out.
            local playerName = GRM_GuildMemberHistory_Save[GRM_G.FID][index[i]][2][1];
            local playerServer = string.sub ( playerName , string.find ( playerName , "-" ) + 1 );
            if not isMergeRealm then
                if playerServer == GRM_G.realmName then
                    GRM_G.saveGID = index[i];
                    break;
                end                
            else
                -- Oh my, we ARE on a merged realm guild! Welp, if that's the case, this is a last resort, let's just parse through ALL of the guilds til we find our own index added to it.
                for j = 2 , #GRM_GuildMemberHistory_Save[GRM_G.FID] do
                    for r = 2 , #GRM_GuildMemberHistory_Save[GRM_G.FID][j] do
                        if GRM_GuildMemberHistory_Save[GRM_G.FID][j][r][1] == GRM_G.addonPlayerName then
                            GRM_G.saveGID = r;
                            break;
                        end
                    end
                end               
            end
        end
    end

    --- END OLD DATABASES ---
    -------------------------

    -- First, let's verify the notepad has been added...
    local notePadFound = false;
    for i = 2 , #GRM_GuildNotePad_Save[ GRM_G.FID ] do
        if string.find ( GRM_G.guildName , "-" ) ~= nil and GRM_GuildNotePad_Save[ GRM_G.FID ][i][1][1] == GRM_G.guildName then
            -- Good! Guild is proper!
            notePadFound = true;
        elseif GRM_GuildNotePad_Save[ GRM_G.FID ][i][1][1] == GRM.SlimName ( GRM_G.guildName ) then
            -- Guild name never fixed, let's fix the guild name.3
            notePadFound = true;
        end
    end

    -- Now, check if needs to be one-time configured...
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_G.FID ] do
        if string.find ( GRM_G.guildName , "-" ) ~= nil and GRM_GuildMemberHistory_Save[ GRM_G.FID ][i][1][1] == GRM_G.guildName and GRM_PlayersThatLeftHistory_Save[ GRM_G.FID ][i][1][1] == GRM_G.guildName and GRM_CalendarAddQue_Save[ GRM_G.FID ][i][1][1] == GRM_G.guildName and GRM_GuildDataBackup_Save[ GRM_G.FID ][i][1][1] == GRM_G.guildName and GRM_LogReport_Save[ GRM_G.FID ][i][1][1] == GRM_G.guildName then
            -- Good! Guild is proper!
            GRM_G.saveGID = i;
            if not notePadFound then
                table.insert ( GRM_GuildNotePad_Save[ GRM_G.FID ] , GRM_G.saveGID , { { GRM_G.guildName , GRM_G.guildCreationDate } }  );  -- Notepad, let's create an index as well!
            end
            break;
        elseif string.find ( GRM_G.guildName , "-" ) ~= nil and GRM_GuildMemberHistory_Save[ GRM_G.FID ][i][1][1] == GRM_G.guildName then
            -- This means we had a partial database update!!!! Need to fix it!
            GRM_G.saveGID = i;
            if not notePadFound then
                table.insert ( GRM_GuildNotePad_Save[ GRM_G.FID ] , GRM_G.saveGID , { { GRM_G.guildName , GRM_G.guildCreationDate } }  );  -- Notepad, let's create an index as well!
            end
            GRM.ResetGuildNameEverywhere ( GRM_G.guildName );
            break;
        elseif GRM_GuildMemberHistory_Save[ GRM_G.FID ][i][1][1] == GRM.SlimName ( GRM_G.guildName ) then
            -- Guild name never fixed, let's fix the guild name.3
            GRM_G.saveGID = i;
            if not notePadFound then
                table.insert ( GRM_GuildNotePad_Save[ GRM_G.FID ] , GRM_G.saveGID , { { GRM_G.guildName , GRM_G.guildCreationDate } }  );  -- Notepad, let's create an index as well!
            end
            GRM.ResetGuildNameEverywhere ( GRM_G.guildName );
            break;
        end
    end

    -- If guild ranks have never been updated...
    local numRanks = GuildControlGetNumRanks();
    if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][1] == 2 then
        table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][1] , numRanks );
        return;
    end

    ------------------------------
    --------- BFA UPDATE ---------
    ------------------------------

    -- Now, we check if ClubID has ever been added
    GRM_G.gClubID = C_Club.GetGuildClubId();
    -- If guild clubID has never been added.
    if #GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][1] == 3 then
        table.insert ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][1] , GRM_G.gClubID );
        return;
    end
end

-- Method           GRM.SetLogGID()
-- What it Does:    Establishes the index of the current player's guild in the database, and triggers a conversion fix of old database as well...
-- Purpose:         Massive resource saving if I find the index one time and store it for lookup use rather than to repeat lookup.
GRM.SetLogGID = function()
    for i = 2 , #GRM_LogReport_Save[GRM_G.FID] do
        if type ( GRM_LogReport_Save[GRM_G.FID][i][1] ) == "string" and GRM_LogReport_Save[GRM_G.FID][i][1] == GRM.SlimName ( GRM_G.guildName ) then
            -- Fix the old system
            GRM_Patch.FixLogGuildInfo( i );
            GRM_G.logGID = i;
        
        elseif GRM_LogReport_Save[GRM_G.FID][i][1][1] == GRM_G.guildName then
            GRM_G.logGID = i;
        end
    end
end

-- Method:          GRM.EstablishDatabasePoints()
-- What it Does:    Establishes all the remaining index point saves...
-- Purpose:         Resource saving!!!
GRM.EstablishDatabasePoints = function( forced )

    -- Need to do the same for save index ID
    if GRM_G.saveGID == 0 or forced then
        GRM.SetSaveGID();
    end

    -- Also includes logic to fix old database...
    if GRM_G.logGID == 0 or forced then
        GRM.SetLogGID();
    end
    
    -- for Settings
    if GRM_G.setPID == 0 or forced then
        for i = 2 , #GRM_AddonSettings_Save[GRM_G.FID] do
            if GRM_AddonSettings_Save[GRM_G.FID][i][1] == GRM_G.addonPlayerName then
                GRM_G.setPID = i;
                break;
            end
        end
    end

     -- Need to doublecheck guild Index ID
     if GRM_G.logGID == 0 then
        for i = 2 , #GRM_LogReport_Save[GRM_G.FID] do
            if GRM_LogReport_Save[GRM_G.FID][i][1][1] == GRM_G.guildName then
                GRM_G.logGID = i;
                break;
            end
        end
    end
end


-- Method:          Tracking()
-- What it Does:    Checks the Roster once in a repeating time interval as long as player is in a guild
-- Purpose:         Constant checking for roster changes. Flexibility in timing changes. Default set to 10 now, could be 30 or 60.
--                  Keeping local
local function Tracking()
    if IsInGuild() and not GRM_G.trackingTriggered then
        GRM_G.trackingTriggered = true;
        local timeCallJustOnce = time();
        if ( GRM_G.timeDelayValue == 0 or ( timeCallJustOnce - GRM_G.timeDelayValue ) >= GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][6] )  then -- Initial scan is zero.
            GRM_G.currentlyTracking = true;
            GRM_G.timeDelayValue = timeCallJustOnce;
            -- Need to doublecheck Faction Index ID
            if GRM_G.FID == 0 then
                if GRM_G.faction == "Horde" then
                    GRM_G.FID = 1;
                else
                    GRM_G.FID = 2;
                end
            end

            -- Add an escape if necessary due to unloaded data points. It will try again in 10 seconds or less, whenever the server calls back.
            if GRM_G.guildCreationDate == "" then
                GRM.DelayForGuildInfoCallback();
                return
            end

            -- Establish proper database tags before building and scanning roster data
            -- For massive resourcing saving, let's establish core data points.
            if GRM_G.saveGID == 0 then
                GRM.EstablishDatabasePoints( false );
            end

            if GRM_G.saveGID ~= 0 and GRM_G.OnFirstLoad then
                GRM.SyncAddonSettingsOfNewToon();
            end
           
            -- Checking Roster, tracking changes
            GRM.BuildNewRoster();

            -- Prevent from re-scanning changes
            -- On first load, bring up window.
            if GRM_G.OnFirstLoad then

                -- Determine if player has access to guild chat or is in restricted chat rank
                GRM.RegisterGuildChatPermission();
               
                -- Determine if player is already listed as alt...
                local needsToAdd , guildIndex = GRM.CheckIfNeedToAddAlt();
                if needsToAdd and guildIndex ~= -1 then
                    GRM.AddPlayerToOwnAltList( guildIndex );
                end

                -- Establish Message Sharing as well!
                GRMsyncGlobals.SyncOK = true;
                
                C_Timer.After ( 10 , GRMsync.Initialize ); -- It needs to be minimum 10 seconds as it might take that long to process all changes and add player to database.

                -- MISC frames to be loaded immediately, not on delay
                GRM.AllRemainingNonDelayFrameInitialization();

                -- Open the core addon frame...
                if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][2] and not GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][28] then
                    GRM_UI.GRM_RosterChangeLogFrame:Show();
                end

                -- To avoid kick spam in the chat, due to the stutter elimination temp delay system
                C_Timer.After ( 45 , function() GRM_G.OnFirstLoadKick = false end);
            end
        end
        GRM_G.currentlyTracking = false;
        if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][18] then
            if not CommunitiesFrame or not CommunitiesFrame:IsVisible() then
                GuildRoster();
            end;
            C_Timer.After( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][6] , GRM.TriggerTrackingCheck ); -- Recursive check every X seconds.
        end
    else
        GRM_G.currentlyTracking = false;
    end
end

-- Method:          GRM.DelayForGuildInfoCallback()
-- What it Does:    It basically recursively waits til the conditions are met and the server properly retrieved the guildCreationDate
-- Purpose:         If a guild is on more than one server with the same name, that can complicate things. This helps idenitfy the server by the creation date as well...
GRM.DelayForGuildInfoCallback = function()
    if GRM_G.guildCreationDate == "" then
        GRM.SetGuildInfoDetails();
        GuildRoster();
        C_Timer.After ( 1 , GRM.DelayForGuildInfoCallback );
    else
        GRM_G.timeDelayValue = 0;
        GRM_G.trackingTriggered = false;
        Tracking();
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
    
    if GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][29] then
        local chatEvents = { "CHAT_MSG_GUILD" , "CHAT_MSG_WHISPER" , "CHAT_MSG_GUILD_ACHIEVEMENT" , "CHAT_MSG_PARTY" , "CHAT_MSG_PARTY_LEADER" , "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER" , "CHAT_MSG_INSTANCE_CHAT" , "CHAT_MSG_INSTANCE_CHAT_LEADER" , "CHAT_MSG_OFFICER" }
        for i = 1 , #chatEvents do
            ChatFrame_AddMessageEventFilter ( chatEvents[i] , GRM.AddMainToChat );
        end
    end
    -- Quick Version Check
    if not GRM_G.VersionCheckRegistered then
        GRM.RegisterVersionCheck();
        SendAddonMessage ( "GRMVER" , GRM_G.Version.. "?" .. tostring ( GRM_G.PatchDay ) , "SLASH_CMD_GUILD" );
        GRM_G.VersionCheckRegistered = true;
    end

    -- Determine who is using the addon...
    -- 3 second dely to account for initialization of various variables. Safety cushion.
    C_Timer.After ( 3 , GRM.RegisterGuildAddonUsers );

    -- The following event registartion is purely for UI registeration and activation... General tracking does not need the UI, but CommunitiesFrame should be visible bnefore triggering
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
            if not GRM_G.FramesInitialized  then
                GRM.InitiateMemberDetailFrame();
            else
                self:UnregisterEvent ( "GUILD_ROSTER_UPDATE" );
                self:UnregisterEvent ( "GUILD_RANKS_UPDATE" );
                self:UnregisterEvent ( "GUILD_NEWS_UPDATE" );
                self:UnregisterEvent ( "GUILD_TRADESKILL_UPDATE" );
                self:UnregisterEvent ( "UPDATE_INSTANCE_INFO" );
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
     if GRM_G.faction == nil then
        GRM_G.faction = UnitFactionGroup ( "PLAYER" );
    end

    if GRM_G.faction == "Horde" then
        GRM_G.FID = 1;
    else
        GRM_G.FID = 2;
    end

    -- Must get PID immediately after.
    if GRM_G.setPID == 0 then
        for i = 2 , #GRM_AddonSettings_Save[GRM_G.FID] do
            if GRM_AddonSettings_Save[GRM_G.FID][i][1] == GRM_G.addonPlayerName then
                GRM_G.setPID = i;
                break;
            end
        end
    end

    C_Timer.After ( 5 , GRM.RegisterGuildChatPermission );

    GRM.SetGuildInfoDetails();
    GuildRoster();
    QueryGuildEventLog();
    RequestGuildApplicantsList();
    C_Timer.After ( 2 , GRM.GR_LoadAddon );

end

-- Method           GRM.ManageGuildStatus()
-- What it Does:    If player leaves or joins the guild, it deactivates/reactivates tracking - as well as re-checks guild to see if rejoining or new guild.    
-- Purpose:         Efficiency in resource use to prevent unnecessary tracking of info if out of the guild.
GRM.ManageGuildStatus = function ()
    GeneralEventTracking:UnregisterEvent ( "PLAYER_GUILD_UPDATE" );
    if GRM_G.guildStatusChecked ~= true then
       GRM_G.timeDelayValue2 = time(); -- Prevents it from doing "IsInGuild()" too soon by resetting timer as server reaction is slow.
    end
    if GRM_G.timeDelayValue2 == 0 or ( time() - GRM_G.timeDelayValue2 ) >= 2 then -- Let's do a recheck on guild status to prevent unnecessary scanning.
        if IsInGuild() then
            if GRM_G.DelayedAtLeastOnce then
                if not GRM_G.currentlyTracking then                 
                    GRM.ReactivateAddon();
                end
            else
                GRM_G.DelayedAtLeastOnce = true;
                C_Timer.After ( 5 , GRM.ManageGuildStatus );
            end
        else
            -- Reset some values;
            GRMsyncGlobals.SyncOK = false;
            GRM_G.logGID = 0;
            GRM_G.saveGID = 0;   
            GRM_G.timeDelayValue = 0;
            GRM_G.OnFirstLoad = true;
            GRM_G.OnFirstLoadKick = true;
            GRM_G.guildName = "";
            GRM_G.guildCreationDate = "";
            GRM_G.trackingTriggered = false;
            GRM_G.DelayedAtLeastOnce = true;                     -- Keeping it true as there does not need to be a delay at this point.
            UI_Events:UnregisterEvent ( "GUILD_EVENT_LOG_UPDATE" );         -- This prevents it from doing an unnecessary tracking call if not in guild.
            if GRMsync.MessageTracking ~= nil then
                GRMsync.MessageTracking:UnregisterAllEvents();
            end
            GRMsync.ResetDefaultValuesOnSyncReEnable();                     -- Need to reset sync algorithm too!
            GRM_UI.GRM_RosterChangeLogFrame:Hide();
        end
        GeneralEventTracking:RegisterEvent ( "PLAYER_GUILD_UPDATE" );
        GeneralEventTracking:SetScript ( "OnEvent" , GRM.ManageGuildStatus );
        GRM_G.guildStatusChecked = false;
    else
        GRM_G.guildStatusChecked = true;
        C_Timer.After ( 2 , GRM.ManageGuildStatus ); -- Recursively re-check on guild status trigger.
    end
end

-- Method:          ActivateAddon( self , string , string )
-- What it Does:    First, doesn't trigger to load until all variables of addon fully loaded.
--                  Then, it triggers to delay until player is fully in the world, in that order.
--                  Finally, it delays 5 seconds upon querying server as often initial Roster and Guild Event Log query takes a moment to return info.
-- Purpose:         To ensure the smooth handling and loading of the addon so all information is accurate before attempting to parse guild info.
GRM.ActivateAddon = function ( _ , event , addon )
    if event == "ADDON_LOADED" then
    -- initiate addon once all variable are loaded.
        if addon == GRM_G.addonName then
            Initialization:RegisterEvent ( "PLAYER_ENTERING_WORLD" ); -- Ensures this check does not occur until after Addon is fully loaded. By registering, it acts recursively throug hthis method
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Initialize load settings! Don't need to be in a guild for this!
        -- Setting the index of the player's faction.
        if GRM_G.faction == nil then
            GRM_G.faction = UnitFactionGroup ( "PLAYER" );
        end

        if GRM_G.faction == "Horde" then
            GRM_G.FID = 1;
        else
            GRM_G.FID = 2;
        end

        GRM.LoadSettings();

        -- Rerun this for the language changes...
        -- this will also build initial frames...
        GRML.SetNewLanguage ( GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][43] , true );
       
        -- Double check on setting
        if GRM_G.setPID == 0 then
            for i = 2 , #GRM_AddonSettings_Save[GRM_G.FID] do
                if GRM_AddonSettings_Save[GRM_G.FID][i][1] == GRM_G.addonPlayerName then
                    GRM_G.setPID = i;
                    break;
                end
            end
        end

        -- Restore debugLog since addonloaded
        GRM_G.DebugLog = GRM_DebugLog_Save;

        -- MISC Quality of Life Settings...
        -- Addon Compatibility Detection
        -- EPGP uses officer notes and is an incredibly popular addon. This now ensures auto-adding not will default to PUBLIC note rather than officer.
        if GRM_G.setPID ~= 0 and IsAddOnLoaded("epgp") then
            GRM_AddonSettings_Save[GRM_G.FID][GRM_G.setPID][2][20] = false;
        end

        if IsInGuild() then
            Initialization:UnregisterEvent ("PLAYER_ENTERING_WORLD");
            Initialization:UnregisterEvent ("ADDON_LOADED");     -- no need to keep scanning these after full loaded. 
            GuildRoster();                                       -- Initial queries...
            QueryGuildEventLog();
            RequestGuildApplicantsList();
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

    -- Request to join filters... Clear all that only X days or less left -- possible to filter the log?

    -- Prevent GRM window from popping up from minimap button if in combat currently.

    -- Auto main/alt tagging  -- Main can be auto-tagged by checking the ginfo num of unique accounts on load, though only if players join live. Alt tagging will be you know it is an alt cause counter didn't go up when joined

    -- Add exemption dropdown checklist on kick recommendations
        -- Add the ability to exampt individual players from kick recommendation, and upon checking the box, IF they have alts, a popup window asking to exexmpt all of their alts as well? Yes or no.
        -- If unchecking an exemption, if they have alts, and at least 1 alt is exempt, then popup window to asking "Remove exemption from all X's alts as well?"

    -- Option to add custom names like tag people with nicknames.
      
    -- Interface to search public and officer notes

    -- Ability to edit the date on guild bans

    -- For clickable log... if more than one name is parsed, then have selection of the 2 names, which one you wish to go to... "Left Click to go to playerA, Right click to go to playerB"

    -- Option to push for sync of just some features, not all...

    -- Alt grouping table... details on all of the alts in separate window but with full rundown of details... last online, etc...

    -- Customized Trial period reminder...

    -- Notification text color selection
    
    -- When opening the mailbox, IF the player has people requesting to join the guild, popup window to send them a customizable recruitment message.

    -- Option to only log the level caps of each expansion

    -- Potential player hyperlink generation for wowprogress, guildox, and so on   GetCurrentRegion()  :  1 = US/Brazil/Oceanic  2 = Korea , 3 = EU , 4 = Taiwan , 5 = China

    -- Add to calendar tab will convert into an events/reminders tab
    -- Sub categories..

    -- Plugin support- like guild recruiting feature...

    -- Ability to color code player names based on rank...  ??

    -- Add main name to public or officer note in log...

    -- Make list of all players that LEFT the guild... Purge the list option except for banned?

    -- Custom Messaging - stored messages to send to guild chat. Customizable?   -- Possibly standalone addon or plugin
    -- Guild Officer Notepad... Communal notepad anyone can edit...

    --ADDON PLUGIN IDEAS
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
    
    -- GUILD NEWS HANDLING
    -- On the guild news, let's start with Guild achievements!
    -- If more than one guildie in a zone it also mentions how many people in the guild are also in the zone ( with mouseover including names of those in zone too ).
    -- Drop down menu on the Log Frame allowing you to choose which log to view, from any character, any faction you have... just the log. (maybe I will include maybe not. Seems mostly useless for high time effort)
    -- Guild achievement and loot NEWS window could be parsed for interesting info
    
    -- Create powerful SYNC tool - only for GM. Ability to push all current data as most-current.

    -- MAIN TO DO GOALS

    -- 3) Custom Notifications/Reminders -  Basically, I want to build in a feature where the player types /roster remind, or something like that, which pops up a window to set a time and date for any kind of reminder the player wants, just type it out. I've written out a rough UI on how I wish this to look, and I think it is going to be killer useful. You could set reminder to minutes or hours from now, to days or months. Very useful for on-the-spot thoughts. 
    -- It will have a custom UI to quickly set a specific time and date, and note reminder
    -- Slash command will be advances as well. For example, instead of just /roster remind, you could type '/roster remind 30 Recheck AH for deals' Rather than popup the UI window, it will just automatically create a reminder 30 minutes from now that will notify you to "Recheck AH for deals" - Use the UI or use the slash command. UI might be necessary for things much further out, but for simple reminders in that game session... quite useful.
    -- Oh and, I will be adding a Birthday reminder, so guilds can enter player's RL bday, if they so choose.
    
    -- 4) Guild Notepad - Still hammering out the minor details, but generally the idea is I plan on creating an editable notepad that people can write on in the guild. I will likely have a general and an officer one. It of course will sync with general info on who and when edits were made. This might roll into its own addon as it is a sizable project. So many potential uses, however.

    -- Guild toolbox -- things like Inquiry where you can add a name and say "What happened to this player?" and the addon will attempt to find out through checking their main, their former alt list (add to friend/remove), check online...

    -- INTERESTING GUILD STATISTICS (Hrmm most of these not really watchable without web API)
        -- Like number of legendaries collected this week
        -- Notable achievements, like Prestige advancements, rare achievements, etc.
        -- If players have obtained recent impressive titles (100k or 250k kills, battlemaster)
        -- Total number of guild battlemasters
        -- Total number of guildies with certain achievements
        -- Is it possible to identify player's achievements without being close to them?
        -- Notable high ilvl notifications with adjustable threshold to trigger it, for editable updating for expansion update flexibility
        -- Analysis of close-to-get achievements?
        -- useful tools only guild leader can see'... Like gkick all, or something.

    -------------------------------------
    ----- KNOWN BUGS --------------------
    -------------------------------------

    -- On editing the player's ban, if you choose to ban all alts as well in the edit ban feature, it doesn't carry over the reason and tries to pass an empty string "" through the localization function on the class...
    -- If a new player joins the guild -- does it instantly spam all their custom notes? YES -- possible change here?
    -- If the date has passed on the suggested "add to calendar" options, the player should remove them from the list.    
    -- The Custom notepad will be indexed out of order for some people... One day I will need to rebuild it... 
    -- player will spam guild actions and get "You are not in a guild" error
    -- Ban list sync occasionally wonky, like it syncs partial list, then you sync again and you get the rest... or only the person sharing the data with you syncs to you, but it doesn't pass through a mediator if more than 2 online
    -- Ban list only syncs if it is coming from the sender and the leader updates themselves... what am I missing here? Maybe if they are sending me incorrect info, I should shoot back to them to update it properly...
    -- If a player goes from not being able to read officer note, to having access, it spams your log. That should be known...
    -- Note change spam if you have curse words in note/officer notes and Profanity filter on. Just disable profanity filter for now until I get around to it.
    
    -------------------------------------
    ----- BUSY work ---------------
    -------------------------------------

    -- if number of unique accounts goes up since the last player joined -- set the player as main... count number of joined since last checked unique players...

    -- local clubID = C_Club.GetMemberInfo ( CommunitiesFrame:GetSelectedClubId() , 1 )
    -- /dump C_Club.GetClubInfo(5521)
    -- /dump C_Club.GetClubInfo(55341)
    -- GetCVar("portal") -- to determine the region
    -- /dump CommunitiesFrame:GetPrivilegesForClub(CommunitiesFrame:GetSelectedClubId())
    -- /run local guildMemberIDs = C_Club.GetClubMembers(CommunitiesFrame:GetSelectedClubId() ); print(#guildMemberIDs)
    -- /dump C_Club.GetMemberInfo(CommunitiesFrame:GetSelectedClubId() , 1 )
    -- /dump C_Club.GetAssignableRoles ( 55341 , 1 )
    -- /dump C_Club.GetMemberInfo(CommunitiesFrame:GetSelectedClubId(),1)
    -- /run 
    -- /run local player = C_Club.GetMemberInfo(55341,6); local _,_,_,_,_,name,server = GetPlayerInfoByGUID(player.guid) print(server)
    -- /dump C_Club.GetMemberInfo ( 5521 , CommunitiesUtil.GetMemberIdsSortedByName(5521,CommunitiesFrame:GetSelectedStreamId() )[6])
    -- /run local t = C_Club.GetMemberInfo ( 5521 , CommunitiesUtil.GetMemberIdsSortedByName(5521,CommunitiesFrame:GetSelectedStreamId() )[6] ); print( select ( 8 , GetPlayerInfoByGUID(t.guid) ) );
    
    -- /dump CommunitiesUtil.GetMemberIdsSortedByName ( GRM_G.gClubID );
    -- /dump CommunitiesUtil.GetAndSortMemberInfo ( 5521 , CommunitiesFrame:GetSelectedStreamId() )
    -- /run local c=CommunitiesFrame;local t=C_Club.GetClubMembers(c:GetSelectedClubId());for i=1,30 do local s=PlayerLocation:CreateFromGUID(C_Club.GetMemberInfo(c:GetSelectedClubId(),t[i]).guid))end
    -- /dump C_GuildInfo.QueryGuildMemberRecipes ( GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][2][42] )

    -------- BFA UPDATES COMPLETED -----------------
    -- ClubID logic has been integrated to GRM_GuildMemberHistory_Save[ GRM_G.FID ][ GRM_G.saveGID ][1][4] index on load...
    -- clubID and guildClubID (gClubID) -- implemented in the CommunitiesFrame OnUpdate


    -- NEEDS TO BE DONE -- throttle the sync on zoning, for 5 seconds.
    -- Side window on the calendar should close when re-clicking person's portrait
    -- Show the main tag in the notes in the log
    -- Rewrite sync data to only send actual data... as of now it sends for each player no matter what...  (This is about 30% done as of July 4th '18)
        -- Send data from player
        -- Leader collects data, then compares his data to collected, and if his needs to be sent he adds it...
        -- Custom Note does this already...

   
    -- Ability to reset all data with one button  ( /grm hardreset does this but need a front-end UI button now)
    
    -- Create an option to display the users officer and public note when they gquit (like it displays their alts)
    -- * In "Log". Clickable character names that open the roster for the character.

    -- GRM.IsValidName -- get ASCII byte values for the other 4 regions' Blizz selected fonts.
    -- Sync the history of promotions and demotions as well.

    -- BIRTHDAYS
    -- Custom Reminders

    -- If Mature language filter is on
    -- 4 letter word == !@#$ !@#$%^ or ^&*!  
        -- "CHAT_MSG_GUILD_ITEM_LOOTED"
    

    -- BACKEND CODE WRITTEN - NEEDS FRONT END SOLUTION!!!!
    -- Add birthdate configuration...
    -- RL birthday should also state the number of years that player has been in the guild.
    -- Have a tab to view all of the events currently already on the calendar.
    -- Sync the custom event reminder.
    -- soo to be new feature:
            -- BIRTHDAY TRACKING AND SYNC
            -- Custom events
    
    -- CHANGELOG:
    
    -- New Feature
            -- Sync algorithm re-written to take advantage of 8.0 features!
            -- Infinite scrolling
            -- Audit Log sorting of dates as well as displaying of dates.
            -- Alt grouping side frame.
            -- Added main/alt tagging in the guild calendar, so you can see who, also if you click on them it will bring out side window.
            -- Auto "main" tagging when a player joins the guild... Basically if someone joins the guild and the addon takes notice of "Unique accounts" incrementing by 1, we know a new player has joined
        

    -- QOL
        -- INFINITE SCROLLING aka smart scrolling now fully implemented on the Main guild log and the audit log. Only load a small number of lines that are viewable, and as you scroll it loads more lines on demand. For resource minimalization!
        -- The Audit log you can now sort it! You can sort the names, all guildies by join date, by promo date, or even by sort all mains first... Just click the headers!
        -- Default BFA position of the GuildMemberDetailFrame was over the tabbed side buttons on the communities frame. This changes the position to be more suitable, imo.
        -- Ban List info text on no bans should no be properly visible at the right strata
        -- Player now has the ability to see bans, even if they cannot remove a player from the guild, but only if the ban info is shared with them. Before it didn't even allow you to see the ban if player was still in the guild on mouseover popup.
        -- DateTime format has been added: year-month-day like 2018-06-20
        -- Request to join people that are online should now include full names with server identifier.
        -- Ban List, Users Frame, and Events frame should now properly allign the columns.
        -- NameChanges are now 100% flawless! Blizz has given access to player server GUID in BFA, this allows me to perfectly identify them. The ONLY way this changes is if the player server transfers off and then server transfers back.
        -- Events window tooltips should now properly update whe nthe player hits the ESC key to remove targeting of an event to add.
        -- the game will now report if the player returning name-changed when they were no longer in the guild.
        -- Lots and lots of code optimized on the backend.
        -- Changed Default scan time for changes to 30 seconds for new toons

    -- BUGS
          -- Fixed a bug that could error on some people's event calendars when trying to ignore them.
          -- The count should properly display now. Before it was tallying the count on "mains" even if you were not updating or changing it.
          -- Fixed an issue with the Ban list names not saving properly if it is a special character...
          -- Fixed localization bug on the ban list saying it didn't recognize a class name
          -- Fixed an issue where settings were not syncing completely in all cases. This verifies the player account
          -- Sync settings between alts should now work properly for everyone...
          -- Guild Log button should now be the proper frame strata matched to the communities frame.
          -- Fixed a bug that made it not possible to add certain players to the ban list if you were in a guild that had a large number of people who had left the guild. This would ONLY be an issue for mega guilds.
          -- Fixed a bug where an error could occur when creating a ban and trying to display chat message if you used the chat-chat plugin with ElvUI -- FIXED!
          -- Fixed a bug that was causing the Calendar Creat Event "Mass Invite" window to close...

        




-- ADDON IDEA
-- "The Mad Hopper"
    -- Counts number of hops while in combat
    -- Stores hops per raid boss, checks if new count beats old count and announces a new record.
    -- Option to share with raid/party/guild chat
    -- Hop challenges, like only 33% or less of hops can be up and down... the rest have to move around.
    -- /hop start 60 -- all hops in that 60 second window in raid... tally winner.
    -- /hop stop stops counting...
    -- Raid leader or raid assist to access those features...
    -- DDR hop challenge! -- Score collecting!  @Dyfed-Zul'jin's idea.
    -- Passively tally total number of hops since date installed... average number of hops per hour of play time...




    -- /run local memberInfo = C_Club.GetMemberInfo ( 55341 , 6 ); print(memberInfo.name)
    -- { Name = "isSelf", Type = "bool", Nilable = false },
    -- { Name = "memberId", Type = "number", Nilable = false },
    -- { Name = "name", Type = "string", Nilable = true, Documentation = { "name may be encoded as a Kstring" } },
    -- { Name = "role", Type = "ClubRoleIdentifier", Nilable = true },
    -- { Name = "presence", Type = "ClubMemberPresence", Nilable = false },
    -- { Name = "clubType", Type = "ClubType", Nilable = true },
    -- { Name = "guid", Type = "string", Nilable = true },
    -- { Name = "bnetAccountId", Type = "number", Nilable = true },
    -- { Name = "memberNote", Type = "string", Nilable = true },
    -- { Name = "officerNote", Type = "string", Nilable = true },
    -- { Name = "classID", Type = "number", Nilable = true },
    -- { Name = "race", Type = "number", Nilable = true },
    -- { Name = "level", Type = "number", Nilable = true },
    -- { Name = "zone", Type = "string", Nilable = true },
    -- { Name = "achievementPoints", Type = "number", Nilable = true },
    -- { Name = "profession1ID", Type = "number", Nilable = true },
    -- { Name = "profession1Rank", Type = "number", Nilable = true },
    -- { Name = "profession1Name", Type = "string", Nilable = true },
    -- { Name = "profession2ID", Type = "number", Nilable = true },
    -- { Name = "profession2Rank", Type = "number", Nilable = true },
    -- { Name = "profession2Name", Type = "string", Nilable = true },
    -- { Name = "lastOnlineYear", Type = "number", Nilable = true },
    -- { Name = "lastOnlineMonth", Type = "number", Nilable = true },
    -- { Name = "lastOnlineDay", Type = "number", Nilable = true },
    -- { Name = "lastOnlineHour", Type = "number", Nilable = true },
    -- { Name = "guildRank", Type = "string", Nilable = true },
    -- { Name = "guildRankOrder", Type = "number", Nilable = true },
    -- { Name = "isRemoteChat", Type = "bool", Nilable = true },