-- For Sync controls!
-- Author: Arkaan... aka "TheGenomeWhisperer"


-- To hold all Sync Methods/Functions
GRMsync = {};


-- All Sync Globals
GRMsyncGlobals = {};

GRMsyncGlobals.channelName = "GUILD";
GRMsyncGlobals.DatabaseLoaded = false;
GRMsyncGlobals.RulesSet = false;
GRMsyncGlobals.LeadSyncProcessing = false;
GRMsyncGlobals.SyncOK = true;
GRMsyncGlobals.Locale = GetLocale();

-- Establishing leadership controls.
GRMsyncGlobals.IsLeaderRequested = false;
GRMsyncGlobals.LeadershipEstablished = false;
GRMsyncGlobals.IsElectedLeader = false;
GRMsyncGlobals.DesignatedLeader = "";
GRMsyncGlobals.ElectTimeOnlineTable = {};
GRMsyncGlobals.LeaderShipChanged = false;
GRMsyncGlobals.ElectionProcessing = false;

-- For players queing to by sync'd to share data!
-- If a player requests a leader sync, they are added to this que. This is so the leader can just add them to que
-- in the case that they may be syncing with another player already. Depending on the amount of data transferring, and the size of the guild, sync can take anywhere from 1-5 seconds
-- Based on server response time, per person. At least, initially. Live Sync updates happen near instantly.
GRMsyncGlobals.SyncQue = {};

-- Collected Tables of Data when received from the player
GRMsyncGlobals.JDReceivedTemp = {};
GRMsyncGlobals.PDReceivedTemp = {};
GRMsyncGlobals.BanReceivedTemp = {};
GRMsyncGlobals.AltReceivedTemp = {};
GRMsyncGlobals.AltRemReceivedTemp = {};
GRMsyncGlobals.MainReceivedTemp = {};

-- Tables of the changes -- Leader will collect and store them here from all players before broadcasting the changes out, and then resetting them.
-- By compiling all changes first, and THEN checking, it saves an insane amount of resources rather than passing on every new piece received.
GRMsyncGlobals.JDChanges = {};
GRMsyncGlobals.PDChanges = {};
GRMsyncGlobals.BanChanges = {};
GRMsyncGlobals.AltAddChanges = {};
GRMsyncGlobals.AltRemoveChanges = {};
GRMsyncGlobals.AltMainChanges = {};

-- SYNC START AND STOP CONTROLS
-- These are used to verify the expected number of packets of info arrived.
GRMsyncGlobals.ReceivingData = false;
GRMsyncGlobals.NumPlayerDataExpected = 0;

-- SYNC PROCEDURAL ORDERING CONTROLS PER SYNC
GRMsyncGlobals.CurrentSyncPlayer = "";
GRMsyncGlobals.currentlySyncing = false;
GRMsyncGlobals.JDSyncComplete = false;
GRMsyncGlobals.SyncCount = 2;               -- 2 because index begins at 2 in the table, as index 1 is the guild name
GRMsyncGlobals.SyncCount2 = 2;              -- For alt add and remove
GRMsyncGlobals.SyncCount3 = 1;              -- Controlling the number alts sync'd, for players with LARGE numbers of alts.
GRMsyncGlobals.SyncCount4 = 1;              -- same for 3-6
GRMsyncGlobals.SyncCount5 = 1;              
GRMsyncGlobals.SyncCount6 = 1;
GRMsyncGlobals.syncTempDelay = false;
GRMsyncGlobals.syncTempDelay2 = false;
GRMsyncGlobals.finalSyncDataCount = 1;
GRMsyncGlobals.finalSyncProgress = { false , false , false , false , false , false };        -- on eahc of the tables, if submitted fully
GRMsyncGlobals.syncCap = 50;

-- For sync control measures on player details, so leader can be determined on who has been online the longest. In other words, for the leadership selecting algorithm
-- when determining the tiers for syncing, it is ideal to select the leader who has been online the longest, as they most-likely have encountered the most current amount of information.
GRMsyncGlobals.timeAtLogin = 0;           -- A simple new time() - timeAtLogin will determine the exact amount of time that has passed since login.


-- Prefixes for tagging info as it is sent and picked up across server channel to other players in guild.
GRMsyncGlobals.listOfPrefixes = { 

    -- syncing prefixes for LIVE syncing
    "GRM_JD",               -- Join Date
    "GRM_PD",               -- Recent Promo Date
    "GRM_AC",               -- Added to Calendar (triggers other players to remove from their que);
    "GRM_BAN",              -- For banning players and alts before full kick
    "GRM_ADDALT",           -- If an alt is tagged
    "GRM_RMVALT",           -- alt is removed
    "GRM_MAIN",             -- Player designated as "main"
    "GRM_RMVMAIN",          -- Player demoted from main.
    
    -- Syncing prefixes for retroactive syncing algorithm in establishing leadership chain of command in sync tree
    "GRM_WHOISLEADER",
    "GRM_IAMLEADER",
    "GRM_ELECT",
    "GRM_TIMEONLINE",       
    "GRM_NEWLEADER",

    -- With leadership established, Actual sharing algorithms now.
    -- START AND STOP CODES IN MESSAGE RECEIVING DECLARING START AND END OF DATABASE BLOCK
    "GRM_START",
    "GRM_STOP",
    "GRM_STOPALTREM",

    -- Non leaders request sync to leader as needed
    "GRM_REQUESTSYNC",

    -- Leader confirms request, callsback with confirmation to begin transmission of data across Blizz's server channel for addon sync.
    "GRM_REQJDDATA",
    "GRM_REQPDDATA",
    "GRM_REQBANDATA",
    "GRM_REQALTDATA",
    "GRM_REQMAIN",

    -- Message to the leader with the data!
    "GRM_JDSYNC",
    "GRM_PDSYNC",
    "GRM_BANSYNC",
    "GRM_ALTADDSYNC",
    "GRM_ALTREMSYNC",
    "GRM_MAINSYNC",
    
    -- FOR FINAL UPDATE REPORTING - NECESSARY TO SUBMIT CHANGES WITHOUT GETTING SPAMMY WITH CHANGE MESSAGES.
    -- In other words, on this callback, the change is submitted as a "LIVE" change, however it is not broadcast live lest a person get a TON of spam on login sync.
    -- This will be used as tag to silence message spam for sync updates, unlike Live updates where player is given option to enable notification.
    -- Essentially, your are sending and receiving data only from the designated leader rather than each person sending data back and forth to each other. This is the far more efficient way
    -- to accomplish data sync without wasting resources, causing odd sync bugs, and getting server spammy behind the scenes. We are talking about thousands of pieces of data vs hundreds of thousands.
    -- HUGE savings to do it by behind-the-scenes leadership sync. Also a bit less-complicated to code because the elected leader acts like a centralized lookup table database, but with dynamic sync capabilities.
    "GRM_JDSYNCUP",
    "GRM_PDSYNCUP",
    "GRM_BANSYNCUP",
    "GRM_ALTSYNCUP",
    "GRM_REMSYNCUP",
    "GRM_MAINSYNCUP",

    -- To announce that final sync with all guildies online is complete, and the most current data has been pushed to all
    "GRM_COMPLETE"
};

-- Chat/print properties.
local chat = DEFAULT_CHAT_FRAME;


-- Method:          GRMsync.ResetDefaultValuesOnSyncReEnable()
-- What it Does:    Sets values to default, as if just logging back in.
-- Purpose:         For sync to properly work, default startup values need to be reset.
GRMsync.ResetDefaultValuesOnSyncReEnable = function()
    GRMsyncGlobals.DatabaseLoaded = false;
    GRMsyncGlobals.RulesSet = false;
    GRMsyncGlobals.IsLeaderRequested = false;
    GRMsyncGlobals.LeadershipEstablished = false;
    GRMsyncGlobals.IsElectedLeader = false;
    GRMsyncGlobals.DesignatedLeader = "";
    GRMsyncGlobals.ElectTimeOnlineTable = nil;
    GRMsyncGlobals.ElectTimeOnlineTable = {};
    GRMsyncGlobals.currentlySyncing = false;
end

-- Resetting after broadcasting the changes.
GRMsync.ResetReportTables = function()
    GRMsyncGlobals.JDChanges = {};
    GRMsyncGlobals.PDChanges = {};
    GRMsyncGlobals.BanChanges = {};
    GRMsyncGlobals.AltAddChanges = {};
    GRMsyncGlobals.AltRemoveChanges = {};
    GRMsyncGlobals.AltMainChanges = {};
end

-- In case of mid-cycling reset, this resets all the temp tables.
GRMsync.ResetTempTables = function()
    GRMsyncGlobals.JDReceivedTemp = {};
    GRMsyncGlobals.PDReceivedTemp = {};
    GRMsyncGlobals.BanReceivedTemp = {};
    GRMsyncGlobals.AltReceivedTemp = {};
    GRMsyncGlobals.AltRemReceivedTemp = {};
    GRMsyncGlobals.MainReceivedTemp = {};
end

--------------------------
----- FUNCTIONS ----------
--------------------------

-- Method:          GRMsync.WaitTilDatabaseLoads()
-- What it Does:    Sets the player's guild ranking by index of rank
-- Purpose:         This is important for addon talk to not get info from ranks too low.
GRMsync.WaitTilDatabaseLoads = function()
    if IsInGuild() and ( GRM_AddonGlobals.saveGID == 0 or GRM_AddonGlobals.FID == 0 or GRM_AddonGlobals.setPID == 0 ) then
        C_Timer.After ( 5 , GRMsync.WaitTilDatabaseLoads );
        return
    else
        GRMsyncGlobals.DatabaseLoaded = true;
    end
    GRMsync.BuildSyncNetwork();
end

-- method:          GRMsync.SlimDate ( string )
-- What it Does:    Returns the string with the hour/min taken off the end.
-- Purpose:         For SYNCing, the only important piece of info on the timestamp is the date, and comparing it is the same. I don't want sync to trigger over and over
--                  Because the hour/min is off on the sync when that is unimportant info, at least in this context.
GRMsync.SlimDate  = function ( date )
    if date == "" then
        return date;
    else
        return string.sub ( date , 1 , string.find( date , " " , -8 ) -1 );
    end
end


-- Method:          GRMsync.SyncName ( string , string )
-- What it Does:    Adds the white spaces in comm name to reflect real player-server name
-- Purpose:         Unable to sync otherwise, on servers that have more than 1 word in the name
GRMsync.SyncName = function ( name , lang )
    local result = "";
    if string.find ( name , " " ) == nil then
        -- For English localization!
        if lang == "enUS" or lang == "enGB" then
            local rawServer = string.sub ( name , string.find ( name , "-" ) + 1 );
            local count = 0;
            local char = "";
            for i = 1 , #rawServer do

                -- parsing 1 letter at a time!
                char = string.sub ( rawServer , i , i );
                if char ~= "'" then
                    if tonumber( char ) == nil then 
                        if char == string.upper ( char ) then               -- We found a capital letter!
                            count = count + 1;
                            -- Likely Area52 server, let's add a space before 
                            if count > 1 then
                                if string.sub ( rawServer , i - 1 , i - 1 ) ~= " " and string.sub ( rawServer , i - 1 , i - 1 ) ~= "'" then
                                    rawServer = string.sub ( rawServer , 1 , i - 1 ) .. " " .. string.sub ( rawServer , i );
                                end
                            end
                        end
                    else
                        -- Likely Area52 server, let's add a space before 
                        if string.sub ( rawServer , i - 1 , i - 1 ) ~= " " and tonumber ( string.sub ( rawServer , i - 1 , i - 1 ) ) == nil then
                            count = count + 1;
                            rawServer = string.sub ( rawServer , 1 , i - 1 ) .. " " .. string.sub ( rawServer , i );
                        end
                    end
                end
            end
            result = string.sub ( name , 1 , string.find ( name , "-" ) ) .. rawServer;
        -- For future localization issues!!!



        end
    else
        result = name
    end
    return result;
end

-------------------------------
---- MESSAGE SENDING ----------
-------------------------------

-- Method:          GRMsync.SendMessage ( string , string , string , int )
-- What it Does:    Sends an invisible message over a specified channel that a player cannot see, but an addon can read.
-- Purpose:         Necessary function for cross-talk between players using addon.
GRMsync.SendMessage = function ( prefix , msg , type , typeID )
    if GRMsyncGlobals.SyncOK then
        SendAddonMessage ( prefix , msg , type , typeID );
    end
end



--------------------------------
---- LIVE MESSAGE SCRIPTS ------
--------------------------------

