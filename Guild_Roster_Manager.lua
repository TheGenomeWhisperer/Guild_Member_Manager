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
GRM_GuildNotePad_Save = {};                   -- This includes both the restricted Officer only notepad, as well as the guild-wide notepad.

-- slash commands
SLASH_GRM1 = '/roster';
SLASH_GRM2 = '/grm';

-- Table to hold all localization files...\
GRM_L = {};

-- Useful Variables ( kept in table to keep low upvalues count )
GRM_AddonGlobals = {};

-- Addon Details:
GRM_AddonGlobals.Version = "7.3.5R1.130";
GRM_AddonGlobals.PatchDay = 1517378854;             -- In Epoch Time
GRM_AddonGlobals.PatchDayString = "1517378854";     -- 2 Versions saves on conversion computational costs... just keep one stored in memory. Extremely minor gains, but very useful if syncing thousands of pieces of data in large guilds.
GRM_AddonGlobals.Patch = "7.3.5";
GRM_AddonGlobals.LvlCap = 110;

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
GRM_AddonGlobals.saveGID = 0;    -- Needs a separate GID "Guild Index ID" because it may not match the log index depending on if a log entry is cleared vs guild info, which can be separate.
GRM_AddonGlobals.setPID = 0;     -- Since settings are player unique, PID = Player ID

-- To ensure frame initialization occurse just once... what a waste in resources otherwise.
GRM_AddonGlobals.timeDelayValue = 0;
GRM_AddonGlobals.timeDelayValue2 = 0;
GRM_AddonGlobals.FramesInitialized = false;
GRM_AddonGlobals.OnFirstLoad = true;
GRM_AddonGlobals.OnFirstLoadKick = true;
GRM_AddonGlobals.currentlyTracking = false;
GRM_AddonGlobals.trackingTriggered = false;

-- Guild Status holder for checkover.
GRM_AddonGlobals.guildStatusChecked = false;

-- UI Controls global for reset
GRM_AddonGlobals.UIIsLoaded = false;

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
GRM_AddonGlobals.TempLeftGuildPlaceholder = {};
GRM_AddonGlobals.TempNameChanged = {};
GRM_AddonGlobals.TempEventReport = {};

-- Useful Globals for Quick Use
GRM_AddonGlobals.rankIndex = 1;
GRM_AddonGlobals.playerIndex = -1;
GRM_AddonGlobals.monthIndex = 1;
GRM_AddonGlobals.yearIndex = 1;
GRM_AddonGlobals.dayIndex = 1;
GRM_AddonGlobals.PlayerFromGuildLog = "";
GRM_AddonGlobals.GuildLogDate = {};

-- Alt Helpers
GRM_AddonGlobals.selectedAlt = {};
GRM_AddonGlobals.selectedAltList = {};
GRM_AddonGlobals.currentHighlightIndex = 1;

-- Guildie info
GRM_AddonGlobals.listOfGuildies = {};
GRM_AddonGlobals.numAccounts = 0;

-- MISC Globals for resource handling... generally to avoid wasteful checks based on timers, position, pause controls.
-- Some of this is just to prevent messy carryover by keeping 1 less argument to a method, by just keeping a global. 
-- Some are for frame/UI control, like "pause" to stop mouseover updates if you are adjusting an input or editing a date or something similar.

-- TIMERS FOR ONUPDATE CONTROL TO AVOID SPAMMY CHECKS
GRM_AddonGlobals.timer = 0;
GRM_AddonGlobals.timer2 = 0; 
GRM_AddonGlobals.timer3 = 0;
GRM_AddonGlobals.timer4 = 0;
GRM_AddonGlobals.timer5 = 0;
GRM_AddonGlobals.SyncJDTimer = 0;           -- Use to hide window frame if all alts with dates are removed.
GRM_AddonGlobals.eventTimer = 0;            -- Use for OnUpdate Limiter for Event Tab on main window.
GRM_AddonGlobals.eventTimerTooltip = 0;     -- For the OnUpdate Limiter of the informative tooltip in roster window.
GRM_AddonGlobals.usersTimerTooltip = 0      -- For the OnUpdate Limiter on th AddonUsers window... 
GRM_AddonGlobals.ScanRosterTimer = 0;       -- keep track of how long since last scan.
GRM_AddonGlobals.buttonTimer1 = 0;          -- Controlling the info for 
GRM_AddonGlobals.buttonTimer2 = 0;

-- MISC argument resource saving globals.
GRM_AddonGlobals.CharCount = 0;
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
GRM_AddonGlobals.currentNameIndex = 2;
GRM_AddonGlobals.RecursiveStop = false;
GRM_AddonGlobals.isChecked = false;
GRM_AddonGlobals.isChecked2 = false;
GRM_AddonGlobals.ClickCount = 0;
GRM_AddonGlobals.HasAccessToGuildChat = false;
GRM_AddonGlobals.HasAccessToOfficerChat = false;
GRM_AddonGlobals.tempAltName = "";
GRM_AddonGlobals.firstTimeWarning = true;
GRM_AddonGlobals.tempAddBanClass = "";
GRM_AddonGlobals.isHyperlinkListenInitialized = false;
GRM_AddonGlobals.ChangesFoundOnLoad = false;
GRM_AddonGlobals.MsgFilterEnabled = false;
GRM_AddonGlobals.MsgFilterDelay = false;
GRM_AddonGlobals.LeftPlayersStillOnServer = {};

-- Throttle controls
GRM_AddonGlobals.ThrottleControlNum = 1;
GRM_AddonGlobals.ThrottleControlNum2 = 2;
GRM_AddonGlobals.newPlayers = {};
GRM_AddonGlobals.leavingPlayers = {};

-- Current Addon users
GRM_AddonGlobals.currentAddonUsers = {};

-- Dropdown logic helpers and Roster UI Logic
GRM_AddonGlobals.RosterButtons = {};
GRM_AddonGlobals.CurrentRank = "";

-- Version Control
GRM_AddonGlobals.VersionChecked = false;
GRM_AddonGlobals.VersionCheckRegistered = false;
GRM_AddonGlobals.VersionCheckedNames = {};
GRM_AddonGlobals.NeedsToAddSelfToList = false;
GRM_AddonGlobals.ActiveStatusQue = {};

-- For Temporary Slash Command Actions
GRM_AddonGlobals.TemporarySync = false;
GRM_AddonGlobals.ManualScanEnabled = false;

-- Banning players
GRM_AddonGlobals.TempBanTarget = {};

-- FOR LOCALIZATION
GRM_AddonGlobals.Region = GetLocale();
GRM_AddonGlobals.Localized = false;
GRM_AddonGlobals.FontChoice = "";
GRM_AddonGlobals.FontModifier = 0;

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
-- GuildRosterFontstrings = {};

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
local MessageListeners = CreateFrame ( "Frame" );   -- For listening to guild/whisper/misc chat windows so player "main" can be added to front

-- MISC FRAMES
UI_Events.GRM_NumGuildiesText = UI_Events:CreateFontString ( "GRM_NumGuildiesText" , "OVERLAY" , "GameFontNormalSmall" );

--------------------------
--- FUNCTIONS ------------
--------------------------

-- Method:          GRM.ClearPermData()
-- What it Does:    Resets all the saved data back to nothing... and does not rebuid it.
-- Purpose:         Mainly for use if ever there is a need to purge the data
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

    GRM_GuildNotePad_Save = nil;
    GRM_GuildNotePad_Save = {};
    table.insert ( GRM_GuildNotePad_Save , { "Horde" } );
    table.insert ( GRM_GuildNotePad_Save , { "Alliance" } );
    
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
        print ( "\n" .. GRM.L ( "Configuring Guild Roster Manager for {name} for the first time." , GetUnitName ( "PLAYER" , false ) ) );
        

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
            true,                                                                                                   -- 20) Add Join Date to Officer Note = true, Public Note = false
            true,                                                                                                   -- 21) Sync Ban List
            2,                                                                                                      -- 22) Rank player must be to send or receive Ban List sync updates!
            1,                                                                                                      -- 23) Only Report level increase greater than or equal to this.
            40,                                                                                                     -- 24) Sync % - 40 = 100 % speed
            345,                                                                                                    -- 25) Minimap Position
            78,                                                                                                     -- 26) Minimap Radius
            true,                                                                                                   -- 27) Notify when player requests to join guild the recruitment window
            false,                                                                                                  -- 28) Only View on Load if Changes were found
            true,                                                                                                   -- 29) Show "main" name in guild/whispers if player speaking on their alt
            false,                                                                                                  -- 30) Only show those needing to input data on the audit window.
            false,                                                                                                  -- 31) Sync Settings of all alts in the same guild
            true,                                                                                                   -- 32) Show Minimap Button
            true,                                                                                                   -- 33) Audit Frame - Unknown Counts as complete
            true,                                                                                                   -- 34) ''
            true,                                                                                                   -- 35) ''
            true,                                                                                                   -- 36) ''
            true,                                                                                                   -- 37) ''
            true,                                                                                                   -- 38) ''
            true,                                                                                                   -- 39) ''
            true,                                                                                                   -- 40) ''
            1,                                                                                                      -- 41) ''
            1,                                                                                                      -- 42) ''
            1,                                                                                                      -- 43) ''
            1,                                                                                                      -- 44) ''
            1                                                                                                       -- 45) ''
        };
       
        -- Unique Settings added to the player.
        table.insert ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][ #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] ] , AllDefaultSettings );

        -- Forcing core log window/options frame to load on the first load ever as well
        GRM_AddonGlobals.ChangesFoundOnLoad = true;

    elseif GRM_AddonSettings_Save[GRM_AddonGlobals.FID][indexFound][2][1] ~= GRM_AddonGlobals.Version then
        -- NumericV is used to compare older versions.
        local numericV = tonumber ( string.sub ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][indexFound][2][1] , string.find ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][indexFound][2][1] , "R" ) + 1 , # GRM_AddonSettings_Save[GRM_AddonGlobals.FID][indexFound][2][1] ) );

        -------------------------------
        --- START PATCH FIXES ---------
        -------------------------------
        
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
        if #GRM_AddonSettings_Save[GRM_AddonGlobals.FID][2][2] == 26 then
            GRM_Patch.ExpandOptions();
        end

        -- Intoduced Patch R1.122
        -- Adds an additional point of logic for "Unknown" on join date...
        if numericV < 1.122 then
            GRM_Patch.IntroduceUnknown();
        end

        -- Introduced Patch R1.125
        -- Bug fix... need to purge of repeats
        if numericV < 1.125 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][2][2][24] == 0 then
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
        if #GRM_AddonSettings_Save[GRM_AddonGlobals.FID][2][2] == 30 then
            GRM_Patch.ExpandOptionsScalable( 10 , 30 , true );  -- Adding 10 boolean spots
        end

        -- Introdued Patch R1.126
        -- Need some more options int placeholders for dropdown menus
        if #GRM_AddonSettings_Save[GRM_AddonGlobals.FID][2][2] == 40 then
            GRM_Patch.ExpandOptionsScalable( 5 , 40 , false );  -- Adding 10 boolean spots
        end

        -- Introduced Patch R1.126
        -- Minimap Created!!!
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][2][2][25] == 0 or GRM_AddonSettings_Save[GRM_AddonGlobals.FID][2][2][26] == 0 then
            GRM_Patch.SetMinimapValues();
        end

        -- Introduced R1.129
        -- Some erroneous promo date formats occurred due to a faulty previous update. These cleans them up.
        if numericV < 1.129 then
            GRM_Patch.CleanupPromoDates();
        end

        -- Introduced R1.130
        -- Sync addon settings should not be enabled by default.
        if numericV < 1.130 then
            GRM_Patch.TurnOffDefaultSyncSettingsOption();
        end
        
        -------------------------------
        -- END OF PATCH FIXES ---------
        -------------------------------

        -- Ok, let's update the version!
        print ( GRM.L ( "GRM Updated:" ) .. " v" .. string.sub ( GRM_AddonGlobals.Version , 6 ) );

        -- Updating the version for ALL saved accoutns.
        for i = 1 , #GRM_AddonSettings_Save do
            for j = 2 , #GRM_AddonSettings_Save[i] do
                GRM_AddonSettings_Save[i][j][2][1] = GRM_AddonGlobals.Version;      -- Changing version for all indexes of all toons on this account
            end
        end
    end

    -- Need to doublecheck Faction Index ID
    if GRM_AddonGlobals.faction == 0 then
        if GRM_AddonGlobals.faction == "Horde" then
            GRM_AddonGlobals.FID = 1;
        elseif GRM_AddonGlobals.faction == "Alliance" then
            GRM_AddonGlobals.FID = 2;
        end
    end

    -- for Settings
    for i = 2 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] do
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.addonPlayerName then
            GRM_AddonGlobals.setPID = i;
            break;
        end
    end
    
    -- Let's load that minimap button now too...
    GRM_UI.GRM_MinimapButtonInit();
    
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
        true,                                                                                                   -- 20) Add Join Date to Officer Note = true, Public Note = false
        true,                                                                                                   -- 21) Sync Ban List
        2,                                                                                                      -- 22) Rank player must be to send or receive Ban List sync updates!
        1,                                                                                                      -- 23) Only Report level increase greater than or equal to this.
        40,                                                                                                     -- 24) Sync % - 40 = 100 % speed
        345,                                                                                                    -- 25) Minimap Position
        78,                                                                                                     -- 26) Minimap Radius
        true,                                                                                                   -- 27) Notify when player requests to join guild the recruitment window
        false,                                                                                                  -- 28) Only View on Load if Changes were found
        true,                                                                                                   -- 29) Show "main" name in guild/whispers if player speaking on their alt
        false,                                                                                                  -- 30) Only show those needing to input data on the audit window.
        false,                                                                                                  -- 31) Sync Settings of all alts in the same guild
        true,                                                                                                   -- 32) Show Minimap Button
        true,                                                                                                   -- 33) Audit Frame - Unknown Counts as complete
        true,                                                                                                   -- 34) ''
        true,                                                                                                   -- 35) ''
        true,                                                                                                   -- 36) ''
        true,                                                                                                   -- 37) ''
        true,                                                                                                   -- 38) ''
        true,                                                                                                   -- 39) ''
        true,                                                                                                   -- 40) ''
        1,                                                                                                      -- 41) ''
        1,                                                                                                      -- 42) ''
        1,                                                                                                      -- 43) ''
        1,                                                                                                      -- 44) ''
        1                                                                                                       -- 45) ''
    }

    -- If scan  was previously disabled, need to re-trigger it.
    if not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_ScanningOptionsFrame.GRM_RosterTimeIntervalCheckButton:GetChecked() then
        GRM.Report ( GRM.L ( "Reactivating Auto SCAN for Guild Member Changes..." ) );

        GuildRoster();
        C_Timer.After ( 5 , GRM.TriggerTrackingCheck );     -- 5 sec delay necessary to trigger server call.
    end

    -- if sync was disabled
    if ( not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncCheckButton:GetChecked() or ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList:IsEnabled() and not GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncBanList:GetChecked() and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][21] ) ) and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
        if not GRMsyncGlobals.currentlySyncing and GRM_AddonGlobals.HasAccessToGuildChat then
            GRM.Report ( GRM.L ( "Reactivating Data Sync..." ) );
            GRMsync.TriggerFullReset();
            -- Now, let's add a brief delay, 3 seconds, to trigger sync again
            GRMsync.Initialize();
        end
    end

    if GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then
        GRM_UI.BuildLogFrames();
    end
end

-- Method:          GRM.SyncAddonSettings()
-- What it Does:    It syncs all of the addon settings of the current player with all of the other alts the player has within that guild
-- Purpose:         To have a "global" settings option.
GRM.SyncAddonSettings = function()
    for i = 2 , #GRM_PlayerListOfAlts_Save[GRM_AddonGlobals.FID] do
        if GRM_PlayerListOfAlts_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.guildName then
            -- Now, let's sync the settings of all players
            for j = 2 , #GRM_PlayerListOfAlts_Save[GRM_AddonGlobals.FID][i] do
                if GRM_PlayerListOfAlts_Save[GRM_AddonGlobals.FID][i][j][1] ~= GRM_AddonGlobals.addonPlayerName then
                    -- Ok, guild found, and a player that is not the current logged in addon user found... need to sync settings with this player
                    for s = 2 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] do
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][s][1] == GRM_PlayerListOfAlts_Save[GRM_AddonGlobals.FID][i][j][1] then
                            -- Preserve the Minimap button rules, however... both on if to show, and the position are preserved...
                            local tempMinimapHolder = { GRM_AddonSettings_Save[GRM_AddonGlobals.FID][s][2][32] , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][s][2][25] , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][s][2][26] };
                            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][s][2] = GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2];      -- overwrite each player's settings with the current
                            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][s][2][32] = tempMinimapHolder[1];
                            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][s][2][25] = tempMinimapHolder[2];
                            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][s][2][26] = tempMinimapHolder[3];
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
    if GRM_AddonGlobals.guildName ~= nil then
        for i = 2 , #GRM_PlayerListOfAlts_Save[GRM_AddonGlobals.FID] do
            if GRM_PlayerListOfAlts_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.guildName then
                -- Now, let's sync the settings of all players
                local isSynced = false;
                for j = 2 , #GRM_PlayerListOfAlts_Save[GRM_AddonGlobals.FID][i] do
                    if GRM_PlayerListOfAlts_Save[GRM_AddonGlobals.FID][i][j][1] ~= GRM_AddonGlobals.addonPlayerName then
                        for s = 2 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] do
                            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][s][1] == GRM_PlayerListOfAlts_Save[GRM_AddonGlobals.FID][i][j][1] then
                                -- Now, player alt is identified... now I need to check if their settings is set to sync true, and if so, then absorb them as my own.
                                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][s][2][31] then
                                        GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2] = GRM_AddonSettings_Save[GRM_AddonGlobals.FID][s][2];      -- Setting new toon to that toon's alt settings...
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
    if string.find ( name , "-" , 1 ) ~= nil then
        return string.sub ( name , 1 , string.find ( name ,"-" ) - 1 );
    else
        return name;
    end
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
            -- Adjust where playerName is
            local result = GRM_L[key];
            if playerName then          -- It is not nil
                result = string.gsub ( result , "{name}" , playerName );    -- insert playerName where needed - this is because in localization, for example "Arkaan's bday" in Spanish would have name at end of statement
            end
            if playerName2 then          -- It is not nil
                result = string.gsub ( result , "{name2}" , playerName2 );    -- insert playerName where needed - this is because in localization, for example "Arkaan's bday" in Spanish would have name at end of statement
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
            return result
        end
    else
        if key ~= nil then
            print("GRM WARNING!!! FAILURE TO LOAD THIS KEY: " .. key .. "\nPLEASE REPORT TO ADDON DEV! THANK YOU!" );  -- for debugging purposes.
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
    local result = "";
    -- if it is not nil, then we know we already have the OrigL
    if GRM_L[localizedString] == nil then
        for key , y in pairs ( GRM_L ) do
            if y == localizedString then
                result = key;
                break;
            end
        end
    else
        result = localizedString;
    end
    return result;
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

-- Method:          GRM.SetSystemMessageFilter ( self , string , string )
-- What it Does:    Starts tracking the system messages for filtering. This is only triggered on the audit frame initialization or if a player has left the guild
-- Purpose:         To control system message spam when doing server inquiries
GRM.SetSystemMessageFilter = function ( self , event , msg )   
    local result = false;
    -- GUILD INFO FILTER (GuildInfo())
    if ( GRM_AddonGlobals.MsgFilterDelay and ( string.find ( msg , GRM.L ( "Guild: " ) ) ~= nil or string.find ( msg , GRM.L ( "Guild created " ) ) ~= nil ) ) then       -- These may need to be localized. I have not yet tested if other regions return same info. It IS system info.
        if string.find ( msg , GRM.L ( "Guild created " ) ) ~= nil then
            local tempString = "";
            if GRM_AddonGlobals.Region == "ruRU" then
                tempString = string.sub ( msg , string.find ( msg , ":" , -10 ) + 2 , #msg );
            elseif GRM_AddonGlobals.Region == "zhTW" or GRM_AddonGlobals.Region == "zhCN" then
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
                    GRM_AddonGlobals.numAccounts = tonumber ( string.sub ( tempString , 1 , i - 1 ) );
                    break;
                end
            end
        end
        result = true;
    -- Player Not Found when trying to add to friends list message
    elseif GRM_AddonGlobals.MsgFilterDelay and ( msg == GRM.L ( "Player not found." ) or string.find ( msg , GRM.L ( "added to friends" ) ) ~= nil or string.find ( msg , GRM.L ( "is already your friend" ) ) ~= nil ) then
        result = true;
    else
        result = false;
    end
    return result;
end

-- Method:          GRM.SetNumUniqueGuildAccounts
-- Purpose:         Calls the server info on the guild and parses out the number of exact unique accounts are in the guild. It also filters the chat msg to avoid chat spam, then unfilters it immediately after
--                  as a Quality of Life feature so the user can manually continue to call as needed.
-- Purpose:         It is useful information to know how many unique acocunts are in the guild. This particularly is useful when comparing how many "mains" there 
--                  are on the audit window...
GRM.SetNumUniqueGuildAccounts = function()
    GRM_AddonGlobals.MsgFilterDelay = true;         -- Resets the 1 second timer upon calling this method for the chat spam blocking. This ensures player manual calls are visual, but code calls are filtered.
    if not GRM_AddonGlobals.MsgFilterEnabled then   -- Gate to ensure this only is registered one time. This is also controlled here so as to not waste resources by being called needlessly if player never checks audit window
        GRM_AddonGlobals.MsgFilterEnabled = true;   -- Establishing boolean gate so it is only registered once.
        ChatFrame_AddMessageEventFilter ( "CHAT_MSG_SYSTEM" , GRM.SetSystemMessageFilter );
    end

    GuildInfo();
    -- This should only be blocked momentarily.
    C_Timer.After ( 1 , function()
        GRM_AddonGlobals.MsgFilterDelay = false;
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

-- Method:          GRM.GetAllGuildiesInOrder ( boolean )
-- What it Does:    Returns a sorted string array of all guildies
-- Purpose:         Useful to have an alphabetized list of guildies :)
GRM.GetAllGuildiesInOrder = function( fullNameNeeded )
    GuildRoster();
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
    return listOfGuildies;
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
    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] ~= nil then
        for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == name then
                result = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][5];
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
-- What it Does:    Returns true of the player has permission to use the guild chat channel.
-- Purpose:         If guild chat channel is restricted then sync cannot be enabled either...
GRM.RegisterGuildChatPermission = function()
    GRMsync.SendMessage ( "GRM_GCHAT" , "" , "GUILD" );
    GRMsync.SendMessage ( "GRM_GCHAT" , "" , "OFFICER");
end


-- Method:          GRM.AddPlayerOnlineStatusCheck ( string )
-- What it Does:    Adds a player to the status check, to notify when they come Online!
-- Purpose:         Active tracking of changes within the guild on player status. Easy to notify you when someone comes online!
GRM.AddPlayerStatusCheck = function ( name , checkIndex )
    local isFound = false;
    local tempRosterList = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];
    for i = 1 , #GRM_AddonGlobals.ActiveStatusQue do
        if name == GRM_AddonGlobals.ActiveStatusQue[i][1] and checkIndex == GRM_AddonGlobals.ActiveStatusQue[i][3] then
            isFound = true;
            break;
        end
    end

    -- Good, the notification has not already been set...
    if not isFound then
        for i = 2 , #tempRosterList do
            if tempRosterList[i][1] == name then
                table.insert ( GRM_AddonGlobals.ActiveStatusQue , { name , tempRosterList[i][33] , checkIndex } );
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
    GRM_AddonGlobals.LeftPlayersStillOnServer = {};
    -- First, let's add him to friend's list
    if not GRM_AddonGlobals.MsgFilterEnabled then   -- Gate to ensure this only is registered one time. This is also controlled here so as to not waste resources by being called needlessly if player never checks audit window
        GRM_AddonGlobals.MsgFilterEnabled = true;   -- Establishing boolean gate so it is only registered once.
        ChatFrame_AddMessageEventFilter ( "CHAT_MSG_SYSTEM" , GRM.SetSystemMessageFilter );
    end

    local isFound = {};
    local tempListNames = {};           -- This list will be used to determine who to remove from friend's list.
    for i = 1 , #playerNames do
        isFound = GRM.IsOnFriendsList ( playerNames[i] );

        if not isFound[1] then
            GRM_AddonGlobals.MsgFilterDelay = true;
            AddFriend ( playerNames[i] );
            table.insert ( tempListNames , playerNames[i] );
        end
    end

    -- The delay needs to be here...
    C_Timer.After ( 1 , function()
        for i = 1 , #playerNames do
            isFound = GRM.IsOnFriendsList ( playerNames[i] );
    
            if isFound[1] then
                table.insert ( GRM_AddonGlobals.LeftPlayersStillOnServer , { playerNames[i] , isFound[2] } );

                for j = 1 , #tempListNames do
                    if tempListNames[j] == playerNames[i] then
                        RemoveFriend ( playerNames[i] );
                        RemoveFriend ( GRM.SlimName ( playerNames[i] ) );   -- Non merged realm will not have the server name, so this avoids the "Player not found" error
                        break;
                    end
                end
            end
        end
        GRM_AddonGlobals.MsgFilterDelay = false;
    end);
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