-- Method:          GRMsync.CheckJoinDataChange ( string )
-- What it Does:    Parses the details of the message to be usable, and then uses that info to see if it is different than current info, and if it is, then enacts changes.
-- Purpose:         To sync player join dates properly.
GRMsync.CheckJoinDateChange = function( msg , sender , prefix )
    -- To avoid spamminess
    local isSyncUpdate = false;
    if prefix == "GRM_JDSYNCUP" then
        isSyncUpdate = true;
    end

    local playerName = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local joinDate = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local finalTStamp = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local finalEpochStamp = tonumber ( string.sub ( msg , string.find ( msg , "?" ) + 1 ) );

    for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if playerName == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] then
            -- Let's see if there was a change
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][2] ~= finalTStamp then
                -- do a null check... will be same as button text
                if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20][ #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] ] ~= nil then
                    table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] );  -- Removing previous instance to replace
                    table.remove ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][21] , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][21] );
                end
                table.insert( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][20] , finalTStamp );     -- oldJoinDate
                table.insert( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][21] , finalEpochStamp ) ;   -- oldJoinDateMeta
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][2] = finalTStamp;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][3] = finalEpochStamp;
               
               -- For sync
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][35][1] = finalTStamp;
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][35][2] = finalEpochStamp;

                -- Update timestamp to officer note.
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][7] and CanEditOfficerNote() then
                    for h = 1 , GRM.GetNumGuildies() do
                        local guildieName ,_,_,_,_,_,_, oNote = GetGuildRosterInfo( h );
                        if guildieName == name and oNote == "" then
                            GuildRosterSetOfficerNote ( h , joinDate );
                            break;
                        end
                    end
                end

                if GRM_MemberDetailMetaData:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == playerName then
                    GRM_noteFontString2:SetText ( joinDate );
                    GRM_PlayerOfficerNoteEditBox:SetText ( joinDate );
                end
                -- Gotta update the event tracker date too!
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][22][1][2] = string.sub ( joinDate , 9 ); -- Remember, position 1 of the events tracker for anniversary tracking is always position 1 of the array, with date being pos 1 of table too.
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][22][1][3] = false;  -- Gotta Reset the "reported already" boolean!
                GRM.RemoveFromCalendarQue ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][22][1][1] );

                -- Report the updates!
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] and not isSyncUpdate then
                    chat:AddMessage ( GRM.SlimName ( sender ) .. " updated " .. GRM.SlimName ( playerName ) .. "'s Join Date." , 1.0 , 0.84 , 0 );
                end
                
                if GRM_MemberDetailMetaData:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == playerName then
                     GRM_JoinDateText:SetText ( string.sub ( joinDate , 9 ) );
                     if GRM_MemberDetailJoinDateButton:IsVisible() then
                        GRM_MemberDetailJoinDateButton:Hide();                
                    end
                    GRM_JoinDateText:Show();
                end
                
            end
            break;
        end
    end
end

-- Method           GRMsync.CheckPromotionDateChange ( string , string )
-- What it Does:    Checks if received info is different than current, then updates it
-- Purpose:         Data sharing between guildies carrying the addon
GRMsync.CheckPromotionDateChange = function ( msg , sender , prefix )
    -- To avoid spamminess
    local isSyncUpdate = false;
    if prefix == "GRM_PDSYNCUP" then
        isSyncUpdate = true;
    end

    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local promotionDate = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local promotionDateTimestamp = tonumber ( string.sub ( msg , string.find ( msg , "?" ) + 1 ) );

    for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == name then
            
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] = string.sub ( promotionDate , 9 );
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25][#GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][25]][2] = string.sub ( promotionDate , 9 );
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][13] = GRM.TimeStampToEpoch ( promotionDate );

            -- For SYNC
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][1] = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12];
                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][36][2] = promotionDateTimestamp;

            -- Report the updates!
            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] and not isSyncUpdate then
                chat:AddMessage ( GRM.SlimName ( sender ) .. " updated " .. GRM.SlimName ( name ) .. "'s Promotion Date." , 1.0 , 0.84 , 0 );
            end

            -- If the player is on the same frames, update them too!
            if GRM_MemberDetailMetaData:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == name then
                if GRM_SetPromoDateButton:IsVisible() then
                    GRM_SetPromoDateButton:Hide();
                end

                if GRM_AddonGlobals.rankIndex > GRM_AddonGlobals.playerIndex then
                    GRM_MemberDetailRankDateTxt:SetPoint ( "TOP" , 0 , -80 ); -- slightly varied positioning due to drop down window or not.
                else
                    GRM_MemberDetailRankDateTxt:SetPoint ( "TOP" , 0 , -68 );
                end
                GRM_MemberDetailRankDateTxt:SetTextColor ( 1 , 1 , 1 , 1.0 );
                GRM_MemberDetailRankDateTxt:SetText ( "Promoted: " .. GRM.Trim ( string.sub ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][12] , 1 , 10) ) );
                GRM_MemberDetailRankDateTxt:Show();
            end
            break;
        end
    end
end

-- Method:          GRMsync.EventAddedToCalendarCheck ( string , string )
-- What it Does:    Checks to see if player has the event already in que. If it is, then remove it.
-- Purpose:         Cleanliness. If it is removed from one person's list, it is removed from all!
GRMsync.EventAddedToCalendarCheck = function ( msg , sender )
    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local title = string.sub ( msg , string.find ( msg , "?" ) + 1 );


    if GRM.IsOnAnnouncementList ( name , title ) then
        -- Remove from the list
        GRM.RemoveFromCalendarQue ( name , title );

        -- Refresh the frame!
        GRM.RefreshAddEventFrame();
        -- Send chat update info.
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] then
            chat:AddMessage ( "\"" .. title .. "\" event added to the calendar by " .. GRM.SlimName ( sender ) , 1.0 , 0.84 , 0 );
        end
    end
end

-------------------------------------------
-------- ALT UPDATE COMMS -----------------
-------------------------------------------


-- Method:          GRMsync.CheckAddAltChange ( string , string , string )
-- What it Does:    Adds the alt as well to your list, if it is not already added
-- Purpose:         Additional chcecks required to avoid message spamminess, but basically to sync alt lists on adding.
GRMsync.CheckAddAltChange = function ( msg , sender , prefix )
    -- To avoid spamminess
    local isSyncUpdate = false;
    if prefix == "GRM_ALTSYNCUP" then
        isSyncUpdate = true;
    end

    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local altName = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local altNameEpochTime = tonumber ( string.sub ( msg , string.find ( msg , "?" ) + 1 ) );

    if name ~= altName then         -- To avoid spam message to all players...
       
        -- Verify player is not already on someone else's list...
        local isFound = false;
        local isFound2 = false;
        for s = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][s][1] == altName then
                
                if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][s][11] > 0 then
                    local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][s][11];
            
                    for m = 1 , #listOfAlts do                                              -- Let's quickly verify that this is not a repeat alt add.
                        if listOfAlts[m][1] == name then                              -- Is that supposed to be "altName" ??
                            isFound = true;
                            break;
                        end
                    end
                else
                    for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == name then
                            local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][11];
                            if #listOfAlts > 0 then                                                                 -- There is more than 1 alt for new alt to be added to
                                for i = 1 , #listOfAlts do                                                          -- Cycle through previously known alt names to add new on each, one by one.
                                    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                             -- Need to now cycle through all toons in the guild to set the alt
                                        if listOfAlts[i][1] == GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] then       -- name on current focus altList found in the metadata!
                                            -- Now, make sure it is not a repeat add!
                                            
                                            for m = 1 , #listOfAlts do                                              -- Let's quickly verify that this is not a repeat alt add.
                                                if listOfAlts[m][1] == altName then
                                                    isFound2 = true;
                                                    break;
                                                end
                                            end
                                            break;
                                        end
                                    end
                                    if isFound2 then
                                        break;
                                    end
                                end
                            end

                            break;
                        end
                    end
                end
                break;
            end
        end

        if not isFound and not isFound2 then
            if isSyncUpdate then
                GRM.AddAlt ( name , altName , GRM_AddonGlobals.guildName , true , altNameEpochTime );
            else
                GRM.AddAlt ( name , altName , GRM_AddonGlobals.guildName , false , 0 );
            end

            if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] and not isSyncUpdate then
                chat:AddMessage ( GRM.SlimName ( sender ) .. " updated " .. GRM.SlimName ( name ) .. "'s list of Alts." , 1.0 , 0.84 , 0 );
            end
        end
    end
end


-- Method:          GRMsync.CheckRemoveAltChange ( string , string , string )
-- What it Does:    Syncs the removal of an alt between all ONLINE players
-- Purpose:         Sync data between online players.
GRMsync.CheckRemoveAltChange = function ( msg , sender , prefix )
    -- To avoid spamminess
    local isSyncUpdate = false;
    if prefix == "GRM_REMSYNCUP" then
        isSyncUpdate = true;
    end

    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local altName = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local altChangeTimeStamp = tonumber ( string.sub ( msg , string.find ( msg , "?" ) + 1 ) );
    local count = 0;
    local index = 0;

    -- Checking if alt is to be removed... establishing number of alts.
    for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == name then
            count = #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11];
            index = i;
            break;
        end
    end
    
    if isSyncUpdate then
        GRM.RemoveAlt ( name , altName , GRM_AddonGlobals.guildName , true , altChangeTimeStamp );
    else
        GRM.RemoveAlt ( name , altName , GRM_AddonGlobals.guildName , false , 0 );
    end
    
    
    if GRM_MemberDetailMetaData:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == altName then       -- If the alt being removed is being dumped from the list of alts, but the Sync person is on that frame...
        -- if main, we will hide this.
        GRM_MemberDetailMainText:Hide();

        -- Now, let's hide all the alts
        for i = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] == altName then
                GRM.PopulateAltFrames ( i );
                break;
            end
        end
    end

    -- if alts are ZERO, it implies the person is going 1 to zero and this player was not sync'd with them in count. If
    -- alts are less, then you are ensuring that one was actually removed.
    if count == 0 or count > #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][index][11] then
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] and not isSyncUpdate then
            chat:AddMessage ( GRM.SlimName ( sender ) .. " removed " .. GRM.SlimName ( altName ) .. " from " .. GRM.SlimName ( name ) .. "'s list of Alts." , 1.0 , 0.84 , 0 );
        end
    end
end


-- Method:          GRMsync.CheckAltMainChange ( string , string )
-- What it Does:    Syncs Main selection control between players
-- Purpose:         Sync data between players LIVE
GRMsync.CheckAltMainChange = function ( msg , sender )
    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local mainName = string.sub ( msg , string.find ( msg , "?" ) + 1 );

    GRM.SetMain ( name , mainName , GRM_AddonGlobals.guildName , false , 0 );

    -- We need to add the timestamps our selves as well! In the main program, the timestamps are only triggered on manually clicking and adding/removing
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == mainName then
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][39] = time();
            break;
        end
    end

    -- Need to ensure "main" tag populates correctly.
    if GRM_MemberDetailMetaData:IsVisible() then
        if not GRM_MemberDetailMainText:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == mainName then
            GRM_MemberDetailMainText:Show();
        elseif GRM_MemberDetailMainText:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) ~= mainName then
            GRM_MemberDetailMainText:Hide();
        end
    end

    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] then
        chat:AddMessage ( GRM.SlimName ( sender ) .. " set " .. GRM.SlimName ( mainName ) .. " to be 'Main'" , 1.0 , 0.84 , 0 );
    end
end


-- Method:          GRMsync.CheckMainSyncChange ( string )
-- What it Does:    Syncs the MAIN status among all online guildies who have addon installed and are proper rank
-- Purpose:         Keep player MAINS sync'd properly!
GRMsync.CheckMainSyncChange = function ( msg )
    local mainName = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local mainStatus = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local mainChangeTimestamp = tonumber ( string.sub ( msg , string.find ( msg , "?" ) + 1 ) );

    if mainStatus == "true" then
        -- Set the player as Main
        GRM.SetMain ( mainName , mainName , GRM_AddonGlobals.guildName , true , mainChangeTimestamp );
        -- Need to ensure "main" tag populates correctly if window is open.
        if GRM_MemberDetailMetaData:IsVisible() then
            if not GRM_MemberDetailMainText:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == mainName then
                GRM_MemberDetailMainText:Show();
            end
        end
    else
        -- remove from being main.
        GRM.DemoteFromMain ( mainName , mainName , GRM_AddonGlobals.guildName , true , mainChangeTimestamp );
        -- Udate the UI!
        if GRM_MemberDetailMetaData:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == mainName then
            GRM_MemberDetailMainText:Hide();
        end
    end
end


-- Method:          GRMsync.CheckAltMainToAltChange ( string , string )
-- What it Does:    If a player is demoted from main to alt, it syncs that change with everyone
-- Purpose:         Sync data between players LIVE
GRMsync.CheckAltMainToAltChange = function ( msg , sender )
    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local mainName = string.sub ( msg , string.find ( msg , "?" ) + 1 );

    GRM.DemoteFromMain ( name , mainName , GRM_AddonGlobals.guildName , false , 0 );

    if GRM_MemberDetailMetaData:IsVisible() then
        if GRM_MemberDetailMainText:IsVisible() and GRM.GetMobileFreeName ( GuildMemberDetailName:GetText() ) == mainName then
            GRM_MemberDetailMainText:Hide();
        end
    end
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] then
        chat:AddMessage ( GRM.SlimName ( sender ) .. " has changed " .. GRM.SlimName ( mainName ) .. " to be listed as an 'alt'" , 1.0 , 0.84 , 0 );
    end
end