GRM.GetChatRGB = function ( channel )
    local result = {};
    if ChatTypeInfo[ channel ] ~= nil then
        result = { ChatTypeInfo[channel].r , ChatTypeInfo[channel].g , ChatTypeInfo[channel].b , ChatTypeInfo[channel].colorNameByClass };
    end
    return result;
end

-- Method:          GRM.AddMainToChat ( ... )
-- What it Does:    It adds either a Main tag to the player, or if they are on an alt, includes the name of the main.
-- Purpose:         Easy to see player name in guild chat, for achievments and so on...
GRM.AddMainToChat = function( self , event , msg , sender , ... )
    local result = false;
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][29] and sender ~= GRM_AddonGlobals.addonPlayerName then
        local guildData = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];
        local channelName = channelEnum [ event ];
        local colorCode = GRM.GetChatRGB ( GRM.GetChannelType ( channelName ) );
        local format = { "none" , "<M>" , "(M)" , "<Main>" , "(Main)" };
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
                                        msg = "|cffff0000" .. GRM.L ( "<M>" ) .. "|r(" .. GRM.SlimName ( guildData[i][11][j][1] ) .. "): " .. msg;
                                    else
                                        msg = "|cffff0000" .. GRM.L ( "<M>" ) .. "|r(" .. GRM.SlimName ( guildData[i][11][j][1] ) .. "): " .. msg;
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

-- FOR CHAT FILTERING FOR INFO AND LISTENING... No need to parse it now, but possibly for the future...
-- ChatHistory_GetAccessID("CHAT_MSG_GUILD")
-- ChatFrame1:GetNumMessages(34)
-- /dump ChatFrame1:GetMessageInfo(1,34)
-- /run for i=1,ChatFrame1:GetNumMessages(34) do local t,aID,id,ex=ChatFrame1:GetMessageInfo(i);print(ex);end
-- /dump ChatFrame1:GetNumLinesDisplayed()

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
            chat:AddMessage ( "|cff00c8ff" .. GRM.L ( "GRM:" ) .. " |cffffffff" .. GRM.L ( "A new version of Guild Roster Manager is Available!" ) .. " |cffff0044" .. GRM.L ( "Please Upgrade!" ) );
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

-- Method:          RegisterGuildAddonUsersRefresh ()
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
                result = "Their Rank too Low";
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
        local byteValue = string.byte ( char );
        if tonumber ( char ) ~= nil or char == " " or char == "\\" or char == "\n" or char == ":" or char == "(" or char == "$" or char == "%" then
            return false;
        end
        -- Real ASCII limitations for the fonts
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

        elseif GRM_AddonGlobals.FontChoice == "FONTS\\PT_Sans_Narrow.ttf" then      -- ElvUI Default Font

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
    GRM_AddonGlobals.TempLeftGuildPlaceholder = {};
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
        return -1;
    end
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
    local months = math.floor ( ( hours % 8766 ) / 730 );
    local days = math.floor ( ( hours % 730 ) / 24 );

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

-- Method:          GRM.GetTimestampBasedOnTimePassed ( array )
-- What it Does:    Returns an array that contains a string timestamp of the date based on the timepassed, as well as the epochstamp corresponding to that date
-- Purpose:         Incredibly necessary for join date and promo date tagging with proper dates for display and for sync.
GRM.GetTimestampBasedOnTimePassed = function ( dateInfo )
    local stampYear = dateInfo[1];
    local stampMonth = dateInfo[2];
    local stampDay = dateInfo[3];
    local stampHour = dateInfo[4];
    local hour, minutes = GetGameTime();
    local _ , month , day , year = CalendarGetDate();
    local LeapYear = GRM.IsLeapYear ( year );
    local time = "12:01am";                     -- Generic stamp.
    local date = date ( "*t" );
    
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
        local morning = true;
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
        -- Establishing proper format
        time = hour .. ":" .. minutes;
        if morning then
            time =  ( time .. "am" );
        else
            time =  ( time .. "pm" );
        end
    end
    
    local timestamp = day .. " " .. monthEnum2[ tostring ( month ) ] .. " '" .. year;
    return { timestamp .. " " .. time , GRM.TimeStampToEpoch ( " " .. timestamp , true ) };
end

------------------------------------
------ END OF TIME METHODS ---------
------------------------------------

------------------------------------
------ UI FORMATTING HELPERS -------
------------------------------------

GRM.AllignTwoColumns = function ( listOfStrings , spacing )
    -- First, determine longest string width of headers
    local result = "\n";
    UI_Events.InvisFontStringWidthCheck:SetText( listOfStrings[1][1] );         -- need to set string to measurable value
    local longestW = UI_Events.InvisFontStringWidthCheck:GetWidth();
    for i = 2 , #listOfStrings do
        UI_Events.InvisFontStringWidthCheck:SetText( listOfStrings[i][1] );
        local tempW = UI_Events.InvisFontStringWidthCheck:GetWidth();
        if tempW > longestW then
            longestW = tempW;
        end
    end

    -- Now, establish the total necessary width - We are setting spacing at 5.
    longestW = longestW + spacing;
    for i = 1 , #listOfStrings do
        UI_Events.InvisFontStringWidthCheck:SetText( listOfStrings[i][1] );
        while UI_Events.InvisFontStringWidthCheck:GetWidth() < longestW do
            UI_Events.InvisFontStringWidthCheck:SetText ( UI_Events.InvisFontStringWidthCheck:GetText() .. " " );       -- Keep adding spaces until it matches
        end
        result = result .. UI_Events.InvisFontStringWidthCheck:GetText() .. listOfStrings[i][2];
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
    local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11];
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
            --GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index1][11]
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
            local result = GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][ index1 ][11][i][1] );
            if i == 1 then
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][ index1 ][11][i][5] == true then  --- this person is the main!
                    result = result .. "\n|cffff0000" .. GRM.L ( "(main)" );
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
                    GRM_UI.GRM_altDropDownOptions:SetSize ( width , 92 );
                    GRM_UI.GRM_altDropDownOptions:Show();

                    GRM_UI.GRM_altRemoveButtonText:SetText ( GRM.L ( "Remove" ) );

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
        GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollFrame:SetScript( "OnMouseWheel" , function( self , delta )
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
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do      
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == playerName then
            class = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][9];
            break;
        end
    end
    return class;
end

-- Method:          GRM.GetClassColorRGB ( string )
-- What it Does:    Returns the 0-1 RGB color scale for the player class
-- Purpose:         Easy class color tagging for UI feature.
GRM.GetClassColorRGB = function ( className , getHex )
    local result;
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
            result = { 1.0 , 0.49 , 0.04 };
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
            result = { 0.0 , 1.0 , 0.59 };
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
            result = { 1.0 , 1.0 , 1.0 };
        end
    elseif className == "ROGUE" then
        if getHex then
            result = "|CFFFFF569";
        else
            result = { 1.0 , 0.96 , 0.41 };
        end
    elseif className == "SHAMAN" then
        if getHex then
            result = "|CFF0070DE";
        else
            result = { 0.0 , 0.44 , 0.87 };
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

-- Method:          GRM.GetStringClassColorByName ( string )
-- What it Does:    Returns the RGB Hex code of the given class of the player named
-- Purpose:         Useful for carrying over class name with tagged colors into a string, without needing to change the hwole string's color
GRM.GetStringClassColorByName = function ( name , notCurrentlyInGuild )
    local tempDatabase;
    if notCurrentlyInGuild ~= nil and notCurrentlyInGuild then
        tempDatabase = GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];
    else
        tempDatabase = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];           -- This helps avoid issues that could cause stutter by more than 1 thing accessing database at same time.
    end
    local result = "";
    local serverNameFound = false;
    -- If it is found, then you are on a merged realm server. If it is not found, you are NOT on a merged realm server.
    if string.find ( name , "-" ) ~= nil then
        serverNameFound = true;
    end
    -- let's concatenate the server on there for NON merged realm guilds
    if not serverNameFound then
        name = name .. "-" .. GRM_AddonGlobals.realmName
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
    local roster = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];
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

-- Method:          GRM.RemoveAlt(string , string , string , boolean , int , boolean )
-- What it Does:    Detags the given altName to that set of toons.
-- Purpose:         Alt management, so whoever has addon installed can tag player.
GRM.RemoveAlt = function ( playerName , altName , guildName , isSync , syncTimeStamp , errorProtection )

    -- To protect the data if someone is sending you corrupted, broken, or nefarious alt info...
    if errorProtection then
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do      
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then
                for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] do
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][i][1] == altName then
                        table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] , i );
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
        local index1;
        local altIndex1;
        local count = 0;
        local altIsFound = false;

        -- This block is mainly for resource efficiency, to prevent the blocks from getting too nested, and to store index location for quick access.
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do      
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then        -- Identify position of player
                count = count + 1;
                index1 = j;
            end
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == altName then           -- Pull altName to attach class on Color
                count = count + 1;
                altIndex1 = j;
                altIsFound = true;
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

        -- For protections, in case the player is trying to send you bad data... 
        if not altIsFound then
            GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_RMVERR?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. playerName .. "?" .. altName , "GUILD");
            return
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
        if GRM_UI.GRM_MemberDetailMetaData ~= nil and GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
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
        GRM.Report ( GRM.L ( "{name} cannot remove themselves from alts." , GRM.SlimName ( playerName ) ) );
        
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
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do      
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then        -- Identify position of player
                count = count + 1;
                index2 = j;
                classMain = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][9];
            end
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == altName then           -- Pull altName to attach class on Color
                count = count + 1;
                altIndex2 = j;
                altIsFound = true;
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
        -- For protections, in case the player is trying to send you bad data... 
        if not altIsFound then
            GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_RMVERR?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. playerName .. "?" .. altName , "GUILD");
            return
        end
        if index2 == -1 then
            GRM.Report ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "Failed to add alt for unknown reason. Try closing Roster window and retrying!" ) );
            return
        end
        
        -- NEED TO VERIFY IT IS NOT AN ALT FIRST!!! it is removing and re-adding if it is same person.
        local isFound = false;
        if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11] > 0 then
            local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11];
            
            for m = 1 , #listOfAlts do                                              -- Let's quickly verify that this is not a repeat alt add.
                if listOfAlts[m][1] == playerName then
                    GRM.Report ( GRM.L ( "{name} is Already Listed as an Alt." , GRM.SlimName ( altName ) ) );
                    isFound = true;
                    break;
                end
            end
        end
        -- If player is trying to add this toon to a list that is already on a list then it adds it in reverse
        if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11] > 0 and #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index2][11] > 0 and not isFound then  -- Oh my! Both players have current lists!!! Remove the alt from his list, add to this new one.
            GRM.RemoveAlt ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][11][1][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][altIndex2][1] , guildName , isSync , syncTimeStamp , false );
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
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:Hide();
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
                                    GRM.Report ( GRM.L ( "{name} is Already Listed as an Alt." , GRM.SlimName ( altName ) ) );
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
            if GRM_UI.GRM_MemberDetailMetaData ~= nil and GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
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
        print ( GRM.L ( "{name} cannot become their own alt!" , GRM.SlimName ( playerName ) ) );
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
    if GRM_UI.GRM_MemberDetailMetaData ~= nil and GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
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
    
            if GRM_UI.GRM_CoreAltFrame.GRM_AltName1:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName1:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][1][1];
                isAlt1 = true;
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName2:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName2:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][2][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName3:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName3:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][3][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName4:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName4:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][4][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName5:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName5:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][5][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName6:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName6:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][6][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName7:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName7:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][7][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName8:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName8:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][8][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName9:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName9:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][9][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName10:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName10:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][10][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName11:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName11:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][11][1];
            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName12:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName12:IsMouseOver( 2 , -2 , -2 , 2 ) then
                altName = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][12][1];
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
    if GRM_UI.GRM_MemberDetailMetaData ~= nil and GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
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
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton1:LockHighlight();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton2:UnlockHighlight();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton3:UnlockHighlight();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton4:UnlockHighlight();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton5:UnlockHighlight();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame.GRM_AddAltNameButton6:UnlockHighlight();
    GRM_AddonGlobals.currentHighlightIndex = 1;
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
    GRM_AddonGlobals.listOfGuildies = nil;
    GRM_AddonGlobals.listOfGuildies = {};
    local numButtons = 6;
    local guildRoster = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];

    for i = 2 , #guildRoster do
        if guildRoster[i][1] ~= GRM_AddonGlobals.currentName then   -- no need to go through player's own window
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
            table.insert ( GRM_AddonGlobals.listOfGuildies , { guildRoster[i][1] , guildRoster[i][9] , tag } );
        end
    end
    -- Need to sort "Complex" table
    sort ( GRM_AddonGlobals.listOfGuildies , function ( a , b ) return a[1] < b[1] end );    -- Alphabetizing it for easier parsing for buttontext updating. - This sorts the first index of the 2D array
    
    -- Now, let's identify the names that match
    local count = 0;
    local matchingList = {};
    local found = false;
    local innerFound = false;
    for i = 1 , #GRM_AddonGlobals.listOfGuildies do
        innerFound = false;
        if string.lower ( partName ) == string.lower ( string.sub ( GRM_AddonGlobals.listOfGuildies[i][1] , 1 , #partName ) ) then
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

    -- If No alphabetical matches, try partial
    count = 0;
    if #matchingList == 0 then
        for i = 1 , #GRM_AddonGlobals.listOfGuildies do
            if string.find ( string.lower ( GRM_AddonGlobals.listOfGuildies[i][1] ) , string.lower ( partName ) ) ~= nil then
                count = count + 1;
                table.insert ( matchingList , GRM_AddonGlobals.listOfGuildies[i] );
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
            if string.lower ( GRM_AddonGlobals.currentName ) == string.lower ( partName ) then
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
                    if GRM_UI.GRM_PopupWindowCheckButton1:GetChecked() then     -- Player wants to BAN the alts confirmed!
                        for s = 1 , #listOfAlts do
                            for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == listOfAlts[s][1] and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] ~= GRM_AddonGlobals.addonPlayerName then        -- Logic to avoid kicking oneself ( or at least to avoid getting error notification )
                                    -- Set the banned info.
                                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][1] = true;
                                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][2] = time();
                                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][3] = false;
                                    local instructionNote = GRM.L ( "Reason Banned?" ) .. "\n" .. GRM.L ( "Click \"YES\" When Done" );
                                    local result = GRM_UI.GRM_MemberDetailPopupEditBox:GetText();

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

    -- First things first... ensure the player is not already added...
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == memberInfo[1] then
            return
        end
    end
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
                isMobile , rep , timePlayerEnteredZone , isOnline , memberStatus , joinDateTimestamp , promoDateTimestamp , listOfRemovedAlts , mainStatusChangeTimestamp , timeMainStatusAltered , joinDateIsUnknown , promoDateIsUnknown } );  -- 40 so far. (35-39 = sync stamps)
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
            table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] , { "|cFFC41F3BLeft Guild" , GRM.Trim ( string.sub ( leftGuildDate , 1 , 10 ) ) , leftGuildMeta } );
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
    local scrollWidth = 561;
    local buffer = 15;

    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons or {};  -- Create a table for the Buttons.
    -- populating the window correctly.
    local tempHeight = 0;
    for i = 1 , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] - 1 do
        -- if font string is not created, do so.
        if not GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i] then
            local tempButton = CreateFrame ( "Button" , "PlayerToAdd" .. i , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame ); -- Names each Button 1 increment up
            GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i] = { tempButton , tempButton:CreateFontString ( "PlayerToAddText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "PlayerToAddTitleText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) , tempButton:CreateFontString ( "PlayerToAddDescriptionText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) };
        end
        local EventButtons = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i][1];
        local EventButtonsText = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i][2];
        local EventButtonsText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i][3];
        local EventButtonsText3 = GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame.allFrameButtons[i][4];
        local classColorRGB = GRM.GetClassColorRGB ( GRM.GetPlayerClass ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][1] ) );

        -- Set the values..
        EventButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame , 7 , -99 );
        EventButtons:SetWidth ( 558 );
        EventButtons:SetHeight ( 19 );
        EventButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
        EventButtonsText:SetText ( GRM.SlimName ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][1] ) );
        EventButtonsText:SetTextColor ( classColorRGB[1] , classColorRGB[2] , classColorRGB[3] , 1 );
        EventButtonsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
        EventButtonsText:SetPoint ( "LEFT" , EventButtons );
        EventButtonsText:SetJustifyH ( "LEFT" );
        local name = GRM.SlimName ( string.sub ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2] , 0 , ( string.find ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2] , " " ) - 1 ) - 2 ) );
        local eventName = string.sub ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2] , string.find ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2] , " " ) , #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2] );
        local result = "";
        -- For localization of final display fontstring
        if string.find ( eventName , "Anniversary!" ) ~= nil then
            result = GRM.L ( "{name}'s Anniversary!" , name );
        elseif string.find ( eventName , "Birthday!" ) ~= nil then
            result = GRM.L ( "{name}'s Birthday!" , name );
        else
            result = GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][2];
        end
        EventButtonsText2:SetText ( result );
        EventButtonsText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
        EventButtonsText2:SetJustifyH ( "LEFT" );
        EventButtonsText3:SetText ( GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i + 1][6] );
        EventButtonsText3:SetWidth ( 275 );
        EventButtonsText3:SetWordWrap ( false );
        EventButtonsText3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );
        EventButtonsText3:SetPoint ( "LEFT" , EventButtons );
        EventButtonsText3:SetJustifyH ( "LEFT" );
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
                GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:SetText ( EventButtonsText2:GetText() );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddTitleText:SetText ( EventButtonsText: GetText() );
                
                -- parse out the button number, which will correlate with addonque frame...
                local buttonName = self:GetName();
                local index = tonumber ( string.sub ( buttonName , #buttonName ) ) + 1; -- It has to be incremented up by one as the stored data begins at index 2, not 1, as that references the guild.
                
                GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:SetText(  monthEnum2 [ '' .. GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][index][3] .. '' ] .. " " .. GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][index][4] );

                if GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:IsVisible() then
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameStatusMessageText:Hide();
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameToAddText:Show();
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_EventsFrameNameDateText:Show();
                end
            end
        end);
        
        -- Now let's pin it!
        if i == 1 then
            EventButtons:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame , "TOPLEFT" , 5 , -12 );
            EventButtonsText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame , "TOPLEFT" , 5 , -12 );
            EventButtonsText2:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame , "TOPLEFT" , 105 , -12 );
            EventButtonsText3:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollChildFrame , "TOPLEFT" , 280 , -12 );
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
    GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame.GRM_AddEventScrollFrame:SetScript( "OnMouseWheel" , function( self , delta )
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
    for i = 1 , #GRM_AddonGlobals.currentAddonUsers do
        -- We know there is at least one, so let's hide the warning string...
        GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.GRM_AddonUsersCoreFrameTitleText2:Hide();
        -- if font string is not created, do so.
        if not GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i] then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i] = { GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame:CreateFontString ( "GRM_AddonUserNameText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame:CreateFontString ( "GRM_AddonUserSyncText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame:CreateFontString ( "GRM_AddonUserVersionText" .. i , "OVERLAY" , "GameFontWhiteTiny" ) };
        end

        local AddonUserText1 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][1];
        local AddonUserText2 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][2];
        local AddonUserText3 = GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings[i][3];
        local classColorRGB = GRM.GetClassColorRGB ( GRM.GetPlayerClass ( GRM_AddonGlobals.currentAddonUsers[i][1] ) );
        AddonUserText1:SetText ( GRM.SlimName ( GRM_AddonGlobals.currentAddonUsers[i][1] ) );
        AddonUserText1:SetTextColor ( classColorRGB[1] , classColorRGB[2] , classColorRGB[3] );
        AddonUserText1:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 13 );
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
        AddonUserText2:SetText ( GRM.L ( GRM_AddonGlobals.currentAddonUsers[i][2] ) );
        AddonUserText2:SetWidth ( 200 );
        AddonUserText2:SetWordWrap ( false );
        AddonUserText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 13 );
        AddonUserText2:SetJustifyH ( "CENTER" );
        AddonUserText3:SetText ( string.sub ( GRM_AddonGlobals.currentAddonUsers[i][3] , string.find ( GRM_AddonGlobals.currentAddonUsers[i][3] , "R" , -8 ) , #GRM_AddonGlobals.currentAddonUsers[i][3] ) );
        AddonUserText3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 13 );
        AddonUserText3:SetJustifyH ( "RIGHT" );

        local stringHeight = AddonUserText1:GetStringHeight();

        -- Now let's pin it!
        if i == 1 then
            AddonUserText1:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame , "TOPLEFT" , 5 , - 15 );
            AddonUserText2:SetPoint( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame , "TOP" , -6 , - 15 );
            AddonUserText3:SetPoint( "TOPRIGHT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame , "TOPRIGHT" , -25 , - 15 );
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
    for i = #GRM_AddonGlobals.currentAddonUsers + 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollChildFrame.AllFrameFontstrings do
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
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame.GRM_AddonUsersScrollFrame:SetScript( "OnMouseWheel" , function( self , delta )
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
    if #GRM_AddonGlobals.currentAddonUsers == 0 then
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


-- Method:          GRM.RefreshAuditFrames()
-- What it Does:    Updates the audit frames when called
-- Purpose:         Audit frames are useful so the leader or player can do an easy visual check of the entire guild on what is needed.
GRM.RefreshAuditFrames = function()
    local scrollHeight = 0;
    local scrollWidth = 561;
    local buffer = 10;
    local guildList = GRM.GetAllGuildiesInOrder ( true );
    local ok = { 0 , 0.77 , 0.063 };
    local notOk = { 0.64 , 0.102 , 0.102 };
    local unknown = { 1.0 , 0.647 , 0 };
    local count = 1;
    local count2 = 0;
    local count3 = 0;
    local numJoinUnknown = 0;
    local numJoinNoDate = 0;
    local numPromoUnknown = 0;
    local numPromoNoDate = 0;
    local isComplete = true;
    local tempGuild = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];

    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings = GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame.AllFrameFontstrings or {};  -- Create a table for the Buttons.
    -- Building all the fontstrings.
    for i = 1 , #guildList do
        isComplete = true;
        for j = 2 , #tempGuild do
            if tempGuild[j][1] == guildList[i] then
            -- We know there is at least one, so let's hide the warning string...
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText5:Hide(guildList[i]);
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
                AddonUserText1:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
                AddonUserText1:SetJustifyH ( "LEFT" );
                AddonUserText1:SetWidth ( 190 );
                AddonUserText1:SetWordWrap ( false );

                -- Join Date
                AddonUserText2:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
                AddonUserText2:SetWidth ( 125 );
                AddonUserText2:SetWordWrap ( false );
                AddonUserText2:SetJustifyH ( "CENTER" );
                if #tempGuild[j][20] == 0 then
                    if tempGuild[j][40] then
                        AddonUserText2:SetText ( GRM.L ( "Unknown" ) );
                        AddonUserText2:SetTextColor ( unknown[1] , unknown[2] , unknown[3] , 1.0 );
                        numJoinUnknown = numJoinUnknown + 1;
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][33] then
                            isComplete = false;
                        end
                    else
                        AddonUserText2:SetText ( GRM.L ( "No Date Set" ) );
                        AddonUserText2:SetTextColor ( notOk[1] , notOk[2] , notOk[3] , 1.0 );
                        numJoinNoDate = numJoinNoDate + 1;
                        isComplete = false;
                    end
                else
                    AddonUserText2:SetText ( GRM.L ( "Ok!" ) );
                    AddonUserText2:SetTextColor ( ok[1] , ok[2] , ok[3] , 1.0 ); 
                end

                -- Promo Date
                AddonUserText3:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
                AddonUserText3:SetJustifyH ( "CENTER" );
                AddonUserText3:SetWidth ( 125 );
                if tempGuild[j][12] == nil then
                    if tempGuild[j][41] then
                        AddonUserText3:SetText ( GRM.L ( "Unknown" ) );
                        AddonUserText3:SetTextColor ( unknown[1] , unknown[2] , unknown[3] , 1.0 );
                        numPromoUnknown = numPromoUnknown + 1;
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][33] then
                            isComplete = false;
                        end
                    else
                        AddonUserText3:SetText ( GRM.L ( "No Date Set" ) );
                        AddonUserText3:SetTextColor ( notOk[1] , notOk[2] , notOk[3] , 1.0 );
                        numPromoNoDate = numPromoNoDate + 1;
                        isComplete = false;
                    end
                else
                    AddonUserText3:SetText ( GRM.L ( "Ok!" ) );
                    AddonUserText3:SetTextColor ( ok[1] , ok[2] , ok[3] , 1.0 ); 
                end

                -- Main or Alt
                AddonUserText4:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
                AddonUserText4:SetJustifyH ( "CENTER" );
                AddonUserText4:SetWidth ( 125 );
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] then
                    AddonUserText4:SetText ( GRM.L ( "Main" ) );
                    AddonUserText4:SetTextColor ( ok[1] , ok[2] , ok[3] , 1.0 );
                    count3 = count3 + 1;
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
                if not isComplete or not GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][30] then
                    -- Variable to hold height to know how much more to add to scrollframe.
                    local stringHeight = AddonUserText1:GetStringHeight();

                    -- Now let's pin it!
                    if count == 1 then
                        AddonUserText1:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame , "TOPLEFT" , 5 , - 10 );
                        AddonUserText2:SetPoint( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame , "TOP" , -35 , - 10 );
                        AddonUserText3:SetPoint( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame , "TOP" , 95 , - 10 );
                        AddonUserText4:SetPoint( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollChildFrame , "TOPRIGHT" , -52 , - 10 );
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
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditScrollFrame:SetScript( "OnMouseWheel" , function( self , delta )
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

    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText5:SetText ( GRM.L ( "Total Incomplete:" ) .. "   " .. count2 .. " / " .. GRM.GetNumGuildies() );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText5:Show();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText8:SetText ( GRM.L ( "Mains:" ) .. " " .. count3 );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText8:Show();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_AuditFrameText7:SetText ( GRM.L ( "Unique Accounts:" ) .. " " .. GRM_AddonGlobals.numAccounts );
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
    GRM_AddonGlobals.timer5 = 0;

    -- Notification that player has sync disabled themselves.
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
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
    if #GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] > 1 then
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
    -- Ok Building Frame!
    GRM.BuildEventCalendarManagerScrollFrame();
end

-- Method:          GRM.FinalReport()
-- What it Does:    Organizes flow of final report and send it to chat frame and to the logReport.
-- Purpose:         Clean organization for presentation.
GRM.FinalReport = function()
    local needToReport = false;

    -- For extra tracking info to display if the left player is on the server anymore...
    if #GRM_AddonGlobals.TempLeftGuild > 0 then
        -- need to build the names of those leaving for insert...
        
        local names = {};
        for i = 1 , #GRM_AddonGlobals.leavingPlayers do
            table.insert ( names , GRM_AddonGlobals.leavingPlayers[i][1] );
        end
        -- Establishing the players that left but are still on the server
        GRM.SetLeftPlayersStillOnServer ( names );
    end

    -- Cleanup the notes for reporting
    -- Join Dates Cleaned up First
    if #GRM_AddonGlobals.TempNewMember > 0 then
        local tempTable = {};
        for i = 1 , #GRM_AddonGlobals.TempNewMember do
            if string.find ( GRM_AddonGlobals.TempNewMember[i][2] , GRM.L ( "Invited By:" ) ) ~= nil then
                table.insert ( tempTable , 1 , GRM_AddonGlobals.TempNewMember[i] );
            else
                table.insert ( tempTable , GRM_AddonGlobals.TempNewMember[i] );
            end
        end
        GRM_AddonGlobals.TempNewMember = tempTable;
    end

    -- No need to spam the chat window when logging in.
    if not GRM_AddonGlobals.OnFirstLoad then
        if #GRM_AddonGlobals.TempNewMember > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] then
            
            for i = 1 , #GRM_AddonGlobals.TempNewMember do
                GRM.PrintLog ( GRM_AddonGlobals.TempNewMember[i][1] , GRM_AddonGlobals.TempNewMember[i][2] , GRM_AddonGlobals.TempNewMember[i][3] );   -- Send to print to chat window
            end
        end
    
        if #GRM_AddonGlobals.TempRejoin > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] then
            
            for i = 1 , #GRM_AddonGlobals.TempRejoin do
                GRM.PrintLog ( GRM_AddonGlobals.TempRejoin[i][1] , GRM_AddonGlobals.TempRejoin[i][2] , GRM_AddonGlobals.TempRejoin[i][3] );            -- Same Comments on down
                GRM.PrintLog ( GRM_AddonGlobals.TempRejoin[i][4] , GRM_AddonGlobals.TempRejoin[i][5] , GRM_AddonGlobals.TempRejoin[i][3] );
            end
        end

        if #GRM_AddonGlobals.TempBannedRejoin > 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][1] then
            
            for i = 1 , #GRM_AddonGlobals.TempBannedRejoin do
                GRM.PrintLog ( GRM_AddonGlobals.TempBannedRejoin[i][1] , GRM_AddonGlobals.TempBannedRejoin[i][2] , GRM_AddonGlobals.TempBannedRejoin[i][3] );
                GRM.PrintLog ( GRM_AddonGlobals.TempBannedRejoin[i][4] , GRM_AddonGlobals.TempBannedRejoin[i][5] , GRM_AddonGlobals.TempBannedRejoin[i][3] );
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
    end

    -- OK, NOW LET'S REPORT TO LOG FRAME IN REVERSE ORDER!!!

    if #GRM_AddonGlobals.TempEventRecommendKickReport > 0 then
        needToReport = true;
        if GRM_AddonGlobals.OnFirstLoad then
            GRM_AddonGlobals.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_AddonGlobals.TempEventRecommendKickReport do
            GRM.AddLog ( GRM_AddonGlobals.TempEventRecommendKickReport[i][1] , GRM_AddonGlobals.TempEventRecommendKickReport[i][2]);                    
        end
    end

    if #GRM_AddonGlobals.TempEventReport > 0 then
        needToReport = true;
        if GRM_AddonGlobals.OnFirstLoad then
            GRM_AddonGlobals.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_AddonGlobals.TempEventReport do
            GRM.AddLog( GRM_AddonGlobals.TempEventReport[i][1] , GRM_AddonGlobals.TempEventReport[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempLogONote > 0 then
        needToReport = true;
        if GRM_AddonGlobals.OnFirstLoad then
            GRM_AddonGlobals.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_AddonGlobals.TempLogONote do
            GRM.AddLog ( GRM_AddonGlobals.TempLogONote[i][1] , GRM_AddonGlobals.TempLogONote[i][2] );                    
        end
    end
 
    if #GRM_AddonGlobals.TempLogNote > 0 then
        needToReport = true;
        if GRM_AddonGlobals.OnFirstLoad then
            GRM_AddonGlobals.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_AddonGlobals.TempLogNote do
            GRM.AddLog ( GRM_AddonGlobals.TempLogNote[i][1] , GRM_AddonGlobals.TempLogNote[i][2] );                    
        end
    end

    if #GRM_AddonGlobals.TempLogLeveled > 0 then
        needToReport = true;
        if GRM_AddonGlobals.OnFirstLoad then
            GRM_AddonGlobals.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_AddonGlobals.TempLogLeveled do
            GRM.AddLog ( GRM_AddonGlobals.TempLogLeveled[i][1] , GRM_AddonGlobals.TempLogLeveled[i][2] );                    
        end
    end

    if #GRM_AddonGlobals.TempRankRename > 0 then
        needToReport = true;
        if GRM_AddonGlobals.OnFirstLoad then
            GRM_AddonGlobals.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_AddonGlobals.TempRankRename do
            GRM.AddLog ( GRM_AddonGlobals.TempRankRename[i][1] , GRM_AddonGlobals.TempRankRename[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempLogDemotion > 0 then
        needToReport = true;
        if GRM_AddonGlobals.OnFirstLoad then
            GRM_AddonGlobals.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_AddonGlobals.TempLogDemotion do
            GRM.AddLog ( GRM_AddonGlobals.TempLogDemotion[i][1] , GRM_AddonGlobals.TempLogDemotion[i][2] );                           
        end
    end

    if #GRM_AddonGlobals.TempLogPromotion > 0 then
        needToReport = true;
        if GRM_AddonGlobals.OnFirstLoad then
            GRM_AddonGlobals.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_AddonGlobals.TempLogPromotion do
            GRM.AddLog ( GRM_AddonGlobals.TempLogPromotion[i][1] , GRM_AddonGlobals.TempLogPromotion[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempNameChanged > 0 then
        needToReport = true;
        if GRM_AddonGlobals.OnFirstLoad then
            GRM_AddonGlobals.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_AddonGlobals.TempNameChanged do
            GRM.AddLog ( GRM_AddonGlobals.TempNameChanged[i][1] , GRM_AddonGlobals.TempNameChanged[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempInactiveReturnedLog > 0 then
        needToReport = true;
        if GRM_AddonGlobals.OnFirstLoad then
            GRM_AddonGlobals.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_AddonGlobals.TempInactiveReturnedLog do
            GRM.AddLog ( GRM_AddonGlobals.TempInactiveReturnedLog[i][1] , GRM_AddonGlobals.TempInactiveReturnedLog[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempBannedRejoin > 0 then
        needToReport = true;
        if GRM_AddonGlobals.OnFirstLoad then
            GRM_AddonGlobals.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_AddonGlobals.TempBannedRejoin do
            GRM.AddLog ( GRM_AddonGlobals.TempBannedRejoin[i][4] , GRM_AddonGlobals.TempBannedRejoin[i][5] );
            GRM.AddLog ( GRM_AddonGlobals.TempBannedRejoin[i][1] , GRM_AddonGlobals.TempBannedRejoin[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempRejoin > 0 then
        needToReport = true;
        if GRM_AddonGlobals.OnFirstLoad then
            GRM_AddonGlobals.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_AddonGlobals.TempRejoin do
            GRM.AddLog ( GRM_AddonGlobals.TempRejoin[i][4] , GRM_AddonGlobals.TempRejoin[i][5] );
            GRM.AddLog ( GRM_AddonGlobals.TempRejoin[i][1] , GRM_AddonGlobals.TempRejoin[i][2] );
        end
    end

    if #GRM_AddonGlobals.TempNewMember > 0 then
        needToReport = true;
        if GRM_AddonGlobals.OnFirstLoad then
            GRM_AddonGlobals.ChangesFoundOnLoad = true;
        end
        for i = 1 , #GRM_AddonGlobals.TempNewMember do
            GRM.AddLog ( GRM_AddonGlobals.TempNewMember[i][1] , GRM_AddonGlobals.TempNewMember[i][2] );                                           -- Adding to the Log of Events
        end
    end
    -- 1.1 to set it immediately after the other 1 second delay for server to register added friends.
    local time = 1.1;
    if #GRM_AddonGlobals.TempLeftGuild == 0 then
        time = 0;
    end

    -- Delay function so players can be determined if they are online or not.
    C_Timer.After ( time , function()
        if #GRM_AddonGlobals.TempLeftGuild > 0 then
            needToReport = true;
            if GRM_AddonGlobals.OnFirstLoad then
                GRM_AddonGlobals.ChangesFoundOnLoad = true;
            end
            -- Let's compare our left players now...
            local isMatched = false;
            for i = 1 , #GRM_AddonGlobals.leavingPlayers do
                isMatched = false;
                for j = 1 , #GRM_AddonGlobals.LeftPlayersStillOnServer do
                    if GRM_AddonGlobals.leavingPlayers[i][1] == GRM_AddonGlobals.LeftPlayersStillOnServer[j][1] then
                        isMatched = true;
                        -- now let's match it to propper tempLeft table
                        break;
                    end
                end

                -- if not isMatched then (player not on friends list... this means that the player has left the server or namechanged)
                if not isMatched then
                    for m = 1 , #GRM_AddonGlobals.TempLeftGuild do
                        if string.find ( GRM_AddonGlobals.TempLeftGuild[m][2] , GRM.L ( "has Left the guild" ) ) ~= nil and string.find ( GRM_AddonGlobals.TempLeftGuild[m][2] , GRM.SlimName ( GRM_AddonGlobals.leavingPlayers[i][1] ) ) ~= nil then
                            if string.find ( GRM_AddonGlobals.TempLeftGuild[m][2] , GRM.L ( "ALTS IN GUILD:" ) ) ~= nil then
                                local _ , index2 = string.find ( GRM_AddonGlobals.TempLeftGuild[m][2] , "\n" );
                                GRM_AddonGlobals.TempLeftGuild[m][2] = string.sub ( GRM_AddonGlobals.TempLeftGuild[m][2] , 1 , index2 - 1 ) .. " |CFFFF0000(" .. GRM.L ( "Player no longer on Server" ) .. ")|CFF808080" .. string.sub ( GRM_AddonGlobals.TempLeftGuild[m][2] , index2 );
                            else
                                GRM_AddonGlobals.TempLeftGuild[m][2] = GRM_AddonGlobals.TempLeftGuild[m][2] .. " |CFFFF0000(" .. GRM.L ( "Player no longer on Server" ) .. ")";
                            end
                            break;
                        end
                    end
                end
            end
            -- Ok, sending to chat
            if not GRM_AddonGlobals.OnFirstLoadKick then
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][11] then
                    for i = 1 , #GRM_AddonGlobals.TempLeftGuild do
                        GRM.PrintLog ( GRM_AddonGlobals.TempLeftGuild[i][1] , GRM_AddonGlobals.TempLeftGuild[i][2] , GRM_AddonGlobals.TempLeftGuild[i][3] );
                    end
                end
            end
            -- sending to log
            for i = 1 , #GRM_AddonGlobals.TempLeftGuild do
                if GRM_AddonGlobals.OnFirstLoad then
                    GRM_AddonGlobals.ChangesFoundOnLoad = true;
                end
                GRM.AddLog ( GRM_AddonGlobals.TempLeftGuild[i][1] , GRM_AddonGlobals.TempLeftGuild[i][2] );
            end
        end

        -- Update the Add Event Window
        if #GRM_AddonGlobals.TempEventReport > 0 and GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame:IsVisible() then
            GRM.RefreshAddEventFrame();
        end
        -- Clear the changes.
        GRM.ResetTempLogs();

        if GRM_AddonGlobals.OnFirstLoad and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][2] then
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][28] and GRM_AddonGlobals.ChangesFoundOnLoad then
                GRM_UI.GRM_RosterChangeLogFrame:Show();
            end
        end
        -- Let's update the frames!
        if needToReport and GRM_UI.GRM_RosterChangeLogFrame ~= nil and GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then
            GRM.BuildLog();
        end

        if GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
            GRM.PopulateMemberDetails ( GRM_AddonGlobals.currentName );
        end
        
        GRM_AddonGlobals.OnFirstLoad = false;
        GRM_AddonGlobals.changeHappenedExitScan = false;
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
                    GRM_AddonGlobals.PlayerFromGuildLog = p1;
                    GRM_AddonGlobals.GuildLogDate = { year , month , day , hour };
                    break;
                elseif index == 2 and eventType [ 2 ] == type and p2 ~= nil and ( p2 == playerName or p2 == GRM.SlimName ( playerName ) ) then
                    p1 = GRM.GetStringClassColorByName ( p1 ) .. GRM.SlimName ( p1 ) .. "|r";
                    p2 = GRM.GetStringClassColorByName ( p2 ) .. GRM.SlimName ( p2 ) .. "|r";
                    result = GRM.L ( "{name} PROMOTED {name2} from {custom1} to {custom2}" , p1 , p2 , nil , initRank , FinRank );
                    GRM_AddonGlobals.PlayerFromGuildLog = p1;
                    GRM_AddonGlobals.GuildLogDate = { year , month , day , hour };
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
                        GRM_AddonGlobals.PlayerFromGuildLog = p1;
                        GRM_AddonGlobals.GuildLogDate = { year , month , day , hour };
                        notFound = false;
                    elseif eventType [ 5 ] == type and ( p1 == playerName or p1 == GRM.SlimName ( playerName ) ) then
                        -- FOUND!
                        p1 = GRM.GetStringClassColorByName ( playerName ) .. GRM.SlimName ( playerName ) .. "|r";
                        result = ( GRM.L ( "{name} has Left the guild" , p1 ) );
                        GRM_AddonGlobals.GuildLogDate = { year , month , day , hour };
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
                GRM_AddonGlobals.PlayerFromGuildLog = p1;
                GRM_AddonGlobals.GuildLogDate = { year , month , day , hour };
                result = GRM.L ( "{name} INVITED {name2} to the guild." , p1 , p2 );
                break;
            end
        end
    end
    return result;
end

-- Method:          GRM.RecordKickChanges ( string , string , string , boolean )
-- What it Does:    Records and logs the changes for when a guildie either is KICKED or leaves the guild
-- Purpose:         Having its own function saves on repeating a lot of code here.
GRM.RecordKickChanges = function ( unitName , simpleName , guildName , playerKicked )
    local timestamp = GRM.GetTimestamp();
    local timeEpoch = time();

    local tempGuildDatabase = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];
    local logReport = "";
    local tempStringRemove = "";
    local classColorCode = GRM.GetStringClassColorByName ( unitName );

    if not playerKicked then
        tempStringRemove = GRM.GetGuildEventString ( 3 , unitName ); -- Kicked from the guild.
        if tempStringRemove ~= nil and tempStringRemove ~= "" then
            local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_AddonGlobals.GuildLogDate );
            timestamp = tempData[1];
            timeEpoch = tempData[2];
            logReport = ( timestamp .. " : " .. tempStringRemove );
        else
            logReport = ( timestamp .. " : " ..  GRM.L ( "{name} has Left the guild" , classColorCode .. unitName .. "|CFF808080" ) );
        end
    else
        -- The player kicked them right now LIVE!
        logReport = ( timestamp .. " : " .. GRM.L ( "{name} KICKED {name2} from the Guild!" , GRM.GetStringClassColorByName ( GRM_AddonGlobals.addonPlayerName ) .. GRM.SlimName ( GRM_AddonGlobals.addonPlayerName ) .. "|r" , classColorCode .. unitName .. "|r" ) );
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
            table.insert ( GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID] , tempGuildDatabase[j] );
                    
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
                    for r = 1 , #GRM_AddonGlobals.TempLeftGuildPlaceholder do
                        if GRM_AddonGlobals.TempLeftGuildPlaceholder[r][1] == tempGuildDatabase[j][11][m][1] then
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
                            for t = 1 , #GRM_AddonGlobals.TempLeftGuildPlaceholder do
                                if GRM_AddonGlobals.TempLeftGuildPlaceholder[t][1] == tempGuildDatabase[j][11][s][1] then
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

                GRM.RemoveAlt ( tempGuildDatabase[j][11][1][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , guildName , false , 0 , false );
            end
            -- removing from active member library
            table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] , j );
            
            break;
        end
    end
    -- Update the live frames too!
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:IsVisible() then
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
    local year , month , day , hour;
    -- Use default dates, since these are auto-tagged, you don't want your data to overwrite any others, so set it as OLD...
    local tempTimeStamp = "1 Jan '01 12:01am";
    local timeEpoch = 978375660;

    local tempStringInv = GRM.GetGuildEventString ( 4 , memberInfo[1] ); -- For determining who did the invite.
    -- Pulling the exact join/rejoin date from the official in-game log.
    if tempStringInv ~= nil and tempStringInv ~= "" then
        local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_AddonGlobals.GuildLogDate );
        tempTimeStamp = tempData[1];
        timeEpoch = tempData[2];
    end
    local tempGuildData = GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][GRM_AddonGlobals.saveGID];
    
    for j = 2 , #tempGuildData do -- Number of players that have left the guild.
        if memberInfo[1] == tempGuildData[j][1] then
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
                local warning = ( timeStamp .. " : " .. GRM.L ( "WARNING!" ) .. "\n" .. GRM.L ( "{name} REJOINED the guild but was previously BANNED!" , simpleName ) );
                if tempStringInv ~= nil and tempStringInv ~= "" then
                    warning = warning  .. GRM.L ( "(Invited by: {name})" , GRM_AddonGlobals.PlayerFromGuildLog );
                end
                
                local information = { { "|CFF66B5E6" .. GRM.L ( "Date of Ban:" ) .. "|r" , tempGuildData[j][15][#tempGuildData[j][15]] .. " " .. GRM.L ( "({num} ago)" , nil , nil , GRM.GetTimePassed ( tempGuildData[j][16][#tempGuildData[j][16]] ) ) } , { "|CFF66B5E6" .. GRM.L ( "Date Originally Joined:" ) .. "|r" , tempGuildData[j][20][1] } , { "|CFF66B5E6" .. GRM.L ( "Old Guild Rank:" ) .. "|r" , tempGuildData[j][19] } , { "|CFF66B5E6" .. GRM.L ( "Reason:" ) .. "|r" , reasonBanned } };
                -- Add an extra piece of info
                if tempGuildData[j][23] ~= "" then
                    table.insert ( information , { "|CFF66B5E6" .. GRM.L ( "Additional Notes:" ) .. "|r" , tempGuildData[j][23] } )
                end
                -- Add to the log, alligned
                table.insert ( GRM_AddonGlobals.TempBannedRejoin , { 9 , warning , false , 12 , numTimesString .. GRM.AllignTwoColumns ( information , 20 ) } );
            else
                -- No Ban found, player just returning!
                if tempStringInv ~= nil and tempStringInv ~= "" then
                    logReport = ( timeStamp .. " : " .. GRM.L ( "{name} has REINVITED {name2} to the guild" , GRM_AddonGlobals.PlayerFromGuildLog , simpleName ) .. " " .. GRM.L ( "(LVL: {num})" , nil , nil , memberInfo[4] ) );
                else
                    logReport = ( timeStamp .. " : " .. GRM.L ( "{name} has REJOINED the guild" , simpleName ) .. " " .. GRM.L ( "(LVL: {num})" , nil , nil , memberInfo[4] ) );
                end

                local information = { { "|CFF66B5E6" .. GRM.L ( "Date Left:" ) .. "|r" , tempGuildData[j][15][#tempGuildData[j][15]] .. " " .. GRM.L ( "({num} ago)" , nil , nil , GRM.GetTimePassed ( tempGuildData[j][16][#tempGuildData[j][16]] ) ) } , { "|CFF66B5E6" .. GRM.L ( "Date Originally Joined:" ) .. "|r" , tempGuildData[j][20][1] } , { "|CFF66B5E6" .. GRM.L ( "Old Guild Rank:" ) .. "|r" , tempGuildData[j][19] } };
                -- Add an extra piece of info
                if tempGuildData[j][23] ~= "" then
                    table.insert ( information , { "|CFF66B5E6" .. GRM.L ( "Additional Notes:" ) .. "|r" , tempGuildData[j][23] } )
                end

                local toReport = { 7 , logReport , false , 12 , numTimesString .. GRM.AllignTwoColumns ( information , 20 ) };

                table.insert ( GRM_AddonGlobals.TempRejoin , toReport );
            end
            rejoin = true;
            -- AddPlayerTo MemberHistory

            -- Adding timestamp to new Player.
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] and ( CanEditOfficerNote() or CanEditPublicNote() ) then
                for h = 1 , GRM.GetNumGuildies() do
                    local name ,_,_,_,_,_, note , oNote = GetGuildRosterInfo( h );
                    if name == memberInfo[1] then
                        local t;
                        if tempStringInv == nil or tempStringInv == "" then
                            t = GRM.Trim ( string.sub ( GRM.GetTimestamp() , 1 , 10 ) );
                        else
                            t = string.sub ( tempTimeStamp , 1 , string.find ( tempTimeStamp , "'" ) + 2 );
                        end
                        day = string.sub ( t , 1 , string.find ( t , " " ) -1 );
                        month = string.sub ( t , string.find ( t , " " ) + 1 , string.find ( t , " " ) + 3 );
                        year = string.sub ( t , string.find ( t , "'" ) + 1 );
                        local noteToSet = ( GRM.L ( "Rejoined:" ) .. " " .. day .. " " .. GRM.L ( month ) .. " '" .. year );
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] and CanEditOfficerNote() and ( oNote == "" or oNote == nil ) then
                            GuildRosterSetOfficerNote( h , noteToSet );
                        elseif not GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] and CanEditPublicNote() and ( note == "" or note == nil ) then
                            GuildRosterSetPublicNote ( h , noteToSet );
                        end
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
        local t;
        local timeStamp;
        if tempTimeStamp ~= "1 Jan '01 12:01am" then
            timeStamp = tempTimeStamp;
        else
            timeStamp = GRM.GetTimestamp();
        end
        logReport = ( timeStamp .. " : " .. GRM.L ( "{name} has JOINED the guild!" , simpleName ) .. " " .. GRM.L ( "(LVL: {num})" , nil , nil , memberInfo[4] ) );
        if tempStringInv == nil or tempStringInv == "" then
            t = GRM.Trim ( string.sub ( GRM.GetTimestamp() , 1 , 10 ) );
        else
            logReport = logReport .. " - " .. GRM.L ( "Invited By: {name}" , GRM_AddonGlobals.PlayerFromGuildLog );
            t = string.sub ( tempTimeStamp , 1 , string.find ( tempTimeStamp , "'" ) + 2 );
        end
        day = string.sub ( t , 1 , string.find ( t , " " ) -1 );
        month = string.sub ( t , string.find ( t , " " ) + 1 , string.find ( t , " " ) + 3 );
        year = string.sub ( t , string.find ( t , "'" ) + 1 );       
        local finalTStamp = ( GRM.L ( "Joined:" ) .. " " .. day .. " " .. GRM.L ( month ) .. " '" .. year );
        
        -- Adding timestamp to new Player.
        local currentOfficerNote = memberInfo[6];
        local currentPublicNote = memberInfo[5];
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] and ( CanEditOfficerNote() or CanEditPublicNote() ) then
            for s = 1 , GRM.GetNumGuildies() do
                local name ,_,_,_,_,_, note , oNote = GetGuildRosterInfo ( s );
                if name == memberInfo[1] then
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] and CanEditOfficerNote() and ( oNote == "" or oNote == nil ) then
                        GuildRosterSetOfficerNote( s , finalTStamp );
                    elseif not GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] and CanEditPublicNote() and ( note == "" or note == nil ) then
                        GuildRosterSetPublicNote ( s , finalTStamp );
                    end
                    break;
                end
            end
        end
        -- Do extra query
        GuildRoster();

        -- Adding to global saved array, adding to report 
        GRM.AddMemberRecord ( memberInfo , false , nil , guildName );
        table.insert ( GRM_AddonGlobals.TempNewMember , { 8 , logReport , false } );
        
        local tempGuildData = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];
        -- adding join date to history and rank date.
        for j = 2 , #tempGuildData do                     -- Number of players that have left the guild.
            if memberInfo[1] == tempGuildData[j][1] then
                -- Add the tempTimeStamp to officer note... this avoids report spam

                -- Promo Date stamp
                tempGuildData[j][12] = string.sub ( tempTimeStamp , 1 , string.find ( tempTimeStamp , "'" ) + 2 );  -- Date of Last Promotion - cuts of the date...
                tempGuildData[j][13] = timeEpoch;                                                                   -- Date of Last Promotion Epoch time.
                -- Join Date stamp
                -- No need to check size of table, it will be the first index as the player data was just added.
                table.insert ( tempGuildData[j][20] , tempTimeStamp );
                table.insert ( tempGuildData[j][21] , timeEpoch );
                -- For Event tracking!
                tempGuildData[j][22][1][2] = tempTimeStamp;

                if currentOfficerNote == nil or currentOfficerNote == "" then
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] and ( CanEditOfficerNote() or CanEditPublicNote() ) then
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] and CanEditOfficerNote() and ( tempGuildData[j][8] == "" or tempGuildData[j][8] == nil ) then
                            tempGuildData[j][8] = finalTStamp;
                        elseif not GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] and CanEditPublicNote() and ( tempGuildData[j][7] == "" or tempGuildData[j][7] == nil ) then
                            tempGuildData[j][7] = finalTStamp;
                        end
                    end
                    -- For SYNC
                    -- Join Date
                    tempGuildData[j][35][1] = tempTimeStamp;
                    tempGuildData[j][35][2] = timeEpoch;
                    -- Promo Date
                    tempGuildData[j][36][1] = tempTimeStamp;
                    tempGuildData[j][36][2] = timeEpoch;

                elseif currentOfficerNote ~= nil and currentOfficerNote ~= "" then
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] and ( CanEditOfficerNote() or CanEditPublicNote() ) then
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] and CanEditOfficerNote() and ( tempGuildData[j][8] == "" or tempGuildData[j][8] == nil ) then
                            tempGuildData[j][8] = currentOfficerNote;
                        elseif not GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] and CanEditPublicNote() and ( tempGuildData[j][7] == "" or tempGuildData[j][7] == nil ) then
                            tempGuildData[j][7] = currentPublicNote;
                        end
                    end
                    -- For SYNC
                    -- Join Date
                    tempGuildData[j][35][1] = tempTimeStamp;
                    tempGuildData[j][35][2] = timeEpoch;
                    -- Promo Date
                    tempGuildData[j][36][1] = tempTimeStamp;
                    tempGuildData[j][36][2] = timeEpoch;
                end
                break;
            end
        end
        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] = tempGuildData;
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
            local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_AddonGlobals.GuildLogDate );
            logReport = ( tempData[1] .. " : " .. tempString );
        else
            logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name} has been PROMOTED from {custom1} to {custom2}" , simpleName , nil , nil , memberOldInfo[4] , memberInfo[2] ) );
        end
        table.insert ( GRM_AddonGlobals.TempLogPromotion , { 1 , logReport , false } );
    -- 9 = Guild Rank Demotion
    elseif indexOfInfo == 9 then
        local tempString = GRM.GetGuildEventString ( 1 , memberInfo[1] , memberOldInfo[4] , memberInfo[2] );
        if tempString ~= nil and tempString ~= "" then
            local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_AddonGlobals.GuildLogDate );
            logReport = ( tempData[1] .. " : " .. tempString );
        else
            logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name} has been DEMOTED from {custom1} to {custom2}" , simpleName , nil , nil , memberOldInfo[4] , memberInfo[2] ) );
        end
        table.insert ( GRM_AddonGlobals.TempLogDemotion , { 2 , logReport , false } );
    -- 4 = level
    elseif indexOfInfo == 4 then
        local numGained = memberInfo[4] - memberOldInfo[6];
        logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name} has Leveled to {num}" , simpleName , nil , memberInfo[4] ) .. " " );
        if numGained > 1 then
            logReport = logReport .. GRM.L ( "(+{num} levels)" , nil , nil , numGained );
        else
            logReport = logReport .. GRM.L ( "(+{num} level)" , nil , nil , numGained );
        end
        table.insert ( GRM_AddonGlobals.TempLogLeveled , { 3 , logReport , false } );
    -- 5 = note
    elseif indexOfInfo == 5 then
        if memberOldInfo[7] == "" then
            logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name}'s PUBLIC Note: \"{custom1}\" was Added" , simpleName , nil , nil , memberInfo[5] ) );
        elseif memberInfo[5] == "" then
            logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name}'s PUBLIC Note: \"{custom1}\" was Removed" , simpleName , nil , nil , memberOldInfo[7] ) );
        else
            logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name}'s PUBLIC Note: \"{custom1}\" to \"{custom2}\"" , simpleName , nil , nil , memberOldInfo[7] , memberInfo[5] ) );
        end
        table.insert ( GRM_AddonGlobals.TempLogNote , { 4 , logReport , false } );
    -- 6 = officerNote
    elseif indexOfInfo == 6 then
        if memberOldInfo[8] == "" then
            logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name}'s OFFICER Note: \"{custom1}\" was Added" , simpleName , nil , nil , memberInfo[6] ) );
        elseif memberInfo[6] == "" or memberInfo[6] == nil then
            logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name}'s OFFICER Note: \"{custom1}\" was Removed" , simpleName , nil , nil , memberOldInfo[8] ) );
        else
            logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name}'s OFFICER Note: \"{custom1}\" to \"{custom2}\"" , simpleName , nil , nil , memberOldInfo[8] , memberInfo[6] ) );
        end
        table.insert ( GRM_AddonGlobals.TempLogONote , { 5 , logReport , false } );
    -- 8 = Guild Rank Name Changed to something else
    elseif indexOfInfo == 8 then
        logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "Guild Rank Renamed from {custom1} to {custom2}" , nil , nil , nil , memberOldInfo[4] , memberInfo[2] ) );
        table.insert ( GRM_AddonGlobals.TempRankRename , { 6 , logReport , false } );
    -- 10 = New Player
    elseif indexOfInfo == 10 then
        -- Check against old member list first to see if returning player!
        GRM.RecordJoinChanges ( memberInfo , simpleName );
    -- 11 = Player Left  
    elseif indexOfInfo == 11 then
        table.insert ( GRM_AddonGlobals.TempLeftGuildPlaceholder , { memberInfo[1] , simpleName , guildName , false } );
    -- 12 = NameChanged
    elseif indexOfInfo == 12 then
        local classColorString = GRM.GetStringClassColorByName ( memberOldInfo[1] );
        logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name} has Name-Changed to {name2}" , classColorString .. memberOldInfo[1] .. "|r" , classColorString .. simpleName .. "|r" ) );
        table.insert ( GRM_AddonGlobals.TempNameChanged , { 11 , logReport , false } );
    -- 13 = Inactive Members Return!
    elseif indexOfInfo == 13 then
        logReport = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name} has Come ONLINE after being INACTIVE for {num}" , simpleName , nil , GRM.HoursReport ( memberOldInfo ) ) );
        table.insert( GRM_AddonGlobals.TempInactiveReturnedLog , { 14 , logReport , false } );
    end