-- Method:          GRMsync.CheckBanListChange ( string , string )
-- What it Does:    If a player is banned, then it broadcasts the bane to the rest of the players, so they can update their info.
-- Purpose:         It is far more useful if more than one person maintains a BAN list...
GRMsync.CheckBanListChange = function ( msg , sender )
    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local banAlts = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local reason = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local timeEpoch = time();

    if reason == "No Reason Given" then
        reason = "";
    end

    -- First things first, let's find player!
    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then
            -- The initial ban of the player.
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][1] = true;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][2] = timeEpoch;
            GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][18] = reason;

            -- Next thing is IF alts are to be banned, this will ban them all as well!
            if banAlts == "true" then
                local listOfAlts = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];
                if #listOfAlts > 0 then
                    for s = 1 , #listOfAlts do
                        for r = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                            if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] == listOfAlts[s][1] and GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][1] ~= GRM_AddonGlobals.addonPlayerName then

                                -- Banning the alts one by one in the for loop
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][1] = true;
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][17][2] = timeEpoch;
                                GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][r][18] = reason;

                                break;
                            end
                        end
                    end
                end
            end
            break;
        end
    end

    -- Add ban info to the log.
    local logEntry = "";
    if banAlts == "true" then
        logEntry = ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( sender ) .. " has BANNED " .. GRM.SlimName ( name ) .. " and all linked alts from the guild!!!" );
    else
        logEntry = ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( sender ) .. " has BANNED " .. GRM.SlimName ( name ) .. " from the guild!!!" );
    end
    
    if reason ~= "" then
        GRM.AddLog ( 18 , "Reason Banned: " .. reason );
    end
    GRM.AddLog ( 17 , logEntry );

    -- Report the change to chat window...
    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] then
        if banAlts == "true" then
            chat:AddMessage ( GRM.SlimName ( sender ) .. " has BANNED " .. GRM.SlimName ( name ) .. " and all linked alts from the guild!!!" , 1.0 , 0 , 0 );
            if reason == "" then
                reason = "< None Stated > ";
            end
            chat:AddMessage ( "Reason Banned: " .. reason , 1.0 , 1.0 , 1.0 );
        else
            chat:AddMessage ( GRM.SlimName ( sender ) .. " has BANNED " .. GRM.SlimName ( name ) .. " from the guild!!!" , 1.0 , 0 , 0 );
            if reason == "" then
                reason = "< None Stated > ";
            end
            chat:AddMessage ( "Reason Banned: " .. reason , 1.0 , 1.0 , 1.0 );
        end
    end
end

-- Method:          GRMsync.BanManagementPlayersThatLeft ( string )
-- What it Does:    Bans or Unbans a player on the "PlayersThatLeft" global save file
-- Purpose:         Syncing bans and unbans between players...
GRMsync.BanManagementPlayersThatLeft = function ( msg , sender , prefix )
    -- To avoid spamminess
    local isSyncUpdate = false;
    if prefix == "GRM_BANSYNCUP" then
        isSyncUpdate = true;
    end

    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local timeStampEpoch = tonumber ( string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 ) );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local banStatus = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    local reason = string.sub ( msg , string.find ( msg , "?" ) + 1 );

    if reason == "No Reason Given" then
        reason = "";
    end

    for j = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == name then
            if ( banStatus == "ban" and not GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][1] ) or ( banStatus == "unban" and GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][1] ) then
                -- Ok, let's see if it is a ban or an unban!
                if banStatus == "ban" then
                    GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][1] = true;
                    GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][2] = timeStampEpoch;
                    GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][3] = false;
                    GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][18] = reason;
                else
                    -- Cool, player is being unbanned! "unban"
                    if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][1] then
                        GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][3] = true;
                    end
                    GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][1] = false;
                    GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][2] = timeStampEpoch;
                    GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][18] = "";

                end

                -- Add ban info to the log.
                -- Report the updates!
                if banStatus == "ban" then
                    if reason ~= "" then
                        GRM.AddLog ( 18 , reason );
                    end
                    GRM.AddLog ( 17 , ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( name ) .. " has been BANNED from the guild!!!" ) );
                else
                    GRM.AddLog ( 17 , ( GRM.GetTimestamp() .. " : " .. GRM.SlimName ( name ) .. " has been UN-BANNED from the guild!!!" ) );
                end
                
                -- Send update to chat window!
                if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] and not isSyncUpdate then
                    if banStatus == "ban" then
                        chat:AddMessage ( GRM.SlimName ( name ) .. " has been BANNED from the guild!!!"  , 1.0 , 0 , 0 );
                    else
                        chat:AddMessage ( GRM.SlimName ( name ) .. " has been UN-BANNED from the guild!!!"  , 1.0 , 0 , 0 );
                    end
                end
            end
            break;
        end
    end
end

--------------------------------
---- Default Mesage Functions --
--------------------------------

-- Method:          GRMsync.RegisterPrefix( string )
-- What it Does:    To do an addon info send over a channel, the prefix first needs to be registered.
-- Purpose:         For player to player addon talk.
GRMsync.RegisterPrefix = function ( prefix )

    -- Prefix can't be more than 16 characters
    if #prefix > 16 then
        error ( "GRM Error: Unable to register prefix > 16 characters, whilst " .. prefix .. " is " .. #prefix .. "!" );
    end
    RegisterAddonMessagePrefix ( prefix );
end

-- Method:          GRMsync.RegisterPrefixes()
-- What it Does:    Registers the tages for all of the messages, so the addon recognizes and knows to pick them up
-- Purpose:         Prefixes need to be registered to the server to be usable for addon to addon talk.
GRMsync.RegisterPrefixes = function( listOfPrefixes )
    for i = 1 , #listOfPrefixes do 
        GRMsync.RegisterPrefix ( listOfPrefixes[i] );
    end
end

-- Method:          GRMsync.IsPrefixVerified ( string )
-- What it Does:    Returns true if received prefix is listed in this addon's
-- Purpose:         Control the spam in case of other prefixes received from other addons in guild channel.
GRMsync.IsPrefixVerified = function( prefix )
    local result = false;
    for i = 1 , #GRMsyncGlobals.listOfPrefixes do
        if GRMsyncGlobals.listOfPrefixes[i] == prefix then
            result = true;
            break;
        end
    end
    return result;
end



-------------------------------
-------------------------------
------ SYNC ALGORITHM ---------
-------------------------------
------ RETROACTIVE SYNC -------
-------------------------------
-------------------------------


-------------------------------
------- NON-LEADER FORWARD ----
-------------------------------

-- Method:          GRMsync.zPackets()
-- What it Does:    Broadcasts to the leader all join date information
-- Purpose:         Data sync
GRMsync.SendJDPackets = function()
     if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] and not GRMsyncGlobals.syncTempDelay then
        chat:AddMessage ( "GRM: Syncing Data With Guildies Now..."  , 1.0 , 0.84 , 0 );
    end
    -- Initiate Data sending
    if GRMsyncGlobals.SyncOK and not GRMsyncGlobals.syncTempDelay then
        GRMsync.SendMessage ( "GRM_START" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. tostring ( #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] - 1 ) , GRMsyncGlobals.channelName );         -- MSG = number of expected values to be sent.
    end
    -- Send all values ( May need to be throttled for massive guilds? Not sure yet! );
    for i = GRMsyncGlobals.SyncCount , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRMsyncGlobals.SyncOK then
            GRMsyncGlobals.SyncCount = GRMsyncGlobals.SyncCount + 1;
            if GRMsyncGlobals.SyncCount % GRMsyncGlobals.syncCap == 0 then
                GRMsyncGlobals.syncTempDelay = true;
                GRMsync.SendMessage ( "GRM_JDSYNC" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][35][2] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][35][1] , GRMsyncGlobals.channelName )               --  "Name" .. "?" .. TimestampOfChange .. "?" .. JoinDate
                C_Timer.After ( 2 , GRMsync.SendJDPackets );       -- Add a 2 secon delay on packet sending.
                return;
            else
                GRMsync.SendMessage ( "GRM_JDSYNC" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][35][2] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][35][1] , GRMsyncGlobals.channelName )               --  "Name" .. "?" .. TimestampOfChange .. "?" .. JoinDate
            end
        end
    end
    
    -- Close the Data stream
    GRMsyncGlobals.SyncCount = 2;
    GRMsyncGlobals.syncTempDelay = false;
    if GRMsyncGlobals.SyncOK then
        GRMsync.SendMessage ( "GRM_STOP" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. "JD" , GRMsyncGlobals.channelName );
    end
end

-- Method:          GRMsync.SendPDPackets()
-- What it Does:    Broadcasts to the leader all promo date information
-- Purpose:         Data sync
GRMsync.SendPDPackets = function()
    -- Initiate Data sending

    if GRMsyncGlobals.SyncOK and not GRMsyncGlobals.syncTempDelay then
        GRMsync.SendMessage ( "GRM_START" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. tostring ( #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] - 1 ) , GRMsyncGlobals.channelName );         -- MSG = number of expected values to be sent.
    end
    -- Send all values ( May need to be throttled for massive guilds? Not sure yet! );
    for i = GRMsyncGlobals.SyncCount , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        if GRMsyncGlobals.SyncOK then
            GRMsyncGlobals.SyncCount = GRMsyncGlobals.SyncCount + 1;
            if GRMsyncGlobals.SyncCount % GRMsyncGlobals.syncCap == 0 then
                GRMsyncGlobals.syncTempDelay = true;
                    GRMsync.SendMessage ( "GRM_PDSYNC" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][36][2] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][36][1] , GRMsyncGlobals.channelName )               --  "Name" .. "?" .. TimestampOfChange .. "?" .. PromoDate
                C_Timer.After ( 2 , GRMsync.SendPDPackets );       -- Add a 2 secon delay on packet sending.
                return;
            else
                GRMsync.SendMessage ( "GRM_PDSYNC" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][36][2] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][36][1] , GRMsyncGlobals.channelName )               --  "Name" .. "?" .. TimestampOfChange .. "?" .. PromoDate
            end
        end
    end
    
    -- Close the Data stream
    GRMsyncGlobals.SyncCount = 2;
    GRMsyncGlobals.syncTempDelay = false;
    if GRMsyncGlobals.SyncOK then
        GRMsync.SendMessage ( "GRM_STOP" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. "PD" , GRMsyncGlobals.channelName );
    end
end

-- Method:          GRMsync.SendBANPackets()
-- What it Does:    Broadcasts to the leader all Ban information
-- Purpose:         Data sync
GRMsync.SendBANPackets = function()
    -- Initiate Data sending

    if GRMsyncGlobals.SyncOK and not GRMsyncGlobals.syncTempDelay then
        GRMsync.SendMessage ( "GRM_START" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. tostring ( #GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] - 1 ) , GRMsyncGlobals.channelName );         -- MSG = number of expected values to be sent.
    end
    -- Send all values ( May need to be throttled for massive guilds? Not sure yet! );
    for i = GRMsyncGlobals.SyncCount , #GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        local timeStampOfBanChange = tostring ( GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17][2] );
        local msgTag = "ban";
        -- Let's see if someone was unbanned.
        if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17][3] then
            msgTag = "unban";
        elseif not GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17][1] and not GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][17][3] then
            msgTag = "noban";
        end

        if GRMsyncGlobals.SyncOK then
            GRMsyncGlobals.SyncCount = GRMsyncGlobals.SyncCount + 1;
            if GRMsyncGlobals.SyncCount % GRMsyncGlobals.syncCap == 0 then
                GRMsyncGlobals.syncTempDelay = true;
                GRMsync.SendMessage ( "GRM_BANSYNC" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] .. "?" .. timeStampOfBanChange .. "?" .. msgTag .. "?" .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][18] , GRMsyncGlobals.channelName );
                C_Timer.After ( 2 , GRMsync.SendBANPackets );       -- Add a 2 secon delay on packet sending.
                return;
            else
                GRMsync.SendMessage ( "GRM_BANSYNC" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] .. "?" .. timeStampOfBanChange .. "?" .. msgTag .. "?" .. GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][18] , GRMsyncGlobals.channelName );
            end
        end
    end
    
    -- Close the Data stream
    GRMsyncGlobals.SyncCount = 2;
    GRMsyncGlobals.syncTempDelay = false;
    if GRMsyncGlobals.SyncOK then
        GRMsync.SendMessage ( "GRM_STOP" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. "BAN" , GRMsyncGlobals.channelName );
    end
end
-- /run for i=2,#GRM_GuildMemberHistory_Save[1][3] do local f=false;local n=GRM_GuildMemberHistory_Save[1][3][i][1];for j=1,#GRMsyncGlobals.AltReceivedTemp do if n==GRMsyncGlobals.AltReceivedTemp[j][1] then f=true;break;end;end;if not f then print(n);end;end

-- Method:          GRMsync.SendAltPackets()
-- What it Does:    Broadcasts to the leader all ALT information
-- Purpose:         Data sync
GRMsync.SendAltPackets = function()
    local msg = "";
    if not GRMsyncGlobals.syncTempDelay2  then
        if GRMsyncGlobals.SyncOK and not GRMsyncGlobals.syncTempDelay then
            GRMsync.SendMessage ( "GRM_START" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. tostring ( #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] - 1 ) , GRMsyncGlobals.channelName );         -- MSG = number of expected values to be sent.
        end
        -- Gonna send 2 tables... 1 of the alts, one of the removed alts.
        for i = GRMsyncGlobals.SyncCount , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
            -- Initiate rank restrictions at start of msg string.
            -- If player has alts
            if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11] > 0 then
                for j = GRMsyncGlobals.SyncCount3 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11] do
                    msg = GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1];  
                    if GRMsyncGlobals.SyncOK then
                        GRMsyncGlobals.SyncCount3 = GRMsyncGlobals.SyncCount3 + 1;          -- Controlling the position of the alt in the list
                        GRMsyncGlobals.SyncCount4 = GRMsyncGlobals.SyncCount4 + 1;          -- Number will not be reset until the end... this controls the overall sync number
                        if GRMsyncGlobals.SyncCount4 % GRMsyncGlobals.syncCap == 0 then
                            GRMsync.SendMessage ( "GRM_ALTADDSYNC" , msg .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][j][1] .. "?" .. tostring ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][j][6] ) , GRMsyncGlobals.channelName );
                            C_Timer.After ( 2 , GRMsync.SendAltPackets );       -- Add a 2 second delay on packet sending.
                            return;
                        else
                            GRMsync.SendMessage ( "GRM_ALTADDSYNC" , msg .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][j][1] .. "?" .. tostring ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][11][j][6] ) , GRMsyncGlobals.channelName );
                        end
                    end
                end
            else
                GRMsync.SendMessage ( "GRM_ALTADDSYNC" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] .. "?0" , GRMsyncGlobals.channelName );
            end

            if GRMsyncGlobals.SyncOK then
                GRMsyncGlobals.SyncCount = GRMsyncGlobals.SyncCount + 1;
                if GRMsyncGlobals.SyncCount % GRMsyncGlobals.syncCap == 0 then
                    GRMsyncGlobals.SyncCount3 = 1;
                    GRMsyncGlobals.syncTempDelay = true;
                    C_Timer.After ( 2 , GRMsync.SendAltPackets );       -- Add a 2 secon delay on packet sending.
                    return;
                end
            end
            GRMsyncGlobals.SyncCount3 = 1;
        end
    end

    -- -- Removed Alts Table...
    for i = GRMsyncGlobals.SyncCount2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do

        -- If player has alts
        if #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][37] > 0 then
            for j = GRMsyncGlobals.SyncCount5 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][37] do
                msg = GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1];  
                if GRMsyncGlobals.SyncOK then
                    GRMsyncGlobals.SyncCount5 = GRMsyncGlobals.SyncCount5 + 1;          -- Controlling the position of the alt in the list
                    GRMsyncGlobals.SyncCount6 = GRMsyncGlobals.SyncCount6 + 1;          -- Number will not be reset until the end... this controls the overall sync number
                    if GRMsyncGlobals.SyncCount6 % GRMsyncGlobals.syncCap == 0 then
                        GRMsyncGlobals.syncTempDelay = true;
                        GRMsync.SendMessage ( "GRM_ALTREMSYNC" , msg .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][37][j][1] .. "?" .. tostring ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][37][j][6] ) , GRMsyncGlobals.channelName );
                        C_Timer.After ( 2 , GRMsync.SendAltPackets );       -- Add a 2 second delay on packet sending.
                        return;
                    else
                        GRMsync.SendMessage ( "GRM_ALTREMSYNC" , msg .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][37][j][1] .. "?" .. tostring ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][37][j][6] ) , GRMsyncGlobals.channelName );
                    end
                end
            end
        else
            GRMsync.SendMessage ( "GRM_ALTREMSYNC" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1] .. "?0" , GRMsyncGlobals.channelName );
        end

        if GRMsyncGlobals.SyncOK then
            GRMsyncGlobals.SyncCount2 = GRMsyncGlobals.SyncCount2 + 1;
            if GRMsyncGlobals.SyncCount2 % GRMsyncGlobals.syncCap == 0 then
                GRMsyncGlobals.SyncCount5 = 1;
                GRMsyncGlobals.syncTempDelay = true;
                C_Timer.After ( 2 , GRMsync.SendAltPackets );       -- Add a 2 secon delay on packet sending.
                return;
            end
        end
        GRMsyncGlobals.SyncCount5 = 1;
    end

    GRMsyncGlobals.SyncCount = 2;
    GRMsyncGlobals.SyncCount2 = 2;
    GRMsyncGlobals.SyncCount3 = 1;
    GRMsyncGlobals.SyncCount4 = 1;
    GRMsyncGlobals.SyncCount5 = 1;
    GRMsyncGlobals.SyncCount6 = 1;
    GRMsyncGlobals.syncTempDelay = false;
    GRMsyncGlobals.syncTempDelay2 = false;
    if GRMsyncGlobals.SyncOK then
        GRMsync.SendMessage ( "GRM_STOPALTREM" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" , GRMsyncGlobals.channelName )
    end
end

-- Method:          GRMsync.SendMainPackets()
-- What it Does:    Broadcasts to the leader all MAIN information
-- Purpose:         Data sync
GRMsync.SendMainPackets = function()
    if GRMsyncGlobals.SyncOK and not GRMsyncGlobals.syncTempDelay then
        GRMsync.SendMessage ( "GRM_START" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. tostring ( #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] - 1 ) , GRMsyncGlobals.channelName );         -- MSG = number of expected values to be sent.
    end
    -- Send all values ( May need to be throttled for massive guilds? Not sure yet! );
    local isPlayerMain;

    for i = GRMsyncGlobals.SyncCount , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
        
        isPlayerMain = "false";                                                                                 -- Kept as a string rather than a boolean so it can be passed as a comm over the server without needing to cast it to a string.
        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][10] then
            isPlayerMain = "true";
        end

        if GRMsyncGlobals.SyncOK then
            GRMsyncGlobals.SyncCount = GRMsyncGlobals.SyncCount + 1;
            if GRMsyncGlobals.SyncCount % GRMsyncGlobals.syncCap == 0 then
                GRMsyncGlobals.syncTempDelay = true;
                GRMsync.SendMessage ( "GRM_MAINSYNC" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1]  .. "?" .. tostring ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][39] ) .. "?" .. isPlayerMain , GRMsyncGlobals.channelName );
                C_Timer.After ( 2 , GRMsync.SendMainPackets );       -- Add a 2 secon delay on packet sending.
                return;
            else
                GRMsync.SendMessage ( "GRM_MAINSYNC" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][1]  .. "?" .. tostring ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][i][39] ) .. "?" .. isPlayerMain , GRMsyncGlobals.channelName );
            end
        end
    end
    
    -- Close the Data stream
    GRMsyncGlobals.SyncCount = 2;
    GRMsyncGlobals.syncTempDelay = false;
    if GRMsyncGlobals.SyncOK then
        GRMsync.SendMessage ( "GRM_STOP" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. "MAIN" , GRMsyncGlobals.channelName );
    end
end

-------------------------------
----- LEADER COLLECTION -------
----- AND ANALYSIS ------------ 
-------------------------------

-- Method:          GRMsync.InitiateDataSync()
-- What it Does:    Begins the sync process going throug hthe sync que
-- Purpose:         To Sync data!
GRMsync.InitiateDataSync = function ()
    GRMsyncGlobals.LeadSyncProcessing = false;
    -- First step, let's check Join Date Changes! Kickstart the fun!   
    if #GRMsyncGlobals.SyncQue > 0 then
        GRMsyncGlobals.currentlySyncing = true;
        GRMsyncGlobals.CurrentSyncPlayer = GRMsyncGlobals.SyncQue[1];
        if GRMsyncGlobals.SyncOK then
            GRMsync.ResetTempTables();
            GRMsync.SendMessage ( "GRM_REQJDDATA" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.SyncQue[1] , GRMsyncGlobals.channelName );
        end
        table.remove ( GRMsyncGlobals.SyncQue , 1 );

        -- If it fails to sync, after 30 seconds, it retries...
        C_Timer.After ( 30 , function()
            if GRMsyncGlobals.currentlySyncing and #GRMsyncGlobals.SyncQue > 0 then
                GRMsync.InitiateDataSync();
            end
        end);
    end
end

-- Method:          GRMsync.SubmitFinalSyncData()
-- What it Does:    Sends out the mandatory updates to all online (they won't if the change is already there)
-- Purpose:         So leader can send out current, updated sync info.
GRMsync.SubmitFinalSyncData = function()
    -- Ok send of the Join Date updates!
    if #GRMsyncGlobals.JDChanges > 0 and not GRMsyncGlobals.finalSyncProgress[1] then
        local joinDate = "";
        local finalTStamp = "";
        local finalEpochStamp = "";
        for i = GRMsyncGlobals.finalSyncDataCount , #GRMsyncGlobals.JDChanges do
            joinDate = ( "Joined: " .. GRMsyncGlobals.JDChanges[i][3] );
            finalTStamp = ( string.sub ( joinDate , 9 ) .. " 12:01am" );
            finalEpochStamp = GRM.TimeStampToEpoch ( joinDate );
            -- Send a change to everyone!
            if GRMsyncGlobals.SyncOK then
                GRMsyncGlobals.finalSyncDataCount = GRMsyncGlobals.finalSyncDataCount + 1;
                GRMsync.SendMessage ( "GRM_JDSYNCUP" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.JDChanges[i][1] .. "?" .. joinDate .. "?" .. finalTStamp .. "?" .. finalEpochStamp , GRMsyncGlobals.channelName );
                -- Do my own changes too!
                GRMsync.CheckJoinDateChange ( GRMsyncGlobals.JDChanges[i][1] .. "?" .. joinDate .. "?" .. finalTStamp .. "?" .. finalEpochStamp , "" , "GRM_JDSYNCUP" );
                if GRMsyncGlobals.finalSyncDataCount % GRMsyncGlobals.syncCap == 0 then
                    C_Timer.After ( 2 , GRMsync.SubmitFinalSyncData );
                    return;
                end
            end
        end
        GRMsyncGlobals.finalSyncDataCount = 1;
        GRMsyncGlobals.finalSyncProgress[1] = true;
    end

    -- Promo date sync!
    if #GRMsyncGlobals.PDChanges > 0 and not GRMsyncGlobals.finalSyncProgress[2] then
        local promotionDate = "";
        for i = GRMsyncGlobals.finalSyncDataCount , #GRMsyncGlobals.PDChanges do
            promotionDate = ( "Joined: " .. GRMsyncGlobals.PDChanges[i][3] );
            if GRMsyncGlobals.SyncOK then
                GRMsyncGlobals.finalSyncDataCount = GRMsyncGlobals.finalSyncDataCount + 1;
                GRMsync.SendMessage ( "GRM_PDSYNCUP" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.PDChanges[i][1] .. "?" .. promotionDate .. "?" .. tostring ( GRMsyncGlobals.PDChanges[i][2] ) , "GUILD"); 
                -- Do my own changes too!
                GRMsync.CheckPromotionDateChange ( GRMsyncGlobals.PDChanges[i][1] .. "?" .. promotionDate .. "?" .. tostring ( GRMsyncGlobals.PDChanges[i][2] ) , "" , "GRM_PDSYNCUP" );
                if GRMsyncGlobals.finalSyncDataCount % GRMsyncGlobals.syncCap == 0 then
                    C_Timer.After ( 2 , GRMsync.SubmitFinalSyncData );
                    return;
                end
            end
        end
        GRMsyncGlobals.finalSyncDataCount = 1;
        GRMsyncGlobals.finalSyncProgress[2] = true;
    end

    -- BAN changes sync!
    if #GRMsyncGlobals.BanChanges > 0 and not GRMsyncGlobals.finalSyncProgress[3] then
        for i = GRMsyncGlobals.finalSyncDataCount , #GRMsyncGlobals.BanChanges do
            if GRMsyncGlobals.SyncOK then
                GRMsyncGlobals.finalSyncDataCount = GRMsyncGlobals.finalSyncDataCount + 1;
                GRMsync.SendMessage ( "GRM_BANSYNCUP" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.BanChanges[i][1] .. "?" .. tostring ( GRMsyncGlobals.BanChanges[i][2] ) .. "?" .. GRMsyncGlobals.BanChanges[i][3] .. "?" .. GRMsyncGlobals.BanChanges[i][4] , GRMsyncGlobals.channelName );
                -- Do my own changes too!
                GRMsync.BanManagementPlayersThatLeft ( GRMsyncGlobals.BanChanges[i][1] .. "?" .. tostring ( GRMsyncGlobals.BanChanges[i][2] ) .. "?" .. GRMsyncGlobals.BanChanges[i][3] .. "?" .. GRMsyncGlobals.BanChanges[i][4] , "" , "GRM_BANSYNCUP" );
                if GRMsyncGlobals.finalSyncDataCount % GRMsyncGlobals.syncCap == 0 then
                    C_Timer.After ( 2 , GRMsync.SubmitFinalSyncData );
                    return;
                end
            end
        end
        GRMsyncGlobals.finalSyncDataCount = 1;
        GRMsyncGlobals.finalSyncProgress[3] = true;
    end
    
    -- ALT changes sync for adding alts!
    if #GRMsyncGlobals.AltAddChanges > 0 and not GRMsyncGlobals.finalSyncProgress[4] then
        for i = GRMsyncGlobals.finalSyncDataCount , #GRMsyncGlobals.AltAddChanges do  -- ( playerName , altName )
            if GRMsyncGlobals.SyncOK then
                GRMsyncGlobals.finalSyncDataCount = GRMsyncGlobals.finalSyncDataCount + 1;
                GRMsync.SendMessage ( "GRM_ALTSYNCUP" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.AltAddChanges[i][1] .. "?" .. GRMsyncGlobals.AltAddChanges[i][2] .. "?" .. tostring ( GRMsyncGlobals.AltAddChanges[i][3] ) , GRMsyncGlobals.channelName );
                -- Do my own changes too!
                GRMsync.CheckAddAltChange ( GRMsyncGlobals.AltAddChanges[i][1] .. "?" .. GRMsyncGlobals.AltAddChanges[i][2] .. "?" .. tostring ( GRMsyncGlobals.AltAddChanges[i][3] ) , "" , "GRM_ALTSYNCUP" );
                if GRMsyncGlobals.finalSyncDataCount % GRMsyncGlobals.syncCap == 0 then
                    C_Timer.After ( 2 , GRMsync.SubmitFinalSyncData );
                    return;
                end
            end
            -- Now my data!
        end
        GRMsyncGlobals.finalSyncDataCount = 1;
        GRMsyncGlobals.finalSyncProgress[4] = true;
    end
    
    -- ALT changes sync for adding alts!
    if #GRMsyncGlobals.AltRemoveChanges > 0 and not GRMsyncGlobals.finalSyncProgress[5] then
        for i = GRMsyncGlobals.finalSyncDataCount , #GRMsyncGlobals.AltRemoveChanges do  -- ( playerName , altName )
            if GRMsyncGlobals.SyncOK then
                GRMsyncGlobals.finalSyncDataCount = GRMsyncGlobals.finalSyncDataCount + 1;
                GRMsync.SendMessage ( "GRM_REMSYNCUP" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.AltRemoveChanges[i][1] .. "?" .. GRMsyncGlobals.AltRemoveChanges[i][2] .. "?" .. tostring ( GRMsyncGlobals.AltRemoveChanges[i][3] ) , GRMsyncGlobals.channelName );
                -- Do my own changes too!
                GRMsync.CheckRemoveAltChange ( GRMsyncGlobals.AltRemoveChanges[i][1] .. "?" .. GRMsyncGlobals.AltRemoveChanges[i][2] .. "?" .. tostring ( GRMsyncGlobals.AltRemoveChanges[i][3] ) , "" , "GRM_REMSYNCUP" );
                if GRMsyncGlobals.finalSyncDataCount % GRMsyncGlobals.syncCap == 0 then
                    C_Timer.After ( 2 , GRMsync.SubmitFinalSyncData );
                    return;
                end
            end
        end
        GRMsyncGlobals.finalSyncDataCount = 1;
        GRMsyncGlobals.finalSyncProgress[5] = true;
    end
    

    -- MAIN STATUS CHECK!
    if #GRMsyncGlobals.AltMainChanges > 0 and not GRMsyncGlobals.finalSyncProgress[6] then
        for i = GRMsyncGlobals.finalSyncDataCount , #GRMsyncGlobals.AltMainChanges do
            if GRMsyncGlobals.SyncOK then
                GRMsyncGlobals.finalSyncDataCount = GRMsyncGlobals.finalSyncDataCount + 1;
                GRMsync.SendMessage ( "GRM_MAINSYNCUP" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.AltMainChanges[i][1] .. "?" .. tostring ( GRMsyncGlobals.AltMainChanges[i][2] ) .. "?" .. tostring ( GRMsyncGlobals.AltMainChanges[i][3] ) , GRMsyncGlobals.channelName )
                -- Do my own changes too!
                GRMsync.CheckMainSyncChange ( GRMsyncGlobals.AltMainChanges[i][1] .. "?" .. tostring ( GRMsyncGlobals.AltMainChanges[i][2] ) .. "?" .. tostring ( GRMsyncGlobals.AltMainChanges[i][3] )  );
                if GRMsyncGlobals.finalSyncDataCount % GRMsyncGlobals.syncCap == 0 then
                    C_Timer.After ( 2 , GRMsync.SubmitFinalSyncData );
                    return;
                end
            end
        end
        GRMsyncGlobals.finalSyncDataCount = 1;
        GRMsyncGlobals.finalSyncProgress[6] = true;
    end
    
    -- Ok all done! Reset the tables!
    GRMsync.ResetReportTables();
    GRMsyncGlobals.finalSyncDataCount = 1;
    GRMsyncGlobals.finalSyncProgress = { false , false , false , false , false , false };
    
    -- Do a quick check if anyone else added themselves to the que in the last millisecond, and if so, REPEAT!
    -- Setup repeat here.
    -----------------------------------

    if #GRMsyncGlobals.SyncQue > 0 then
        GRMsync.InitiateDataSync();
    else
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] then
            chat:AddMessage ( "GRM: Sync With Guildies Complete..."  , 1.0 , 0.84 , 0 );
        end
        GRMsync.SendMessage ( "GRM_COMPLETE" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?0" , GRMsyncGlobals.channelName );
        GRMsyncGlobals.currentlySyncing = false;
    end
end

-- Method:          GRMsync.CollectData ( string , string )
-- What it Does:    Collects all of the sync data before analysis.
-- Purpose:         Need to aggregate the data so one only needs to parse through the tables once, rather than on each new piece of info added. Far more efficient.
GRMsync.CollectData = function ( msg , prefix )
    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
    local timeStampOfChange = 0;
    -- Need to check, in some cases this will be the end of the road...
    if string.find ( msg , "?" ) ~= nil then
        timeStampOfChange = tonumber ( string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 ) );
    else
        timeStampOfChange = tonumber ( msg );
    end

    -- JOIN DATE
    if prefix == "GRM_JDSYNC" then
        local joinDate = string.sub ( msg , string.find ( msg , "?" ) + 1 );
        table.insert ( GRMsyncGlobals.JDReceivedTemp , { name , timeStampOfChange , GRMsync.SlimDate ( joinDate ) } );
    
    -- PROMO DATE
    elseif prefix == "GRM_PDSYNC" then
        local promoDate = string.sub ( msg , string.find ( msg , "?" ) + 1 );
        table.insert ( GRMsyncGlobals.PDReceivedTemp , { name , timeStampOfChange , promoDate } );
    
    -- BAN/UNBAN
    elseif prefix == "GRM_BANSYNC" then
        msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
        local banStatus = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
        local reason = string.sub ( msg , string.find ( msg , "?" ) + 1 );
        table.insert ( GRMsyncGlobals.BanReceivedTemp , { name , timeStampOfChange , banStatus , reason } );

    -- MAIN STATUS
    elseif prefix == "GRM_MAINSYNC" then
        local mainStatus = string.sub ( msg , string.find ( msg , "?" ) + 1 );
        local mainResult = false;
        -- Let's convert that string to boolean
        if mainStatus == "true" then
            mainResult = true;
        end
        table.insert ( GRMsyncGlobals.MainReceivedTemp , { name , mainResult , timeStampOfChange } );
    end