end

-- Method:          GRM.CheckPlayerChanges ( array , string , boolean )
-- What it Does:    Scans through guild roster and re-checks for any  (Will only fire if guild is found!)
-- Purpose:         Keep whoever uses the addon in the know instantly of what is going and changing in the guild.
GRM.CheckPlayerChanges = function ( metaData , guildName , guildNotFound )
    if GRM_AddonGlobals.changeHappenedExitScan or GRM_AddonGlobals.saveGID == 0 then    -- This provides an escape if the player quits the guild in the middle of the scan process, or on first joining, to avoid lua error then
        GRM.ResetTempLogs();
        GRM_AddonGlobals.changeHappenedExitScan = false;
        return;
    end
    local newPlayerFound;
    local guildRankIndexIfChanged = -1; -- Rank index must start below zero, as zero is Guild Leader.

    local tempRosterCopy = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];

    for j = GRM_AddonGlobals.ThrottleControlNum , #metaData do
        newPlayerFound = true;
        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do -- Number of members in guild (Position 1 = guild name, so we skip)
            if metaData[j][1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] then
                newPlayerFound = false;
                -- Only scan for changes here based on player scan timer settings.
                if ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][18] or GRM_AddonGlobals.ManualScanEnabled ) and ( time() - GRM_AddonGlobals.ScanRosterTimer > GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][6] ) then
                    for k = 2 , 8 do
                        
                        if k ~= 3 and k < 7 and metaData[j][k] ~= GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][k + 2] then -- CHANGE FOUND! New info and old info are not equal!
                            -- Ranks
                            if k == 2 and metaData[j][3] ~= GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] and metaData[j][2] ~= GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] then -- This checks to see if guild just changed the name of a rank.
                                local tempString = "";
                                local timestamp = GRM.GetTimestamp();
                                local epochTime = time();
                                local isFoundInLog = false;
                                -- Promotion Obtained                                
                                if metaData[j][3] < GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] then
                                    tempString = GRM.GetGuildEventString ( 2 , metaData[j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] , metaData[j][2] );
                                    if tempString ~= nil and tempString ~= "" then
                                        local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_AddonGlobals.GuildLogDate );
                                        timestamp = tempData[1];
                                        epochTime = tempData[2];
                                        isFoundInLog = true;
                                    end
                                    GRM.RecordChanges ( k , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                                -- Demotion Obtained
                                elseif metaData[j][3] > GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] then
                                    tempString = GRM.GetGuildEventString ( 1 ,  metaData[j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] , metaData[j][2] );
                                    if tempString ~= nil and tempString ~= "" then
                                        local tempData = GRM.GetTimestampBasedOnTimePassed ( GRM_AddonGlobals.GuildLogDate );
                                        timestamp = tempData[1];
                                        epochTime = tempData[2];
                                        isFoundInLog = true;
                                    end
                                    GRM.RecordChanges ( 9 , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                                end
                                
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] = metaData[j][2]; -- Saving new rank Info
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5] = metaData[j][3]; -- Saving new rank Index Info
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] = string.sub ( timestamp , 1 , string.find ( timestamp , "'" ) + 2 ); -- Time stamping rank change
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13] = epochTime;

                                -- For SYNC
                                if not isFoundInLog then
                                    -- Use old stamps so as not to override other player data...
                                    timestamp = "1 Jan '01 12:01am";
                                    epochTime = 978375660;
                                end
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][1] = string.sub ( timestamp , 1 , string.find ( timestamp , "'" ) + 2 );
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][2] = epochTime;

                                table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25] , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13] } ); -- New rank, date, metatimestamp
                                
                                -- Update the player index if it is the player themselves that received the change in rank.
                                if metaData[j][1] == GRM_AddonGlobals.addonPlayerName then
                                    GRM_AddonGlobals.playerIndex = metaData[j][3];

                                    -- Let's do a resync check as well... If permissions have changed, we should resync check em.
                                    -- First, RESET all..
                                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and not GRMsyncGlobals.currentlySyncing and GRM_AddonGlobals.HasAccessToGuildChat and not GRM_AddonGlobals.OnFirstLoad then
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
                                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][23] <= metaData[j][4] then
                                    GRM.RecordChanges ( k , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                                end
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][6] = metaData[j][4]; -- Saving new Info
                            -- Note
                            elseif k == 5 then
                                GRM.RecordChanges ( k , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][7] = metaData[j][5];
                                -- Update metaframe
                                if GRM_UI.GRM_MemberDetailMetaData ~= nil and GRM_UI.GRM_MemberDetailMetaData:IsVisible() and GRM_AddonGlobals.currentName == metaData[j][1] then
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
                                if metaData[j][k] == nil or GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8] == nil then
                                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8] = metaData[j][6];
                                else
                                    GRM.RecordChanges ( k , metaData[j] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r] , guildName );
                                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8] = metaData[j][6];
                                end
                                if GRM_UI.GRM_MemberDetailMetaData ~= nil and GRM_UI.GRM_MemberDetailMetaData:IsVisible() and GRM_AddonGlobals.currentName == metaData[j][1] then
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
                                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][11] and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][24] > GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][4] and metaData[j][8] < GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][4] and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][24] > metaData[j][8] then  -- Player has logged in after having been inactive for greater than given time
                                    GRM.RecordChanges ( 13 , metaData[j][1] , ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][24] - metaData[j][8] ) , guildName );   -- Recording the change in hours to log
                                end
                
                                -- Recommend to kick offline if player has the power to!
                                if CanGuildRemove() then
                                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][10] and not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][27] and ( 30 * 24 * GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][9] ) <= metaData[j][8] then
                                        -- Player has been offline for longer than the given time... REPORT RECOMMENDATION TO KICK!!!
                                        table.insert ( GRM_AddonGlobals.TempEventRecommendKickReport , { 16 , ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name} has been OFFLINE for {num}. Kick Recommended!" , GRM.GetStringClassColorByName ( metaData[j][1] ) .. GRM.SlimName ( metaData[j][1] ) .. "|r" , nil , GRM.HoursReport ( metaData[j][8] ) ) ) , false } );
                                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][27] = true;    -- No need to report more than once.
                                    elseif GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][27] and ( 30 * 24 * GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][9] ) > metaData[j][8]  then
                                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][27] = false;
                                    end
                                end
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][24] = metaData[j][8];                   -- Set new hours since last login.
                            end
                        end
                    end
                end

                -- Just straight update these everytime... No need for change check
                if ( metaData[j][13] and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= metaData[j][9] ) or GRM_AddonGlobals.OnFirstLoad then     
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] = time();   -- Resetting the time on hitting this zone.
                end
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] = metaData[j][9];    -- zone
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][29] = metaData[j][10];   -- Achievement pts
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][30] = metaData[j][11];   -- isMobile
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][31] = metaData[j][12];   -- Guild Reputation
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] = metaData[j][13];   -- online Status
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][34] = metaData[j][14];   -- Active Status
                break;
            end
        end
        -- NEW PLAYER FOUND! (Maybe)
        if newPlayerFound then
            table.insert ( GRM_AddonGlobals.newPlayers , metaData[j] );
        end

        -- Throttle Controls on the scan!!!
        if not GRM_AddonGlobals.OnFirstLoad then
            if j % 250 == 0 then
                GRM_AddonGlobals.ThrottleControlNum = j + 1;
                C_Timer.After ( 1 , function() 
                    GRM.CheckPlayerChanges ( metaData , guildName , guildNotFound );
                end);
                return
            end
        end
    end
    -- Checking if any players left the guild
    C_Timer.After ( 1 , function()
        if GRM_AddonGlobals.changeHappenedExitScan then
            GRM.ResetTempLogs();
            GRM_AddonGlobals.changeHappenedExitScan = false;
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
                table.insert ( GRM_AddonGlobals.leavingPlayers , tempRosterCopy[j] );
            end
        end
        -- Spread out the scans to avoid stutter...
        C_Timer.After ( 2 , function()
            if GRM_AddonGlobals.changeHappenedExitScan then
                GRM.ResetTempLogs();
                GRM_AddonGlobals.changeHappenedExitScan = false;
                return;
            end
            -- Final check on players that left the guild to see if they are namechanges.CanViewOfficerNote
            local playerNotMatched = true;
            local numMatches = {};
            if #GRM_AddonGlobals.leavingPlayers > 0 and #GRM_AddonGlobals.newPlayers > 0 then
                for k = 1 , #GRM_AddonGlobals.leavingPlayers do
                    numMatches = {};            -- Need to reset for next player
                    playerNotMatched = false;
                    for j = 1 , #GRM_AddonGlobals.newPlayers do
                    if ( GRM_AddonGlobals.leavingPlayers[k] ~= nil and GRM_AddonGlobals.newPlayers[j] ~= nil ) and GRM_AddonGlobals.leavingPlayers[k][9] == GRM_AddonGlobals.newPlayers[j][7]    -- Class is the sane
                            and GRM_AddonGlobals.leavingPlayers[k][5] == GRM_AddonGlobals.newPlayers[j][3]                                                        -- Guild Rank is the same
                                and GRM_AddonGlobals.leavingPlayers[k][31] == GRM_AddonGlobals.newPlayers[j][12]                                                  -- Guild Rep Rank is the same
                                    and GRM_AddonGlobals.leavingPlayers[k][7] == GRM_AddonGlobals.newPlayers[j][5]                                                -- Player note is the same
                                        and ( GRM_AddonGlobals.newPlayers[j][10] >= GRM_AddonGlobals.leavingPlayers[k][29] - 50 and GRM_AddonGlobals.newPlayers[j][10] <= GRM_AddonGlobals.leavingPlayers[k][29] + 100 ) then -- In other words, sometimes patches can remove achievements, so gives negative cushion, but assumes they didn't gain 100 + pts since last you noticed
                            -- Match Found!!!
                            table.insert ( numMatches , GRM_AddonGlobals.newPlayers[j] );
                        end
                    end

                    if #numMatches >= 1 then
                        -- PLAYER IS A NAMECHANGE!!!
                        if #numMatches > 1 then
                            -- More than 1 namechange match!!! This is tricky, so we will let the player know
                            local classColorString = GRM.GetStringClassColorByName ( GRM_AddonGlobals.leavingPlayers[k][1] );
                            local result =  GRM.L ( "{name } Seems to Have Name-Changed, but their New Name was Hard to Determine" , classColorString .. GRM.SlimName ( GRM_AddonGlobals.leavingPlayers[k][1] ) .."|r" ) .. "\n" .. GRM.L ( "It Could Be One of the Following:" ) .. " " .. classColorString .. GRM.SlimName ( numMatches[1][1] ) .. "|r";

                            for m = 2 , #numMatches do
                                result = result .. GRM.L ( "," ) .. " " .. classColorString .. GRM.SlimName ( numMatches[m][1] ) .. "|r";
                            end
                            -- Report it to chat...
                            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][8] then
                                chat:AddMessage( result, 0.9 , 0.82 , 0.62 );
                            end
                            -- Insert it into the log.
                            table.insert ( GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] , { 11 , result } );

                        else
                            playerNotMatched = false;
                            GRM.RecordChanges ( 12 , numMatches[1] , GRM_AddonGlobals.leavingPlayers[k] , guildName );
                            for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                                if GRM_AddonGlobals.leavingPlayers[k][9] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][9] -- Mathching the Leaving player to historical index so it can be identified and new name stored.
                                    and GRM_AddonGlobals.leavingPlayers[k][5] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5]
                                        and GRM_AddonGlobals.leavingPlayers[k][29] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][29] then

                                    -- Need to remove him from list of alts IF he has a lot of alts...
                                    if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][11] > 0 then
                                        local tempNameToReAddAltTo = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][11][1][1];
                                        GRM.RemoveAlt ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][11][1][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] , guildName , false , 0 , false );
                                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] = numMatches[1][1]; -- Changing the name...
                                        -- Now, let's re-add him back.
                                        GRM.AddAlt ( tempNameToReAddAltTo , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] , guildName , false , 0 );
                                    else
                                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] = numMatches[1][1]; -- Changing the name!
                                    end

                                    break
                                end
                            end
                            -- since namechange identified, also need to remove name from GRM_AddonGlobals.newPlayers array now.
                            if #GRM_AddonGlobals.newPlayers == 1 then
                                GRM_AddonGlobals.newPlayers = {}; -- Clears the array of the one name.
                            else
                                local tempArray = {};
                                local count = 1;
                                for r = 1 , #GRM_AddonGlobals.newPlayers do -- removing the namechange from GRM_AddonGlobals.newPlayers list.
                                    if r ~= j then  -- j = the position of the nameChanged player, so I am SKIPPING the nameChange player when adding to new array.
                                        tempArray[count] = {};
                                        tempArray[count] = GRM_AddonGlobals.newPlayers[r];
                                        count = count + 1;
                                    end
                                end
                                GRM_AddonGlobals.newPlayers = {};
                                GRM_AddonGlobals.newPlayers = tempArray;
                            end
                        end
                    end

                    -- Player not matched! For sure this player has left the guild!
                    if playerNotMatched then
                        GRM.RecordChanges ( 11 , GRM_AddonGlobals.leavingPlayers[k] , GRM_AddonGlobals.leavingPlayers[k] , guildName );
                    end
                end
            elseif #GRM_AddonGlobals.leavingPlayers > 0 then
                for k = 1 , #GRM_AddonGlobals.leavingPlayers do
                    GRM.RecordChanges ( 11 , GRM_AddonGlobals.leavingPlayers[k] , GRM_AddonGlobals.leavingPlayers[k] , guildName );
                end
            end
            if #GRM_AddonGlobals.newPlayers > 0 then
                for k = 1 , #GRM_AddonGlobals.newPlayers do
                    GRM.RecordChanges ( 10 , GRM_AddonGlobals.newPlayers[k] , GRM_AddonGlobals.newPlayers[k] , guildName );
                end
            end

            -- Now that we have collected all the players to be kicked... Let's not spam the log with alt info by parsing it properly.
            if #GRM_AddonGlobals.TempLeftGuildPlaceholder > 0 then
                for k = 1 , #GRM_AddonGlobals.TempLeftGuildPlaceholder do
                    table.insert ( GRM_AddonGlobals.TempLeftGuild , { 10 , GRM.RecordKickChanges ( GRM_AddonGlobals.TempLeftGuildPlaceholder[k][1] , GRM_AddonGlobals.TempLeftGuildPlaceholder[k][2] , GRM_AddonGlobals.TempLeftGuildPlaceholder[k][3] , GRM_AddonGlobals.TempLeftGuildPlaceholder[k][4] ) , false } );
                end
            end

            -- OK, let's close this out!!!!!
            C_Timer.After ( 1 , function()
                if not guildNotFound then
                    if ( time() - GRM_AddonGlobals.ScanRosterTimer - 4 > GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][6] ) then
                        -- Seeing if any upcoming notable events, like anniversaries/birthdays
                        GRM.CheckPlayerEvents( GRM_AddonGlobals.guildName );
                        -- Do a quick check on if players requesting to join the guild as well!
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][27] then
                            GRM.ReportGuildJoinApplicants();
                        end

                        GRM_AddonGlobals.ScanRosterTimer = time();          -- Setting the time since the last scan finished.
                    end
                    -- Printing Report, and sending report to log.
                    GRM.FinalReport();

                    -- Disable manual scan if activated.
                    if GRM_AddonGlobals.ManualScanEnabled then
                        GRM_AddonGlobals.ManualScanEnabled = false;
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
        if GRM_AddonGlobals.guildName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][i][1] then
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
        roster[i][8] = GRM.GetHoursSinceLastOnline ( i , online ); -- Time since they last logged in in hours.
        roster[i][9] = zone;
        roster[i][10] = achievementPoints;
        roster[i][11] = isMobile;
        roster[i][12] = rep;
        roster[i][13] = online;
        roster[i][14] = status;
    end

        -- Build Roster for the first time if guild not found.
    if #roster > 0 and GRM_AddonGlobals.guildName ~= nil and GRM_AddonGlobals.guildName ~= "" then
        if guildNotFound  then
            -- See if it is a Guild NameChange first!
            if GRM.GuildNameChanged ( GRM_AddonGlobals.guildName ) then
                local logEntry = "\n" .. GRM.L ( "{name}'s Guild has Name-Changed to \"{name2}\"" , GRM.GetStringClassColorByName( GRM_AddonGlobals.addonPlayerName ) .. GRM.SlimName( GRM_AddonGlobals.addonPlayerName ) .. "|r" , GRM_AddonGlobals.guildName );
                GRM.PrintLog ( 15 , logEntry , false );   
                GRM.AddLog ( 15 , logEntry ); 
                -- ADD NEW GUILD VALUES
            else
                GRM.Report ( "\n" .. GRM.L ( "Guild Roster Manager" ) .. "\n" .. GRM.L ( "Analyzing guild for the first time..." ) .. "\n" .. GRM.L ( "Building Profiles on ALL \"{name}\" members" , GRM_AddonGlobals.guildName ) .. "\n" );
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
                table.insert ( GRM_GuildNotePad_Save[ GRM_AddonGlobals.FID ] , { GRM_AddonGlobals.guildName } );                                   -- Notepad, let's create an index as well!

                -- Make sure guild is not already added.
                local guildIsFound = false;
                for i = 2 , #GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ] do
                    if GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ][i][2] == GRM_AddonGlobals.guildName  then
                        guildIsFound = true;
                        break;
                    end
                end
                if not guildIsFound then
                    table.insert ( GRM_PlayerListOfAlts_Save[ GRM_AddonGlobals.FID ] , { GRM_AddonGlobals.guildName } );                          -- Adding index for the guild!
                end
                
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
            -- Do a notification check real fast...
            GRM.NotificationCheck ( roster );

            if not GRM_AddonGlobals.OnFirstLoad then
                C_Timer.After ( 2 , function()
                    GRM_AddonGlobals.ThrottleControlNum = 1;
                    -- new member and leaving members arrays to check at the end - need to reset it here.
                    GRM_AddonGlobals.newPlayers = {};
                    GRM_AddonGlobals.leavingPlayers = {};
                    GRM.CheckPlayerChanges ( roster , GRM_AddonGlobals.guildName , guildNotFound );
                end);
            else
                GRM_AddonGlobals.ThrottleControlNum = 1;
                -- new member and leaving members arrays to check at the end - need to reset it here.
                GRM_AddonGlobals.newPlayers = {};
                GRM_AddonGlobals.leavingPlayers = {};
                GRM.CheckPlayerChanges ( roster , GRM_AddonGlobals.guildName , guildNotFound );
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
    for i = 1 , #GRM_AddonGlobals.ActiveStatusQue do
        for j = 1 , #metaData do
            if metaData[j][1] == GRM_AddonGlobals.ActiveStatusQue[i][1] then
                if GRM_AddonGlobals.ActiveStatusQue[i][3] == 2 or GRM_AddonGlobals.ActiveStatusQue[i][3] == 3 then
                    if GRM_AddonGlobals.ActiveStatusQue[i][2] ~= metaData[j][13] then
                        if metaData[j][13] then
                            chat:AddMessage ( "\n|cffff0000" .. GRM.L ( "NOTIFICATION:" ) .. "|r " .. GRM.L ( "{name} is now ONLINE!" , GRM.GetStringClassColorByName ( GRM_AddonGlobals.ActiveStatusQue[i][1] ) .. GRM.SlimName ( GRM_AddonGlobals.ActiveStatusQue[i][1] ) .. "|r" ) .. "\n" , 1 , 1 , 1 );
                        else
                            chat:AddMessage ( "\n|cffff0000" .. GRM.L ( "NOTIFICATION:" ) .. "|r " .. GRM.L ( "{name} is now OFFLINE!" , GRM.GetStringClassColorByName ( GRM_AddonGlobals.ActiveStatusQue[i][1] ) .. GRM.SlimName ( GRM_AddonGlobals.ActiveStatusQue[i][1] ) .. "|r" ) .. "\n" , 1 , 1 , 1 );
                        end
                        table.remove ( GRM_AddonGlobals.ActiveStatusQue , i );
                    end
                else
                    -- GRM_AddonGlobals.ActiveStatusQue[i][3] == 1; Meaning it is an AFK check
                    if metaData[j][14] == 0 then
                        if metaData[j][13] then
                            chat:AddMessage ( "\n|cffff0000" .. GRM.L ( "NOTIFICATION:" ) .. "|r " .. GRM.L ( "{name} is No Longer AFK or Busy!" , GRM.GetStringClassColorByName ( GRM_AddonGlobals.ActiveStatusQue[i][1] ) .. GRM.SlimName ( GRM_AddonGlobals.ActiveStatusQue[i][1] ) .. "|r" ) .. "\n" , 1 , 1 , 1 );
                        else
                            chat:AddMessage ( "\n|cffff0000" .. GRM.L ( "NOTIFICATION:" ) .. "|r " .. GRM.L ( "{name} is No Longer AFK or Busy, but they Went OFFLINE!" , GRM.GetStringClassColorByName ( GRM_AddonGlobals.ActiveStatusQue[i][1] ) .. GRM.SlimName ( GRM_AddonGlobals.ActiveStatusQue[i][1] ) .. "|r" )  .. "\n" , 1 , 1 , 1 );
                        end
                        table.remove ( GRM_AddonGlobals.ActiveStatusQue , i );
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
    local tempQue = GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID];
    local count = 2;

    while count <= #tempQue do
        if GRM.IsCalendarEventAlreadyAdded ( tempQue[count][2] , tempQue[count][5] , tempQue[count][3] , tempQue[count][4] ) then
            table.remove ( tempQue , count );
        else
            count = count + 1;
        end
    end
    GRM_CalendarAddQue_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] = tempQue;
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
                                eventDate = GRM.L ( "1 Mar" );
                            else
                                eventDate = string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][2] , 0 , string.find ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][22][r][2] , " " ) + 3 );
                            end
                            if numYears == 1 then
                                logReport = ( GRM.L ( "{name} will be celebrating {num} year in the Guild! ( {custom1} )" , GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] ) , nil , numYears , eventDate  ) );
                            else
                                logReport = ( GRM.L ( "{name} will be celebrating {num} years in the Guild! ( {custom1} )" , GRM.SlimName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] ) , nil , numYears , eventDate  ) );
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
--                  be linked to a button on the "GRM_UI.GRM_RosterChangeLogFrame.GRM_EventsFrame" window. Again, this cannot be activated, it WILL NOT WORK without 
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
    local scrollWidth = 561;
    local buffer = 7;

    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings or {};  -- Create a table for the Buttons.
    -- populating the window correctly.
    local count = 1;
    for i = 1 , #GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] do
        -- if font string is not created, do so.
        local trueString = false;
        
        -- Check buttons
        local index = GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID][#GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] - i + 1][1];
        if index == 1 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterPromotionChangeCheckButton:GetChecked() then      -- Promotion 
            trueString = true;
        elseif index == 2 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterDemotionChangeCheckButton:GetChecked() then  -- Demotion
            trueString = true;
        elseif index == 3 and GRM_UI.GRM_RosterChangeLogFrame.GRM_RosterLeveledChangeCheckButton:GetChecked() then  -- Leveled

            -- Need to parse out the level, then compare. Only show the string if they are matching level
            local levelEntry = GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID][#GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] - i + 1][2];
            local start, final;
            -- This is importance because it includes pre-localization efforts...
            if string.find ( levelEntry , GRM.L ( "Leveled to" ) ) ~= nil then
                start, final = string.find ( levelEntry , GRM.L ( "Leveled to" ) );
            elseif string.find ( levelEntry , GRM.L ( "Leveled to" ) ) ~= nil then
                start , final = string.find ( levelEntry , GRM.L ( "Leveled to" ) );
            end
            local level = 0;
            local count = 0;
            -- ENSURE LOCALIZATION IS COMPATIBLE WITH THIS LOGIC!!!
            while tonumber ( string.sub ( levelEntry , final + 2 , final + 2 + count ) ) ~= nil do
                level = tonumber ( string.sub ( levelEntry , final + 2 , final + 2 + count ) );
                count = count + 1;
            end
            if level >= GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][23] then
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
        end

        if trueString then
            if not GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings[count] then
                GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings[count] = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame:CreateFontString ( "GRM_LogEntry_" .. count );
            end

            -- coloring
            local r , g , b = GRM.GetMessageRGB ( GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID][#GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] - i + 1][1] );
            local logFontString = GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings[count];
            logFontString:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame , 7 , -99 );
            logFontString:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 );   
            logFontString:SetJustifyH ( "LEFT" );
            logFontString:SetSpacing ( buffer );
            logFontString:SetTextColor ( r , g , b , 1.0 );
            logFontString:SetText ( GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID][#GRM_LogReport_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.logGID] - i + 1][2] );
            logFontString:SetWidth ( 555 );
            logFontString:SetWordWrap ( true );
            local stringHeight = logFontString:GetStringHeight();

            -- Now let's pin it!
            if count == 1 then
                logFontString:SetPoint( "TOPLEFT" , 0 , - 5 );
                scrollHeight = scrollHeight + stringHeight;
            else
                logFontString:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings[count - 1] , "BOTTOMLEFT" , 0 , - buffer );
                scrollHeight = scrollHeight + stringHeight + buffer;
            end
            count = count + 1;
            logFontString:Show();
        end
    end
            

    -- Hides all the additional buttons... if necessary
    for i = count , #GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings do
        GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollChildFrame.allFontStrings[i]:Hide();
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
    GRM_UI.GRM_RosterChangeLogFrame.GRM_LogFrame.GRM_RosterChangeLogScrollFrame:SetScript( "OnMouseWheel" , function( self , delta )
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
end


------------------------------------
---- BEGIN OF FRAME/UI LOGIC -------
---- General Framebuild Methods ----
------------------------------------


-- Method:          GRM.OnDropMenuClickDay()
-- What it Does:    Upon clicking any item in a drop down menu, this sets the ID of that item as defaulted choice
-- Purpose:         General use clicking logic for month based drop down menu.
GRM.OnDropMenuClickDay = function ()
    GRM_AddonGlobals.dayIndex = tonumber ( GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected.GRM_DayText:GetText() );
    GRM.InitializeDropDownDay();
end

-- Method:          GRM.OnDropMenuClickMonth()
-- What it Does:    Recalculates the logic of number days to show.
-- Purpose:         General use clicking logic for month based drop down menu.
GRM.OnDropMenuClickMonth = function ()
    GRM_AddonGlobals.monthIndex = monthsFullnameEnum [ GRM.OrigL ( GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:GetText() ) ];
    GRM.InitializeDropDownDay();
end

-- Method:          GRM.OnDropMenuClickYear()
-- What it Does:    Upon clicking any item in a drop down menu, this sets the ID of that item as defaulted choice
-- Purpose:         General use clicking logic for year based drop down menu.
GRM.OnDropMenuClickYear = function ()
    GRM_AddonGlobals.yearIndex = tonumber ( GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected.GRM_YearText:GetText() );
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
        DayButtonsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
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
        YearButtonsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
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
        MonthButtonsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 9 );
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