end

-- Method:          GRMsync.CollectAltAddData ( string )
-- What it Does:    Compiles the alt ADD data into a temp file
-- Purpose:         For use of syncing. Need to compile all data from a single player before analyzing it.
GRMsync.CollectAltAddData = function ( msg )
    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );

    -- Initializing empty array
    local index = -1;
    for i = 1 , #GRMsyncGlobals.AltReceivedTemp do
        if GRMsyncGlobals.AltReceivedTemp[i][1] == name then
            index = i;
            break;
        end
    end

    if index == -1 then
        table.insert ( GRMsyncGlobals.AltReceivedTemp , { name , {} } ); 
    end

    -- Ok, let's see if there are alts to be added!
    if msg ~= "0" then      
        -- Ok, let's add the alt info!
        -- Player was just added, so you know it is at the end of the table in the last index.
        -- Sets insert point in table.
        if index == -1 then
            index = #GRMsyncGlobals.AltReceivedTemp;
        end

        local timestampResult;
        local altName = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
        msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );

        -- This protects against older version from breaking new way alt data is sync'd
        if string.find ( msg , "?" ) == nil then
            timestampResult = tonumber ( msg );
        else
            timestampResult = tonumber ( string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 ) );
        end

        table.insert ( GRMsyncGlobals.AltReceivedTemp[ index ][2] , { altName , timestampResult } );
    end
end

-- Method:          GRMsync.CollectAltRemData ( string )
-- What it Does:    Compiles the received data from a player about their alt configurations
-- Purtpose:        For syncing
GRMsync.CollectAltRemData = function ( msg )
    local name = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );

    local index = -1;
    for i = 1 , #GRMsyncGlobals.AltRemReceivedTemp do
        if GRMsyncGlobals.AltRemReceivedTemp[i][1] == name then
            index = i;
            break;
        end
    end

    if index == -1 then
        table.insert ( GRMsyncGlobals.AltRemReceivedTemp , { name , {} } ); 
    end

    -- Ok, let's see if there are alts to be added!
    if msg ~= "0" then

        if index == -1 then
            index = #GRMsyncGlobals.AltRemReceivedTemp;
        end
        
        local timestampResult;
        local altName = string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 );
        msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );

        -- This protects against older version from breaking new way alt data is sync'd
        if string.find ( msg , "?" ) == nil then
            timestampResult = tonumber ( msg );
        else
            timestampResult = tonumber ( string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 ) );
        end

        table.insert ( GRMsyncGlobals.AltRemReceivedTemp[ index ][2] , { altName , timestampResult } );
    end
end

-- Method:          GRMsync.AddToProperAltTable ( string , string , int , boolean )
-- What it Does:    Verifies that the alt needs to be added to the finalized data... or removed.
-- Purpose:         Sync control for alt management.                                                                    ----- HUGE ERROR!!! I AM NOT CHECKING FINAL TABLES< ONLY INITIAL TEMP TABLES!!! NEED TO FIX!!!!!!!
GRMsync.AddToProperAltTable = function ( name , altName , timeStamp , toAddAlt )
    local currentTime = time();
    local needsAdding = true;
    local isAlreadyAdded = false;

    -- POSSIBLY ADDING!
    if toAddAlt then
    -- If I am going to add it, then make sure it is not on the finalized Remove table, and if it is, compare timestamps
    -- if it IS to be added to the final ADD table, then ensure it is not already there as well!
        if #GRMsyncGlobals.AltRemoveChanges > 0 then
            for i = 1 , #GRMsyncGlobals.AltRemoveChanges do
                if GRMsyncGlobals.AltRemoveChanges[i][1] == name and GRMsyncGlobals.AltRemoveChanges[i][2] == altName then
                    -- Ok, match is found! We need to check timestamps now!
                    if ( currentTime - timeStamp ) > ( currentTime - GRMsyncGlobals.AltRemoveChanges[i][3] ) then
                        -- This means that the player set to be added is actually set to be removed by a more recent entry!
                        needsAdding = false;
                    
                    else
                        -- Since it was found in the table, and the incoming data is more recent, then it also needs to be removed from the removeChanges table
                        table.remove ( GRMsyncGlobals.AltRemoveChanges , i );
                    end
                    break;
                end
            end
        end

        -- Confirmed, it is definitely a change to be added!
        if needsAdding then
            -- Before we add it, let's first verify it is not already in the table!
            if #GRMsyncGlobals.AltAddChanges > 0 then
                for i = 1 , #GRMsyncGlobals.AltAddChanges do
                    if GRMsyncGlobals.AltAddChanges[i][1] == name and GRMsyncGlobals.AltAddChanges[i][2] == altName then
                        -- Player info has already been determined through scannign another player's update info!
                        isAlreadyAdded = true;
                        break;
                    end
                end
            end

            if not isAlreadyAdded then
                -- Add it here!
                table.insert ( GRMsyncGlobals.AltAddChanges , { name , altName , timeStamp } );
            end
        end



    -- POSSIBLY REMOVING!
    else
    -- If it is to be removed, ensure it is not already on the ADD table, and if it is, compare timestamps.
    -- IF it IS certain to be removed, ensure that it is not already on the Remove table to avoid double adds.
        if #GRMsyncGlobals.AltAddChanges > 0 then
            for i = 1 , #GRMsyncGlobals.AltAddChanges do
                if GRMsyncGlobals.AltAddChanges[i][1] == name and GRMsyncGlobals.AltAddChanges[i][2] == altName then
                    -- Ok, match is found! We need to check timestamps now!
                    if ( currentTime - timeStamp ) > ( currentTime - GRMsyncGlobals.AltAddChanges[i][3] ) then
                        -- This means that the player set to be added is actually set to be removed by a more recent entry!
                        needsAdding = false;
                    
                    else
                        -- Since it was found in the table, and the incoming data is more recent, then it also needs to be removed from the removeChanges table
                        table.remove ( GRMsyncGlobals.AltAddChanges , i );
                    end
                    break;
                end
            end
        end

         -- Confirmed, it is definitely a change to be added to REMOVE table
        if needsAdding then
            -- Before we add it, let's first verify it is not already in the table!
            
            if #GRMsyncGlobals.AltRemoveChanges > 0 then
                for i = 1 , #GRMsyncGlobals.AltRemoveChanges do
                    if GRMsyncGlobals.AltRemoveChanges[i][1] == name and GRMsyncGlobals.AltRemoveChanges[i][2] == altName then
                        -- Player info has already been determined through scannign another player's update info!
                        isAlreadyAdded = true;
                        break;
                    end
                end
            end

            if not isAlreadyAdded then
                -- Add it here!
                table.insert ( GRMsyncGlobals.AltRemoveChanges , { name , altName , timeStamp } );
            end
        end
    end
end