-- Method:          GRM.SetJoinDate ( self , string )
-- What it Does:    Sets the player's join date properly, be it the first time, a modified time, or an edit.
-- Purpose:         For so many uses! Anniversary tracking, for editing the date, and so on...
GRM.SetJoinDate = function ()
    local name = GRM_AddonGlobals.currentName;
    local dayJoined = tonumber ( GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected.GRM_DayText:GetText() );
    local yearJoined = tonumber ( GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected.GRM_YearText:GetText() );
    local IsLeapYearSelected = GRM.IsLeapYear ( yearJoined );
    local buttonText = GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButtonTxt:GetText();

    if GRM.IsValidSubmitDate ( dayJoined , monthsFullnameEnum [ GRM.OrigL ( GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:GetText() ) ] , yearJoined, IsLeapYearSelected ) then
        local rankButton = false;
        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == name then

                local joinDate = ( "Joined: " .. dayJoined .. " " .. string.sub ( GRM.OrigL ( GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:GetText() ) , 1 , 3 ) .. " '" ..  string.sub ( yearJoined , 3 ) );
                local finalTStamp = ( string.sub ( joinDate , 9 ) .. " 12:01am" );
                local finalEpochStamp = GRM.TimeStampToEpoch ( joinDate );
                -- For metadata tracking
                if buttonText == GRM.L ( "Edit Join Date" ) then
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

                -- If it was unKnown before
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][40] = false;

                -- For UI
                GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:SetText ( dayJoined .. " " .. GRM.L ( string.sub ( GRM.OrigL ( GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:GetText() ) , 1 , 3 ) ) .. " '" ..  string.sub ( yearJoined , 3 ) );
                
                -- Update timestamp to officer note.
                local noteDestination = "none";
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] and ( CanEditOfficerNote() or CanEditPublicNote() ) then
                    for h = 1 , GRM.GetNumGuildies() do
                        local guildieName ,_,_,_,_,_, note , oNote = GetGuildRosterInfo( h );
                        if name == guildieName then
                            local t = GRM.Trim ( string.sub ( finalTStamp , 1 , 10 ) );
                            local day = string.sub ( t , 1 , string.find ( t , " " ) -1 );
                            local month = string.sub ( t , string.find ( t , " " ) + 1 , string.find ( t , " " ) + 3 );
                            local year = string.sub ( t , string.find ( t , "'" ) + 1 );
                            local noteDate = ( GRM.L ( "Joined:" ) .. " " .. day .. " " .. GRM.L ( month ) .. " '" .. year );
                            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] and CanEditOfficerNote() and ( oNote == "" or oNote == nil ) then
                                noteDestination = "officer";
                                GuildRosterSetOfficerNote( h , noteDate );
                                GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:SetText ( noteDate );
                                GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:SetText ( noteDate );
                            elseif not GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] and CanEditPublicNote() and ( note == "" or note == nil ) then
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
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][22][1][2] = string.sub ( joinDate , 9 ); -- Remember, position 1 of the events tracker for anniversary tracking is always position 1 of the array, with date being pos 1 of table too.
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][22][1][3] = false;  -- Gotta Reset the "reported already" boolean!
                GRM.RemoveFromCalendarQue ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][22][1][1] );
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] == nil and not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][41] then
                    rankButton = true;
                end

                -- Need player index to get this info.
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= nil then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] );                                     -- Zone
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] ) );              -- Time Passed
                    end
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Show();
                end

                -- Let's send the changes out as well!
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_JD?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. name .. "?" .. joinDate .. "?" .. finalTStamp .. "?" .. finalEpochStamp .. "?" .. tostring ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][35][2] ) .. "?" .. noteDestination , "GUILD");
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
        GRM_AddonGlobals.pause = false;
        -- Update the Audit Frames!
        if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
            GRM.RefreshAuditFrames();
        end
    end
end

-- Method:          GRM.SyncJoinDatesOnAllAlts()
-- What it Does:    Tales the player name and makes ALL of their alts share the same timestamp on joining.
-- Purpose:         Ease for the addon user to be able to sync the join dates among all alts rather than have to manually do them 1 at a time.6
GRM.SyncJoinDatesOnAllAlts = function ( playerName )
    local roster = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];
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
                for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                    -- Alt is found!
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == roster[i][11][j][1] then

                        -- 
                        
                        -- Let's match the values now...
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20][ #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] ] ~= nil or #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] > 0 then
                            -- Removing old date
                            table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] );
                            table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][21] , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][21] );
                        end
                        -- Adding the new stamps
                        table.insert( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] , finalTStamp );      -- oldJoinDate
                        table.insert( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][21] , finalTStampEpoch ) ;    -- oldJoinDateMeta
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][2] = finalTStamp;
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][3] = finalTStampEpoch;

                        -- For sync timestamp checking...
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][35][1] = finalTStamp;
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][35][2] = syncEpochStamp;

                        -- If it was unKnown before
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][40] = false;

                        -- Let's set those officer/public notes as well!
                        local noteDestination = "none";
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] and ( CanEditOfficerNote() or CanEditPublicNote() ) then
                            for h = 1 , GRM.GetNumGuildies() do
                                local guildieName ,_,_,_,_,_, note , oNote = GetGuildRosterInfo( h );
                                if roster[i][11][j][1] == guildieName then
                                    local t = GRM.Trim ( string.sub ( finalTStamp , 1 , 10 ) );
                                    local day = string.sub ( t , 1 , string.find ( t , " " ) -1 );
                                    local month = string.sub ( t , string.find ( t , " " ) + 1 , string.find ( t , " " ) + 3 );
                                    local year = string.sub ( t , string.find ( t , "'" ) + 1 );
                                    local noteDate = ( GRM.L ( "Joined:" ) .. " " .. day .. " " .. GRM.L ( month ) .. " '" .. year );
                                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] and CanEditOfficerNote() and ( oNote == "" or oNote == nil ) then
                                        noteDestination = "officer";
                                        GuildRosterSetOfficerNote( h , noteDate );
                                    elseif not GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] and CanEditPublicNote() and ( note == "" or note == nil ) then
                                        noteDestination = "public";
                                        GuildRosterSetPublicNote ( h , noteDate );
                                    end                            
                                    break;
                                end
                            end
                        end

                        -- Gotta update the event tracker date too!
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][22][1][2] = joinDate; -- Remember, position 1 of the events tracker for anniversary tracking is always position 1 of the array, with date being pos 1 of table too.
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][22][1][3] = false;  -- Gotta Reset the "reported already" boolean!
                        -- Update the Calendar Que since anniversary dates might be changed as a result
                        GRM.RemoveFromCalendarQue ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][22][1][1] );

                        -- To Avoid the spam, we are going to treat this like a SYNC message
                        -- Let's send the changes out as well!
                        
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                            GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_JDSYNCUP?" .. GRM_AddonGlobals.addonPlayerName .. "?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. roster[i][11][j][1] .. "?" .. joinDate .. "?" .. finalTStamp .. "?" .. finalTStampEpoch .. "?" .. tostring ( syncEpochStamp ) .. "?" .. noteDestination , "GUILD");
                        end
                        break;

                    end
                end
            end
            break;        
        end
    end

    GRM_AddonGlobals.pause = false;
    -- Update the Audit Frames!
    if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
        GRM.RefreshAuditFrames();
    end

end

-- Method:          GRM.SyncJoinDateUsingEarliest()
-- What it Does:    Syncs the join date of the grouping of alts to all be the same as the alt with the earliest join date
-- Purpose:         For join date syncing and time-saving for the player
GRM.SyncJoinDateUsingEarliest = function()
    GRM.SyncJoinDatesOnAllAlts ( GRM.GetAltWithOldestJoinDate ( GRM_AddonGlobals.currentName )[1] );
end

-- Method:          GRM.SyncJoinDateUsingMain()
-- What it Does:    Syncs the join date of the grouping of alts to all be the same as the alt with the player's main
-- Purpose:         For join date syncing and time-saving for the player
GRM.SyncJoinDateUsingMain = function()
    GRM.SyncJoinDatesOnAllAlts ( GRM.GetPlayerMain ( GRM_AddonGlobals.currentName ) );
end

-- Method:          GRM.SyncJoinDateUsingMain()
-- What it Does:    Syncs the join date of the grouping of alts to all be the same as the alt with the currently selected player on the roster
-- Purpose:         For join date syncing and time-saving for the player
GRM.SyncJoinDateUsingCurrentSelected = function()
    GRM.SyncJoinDatesOnAllAlts ( GRM_AddonGlobals.currentName );
end

-- Method:          GRM.GetPlayerMain ( string )
-- What it Does:    Returns the full player of the toon's main, or himself if he is main, or nil if no main.
-- Purpose:         Useful lookup for many purposes...
GRM.GetPlayerMain = function ( playerName )
    local roster = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];
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
    local roster = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];
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
    local roster = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];
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
    local roster = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];
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
    local roster = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];
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
    local name = GRM_AddonGlobals.currentName;
    local dayJoined = tonumber ( GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected.GRM_DayText:GetText() );
    local yearJoined = tonumber ( GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected.GRM_YearText:GetText() );
    local IsLeapYearSelected = GRM.IsLeapYear ( yearJoined );

    if GRM.IsValidSubmitDate ( dayJoined , monthsFullnameEnum [ GRM.OrigL ( GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:GetText() ) ] , yearJoined, IsLeapYearSelected ) then

        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == name then
                local promotionDate = ( "Promoted: " .. dayJoined .. " " ..  string.sub ( GRM.OrigL ( GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:GetText() ) , 1 , 3 ) .. " '" ..  string.sub ( yearJoined , 3 ) );
                -- Promo Save Data
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] = string.sub ( promotionDate , 11 );
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25][#GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25]][2] = string.sub ( promotionDate , 11 );
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13] = GRM.TimeStampToEpoch ( promotionDate );
                
                -- For SYNC
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][1] = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12];
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][2] = time();
                
                -- If player had it set to "unknown before"
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][41] = false;
                
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:SetText ( GRM.L ( "Promoted:" ) .. " " .. dayJoined .. " " .. GRM.L ( string.sub ( GRM.OrigL ( GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:GetText() ) , 1 , 3 ) ) .. " '" .. string.sub ( yearJoined , 3 ) );

                -- Need player index to get this info.
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= nil then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] );                                     -- Zone
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] ) );              -- Time Passed
                    end
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoText:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText1:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:Show();
                end

                -- Send the details out for others to pickup!
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                    GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_PD?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. name .. "?" .. promotionDate .. "?" .. tostring( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][2] ) , "GUILD");
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
        GRM_AddonGlobals.pause = false;
        -- Update Audit Frames.
        if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
            GRM.RefreshAuditFrames();
        end
    end
end

-- Method:          GRM.SetAllIncompleteJoinUnknown()
-- What it Does:    Sets the join date of every player in the guild who does not have it yet set as "unknown"
-- Purpose:         More just quality of life information and UI feature. Useful than manually going to them all to set as unknown...
GRM.SetAllIncompleteJoinUnknown = function()
    if not ( GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:GetText() == GRM.L ( "All Complete" ) ) then
        if time() - GRM_AddonGlobals.buttonTimer1 >= 2 then
            if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:GetText() == GRM.L ( "Set Incomplete to Unknown" ) then
                -- Ok, let's go through ALL guildies and clear it!
                for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                    -- if not "unknown" already, and if it doesn't have an established join date
                    if not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][40] and #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][20] == 0 then
                        GRM.ClearJoinDateHistory ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] , true );
                        GRM.DateSubmitCancelResetLogic( true , "join" , true , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] );
                    elseif GRM_UI.GRM_MemberDetailMetaData:IsVisible() and GRM_AddonGlobals.currentName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] then
                        GRM_AddonGlobals.pause = false;
                        GRM.ClearAllFrames( true );
                        GRM.PopulateMemberDetails ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] );
                        GRM_UI.GRM_MemberDetailMetaData:Show();
                        GuildMemberDetailFrame:Hide();
                        GRM_AddonGlobals.pause = true;
                    end
                end
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:SetText ( GRM.L ( "Clear All Unknown" ) );
            else
                for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                    -- if not "unknown" already, and if it doesn't have an established join date
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][40] then
                        GRM.ClearJoinDateHistory ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] , false );
                        GRM.DateSubmitCancelResetLogic( false , "join" , true , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] );
                    elseif GRM_UI.GRM_MemberDetailMetaData:IsVisible() and GRM_AddonGlobals.currentName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] then
                        GRM_AddonGlobals.pause = false;
                        GRM.ClearAllFrames( true );
                        GRM.PopulateMemberDetails ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] );
                        GRM_UI.GRM_MemberDetailMetaData:Show();
                        GuildMemberDetailFrame:Hide();
                        GRM_AddonGlobals.pause = true;
                    end
                end
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetJoinUnkownButton.GRM_SetJoinUnkownButtonText:SetText ( GRM.L ( "Set Incomplete to Unknown" ) );
            end
            GRM.RefreshAuditFrames();
            GRM_AddonGlobals.buttonTimer1 = time();
        else
            GRM.Report ( GRM.L ( "Please Wait {num} more Seconds" , nil , nil , math.floor ( 2 - ( time()-GRM_AddonGlobals.buttonTimer1 ) ) ) );
        end
    end
end

-- Method:          GRM.SetAllIncompletePromoUnknown()
-- What it Does:    Sets the promo date of every player in the guild who does not have it yet set to an unknown value
-- Purpose:         More just quality of life information and UI feature. Useful than manually going to them all...
GRM.SetAllIncompletePromoUnknown = function()
    if not ( GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:GetText() == GRM.L ( "All Complete" ) ) then
        if time() - GRM_AddonGlobals.buttonTimer2 >= 2 then
            if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:GetText() == GRM.L ( "Set Incomplete to Unknown" ) then
                for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                    -- if not "unknown" already, and if it doesn't have an established join date
                    if not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][41] and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][12] == nil then
                        GRM.ClearPromoDateHistory ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] , true );
                        GRM.DateSubmitCancelResetLogic( true , "promo" , true , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] );
                    end
                end
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:SetText ( GRM.L ( "Clear All Unknown" ) );
            else
                for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][41] then
                        GRM.ClearPromoDateHistory ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] , false );
                        GRM.DateSubmitCancelResetLogic( false , "promo" , true , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] );
                    end
                end
                GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame.GRM_SetPromoUnkownButton.GRM_SetPromoUnkownButtonText:SetText ( GRM.L ( "Set Incomplete to Unknown" ) );
            end
            GRM.RefreshAuditFrames();
            GRM_AddonGlobals.buttonTimer2 = time();
        else
            GRM.Report ( GRM.L ( "Please Wait {num} more Seconds" , nil , nil , math.floor ( 2 - ( time()-GRM_AddonGlobals.buttonTimer2 ) ) ) );
        end
    end
end

-- Method:          GRM.DateSubmitCancelResetLogic( boolean , string , boolean , string )
-- What it Does:    Resets the logic on what occurs with the cancel button, since it will have multiple uses.
-- Purpose:         Resource efficiency. No need to make new buttons for everything! This reuses the button, just resets the click logic in join date submit cancel event.
GRM.DateSubmitCancelResetLogic = function( isUnknown , date , isAudit , playerName )
    local buttonText = GRM.L ( GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButtonTxt:GetText() );
    local joinDateText = GRM.L ( "Set Join Date" );
    local promoDateText = GRM.L ( "Set Promo Date" );
    local editDateText = GRM.L ( "Edit Promo Date" );
    local editJoinText = GRM.L ( "Edit Join Date" );
    local name = GRM_AddonGlobals.currentName;
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
    for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == name then

            if name == GRM_AddonGlobals.currentName then
                if ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][41] or GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] ~= nil ) then
                    GRM_AddonGlobals.rankDateSet = true;
                end
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][40] or #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] ~= 0 then
                    showJoinText = true;
                end
            end
                
            if isUnknown then
                if date == "join" then
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][40] = true;
                elseif date == "promo" then
                    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][41] = true
                    if name == GRM_AddonGlobals.currentName then
                        GRM_AddonGlobals.rankDateSet = true;
                    end
                end
            end

            if not isAudit or ( GRM_UI.GRM_MemberDetailMetaData:IsVisible() and GRM_AddonGlobals.currentName == playerName ) then
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= nil then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] );                                     -- Zone
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] ) );              -- Time Passed
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
    if GRM_UI.GRM_MemberDetailMetaData:IsVisible() and name == GRM_AddonGlobals.currentName then
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

            if name == GRM_AddonGlobals.currentName then
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
        
        if not GRM_AddonGlobals.rankDateSet then      --- Promotion has never been recorded!
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Hide();
            GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Show();
        else
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Show();
        end

        if not isAudit then
            GRM_AddonGlobals.pause = false;
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
    local _ , month , day , currentYear = CalendarGetDate();
    local months = { "January" , "February" , "March" , "April" , "May" , "June" , "July" , "August" , "September" , "October" , "November" , "December" };
    local joinDateText = GRM.L ( "Set Join Date" );
    local promoDateText = GRM.L ( "Set Promo Date" );

    -- Month
    GRM_UI.GRM_MemberDetailMetaData.GRM_MonthDropDownMenuSelected.GRM_MonthText:SetText ( GRM.L ( months [ month ] ) );
    GRM_AddonGlobals.monthIndex = month;
    
    -- Year
    GRM_UI.GRM_MemberDetailMetaData.GRM_YearDropDownMenuSelected.GRM_YearText:SetText ( currentYear );
    GRM_AddonGlobals.yearIndex = currentYear;
    
    -- Initialize the day choice now.
    GRM_UI.GRM_MemberDetailMetaData.GRM_DayDropDownMenuSelected.GRM_DayText:SetText ( day );
    GRM_AddonGlobals.dayIndex = day;
    
    if buttonName == "PromoRank" then
        GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButtonTxt:SetText ( promoDateText );
        GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:SetScript("OnClick" , function( self , button )
            if button == "LeftButton" then
                GRM.SetPromoDate();
            end
        end);
    elseif buttonName == "JoinDate" then
        GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButtonTxt:SetText ( joinDateText );
        GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:SetScript("OnClick" , function( self , button )
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
                local simpleName = GRM.GetStringClassColorByName ( GRM_AddonGlobals.currentName ) .. GRM.SlimName ( GRM_AddonGlobals.currentName ) .. "|r";
                local playerSimpleName = GRM.GetStringClassColorByName ( GRM_AddonGlobals.addonPlayerName ) .. GRM.SlimName ( GRM_AddonGlobals.addonPlayerName ) .. "|r";
                local logReport = "";
                -- Promotion Obtained
                if newRankIndex < formerRankIndex and CanGuildPromote() then
                    logReport =   GRM.GetTimestamp() .. " : " .. GRM.L ( "{name} PROMOTED {name2} from {custom1} to {custom2}" , playerSimpleName , simpleName , nil , formerRankName , newRank );
                    
                    -- report the changes!
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] then
                        GRM.PrintLog ( 1 , logReport , false );
                    end
                    GRM.AddLog ( 1 , logReport );

                -- Demotion Obtained
                elseif newRankIndex > formerRankIndex and CanGuildDemote() then
                    logReport =   GRM.GetTimestamp() .. " : " .. GRM.L ( "{name} DEMOTED {name2} from {custom1} to {custom2}" , playerSimpleName , simpleName , nil , formerRankName , newRank );

                    -- reporting the changes!
                    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][5] then
                        GRM.PrintLog ( 2 , logReport , false );                          
                    end
                    GRM.AddLog ( 2 , logReport );
                end
                if GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
                    GRM.PopulateMemberDetails ( GRM_AddonGlobals.currentName );
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
        if GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:IsVisible() then
            GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Hide();
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:SetText ( GRM.L ( "Promoted:" ) .. " " .. GRM.Trim ( string.sub ( timestamp , 1 , 10 ) ) );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Show();
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
        RankButtonsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
        RankButtonsText:SetPoint ( "CENTER" , RankButtons );
        RankButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            RankButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu , 0 , -7 );
            height = height + RankButtons:GetHeight();
        else
            RankButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + RankButtons:GetHeight() + buffer;
        end

        RankButtons:SetScript ( "OnClick" , function( self , button ) 
            if button == "LeftButton" then
                local formerRank = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelectedText:GetText();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelectedText:SetText ( RankButtonsText:GetText() );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelected:Show();
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] = GRM.GetRankIndex ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelectedText:GetText() , self );

                -- Retrigger active addon users... Very important to know permissions
                if not GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:IsVisible() then
                    GRM.RegisterGuildAddonUsersRefresh();
                end

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
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownMenu:SetHeight ( height + 15 );
end

-- Method:          GRM.PopulateBanListOptionsDropDown ()
-- What it Does:    Adds all the guild ranks to the drop down menu for ban changes
-- Purpose:         UI Feature in options - greater control to keep sync of ban list to officers only, whilst allowing great sync with all guildies.
GRM.PopulateBanListOptionsDropDown = function ()
    -- populating the frames!
    local buffer = 3;
    local height = 0;
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
        RankButtonsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
        RankButtonsText:SetPoint ( "CENTER" , RankButtons );
        RankButtonsText:SetJustifyH ( "CENTER" );

        if i == 1 then
            RankButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu , 0 , -7 );
            height = height + RankButtons:GetHeight();
        else
            RankButtons:SetPoint ( "TOP" , GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu.Buttons[i - 1][1] , "BOTTOM" , 0 , -buffer );
            height = height + RankButtons:GetHeight() + buffer;
        end

        RankButtons:SetScript ( "OnClick" , function( self , button ) 
            if button == "LeftButton" then
                local formerRank = GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelectedText:GetText();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelectedText:SetText ( RankButtonsText:GetText() );
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:Hide();
                GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected:Show();
                GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][22] = GRM.GetRankIndex ( GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelectedText:GetText() , self );

                -- Re-trigger addon users permissions
                if not GRM_UI.GRM_RosterChangeLogFrame.GRM_AddonUsersFrame:IsVisible() then
                    GRM.RegisterGuildAddonUsersRefresh();
                end

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
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownMenu:SetHeight ( height + 15 );
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
        ClassButtonsText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 10 );
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
                local nameOfButton = ClassButtons:GetName();
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
                GRM_AddonGlobals.tempAddBanClass = string.upper ( AllClasses[parsedNumber] );
            end
        end);
        ClassButtons:Show();
    end
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_AddBanFrame.GRM_AddBanDropDownMenu:SetHeight ( height + 15 );
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
            GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( GRM.L ( "In Group" ) );
            GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:SetScript ("OnClick" , function ( _ , button , down )
                if button == "LeftButton" then
                    GRM.Report (  GRM.L ( "{name} is Already in Your Group!" , GRM.GetStringClassColorByName ( handle ) .. GRM.SlimName ( handle ) .. "|r" ) );
                end
            end);
        elseif isGroupLeader or isInRaidWithAssist then                                         -- Player has the ability to invite to group
            GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( GRM.L ( "Group Invite" ) );
            GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:SetScript ( "OnClick" , function ( _ , button , down )
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
                        print ( report );
                    else
                        InviteUnit ( handle );
                    end
                end
            end);
        else            -- Player is in a group but does not have invite privileges
            GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( GRM.L ( "No Invite" ) );
            GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:SetScript ( "OnClick" , function ( _ , button , down )
                if button == "LeftButton" then
                    GRM.Report ( GRM.L ( "Player should try to obtain group invite privileges." ) );
                end
            end);
        end
    else
        -- Player is not in any group, thus inviting them will create new group.
        GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton.GRM_GroupInviteButtonText:SetText ( GRM.L ( "Group Invite" ) );
        GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:SetScript ( "OnClick" , function ( _ , button , down )
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

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelectedText:SetText( setRankName );
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelectedText:SetText ( setRankNameBanList );

    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterSyncRankDropDownSelected:Show();
    GRM_UI.GRM_RosterChangeLogFrame.GRM_OptionsFrame.GRM_SyncOptionsFrame.GRM_RosterBanListDropDownSelected:Show();
end

-- Method:              GRM.ClearPromoDateHistory ( string )
-- What it Does:        Purges history of promotions as if they had just joined the guild.
-- Purpose:             Editing ability in case of user error.
GRM.ClearPromoDateHistory = function ( name , isUnknown )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then        -- Player found!
            -- Ok, let's clear the history now!
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][12] = nil;
            if not isUnknown then
                GRM_AddonGlobals.rankDateSet = false;
            end
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] = nil;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] = {};
            table.insert ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][4] , string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][2] , 1 , string.find ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][2] , "'" ) + 2 ) , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][3] } );
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][41] = false;
            if name == GRM_AddonGlobals.currentName and GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
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
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then        -- Player found!
            -- Ok, let's clear the history now!
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][40] = false;
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
            if name == GRM_AddonGlobals.currentName and GRM_UI.GRM_MemberDetailMetaData:IsVisible() then
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
GRM.ResetPlayerMetaData = function ( playerName , guildName )
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == playerName then
            local classedName = GRM.GetStringClassColorByName ( playerName ) .. GRM.SlimName ( playerName ) .. "|r";
            GRM.Report ( GRM.L ( "{name}'s saved data has been wiped!" , classedName ) );

            local memberInfo = { playerName , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][4] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][5] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][6] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][7] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][8] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][9] , nil , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][28] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][29] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][30] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][31] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][33] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][34] };

            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] > 0 then
                GRM.RemoveAlt ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][1][1] , playerName , guildName , false , 0 , false );      -- Removing oneself from his alts list on clearing info so it clears him from them too.
            end
            table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] , j );         -- Remove the player!
            GRM.AddMemberRecord( memberInfo , false , nil , guildName )     -- Re-Add the player!
            GRM_UI.GRM_MemberDetailMetaData:Hide();
            
            --Let's re-initiate syncing!
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and not GRMsyncGlobals.currentlySyncing and GRM_AddonGlobals.HasAccessToGuildChat then
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

    -- Hide the window frame so it can quickly be reloaded.
    GRM_UI.GRM_MemberDetailMetaData:Hide();

    -- Reset the important guild indexes for data tracking.
    GRM_AddonGlobals.saveGID = 0;
    GRM_AddonGlobals.logGID = 0;

    -- Now, let's rebuild...
    if IsInGuild() then
        GRM.BuildNewRoster();
    end
    -- Update the logFrame if it was open at the time too
    if GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then
        GRM.BuildLog();
    end

    -- Update the ban list too!
    if GRM_CoreBanListFrame:IsVisible() then
        GRM.RefreshBanListFrames();
    end

    if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
        GRM.RefreshAuditFrames();
    end

    -- To avoid Lua error if player tries to trigger this immediately after loading
    if GRM_AddonGlobals.setPID == 0 then
        for i = 2 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] do
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.addonPlayerName then
                GRM_AddonGlobals.setPID = i;
                break;
            end
        end
    end

    -- Trigger Sync
    --Let's re-initiate syncing!
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and not GRMsyncGlobals.currentlySyncing and GRM_AddonGlobals.HasAccessToGuildChat then
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
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][i][1] == guildName then
            table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ] , i );
            break;
        end
    end

    -- Removing Players that left saved metadata
    for i = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ] do
        if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][i][1] == guildName then
            table.remove ( GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ] , i );
            break;
        end
    end

    -- Clearing the Guild Log...
    for i = 2 , #GRM_LogReport_Save[ GRM_AddonGlobals.FID ] do
        if GRM_LogReport_Save[ GRM_AddonGlobals.FID ][i][1] == guildName then
            table.remove ( GRM_LogReport_Save[ GRM_AddonGlobals.FID ] , i );
            break;
        end
    end

    -- Clearing the Guild Log...Resetting the add to calendar que
    for i = 2 , #GRM_CalendarAddQue_Save[ GRM_AddonGlobals.FID ] do
        if GRM_CalendarAddQue_Save[ GRM_AddonGlobals.FID ][i][1] == guildName then
            table.remove ( GRM_CalendarAddQue_Save[ GRM_AddonGlobals.FID ] , i );
            break;
        end
    end

    -- Clearing the Guild Notepads
    for i = 2 , #GRM_GuildNotePad_Save[ GRM_AddonGlobals.FID ] do
        if GRM_GuildNotePad_Save[ GRM_AddonGlobals.FID ][i][1] == guildName then
            table.remove ( GRM_GuildNotePad_Save[ GRM_AddonGlobals.FID ] , i );
            break;
        end
    end

    -- Hide the window frame so it can quickly be reloaded.
    GRM_UI.GRM_MemberDetailMetaData:Hide();
    
    -- Reset the important guild indexes for data tracking.
    GRM_AddonGlobals.saveGID = 0;
    GRM_AddonGlobals.logGID = 0;

    -- Now, let's rebuild...
    if IsInGuild() then
        GRM.BuildNewRoster();
    end
    -- Update the logFrame if it was open at the time too
    if GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then
        GRM.BuildLog();
    end

    -- Update the ban list too!
    if GRM_CoreBanListFrame:IsVisible() then
        GRM.RefreshBanListFrames();
    end

    if GRM_UI.GRM_RosterChangeLogFrame.GRM_AuditFrame:IsVisible() then
        GRM.RefreshAuditFrames();
    end

    -- Trigger Sync
    -- To avoid Lua error if player tries to trigger this immediately after loading
    if GRM_AddonGlobals.setPID == 0 then
        for i = 2 , #GRM_AddonSettings_Save[GRM_AddonGlobals.FID] do
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][i][1] == GRM_AddonGlobals.addonPlayerName then
                GRM_AddonGlobals.setPID = i;
                break;
            end
        end
    end
    
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
        GRM.Report ( GRM.L ( "There are No Log Entries to Delete, silly {name}!" , GRM.GetClassifiedName ( GRM_AddonGlobals.addonPlayerName , true ) ) );
    else
        GRM.Report ( GRM.L ( "Guild Log has been RESET!" ) );
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
        if GRM_UI.GRM_RosterChangeLogFrame:IsVisible() then    -- if frame is open, let's rebuild it!
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
        if string.find ( text , GRM.L ( "has been kicked" ) ) ~= nil and string.find ( text , GRM.SlimName ( GRM_AddonGlobals.addonPlayerName ) ) ~= nil and string.find ( text , GRM.SlimName ( frameName ) ) ~= nil then
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
                        local result = GRM_UI.GRM_MemberDetailPopupEditBox:GetText();
                        if result ~= GRM.L ( "Reason Banned?" ) .. "\n" .. GRM.L ( "Click \"YES\" When Done" ) and result ~= "" and result ~= nil then
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] = result;
                        else
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] = "";
                            result = "";
                        end

                        -- Add a log message too if it is a ban!
                        local logEntry = "";
                        
                        if GRM_AddonGlobals.isChecked2 then
                            logEntry = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name} has BANNED {name2} and all linked alts from the guild!" , GRM.GetClassifiedName ( GRM_AddonGlobals.addonPlayerName , true ) , GRM.GetClassifiedName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] , true ) ) );
                            
                            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] ~= "" then
                                GRM.AddLog ( 18 , GRM.L ( "Reason Banned:" ) .. " " .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] );
                            end
                            GRM.AddLog ( 17 , logEntry );
                        else
                            logEntry = ( GRM.GetTimestamp() .. " : " .. GRM.L ( "{name} has BANNED {name2} from the guild!" , GRM.GetClassifiedName ( GRM_AddonGlobals.addonPlayerName , true ) , GRM.GetClassifiedName ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] , true ) ) );
                            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] ~= "" then
                                GRM.AddLog ( 18 , GRM.L ( "Reason Banned:" ) .. " " .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] );
                            end
                            GRM.AddLog ( 17 , logEntry );
                        end

                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][13][4] then
                            GRM.PrintLog ( 17 , logEntry , false );
                            GRM.PrintLog ( 18 , GRM.L ( "Reason Banned:" ) .. " " .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] , false );
                        end

                        -- Send the message out!
                        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][21] then
                            if result == "" then
                                result = GRM.L ( "None Given" );
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
            GRM_UI.GRM_MemberDetailMetaData:Hide();
            GRM.BuildLog();

            GRM_AddonGlobals.pause = false;
            if GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:IsVisible() then
                GRM.RefreshBanListFrames();
            end
        
        elseif ( string.find ( text , GRM.L ( "has promoted" ) ) ~= nil or string.find ( text , GRM.L ( "has demoted" ) ) ~= nil ) and string.sub ( text , 1 , string.find ( text , " " ) -1 ) == GRM.SlimName ( GRM_AddonGlobals.addonPlayerName ) then
            GRM_AddonGlobals.changeHappenedExitScan = true;
            C_Timer.After ( 0.5 , function()
                GRM.OnRankChange ( GRM_AddonGlobals.CurrentRank , GuildMemberRankDropdownText:GetText() );
            end);
        elseif string.find ( text , GRM.L ( "joined the guild." ) ) ~= nil then
            GRM_AddonGlobals.changeHappenedExitScan = false;
            GuildRoster();
            GRM_AddonGlobals.trackingTriggered = false;
            QueryGuildEventLog();
            if GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:IsVisible() then
                GRM.RefreshBanListFrames();
            end
        end

    elseif msg == "CHAT_MSG_SYSTEM" and string.find ( text , GRM.L ( "joined the guild." ) ) ~= nil then
        GRM_AddonGlobals.changeHappenedExitScan = false;
        GuildRoster();
        GRM_AddonGlobals.trackingTriggered = false;
        QueryGuildEventLog();
        -- Adds player in case of long delay... updates ban list live if necessary as well.
        if GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame:IsVisible() then
            GRM.RefreshBanListFrames();
        end
    end
end

-- Method:          GRM.RemoveBan( int , boolean , boolean , int )
-- What it Does:    Just what it says... it removes the ban from the player and wipes the data clean. No history of ban is stored
-- Purpose:         Necessary for forgiveness or accidental banning.
GRM.RemoveBan = function ( playerIndex , onPopulate )
    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][playerIndex][17] = nil;
    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][playerIndex][17] = { false , time() , true }
    GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][playerIndex][18] = "";

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
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == name then
            if timestamp > GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17][2] then
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17] = nil;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17] = { false , timestamp , true }
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][18] = "";
                
                GRM_UI.GRM_MemberDetailBannedText1:Hide();
                GRM_UI.GRM_MemberDetailBannedIgnoreButton:Hide();
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

GRM.ChangeCurrentPlayerBanReason = function ( name , reason )
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == name then
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][18] = reason;
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
---- GUILD SHARED NOTEPAD -----
-------------------------------

-- Method
GRM.AddNote = function( destination , editor , timestamp )

end

GRM.EditNote = function ( note , editor , timestamp )

end