-- Method:          GRMsync.CheckChanges ( string , string )
-- What it Does:    Checks to see if the received data and the leader's data is different and then adds the most recent changes to update que
-- Purpose:         Retroactive Sync Procedure fully defined here in this method. MUCH WORK!
GRMsync.CheckChanges = function ( msg )
    local currentTime = time();
    -----------------------------
    -- For Join Date checking!
    -----------------------------
    if msg == "JD" then
        if #GRMsyncGlobals.JDReceivedTemp == GRMsyncGlobals.NumPlayerDataExpected then
            for i = 1 , #GRMsyncGlobals.JDReceivedTemp do
                for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == GRMsyncGlobals.JDReceivedTemp[i][1] then
                        -- Ok player identified, now let's compare data.
                        local parsedDate = GRMsync.SlimDate ( GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][35][1] );
                        if parsedDate ~= GRMsyncGlobals.JDReceivedTemp[i][3] then
                            -- Player dates don't match! Let's compare timestamps to see how made the most recent change, then sync data to that!
                            
                            local addReceived = false;      -- AM I going to add received data, or my own. One or the other needs to be added for sync
                            if ( currentTime - GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][35][2] ) > ( currentTime - GRMsyncGlobals.JDReceivedTemp[i][2] ) then
                                -- Received Data happened more recently! Need to update change!
                                addReceived = true;         -- In other words, don't add my own data, add the received data.
                            end

                            -- Setting the change data properly.
                            local changeData;
                            -- Adding Received from other player
                            if addReceived then
                                changeData = GRMsyncGlobals.JDReceivedTemp[i];
                            
                            -- Adding my own data, as it is more current
                            else
                                changeData = { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][35][2] , parsedDate };
                            end

                            -- Need to check if change has not already been added, or if another player added info that is more recent! (Might need review for increased performance)
                            local needToAdd = true;
                            for r = 1 , #GRMsyncGlobals.JDChanges do
                                if changeData[1] == GRMsyncGlobals.JDChanges[r][1] then
                                    -- If dates are the same, no need to change em!
                                    if changeData[2] == GRMsyncGlobals.JDChanges[r][2] or ( currentTime - changeData[3] ) > ( currentTime - GRMsyncGlobals.JDChanges[3] ) then
                                        needToAdd = false;
                                    end

                                    -- If needToAdd is still true, then we need to remove the old index.
                                    if needToAdd then
                                        table.remove ( GRMsyncGlobals.JDChanges , r );
                                    end
                                end
                            end

                            -- Now let's add it!
                            if needToAdd then
                                table.insert ( GRMsyncGlobals.JDChanges , changeData );
                            end
                        end
                        break;
                    end
                end
            end

            -- Wiping the temp file!
            -- From here, request should be sent out for PDSYNC!
            GRMsyncGlobals.JDReceivedTemp = {};
            if GRMsyncGlobals.SyncOK then
                GRMsync.SendMessage ( "GRM_REQPDDATA" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.CurrentSyncPlayer , GRMsyncGlobals.channelName );
            end
        end

    -----------------------------
    -- For Promo Date checking!
    -----------------------------
    elseif msg == "PD" then
        if #GRMsyncGlobals.PDReceivedTemp == GRMsyncGlobals.NumPlayerDataExpected then
            for i = 1 , #GRMsyncGlobals.PDReceivedTemp do
                for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == GRMsyncGlobals.PDReceivedTemp[i][1] then
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][36][1] ~= GRMsyncGlobals.PDReceivedTemp[i][3] then

                  
                            local addReceived = false;      -- AM I going to add received data, or my own. One or the other needs to be added for sync
                            if ( currentTime - GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][36][2] ) > ( currentTime - GRMsyncGlobals.PDReceivedTemp[i][2] ) then
                                -- Received Data happened more recently! Need to update change!
                                addReceived = true;         -- In other words, don't add my own data, add the received data.
                            end

                            -- Setting the change data properly.
                            local changeData;
                            -- Adding Received from other player
                            if addReceived then
                                changeData = GRMsyncGlobals.PDReceivedTemp[i];
                            
                            -- Adding my own data, as it is more current
                            else
                                changeData = { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][36][2] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][36][1] };
                            end

                            -- Need to check if change has not already been added, or if another player added info that is more recent! (Might need review for increased performance)
                            local needToAdd = true;
                            for r = 1 , #GRMsyncGlobals.PDChanges do
                                if changeData[1] == GRMsyncGlobals.PDChanges[r][1] then
                                    -- If dates are the same, no need to change em!
                                    if changeData[2] == GRMsyncGlobals.PDChanges[r][2] or ( currentTime - changeData[3] ) > ( currentTime - GRMsyncGlobals.PDChanges[3] ) then
                                        needToAdd = false;
                                    end

                                    -- If needToAdd is still true, then we need to remove the old index.
                                    if needToAdd then
                                        table.remove ( GRMsyncGlobals.PDChanges , r );
                                    end
                                end
                            end

                            -- If needToAdd is still true, then we need to remove the old index.
                            if needToAdd then
                                table.insert ( GRMsyncGlobals.PDChanges , changeData );
                            end
                        end
                        break;
                    end
                end
            end
            -- Wipe the data!
            GRMsyncGlobals.PDReceivedTemp = {};
            if GRMsyncGlobals.SyncOK then
                GRMsync.SendMessage ( "GRM_REQBANDATA" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.CurrentSyncPlayer , GRMsyncGlobals.channelName );
            end
        end

    -----------------------------
    --- FOR BAN STATUS CHECK ----
    -----------------------------

    elseif msg == "BAN" then
        if #GRMsyncGlobals.BanReceivedTemp == GRMsyncGlobals.NumPlayerDataExpected then -- { name , timeStampOfBanCHange , banStatus , reason }
            for i = 1 , #GRMsyncGlobals.BanReceivedTemp do
                for j = 2 , #GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                    if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == GRMsyncGlobals.BanReceivedTemp[i][1] then
                        -- Let's first check if they have diff. info.
                        if GRMsyncGlobals.BanReceivedTemp[i][3] ~= "noban" or ( GRMsyncGlobals.BanReceivedTemp[i][3] == "noban" and ( GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][1] or GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][3] ) ) then
                            local banStatus = false;
                            if GRMsyncGlobals.BanReceivedTemp[i][3] == "ban" then
                                banStatus = true;
                            end

                            if banStatus ~= GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][1] then
                                
                                local addReceived = false;      -- AM I going to add received data, or my own. One or the other needs to be added for sync
                                if ( currentTime - GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][2] ) > ( currentTime - GRMsyncGlobals.BanReceivedTemp[i][2] ) then
                                    -- Received Data happened more recently! Need to update change!
                                    addReceived = true;         -- In other words, don't add my own data, add the received data.
                                end

                                local changeData;
                                -- Adding Received from other playerZ--[[z]]
                                if addReceived then
                                    changeData = GRMsyncGlobals.BanReceivedTemp[i];
                                
                                -- Adding my own data, as it is more current
                                else
                                    local msgTag = "ban";
                                    if GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][3] then
                                        msgTag = "unban"
                                    end
                                    changeData = { GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][17][2] , msgTag , GRM_PlayersThatLeftHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][18] };
                                end

                                -- Let's see if already indexed by another player!
                                local needToAdd = true;
                                for r = 1 , #GRMsyncGlobals.BanChanges do
                                    if changeData[1] == GRMsyncGlobals.BanChanges[r][1] then
                                        -- If bans are going to be the same, no need to change!
                                        if changeData[3] == GRMsyncGlobals.BanChanges[r][3] or ( currentTime - changeData[2] ) > ( currentTime - GRMsyncGlobals.BanChanges[2] ) then -- If difference found, but the other change was more recent, no need to add.
                                            needToAdd = false;
                                        end

                                        -- If needToAdd is still true, then we need to remove the old index.
                                        if needToAdd then
                                            table.remove ( GRMsyncGlobals.BanChanges , r );
                                        end
                                    end
                                end

                                -- If needToAdd is still true, then we need to remove the old index.
                                if needToAdd then
                                    table.insert ( GRMsyncGlobals.BanChanges , changeData );
                                end
                            end
                        end
                        break;
                    end
                end
            end
            GRMsyncGlobals.BanReceivedTemp = {};
            if GRMsyncGlobals.SyncOK then
                GRMsync.SendMessage ( "GRM_REQALTDATA" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.CurrentSyncPlayer , GRMsyncGlobals.channelName );
            end
        end
        
        -----------------------------
    -- For Main Change checking!
    -----------------------------
    elseif msg == "MAIN" then
        if #GRMsyncGlobals.MainReceivedTemp == GRMsyncGlobals.NumPlayerDataExpected then  -- { name , isMain , timeStampOfChange }
            for i = 1 , #GRMsyncGlobals.MainReceivedTemp do
                for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do
                    if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == GRMsyncGlobals.MainReceivedTemp[i][1] then
                        -- Alright, now let's see if our data matches up!
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] ~= GRMsyncGlobals.MainReceivedTemp[i][2] then
                            -- If it does, then do nothing... however, if it does, do the following...
                            local addReceived = false;      -- AM I going to add received data, or my own. One or the other needs to be added for sync

                            if ( currentTime - GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][39] ) > ( currentTime - GRMsyncGlobals.MainReceivedTemp[i][3] ) then
                                addReceived = true;         -- In other words, don't add my own data, add the received data.
                            end

                            local changeData;
                            -- Adding Received from other player
                            if addReceived then
                                changeData = GRMsyncGlobals.MainReceivedTemp[i];
                                -- Adding my own data, as it is more current
                            else
                                changeData = { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][10] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][39] };
                            end

                            -- Need to check if change has not already been added, or if another player added info that is more recent! (Might need review for increased performance)
                            local needToAdd = true;
                            for r = 1 , #GRMsyncGlobals.AltMainChanges do
                                if changeData[1] == GRMsyncGlobals.AltMainChanges[r][1] then        -- Player matched! Already added to the "Main" table!
                                    -- If main status is the same, no need to change em!
                                    if changeData[2] == GRMsyncGlobals.AltMainChanges[r][2] or ( currentTime - changeData[3] ) > ( currentTime - GRMsyncGlobals.AltMainChanges[3] ) then
                                        needToAdd = false;
                                    end

                                    -- If needToAdd is still true, then we need to remove the old index.
                                    if needToAdd then
                                        table.remove ( GRMsyncGlobals.AltMainChanges , r );
                                    end
                                end
                            end

                            -- Now let's add it!
                            if needToAdd then
                                table.insert ( GRMsyncGlobals.AltMainChanges , changeData );
                            end
                            
                        end                        
                        break;
                    end
                end
            end

            -- Now, let's purge repeats, as only 1 of an alt-grouping needs to be modified.
            local listToRemove = {};
 
            for i = 1 , #GRMsyncGlobals.AltMainChanges do                                                                                                                                       -- Cycle through all results.
                if GRMsyncGlobals.AltMainChanges[i][2] then                -- Only need to cycle through the alts where they are set to be listed as main, not demoted.
                    for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do                                                                             -- Let's cycle through the metadata!
                        if GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] == GRMsyncGlobals.AltMainChanges[i][1] then                                    -- player found!
                            local altList = GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11];
                            -- Now that I have the altList, I should see if any of them match this main
                            for r = 1 , #altList do
                                for s = 1 , #GRMsyncGlobals.AltMainChanges do
                                    if altList[r][1] == GRMsyncGlobals.AltMainChanges[s][1] then
                                        table.insert ( listToRemove , altList[r][1] );

                                        break;
                                    end
                                end
                            end
                            
                            break;
                        end
                    end
                end
            end
            -- Let's purge the changes!
            while #listToRemove > 0 do
                for i = 1 , #GRMsyncGlobals.AltMainChanges do
                    if GRMsyncGlobals.AltMainChanges[i][1] == listToRemove[1] then
                        table.remove ( GRMsyncGlobals.AltMainChanges , i );
                        break;
                    end
                end
                table.remove ( listToRemove , 1 );
            end
            
            -- Resetting the temp tables!
            GRMsyncGlobals.MainReceivedTemp = {};
            -- Final step of the sync process! Let's submit the final changes!!!
            GRMsync.SubmitFinalSyncData();
        end
    end
end