GRM.RemoveNote = function ( note , editor , timestamp )

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
                GRM_AddonGlobals.currentNameIndex = r;
                -- Trigger Check for Any Changes
                GuildRoster();

                for i = 1 , GRM.GetNumGuildies() do
                    local fullName, _, _, _, _, zone, _, _, isOnline = GetGuildRosterInfo ( i );
                    if fullName == handle then
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] = isOnline;
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= zone then
                            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] = time();    -- Resets the time
                        end
                        GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] = zone;
                        break;
                    end                    
                end
                
                --- CLASS
                local classColors = GRM.GetClassColorRGB ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][9] );
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:SetTextColor ( classColors[1] , classColors[2] , classColors[3] , 1.0 );
                
                -- PLAYER NAME
                -- Let's scale the name too!
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:SetText ( GRM.SlimName ( handle ) );
                local nameHeight = 16;
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + nameHeight );        -- Reset size back to 16 just in case previous fontstring was altered 
                while ( GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:GetWidth() > 120 ) do
                    nameHeight = nameHeight - 0.1;
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + nameHeight );
                end

                -- IS MAIN
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][10] then
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:Show();
                else
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMainText:Hide();
                end

                --- LEVEL
                if GRM_AddonGlobals.Region == "ruRU" or GRM_AddonGlobals.Region == "koKR" then
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLevel:SetText (  tostring ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][6] ) .. GRM.L ( "Level: " ) );
                else
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLevel:SetText ( GRM.L ( "Level: " ) .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][6] );
                end

                -- RANK
                GRM_AddonGlobals.rankIndex = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][5];

                -- Possibly a player index issue...
                if GRM_AddonGlobals.playerIndex == -1 then
                    GRM_AddonGlobals.playerIndex = GRM.GetGuildMemberRankID ( GRM_AddonGlobals.addonPlayerName );
                end

                -- Rank Text Info...
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankTxt:SetText ( "\"" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][4] .. "\"");
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankTxt:Show();

                -- ZONE INFORMATION
                if not GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:IsVisible() then
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] ~= nil then
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoZoneText:SetText ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][28] );                                     -- Zone
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][32] ) );              -- Time Passed
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
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][41] then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:SetText ( GRM.L ( "Promoted:" ) .. " " .. GRM.L ( "Unknown" ) );
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Show();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Hide();
                        GRM_AddonGlobals.rankDateSet = true;
                    else
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] == nil then      --- Promotion has never been recorded!
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Hide();
                            GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Show();
                        else
                            GRM_UI.GRM_MemberDetailMetaData.GRM_SetPromoDateButton:Hide();
                            GRM_AddonGlobals.rankDateSet = true;
                            local t = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12];
                            local day = string.sub ( t , 1 , string.find ( t , " " ) - 1 );
                            local month = string.sub ( t , string.find ( t , " " ) + 1 , string.find ( t , " " , -4 ) -1 ); 
                            local year = string.sub ( t , string.find ( t , "'" ) + 1 );
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:SetText ( GRM.L ( "Promoted:" ) .. " " .. day .. " " .. GRM.L ( month ) .. " '" .. year );
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:Show();
                        end
                    end

                    -- JOIN DATE
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][40] then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton:Hide();
                        GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:SetText ( GRM.L ( "Unknown" ) );
                        GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:Show();
                    else
                        if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] == 0 then
                            GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:Hide();
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton:Show();
                        else
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateButton:Hide();
                            local t = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20][#GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20]];
                            local day = string.sub ( t , 1 , string.find ( t , " " ) - 1 );
                            local month = string.sub ( t , string.find ( t , " " ) + 1 , string.find ( t , " " ) + 3 );
                            local year = string.sub ( t , string.find ( t , "'" ) + 1 , string.find ( t , "'" ) + 2 );
                            GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:SetText ( day .. " " .. GRM.L ( month ) .. " '" .. year );
                            GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:Show();
                        end
                    end
                end

                -- PLAYER NOTE AND OFFICER NOTE EDIT BOXES
                if not GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:HasFocus() and not GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:HasFocus() then
                    local finalNote = GRM.L ( "Click here to set a Public Note" );
                    local finalONote = GRM.L ( "Click here to set an Officer's Note" );
                    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerNoteEditBox:Hide();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_PlayerOfficerNoteEditBox:Hide();

                    -- Set Public Note if is One
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][7] ~= nil and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][7] ~= "" then
                        finalNote = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][7];
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
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8] ~= nil and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8] ~= "" then
                            finalONote = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][8];
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
                    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString2:Show();
                    GRM_UI.GRM_MemberDetailMetaData.GRM_noteFontString1:Show();
                end

                -- Last Online
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] then
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLastOnlineTxt:SetText ( GRM.L ( "Online" ) );
                else
                    GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailLastOnlineTxt:SetText ( GRM.HoursReport ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][24] ) );
                end

                -- Group Invite Button -- Setting script here
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][33] and handle ~= GRM_AddonGlobals.addonPlayerName then
                    GRM.SetGroupInviteButton ( handle );
                    GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:Show();
                else
                    GRM_UI.GRM_MemberDetailMetaData.GRM_GroupInviteButton:Hide();
                end

                -- IF PLAYER WAS PREVIOUSLY BANNED AND REJOINED
                -- Player was previous banned and rejoined logic! This will unban the player.
                local isGuildieBanned = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][1];
                if isGuildieBanned and handle ~= GRM_AddonGlobals.addonPlayerName and CanGuildRemove() then
                    GRM_UI.GRM_MemberDetailBannedIgnoreButton:SetScript ( "OnClick" , function ( _ , button ) 
                        if button == "LeftButton" then
                            GRM.RemoveBan ( r , true );

                            -- Send the unban out for sync'd players
                            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][21] then
                                GRMsync.SendMessage ( "GRM_SYNC" , GRM_AddonGlobals.PatchDayString .. "?GRM_UNBAN?" .. GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. tostring ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][22] ) .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] .. "?" , "GUILD");
                            end
                            -- Message
                            local classColorHex = GRM.GetClassColorRGB ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][9] , true )
                            GRM.Report ( GRM.L ( "{name} has been Removed from the Ban List." ,  classColorHex .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] .. "|r" ) );
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
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitCancelButton:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_NoteCount:Hide();
    GRM_UI.GRM_CoreAltFrame:Hide();
    GRM_UI.GRM_altDropDownOptions:Hide();
    GRM_UI.GRM_AddAltButton:Hide();
    GRM_UI.GRM_CoreAltFrame.GRM_AddAltEditFrame:Hide();
    GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:Hide();
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

        -- control on whether to freeze the scanning.
        if not nameCopy and GRM_AddonGlobals.pause and not GRM_UI.GRM_MemberDetailMetaData:IsVisible() and not GuildMemberDetailFrame:IsVisible() then
            GRM_AddonGlobals.pause = false;
        end

        -- Really need to localize the "Professions"
        if nameCopy or ( GRM_AddonGlobals.pause == false and not DropDownList1:IsVisible() and not GuildMemberDetailFrame:IsVisible() and ( GuildRosterViewDropdownText:IsVisible() and GuildRosterViewDropdownText:GetText() ~= GRM.L ( "Professions" ) ) ) then
            if not nameCopy then
                GRM.SubFrameCheck();
            end
            local NotSameWindow = true;
            local mouseNotOver = true;
            local name = "";
            local tempScrollPosition = GuildRosterContainerScrollBar:GetValue();
            
            if ( GuildRosterContainerButton1:IsMouseOver ( 1 , -1 , -1 , 1 ) ) then
                if 1 ~= GRM_AddonGlobals.position or nameCopy or tempScrollPosition ~= GRM_AddonGlobals.ScrollPosition then
                    name = GRM.GetRosterName ( GuildRosterContainerButton1String2 , GuildRosterContainerButton1String1 , 1 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 1;
                        GRM_AddonGlobals.ScrollPosition = tempScrollPosition;
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_UI.GRM_MemberDetailMetaData:Show();
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
                if 2 ~= GRM_AddonGlobals.position or nameCopy or tempScrollPosition ~= GRM_AddonGlobals.ScrollPosition then
                    name = GRM.GetRosterName ( GuildRosterContainerButton2String2 , GuildRosterContainerButton2String1 , 2 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 2;
                        GRM_AddonGlobals.ScrollPosition = tempScrollPosition;
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_UI.GRM_MemberDetailMetaData:Show();
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
                if 3 ~= GRM_AddonGlobals.position or nameCopy or tempScrollPosition ~= GRM_AddonGlobals.ScrollPosition then
                    name = GRM.GetRosterName ( GuildRosterContainerButton3String2 , GuildRosterContainerButton3String1  , 3 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 3;
                        GRM_AddonGlobals.ScrollPosition = tempScrollPosition;
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_UI.GRM_MemberDetailMetaData:Show();
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
                if 4 ~= GRM_AddonGlobals.position or nameCopy or tempScrollPosition ~= GRM_AddonGlobals.ScrollPosition then
                    name = GRM.GetRosterName ( GuildRosterContainerButton4String2 , GuildRosterContainerButton4String1 , 4 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 4;
                        GRM_AddonGlobals.ScrollPosition = tempScrollPosition;
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_UI.GRM_MemberDetailMetaData:Show();
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
                if 5 ~= GRM_AddonGlobals.position or nameCopy or tempScrollPosition ~= GRM_AddonGlobals.ScrollPosition then
                    name = GRM.GetRosterName ( GuildRosterContainerButton5String2 , GuildRosterContainerButton5String1 , 5 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 5;
                        GRM_AddonGlobals.ScrollPosition = tempScrollPosition;
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_UI.GRM_MemberDetailMetaData:Show();
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
                if 6 ~= GRM_AddonGlobals.position or nameCopy or tempScrollPosition ~= GRM_AddonGlobals.ScrollPosition then
                    name = GRM.GetRosterName ( GuildRosterContainerButton6String2 , GuildRosterContainerButton6String1 , 6 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 6;
                        GRM_AddonGlobals.ScrollPosition = tempScrollPosition;
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_UI.GRM_MemberDetailMetaData:Show();
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
                if 7 ~= GRM_AddonGlobals.position or nameCopy or tempScrollPosition ~= GRM_AddonGlobals.ScrollPosition then
                    name = GRM.GetRosterName ( GuildRosterContainerButton7String2 , GuildRosterContainerButton7String1 , 7 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 7;
                        GRM_AddonGlobals.ScrollPosition = tempScrollPosition;
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_UI.GRM_MemberDetailMetaData:Show();
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
                if 8 ~= GRM_AddonGlobals.position or nameCopy or tempScrollPosition ~= GRM_AddonGlobals.ScrollPosition then
                    name = GRM.GetRosterName ( GuildRosterContainerButton8String2 , GuildRosterContainerButton8String1 , 8 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 8;
                        GRM_AddonGlobals.ScrollPosition = tempScrollPosition;
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_UI.GRM_MemberDetailMetaData:Show();
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
                if 9 ~= GRM_AddonGlobals.position or nameCopy or tempScrollPosition ~= GRM_AddonGlobals.ScrollPosition then
                    name = GRM.GetRosterName ( GuildRosterContainerButton9String2 , GuildRosterContainerButton9String1 , 9 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 9;
                        GRM_AddonGlobals.ScrollPosition = tempScrollPosition;
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_UI.GRM_MemberDetailMetaData:Show();
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
                if 10 ~= GRM_AddonGlobals.position or nameCopy or tempScrollPosition ~= GRM_AddonGlobals.ScrollPosition then
                    name = GRM.GetRosterName ( GuildRosterContainerButton10String2 , GuildRosterContainerButton10String1 , 10 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 10;
                        GRM_AddonGlobals.ScrollPosition = tempScrollPosition;
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_UI.GRM_MemberDetailMetaData:Show();
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
                if 11 ~= GRM_AddonGlobals.position or nameCopy or tempScrollPosition ~= GRM_AddonGlobals.ScrollPosition then
                    name = GRM.GetRosterName ( GuildRosterContainerButton11String2 , GuildRosterContainerButton11String1 , 11 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 11;
                        GRM_AddonGlobals.ScrollPosition = tempScrollPosition;
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_UI.GRM_MemberDetailMetaData:Show();
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
                if 12 ~= GRM_AddonGlobals.position or nameCopy or tempScrollPosition ~= GRM_AddonGlobals.ScrollPosition then
                    name = GRM.GetRosterName ( GuildRosterContainerButton12String2 , GuildRosterContainerButton12String1 , 12 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 12;
                        GRM_AddonGlobals.ScrollPosition = tempScrollPosition;
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_UI.GRM_MemberDetailMetaData:Show();
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
                if 13 ~= GRM_AddonGlobals.position or nameCopy or tempScrollPosition ~= GRM_AddonGlobals.ScrollPosition then
                    name = GRM.GetRosterName ( GuildRosterContainerButton13String2 , GuildRosterContainerButton13String1 , 13 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 13;
                        GRM_AddonGlobals.ScrollPosition = tempScrollPosition;
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_UI.GRM_MemberDetailMetaData:Show();
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
                if 14 ~= GRM_AddonGlobals.position or nameCopy or tempScrollPosition ~= GRM_AddonGlobals.ScrollPosition then
                    name = GRM.GetRosterName ( GuildRosterContainerButton14String2 , GuildRosterContainerButton14String1 , 14 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 14;
                        GRM_AddonGlobals.ScrollPosition = tempScrollPosition;
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_UI.GRM_MemberDetailMetaData:Show();
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
                if 15 ~= GRM_AddonGlobals.position or nameCopy or tempScrollPosition ~= GRM_AddonGlobals.ScrollPosition then
                    name = GRM.GetRosterName ( GuildRosterContainerButton15String2 , GuildRosterContainerButton15String1 , 15 );
                    if ( not nameCopy ) or ( nameCopy and string.find ( GetCurrentKeyBoardFocus():GetText() , GRM.SlimName ( name ) ) == nil ) then
                        
                        GRM_AddonGlobals.position = 15;
                        GRM_AddonGlobals.ScrollPosition = tempScrollPosition;
                        GRM_AddonGlobals.ShowOfflineChecked = GuildRosterShowOfflineButton:GetChecked();

                        if not nameCopy then
                            GRM.PopulateMemberDetails( name );
                            if GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true then
                                GRM_UI.GRM_MemberDetailMetaData:Show();
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
                if ( GuildRosterFrame:IsMouseOver ( 2 , -2 , -2 , 2 ) ~= true and not DropDownList1Backdrop:IsMouseOver ( 2 , -2 , -2 , 2 ) and not StaticPopup1:IsMouseOver ( 2 , -2 , -2 , 2 ) and not GRM_UI.GRM_MemberDetailMetaData:IsMouseOver ( 2 , -2 , -2 , 2 ) ) or 
                    ( GRM_UI.GRM_MemberDetailMetaData:IsMouseOver ( 2 , -2 , -2 , 2 ) == true and GRM_UI.GRM_MemberDetailMetaData:IsVisible() ~= true ) then  -- If player is moused over side window, it will not hide it!
                    GRM_AddonGlobals.position = 0;
                    
                    GRM.ClearAllFrames( true );
                end
            end
        end
    end
    -- On Update -- Update these
    if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:IsVisible() then
        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailMetaZoneInfoTimeText2:SetText ( GRM.GetTimePassed ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][GRM_AddonGlobals.currentNameIndex][32] ) );
    end

    -- STATUS TEXT
    if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:IsVisible() then
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][GRM_AddonGlobals.currentNameIndex][33] or handle == GRM_AddonGlobals.addonPlayerName then
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][GRM_AddonGlobals.currentNameIndex][34] == 0 then
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetTextColor ( 0.12 , 1.0 , 0.0 , 1.0 );
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetText ( GRM.L ( "( Active )" ) );
            elseif GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][GRM_AddonGlobals.currentNameIndex][34] == 1 then
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetTextColor ( 1.0 , 0.96 , 0.41 , 1.0 );
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetText ( GRM.L ( "( AFK )" ) );
            else
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetTextColor ( 0.77 , 0.12 , 0.23 , 1.0 );
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetText ( GRM.L ( "( Busy )" ) );
            end
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:Show();
        elseif GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][GRM_AddonGlobals.currentNameIndex][30] then
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetTextColor ( 0.87 , 0.44 , 0.0 , 1.0 );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetText ( GRM.L ( "( Mobile )" ) );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:Show();
        elseif not GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][GRM_AddonGlobals.currentNameIndex][33] then
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetTextColor ( 0.5 , 0.5 , 0.5 , 1.0 );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:SetText ( GRM.L ( "( Offline )" ) );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:Show();
        else
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:Hide();
        end
    end

    if GuildRosterFrame:IsVisible() ~= true or ( GuildRosterViewDropdownText:IsVisible() and GuildRosterViewDropdownText:GetText() == GRM.L ( "Professions" ) ) then
        GRM_AddonGlobals.position = 0;
        GRM.ClearAllFrames( true );
    end
end


-- Method:          GRM.SelectPlayerOnRoster ( string )
-- What it Does:    If the guild roster window is open, this will jump to the player anywhere in the roster, online or offline, and bring up their metadata window
-- Purpose:         Useful for when a player wants to click and alt rather than have to scan through the roster for them.
GRM.SelectPlayerOnRoster = function ( playerName )
    GuildMemberDetailFrame:Hide();
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
    
    GRM_AddonGlobals.currentName = playerName;
    GRM_AddonGlobals.pause = false;
    GRM.ClearAllFrames( false );
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
    local scrollWidth = 561;
    local buffer = 20;

    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons = GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons or {};  -- Create a table for the Buttons.

    -- populating the window correctly.
    local count = 0;
    local tempHeight = 0;

    -- Populating the window based on the Current Players PLayers
    for i = #GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] , 2 , -1 do
        -- if font string is not created, do so.
        if GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][17][1] then  -- If player is banned.
                
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
            local classColor = GRM.GetClassColorRGB ( GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][9] );

            BanButtons:SetWidth ( 555 );
            BanButtons:SetHeight ( 19 );
            BanButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
            BanNameText:SetText ( GRM.L ( "{name}(Still in Guild)" , GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][1] .. "  |cff7fff00" ) );
            BanNameText:SetTextColor ( classColor[1] , classColor[2] , classColor[3] , 1 );
            BanNameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            BanNameText:SetJustifyH ( "LEFT" );
            BanRankText:SetText ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][4] );
            BanRankText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            BanRankText:SetTextColor ( 0.90 , 0.80 , 0.50 , 1.0 );
            BanDateText:SetText ( GRM.EpochToDateFormat ( GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][17][2] ) );
            BanDateText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            -- Determine it's not an empty ban reason!
            local reason = "";
            if GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][18] == "" or GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][18] == nil then
                reason = GRM.L ( "No Ban Reason Given" );
            else
                reason = GRM_GuildMemberHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][18];
            end
            BanReasonText:SetText ( "|CFFFF0000" .. GRM.L ( "Reason:" ) .. " |CFFFFFFFF" .. reason );
            BanReasonText:SetWidth ( 245 );
            BanReasonText:SetWordWrap ( true );
            BanReasonText:SetSpacing ( 1 );
            BanReasonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            BanReasonText:SetPoint ( "TOPLEFT" , BanButtons , "BOTTOMLEFT" , 0 , -1);
            BanReasonText:SetJustifyH ( "LEFT" );

            -- Logic
            BanButtons:SetScript ( "OnClick" , function ( self , button )
                if button == "LeftButton" then
                    -- For highlighting purposes
                    for j = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons do
                        if BanButtons ~= GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1] then
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1]:UnlockHighlight();
                        else
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1]:LockHighlight();
                        end
                    end
                    local fullName = BanNameText:GetText();
                    local R,G,B = BanNameText:GetTextColor();

                    GRM_AddonGlobals.TempBanTarget = { string.sub ( fullName , 1 , string.find ( fullName , " " ) - 1 ) , { GRM.ConvertRGBScale ( R , true ) , GRM.ConvertRGBScale ( G , true ) , GRM.ConvertRGBScale ( B , true ) } }; -- Need to parse out the "(Still in Guild)"
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:SetText ( GRM.SlimName ( fullName ) );
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameText:SetText ( GRM.L ( "Player Selected" ) );
                    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListFrameSelectedNameText:Show();
                    
                end
            end);
            
            -- Now let's pin it!
            
            if count == 1 then
                BanButtons:SetPoint( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame , "TOPLEFT" , 5 , -12 );
                BanNameText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame , "TOPLEFT" , 5 , -12 );
                BanRankText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame , "TOP" , 44 , -12 );
                BanDateText:SetPoint ( "TOPLEFT" , GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame , "TOPLEFT" , 457 , -12 );
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
    for i = #GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID] , 2 , -1 do
        -- if font string is not created, do so.
        if GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][17][1] then  -- If player is banned.
                
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
            local classColor = GRM.GetClassColorRGB ( GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][9] );

            BanButtons:SetWidth ( 555 );
            BanButtons:SetHeight ( 19 );
            BanButtons:SetHighlightTexture ( "Interface\\Buttons\\UI-Panel-Button-Highlight" );
            BanNameText:SetText ( GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][1] );
            BanNameText:SetTextColor ( classColor[1] , classColor[2] , classColor[3] , 1 );
            BanNameText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            BanNameText:SetJustifyH ( "LEFT" );
            BanRankText:SetText ( GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][19] );
            BanRankText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            BanRankText:SetJustifyH ( "CENTER" );
            BanRankText:SetTextColor ( 0.90 , 0.80 , 0.50 , 1.0 );
            BanDateText:SetText ( GRM.EpochToDateFormat ( GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][17][2] ) );
            BanDateText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            -- Determine it's not an empty ban reason!
            local reason = "";
            if GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][18] == "" or GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][18] == nil then
                reason = GRM.L ( "No Ban Reason Given" );
            else
                reason = GRM_PlayersThatLeftHistory_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.saveGID][i][18];
            end
            BanReasonText:SetText ( "|CFFFF0000" .. GRM.L ( "Reason:" ) .. " |CFFFFFFFF" .. reason );
            BanReasonText:SetWidth ( 245 );
            BanReasonText:SetWordWrap ( true );
            BanReasonText:SetSpacing ( 1 );
            BanReasonText:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 12 );
            BanReasonText:SetPoint ( "TOPLEFT" , BanButtons , "BOTTOMLEFT" , 0 , -1);
            BanReasonText:SetJustifyH ( "LEFT" );

            -- Logic
            BanButtons:SetScript ( "OnClick" , function ( self , button )
                if button == "LeftButton" then
                    -- For highlighting purposes
                    for j = 1 , #GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons do
                        if BanButtons ~= GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1] then
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1]:UnlockHighlight();
                        else
                            GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollChildFrame.allFrameButtons[j][1]:LockHighlight();
                        end
                    end
                    
                    local fullName = BanNameText:GetText();
                    local R,G,B = BanNameText:GetTextColor();
                    GRM_AddonGlobals.TempBanTarget = { fullName , { GRM.ConvertRGBScale ( R , true ) , GRM.ConvertRGBScale ( G , true ) , GRM.ConvertRGBScale ( B , true ) } };
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
    GRM_UI.GRM_RosterChangeLogFrame.GRM_CoreBanListFrame.GRM_CoreBanListScrollFrame:SetScript( "OnMouseWheel" , function( self , delta )
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
GRM.MemberDetailToolTips = function ( self , elapsed )
    GRM_AddonGlobals.timer2 = GRM_AddonGlobals.timer2 + elapsed;
    if GRM_AddonGlobals.timer2 >= 0.075 then
        local name = GRM_AddonGlobals.currentName;

        -- Rank Text
        -- Only populate and show tooltip if mouse is over text frame and it is not already visible.
        if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip:IsVisible() ~= true and not StaticPopup1:IsVisible() and not DropDownList1:IsVisible() and GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:IsVisible() == true and GRM_UI.GRM_altDropDownOptions:IsVisible() ~= true and GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:IsMouseOver(1,-1,-1,1) == true then
            
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip:SetOwner( GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt , "ANCHOR_BOTTOMRIGHT" );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip:AddLine( "|cFFFFFFFF" .. GRM.L ( "Rank History" ) );

            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then   --- Player Found in MetaData Logs
                    -- Now, let's build the tooltip
                    if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:GetText() == GRM.L ( "Promoted:" ) .. " " .. GRM.L ( "Unknown" ) then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip:AddDoubleLine ( "|cFFFF0000" .. GRM.L ( "Time at Rank:" ) , GRM.L ( "Unknown" ) );
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip:AddDoubleLine ( " " , " " );
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip:AddLine ( GRM.L ( "Right-Click to Edit" ) );
                    else
                        for k = #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] , 1 , -1 do
                            if k == #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25] then
                                local timeAtRank = GRM.GetTimePassedUsingStringStamp ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][12] );
                                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip:AddDoubleLine ( "|cFFFF0000" .. GRM.L ( "Time at Rank:" ) , timeAtRank[4] );
                                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip:AddDoubleLine ( " " , " " );
                            end
                            local t = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25][k][2];
                            local day = string.sub ( t , 1 , string.find ( t , " " ) , - 1 );
                            local month = string.sub ( t , string.find ( t , " " ) + 1 , string.find ( t , " " ) + 3 );
                            local year = string.sub ( t , string.find ( t , "'" ) + 1 );
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip:AddDoubleLine(  string.gsub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][25][k][1] , "Left Guild" , GRM.L ( "Left Guild" ) ) .. ":" , day .. " " .. GRM.L ( month ) .. " '" .. year , 0.38 , 0.67 , 1.0 );
                        end
                    end
                    break;
                end
            end

            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip:Show();
        elseif GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip:IsVisible() == true and GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankDateTxt:IsMouseOver(1,-1,-1,1) ~= true then
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailRankToolTip:Hide();
            GRM_MemberDetailServerNameToolTip:Hide();
        end

        -- JOIN DATE TEXT
        if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip:IsVisible() ~= true and not StaticPopup1:IsVisible() and GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:IsVisible() == true and GRM_UI.GRM_altDropDownOptions:IsVisible() ~= true and GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:IsMouseOver(1,-1,-1,1) == true then
           
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip:SetOwner( GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText , "ANCHOR_BOTTOMRIGHT" );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip:AddLine( "|cFFFFFFFF" .. GRM.L ( "Membership History" ) );
            local joinedHeader;

            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then   --- Player Found in MetaData Logs
                    -- Ok, let's build the tooltip now.
                    if GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:GetText() == GRM.L ( "Unknown" ) then
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip:AddDoubleLine ( GRM.L ( "Joined:" ) , GRM.L ( "Unknown" ) );
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip:AddDoubleLine ( " " , " " );
                        GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip:AddLine ( GRM.L ( "Right-Click to Edit" ) );
                    else
                        for r = #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20] , 1 , -1 do                                       -- Starting with most recent join which will be at end of array.
                            if r > 1 then
                                joinedHeader = GRM.L ( "Rejoined:" );
                            else
                                joinedHeader = GRM.L ( "Joined:" );
                            end
                            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][15][r] ~= nil then
                                local t = string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][15][r] , 1 , 10  );
                                local day = string.sub ( t , 1 , string.find ( t , " " ) , - 1 );
                                local month = string.sub ( t , string.find ( t , " " ) + 1 , string.find ( t , " " ) + 3 );
                                local year = string.sub ( t , string.find ( t , "'" ) + 1 );
                                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip:AddDoubleLine( "|CFFC41F3B" .. GRM.L ( "Left:" ) ,  day .. " " .. GRM.L ( month ) .. " '" .. year , 1 , 0 , 0 );
                            end
                            local t = string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][20][r] , 1 , 10  );
                            local day = string.sub ( t , 1 , string.find ( t , " " ) , - 1 );
                            local month = string.sub ( t , string.find ( t , " " ) + 1 , string.find ( t , " " ) + 3 );
                            local year = string.sub ( t , string.find ( t , "'" ) + 1 );
                            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip:AddDoubleLine( joinedHeader , day .. " " .. GRM.L ( month ) .. " '" .. year , 0.38 , 0.67 , 1.0 );
                            -- If player once left, then this will add the line for it.
                        end
                    end
                break;
                end
            end

            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip:Show();
        elseif GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText:IsMouseOver(1,-1,-1,1) ~= true and ( GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip:IsVisible() or GRM_MemberDetailServerNameToolTip:IsVisible() ) then
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailJoinDateToolTip:Hide();
            GRM_MemberDetailServerNameToolTip:Hide();
        end

        -- Mouseover name shows full server... useful on merged realms.
        if not GRM_UI.GRM_altDropDownOptions:IsVisible() and not StaticPopup1:IsVisible() and GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
            -- Get Class Color
            local textR, textG, textB = GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:GetTextColor();

            -- Build the tooltip
            GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_MemberDetailMetaData.GRM_JoinDateText , "ANCHOR_CURSOR" );
            GRM_MemberDetailServerNameToolTip:AddLine ( name , textR , textG , textB );

            GRM_MemberDetailServerNameToolTip:Show();
        else
            GRM_MemberDetailServerNameToolTip:Hide();
        end

        if not GRM_UI.GRM_MemberDetailMetaData.GRM_DateSubmitButton:IsVisible() and not GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNJDSyncTooltip:IsVisible() and not GRM_UI.GRM_MemberDetailMetaData.GRM_SyncJoinDateSideFrame:IsVisible() and GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailDateJoinedTitleTxt:IsMouseOver ( 1 , -1 , -1 , 1 ) and GRM.PlayerOrAltHasJD ( name ) then
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNJDSyncTooltip:SetOwner ( GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailDateJoinedTitleTxt , "ANCHOR_CURSOR" );
            if GRM.IsAltJoinDatesSynced ( name ) then
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNJDSyncTooltip:AddLine( GRM.L ( "Join Date of All Alts is Currently Synced" ) );
            else
                GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNJDSyncTooltip:AddLine( GRM.L ( "|CFFE6CC7FRight-Click|r to Sync Join Date with Alts" ) );
            end
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNJDSyncTooltip:Show();
        elseif not GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailDateJoinedTitleTxt:IsMouseOver ( 1 , -1 , -1 , 1 ) and GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNJDSyncTooltip:IsVisible() then
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNJDSyncTooltip:Hide();
        end

        -- Mouseover on Alt Names
        if GRM_UI.GRM_CoreAltFrame.GRM_AltName1:IsVisible() or ( GRM_AltAdded1 ~= nil and GRM_AltAdded1:IsVisible() ) and not StaticPopup1:IsVisible() and not GRM_UI.GRM_altDropDownOptions:IsVisible() then
            for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then   --- Player Found in MetaData Logs
                    local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];

                        -- for regular frames
                        if #listOfAlts <= 12 then
                            local numAlt = 0;
                            if GRM_UI.GRM_CoreAltFrame.GRM_AltName1:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName1:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 1;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName1 , "ANCHOR_CURSOR" );
                            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName2:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName2:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 2;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName2 , "ANCHOR_CURSOR" );
                            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName3:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName3:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 3;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName3 , "ANCHOR_CURSOR" );
                            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName4:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName4:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 4;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName4 , "ANCHOR_CURSOR" );
                            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName5:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName5:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 5;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName5 , "ANCHOR_CURSOR" );
                            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName6:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName6:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 6;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName6 , "ANCHOR_CURSOR" );
                            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName7:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName7:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 7;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName7 , "ANCHOR_CURSOR" );
                            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName8:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName8:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 8;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName8 , "ANCHOR_CURSOR" );
                            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName9:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName9:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 9;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName9 , "ANCHOR_CURSOR" );
                            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName10:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName10:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 10;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName10 , "ANCHOR_CURSOR" );
                            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName11:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName11:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 11;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName11 , "ANCHOR_CURSOR" );
                            elseif GRM_UI.GRM_CoreAltFrame.GRM_AltName12:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_AltName12:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                numAlt = numAlt + 12;
                                GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_AltName12 , "ANCHOR_CURSOR" );
                            end

                            if numAlt > 0 then
                                GRM_AddonGlobals.tempAltName = listOfAlts[numAlt][1];
                                GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[numAlt][1] , listOfAlts[numAlt][2] , listOfAlts[numAlt][3] , listOfAlts[numAlt][4] );
                                GRM_MemberDetailServerNameToolTip:Show();
                            elseif not GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                GRM_MemberDetailServerNameToolTip:Hide();
                            end

                        else
                            local isOver = false;
                            if GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons ~= nil then
                                for i = 1 , #GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons do
                                    if GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons[i][1]:IsVisible() and GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons[i][1]:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                        GRM_AddonGlobals.tempAltName = listOfAlts[i][1];
                                        GRM_MemberDetailServerNameToolTip:SetOwner ( GRM_UI.GRM_CoreAltFrame.GRM_CoreAltScrollChildFrame.allFrameButtons[i][1] , "ANCHOR_CURSOR" );
                                        GRM_MemberDetailServerNameToolTip:AddLine ( listOfAlts[i][1] , listOfAlts[i][2] , listOfAlts[i][3] , listOfAlts[i][4] );
                                        isOver = true;
                                        break;
                                    end
                                end
                            end

                            if isOver and not GRM_UI.GRM_altDropDownOptions:IsVisible() then
                                GRM_MemberDetailServerNameToolTip:Show();
                            elseif GRM_UI.GRM_altDropDownOptions:IsVisible() and not GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
                                GRM_MemberDetailServerNameToolTip:Hide();
                            end
                        end

                    break;
                end
            end
        elseif not GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNameText:IsMouseOver ( 1 , -1 , -1 , 1 ) then
            GRM_MemberDetailServerNameToolTip:Hide();
        end

        -- Player status notification to let people know they can edit it.
        if GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus:IsMouseOver ( 1 , -1 , -1 , 1 ) and not GRM_UI.GRM_altDropDownOptions:IsVisible() then
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNotifyStatusChangeTooltip:SetOwner ( GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailPlayerStatus , "ANCHOR_CURSOR" );
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNotifyStatusChangeTooltip:AddLine ( "|cFFFFFFFF" .. GRM.L ( "|CFFE6CC7FRight-Click|r to Set Notification of Status Change" ) );

            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNotifyStatusChangeTooltip:Show();
        else
            GRM_UI.GRM_MemberDetailMetaData.GRM_MemberDetailNotifyStatusChangeTooltip:Hide();
        end

        GRM_AddonGlobals.timer2 = 0;
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
        RequestGuildApplicantsList();

        local numApps = GetNumGuildApplicants();
        if numApps > 0 and numApps ~= GRM_AddonGlobals.numPlayersRequestingGuildInv then
            GRM_AddonGlobals.numPlayersRequestingGuildInv = numApps;
            -- Initialize listening (placed here as not all players need listening)
            if not GRM_AddonGlobals.isHyperlinkListenInitialized then
                GRM_AddonGlobals.isHyperlinkListenInitialized = true;
                chat:HookScript ( "OnHyperlinkClick" , function( self , linkData , link , button )
                    if button == "LeftButton" then
                        if string.find ( link , "Guild Recruits") ~= nil then
                            GRM.SlashCommandRecruitWindow();
                        end
                    end                
                end);
            end
            if GuildInfoFrameApplicantsContainer == nil or ( GuildInfoFrameApplicantsContainer ~= nil and not GuildInfoFrameApplicantsContainer:IsVisible() ) then
                if numApps > 1 then
                    chat:AddMessage ( "\n" .. GRM.L ( "GRM:" ) .. " " .. GRM.L ( "{num} Players Have Requested to Join the Guild." , nil , nil , numApps ) .. "\n" .. GRM.L ( "Click Link to Open Recruiting Window:" ) .. "\124cffffff00\124Hquest:0:0\124h[" .. GRM.L ( "Guild Recruits" ) .. "]\124h\124r\n" , 0 , 0.77 , 0.95 , 1 , 1 );
                else
                    chat:AddMessage ( "\n" .. GRM.L ( "GRM:" ) .. " " .. GRM.L ( "A Player Has Requested to Join the Guild." ) .. "\n" .. GRM.L ( "Click Link to Open Recruiting Window:" ) .. "\124cffffff00\124Hquest:0:0\124h[" .. GRM.L ( "Guild Recruits" ) .. "]\124h\124r\n" , 0 , 0.77 , 0.95 , 1 , 1 );
                end
            end
        end
    end