-- Method:          GRMsync.CheckAltChanges()
-- What it Does:    Compares the Leader's data to the received's data
-- Purpose:         Let's analyze the alt lists!
GRMsync.CheckAltChanges = function()
-- Ok, first things first, I need to compile both tables
-- GRMsyncGlobals.AltReceivedTemp
-- GRMsyncGlobals.AltRemReceivedTemp
    if #GRMsyncGlobals.AltReceivedTemp == GRMsyncGlobals.NumPlayerDataExpected then
        local currentTime = time();
        local leaderListOfAlts = {};
        local leaderListOfRemovedAlts = {};

        -- Let's first get the leader's alt data to compare.
        for j = 2 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ] do

            -- initializing empty tables for each of the leader's players
            table.insert ( leaderListOfAlts , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , {} } );
            table.insert ( leaderListOfRemovedAlts , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][1] , {} } );

            -- Build leader alt Tables for easier coding
            for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11] do
                table.insert ( leaderListOfAlts[ #leaderListOfAlts ][2] , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][i][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][11][i][6] } ); -- AN extra step, but easier to follow in the code.
            end
                    
            -- Building leader removed alt tables.
            for i = 1 , #GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][37] do
                table.insert ( leaderListOfRemovedAlts[ #leaderListOfRemovedAlts ][2] , { GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][37][i][1] , GRM_GuildMemberHistory_Save[ GRM_AddonGlobals.FID ][ GRM_AddonGlobals.saveGID ][j][37][i][6] } ); -- AN extra step, but easier to follow in the code.
            end
        end

        -- Now we can compare!!!

        ----------------------------------------------
        ----- CHECKING AGAINST LEADER'S DATA  --------
        ----------------------------------------------
        local possibleAltsToRemove = {};
        local possibleAltsToAdd = {};

        for i = 1 , #leaderListOfAlts do                                                                -- Cycling through every single player in the guild in leader's database
            for j = 1 , #GRMsyncGlobals.AltReceivedTemp do                                              -- Cycling through the alt list of guildie to receive comparative info!
                if leaderListOfAlts[i][1] == GRMsyncGlobals.AltReceivedTemp[j][1] then                  -- We have a match! Let's compare the alt tables of both players now.

                    -- First, check if any missing.
                    -- Checking if all of leader's data is found in received's
                    local altIsMatched = false;

                    -- STEP 1: LEADER DATA!!!!
                    -- Comparing alt lists held by leader...
                    for r = 1 , #leaderListOfAlts[i][2] do
                        altIsMatched = false;
                        for s = 1 , #GRMsyncGlobals.AltReceivedTemp[j][2] do
                            if leaderListOfAlts[i][2][r][1] == GRMsyncGlobals.AltReceivedTemp[j][2][s][1] then
                                altIsMatched = true;
                                -- if true, it's a match, move on!
                                break;
                            end
                        end

                        -- No match, potentially need to add to Received, or be removed from leader! Must compare timestamps!
                        if not altIsMatched then            -- No match was found. In other words, the leader has an alt listed, but the received player does not!

                            -- Ok, the ONLY way to know what is the correct course of action:
                            -- If I am going to ADD this, I must do 2 things. First, check if the receiving player has them on the removed list, and if so, Second, compare timestamps to know proper action
                            local addLeadersData = false;
                            for m = 1 , #GRMsyncGlobals.AltRemReceivedTemp do
                                if GRMsyncGlobals.AltRemReceivedTemp[m][1] == GRMsyncGlobals.AltReceivedTemp[j][1] then -- Ok, alt remove

                                    -- If there are no added values, no need to do extra work!
                                    if #GRMsyncGlobals.AltRemReceivedTemp[m][2] > 0 then

                                        local altRemMatched = false;
                                        for n = 1 , #GRMsyncGlobals.AltRemReceivedTemp[m][2] do
                                            if GRMsyncGlobals.AltRemReceivedTemp[m][2][n][1] == leaderListOfAlts[i][2][r][1] then           -- Leader's alt DID match the removed!!! Must compare timestamps!!!
                                                altRemMatched = true;
                                                -- We have a match! Must see which was the more current event!!!
                                                if ( currentTime - GRMsyncGlobals.AltRemReceivedTemp[m][2][n][2] ) > ( currentTime - leaderListOfAlts[i][2][r][2] ) then
                                                    -- Leader's time is most recent!!!
                                                    addLeadersData = true;
                                                else
                                                    addLeadersData = false;
                                                end
                                                break;
                                            end
                                        end

                                        if not altRemMatched then           -- Leader's alt was not found among received's removed data.
                                            addLeadersData = true;
                                        end

                                    else
                                        addLeadersData = true;              -- No need to do any work if the received's data has ZERO removed players to begin with!
                                    end

                                    break;
                                end
                            end

                            if addLeadersData then
                                -- If I am going to add it, then make sure it is not on the finalized Remove table, and if it is, compare timestamps
                                -- if it IS to be added to the final ADD table, then ensure it is not already there!
                                GRMsync.AddToProperAltTable ( leaderListOfAlts[i][1] , leaderListOfAlts[i][2][r][1] , leaderListOfAlts[i][2][r][2] , true );
                            else
                                -- If it is to be removed, ensure it is not already on the ADD table, and if it is, compare timestamps.
                                -- IF it IS certain to be removed, ensure that it is not already on the Remove table to avoid double adds.
                                GRMsync.AddToProperAltTable ( leaderListOfAlts[i][1] , leaderListOfAlts[i][2][r][1] , leaderListOfAlts[i][2][r][2] , false );
                            end

                        end

                    end

                    -- STEP2: RECEIVED DATA
                    -- Comparing alt lists held by received...
                    for r = 1 , #GRMsyncGlobals.AltReceivedTemp[j][2] do
                        altIsMatched = false;
                        for s = 1 , #leaderListOfAlts[i][2] do
                            if leaderListOfAlts[i][2][s][1] == GRMsyncGlobals.AltReceivedTemp[j][2][r][1] then
                                altIsMatched = true;
                                -- if true, it's a match, move on!
                                break;
                            end
                        end

                        -- No match, potentially need to add to leader, or be removed from received! Must compare timestamps!
                        if not altIsMatched then            -- No match was found. In other words, the received has an alt listed, but the leader does not!
                    
                            local addAltData = false;
                            -- Ok, the ONLY way to know what is the correct course of action:
                            -- If I am going to ADD this, I must do 2 things. First, check if the leader has them on the removed list, and if so, Second, compare timestamps to know proper action (whichever was most recent.)
                            for m = 1 , #leaderListOfRemovedAlts do
                                if leaderListOfRemovedAlts[m][1] == leaderListOfAlts[i][1] then -- Ok, alt remove

                                    -- If there are no added values, no need to do extra work!
                                    if #leaderListOfRemovedAlts[m][2] > 0 then

                                        local altRemMatched = false;
                                        for n = 1 , #leaderListOfRemovedAlts[m][2] do
                                            if leaderListOfRemovedAlts[m][2][n][1] == GRMsyncGlobals.AltReceivedTemp[j][2][r][1] then           -- Received's alt DID match the removed!!! Must compare timestamps!!!
                                                altRemMatched = true;
                                                -- We have a match! Must see which was the more current event!!!
                                                if ( currentTime - leaderListOfRemovedAlts[m][2][n][2] ) > ( currentTime - GRMsyncGlobals.AltReceivedTemp[j][2][r][2] ) then
                                                    -- Leader's time is most recent!!!
                                                    addAltData = true;
                                                else
                                                    addAltData = false;
                                                end
                                                break;
                                            end
                                        end

                                        if not altRemMatched then           -- Leader's alt was not found among received's removed data.
                                            addAltData = true;
                                        end

                                    else
                                        addAltData = true;              -- No need to do any work if the received's data has ZERO removed players to begin with!
                                    end

                                    break;
                                end
                            end

                            if addAltData then
                                -- If I am going to add it, then make sure it is not on the finalized Remove table, and if it is, compare timestamps
                                -- if it IS to be added to the final ADD table, then ensure it is not already there!
                                GRMsync.AddToProperAltTable ( GRMsyncGlobals.AltReceivedTemp[j][1] , GRMsyncGlobals.AltReceivedTemp[j][2][r][1] , GRMsyncGlobals.AltReceivedTemp[j][2][r][2] , true );
                            else
                                -- If it is to be removed, ensure it is not already on the ADD table, and if it is, compare timestamps.
                                -- IF it IS certain to be removed, ensure that it is not already on the Remove table to avoid double adds.
                                GRMsync.AddToProperAltTable ( GRMsyncGlobals.AltReceivedTemp[j][1] , GRMsyncGlobals.AltReceivedTemp[j][2][r][1] , GRMsyncGlobals.AltReceivedTemp[j][2][r][2] , false );
                            end

                        end
                    end

                    break;
                end
            end
        end

        GRMsyncGlobals.AltReceivedTemp = {};
        GRMsyncGlobals.AltRemReceivedTemp = {};
        -- CHECK MAIN CHANGES NOW!!!
        if GRMsyncGlobals.SyncOK then
            GRMsync.SendMessage ( "GRM_REQMAIN" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.CurrentSyncPlayer , GRMsyncGlobals.channelName );
        end
    end
end

-- Method:          GRMsync.InquireLeader()
-- What it Does:    On logon, or activation of sync alg, it requests in the guild channel if a leader is online.
-- Purpose:         Step 1 of sync algorithm in determining leader.
GRMsync.InquireLeader = function()
    GRMsyncGlobals.IsLeaderRequested = true;
    if GRMsyncGlobals.SyncOK then
        GRMsync.SendMessage ( "GRM_WHOISLEADER" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. "" , GRMsyncGlobals.channelName );
    end
end

-- Method:          GRMsync.SetLeader ( string )
-- What it Does:    If message received, designates the sender as the leader
-- Purpose:         Need to designate a leader!
GRMsync.SetLeader = function ( leader )
    if leader ~= GRM_AddonGlobals.addonPlayerName and leader ~= GRMsyncGlobals.DesignatedLeader then
        GRMsyncGlobals.DesignatedLeader = leader;
        GRMsyncGlobals.LeadershipEstablished = true;

        -- Non leader sends request to sync
        if GRMsyncGlobals.SyncOK then
            GRMsync.SendMessage ( "GRM_REQUESTSYNC" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. "" , GRMsyncGlobals.channelName );
        end
    elseif leader == GRM_AddonGlobals.addonPlayerName then
        GRMsyncGlobals.DesignatedLeader = leader;
        GRMsyncGlobals.LeadershipEstablished = true;
        GRMsyncGlobals.IsElectedLeader = true;

        -- Initiate data sync
        -- After time delay to receive responses, intiate sync after vote... 3 sec. delay. Everyone else request to sync.
        C_Timer.After ( 3 , GRMsync.InitiateDataSync );
    end    
end

-- Method:          GRMsync.InquireLeaderRespond ( string )
-- What it Does:    The new leader will respond out "I AM LEADER" and everyone set him as leader. No need to set as leader as it would have already been done at this point.
-- Purpose:         Sync leadership controls.
GRMsync.InquireLeaderRespond = function ( sender )
    GRMsyncGlobals.IsLeaderRequested = true;
    GRMsyncGlobals.LeadershipEstablished = true;
    if GRMsyncGlobals.SyncOK then
        GRMsync.SendMessage ( "GRM_IAMLEADER" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. "" , GRMsyncGlobals.channelName );
    end
    C_Timer.After ( 3 , GRMsync.InitiateDataSync );
end

-- Method:          GRMsync.ReviewElectResponses ()
-- What it Does:    Reviews timestamps of all online people with addon, and if there is no leader, it elects a new leader.
-- Purpose:         Leadership needs to be established to ensure clean syncing.
GRMsync.ReviewElectResponses = function()

    if #GRMsyncGlobals.ElectTimeOnlineTable > 1 then
        local highestName = GRM_AddonGlobals.addonPlayerName;
        local highestTime = GRMsyncGlobals.timeAtLogin;
        local time = time();

        -- Let's determine who has been online the longest.
        for i = 1 , #GRMsyncGlobals.ElectTimeOnlineTable do
            if ( time - GRMsyncGlobals.ElectTimeOnlineTable[i][1] ) > ( time - highestTime ) then
                highestTime = GRMsyncGlobals.ElectTimeOnlineTable[i][1];
                highestName = GRMsyncGlobals.ElectTimeOnlineTable[i][2];
            end
        end

        -- Send Message out
        if GRMsyncGlobals.SyncOK then
            GRMsync.SendMessage ( "GRM_NEWLEADER" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. highestName , GRMsyncGlobals.channelName );
        end
        -- Establishing leader.
        GRMsync.SetLeader ( highestName );
        

    elseif #GRMsyncGlobals.ElectTimeOnlineTable == 1 then
        -- One result will be established as leader. No need to compare.
        -- Identifying new leader!
        if GRMsyncGlobals.SyncOK then
            GRMsync.SendMessage ( "GRM_NEWLEADER" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRMsyncGlobals.ElectTimeOnlineTable[1][2] , GRMsyncGlobals.channelName );
        end
        -- Sending message out.
        GRMsync.SetLeader ( GRMsyncGlobals.ElectTimeOnlineTable[1][2] );
        

    else
        -- ZERO RESPONSES! No one else online! -- No need to data sync and go further!
        GRMsyncGlobals.DesignatedLeader = GRM_AddonGlobals.addonPlayerName;
        GRMsyncGlobals.IsElectedLeader = true;
        
        -- if no leader was found, and it is just me, do a random check again within the next 45-90 seconds.
        GRMsyncGlobals.LeadSyncProcessing = true;
        GRMsyncGlobals.IsLeaderRequested = false;
        C_Timer.After ( math.random ( 10 , 55 ) , GRMsync.EstablishLeader );

    end

    -- RESET TABLE!
    GRMsyncGlobals.ElectionProcessing = false;
    GRMsyncGlobals.ElectTimeOnlineTable = nil;
    GRMsyncGlobals.ElectTimeOnlineTable = {};

end


-- Method:          GRMsync.RequestElection()
-- What it Does:    To person who just logged in or reactivated syncing, it sends out a request to elect a leader if no leader identified.
-- Purpose:         Need to get time responses from all players to determine who has been online the longest, which will likely have the best data.
GRMsync.RequestElection = function()
    GRMsyncGlobals.ElectionProcessing = true;
    if GRMsyncGlobals.SyncOK then
        GRMsync.SendMessage ( "GRM_ELECT" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. "" , GRMsyncGlobals.channelName );
    end
    -- Let's give it a time delay to receive responses. 3 seconds.
    C_Timer.After ( 3 , GRMsync.ReviewElectResponses );
end


-- Method:          GRMsync.SendTimeForElection()
-- What it Does:    Sends the time logged in or addon sync was enabled
-- Purpose:         For voting, to determine who was online the longest.
GRMsync.SendTimeForElection = function()
    if not GRMsyncGlobals.ElectionProcessing then
        if GRMsyncGlobals.SyncOK then
            GRMsync.SendMessage ( "GRM_TIMEONLINE" , GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] .. "?" .. GRM_AddonGlobals.addonPlayerName .. "?" .. tostring ( GRMsyncGlobals.timeAtLogin ) , GRMsyncGlobals.channelName );
        end
    end
end

-- Method:          GRMsync.ResgisterTimeStamps( string )
-- What it Does:    Adds the player's name and timestamp for election
-- Purpose:         Need to aggregate all the player data for voting!
GRMsync.ResgisterTimeStamps = function ( msg )
    -- Adding { timestamp , name } to the list of people giving their time... 3 second response time valid only.
    table.insert ( GRMsyncGlobals.ElectTimeOnlineTable , { tonumber ( string.sub ( msg , string.find ( msg , "?" ) + 1 ) ) , string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 ) } );
end

-- Method:          GRMsync.ElectedLeader ( string )
-- What it Does:    Established the elected leader based on message received.
-- Purpose:         Final step in designating a leader!
GRMsync.ElectedLeader = function ( msg )
    -- Message should just be the name, so no need to parse.
    GRMsync.SetLeader ( msg );
end


-- Method:          GRMsync.EstablishLeader()
-- What it Does:    Controls the algorithm flow for syncing data between players by establishing leader.
-- Purpose:         To have a healthy, lightweight, efficient syncing addon.
GRMsync.EstablishLeader = function()
    -- "Who is the leader?"
    if not GRMsyncGlobals.IsLeaderRequested then
        GRMsync.InquireLeader();
    end

    C_Timer.After ( 5 , function ()
        -- No responses, no leader! Setup an election for the leader!
        if not GRMsyncGlobals.LeadershipEstablished then
            GRMsync.RequestElection()
            
        end    
    end);
end

-- Method:          GRMsync.FinalAnnounce()
-- What it Does:    Initiates a final announcement that the sync is complete... useful for player info.
-- Purpose:         So the player can easily determine the beginning AND the end of the sync process.
GRMsync.FinalAnnounce = function()

    if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][16] then
        chat:AddMessage ( "GRM: Sync With Guildies Complete..."  , 1.0 , 0.84 , 0 );
    end
end

-------------------------------
------ INITIALIZING -----------
-------------------------------

-- Method:          GRMsync.RegisterCommunicationProtocols()
-- What it Does:    Establishes the channel communication rules for sending and receiving
-- Purpose:         Need to make rules to get this to behave properly!
GRMsync.RegisterCommunicationProtocols = function()
    GRMsync.MessageTracking:RegisterEvent ( "CHAT_MSG_ADDON" );
    -- Register used prefixes!
    GRMsync.RegisterPrefixes ( GRMsyncGlobals.listOfPrefixes );

    -- Setup tracking...
    GRMsync.MessageTracking:SetScript ( "OnEvent" , function( self , event , prefix , msg , channel , sender )
        if not GRMsyncGlobals.SyncOK or not IsInGuild() then
            GRMsync.MessageTracking:UnregisterAllEvents();
        else
           
            if event == "CHAT_MSG_ADDON" and channel == GRMsyncGlobals.channelName and GRMsync.IsPrefixVerified ( prefix ) then     -- Don't need to register my own sends.
               
                 -- Let's format the sender info for ease!
                -- sender = GRMsync.SyncName ( sender , "enGB" ) -- This will eventually be localized
                if sender ~= GRM_AddonGlobals.addonPlayerName then

                    -- Let's strip out the rank requirement of the sender, so it avoids syncing with people not of required rank.
                    local senderRankRequirement = tonumber ( string.sub ( msg , 1 , string.find ( msg , "?" ) - 1 ) );

                    -- Need to do a rank check here to accept the send or not. -- VERIFY PREFIX BEFORE CHECKING!
                    
                    if sender ~= GRMsyncGlobals.DesignatedLeader and ( GRM.GetGuildMemberRankID ( sender ) >= GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][15] or senderRankRequirement <= GRM.GetGuildMemberRankID ( GRM_AddonGlobals.addonPlayerName ) ) then        -- If player's rank is below settings threshold, ignore message.
                        return
                    end
                    
                    -- parsing out the rankRequirementOfSender
                    msg = string.sub ( msg , string.find ( msg , "?" ) + 1 );
                    ------------------------------------------
                    ----------- LIVE UPDATE TRACKING ---------
                    ------------------------------------------

                    -- Varuious Prefix Logic handling now...
                    if prefix == "GRM_JD" then
                        GRMsync.CheckJoinDateChange ( msg , sender , prefix );
                    
                    -- On a Promotion Date Edit
                    elseif prefix == "GRM_PD" then
                        GRMsync.CheckPromotionDateChange ( msg , sender , prefix );

                    -- If person added to Calendar... this event occurs.
                    elseif prefix == "GRM_AC" then
                        GRMsync.EventAddedToCalendarCheck ( msg , sender );
                    
                    -- For adding an alt!
                    elseif prefix == "GRM_ADDALT" then
                        GRMsync.CheckAddAltChange ( msg , sender , prefix );
                
                    -- For Removing an alt!
                    elseif prefix == "GRM_RMVALT" then
                        GRMsync.CheckRemoveAltChange ( msg , sender , prefix );
                
                    -- For declaring who is to be "main"
                    elseif prefix == "GRM_MAIN" then
                        GRMsync.CheckAltMainChange ( msg , sender );
                
                    -- For demoting from main -- basically to set as no mains.
                    elseif prefix == "GRM_RMVMAIN" then
                        GRMsync.CheckAltMainToAltChange ( msg , sender );
                
                    -- For ensuring bans are shared!
                    elseif prefix == "GRM_BAN" then
                        GRMsync.CheckBanListChange ( msg , sender );

                
                    
                    --------------------------------------------
                    -------- RETROACTIVE SYNC TRACKING ---------
                    --------------------------------------------

                    -- In response to asking "Who is the leader" then ONLY THE LEADER will respond.
                    elseif prefix == "GRM_WHOISLEADER" and GRMsyncGlobals.IsElectedLeader then
                            GRMsync.InquireLeaderRespond( sender );

                    -- Updates who is the LEADER to sync with!
                    elseif prefix == "GRM_IAMLEADER" then
                        GRMsync.SetLeader ( sender );

                    -- For an election...
                    elseif prefix == "GRM_ELECT" then
                        GRMsync.SendTimeForElection ();

                    -- For sending timestamps out!
                    elseif prefix == "GRM_TIMEONLINE" and not GRMsyncGlobals.LeadershipEstablished then -- Only the person who sent the inquiry will bother reading these... flow control...
                        GRMsync.ResgisterTimeStamps ( msg );
                        
                    -- For establishing the new leader after an election
                    elseif prefix == "GRM_NEWLEADER" then
                        GRMsync.ElectedLeader ( msg )
                    

                    -- LEADERSHIP ESTABLISHED, NOW LET'S SYNC COMMS!

                    -- Only the leader will hear this message!
                    elseif prefix == "GRM_REQUESTSYNC" and GRMsyncGlobals.IsElectedLeader then
                        table.insert ( GRMsyncGlobals.SyncQue , sender );
                    
                    -- PLAYER DATA REQ FROM LEADERS
                    -- Leader has requesated your Join Date Data!
                    elseif prefix == "GRM_REQJDDATA" and msg == GRM_AddonGlobals.addonPlayerName then
                        -- Start forwarding Join Date data...
                        GRMsync.SendJDPackets();

                    elseif prefix == "GRM_REQPDDATA" and msg == GRM_AddonGlobals.addonPlayerName then
                        -- Start forwarding Promo Date data
                        GRMsync.SendPDPackets();

                    elseif prefix == "GRM_REQBANDATA" and msg == GRM_AddonGlobals.addonPlayerName then
                        -- Forwarding ban/unban data request.
                        GRMsync.SendBANPackets();
                    elseif prefix == "GRM_REQALTDATA" and msg == GRM_AddonGlobals.addonPlayerName then
                        -- Checking for new alts that have been added!
                        GRMsync.SendAltPackets();
                        -- forwarding player MAIN status.
                    elseif prefix == "GRM_REQMAIN" and msg == GRM_AddonGlobals.addonPlayerName then
                        GRMsync.SendMainPackets();


                    -- DATA FLOW INITIATION AND STOP CONTROLS
                    -- Initializes the starting value
                    elseif prefix == "GRM_START" and GRMsyncGlobals.IsElectedLeader and sender == GRMsyncGlobals.CurrentSyncPlayer then
                        GRMsyncGlobals.NumPlayerDataExpected = tonumber ( msg );

                    -- Stop collecting, start processing!
                    elseif prefix == "GRM_STOP" and GRMsyncGlobals.IsElectedLeader and sender == GRMsyncGlobals.CurrentSyncPlayer then
                        GRMsync.CheckChanges ( msg );

                    -- Stop collecting ALT data, start processing alt changes!
                    elseif prefix == "GRM_STOPALTREM" and GRMsyncGlobals.IsElectedLeader and sender == GRMsyncGlobals.CurrentSyncPlayer then
                        GRMsync.CheckAltChanges ();

                    -- Collect all data before checking for changes!
                    elseif ( prefix == "GRM_JDSYNC" or prefix == "GRM_PDSYNC" or prefix == "GRM_BANSYNC" or prefix == "GRM_MAINSYNC" ) and GRMsyncGlobals.IsElectedLeader and sender == GRMsyncGlobals.CurrentSyncPlayer then
                        GRMsync.CollectData ( msg , prefix );            

                    -- For ALT ADD DATA
                    elseif prefix == "GRM_ALTADDSYNC" and GRMsyncGlobals.IsElectedLeader and sender == GRMsyncGlobals.CurrentSyncPlayer then
                        GRMsync.CollectAltAddData ( msg );

                    -- For ALT REMOVE DATA
                    elseif prefix == "GRM_ALTREMSYNC" and GRMsyncGlobals.IsElectedLeader and sender == GRMsyncGlobals.CurrentSyncPlayer then
                        GRMsync.CollectAltRemData ( msg );



                    -- AFTER DATA RECEIVED AND ANALYZED, SEND UPDATES!!!
                    -- THESE WILL HEAD TO THE SAME METHODS AS LIVE SYNC, WITH A COUPLE CHANGES BASED ON UNIQUE MESSAGE HEADER.
                    -- Sync the Join Dates!
                    elseif prefix == "GRM_JDSYNCUP" then 
                        GRMsync.CheckJoinDateChange ( msg , sender , prefix );

                    -- Sync the Promo Dates!
                    elseif prefix == "GRM_PDSYNCUP" then
                        GRMsync.CheckPromotionDateChange ( msg , sender , prefix );

                    -- Final sync of ban player info
                    elseif prefix == "GRM_BANSYNCUP" then
                        GRMsync.BanManagementPlayersThatLeft ( msg , sender , prefix );

                    -- Final sync of ALT player info
                    elseif prefix == "GRM_ALTSYNCUP" then
                        GRMsync.CheckAddAltChange ( msg , sender , prefix );

                    -- Final sync of Removing alts
                    elseif prefix == "GRM_REMSYNCUP" then
                        GRMsync.CheckRemoveAltChange ( msg , sender , prefix );
                    
                    -- Final sync on Main Status
                    elseif prefix == "GRM_MAINSYNCUP" then
                        GRMsync.CheckMainSyncChange ( msg );

                    -- Final Announce!!!
                    elseif prefix == "GRM_COMPLETE" then
                        GRMsync.FinalAnnounce ();
                    end
                end
            end
        end
    end);

    GRMsyncGlobals.RulesSet = true;
end

-- Method:          GRMsync.BuildSyncNetwork()
-- What it Does:    Step by step of my in-house sync algorithm custom built for this addon. Step by step it goes!
-- Purpose:         Control the work-flow of establishing the sync infrastructure. This will not maintain it, just builds the initial rules
--                  and the server-side channel of communication between players using the addon. Furthermore, by compartmentalizing it, it controls the flow of actions
--                  allowing a recursive check over the algorithm for flawless timing, and not moving ahead until the proper parameters are first met.
GRMsync.BuildSyncNetwork = function()  
    -- Rank necessary to be established to keep'
    if IsInGuild() then
        if not GRMsyncGlobals.DatabaseLoaded then
            GRMsync.WaitTilDatabaseLoads();
        end

        -- Let's get the party started! Establishing rules then communication should be good to go!
        if GRMsyncGlobals.DatabaseLoaded and not GRMsyncGlobals.RulesSet then
            GRMsyncGlobals.timeAtLogin = time();                                   -- Timestamp needs to be reset everytime tracking starts. Don't want to
            GRMsync.RegisterCommunicationProtocols();
        end

        -- Redundancy in case it fails to load.
        if GRMsyncGlobals.DatabaseLoaded and not GRMsyncGlobals.RulesSet then
            C_Timer.After ( 2 , GRMsync.BuildSyncNetwork );
        end
        
        -- We need to set leadership at this point.
        if GRMsyncGlobals.DatabaseLoaded and GRMsyncGlobals.RulesSet and not GRMsyncGlobals.LeadershipEstablished and not GRMsyncGlobals.LeadSyncProcessing then
            GRMsyncGlobals.LeadSyncProcessing = true;
            GRMsync.EstablishLeader();
        end
    end
end

-- ON LOADING!!!!!!!
-- Event Tracking
GRMsync.Initialize = function()
    if GRMsyncGlobals.SyncOK then
        if GRM_AddonSettings_Save[GRM_AddonGlobals.FID][GRM_AddonGlobals.setPID][2][14] and IsInGuild() then
            GRMsync.ResetDefaultValuesOnSyncReEnable();
            GRMsync.ResetReportTables();
            GRMsync.ResetTempTables();
            GRMsyncGlobals.LeadershipEstablished = false;
            GRMsyncGlobals.LeadSyncProcessing = false;
            GRMsync.MessageTracking = GRMsync.MessageTracking or CreateFrame ( "Frame" , "GRMsyncMessageTracking" );
            GRMsync.BuildSyncNetwork();
        end
    end
end