end


-- Method:              GRM.GR_Roster_Click ( self, string )2
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

            if GetCurrentKeyBoardFocus() ~= nil then
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
    chat:AddMessage ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "Scanning for Guild Changes Now. One Moment..." ) , 1.0 , 0.84 , 0 );
    GRM_AddonGlobals.ManualScanEnabled = true;
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
            if #GRM_AddonGlobals.currentAddonUsers == 0 and GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] then
                chat:AddMessage ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "No Players Currently Online to Sync With..." ) , 1.0 , 0.84 , 0 );
            elseif not GRMsync.IsPlayerDataSyncCompatibleWithAnyOnline() then
                chat:AddMessage ( GRM.L ( "GRM:" ) .. GRM.L ( "No Addon Users Currently Compatible for Sync." ) .. "\nCheck the \"Sync Users\" tab to find out why!"  , 1.0 , 0.84 , 0 );
            end
        end);
    else
        print ( GRM.L ( "SYNC is currently not possible! Unable to Sync with guildies when guild chat is restricted." ) );
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
    
    print ( "\n" .. GRM.L ( "Guild Roster Manager" ) .. " " .. GRM.L ( "(Ver:" ) .. " " .. GRM_AddonGlobals.Version .. ")\n\n/grm                     - " .. GRM.L ( "Opens Guild Log Window" ) .. "\n/grm clearall         - " .. GRM.L ( "Resets ALL saved data" ) .. "\n/grm clearguild      - " .. GRM.L ( "Resets saved data only for current guild" ) .. "\n/grm center          - " .. GRM.L ( "Re-centers the Log window" ) .. "\n/grm sync             - " .. GRM.L ( "Triggers manual re-sync if sync is enabled" ) .. "\n/grm scan             - " .. GRM.L ( "Does a one-time manual scan for changes" ) .. "\n/grm ver               - " .. GRM.L ( "Displays current Addon version" ) .. "\n/grm recruit          - " .. GRM.L ( "Opens Guild Recruitment Window" ) .. "\n/grm hardreset     - " .. GRM.L ( "WARNING! complete hard wipe, including settings, as if addon was just installed." ) );
end

-- Method:          GRM.SlashCommandClearAll()
-- What it Does:    Resets all data account wide, as if the addon was just installed, on the click of the button.
-- Purpose:         Useful to purge data in case of corruption or trolling or other misc. reasons.
GRM.SlashCommandClearAll = function()
    GRM_UI.GRM_RosterChangeLogFrame:EnableMouse( false );
    GRM_UI.GRM_RosterChangeLogFrame:SetMovable( false );
    GRM_UI.GRM_RosterConfirmFrameText:SetText( GRM.L ( "Really Clear All Account-Wide Saved Data?" ) );
    GRM_UI.GRM_RosterConfirmYesButtonText:SetText ( GRM.L ( "Yes!" ) );
    GRM_UI.GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( self , button )
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
    GRM_UI.GRM_RosterConfirmYesButton:SetScript ( "OnClick" , function( self , button )
        if button == "LeftButton" then
            GRM.ResetGuildSavedData( GRM_AddonGlobals.guildName );      --Resetting!
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
    GRM.Report ( "\n" .. GRM.L ( "Guild Roster Manager" ) .. "\nVer: " .. GRM_AddonGlobals.Version .. "\n" );
end

-- Method:          GRM.SlashCommandRecruitWindow()
-- What it Does:    It opens up the roster menu to the recruit window.
-- Purpose:         Easy access to recruit window really is all...
GRM.SlashCommandRecruitWindow = function()
    if CanGuildInvite() then
        RequestGuildApplicantsList();
        local numApps = GetNumGuildApplicants();
        if numApps > 0 then
            if GuildFrame == nil then
                GuildMicroButton:Click();
            elseif not GuildFrame:IsVisible() then
                GuildFrame:Show();
            end
            
            GuildFrameTab5:Click();
            GuildInfoFrameTab3:Click();
        else
            chat:AddMessage ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "There are No Current Applicants Requesting to Join the Guild." ) );
        end
    else
        chat:AddMessage ( GRM.L ( "GRM:" ) .. " " .. GRM.L ( "The Applicant List is Unavailable Without Having Invite Privileges." ) );
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
    else
        alreadyReported = true;
        GRM.Report ( GRM.L ( "Invalid Command: Please type '/grm help' for More Info!" ) );
    end
    
    if not inGuild and not alreadyReported then
        GRM.Report ( GRM.L ( "{name} is not currently in a guild. Unable to Proceed!" , GRM.SlimName( GRM_AddonGlobals.addonPlayerName ) ) );
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
        
        GRM_AddonGlobals.UIIsLoaded = true;
        

        -- For determining mouseover on the frames.
        local GRM_CoreUpdateFrame = GRM_CoreUpdateFrame or CreateFrame ( "frame" );
        GRM_CoreUpdateFrame:SetScript ( "OnUpdate" , function ( self , elapsed )
            GRM_AddonGlobals.timer = GRM_AddonGlobals.timer + elapsed;
            if GuildRosterFrame:IsVisible() and GRM_AddonGlobals.timer >= 0.038 then
                GR_RosterFrame();
                GRM_AddonGlobals.timer = 0;
            end
        end);
        
        if GuildFrame:IsVisible() then
            GRM_UI.GRM_RosterChangeLogFrame.GRM_LoadLogButton:Show();
        end

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
    UI_Events:RegisterEvent ( "PLAYER_LOGOUT" );

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
        -- Sync the addon settings on logout!!!
        elseif event == "PLAYER_LOGOUT" then
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][31] then
                GRM.SyncAddonSettings();
            end
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
            
            -- Checking Roster, tracking changes
            GRM.BuildNewRoster();

                -- Prevent from re-scanning changes
            -- On first load, bring up window.
            if GRM_AddonGlobals.OnFirstLoad then

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
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][2] and not GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][28] then
                    GRM_UI.GRM_RosterChangeLogFrame:Show();
                end

                -- To avoid kick spam in the chat, due to the stutter elimination temp delay system
                C_Timer.After ( 45 , function() GRM_AddonGlobals.OnFirstLoadKick = false end);
            end
        end
        GRM_AddonGlobals.currentlyTracking = false;
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][18] then
            GuildRoster();
            C_Timer.After( 10 , GRM.TriggerTrackingCheck ); -- Recursive check every X seconds.
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
    
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][29] then
        local chatEvents = { "CHAT_MSG_GUILD" , "CHAT_MSG_WHISPER" , "CHAT_MSG_GUILD_ACHIEVEMENT" , "CHAT_MSG_PARTY" , "CHAT_MSG_PARTY_LEADER" , "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER" , "CHAT_MSG_INSTANCE_CHAT" , "CHAT_MSG_INSTANCE_CHAT_LEADER" , "CHAT_MSG_OFFICER" }
        for i = 1 , #chatEvents do
            ChatFrame_AddMessageEventFilter ( chatEvents[i] , GRM.AddMainToChat );
        end
    end
    -- Quick Version Check
    if not GRM_AddonGlobals.VersionCheckRegistered then
        GRM.RegisterVersionCheck();
        SendAddonMessage ( "GRMVER" , GRM_AddonGlobals.Version.. "?" .. tostring ( GRM_AddonGlobals.PatchDay ) , "GUILD" );
        GRM_AddonGlobals.VersionCheckRegistered = true;
    end

    -- Determine who is using the addon...
    -- 3 second dely to account for initialization of various variables. Safety cushion.
    C_Timer.After ( 3 , GRM.RegisterGuildAddonUsers );

    -- Build initial frame values not tied to guild roster window
    GRM_UI.MetaDataInitializeUIrosterLog1();
    GRM_UI.MetaDataInitializeUIrosterLog2();

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
            GRM_AddonGlobals.timeDelayValue = 0;
            GRM_AddonGlobals.OnFirstLoad = true;
            GRM_AddonGlobals.OnFirstLoadKick = true;
            GRM_AddonGlobals.guildName = nil;
            GRM_AddonGlobals.trackingTriggered = false;
            GRM_AddonGlobals.DelayedAtLeastOnce = true;                     -- Keeping it true as there does not need to be a delay at this point.
            UI_Events:UnregisterEvent ( "GUILD_EVENT_LOG_UPDATE" );         -- This prevents it from doing an unnecessary tracking call if not in guild.
            if GRMsync.MessageTracking ~= nil then
                GRMsync.MessageTracking:UnregisterAllEvents();
            end
            GRMsync.ResetDefaultValuesOnSyncReEnable();                     -- Need to reset sync algorithm too!
            GRM_UI.GRM_RosterChangeLogFrame:Hide();
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
        --For UI allignment controls - use invis string to match widths and so on.
        UI_Events.InvisFontStringWidthCheck = UI_Events:CreateFontString ( "InvisFontStringWidthCheck" );
        UI_Events.InvisFontStringWidthCheck:SetFont ( GRM_AddonGlobals.FontChoice , GRM_AddonGlobals.FontModifier + 11 ); 

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
        -- EPGP uses officer notes and is an incredibly popular addon. This now ensures auto-adding not will default to PUBLIC note rather than officer.
        if GRM_AddonGlobals.setPID ~= 0 and IsAddOnLoaded("epgp") then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][20] = false;
        end

        -- This addon uses a lot of backend comms, so it is prudent to do a bit more throttling down.
        if IsAddOnLoaded("GreenWall") and IsInGuild() then
            GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][24] = math.floor ( GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][24] * 0.75 );
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

    -- Archive and export ability (export roster list, export log, export ... )
    -- Add main name to public or officer note...

    -- Store notes for X number of days for restore...

    -- Make list of all players that LEFT the guild... Purge the list except for banned?

    -- Custom Messaging - stored messages to send to guild chat. Customizable?

    -- Include ilvl, spec

    -- Guild Officer Notepad... Communal notepad anyone can edit...

    -- MNouseover option on player name to show main

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

    -- Guild toolbox -- things like Inquiry where you can add a name and say "What happened to this player?" and the addon will attempt to find out through checking their main, their former alt list (add to friend/remove), check online...

    -- INTERESTING GUILD STATISTICS
        -- Like number of legendaries collected this week
        -- Notable achievements, like Prestige advancements, rare achievements, etc.
        -- If players have obtained recent impressive titles (100k or 250k kills, battlemaster)
        -- Total number of guild battlemasters
        -- Total number of guildies with certain achievements
        -- Is it possible to identify player's achievements without being close to them?
        -- Notable high ilvl notifications with adjustable threshold to trigger it, for editable updating for expansion update flexibility
        -- Analysis of close-to-get achievements?
        -- useful tools only guild leader can see'... Like gkick all, or something.
    -- Ability to ex port data to useful format./
    -- Ability to choose how you would like your timestamps to look.
    -- Sort guild roster by "Time in guild" - possible in built-in UI? - need to complete "Total time in the guild".

    -------------------------------------
    ----- KNOWN BUGS --------------------
    ------------------------------------

    -- Issue a patch fix
    -- Rank namechange is faulty when no one is currently that rank... or when someone is removed from that rank that it becomes no rank.
    -- Namechange not finding it occasionally... needs stress testing
    -- Ban list sync occasionally wonky, like it syncs partial list, then you sync again and you get the rest... or only the person sharing the data with you syncs to you, but it doesn't pass through a mediator if more than 2 online
    -- Double reporting likely due to stutter elimination delay. Roster needs to be used immediately. More stop checks need to be secured inthe Checking for Changes to ensure it doesn't collect new data whilst holding on to a copy of the guild form the server that might be 1-10 seconds older than current.
    -- Inactive return does not report if < 1hr, only once they have been offline for 1hr or more...
    -- If a player has been offline for 5 years Blizz opens up their name by changing the last few characters... name-change triggers. If multiple name-changes, it won't know which is which
    -- Sync restrictions on data is not working.,.. I was too low of a rank, yet I still got the updates...
    -- Ban list only syncs if it is coming from the sender and the leader updates themselves... what am I missing here? Maybe if they are sending me incorrect info, I should shoot back to them to update it properly...
    -- Potential issue when comparing players that left and are returning... GuildControlGetNumRanks() - if they were a rank that is say 9, but there is only 7 ranks in the guild now, what happens?
    -- If a player goes from not being able to read officer note, to having access, it spams you. That should be known...
    -- Note change spam if you have curse words in note/officer notes and Profanity filter on. Just disable profanity filter for now until I get around to it.
    -- Namechange sometimes is "funny"
    
    -------------------------------------
    ----- BUSY work ---------------
    -------------------------------------

    -- Ban list the rank for a custom added player should be "Unknown" option
    -- Escape key on officer/public notes exiting full window when it should just exit editbox.

    -- Create an option to display the users officer and public note when they gquit (like it displays their alts)
    -- * In "Log". Clickable character names that open the roster for the character.
    -- LOG FUNCTIONS - search, export, archive... endless scroll, but compartmentalize the load to every 200 lines or so...

    -- Create a check to see who is online currently on the guild recruit window... (add them to friends list, see if online, remove from friends list)
    -- Ability to disable showing full name (possibly per channel?)
    -- Create method for "IsMergedRealm" by checking the guild log. If server names are included, it is a merged realm player is on.
    -- GRM.IsValidName -- get ASCII byte values for the other 4 regions' Blizz selected fonts.
    -- Sync the history of promotions and demotions as well.
    -- Potentially have it say "currently syncing" next to player's name... on addon users window

    -- GetHoursSinceLastOnline() is not truly exact as it does not account for leap year and specific month counts depending on the day and so on. It just averages all months to be an avg of 730hrs each Mostly accurate, but if leap year it could be a day off.
    -- Upon changing format option -- addon scans a bunch of officer noters, determines formats are different... Asks player if they wish to change officer note format for all automatically.
    -- Modify Timestamp format ( only modify on the display of the timestamp )

    -- BIRTHDAYS
    -- Custom Reminders
    -- Guild Namechange needs to be tested.

    -- If Mature language filter is on
    -- 4 letter word == !@#$ !@#$%^ or ^&*!  
  
    -- CHANGELOG:
        -- Noticed in the log there was no timestamp when promotions/demotions happen whislt online live.
        -- Fixed a UI bug where if the player had the option "Show on Logon" unchecked, the UI would bug out on the window.
        -- Log will now state the correct date the player joined the guild, not just the current date it noticed the change. It will default to today's date if invite is not found on the official log.
        -- The addon was previously setting join/promo dates to the current date on login, and then tagging that as most current info. This is problematic if you have people login after months and check changes and then make lots of changes as a result to the data, inadvertantly. Auto-tagged dates are no longer given priority in the sync que.
        -- Player now no longer shows <M> on their own alts
        -- Sync Settings option should now be properly disabled by default, not enabled. This caused people to logon to alts then have their alt info immediately mess-up their new player info.
        -- Right click on the minimap, if you are not in the guild, should no longer error
        -- Hide the minimap with ctrl-shift-Click
        -- Minimap was not saving its position in-between sessions in some circumstances. This is now fixed.
        -- Addon window was not loading on logon... Fixed!
        -- On logon, the kicked/left data was still spamming chat. This is resolved now.
        -- Plugin for addonskins / ElvUI cleaned up a little more, some overlapping txt.
        -- Sync of the settings among alts now keeps the minimap button placement and visibility unique to each player, but all other settings sync.
        -- namechange now properly class colorizes the names.
        -- On logon, on a scan of changes, it now sorts the names of new guildies where we know who invited them (found in the log) and groups them.
        -- Exact timestamps to the Hour, if found in the log, of when a player joins/leaves/gkicked/promoted/demoted now.
        -- Accurate timestamp reflection both to the officer/public note, and to the display. Before, it would just timestamp the current day it found the change. This might be innacurate if a player hasn't logged in a few days. Now it will parse the log and determine the exact day/hr it occurred. If it is not found in the log because it has been significantly too long, the displayed date will show the current day, but the sync information will be emptied so that any other player with more current information you will sync their data.
        -- The core GRM addon window no longer takes preference on the ESCAPE key if you are on the player info window...


-- /run local t=GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];for i=2,#t do if t[i][1]=="Resri-Fizzcrank" then table.remove(t,i);end;end;GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ]=t

-- /run local t=GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ];for i=2,#t do if t[i][1]=="Pullupskrrt-Aggramar" then table.remove(t,i);end;end;GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ]=t;